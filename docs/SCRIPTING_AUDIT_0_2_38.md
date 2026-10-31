# Auditoria de scripting de todo o conteúdo — 0.2.38-dev

Base revisada: `70e917f43c80efa2c7d2eea5bc516efaa57e4a2b` (0.2.37-dev).
Aplicação da política [SCRIPTING_PERFORMANCE](SCRIPTING_PERFORMANCE.md) e da
[skill do projeto](../.agents/skills/starbound-scripting-performance/SKILL.md).

## Inventário de caminhos executados

Foram revisadas as cinco definições `.object`, as três `.item`, as duas panes,
os patches dos dois apiários FU e da janela IC, além de todos os módulos Lua
próprios, receitas e dados de pesquisa. Nenhum item novo recebeu loop de script.

| Conteúdo | Execução necessária / decisão |
| --- | --- |
| Genetic Queen Filter | Controlador `scriptDelta=30`, vazão máxima 1 unidade/s; garantias da 0.2.37 mantidas. Pane de 60 para 30 callbacks/s a 60 ticks/s, polling ainda 1 s e comandos imediatos. |
| Auto Refugee | Controlador `scriptDelta=10`, até uma receita por slot por ciclo de 1 s. Eliminadas leituras completas para slots vazios, recursos e itens não negociáveis; snapshots necessários usam a API bulk. |
| Overload Apiary | `scriptDelta=5` preservado para a rede FU; leitura fixa de 12 W somente no init; sem decodificação extra do bônus de produção quando sem energia. |
| Overload Large Apiary | Mesmo controlador e regras de energia/produção do pequeno; a verificação de híbridas reutiliza o snapshot nativo, inclusive nos dois slots de drones. |
| Genetic Hybridizer | `scriptDelta=30`, até 24 W e 10.000 energia por tentativa preservados; potência lida no init e tags imutáveis em cache limitado. Carga antecipada, consumo parcial da fonte e revalidação dos progenitores mantidos. |
| Queen, Young Queen e Drone híbridos | Builder de criação/apresentação, sem update periódico. Sprite, nome, subtítulo, lifebar e genética preservados. Removida uma lista derivada que era criada e não usada pelo builder visual. |
| Apiários pequeno e grande do FU | Configuração e cadência nativas preservadas. Patch carrega a lógica híbrida apenas quando a leitura nativa do tick contém híbridas; sem leituras extras de slots para essa detecção. |
| Pane do Hybridizer | `scriptDelta=15` e consulta de 2 s preservados; textos escritos somente se mudarem; uma leitura de existência por update, sem consulta duplicada ao solicitar estado. |
| Ponte de janela IC | Outros contêineres de 16 slots retomam o callback original do provedor, sem wrapper periódico do addon. Auto Refugee mantém o acknowledgement antes de sort/quickstack. |
| Compatibilidade/aging | Detecção do provedor ocorre no init ou primeiro aging; resolução já era tardia e cacheada. Não foi criado polling adicional. |
| Adapter, contratos e inventário | Helpers sem update próprio; tags compartilhadas em cache limitado a 128 nomes por contexto. Dados mutáveis dos espécimes continuam sendo validados. |
| Probe de desenvolvimento | Sem registro em objetos e sem execução automática; só cria descritores quando explicitamente chamado. |
| Receitas, pesquisas, sprites e frames | Assets declarativos, sem scripts recorrentes adicionais. |

As frequências em callbacks/s pressupõem simulação a 60 ticks/s. O engine pode
atrasar a execução; `scriptDelta` não é uma garantia de tempo de CPU nem de
intervalo de parede.

## Auto Refugee: menos travessias de bindings

Antes, `exchange()` chamava `contents()` para cada um dos 16 slots; cada chamada
fazia 16 leituras individuais. Uma máquina vazia ou contendo apenas recursos
fazia 256 chamadas `containerItemAt` por ciclo.

Agora cada slot recebe uma consulta inicial leve. Só candidatos negociáveis
provocam a leitura completa, com `world.containerItems`, API já usada pelo FU.
O hint não é autoridade: o planejamento relê o inventário real, e cada fonte é
comparada novamente imediatamente antes da retirada.

| Cenário controlado | Antes | Depois |
| --- | ---: | ---: |
| Máquina vazia ou com itens não negociáveis, por ciclo | 256 leituras individuais | 16 leituras individuais, zero snapshots completos |
| Snapshot completo necessário | 16 chamadas individuais | 1 chamada bulk |
| Releitura pré-retirada e confirmação pós-inserção | presentes | preservadas |

A redução de 93,75% no primeiro cenário se refere apenas às leituras individuais
de inventário, não ao custo total da máquina. Cópias e comparações agora usam
os helpers compartilhados, sem instalar wrappers no objeto nem reconstruir
espécimes. `root.itemConfig` permanece atualizado por descritor para respeitar
limites de stacks e parâmetros; não há cache de inventário ou de saldos.

