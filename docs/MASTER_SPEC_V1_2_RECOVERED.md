# Requisitos v1.2 recuperados do histórico

**Este arquivo é uma consolidação de recuperação, não o anexo original v1.2.**
O original completo não está nos dois ZIPs reenviados nem no GitHub. As adições
v1.1/v1.2 abaixo foram recuperadas dos diffs e instruções registrados na conversa.
Devem ser lidas junto da MasterSpec original preservada. Se o anexo reaparecer,
compará-lo integralmente antes de declarar correspondência documental exata.

## Runtime, arquitetura e inventário

- Fixar revisão FU e OpenStarbound e registrar versões realmente testadas no jogo.
- Sistema atual de nove genes/18 caracteres; não adaptar automaticamente a futuras
  mudanças de formato, tags ou semântica. Reauditar mudanças upstream.
- Container verdadeiro, três slots reais, UI de container scriptável; sem metaGUI,
  ScriptPane com slots proxy ou arquitetura alternativa silenciosa.
- Footprint 5×4, máquina de chão, sprite estático/orientação única, printable=false.
  Placement evita sobreposição; colisão fina deve acompanhar o corpo sólido.
- Slots livres para inserção/extração manual e ITD; nenhuma correção de Shift+Click,
  filtros ou proteção semântica de outputs. Não exigir botão Take All customizado.
- Sem consumo de energia, fila normal, varredura externa ou simulação offline.
  Pequeno stagger inicial é permitido, não obrigatório; preservar ~1 ciclo/s.

## Adapter — estrutura e precedência (13.2, 15, 17)

Normalizar formas abreviadas válidas do engine antes da leitura semântica.
Descriptor canônico: name string não vazia, count inteiro finito >=1 e parameters
como tabela. Count ausente vira 1; parameters ausente vira {}. Parameters inválido
ou count zero, negativo, fracionário, não numérico, NaN/infinito é INVALID_DESCRIPTOR
antes de testar tags. Nil do slot é vazio e não deve chegar ao Adapter pelo motor.

Ordem: INVALID_DESCRIPTOR → tag bee → queen/youngQueen → inspeção pela truthiness
Lua do FU → genome 18 caracteres 0-9A-Z → family → subtype → seis raws válidos.
Queen não inspecionada e sem genome retorna NOT_INSPECTED. Os 18 caracteres
inteiros são validados, inclusive miteResistance/workTime, sem armazenar/comparar
esses dois traits. Family vem entre primeiro e segundo underscores e deve existir
em beeData.stats. Subtype deve existir; entrada sem nome utilizável é INVALID_GENOME.
Não inferir identidade por texto de apresentação nem inventar nome.

## Perfil e processamento (20.4, 22.4–22.5, 23.5, 30, 33, 35)

- Persistir raws, não genome inteiro ou display. referenceDisplay deriva da raw
  persistida via genelib.numberToStat + genelib.statToValue, inclusive perfil composto.
- Perfil completo: family/subtype/subspeciesName e seis referências inteiras 0..1295.
  Incompletude limpa profile/references com warning, preservando modos válidos.
  Modos ausentes usam gte; inválidos voltam a gte com warning.
- Não criar revision/version/generation/approvedCount/processedCount ou CAS,
  optimistic locking, expectedRevision, conflitos ou merge entre panes.
- setMode muda apenas o modo, nunca recalcula/apaga referência. Modos disponíveis
  antes da baseline. Primeira válida inicializa todas as referências, sem comparação.
- AND, igualdade inclusiva, Mutation Chance sem inversão; rejeição não atualiza refs;
  aprovação atualiza somente ativos; ignore congela a referência até futura aprovação.
- Reset imediato, preserva modos/itens, limpa profile/references e lastResult=NONE.
  Status é recalculado dos slots; Reset não força WAITING_INPUT com saída ocupada.
- Cada decisão usa cópias coerentes de profile/references/modes, em ciclo síncrono
  sem yield, Promise ou RPC no meio da decisão/movimentação.
