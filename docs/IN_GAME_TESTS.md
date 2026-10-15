# Validação no OpenStarbound — todos os itens pendentes

Registrar build/commit OpenStarbound, versão FU, commit do addon, mods, data,
resultado e trechos de starbound.log. Não marcar como executado por mocks.

- [ ] Instalar fubeesgenetics-mvp-0.1.6-dev.pak em Starbound/mods e abrir via OpenStarbound,
  sem erros de assets/scripts/dependência. Não manter cópia descompactada ou
  assinatura Workshop duplicada. Testar também a instalação por assinatura
  Workshop quando publicada, com conteúdo contents.pak gerenciado pela Steam.
- [ ] A1–A18: Queen/Young Queen analisadas reais, casta por tags, wild separado,
  vida restante independente, inspeção truthy, estrutura inteira e erros em genes
  excluídos, defaults e precedência de descriptors; comparar valores com tooltip FU.
- [ ] Probe opcional com root real: require do script adapterprobe e
  fubeesgenetics_adapterprobe.run(); ele não adiciona itens físicos.
- [ ] Container: três slots nativos, visual Approved/Input/Rejected e offsets 1/0/2;
  drag/drop, right-click, stacks, shift-transfer e inserção manual nas saídas livres.
- [ ] B1–B3/G7: pré-configurar ignore/lte antes da primeira válida; baseline aprova
  sem comparar, inicializa seis refs e preserva modos.
- [ ] C1–C8/G8: igualdade inclusiva, todos ativos precisam passar, mudança de modo
  sem processar não muda raw. Exemplo 500/99 rejeita sem melhorias parciais.
- [ ] G9: ignore congela raw, reativação usa valor antigo, Mutation display confere
  com genelib e não usa última candidata. Zero aparece como zero.
- [ ] L1–L4: family/subtype distinguem linhagem; casta não; todos ignorados ainda
  rejeitam incompatível.
- [ ] O1–O4: qualquer saída ocupada bloqueia antes de analisar Input; limpar ambas
  libera ciclo. Uma unidade/s com GUI fechada, sem simulação offline própria.
- [ ] R1–R4: Reset imediato preserva modos/itens/escrow; lastResult=NONE e status
  reflete saídas ocupadas ou RECOVERY_HOLD.
- [ ] P1/P3: save/reload preserva perfil/refs/modos/lastResult; quebra com itens nos
  três slots não perde/duplica, recolocar não exige serialização genética especial.
- [ ] T1–T5: corrida de Input/output, quantidade vs parâmetros, falha de take/put,
  rollback ou drop exato sem commit de refs/lastResult. Induzir com harness se possível.
- [ ] T6: forçar falha output/Input/drop, conferir uma unidade em escrow, estado
  RECOVERY_HOLD, slots livres para interação e nenhuma nova genética.
- [ ] T7: liberar Input ou drop recupera uma vez; limpar escrow só após confirmação;
  genética volta no tick seguinte, sem commit retroativo.
- [ ] T8: save/reload em hold mantém descriptor e recupera antes de processar Input.
- [ ] Destruir com escrow tenta um drop adicional só do escrow, sem duplicar os
  três slots; falha final registra FATAL e descriptor.
- [ ] I1–I5: ITD insere 0, extrai 1/2; saída preenchida pelo ITD bloqueia. Sem
  roteamento mágico, filtros ou proteção dos slots.
- [ ] M1–M7: duas GUIs, last-write-wins natural, sem contador/locks; mudanças
  convergem após refresh. Uma mutação pendente por pane; resposta de read anterior
  deve ser descartada mesmo quando chega após a resposta do comando.
- [ ] Seletores: nas seis linhas, clicar Equal or higher, Equal or lower e Indifferent; aguardar atualização,
  fechar/reabrir a interface e save/reload para confirmar modos persistidos.
  Alterar modo sem processar item não deve mudar as referências genéticas.
- [ ] G10/G11: quebrar com pane aberta encerra consultas/comandos; atualizar radios
  programaticamente não envia novo setMode.
