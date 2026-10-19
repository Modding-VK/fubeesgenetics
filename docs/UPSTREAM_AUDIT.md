# Auditoria de integração da reconstrução

Data: 2026-10-14, horário do usuário. Auditoria de fontes públicas, não jogo instalado.

- FU: [17868d86c9bb7bc00f92038fb78b48cebd1b41b8](https://github.com/sayterdarkwynd/FrackinUniverse/tree/17868d86c9bb7bc00f92038fb78b48cebd1b41b8), metadata 6.5.8.
- OpenStarbound: [77f284b0f35b6b383cb149c1bd2295c8a1d00839](https://github.com/OpenStarbound/OpenStarbound/tree/77f284b0f35b6b383cb149c1bd2295c8a1d00839).
- Vanilla espelho: [FerreiraJGB/Starbound 3b370d25c27923155badb38c414a664e1ee2abfc](https://github.com/FerreiraJGB/Starbound/tree/3b370d25c27923155badb38c414a664e1ee2abfc).
- Hashes de 12 fontes FU executadas/examinadas em [tools/upstream.json](../tools/upstream.json).

## Contratos de genética e automação

| Fonte FU | Contrato observado/aplicado |
| --- | --- |
| .metadata | Dependência name=FrackinUniverse |
| bees/genomeLibrary.lua | Global genelib; nove genes, 18 caracteres 0-9A-Z; decoder e numberToStat/statToValue originais |
| bees/beeData.config | 35 families, 70 subespécies, update 1 s |
| Honey Queen/Young Queen/Drone .item | Tags bee+queen/youngQueen/drone; adult maxStack 1 e young maxStack 1000 |
| scripts/kheAA/transferUtil.lua | loadSelfContainer inicializa e registra storage.position em vars.inContainers/outContainers; chamado ~1 Hz |
| objects/bees/beestation/beestation.object | Campo learnBlueprintsOnPickup comentado/ausente; patch trata ausência/existência preservando outras entradas |

Apenas os seis traits definidos são retornados. Family segue convenção entre
primeiros underscores; identidade é family+subtype. wild e lifespan restante
não substituem inspeção/queenLifespan raw. O Adapter usa truthiness Lua conforme
explicitação v1.1; string vazia e 0 são truthy, somente nil/false são falsy.
35 families/70 subespécies são percorridas com tags sintéticas fora de Honey;
os bindings root de itemHasTag/assetJson são simulados, não o asset loader real.

## Materiais

| Material | ID | Evidência |
| --- | --- | --- |
| AI Chip | aichip | FU items/generic/crafting/matterassembler/aichip.item |
| Reinforced Glass | skathreinforcedglass | FU items/generic/crafting/skathreinforcedglass.item; distinto do bloco fureinforcedglass |
| Laser Diode | laserdiode | Receita FU; espelho assets/packed/items/generic/crafting/laserdiode.item, itemName confirmado, blob f5e02f30f3770000ec43678fdfcc96d3a6b39166 |
| Titanium Bar | titaniumbar | Receita FU; espelho assets/packed/items/generic/crafting/titaniumbar.item, itemName confirmado, blob ae1fbde93f60b1cc1ca736fe7e142745cab6f1ab |

Os dois assets vanilla foram relidos nesta reconstrução e não são redistribuídos.
Isso corrobora os IDs, sem comprovar resolução na instalação alvo. Receita usa
2/5/5/10 e grupos mod,beestation,tools,all,functional. Unlock exige testar pickup,
permanência do blueprint e crafting no jogo.

## OpenStarbound auditado

- source/frontend/StarContainerInterface.cpp: lê scripts/scriptDelta/callbacks,
  liga itemGrid/itemGrid2/outputItemGrid ao inventário comum com slotOffset e
  registra pane.containerEntityId e pane.dismiss. createTooltip é de itens.
- source/windowing/StarWidgetParsing.cpp: botões usam pressed; radio groups
  aceitam buttons/selected/IDs; canvas aceita captureMouseEvents/KeyboardEvents
  e mouseTransparent como propriedade comum.
- StarWidgetLuaBindings.cpp: bindCanvas, get/setSelectedOption e canvas
  clear/mousePosition/drawRect/drawText. A atualização programática pode disparar
  callback; a GUI usa flag local de supressão.
- StarCanvasWidget.cpp: MouseMove atualiza posição sem consumir evento.
  StarWidget.cpp: mouseTransparent exclui canvas do hit test e do tooltip nativo;
  ele continua recebendo eventos via sendEvent. Canvas não captura mouse/teclado.
- doc/lua/world.md: world.entityExists; containerTakeNumItemsAt retira até count;
  containerPutItemsAt retorna leftover ou nil para inserção completa;
  spawnItem retorna EntityId ou nil, não confirmar sucesso sem conferir retorno.
- doc/lua/containerpane.md: obter ID e dismiss são APIs da pane real.
- source/game/StarObject.cpp: Object::destroy invoca callback die no master.
- source/game/objects/StarContainerObject.cpp: ContainerObject::destroy chama
  Object::destroy e solta os conteúdos nativos. die do addon só tenta escrow.

Require no engine retorna zero valores; o addon exporta tabelas globais namespaced,
seguindo convenção FU. Esse contrato é modelado no harness. A arquitetura não
foi trocada por ScriptPane ou inventário proxy.

As fontes auditadas ficam no cache, sem redistribuição. As versões instaladas
são desconhecidas: validação no runtime alvo continua necessária. Não se promete
compatibilidade preventiva com versões futuras do sistema genético.

## Empacotamento nativo padrão

Para a distribuição PAK foram usadas as ferramentas de OpenStarbound v0.1.15.1,
compatíveis com Starbound 1.4.4, sem trocar o código funcional auditado. A release
Linux oficial foi verificada pelo SHA-256 publicado no GitHub; os hashes dos
executáveis e as versões estão em tools/pak_toolchain.json. Elas ficam no cache,
não são redistribuídas. StarPackedAssetSource.cpp usa cabeçalho SBAsset6 e guarda
metadata no índice; por isso o unpacker pode reformatar _metadata mantendo seus
valores. Os demais 25 arquivos foram comparados byte a byte após desempacotar.

## Runtime instalado e correção 0.1.1

O log posterior identifica OpenStarbound 0.1.14, revisão
cd2d804f6feaa4c588df822f01eb5504ebd4ba55, e FU 6.5.8. A auditoria inicial
modelou incorretamente root disponível ao carregar scripts e seguiu o contrato
documentado de nil-leftover sem conferir a implementação instalada. A correção
e as diferenças verificadas estão em [RUNTIME_FIX_0_1_1](RUNTIME_FIX_0_1_1.md).
Nesse engine, callbacks são ligados após carregar os scripts, e putItemsAt pode
retornar o argumento mesmo após sucesso; a confirmação agora também admite o
delta exato do slot. Isso substitui as suposições anteriores para essa versão.

## Reagentes solicitados na 0.1.4-dev

Receita atual soma 10 liquidhealing, 5 liquidsulphuricacid e 2 unknowngene aos
quatro ingredientes anteriores, por instrução posterior do usuário. IDs e fontes
verificados em [RECIPE_0_1_4](RECIPE_0_1_4.md); tools/upstream.json passa a fixar
14 fontes FU. Os quantitativos anteriores acima são registro histórico.
