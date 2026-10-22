# Bee Abusive Industry — identidade e expansão

Identidade originalmente planejada e agora solicitada para execução.
O rebranding público está aplicado na 0.2.19-dev e na preparação da candidata.

## Identidade aplicada

- Nome do mod: **Bee Abusive Industry**.
- Título na Steam Workshop e no OpenStarbound: **[oSB][FU] Bee Abusive Industry**.
- [oSB] identifica OpenStarbound e [FU] identifica Frackin Universe.
- A mudança amplia a identidade do projeto para novos recursos ligados à
  indústria de abelhas; o Genetic Queen Filter permanece uma de suas máquinas.

Autor de apresentação: Goblin Man. O metadata mantém name=FUBeesGenetics para
compatibilidade com dependências e saves. IDs, namespaces, código das máquinas e
URL do repositório não foram renomeados. PAKs novos usam bee-abusive-industry.
O ícone usa a Cybernetic Queen do FU, em fundo laranja, com créditos preservados.
O rebranding não muda a conta proprietária da Workshop nem publica o item.

## Máquina implementada — abelhas por recursos

Objetivo fornecido pelo usuário: trocar abelhas por recursos, tomando como
referência o Bee Refuge do Frackin Universe (mencionado como Bee Refugee na
conversa), com a mecânica de referência do **Terramart Shipments 3.5**.

Implementada na **0.2.0-dev**, com o nome provisório **Bee Exchange**.
As fontes do FU foram auditadas no commit fixado em tools/upstream.json:
105 receitas do Bee Refuge; Terramart Shipments 3.5 usa o ID cropshipper_kheAA2
e 40 slots. A Bee Exchange atualmente usa 16 slots compartilhados e lê as receitas reais
do FU em runtime. Crafting: 1 beerefuge + 1 cropshipper_kheAA2 + 2 aichip,
na Bee Station, com desbloqueio ao obtê-la. Não há dependência adicional de mod.

Ver [especificação, tabela e testes](BEE_EXCHANGE_0_2_0.md).
O mantenedor confirmou todas as alterações anteriores validadas e prontas.
O novo ícone de apresentação ainda precisa de conferência visual no jogo.
Ver [estado e prontidão](RELEASE_READINESS.md).

## Apiário de sobrecarga — implementado em `dev`

Implementação iniciada em **0.2.20-dev**. O novo Apiário reutiliza o ciclo
genético nativo do FU, requer **12 W**, multiplica produção de recursos e drones
por **1,2×** e reduz a vida útil da rainha para **0,7×**. A receita melhora um
Apiário normal com dois AI Chips e oito Titanium Bars. Ver
[especificação e detalhes](OVERLOAD_APIARY_0_2_20.md).
Não gera abelhas entidades capturáveis aleatórias.

## Abelhas híbridas — implementadas em `dev`

A primeira implementação já inclui a máquina de hibridização, Queen/Young
Queen/Drone genéricos com metadados de linhagem, produção dinâmica no Overload
Apiary e nos apiários nativos pequeno e grande do FU, além de folhas de sprites
próprias com formas, marcas e cores parentais
fundidas. O catálogo deriva
**595 espécies / 1.190 subespécies** das 35 famílias FU. A validação dentro do
jogo ainda está pendente. A hibridizadora entrega uma larva de rainha
(`bee_hybrid_youngQueen`), que amadurece no apiário com a mesma genética e
linhagem. Os valores de balanceamento estão no
[plano](HYBRID_BEES_PLAN.md) e no [catálogo completo](HYBRID_SPECIES_CATALOG.json).
Desde 0.2.23-dev, o catálogo completo é usado apenas na documentação e nos
checks; o jogo calcula o par quando necessário e carrega o script de produção
somente ao inserir uma híbrida no apiário.

## Fluxo de trabalho

Planejamento e desenvolvimento permanecem em dev. Não criar PR ou promover
para main sem solicitação explícita. O planejamento não representa publicação
na Steam, nova versão de pacote nem promoção para produção.