- Revalidar nome e parâmetros completos, ignorando somente count; confirmar ao
  menos uma unidade disponível e ambas as saídas vazias antes de retirar uma unidade.
- Commit apenas após inserção confirmada. Ciclos abortados não mudam lastResult.
  lastResult persiste em waiting/reload e só muda com processamento comprometido/Reset.
- Status é derivado: recoveryEscrow → RECOVERY_HOLD; saída ocupada → WAITING_OUTPUTS;
  Input vazio → WAITING_INPUT; processamento → PROCESSING (pode ser imperceptível).

## Recuperação excepcional v1.2 (34.1–34.2)

Após falha de inserção de unidade já retirada, preservar descriptor exato e não
alterar profile/references/lastResult. Tentar Input real e conferir leftover.
Se falhar, tentar spawnItem na máquina e exigir EntityId válido para confirmar.
Pequeno conjunto determinístico de posições adjacentes é permitido, não obrigatório.
Registrar warning após recuperação; não assumir sucesso só por chamar spawnItem.

Se rollback e todas as tentativas de drop retornarem falha/nil:

- preservar exatamente uma unidade em storage.recoveryEscrow com parâmetros completos;
- entrar em RECOVERY_HOLD e bloquear todo processamento normal;
- os três slots reais continuam livres para jogador/ITD; escrow não é quarto slot,
  fila, Approved, Rejected ou candidata, nem mecanismo de throughput;
- Reset não apaga/modifica escrow; ele persiste e tem prioridade após reload;
- por processing tick, tentar Input se vazio, senão/também drop seguro;
- limpar escrow somente após sucesso físico confirmado e retomar genética no tick seguinte;
- ao destruir, tentar soltar apenas a unidade de escrow uma única vez, sem duplicar
  os conteúdos que o container nativo já solta;
- falha final de spawn na destruição registra ERROR/FATAL com descriptor para diagnóstico,
  como falha de runtime fora da garantia normal; não criar commit genético fictício.

É a única exceção à proibição de buffer oculto; nenhum journal multi-item,
transaction log ou fila persistente de resultados é autorizado.
O diff preservado não determina a semântica de exceção com efeito incerto no spawn;
o tratamento adotado é explicitado em IMPLEMENTATION_STATUS e não promete atomicidade.

## GUI e multiplayer (37.2, 38, 42–47)

- Objeto autoritativo, estado compartilhado, último comando aplicado prevalece.
- Snapshots sem revision. No máximo uma consulta passiva pendente por pane.
- Uma mutação local pendente por pane; pausar refresh durante ela e descartar
  respostas passivas anteriores mesmo se terminarem depois do comando. Retomar
  polling após resposta autoritativa. Isso não bloqueia outros jogadores.
- Impedir callbacks de mutação ao atualizar radio groups programaticamente.
- Se entidade desaparecer, parar polling/comandos e invalidar/fechar pane.
- Allowlist de traits/modos no objeto; envelope {ok,error,state} é recomendado,
  não obrigatório. Não manter snapshot órfão ou recriar objeto pela GUI.
- Mostrar zero válido e travessão sem perfil. Identidade usa valores canônicos;
  capitalização de apresentação é opcional. Tooltips individuais são recomendados.

## Crafting, testes e release

Blueprint aprendido por pickup de Bee Station é permanente; crafting exige estação.
Patch não destrutivo preserva blueprints existentes; saves antigos precisam recolher
novamente Bee Station. IDs e quantidades originais permanecem.

Além da matriz original: A13 caracteres nos genes excluídos; A14–A18 parameters/count,
normalização, precedência e stack; G7–G11 modos antes da baseline, refs congeladas,
display composto, pane sem entidade e callbacks; P3 destruição com três slots;
T5 fallback drop; T6–T8 escrow, recuperação e reload; M7 ausência de revisão; U1 unlock
permanente. Resultados de mocks não satisfazem gates de engine/release.