## Apiários: snapshot nativo e cache restrito ao tick

`apiaryhybridloader.lua` usa `checkRivalries`, que o FU fixado chama logo após
`contents = world.containerItems(...)`. A detecção é feita nesse snapshot e a
instalação é concluída antes dos cálculos de produção do mesmo tick. Apiários
sem híbridas não carregam a implementação híbrida nem as plantas. A detecção
não acrescenta as antigas 2/3 leituras individuais de slots por tick.

No módulo híbrido, a afinidade de flores pode ser pedida pela rainha e por
vários drones no mesmo tick. Agora há no máximo uma consulta por espécie
híbrida durante esse tick. O cache nasce somente ao consultar flores e é limpo
ao terminar o tick, inclusive após exceção. Chamadas diretas fora do tick,
próximos ticks e iterações de simulação descarregada consultam o mundo de novo.
Ele não persiste, não conserva entidades entre ticks e só pode conter as
espécies consultadas no passe corrente do apiário de slots fixos.

A leitura de linhagem evita recriar a lista parental quando já está correta e
reaproveita o subtipo decodificado na validação. Genome e linhagem continuam
sendo verificados a cada uso; o FU pode alterar espécimes durante o próprio tick.

## Escolhas preservadas para manter a correção

- A frequência de energia dos Overload não foi reduzida: fontes FU sem bateria
  possuem disponibilidade por update. Agrupar o consumo poderia mudar bônus e
  produção mesmo mantendo a demanda nominal de 12 W.
- A Auto Refugee continua reaplicando a tag de orientação antes de gates IC e
  on/off. Há regressão explícita para reparar tags sobrescritas externamente;
  cachear apenas `object.direction()` deixaria essa reparação incorreta.
- A frequência de objeto e os locks do IC continuam iguais. Os scripts originais
  do provedor não são editados nem copiados para o mod.
- A carga parcial do Hybridizer mantém as consultas necessárias ao protocolo
  `fupower`, em vez de substituir funções globais para reutilizar saldos.
- Builders/normalização, revalidações, rollback, escrow, confirmação por delta,
  offsets ITD e cadastro periódico de contêineres foram preservados.
- Potência é configuração fixa de cada máquina, lida novamente a cada init;
  esta versão não cria configuração dinâmica de potência em runtime.

## Validação e limites

Foram acrescentadas regressões para contagens de leituras e widgets, detecção
híbrida sem bindings redundantes, consulta floral durante produção real de um
apiário grande com dois drones, invalidação após tick/exceção, tags imutáveis
com genome mutável, leitura de potência no init, e guardas da janela IC.
As suítes existentes continuam verificando os 105 negócios FU, casos de
retorno legado, conservação de itens, reload e genética das 595 combinações.

Essas evidências executam Lua de produção e referências FU fixadas com bindings
simulados. Não são um benchmark dentro do jogo. Os testes isolados da ponte IC
não substituem a suíte opcional com o código original Improved Containers 2.11,
que não foi executada nesta revisão por falta desse pacote no ambiente.

A validação completa e o empacotamento são executados pelo GitHub Actions.
Nenhum PAK foi gerado localmente. Esta alteração permanece em dev, sem PR ou
promoção para main.

## Medição e reteste no jogo

Comparar os artefatos Actions de 0.2.37-dev e 0.2.38-dev, uma instalação por vez,
com os mesmos mods, mundo, localização, população de abelhas e rede. Guardar
backup antes de alternar versões. Registrar aquecimento e amostras sustentadas.

1. Usar 1, 10, 50 e 100 instâncias carregadas por tipo de máquina, em repouso,
   operação e saída bloqueada. Comparar tempo de script/mundo e frametimes com
   o profiler disponível na versão instalada.
2. Na Auto Refugee, testar vazios, recursos, Queens, larvas e lotes de drones;
   repetir com ITD e com IC ordenando/empilhando. Conferir orientação e teleporte.
3. Nos apiários, comparar nativas e híbridas com um/dois slots de drones, plantas
   removidas/trocadas entre ticks, energia ligada/desligada e frame substituído.
   Conferir a produção, reprodução e desgaste, sem alterar o balanceamento.
4. No Hybridizer, conferir carga antecipada, fonte fraca com/sem bateria, saída
   ocupada, reload e sucesso/falha. Na janela, conferir atualização após falha de
   conexão e encerramento ao destruir a máquina.
5. No Filter, conferir tooltip, seletores, janela fechada, duas janelas e ITD.
   A pane passa a atualizar em até cerca de 33 ms de simulação, em vez de 17 ms;
   comandos continuam sendo enviados no callback de interação.

Registrar separadamente o efeito das mudanças já existentes na 0.2.37-dev.
Não extrapolar as contagens simuladas como percentual de CPU, FPS ou ocupação
da fila de scripting. Não adicionar logs por frame em produção para medir.
