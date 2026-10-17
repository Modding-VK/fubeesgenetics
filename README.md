# FU Bees Genetics

Addon de **Frackin Universe para OpenStarbound**, com duas máquinas: Genetic
Queen Filter (Bee Analyzer) e Bee Exchange (Auto Refugee).

**Versão 0.2.18 — candidata à produção, aguardando revisão e merge do PR.**

[Baixar o PAK](dist/fubeesgenetics-mvp-0.2.18.pak?raw=true) ·
[Alterações da versão](docs/RELEASE_0_2_18.md) ·
[Histórico](docs/VERSION_HISTORY.md) · [Estado e validação](docs/IMPLEMENTATION_STATUS.md)

A 0.2.18 centraliza Reset Profile entre as duas barras e mantém as listras
inferiores inteiramente na faixa metálica. O logo, título laranja e descrição
clara da 0.2.17 estão preservados.
O layout compacto **304×332**, valores centralizados e slots próximos da 0.2.16
permanecem iguais.
A correção do nome **Auto Refugee** da 0.2.15 está preservada.

O mantenedor confirmou que todas as alterações estão validadas e prontas e
solicitou o Pull Request. A candidata 0.2.18 preserva os scripts/assets da
0.2.18-dev validada; somente o metadata muda nos assets de produção.
A dev permanece com sufixo -dev. Não houve merge, tag ou publicação Steam.

## Instalação

1. Instale Frackin Universe e execute OpenStarbound.
2. Com o jogo fechado, substitua o PAK anterior em `Starbound/mods` por
   `fubeesgenetics-mvp-0.2.18.pak`. Mantenha apenas uma cópia do addon.
3. Abra novamente o jogo. A atualização conserva IDs e inventários; não precisa
   refazer as máquinas nem resetar o perfil do Analyzer.

[dist/SHA256SUMS](dist/SHA256SUMS) identifica o PAK e o ZIP Workshop da entrega.
O ZIP Workshop contém os mesmos bytes com o nome padrão `contents.pak`.
Isso não representa publicação na Steam; veja [WORKSHOP](docs/WORKSHOP.md).

## Genetic Queen Filter / Bee Analyzer

Contêiner real de três slots que classifica Queens e Young Queens analisadas
por seis traits, com referências adaptativas e comparadores configuráveis.

- Obtenha/recolha a **Bee Station** para aprender a receita. Fabrique na aba
  Functional com 2 AI Chips, 5 Laser Diodes, 5 Reinforced Glass, 10 Titanium Bars,
  10 Healing Water, 5 Sulphuric Acid e 2 Unknown Gene.
- Use o Input central. A primeira abelha válida estabelece a referência e vai
  para Approved. Todas as condições ativas precisam passar; igualdade é aceita.
- Escolha **Equal or higher**, **Equal or lower** ou **Indifferent** por trait.
  Indifferent congela a referência. Os modos podem ser definidos antes da baseline.
- Qualquer saída ocupada bloqueia o próximo ciclo. Reset Profile limpa o perfil
  e o último resultado, preservando modos, slots e eventual item em recuperação.
- **Offsets ITD: Input 0, Approved 1, Rejected 2.**

Processa uma unidade por segundo enquanto carregada, com janela aberta ou
fechada. Queen/Young Queen da mesma family/subtype compartilham linhagem.
Wild e vida restante não substituem inspeção ou genética.

A recuperação de transferências incompletas usa `storage.recoveryEscrow` e
bloqueia novas classificações até resolver o item. Consulte as limitações e
exceções em [IMPLEMENTATION_STATUS](docs/IMPLEMENTATION_STATUS.md).

ID para `/spawnitem`: `fubeesgenetics_geneticqueenfilter`.

## Bee Exchange / Auto Refugee

Troca abelhas automaticamente conforme as receitas do Bee Refuge do FU.

- Receita na Bee Station / Functional: **1 Bee Refuge + 1 Terramart Shipments 3.5
  + 2 AI Chips**. Desbloqueio ao obter/recolher a Bee Station.
- **16 slots compartilhados**, offsets ITD **0–15**. Filtre abelhas na inserção
  e recursos/Pixels na extração.
- Queens e Young Queens rendem o mesmo recurso e quantidade por espécie.
  **Cinco drones da mesma espécie rendem 7 Pixels**; genéticas podem diferir.
- Recursos/Pixels permanecem no contêiner. Outros itens não são vendidos.
  Sem espaço para a recompensa completa, as abelhas aguardam.
- **Input superior:** chave on/off. Sem fio funciona automaticamente; conectado,
  sinal alto habilita e sinal baixo pausa novas vendas.
- **Input inferior / output:** entrada e saída da rede de itens FU/ITD, nos mesmos
  pontos visuais da referência Terramart 3.5.