- [ ] Tooltips: quatro textos individuais em headers/controles e referências,
  delay 0,35 s, sem capturar mouse/teclado ou bloquear tooltips de itens; clipping,
  escala, fontes, todas as opções e Reset legíveis.
- [ ] U1: obter/reobter Bee Station ensina blueprint permanentemente; retirar estação
  do inventário não apaga aprendizado; craft segue exigindo Bee Station/Functional.
- [ ] Receita: 2 aichip, 5 laserdiode, 5 skathreinforcedglass, 10 titaniumbar,
  10 liquidhealing, 5 liquidsulphuricacid e 2 unknowngene; manter
  blueprints de outros mods e ausência de rota Pixel Printer.
- [ ] Placement 5×4, chão/anchors, colisão fina sem parede invisível em transparências,
  espelhamento esquerda/direita por direção na colocação, preview e sprite estático.
- [ ] Recuperar e integrar a arte final aprovada; conferir original integral v1.2;
  validar o tema GUI aprovado antes de release.

Não repetir automaticamente spawn com efeito desconhecido por exceção: registrar
estado/logs e diagnosticar antes de reload. Falha do engine na destruição fica
fora da garantia normal. Concluir todos os critérios de release da diretriz.

## Reteste visual 0.1.3-dev

- [ ] Fundo, moldura, DNA, cabeçalho e status legíveis na escala usada pelo jogador.
- [ ] Seletores nas seis linhas: normal/hover/selecionado; mudança permanece ao reabrir.
- [ ] Reset, fechar, tooltips e três slots conservam suas áreas de interação.
- [ ] Comparar o perfil/modos existentes antes/depois e repetir o fluxo ITD já validado.

Relato recebido: o usuário confirmou funcionamento perfeito dos seletores e
ITD 100% funcional na 0.1.2-dev. Topologia e demais cenários não foram detalhados.

## Reteste visual 0.1.5-dev

- [ ] Approved/Input/Rejected: a mesma moldura permanece ao inserir/remover itens.
- [ ] Queen/Young Queen, larva e itens comuns ficam centralizados, sem deslocar
  para a borda superior/direita, com contagem e indicação de raridade nativas.
- [ ] Tooltip, clique direito e Shift+Click funcionam em cada slot, inclusive vazio.
- [ ] Perfil/modos existentes e fluxo ITD permanecem funcionais.

## Reteste visual 0.1.6-dev

O usuário confirmou que as alterações da 0.1.5 funcionaram perfeitamente.
Esse relato não detalha a execução de cada cenário acima.

- [ ] Setas para cima/baixo e os três nomes completos legíveis e sem colisão.
- [ ] Nas seis linhas, as três opções continuam selecionáveis e persistem.
- [ ] Status e Last result abaixo da divisória, sem tocar a borda inferior.
- [ ] Reset Profile centralizado no botão, incluindo hover/pressionado.
- [ ] Perfil existente e slots preservados ao substituir o PAK, sem reset.

## Segunda máquina — Bee Exchange 0.2.0-dev

O roteiro de [BEE_EXCHANGE_0_2_0](BEE_EXCHANGE_0_2_0.md#reteste-no-jogo) cobre
receita/desbloqueio, trocas, GUI fechada, lotes de cinco Drones, itens ignorados,
inventário cheio, ITD, save/reload e destruição. Esses testes ainda não foram
executados dentro do OpenStarbound; os 120 grupos automatizados usam bindings
de engine simulados.

## Bee Exchange — interface 0.2.1-dev

Validar [roteiro de interface](BEE_EXCHANGE_UI_0_2_1.md#instalação-e-reteste):
20 slots marcados, vazio/ocupado, centro dos itens, contagem, tooltip, clique
direito, Shift+Click e Take all. Repetir trocas automáticas e ITD.
Esses checks ainda não foram executados no jogo.

## Bee Exchange — 0.2.2-dev

Executar o [reteste 0.2.2](BEE_EXCHANGE_0_2_2.md#instalação-e-reteste):
conservação de conteúdo do save, 24 slots, trocas nos novos offsets 20–23,
ITD 0–23, sprite do FU e placa Auto Refugee sobre o chão, animação de envio/fechamento/
reabertura e sons ao vender. Pendente no jogo.
