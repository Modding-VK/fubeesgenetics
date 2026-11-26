# Swarm Assembler

Protótipo de desenvolvimento 3.0.3-dev. A pesquisa Swarm Encapsulation fica
depois de Genetic Stabilization. O blueprint é fabricado na Bee Station com
3 A.I. Chips, 8 Durasteel Bars, 5 Laser Diodes e 4 Reinforced Glass.
O ID de teste é `fubeesgenetics_swarmassembler`.

## Fabricação

Entradas nas posições 0–5: Queen adulta, três pilhas de Drone, Capture Pod
vazia e A.I. Chip. O slot 6 recebe a cápsula preenchida. A máquina compara
a espécie e o genoma completo das abelhas. A identidade de espécie das
híbridas deriva dos dados das duas famílias e dos seus subtipos, conforme
o contrato de identidade do addon. A fabricação aceita estoques antigos
desde que o item carregue um genoma válido.

O botão **Encapsulate** reserva a Queen, a cápsula, o chip e o maior lote
completo disponível. Sobras permanecem nos slots. A fabricação dura 60
segundos de máquina carregada. A seta preenche em âmbar e uma saída ocupada
retém a cápsula pronta. Uma transferência incompleta devolve os ingredientes
retirados ou os conserva para nova tentativa quando o slot estiver livre.
Quebrar a máquina durante o processo devolve os ingredientes reservados.
Uma cápsula concluída aguardando espaço é solta como item.

O painel apresenta os atributos do lote antes dos bônus que o FU aplica
ao pet solto, como equipamento e coleiras. O resultado da prévia permanece
fixo durante a fabricação.

## Variante do monstro

O nome usa `Small [espécie] Swarm`, `Medium [espécie] Swarm` ou
`Large [espécie] Swarm`. As escalas iniciais são 100%, 115% e 130%, com
bônus de 0%, 10% e 20% nos cinco atributos. O tipo de dano e a paleta
seguem a espécie. Nas híbridas, seguem a família predominante. As paletas e
as afinidades por família são valores iniciais de balanceamento.

Cada atributo interpola entre seus valores base pela raiz quadrada do
valor bruto dividido por 1.295 e recebe o multiplicador do lote. Os limites
iniciais antes do bônus são 9–65 de dano por contato, 45–190 de vida máxima,
0–45 de proteção, 8–20 de velocidade de voo e 0–3 de regeneração.
O mergulho usa 1,5 vezes a velocidade do voo. Production governa dano,
Queen Lifespan a vida, Drone Toughness a proteção, Mutation Chance a
velocidade e Queen Breed Rate a regeneração.

A Filled Capture Pod guarda parâmetros resolvidos do monstro. O controlador
de voo, seguimento, contato e recolhimento vem do Starbound e do FU.
A configuração de animação adapta a do Nanobot Swarm e referencia a textura
do FU. O crédito dos recursos e comportamentos de origem é da equipe do FU.
O zumbido avulso usa um intervalo sorteado de 10 a 60 segundos. Cybernetic
usa os sons do Nanobot Swarm, e as outras espécies usam o zumbido de abelha
gigante do FU.

### Disparo de ferrão

Todos os enxames podem disparar um ferrão adicional sem interromper o
controlador de mergulho. A rajada sorteia de um a quatro ferrões e usa
uma formação de lançamento própria para cada quantidade. Cada origem é
orientada para o alvo e ajustada ao tamanho do enxame. A cor e a fonte de
dano seguem o tipo gravado na cápsula, incluindo o dano físico. O projétil
referencia a textura
Thornburst Stinger do FU.

Balanceamento inicial: 4 a 6 segundos entre rajadas e alcance de 3 a
18 blocos. A soma do dano bruto dos ferrões é 50% do dano bruto de
contato, antes da resistência do alvo. O temporizador usa a atualização
existente do pet. A verificação do alvo e da linha de tiro ocorre somente
quando o temporizador vence. Se a tentativa for bloqueada, o pet espera
1 segundo para tentar de novo. O dano real e a leitura visual da rajada
ainda precisam de teste no OpenStarbound.

## Arte provisória e scripting

O protótipo monta o corpo e as molduras a partir dos assets do Hybridizer e
do Analyzer, com os símbolos FU de Queen e Drone por baixo dos slots. O
sprite mostra a Queen em um hexágono maior com aro dourado, o medidor
vertical de três hexágonos e o LED de prontidão. As partes ativas usam
FullBright. A arte exclusiva da máquina fica para uma revisão posterior.

A estação tem um callback de mundo por cerca de um segundo com sete
leituras de slot por atualização normal. Mantém o cache limitado a quatro
espécimes e uma prévia e grava estados de animação somente quando mudam.
Na confirmação lê novamente os slots e cada item antes de reservar.
O painel aberto faz no máximo uma consulta de estado por segundo e altera
widgets somente quando o resultado muda. O zumbido usa a atualização
existente do monstro com um temporizador local e sem consultas ao mundo.
O banco de monstros gera o retrato uma vez por cápsula fabricada.

## Validação

Os testes de Lua cobrem compatibilidade de espécie e genoma, os três lotes,
nomes, botão com prévia desatualizada, reserva, rollback, retomada do ciclo
e entrega bloqueada. No OpenStarbound, conferir a pane e as camadas FullBright,
a soltura em passagens estreitas, o dano elemental, a cadência dos zumbidos,
o recolhimento e a cura da cápsula. Tempo de scripting no engine e
balanceamento de combate ainda precisam ser medidos.