A arte atual tem placa amarela integrada, caixa de vidro com transparência,
dois LEDs nativos e display de status. Durante work, a abelha na haste desaparece
em um teleporte de 1,25 s no total, com som nativo. Placa e display têm variantes
legíveis para os dois lados, também na prévia de placement.

**Improved Containers 2.11 é opcional.** A integração usa seus scripts instalados
para ordenar, empilhar, buscar, renomear e guardar conteúdo ao quebrar a máquina.
As vendas aguardam a organização. A 0.2.14 mantém `uiConfig` como caminho de
arquivo e repara o valor inválido salvo pelas versões anteriores.
Veja [integração](docs/BEE_EXCHANGE_0_2_11.md) e
[correção de abertura](docs/BEE_EXCHANGE_0_2_14.md). Outros mods de armazenamento
e o Post-Load Mega-Patch ainda não foram validados.

ID para `/spawnitem`: `fubeesgenetics_beeexchange`.
Ao migrar das antigas versões com 24 slots, esvazie os offsets 16–23 antes de
atualizar. As versões atuais já usam os mesmos 16 slots.

## Desenvolvimento e GitHub

As regras acordadas no chat **Bee Analyzer** valem para as duas máquinas:

- `dev`: desenvolvimento e PAKs com versão `X.Y.Z-dev`.
- `main`: produção; PR, merge ou promoção só mediante solicitação explícita.
- Preservar histórico compartilhado e PAKs antigos; downloads usam commits fixos.
- Tags estáveis `vX.Y.Z` ficam reservadas às promoções autorizadas.

Veja [VERSIONING](docs/VERSIONING.md), [operação GitHub](docs/GITHUB_PUBLICATION.md)
e [AGENTS.md](AGENTS.md). O nome futuro **Bee Abusive Industry** e o título
Workshop **[oSB][FU] Bee Abusive Industry** continuam planejados; metadata e IDs
atuais permanecem iguais. [Planejamento](docs/ROADMAP.md).

## Testes e ferramentas

Ambiente usado: Python 3.12 e Lua 5.4 (executável ou biblioteca compartilhada).
Os geradores de sprites usam Pillow. O empacotamento usa as ferramentas nativas
Starbound/OpenStarbound fixadas em [pak_toolchain.json](tools/pak_toolchain.json).

```sh
python3 tools/check_version.py --release --tag v0.2.18
python3 tools/run_checks.py --fetch
# Opcional: testar com o IC 2.11 original desempacotado, sem redistribuí-lo.
python3 tools/run_checks.py --ic-root .cache/improved-containers
python3 tools/package.py --output-dir /caminho/da/entrega
```

Na 0.2.18 passaram **135 grupos básicos**. Os 13 casos opcionais com o IC
não foram repetidos nesta entrega: seu PAK original não está neste ambiente.
Na 0.2.14, esses casos executaram o Lua real do PAK fornecido pelo usuário, conferido por hash.
Bindings de engine, jogador, rede e GUI são simulados; esses testes não equivalem
à execução dentro do jogo. O PAK foi empacotado e extraído para conferir seus
**52 arquivos**, com bytes idênticos e metadata JSON equivalente.

`--fetch` prepara referências fixadas e verificadas por hash em
[upstream.json](tools/upstream.json) e [ui_upstream.json](tools/ui_upstream.json).
O IC opcional segue [ic_upstream.json](tools/ic_upstream.json). Para um checkout
FU local, use `--fu-root /caminho/FrackinUniverse`. Caches não são redistribuídos.

Geradores atuais: `tools/build_assets.py` (Analyzer),
`tools/build_beeexchange_work_assets.py` (móvel/animação) e
`tools/build_beeexchange_icon.py` (ícone). O último par usa os assets e conceitos
aprovados, em escala nativa. [Roteiro de testes no jogo](docs/IN_GAME_TESTS.md).

## API e procedência

```lua
require "/scripts/fubeesgenetics/fubeesgenetics_beegeneticadapter.lua"
local result = fubeesgenetics_beegeneticadapter.read(itemDescriptor)
```

O require do engine retorna zero valores; a API é uma tabela global namespaced.
`normalize` aceita descritores abreviados; `read` retorna elegibilidade,
identidade e seis pares raw/display, ou o motivo de falha. Não altera a abelha.

A [MasterSpec original](FUBeesGenetics_GeneticQueenFilter_MasterSpec.md), os
[requisitos v1.2 recuperados](docs/MASTER_SPEC_V1_2_RECOVERED.md), a
[recuperação](docs/RECOVERY.md) e a [auditoria](docs/UPSTREAM_AUDIT.md) preservam
as referências do Analyzer. Suas limitações de arte recuperada não descrevem
os sprites novos da Bee Exchange. Consulte também a
[revisão de conformidade](docs/CONFORMANCE_REVIEW.md).
