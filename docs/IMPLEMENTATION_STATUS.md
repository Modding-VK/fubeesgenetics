# Estado do projeto — 2026-10-19

## Release estável — 0.2.19

A build 0.2.19-dev foi validada ingame pelo mantenedor e promovida para
0.2.19 em main, com tag anotada v0.2.19. Identidade pública: [oSB][FU] Bee
Abusive Industry, autor Goblin Man, ícone Cybernetic Queen em fundo laranja e
homepage. A promoção preserva IDs, scripts, receitas e inventários.

O PAK SBAsset6 e o ZIP com contents.pak foram gerados e conferidos por
pack/unpack nativo. O upload à Steam Workshop não foi realizado. Ver
[release](RELEASE_0_2_19.md), [prontidão](RELEASE_READINESS.md) e
[material de publicação](WORKSHOP.md).

## Registro da build funcional validada — 0.2.18-dev

A 0.2.18 centraliza Reset Profile entre as barras (margens 11/11) e baixa
as listras para a faixa metálica inferior. Ver [detalhes](HUD_ALIGNMENT_0_2_18.md).
O cabeçalho com logo centralizado, título laranja e descrição da 0.2.17
está preservado.
A compactação 304×332, coluna de referências centralizada, slots próximos e
tooltips da 0.2.16 permanecem iguais. O usuário confirmou melhora significativa
no layout compacto; o novo cabeçalho ainda precisa de conferência no jogo.
A correção do nome Auto Refugee da 0.2.15 está preservada.

Código e PAK entregues somente em dev. O usuário confirmou o funcionamento do
Analyzer e do ITD nas versões anteriores e validou as correções da textura da
Bee Exchange na 0.2.13. A abertura da janela na 0.2.14 e a integração completa
com Improved Containers 2.11 ainda aguardam confirmação no jogo.

A Bee Exchange tem 16 slots, recompensas adultas para Young Queens, drones em
lotes de cinco por espécie, vidro/teleporte, texturas direcionais legíveis, ícone
próprio, I/O e chave on/off. Inspeções raciais explicam os nodes. A integração IC
é opcional e preserva recompensas pendentes e conteúdo ao quebrar/recolocar.

Nesta entrega passaram 135 grupos básicos, com bindings simulados. Os 13 testes
opcionais IC da 0.2.14 não foram repetidos, pois o PAK original não está neste
ambiente. A máquina Auto Refugee permanece byte a byte igual à base 0.2.15.
O pacote de 52 arquivos foi conferido por pack/unpack nativo.
Isso não conclui os gates de jogo, multiplayer ou publicação Steam.
Ver [correção da GUI](BEE_EXCHANGE_0_2_14.md) e [reteste](IN_GAME_TESTS.md).
Os registros abaixo preservam a evolução das entregas anteriores; suas contagens
são históricas. As limitações da arte recuperada do Analyzer não se aplicam aos
sprites novos da Bee Exchange.

Implementação local refeita; **build de desenvolvimento**, sem aprovação de release.
Base e limitações documentais/artísticas: [RECOVERY](RECOVERY.md).
Requisitos mais recentes disponíveis: [v1.2 recuperada](MASTER_SPEC_V1_2_RECOVERED.md).

| Fase | Entrega local | Gate de jogo |
| --- | --- | --- |
| 1 | Metadata, namespace, dependência FU | Carregamento confirmado no log do usuário |
| 2 | Adapter somente leitura, seis traits, formato/precedência/defaults | Specimens reais e probe pendentes |
| 3 | Container real e grids nativos 1/0/2 | Cursor, stacks, Shift+Click pendentes |
| 4 | Motor, baseline, AND, ignore, Reset, revalidação, rollback/escrow | GUI fechada, save e falhas físicas pendentes |
| 5 | transferUtil original e registro ~1 Hz sem restrições | Usuário confirmou ITD 100% funcional na 0.1.2; cenários não detalhados |
| 6 | GUI sem revisão, uma mutação, descarte de reads antigos e tooltips | Seletores validados pelo usuário na 0.1.2; tema 0.1.3 e multiplayer pendentes |
| 7 | IDs/quantidades/groups e patch condicional | Unlock permanente e crafting pendentes |
| 8 | Arte recuperada 40×32 e ícone 20×20, espelhamento nativo | Modelo final aprovado não recuperado; aparência da máquina pendente; tema GUI aprovado e implementado |

## Evidência executada

`python3 tools/run_checks.py`: **91 grupos passaram** — Adapter 22, máquina 40,
interface 20 e assets 9. Sintaxe Lua, metadata e hashes dos 14 arquivos FU
fixados também passaram. Bibliotecas FU são reais; bindings de inventário,
mensagens/promises, widgets e destruição são simulados. Reload é reinit com
storage preservado, não save de mundo. A cobertura inclui 35 families/70 subespécies.

Revisão fixada FU: 17868d86c9bb7bc00f92038fb78b48cebd1b41b8 (metadata 6.5.8).
OpenStarbound auditado: 77f284b0f35b6b383cb149c1bd2295c8a1d00839.
Runtime reportado: OpenStarbound 0.1.14 e FU 6.5.8. O log da 0.1.1 confirma carregamento
sem o erro anterior do Adapter; a captura mostra perfil preenchido e classificação.
O usuário confirmou funcionamento perfeito da 0.1.2 e ITD 100% funcional em sua
instalação. O tema visual aprovado foi implementado na 0.1.3; falta reteste visual
no jogo. Na 0.1.3, Lua, objeto, receita, patch e geometria dos slots não foram alterados.
Na 0.1.4-dev, a receita recebeu os três reagentes pedidos pelo usuário; a entrega
fica em dev, sem PR ou promoção para main. Ver RECIPE_0_1_4 e VERSIONING.

