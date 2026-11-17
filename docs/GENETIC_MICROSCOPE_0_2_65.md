# Bee Genetic Microscope — 0.2.65-dev

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
20 Laser Diodes. A máquina reutiliza a arte do Advanced Microscope do
Frackin Universe por referência de asset, evitando duplicar PNG enquanto a
arte própria do móvel não for revisada. A procedência do sprite é o FU fixado
em `17868d86c9bb7bc00f92038fb78b48cebd1b41b8`.

A máquina possui descrições de scanner para as sete raças vanilla e uma
descrição genérica. O objeto permanece em `dev`; nenhum PAK foi gerado ou
Action de build iniciada.
