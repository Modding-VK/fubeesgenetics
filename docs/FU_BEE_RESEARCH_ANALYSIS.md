# Pesquisas de abelhas no Frackin Universe

Análise da fonte FU fixada em `17868d86c9bb7bc00f92038fb78b48cebd1b41b8`.
A integração foi definida para os cinco blueprints do addon na versão 0.2.27-dev.

## Resultado

É possível acrescentar pesquisas à sequência de abelhas da árvore **Agriculture**
sem substituir a árvore inteira. O FU carrega `/zb/researchTree/data.config`, lê
cada arquivo listado em `researchFiles` e combina as tabelas com
`zbutil.MergeTable`. Essa função acrescenta elementos a arrays, inclusive
`children`, e combina objetos por chave. O próprio FU fornece uma instrução
para mods: registrar seu arquivo com um patch em `data.config`.

Fontes:

- [Árvore Agriculture](https://github.com/sayterdarkwynd/FrackinUniverse/blob/17868d86c9bb7bc00f92038fb78b48cebd1b41b8/zb/researchTree/fu_agriculture.config)
- [Registro dos arquivos de pesquisa](https://github.com/sayterdarkwynd/FrackinUniverse/blob/17868d86c9bb7bc00f92038fb78b48cebd1b41b8/zb/researchTree/data.config)
- [Carregamento, custos e desbloqueios](https://github.com/sayterdarkwynd/FrackinUniverse/blob/17868d86c9bb7bc00f92038fb78b48cebd1b41b8/zb/researchTree/researchTree.lua)
- [Regras de combinação de tabelas](https://github.com/sayterdarkwynd/FrackinUniverse/blob/17868d86c9bb7bc00f92038fb78b48cebd1b41b8/zb/zb_util.lua)
- [Instruções para mods](https://github.com/sayterdarkwynd/FrackinUniverse/blob/17868d86c9bb7bc00f92038fb78b48cebd1b41b8/a_modders/research/research_instructions.txt)
- [Modelo de pesquisa](https://github.com/sayterdarkwynd/FrackinUniverse/blob/17868d86c9bb7bc00f92038fb78b48cebd1b41b8/a_modders/research/research_template.config)
- [Árvore Madness e custos de referência](https://github.com/sayterdarkwynd/FrackinUniverse/blob/17868d86c9bb7bc00f92038fb78b48cebd1b41b8/zb/researchTree/madness.config)

## Sequência atual

| Pesquisa | Tier exibido | Custo de Research | Libera, entre outros |
| --- | ---: | ---: | --- |
| `bees1` | 1 | 500 | Bee Station, Apiary, microscópio básico |
| `bees2` | 2 | 900 | Large Apiary, microscópio avançado |
| `bees3` | 4 | 1.350 | Quadros avançados |
| `bees4` | 5 | 1.850 | Quadros mais eficientes |
| `bees5` | 6 | 2.400 | Quadros finais |

`bees1` nasce de `foragingn`; os outros formam a cadeia
`bees1 → bees2 → bees3 → bees4 → bees5`. Cada nó tem `icon`, `position`,
`price`, `unlocks` e `children`. Também precisa de sigla exclusiva em
`acronyms.fu_agriculture` e de título/descrição em `strings.research`.
O código mostra erro na interface quando falta uma sigla.

## Integração adotada no addon

O addon registra `/zb/researchTree/fubeesgenetics_bees.config` em
`/zb/researchTree/data.config.patch`. O arquivo próprio acrescenta os nós à
árvore `fu_agriculture`, sem substituir `fu_agriculture.config`. Usa IDs
namespaced, siglas únicas, títulos, descrições com tiering laranja (`^orange;...^reset;`), posições e ícones PNG de 16×16.

| Nó | Pais necessários | Posição | Custo | Blueprints |
| --- | --- | --- | --- | --- |
| Industrial Beekeeping | `bees3` (Advanced Beekeeping) | [-155, -50] | 1.000 Research + 1 A.I. Chip | Genetic Queen Filter, Auto Refugee |
| Abusive Apiaries | Industrial Beekeeping | [-155, -90] | 1.400 Research + 60 Madness | Overload Apiary, Overload Large Apiary |
| Unethical Genetic Practices | Abusive Apiaries | [-155, -130] | 2.200 Research + 120 Madness | Genetic Hybridizer |

A cadeia começa depois de `bees3` (Advanced Beekeeping). Os pais são conectados pelo campo `children`. O FU requer que todos os pais
de um nó estejam pesquisados antes de liberá-lo. As siglas persistidas são
`FUBI1`, `FUBI2` e `FUBI3`; mantê-las estáveis para não perder o progresso
em saves. Os nós usam `fuscienceresource` e `fumadnessresource` como moedas.
Na Agriculture, `customConsumptionRules` consome moedas, então os preços são
pagos na pesquisa; materiais das receitas continuam sendo consumidos ao fabricar.
O custo de 120 Madness tem precedente em `psychiatry2` da árvore Madness.

Os ícones próprios ficam em `/zb/researchTree/fubeesgenetics/`: abelha com
separação de saídas; favo sob um raio de sobrecarga; hélices combinadas com
sinal de risco. São PNGs transparentes de 16×16, sem moldura interna: a
interface do FU desenha `iconBackground.png` sob cada ícone. O gerador
reproduzível é `tools/build_research_icons.py`; ver
[revisão visual](RESEARCH_ICONS_0_2_28.md). O jogo aprende cada blueprint
com `player.giveBlueprint` quando o nó é concluído. A Bee Station permanece como
estação de crafting na aba Functional, mas o patch que ensinava as cinco receitas
por coleta foi removido.

## Saves e validação

Blueprints aprendidos antes da mudança permanecem aprendidos; o jogo não os
revoga. Os novos requisitos se aplicam a personagens sem esse aprendizado.
Não alteramos `versions.fu_agriculture`, pois os blueprints estão em nós novos.

A validação estática confere registro, estrutura, custos, cinco desbloqueios,
ícones e ausência do patch de coleta. Ainda é necessário verificar no jogo a
posição dos nós, a exigência de todos os pais, os custos Research/Madness, o
aprendizado de cada receita e a persistência após salvar/recarregar.
