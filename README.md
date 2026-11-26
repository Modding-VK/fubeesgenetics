# Bee Abusive Industry

Addon de **Frackin Universe para OpenStarbound**, com Genetic Queen Filter
(Bee Analyzer), Bee Exchange (Auto Refugee), Bee Genetic Microscope,
Genetic Stabilizer, quatro variantes de Overload Apiary e Genetic Hybridizer.

**Versão de desenvolvimento: 3.0.3-dev. Autor: Goblin Man.**

[Baixar o PAK atual pela Action](https://github.com/Modding-VK/fubeesgenetics/actions/workflows/build-pak.yml) · [Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=3822748368) ·
[Identidade e prontidão da release](docs/RELEASE_READINESS.md) ·
[Histórico](docs/VERSION_HISTORY.md) · [Estado e validação](docs/IMPLEMENTATION_STATUS.md)

A release 3.0 reúne nove máquinas e seis pesquisas na árvore Agriculture.
Ela acrescenta o microscópio genético, o estabilizador e as variantes
Framekeeper e Tri-Frame dos apiários Overload. O nome técnico
`FUBeesGenetics`, os IDs existentes e os inventários são preservados.

O mantenedor confirmou que o conteúdo de desenvolvimento está pronto para
produção. A `main` contém a versão estável 3.0.0; a `dev` usa 3.0.3-dev.
A página oficial da Steam já existe, e suas atualizações são enviadas pelo
mantenedor com o Steam Mod Uploader.

## Direção de arte de máquinas

Referência para arte futura: [estética de sprites de máquinas Starbound](docs/STARBOUND_MACHINE_SPRITES.md),
com [prancha e fontes medidas](docs/SPRITE_SOURCES.md) e
[ficha de criação para IA](docs/MACHINE_SPRITE_BRIEF.md).

## Auditoria de scripting — 0.2.38-dev

Todo o conteúdo próprio foi revisado: leituras de inventário da Auto Refugee,
carregamento e consultas florais dos apiários, tags e linhagens híbridas,
interfaces e ponte IC. As garantias físicas e o balanceamento foram preservados.
Veja [escopo, evidências, escolhas e reteste](docs/SCRIPTING_AUDIT_0_2_38.md).
O ganho de tempo de script ainda precisa de medição no jogo.

## Otimização do Genetic Queen Filter — 0.2.37-dev

Controlador com menos callbacks, janela com polling de 1 s e atualização somente
dos campos alterados, caches limitados e identificação de linhagens híbridas por
par parental/subtipos/dominância. Perfis híbridos antigos sem identidade completa
recriam apenas a baseline; modos e itens são preservados. A vazão continua em
uma unidade por segundo. Ver [detalhes, evidências e roteiro de medição](docs/FILTER_PERFORMANCE_0_2_37.md).

## Critérios fixos e venda em lote — 0.2.64-dev

Equal e Within range permitem alvos fixos por gene, sem alargar a janela. A
Auto Refugee agrupa os lotes de drones, com capacidade e trabalho por ciclo
limitados. Ver [comportamento, migração e validação](docs/FILTER_TARGETS_AND_BATCHES_0_2_64.md).

## Instalação

1. Instale Frackin Universe e execute OpenStarbound.
2. Com o jogo fechado, substitua o PAK anterior em `Starbound/mods` por
   `bee-abusive-industry-3.0.3-dev.pak` do artefato da Action. Mantenha apenas
   uma cópia do addon.
3. Abra novamente o jogo. A atualização conserva IDs e inventários; não precisa
   refazer as máquinas nem resetar o perfil do Analyzer.

[dist/SHA256SUMS](dist/SHA256SUMS) identifica o último pacote histórico em `dist/`.
O artefato da Action contém os hashes do pacote atual.
O ZIP Workshop contém os mesmos bytes com o nome padrão `contents.pak`.
O item oficial está publicado na [Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=3822748368); veja o fluxo de atualização em [WORKSHOP](docs/WORKSHOP.md).

## Pesquisa na árvore Agriculture

Os dez blueprints do addon são aprendidos em sete pesquisas ligadas à trilha de
abelhas do FU. A Bee Station continua sendo a estação de fabricação na aba Functional.
A coleta da estação não ensina mais as receitas do addon.

| Pesquisa | Requisitos | Custo | Blueprints |
| --- | --- | --- | --- |
| Industrial Beekeeping | bees3 (Advanced Beekeeping) | 1.000 Research + 1 A.I. Chip | Genetic Queen Filter, Auto Refugee |
| Abusive Apiaries | Industrial Beekeeping | 1.400 Research + 60 Madness | Overload Apiary, Overload Large Apiary |
| Advanced Frame Management | Abusive Apiaries | 1.800 Research + 60 Madness | Overload Framekeeper, Overload Tri-Frame |
| Efficient Bee Microscopy | Industrial Beekeeping | 1.200 Research | Bee Genetic Microscope |
| Genetic Stabilization | Efficient Bee Microscopy | 2.000 Research + 100 Madness + 1 Unknown Gene + 1 Isogen Bar | Genetic Stabilizer |
| Unethical Genetic Practices | Genetic Stabilization | 2.200 Research + 120 Madness + 1 Red Matter | Genetic Hybridizer |
| Swarm Encapsulation | Genetic Stabilization | 1.800 Research + 80 Madness | Swarm Assembler |

A disposição forma duas ramificações em favo: Abusive Apiaries leva a
Advanced Frame Management; Efficient Bee Microscopy leva a Genetic
Stabilization e depois a Unethical Genetic Practices. O ícone de frames usa
três quadros de tungstênio sobrepostos; microscópio e estabilizador usam os
ícones das respectivas máquinas.

Personagens que já aprenderam blueprints por coleta mantêm esse conhecimento.
Consulte [integração de pesquisa](docs/FU_BEE_RESEARCH_ANALYSIS.md).

Todos os objetos próprios do mod têm texto de scanner para Human, Apex, Avian,
Floran, Glitch, Hylotl e Novakid, além de uma descrição genérica. Essa regra
também vale para novos objetos.

## Genetic Queen Filter / Bee Analyzer

Contêiner real de três slots que classifica Queens e Young Queens analisadas
por seis traits, com referências adaptativas e comparadores configuráveis.

- Pesquise **Industrial Beekeeping** na árvore Agriculture para aprender a receita.
  Fabrique na Bee Station, aba Functional com 2 AI Chips, 5 Laser Diodes, 5 Reinforced Glass, 10 Titanium Bars,
  10 Healing Water, 5 Sulphuric Acid e 2 Unknown Gene.
- Use o Input central. A primeira abelha válida estabelece a referência e vai
  para Approved. Todas as condições ativas precisam passar; igualdade é aceita.
- Escolha **Equal or higher**, **Equal or lower** ou a coluna **Custom** por trait.
  O botão **+** abre o editor individual: **Indifferent**, **Equal** ou **Within range**.
  Informe o alvo ou os limites inclusivos em unidades exibidas pelo jogo e clique **Apply**.
  Equal e Within range são fixos: aprovações não movem seus valores. Indifferent
  não compara o gene e congela a referência. Os modos podem ser definidos antes da baseline.
  Na coluna **REF / TARGET**, `=40` mostra igualdade e `35..45` mostra intervalo.
  Valores de Mutation Chance usam porcentagem e respeitam a discretização genética FU.
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

O **Bee Genetic Microscope** prepara abelhas para a inspeção dos genes. Aceita
itens com a tag de abelha do FU e devolve uma unidade com os parâmetros
preservados e `genomeInspected=true`, sem gerar Research, Pixels ou recompensas.
A análise não tem tempo de experimento nem custo de energia; aguarda o slot
Analyzed ficar livre. Seus dois slots têm offsets 0 (Input) e 1 (Analyzed).

A entrada lógica superior liga/desliga: sem fio funciona; sinal baixo pausa
novas análises e alto permite operar. A entrada inferior e a saída usam a rede
de itens FU/ITD; filtre os slots para inserir abelhas e retirar as analisadas.
A janela compacta reutiliza a UI do microscópio FU, com ícone em moldura de
retrato e tanque em âmbar de mel.

Pesquise **Efficient Bee Microscopy** e fabrique na Bee Station com
1 N. Electron Microscope, 5 A.I. Chips e 20 Laser Diodes. ID para
`/spawnitem`: `fubeesgenetics_geneticmicroscope`.
Veja [mecânica e automação](docs/GENETIC_MICROSCOPE_0_2_86.md).

## Bee Exchange / Auto Refugee

Troca abelhas automaticamente conforme as receitas do Bee Refuge do FU.

- Receita na Bee Station / Functional: **1 Bee Refuge + 1 Terramart Shipments 3.5
  + 2 AI Chips**. Desbloqueio em **Industrial Beekeeping**.
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

## Overload Apiary

As quatro variantes oferecem entrada e saída para a rede de itens do FU. A
entrada inferior existente continua sendo o nó de energia; a entrada superior
é de itens e a saída é de itens. A rede acessa o inventário compartilhado:
configure a automação para usar os slots corretos de rainha, drones e frames.

Apiário alimentado por **12 W**, com produção de recursos e drones **1,2×** e
vida útil da rainha **0,8×**. Sem energia, continua produzindo na velocidade
normal; o desgaste da rainha permanece. A receita usa 1 Normal Apiary, 1 A.I.
Chip e 5 Durasteel Bars. O blueprint vem de **Abusive Apiaries**.
Ele não gera abelhas entidades capturáveis aleatórias; Drones e larvas seguem
como itens no inventário.
Consulte a [especificação](docs/OVERLOAD_APIARY_0_2_20.md).

O pequeno tem 15 slots de output em 3 linhas de 5, além dos slots de rainha,
drone e quadro. O **Overload Large Apiary** tem 20 slots de output em 5 linhas
de 4, além de dois espaços para drones e dois para quadros. Ambos usam a mesma
regra de produção e desgaste e consomem 12 W para ativar o bônus. A receita do
Large na Bee Station é 1 Large Apiary, 1 A.I. Chip e 5 Durasteel Bars.

As novas variantes usam inicialmente as mesmas texturas dos Overload atuais:
**Overload Framekeeper** conserva os quadros inseridos sem consumir sua
durabilidade, mantendo os bônus e funções nativas dos quadros; **Overload
Tri-Frame** usa o corpo grande e oferece três slots de quadro, com desgaste
normal. O Framekeeper mantém um slot de quadro e 15 saídas; o Tri-Frame tem
dois slots de drones, três de quadros e 20 saídas. Ambas usam 18 W para o bônus
de produção de 1,2× e mantêm a vida útil da rainha de 0,8×. Sem energia,
produzem na velocidade normal; a penalidade de vida continua. O Framekeeper é feito a partir do Overload pequeno (2 AI Chips e 10
Durasteel Bars); o Tri-Frame parte do Overload Large (3 AI Chips e 15
Durasteel Bars).

As duas variantes são desbloqueadas em **Advanced Frame Management**.
Os LEDs ciano ficam fullbright quando o apiário recebe energia, sem iluminar
o ambiente. O Framekeeper preserva os quadros dentro do ciclo nativo do FU,
sem timer adicional. IDs para `/spawnitem`:
`fubeesgenetics_overloadframekeeper` e `fubeesgenetics_overloadtriframeapiary`.

## Genetic Hybridizer e abelhas híbridas

O **Genetic Stabilizer**, desbloqueado em Genetic Stabilization, trata uma abelha
por vez em 10 segundos e reduz sua chance genética de mutação pela metade,
arredondada ao valor representável mais próximo. Cada tratamento tem 40% de
chance de destruir a abelha. A receita na Bee Station usa 5 AI Chips, 10
Durasteel Bars, 10 Cell Matter, 5 Isogen Bars, 5 Lunari Crystals e 5 Unknown
Genes (`solaricrystal` é o ID FU dos Lunari Crystals). Não requer energia.
Aceita abelhas FU ou híbridas com genome válido e preserva os demais genes e
parâmetros. Saída ocupada impede o tratamento; trocar o exemplar, descarregar
a máquina ou bloquear a saída reinicia o ciclo incompleto.

Sua janela compacta apresenta Input/Treated, duração e risco. O corpo amarelo
usa detalhes turquesa e displays/partículas fullbright durante o tratamento.
ID para `/spawnitem`: `fubeesgenetics_geneticstabilizer`.
Veja [regras e limites do tratamento](docs/GENETIC_STABILIZER.md).

A janela do Hybridizer usa moldura compacta de 270×165 pixels, logo próprio e
favo de mel discreto no canto inferior direito. O cabeçalho segue o alinhamento
do Analyzer. Ver [layout e diretriz visual](docs/HYBRIDIZER_UI_0_2_41.md).

Cruza Queen e Drone de espécies FU diferentes. Cada tentativa consome **10.000
unidades de energia a até 24 W** para completar o progresso do experimento.
Os dois progenitores são consumidos em sucesso ou falha. A chance inicial de
sucesso é 30%, ou 10% quando os progenitores são rivais.
Desde 0.2.39-dev, o progresso só avança com progenitores válidos inseridos e
saída livre. O progresso parcial é preservado se uma entrada for retirada.
Desde 0.2.40-dev, reinserir o mesmo exemplar conserva o progresso; substituí-lo
por outro reduz o progresso acumulado em 50% e exibe um alerta de retrabalho.
Desde 0.2.32-dev, a máquina atualiza a cada 30 ticks e a janela consulta o
estado a cada 2 segundos para reduzir carga na thread do mundo. O avanço pode
ficar mais lento em redes sem bateria.
O sucesso produz **uma larva de rainha híbrida** (`bee_hybrid_youngQueen`),
que se torna adulta no apiário, preservando o genome e a linhagem.
Desde 0.2.33-dev, genes favoráveis positivos não caem para zero apenas pela
penalidade do cruzamento. Híbridas já criadas preservam seu genome anterior.
Desde 0.2.34-dev, o Hybridizer reduz os genes favoráveis em um terço do menor
valor parental, arredondando ao inteiro mais próximo e mantendo mínimo 1.
Cada cruzamento tem duas subespécies com prioridade de produção alternada e
uma folha de sprites própria para Queen, larva e Drone, que funde formas,
marcas e cores parentais. As duas usam a mesma aparência. A Queen híbrida
transmite sua linhagem a Young Queens e Drones.
O subtítulo mostra `Predominant:` seguido da subespécie nativa cuja produção tem
maior peso. A produção combina 2/3 da linhagem predominante e 1/3 da recessiva,
preservando a união dos recursos dos dois progenitores.

O Hybridizer tem quatro saídas de automação: 1 indica experimento ativo, 2 indica
Research Disc inserido, 3 indica larva na saída e 4 indica máquina pronta.

- Blueprint desbloqueado por **Unethical Genetic Practices**; receita na Bee Station.
- Produção híbrida disponível no **Overload Apiary** e nos apiários nativos
  pequeno e grande do FU. Os apiários nativos mantêm sua produção sem energia;
  o patch lê a linhagem para recursos, preferências e descendentes híbridos.
  Eles continuam a gerar entidades capturáveis para abelhas nativas, mas não
  tentam gerar entidades híbridas inexistentes.
- O catálogo contém **595 combinações / 1.190 subespécies** e 595 folhas de
  sprites. [Prévia visual](artwork/hybrids/preview.png).

Na 0.2.23-dev, os pares são calculados a partir dos dados das 35 famílias do
FU. O catálogo detalhado continua na documentação; o PAK carrega apenas as
plantas escolhidas (1,6 KB). Apiários comuns carregam a lógica híbrida somente
quando recebem uma híbrida. O construtor visual dos itens também deixou de
carregar a lógica de produção.

ID para `/spawnitem`: `fubeesgenetics_hybridizer`.

## Swarm Assembler (protótipo)

Fabrique na Bee Station após pesquisar **Swarm Encapsulation**. Use uma Queen
adulta, 1.000, 2.000 ou 3.000 Drones da mesma espécie e genoma, uma Capture Pod
e um A.I. Chip. A prévia mostra os atributos base antes do ciclo de 60 segundos.
Consulte [mecânica e roteiro de validação](docs/SWARM_ASSEMBLER.md).

## Desenvolvimento e GitHub

**Eficiência de scripting é requisito para todo conteúdo novo ou alterado.**
Consulte a [política de desempenho](docs/SCRIPTING_PERFORMANCE.md) e a
[skill do projeto](.agents/skills/starbound-scripting-performance/SKILL.md).


As regras acordadas no chat **Bee Analyzer** valem para as duas máquinas:

- `dev`: desenvolvimento e PAKs com versão `X.Y.Z-dev`.
- `main`: produção; PR, merge ou promoção só mediante solicitação explícita.
- Preservar histórico compartilhado e PAKs antigos; downloads usam commits fixos.
- Tags estáveis `vX.Y.Z` ficam reservadas às promoções autorizadas.

Veja [VERSIONING](docs/VERSIONING.md), [operação GitHub](docs/GITHUB_PUBLICATION.md)
e [AGENTS.md](AGENTS.md). O nome público **Bee Abusive Industry** e o título
Workshop **[oSB][FU] Bee Abusive Industry** já foram aplicados. O name técnico
e os IDs permanecem iguais. [Identidade e planejamento](docs/ROADMAP.md).

## Testes e ferramentas

Ambiente usado: Python 3.12 e Lua 5.4 (executável ou biblioteca compartilhada).
Instale `requirements-build.txt` para gerar e validar os sprites com Pillow.
O GitHub Actions usa as ferramentas nativas Starbound/OpenStarbound fixadas em
[pak_toolchain.json](tools/pak_toolchain.json) para gerar novos PAKs.

```sh
python3 tools/check_version.py --release  # main; em dev, usar --development
python3 tools/build_hybrid_sprites.py --check
python3 tools/build_research_icons.py --check
python3 tools/run_checks.py --fetch
# Opcional: testar com o IC 2.11 original desempacotado, sem redistribuí-lo.
python3 tools/run_checks.py --ic-root .cache/improved-containers
```

A release 3.0.0 passou nos [checks MVP](https://github.com/Modding-VK/fubeesgenetics/actions/runs/44217817831)
e no [build do PAK](https://github.com/Modding-VK/fubeesgenetics/actions/runs/44217817950).
A suíte confere os nove objetos, receitas, conexões e custos de pesquisa,
layouts e referências de assets. Os testes do estabilizador cobrem redução
da mutação, preservação dos parâmetros, risco de perda, saída bloqueada,
recuperação de inserção e estados de animação.

Bindings de engine, jogador, rede e GUI são simulados; esses testes não equivalem
à execução dentro do jogo. O build confere o PAK por extração nativa e comparação
dos arquivos. Os 13 casos opcionais de Improved Containers 2.11 registrados na
0.2.23 são históricos e não foram repetidos nesta revisão do README.

`--fetch` prepara referências fixadas e verificadas por hash em
[upstream.json](tools/upstream.json) e [ui_upstream.json](tools/ui_upstream.json).
O IC opcional segue [ic_upstream.json](tools/ic_upstream.json). Para um checkout
FU local, use `--fu-root /caminho/FrackinUniverse`. Caches não são redistribuídos.

Geradores atuais: `tools/build_assets.py` (Analyzer),
`tools/build_beeexchange_work_assets.py` (móvel/animação),
`tools/build_beeexchange_icon.py` (ícone), `tools/build_research_icons.py`
(ícones de pesquisa) e `tools/build_hybrid_sprites.py`
(595 folhas de sprites e prévia). [Roteiro de testes no jogo](docs/IN_GAME_TESTS.md).

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
