# Bee Genetic Microscope — 0.2.86-dev

## Mecânica

O Bee Genetic Microscope aceita somente itens com a tag de abelha do FU. Ao
processar, preserva nome, quantidade restante e todos os parâmetros, acrescenta
apenas `parameters.genomeInspected = true` e entrega uma unidade no slot
Analyzed. Não cria moeda, research, gene material, essência, item secundário ou
currency.

A operação é instantânea do ponto de vista da mecânica: não existe barra de
progresso, RNG ou processamento por lote. O script roda com `scriptDelta 5`
(aproximadamente seis verificações por segundo) para manter baixa latência após
a inserção. Há saídas antecipadas quando o slot de entrada está vazio, o item não
é uma abelha ou o slot Analyzed está ocupado. O estado mutável do inventário
continua sendo confirmado pelo engine; falhas de transferência retornam o
item ao Input ou usam escrow de recuperação.

A interface usa dois slots nativos, Input e Analyzed, molduras estáticas e os
assets de UI já existentes. Não foi adicionado polling de pane nem canvas de
decoração.

## Crafting e arte

Receita: 1 N. Electron Microscope (`electronmicroscope2`), 5 A.I. Chips e
20 Laser Diodes. A máquina reutiliza as imagens direcionais e o ícone do N. Electron Microscope
do Frackin Universe por referência de asset. Sua orientação, deslocamento,
spaceScan, suporte e colisão seguem o objeto original. A procedência do sprite é o FU fixado
em `17868d86c9bb7bc00f92038fb78b48cebd1b41b8`.

A máquina possui descrições de scanner para as sete raças vanilla e uma
descrição genérica. O objeto permanece em `dev`; nenhum PAK foi gerado ou
Action de build iniciada.

## Cor do tanque

A aparência usa os PNGs originais do N. Electron Microscope por referência,
com diretivas nativas de substituição das cores vermelhas do tanque por uma
rampa âmbar de mel, nas duas orientações e no ícone. Silhueta, resolução,
alfa, deslocamento e `spaceScan` são preservados. A alteração é estática e
não acrescenta scripts ou consultas recorrentes. A aparência no engine ainda
precisa ser conferida em jogo.

## Janela compacta

A janela usa o fundo compacto 120×101 do microscópio FU, com corpo sem ícones de recompensas. Input e Analyzed conservam offsets 0 e 1 e molduras independentes. A explicação fica abaixo dos slots, alinhada à esquerda em fonte 6. A mudança é estática, sem script ou polling adicional; disposição e legibilidade exigem conferência no jogo.


A janela compacta oculta o símbolo de research original por substituição de cores nativa; rótulos, slots e texto foram deslocados 5 px para baixo. O cabeçalho referencia o ícone de inventário do microscópio, incluindo sua paleta de mel. Os offsets e o alinhamento das molduras são preservados. Não há script novo; a apresentação requer conferência no jogo.
