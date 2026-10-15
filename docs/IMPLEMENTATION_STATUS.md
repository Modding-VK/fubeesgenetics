# Estado da reconstrução — 2026-10-14

Implementação local refeita; **build de desenvolvimento**, sem aprovação de release.
Base e limitações documentais/artísticas: [RECOVERY](RECOVERY.md).
Requisitos mais recentes disponíveis: [v1.2 recuperada](MASTER_SPEC_V1_2_RECOVERED.md).

| Fase | Entrega local | Gate de jogo |
| --- | --- | --- |
| 1 | Metadata, namespace, dependência FU | Carregamento pendente |
| 2 | Adapter somente leitura, seis traits, formato/precedência/defaults | Specimens reais e probe pendentes |
| 3 | Container real e grids nativos 1/0/2 | Cursor, stacks, Shift+Click pendentes |
| 4 | Motor, baseline, AND, ignore, Reset, revalidação, rollback/escrow | GUI fechada, save e falhas físicas pendentes |
| 5 | transferUtil original e registro ~1 Hz sem restrições | Rede ITD pendente |
| 6 | GUI sem revisão, uma mutação, descarte de reads antigos e tooltips | Renderização e multiplayer pendentes |
| 7 | IDs/quantidades/groups e patch condicional | Unlock permanente e crafting pendentes |
| 8 | Arte recuperada 40×32 e ícone 20×20, espelhamento nativo | Modelo final aprovado não recuperado; aparência e layout GUI pendentes |

## Evidência executada

`python3 tools/run_checks.py`: **88 grupos passaram** — Adapter 22, máquina 40,
interface 17 e assets 9. Sintaxe Lua, metadata e hashes dos 12 arquivos FU
fixados também passaram. Bibliotecas FU são reais; bindings de inventário,
mensagens/promises, widgets e destruição são simulados. Reload é reinit com
storage preservado, não save de mundo. A cobertura inclui 35 families/70 subespécies.

Revisão fixada FU: 17868d86c9bb7bc00f92038fb78b48cebd1b41b8 (metadata 6.5.8).
OpenStarbound auditado: 77f284b0f35b6b383cb149c1bd2295c8a1d00839.
Runtime reportado: OpenStarbound 0.1.14 e FU 6.5.8. O log confirma carregamento
do addon e erro na inicialização do Adapter; a correção ainda requer reteste no jogo.

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
anexo integral v1.2 e a arte aprovada e concluir aprovação do mockup/layout GUI.

## Distribuição PAK e Steam Workshop

Formato principal: fubeesgenetics-mvp.pak (SBAsset6 padrão), gerado com o
asset_packer nativo OpenStarbound v0.1.15.1 para Starbound 1.4.4. O asset_unpacker
nativo restaurou os 26 arquivos com assets byte a byte e metadata JSON equivalente.
A cópia Workshop contents.pak é idêntica ao PAK manual; o conteúdo compactado
para entrega ao publisher está em fubeesgenetics-workshop-content.zip.

Instalação manual padrão Starbound/mods e fluxo Steam Workshop documentados em
[WORKSHOP](WORKSHOP.md), conforme a configuração de carregamento informada pelo
usuário. Verificação do formato não substitui carregamento no jogo. Nenhum
runtime/tool/asset base do jogo foi incluído nos pacotes do addon.
