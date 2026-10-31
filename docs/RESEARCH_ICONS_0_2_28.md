# Revisão dos ícones de pesquisa — 0.2.28-dev

Os três nós da Agriculture usam PNGs RGBA de 16×16. O FU define
`iconSizes = 16` em `/zb/researchTree/data.config`, desenha
`iconBackground.png` (frame 20×20) e sobrepõe `tbl.icon` na escala 1.
Os ícones nativos `beeicon.png`, `tungsten.png` e `durasteel.png` também
medem 16×16 e deixam o fundo ao redor do símbolo transparente.

A primeira versão dos ícones do addon tinha uma moldura escura própria em
cada PNG. Essa moldura aparecia sobre a moldura nativa do FU, reduzindo a
área disponível e tornando os símbolos pouco específicos. A revisão remove
os quadrados de fundo e amplia os elementos que representam cada pesquisa:

| Nó | Leitura visual em 16×16 |
| --- | --- |
| Industrial Beekeeping | Abelha acima de um separador que conduz a duas saídas distintas, verde e âmbar |
| Abusive Apiaries | Favo atingido por um raio intenso, indicando produção forçada |
| Unethical Genetic Practices | Duas hélices coloridas com um pequeno aviso de risco |

Os pixels fora desses símbolos são transparentes; a moldura e a cor de estado
continuam sob controle da interface de pesquisa do FU. O desenho é original
e não redistribui os ícones de referência do FU.

Regerar: `python3 tools/build_research_icons.py`. Conferir que os PNGs
versionados correspondem ao gerador: `python3 tools/build_research_icons.py --check`.
A comparação foi feita em escala nativa e com a moldura de referência. A leitura
na interface do OpenStarbound ainda precisa de conferência no jogo.
