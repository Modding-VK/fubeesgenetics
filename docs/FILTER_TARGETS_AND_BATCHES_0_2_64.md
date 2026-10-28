# Critérios fixos e drones em lote — 0.2.64-dev

Implementação solicitada pelo mantenedor após feedback da Workshop.
Base: `cbb51cf631a031e9258aa353d62c32f9e5062549` (0.2.63-dev).

## Genetic Queen Filter: seleção por atributo

A janela continua com 304×332 e três colunas, sem novos PNGs. A terceira
coluna passa a chamar-se **Custom**. Cada linha tem um botão **+** que abre
um editor no espaço central da própria janela, sem alterar os slots nativos.
Os controles da tabela são escondidos durante a edição. Apply confirma uma
alteração por mensagem; Cancel descarta o rascunho. Digitar e alternar opções
no editor não envia mensagens. A máquina continua com a configuração anterior
até Apply ser confirmado; o editor não pausa inventário ou ITD.

| Modo | Critério | Atualização após aprovação |
| --- | --- | --- |
| Equal or higher | Gene >= referência adaptativa | Assume o gene aprovado |
| Equal or lower | Gene <= referência adaptativa | Assume o gene aprovado |
| Indifferent | Atributo não participa da seleção | Referência congelada |
| Equal | Gene corresponde ao alvo exato configurado | Alvo e referência adaptativa permanecem fixos |
| Within range | Mínimo <= gene <= máximo | Limites e referência adaptativa permanecem fixos |

No editor, o botão de modo alterna **Indifferent → Equal → Within range**.
Equal usa o campo Value. Within range usa Minimum e Maximum. Na primeira
configuração, os campos partem da referência atual; sem baseline, partem de
zero e podem ser editados antes da primeira abelha. Configurações já salvas
preenchem seus próprios valores, em vez de serem substituídas pela referência.
A seleção da terceira coluna recupera o último modo Custom escolhido naquela
linha; as seis linhas são independentes.

Na tabela, **REF / TARGET** mostra a referência adaptativa nos modos originais,
`=40` para igualdade e `35..45` para intervalo. Mutation Chance inclui `%`.
Exemplo: Queen Breed Rate 35..45 aceita 35, 40 e 45, mas rejeita 34 e 46. Aprovar
45 e depois 36 não move os limites e não pode transformar a faixa em 36..46.
As demais condições continuam em AND, com a mesma identidade de família,
subespécie e linhagem híbrida já exigida pelo Filter.

Os alvos são independentes da baseline. Ao voltar de um modo fixo para >= ou
<=, retorna a referência adaptativa que estava congelada, não o alvo digitado
nem o último valor recebido. Reset Profile limpa perfil, referências e último
resultado; preserva modos, alvos, inventário e escrow. Isso segue a preservação
dos modos do comportamento original. Ao trocar de espécie após Reset, os alvos
manuais continuam valendo até o jogador alterá-los.

## Conversão, persistência e segurança

`storage.targets[trait]` guarda limites raw canônicos e limites exibidos.
`storage.customModes[trait]` lembra a escolha da terceira coluna. Saves antigos
não precisam de migração de inventário ou perfil; novos campos são inicializados
sem alterar os modos >=, <= ou Indifferent. Um alvo salvo inválido é desativado
apenas naquela linha, preservando o perfil e os itens.

A primeira candidata também deve satisfazer todos os alvos fixos. Não existe
aprovação automática fora da faixa para criar a baseline. Perfil e referências
continuam sendo confirmados somente após inserção física bem-sucedida.
Mensagens inválidas não modificam parcialmente limites/modos. Snapshots enviados
à pane não compartilham tabelas mutáveis com storage. Em duas janelas, prevalece
o último comando válido aplicado; leituras passivas antigas não sobrescrevem
respostas de comandos.

A configuração usa o valor genético mostrado, não a vida restante. Cinco genes
usam valores inteiros de 0 a 1295. Mutation Chance usa o percentual decodificado
pelo FU, cujo máximo atual é 99,92%. Como seus passos não são de 0,01%, nem todo
percentual digitável é representável. Equal rejeita alvos sem representação exata
no FU e informa os valores vizinhos. Within range resolve os genes efetivamente
contidos nos limites inclusivos; uma faixa sem nenhum gene é rejeitada.
Por exemplo, 3% corresponde ao raw 39; 3,01% não é uma igualdade representável,
mas a faixa 3,01..3,09 contém o raw 40, mostrado como 3,08%.

A conversão usa busca binária no domínio 0..1295, com o decoder real do FU,
somente ao configurar ou validar um save. Comparações de candidatas continuam
inteiras. Não foi assumida uma fronteira universal de mutação ±3.

## Auto Refugee: agrupamento de drones

