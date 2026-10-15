# FU Bees Genetics

Repositório: [Modding-VK/fubeesgenetics](https://github.com/Modding-VK/fubeesgenetics).

Addon de Frackin' Universe para **OpenStarbound**. O Genetic Queen Filter é um
container real de três slots que classifica Queens e Young Queens analisadas
por seis traits, com perfil adaptativo e comparadores configuráveis.

**0.1.4-dev — reconstrução preparada para validação no jogo.**
A base é o ZIP MVP recuperado; documentação e testes iniciais vieram do pacote
phases1-2. As correções posteriores foram refeitas conforme os requisitos v1.2
registrados no histórico. Não é uma cópia byte a byte do commit antigo c3a0238.

A [MasterSpec original](FUBeesGenetics_GeneticQueenFilter_MasterSpec.md) foi
preservada. Leia também os [requisitos v1.2 recuperados](docs/MASTER_SPEC_V1_2_RECOVERED.md),
a [procedência](docs/RECOVERY.md) e o [estado de implementação](docs/IMPLEMENTATION_STATUS.md).
**O arquivo integral v1.2 e o sprite final aprovado não foram recuperados.**
O sprite da máquina continua sendo o do ZIP MVP, identificado como provisório.
A interface recebeu o tema aprovado inspirado no FU.

Veja o [tema da interface e o reteste da versão 0.1.3](docs/HUD_THEME_0_1_3.md)
e o [histórico das versões](docs/VERSION_HISTORY.md).

Desenvolvimento: `dev`. Produção: `main`. PRs e promoção somente com pedido
explícito do usuário. Veja [VERSIONING](docs/VERSIONING.md).

A receita da 0.1.4 acrescenta os três reagentes solicitados; veja
[RECIPE_0_1_4](docs/RECIPE_0_1_4.md).

A expansão futura terá o nome **Abusive Bee Industry**, com título Workshop
**[oSB][FU] Abusive Bee Industry**. O [planejamento](docs/ROADMAP.md) registra
o rebranding e a futura máquina de troca de abelhas por recursos.

## Instalar e usar

O formato principal de distribuição é **`fubeesgenetics-mvp.pak`**, um arquivo
Starbound padrão. Para instalação manual, copie para
`Starbound/mods/fubeesgenetics-mvp.pak`. Instale FU e execute OpenStarbound com
essas fontes de mods, conforme a instalação definida pelo usuário.

Na Steam Workshop, o conteúdo é distribuído como **`contents.pak`**: Steam
administra a pasta `steamapps/workshop/content/211820/<id-do-item>/`, carregada
pelo OpenStarbound com Steam aberto. Não é necessário copiar a assinatura para
mods manualmente. Use apenas uma cópia do addon por instalação.

`fubeesgenetics-workshop-content.zip` contém esse mesmo PAK como `contents.pak`.
O ZIP do mod mantém a pasta descompactada para desenvolvimento/Mod Uploader;
o ZIP de fontes contém o projeto. Veja [WORKSHOP](docs/WORKSHOP.md) para os
fluxos de publicação e geração do PAK. O mod continua exigindo OpenStarbound;
a extensão .pak não torna sua interface compatível com o executável vanilla.

1. Obtenha Bee Station para aprender o blueprint. Em saves existentes, recolha
   e obtenha a estação novamente. O aprendizado é permanente.
2. Na aba Functional da Bee Station, fabrique com **2 AI Chips, 5 Laser Diodes,
   5 Reinforced Glass, 10 Titanium Bars, 10 Healing Water,
   5 Sulphuric Acid e 2 Unknown Gene**. A máquina não é printable.
3. Coloque no chão e use o Input central. A primeira válida estabelece baseline
   de todas as seis referências e segue para Approved, à esquerda.
4. Configure `>=`, `<=` ou `—` por trait; os modos podem ser escolhidos antes
   da baseline. Todos os critérios ativos precisam passar; igualdade é aceita.
   Ignore congela a referência antiga, inclusive ao reativar o trait.
5. Retire Approved/Rejected. Qualquer conteúdo em qualquer saída bloqueia o
   próximo ciclo, mesmo que seja uma stack compatível.
6. Reset Profile limpa perfil/referências e último resultado, preservando
   modos, os três slots e eventual unidade em recuperação.

A máquina processa uma unidade por segundo enquanto carregada, com GUI aberta
ou fechada. Queen/Young Queen da mesma family/subtype compartilham linhagem.
`wild` e vida restante não substituem inspeção/genética. A inspeção usa a
truthiness Lua do FU: apenas nil/false são falsos.

Os slots são nativos, sem filtros ou roteamento especial de Shift+Click.
**ITD offsets: Input 0, Approved 1, Rejected 2.** Configure-os no próprio ITD.
Não há energia, locks, contador de revisão, simulação offline ou genome repair.

Se uma unidade já retirada não puder voltar ao Input nem virar drop, ela fica
em `storage.recoveryEscrow`. **Recovery pending — preserving item** bloqueia
novas classificações; os três slots continuam acessíveis. A recuperação tem
prioridade após reload, e o processamento retoma no tick seguinte à recuperação.
Exceções de spawn com efeito incerto são registradas e suspendem tentativas
naquele carregamento; consulte as limitações em IMPLEMENTATION_STATUS.

Para obter o objeto como administrador:

```text
/admin
/spawnitem fubeesgenetics_geneticqueenfilter
```

## Testes e ferramentas

Requisitos: Python 3.9+ e Lua 5.4 (executável ou biblioteca compartilhada).

```sh
python3 tools/run_checks.py --fetch
python3 tools/build_assets.py
python3 tools/package.py --asset-packer /caminho/asset_packer --asset-unpacker /caminho/asset_unpacker
```

`--fetch` baixa as 14 fontes FU fixadas em `tools/upstream.json` e verifica seus
hashes Git. Para checkout FU local, use `--fu-root /caminho/FrackinUniverse`.
O cache não é redistribuído. **91 grupos passaram**: Adapter 22, máquina 40,
interface 20 e assets 9. São testes do código de produção com bibliotecas FU
reais; bindings de inventário, promises, widgets e destruição são simulados.
Não comprovam ITD, multiplayer, save de mundo, crafting ou renderização reais.
O CI da entrega anterior passou no GitHub; a validação desta correção é registrada no PR.
O empacotamento usa ferramentas nativas do Starbound/OpenStarbound e valida o
PAK por desempacotamento: 27 arquivos restaurados, assets idênticos e metadata
JSON equivalente. Não precisa de uma cópia de packed.pak para empacotar o addon.
A procedência das ferramentas usadas está em tools/pak_toolchain.json.

O gerador preserva os pixels recuperados da máquina e do ícone. O tema da GUI
é desenhado em resolução nativa a partir de artwork/ui-theme.json.
`artwork/interface-layout.json` é a fonte da config da GUI; botões usam `pressed`,
e tooltips individuais usam canvas sem captura de eventos ou bloqueio de slots.
Cada pane aceita uma mutação pendente, descarta consultas anteriores ao comando
e retoma polling após sua resposta. Panes convergem por refresh, sem contador.

## API do Adapter

```lua
require "/scripts/fubeesgenetics/fubeesgenetics_beegeneticadapter.lua"
local result = fubeesgenetics_beegeneticadapter.read(itemDescriptor)
```

O require do engine retorna zero valores; a API é a tabela global namespaced.
`normalize` aceita descritores abreviados, defaults de count=1/parameters={} e
retorna forma canônica ou nil; `read` retorna elegibilidade, identidade e seis
pares raw/display, ou motivo de falha. Não modifica entrada, genomes ou casta.

Antes de release, execute [IN_GAME_TESTS](docs/IN_GAME_TESTS.md). Veja também
[CONFORMANCE_REVIEW](docs/CONFORMANCE_REVIEW.md), [UPSTREAM_AUDIT](docs/UPSTREAM_AUDIT.md)
e [GITHUB_PUBLICATION](docs/GITHUB_PUBLICATION.md).
