# Correção 0.1.1-dev — OpenStarbound 0.1.14

O teste informado pelo usuário confirmou que FU 6.5.8 e FUBeesGenetics 0.1.0-dev
carregavam, a interface abria e itens permaneciam no Input. O log registrou
`attempt to index a nil value (global 'root')` no Adapter, linha 5, durante
criação do contexto Lua. O log pessoal não foi incorporado ao repositório.

## Correções

- beeData.config é lido sob demanda dentro de adapter.read, depois de os bindings
  estarem disponíveis. Nenhuma API do engine é chamada no carregamento do Adapter.
- A orientação usa dualImage, o mesmo recurso nativo empregado pela Bee Station.
  O engine escolhe esquerda/direita na colocação e no preview. O desenho, o tamanho,
  os slots e os offsets ITD permanecem os mesmos. O móvel colocado não segue o
  personagem continuamente; para trocar sua direção, recolha e coloque novamente.
- No OpenStarbound 0.1.14, containerPutItemsAt retorna o descriptor de entrada
  mesmo quando a inserção completa ocorreu. putAt aceita nil ou confirma a
  variação exata de quantidade e a identidade completa do slot (nome/parâmetros),
  antes de decidir pelo rollback, drop ou escrow. O fluxo processa uma unidade;
  não interpreta esse retorno anômalo como outra unidade física.

## Evidência e limites

Fonte do engine na revisão instalada cd2d804f6feaa4c588df822f01eb5504ebd4ba55:
[LuaBaseComponent](https://github.com/OpenStarbound/OpenStarbound/blob/cd2d804f6feaa4c588df822f01eb5504ebd4ba55/source/game/scripting/StarLuaComponents.cpp),
[LuaRoot](https://github.com/OpenStarbound/OpenStarbound/blob/cd2d804f6feaa4c588df822f01eb5504ebd4ba55/source/game/scripting/StarLuaRoot.cpp),
[World bindings](https://github.com/OpenStarbound/OpenStarbound/blob/cd2d804f6feaa4c588df822f01eb5504ebd4ba55/source/game/scripting/StarWorldLuaBindings.cpp),
[Orientações](https://github.com/OpenStarbound/OpenStarbound/blob/cd2d804f6feaa4c588df822f01eb5504ebd4ba55/source/game/StarObjectDatabase.cpp).

Os testes carregam o Adapter/controlador sem root e disponibilizam root somente
antes da execução. M38–M40 cobrem retorno anômalo na aprovação, rejeição, rollback
para uma stack existente e recuperação de escrow, sem duplicar itens.
88 grupos passaram: Adapter 22, máquina 40, interface 17, assets 9. Bindings são
simulados: isso reproduz contratos examinados no código, sem executar o jogo.
O PAK deve ser validado novamente na instalação do usuário.

## Reteste

Feche o jogo e substitua o PAK anterior pela versão 0.1.1-dev, mantendo somente
uma cópia do addon nas fontes carregadas. Reinicie e confira a versão no log.
Retire quaisquer itens antes de recolocar a máquina para testar ambos os lados.
Com ambas as saídas vazias, coloque um item comum no Input: uma unidade deve ir
para Rejected após cerca de um segundo, sem inicializar perfil. Retire essa
saída e insira uma Queen/Young Queen previamente analisada: ela deve ir para
Approved e inicializar Family, Subspecies e as seis referências. Itens comuns
ou Queens não analisadas não inicializam perfil. Qualquer saída ocupada bloqueia
o próximo ciclo. Teste também com interface fechada.