Queens e Young Queens mantêm uma receita por slot por ciclo. Para drones, os
lotes completos da mesma espécie são agrupados em uma única transação, mesmo
quando os stacks têm parâmetros genéticos diferentes. As receitas continuam
vindo do FU em runtime; não há preço paralelo fixado no addon.

Na referência FU atual:

- 5 drones → 7 Pixels;
- 100 drones → 140 Pixels;
- 1.000 drones → 1.400 Pixels, havendo espaço para a recompensa completa.

O limite global de drones é **200 lotes por ciclo carregado de 1 segundo**.
Cada espécie é planejada uma vez por ciclo; a prioridade rotativa dos slots é
preservada. Excedentes aguardam o próximo ciclo, sem simular períodos offline.
Sobras menores que uma receita permanecem com os parâmetros exatos. Outro
negócio no mesmo ciclo pode liberar espaço, mas uma espécie já examinada só
será planejada novamente no ciclo seguinte.

O planejador escolhe a maior quantidade que cabe dentro da cota e do espaço
após o consumo. Não usa busca binária sobre a capacidade: consumir um stack
inteiro libera espaço, portanto lotes maiores podem caber quando menores não
cabem. O helper puro examina os pontos em que cada stack seria liberado, com
trabalho limitado pelo inventário de 16 slots. Não executa 200 vendas unitárias
nem itera uma vez por drone. Há uma releitura final do inventário antes do
planejamento e uma comparação física de cada fonte antes de sua retirada.

Recompensas agregadas são persistidas em chunks de tamanho nativo: 1.400 Pixels
podem resultar em 1.000 + 400. Isso preserva a entrega, reload e os drops ao
quebrar a máquina. O ledger anterior `exchangePending` continua compatível.
Não há outra venda enquanto houver devolução ou recompensa pendente. Estão
preservados on/off, IC locks, registro ITD, offsets, retorno legado do engine,
validação de capacidade, animação e som.

## Scripting e validação

Nenhum scriptDelta, intervalo de processamento, polling ou frequência de registro
ITD foi aumentado. A pane mantém um comando em voo, consulta passiva de 1 s,
renderização apenas de campos alterados e descarte de leituras antigas. O editor
usa widgets nativos; não adiciona canvas de decoração nem assets de arte.
Novos controles usam as imagens já existentes na pane.

Caches e tabelas persistentes têm no máximo seis entradas de critérios. A busca
de quantidade da Auto Refugee é aritmética e limitada aos slots, e a recompensa
que passou no preflight ocupa no máximo o número de slots do contêiner. Builders,
inventário e saldos continuam sendo consultados nos pontos necessários para
preservar a correção, sem cache de estado mutável do mundo.

Regressões novas cobrem: primeiro espécime, igualdade/faixa inclusiva sem drift,
mutação percentual, limites inválidos/NaN/infinito, Apply/Cancel, foco de textbox,
rascunhos durante polling, comandos e respostas antigas, migração/reload/Reset,
falha de transferência, capacidade após liberação de stacks, cota global,
recompensa em chunks, retorno legado, retirada interrompida e receita FU alterada.
O planejador é comparado a um oráculo exaustivo independente em 300 inventários
aleatórios pequenos, inclusive casos de capacidade não monotônica.

Os testes usam Lua de produção e bibliotecas FU fixadas, com bindings de engine
simulados. Não equivalem a abrir esta pane ou medir CPU no OpenStarbound.
A suíte IC original opcional só deve ser declarada executada se seu pacote estiver
disponível e for realmente testado. O ganho no engine continua pendente de medição.

## Entrega e reteste manual

Somente dev, sem PR, merge, tag ou promoção de main. Nenhuma imagem nova foi
produzida/enviada. Nenhum PAK foi gerado localmente ou Action de build disparada
pelo agente: o mantenedor deve executar **Build development PAK → Run workflow →
Branch dev**, depois de conferir o CI do commit entregue.

No jogo, com uma única cópia atualizada do mod:

1. Abrir um Filter antigo e verificar a preservação de perfil, modos e itens.
2. No + de Queen Breed Rate, aplicar Equal 40 e testar 39/40/41; depois configurar
   Within range 35..45 e testar 34/35/40/45/46. As demais condições devem passar
   para isolar esse atributo.
3. Conferir =40 ou 35..45 em REF / TARGET e a estabilidade após aprovações,
   fechar/reabrir, reload e Reset. Conferir os campos e o foco ao cancelar.
4. Testar Mutation Chance com percentuais representáveis e não representáveis,
   e confirmar que erros preservam a configuração anterior.
5. Inserir 1.000 drones iguais na Auto Refugee com espaço livre e conferir 1.400
   Pixels; repetir com espécies distintas, genes distintos e inventário cheio.
   Não misturar a recompensa com Pixels anteriores ao contabilizar o teste.
6. Repetir com ITD e operações IC, e conferir saídas bloqueadas/reload. Medir
   latência e tempo de script com várias máquinas, sem logs por frame.
