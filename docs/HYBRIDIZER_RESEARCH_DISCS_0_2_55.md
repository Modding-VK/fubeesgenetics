# Discos de pesquisa no Genetic Hybridizer — 0.2.55-dev

O Hybridizer tem um quarto slot, rotulado `DISC`, para um disco opcional. Na
versão 0.2.55-dev, os slots tinham os índices: rainha 1, drone 2, larva 3 e
disco 4. A interface usa a grade nativa `outputItemGrid` com duas células
visualmente separadas; o OpenStarbound conecta essa grade ao contêiner. Itens
sem bônus conhecido não são consumidos e não alteram a chance.

Na versão 0.2.57-dev, a posição e os índices de larva e disco foram trocados:
disco 3, larva 4. Máquinas já colocadas migram os itens guardados uma única vez,
com devolução persistente se a inserção não terminar no mesmo ciclo.

| Disco FU (ID) | Bônus normal | Bônus com espécies rivais |
| --- | ---: | ---: |
| Research Microdisc (`researchvoxelsmall`) | +5 pontos percentuais | +2,5 pontos |
| Research Holodisc (`researchvoxel`) | +10 pontos | +5 pontos |
| Research Megadisc (`researchvoxellarge`) | +60 pontos | +30 pontos |

Os bônus são somados às chances anteriores de 30% (ou 10% para rivais). Assim,
as chances resultantes são 35%, 40% e 90% para espécies comuns; 12,5%, 15%
e 40% para rivais, respectivamente. A janela apresenta a chance final e o
bônus aplicado. Sem disco, a chance anterior permanece.

Desde 0.2.58-dev, o texto da janela apresenta as duas chances resultantes
(espécies comuns e rivais) para o disco inserido. Com o slot vazio, informa
`Add disc for bonus`; a chance real da tentativa segue a mesma regra anterior.

Uma unidade do disco válido é consumida em cada tentativa, mesmo quando a
hibridização falha. O consumo ocorre junto com os dois pais após o resultado
estar pronto para confirmação. Se uma remoção falhar, os itens já retirados
entram no mecanismo persistente de devolução e a tentativa não é contabilizada.
Um disco que permaneça no slot não afeta o progresso do experimento; trocar de
disco antes do resultado muda apenas a chance da tentativa seguinte.

IDs e nomes conferidos nos três `researchvoxel*.activeitem` do Frackin Universe
na revisão fixada `17868d86c9bb7bc00f92038fb78b48cebd1b41b8`.
O Hybridizer continua com `scriptDelta=30`; a janela continua consultando o
estado a cada 2 s. A nova consulta ao slot ocorre ao confirmar uma tentativa
ou ao responder à janela aberta. Não há polling adicional, cache persistente
ou nova consulta à rede de energia. O custo real na thread do mundo precisa
ser observado no jogo com várias máquinas ativas.

## Novos bônus (0.2.67-dev)

| Disco FU (ID) | Bônus normal | Bônus com espécies rivais | Chance final normal | Chance final rival |
| --- | ---: | ---: | ---: | ---: |
| Research Microdisc (`researchvoxelsmall`) | +15 pontos | +7,5 pontos | 45% | 17,5% |
| Research Holodisc (`researchvoxel`) | +25 pontos | +12,5 pontos | 55% | 22,5% |
| Research Megadisc (`researchvoxellarge`) | +30 pontos | +15 pontos | 60% | 25% |

As taxas sem disco continuam 30% e 10%. A tabela de bônus do objeto é a mesma
usada no cálculo da tentativa e dos valores mostrados na interface. Não há
novas consultas ou custo recorrente de script; o comportamento no jogo ainda
precisa ser conferido após gerar o pacote manualmente pelo Actions.