## Recuperação de item e exceções

Falha confirmada de transferência tenta Input e drop com EntityId. Nil também
permite uma última devolução síncrona ao Input. Persistindo a falha, uma unidade
com parâmetros exatos fica em escrow; status tem prioridade e genética bloqueia.
Reset mantém escrow. Reload retoma recuperação antes de novas candidatas.
Sucesso só libera fluxo no tick seguinte. die só trata escrow, uma tentativa;
o engine solta os três slots nativos. Falha final registra FATAL com descriptor.

Exceção no spawn não confirma ausência de efeito. O descriptor é preservado em
escrow e um guard transitório suspende novas tentativas naquele carregamento;
o log contém descriptor/erro. Isso difere do caminho comum nil: pode exigir
intervenção/diagnóstico. Não recarregar automaticamente diante de efeito incerto,
pois reload reinicializa o guard e pode repetir a tentativa. Não se promete
conservação/atomicidade contra efeitos incertos, crash ou interrupção entre APIs.
Esse tratamento de exceção é explicitado, não uma garantia adicional do engine.

Antes de release: executar [IN_GAME_TESTS](IN_GAME_TESTS.md), recuperar/comparar o
anexo integral v1.2 e a arte aprovada e validar o tema da GUI no jogo.

## Distribuição PAK e Steam Workshop

Formato principal: fubeesgenetics-mvp-0.1.6-dev.pak (SBAsset6 padrão), gerado com o
asset_packer nativo OpenStarbound v0.1.15.1 para Starbound 1.4.4. O asset_unpacker
nativo restaurou os 29 arquivos com assets byte a byte e metadata JSON equivalente.
A cópia Workshop contents.pak é idêntica ao PAK manual; o conteúdo compactado
para entrega ao publisher está em fubeesgenetics-workshop-content.zip.

Instalação manual padrão Starbound/mods e fluxo Steam Workshop documentados em
[WORKSHOP](WORKSHOP.md), conforme a configuração de carregamento informada pelo
usuário. Verificação do formato não substitui carregamento no jogo. Nenhum
runtime/tool/asset base do jogo foi incluído nos pacotes do addon.

## Slots da interface — 0.1.5-dev

Molduras são imagens independentes de 24×24, atrás de grids nativos. Os grids
usam espaçamento 19×19, sem backingImage; o ItemSlot nativo usa tamanho 19×19
na configuração padrão. Origens +3/+3 alinham os centros. Slots físicos e
offsets ITD 1/0/2, Lua, modos e receita permanecem os mesmos. Validação offline
e 91 grupos passaram. O usuário confirmou que as alterações da 0.1.5
funcionaram perfeitamente; o relato não enumera cada cenário de interação.

## Textos e espaçamento da interface — 0.1.6-dev

Setas nativas de 7×7 para cima/baixo acompanham os nomes Equal or higher e
Equal or lower; Indifferent substitui o traço. Cabeçalhos em duas linhas e
colunas mais espaçadas acomodam os nomes completos. Status e Last result
descem 3 pixels; Reset Profile recebe centralização explícita e offset vertical
de -1 pixel. Os slots, receita e scripts Lua são idênticos à 0.1.5.
Ver [HUD_LABELS_0_1_6](HUD_LABELS_0_1_6.md). Reteste visual no jogo pendente.

## Segunda máquina — Bee Exchange 0.2.0-dev

Implementada com 20 slots, as 105 receitas do Bee Refuge lidas do FU em runtime,
trocas automáticas e crafting/desbloqueio na Bee Station. A suíte atual tem
120 grupos locais e PAK validado por round-trip de 39 arquivos. O Queen Filter
permanece igual à 0.1.6-dev. Ver [BEE_EXCHANGE_0_2_0](BEE_EXCHANGE_0_2_0.md)
para tabela, limites de recuperação e reteste manual. Validação no jogo pendente.

## Bee Exchange — interface 0.2.1-dev

Interface baseada no container nativo usado pelo Terramart: 16 slots à direita
e 4 abaixo, todos com backingImage nativo e centro (9,9), objeto, título e
Take all. Controlador/receita/ITD não mudam. 121 grupos locais e round-trip
de 36 arquivos passaram; visual e interação no engine ainda pendentes.
Ver [BEE_EXCHANGE_UI_0_2_1](BEE_EXCHANGE_UI_0_2_1.md).

## Bee Exchange — 0.2.2-dev

A pedido do usuário, agora tem 24 slots (substituindo o limite anterior de 20),
com a fileira inferior completa e offsets 0–23. Sprite, ícone e animações originais do Terramart 3.5 do FU,
com placa Auto Refugee amarela alaranjada. Footprint físico preservado. 125 grupos passaram;
validação de save/visual no jogo pendente. Ver [BEE_EXCHANGE_0_2_2](BEE_EXCHANGE_0_2_2.md).

## Bee Exchange — 0.2.3-dev

Reduzida para 16 slots, offsets 0–15; Young Queens recebem a recompensa da
Queen adulta da mesma espécie. Drones, crafting e animação não mudam. 126 grupos
locais passaram. Esvaziar offsets 16–23 antes de atualizar: o engine reduz o
inventário e derruba itens excedentes no mundo. Ver [BEE_EXCHANGE_0_2_3](BEE_EXCHANGE_0_2_3.md).
