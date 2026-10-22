# Pesquisas de abelhas no Frackin Universe

Análise da fonte FU fixada em `17868d86c9bb7bc00f92038fb78b48cebd1b41b8`.
Esta análise não altera os desbloqueios atuais do addon.

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

## Integração recomendada

Criar um arquivo próprio, por exemplo
`/zb/researchTree/fubeesgenetics_bees.config`, e acrescentar seu caminho a
`/zb/researchTree/data.config` com `data.config.patch` usando
`/researchFiles/-`. No arquivo próprio:

- Acrescentar `fubeesgenetics_overload_research` aos `children` de `bees2`.
  Seu `unlocks` conteria `fubeesgenetics_overloadapiary`. Sugestão inicial:
  1.400 Research, posição aproximada `[-150, -110]`.
- Acrescentar `fubeesgenetics_hybrid_research` aos `children` de `bees3`.
  Seu `unlocks` conteria `fubeesgenetics_hybridizer`. Sugestão inicial:
  2.200 Research, posição aproximada `[-150, -150]`.
- Dar a ambos ícones distintos, siglas prefixadas e descrições que expliquem
  consumo de energia, perda de vida da rainha e falha da hibridização. Conferir
  posições e legibilidade na interface do jogo.

Esses valores são propostas de balanceamento. O FU entrega os blueprints com
`player.giveBlueprint` ao concluir a pesquisa. As receitas já existentes na
Bee Station usam os IDs de saída acima e podem permanecer com seus materiais.
Na árvore Agriculture, `customConsumptionRules` consome moeda Research, mas
**não consome os itens** em `price`: itens ali exigem posse, e as próprias
receitas consomem os materiais ao fabricar.

## Desbloqueio atual e saves

Hoje o patch da Bee Station ensina `fubeesgenetics_overloadapiary` e
`fubeesgenetics_hybridizer` assim que a estação é obtida. Para transformar as
pesquisas em requisito real, retirar esses dois blueprints do patch da estação
ao implementar os nós. O Genetic Queen Filter e a Bee Exchange podem conservar
o desbloqueio atual. Personagens que já aprenderam as receitas mantêm esse
conhecimento; o novo requisito se aplica com clareza a personagens novos.

Não é necessário mudar `versions.fu_agriculture` apenas para adicionar nós.
O modelo do FU recomenda mudar a versão quando são acrescentados blueprints a
pesquisas já concluídas, para reaprender os desbloqueios. IDs e siglas dos nós
novos devem permanecer estáveis após publicados, pois o progresso salvo guarda
as siglas. Outros mods podem acrescentar filhos à mesma árvore; os IDs
prefixados e a combinação de arrays reduzem colisões.

Conclusão baseada no código e nos arquivos do FU. A interface e a persistência
das novas pesquisas exigirão conferência dentro do OpenStarbound quando os
patches forem implementados.
