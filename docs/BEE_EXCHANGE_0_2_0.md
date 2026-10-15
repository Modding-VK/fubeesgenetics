# Bee Exchange — 0.2.0-dev

Segunda máquina do projeto, implementada conforme as instruções deste chat.
Nome provisório: **Bee Exchange**; ID estável: `fubeesgenetics_beeexchange`.
O nome público do mod e os IDs do Genetic Queen Filter não mudaram.

## Referências auditadas

FU: `sayterdarkwynd/FrackinUniverse`, commit
`17868d86c9bb7bc00f92038fb78b48cebd1b41b8`.
Os hashes Git dos 105 arquivos de troca e das referências da máquina estão em
`tools/upstream.json`, verificados pelo runner e pelo CI com `--fetch`.

- Bee Refuge: `objects/bees/beerefuge/beerefuge.object`, ID `beerefuge`.
- Trocas: `recipes/bees/beerefuge/queens`, `larva` e `drones`.
- Terramart Shipments 3.5: `objects/generic/cropshipper/cropshipper_kheAA2.object`,
  ID `cropshipper_kheAA2`, 40 slots; sua lógica automática fica em
  `cropshipper_kheAA.lua`. Não se trata de outro mod.
- A máquina nova tem **20 slots**, exatamente metade, em grade nativa 5×4.

A automação é própria: não usa o preço de venda genérico do Terramart nem
`containerTakeAll`. Só realiza as trocas de abelhas das receitas do Bee Refuge.
Nenhum sprite ou código do Terramart foi copiado. Os sprites novos são
provisórios, gerados em resolução nativa por `tools/build_beeexchange_assets.py`.

## Receita e desbloqueio

**1 Bee Refuge + 1 Terramart Shipments 3.5 + 2 AI Chips**.
Fabricada na aba Functional da **Bee Station**, nos mesmos grupos do Queen Filter.
A receita é aprendida ao obter a Bee Station; em saves existentes, recolha e
obtenha a estação novamente. O patch preserva os blueprints anteriores.
A máquina não é printable. Não é necessário resetar o Queen Filter existente.

## Operação

- Deposite abelhas em qualquer slot; recursos e Pixels aparecem no mesmo inventário.
- Trocas automáticas a cada segundo enquanto a região está carregada, com a
  interface aberta ou fechada. Não há botão, energia ou exigência de superfície.
- Queens adultas: uma por receita, com o recurso e quantidade exatos abaixo.
- Young Queens: uma por **10 Pixels**; Drones: cinco por **7 Pixels**, para cada
  uma das mesmas 35 famílias. Essas são as receitas do Bee Refuge, não preços
  de venda proporcionais. Quatro Drones ficam esperando o quinto.
- Um lote de Drones pode somar stacks da mesma espécie com parâmetros diferentes;
  espécies diferentes não são somadas. Parâmetros dos itens restantes são preservados.
- Não exige inspeção, genome válido ou perfil. Uma Queen depositada será vendida,
  inclusive se tiver bons genes; filtre as abelhas antes de encaminhá-las.
- Itens sem receita de abelha, inclusive recursos produzidos, ficam intactos e
  não impedem o processamento dos demais slots. Não há venda genérica de lixo.
- O mapa de caminhos contém as 105 receitas auditadas. Ao carregar a máquina,
  quantidades e recompensas vêm de `root.assetJson` nas receitas do FU instalado;
  patches sobre essas receitas também são respeitados. Famílias adicionadas em
  caminhos novos exigem auditoria e inclusão no mapa; não são aceitas só pelo prefixo.
- Cada varredura executa no máximo uma receita por posição, até 20 por segundo;
  a prioridade inicial gira para evitar favorecer sempre os primeiros slots.
  Não há simulação de tempo descarregado.

## Tabela de Queens adultas

Os IDs abaixo reproduzem `input` e `output` das 35 receitas auditadas.
Cada linha consome **1 Queen**. Young Queens e Drones seguem as regras acima.

| Abelha (Queen) | Recurso | Quantidade |
| --- | --- | --- |
| `bee_aquarum_queen` | `oceanite` | 4 |
| `bee_artisan_queen` | `paper` | 5 |
| `bee_assassin_queen` | `fuflesh` | 2 |
| `bee_bumblebee_queen` | `normalcomb` | 2 |
| `bee_carpenter_queen` | `darkwoodmaterial` | 50 |
| `bee_crystalwing_queen` | `crystal` | 3 |
| `bee_cuckoo_queen` | `beesilk` | 2 |
| `bee_cybernetic_queen` | `titaniumbar` | 2 |
| `bee_devoratrix_queen` | `ghostlywax` | 2 |
| `bee_digger_queen` | `clay` | 20 |
| `bee_exspiravit_queen` | `corruptionore` | 1 |
| `bee_gelidburrower_queen` | `ff_plastic` | 2 |
| `bee_goldensaint_queen` | `goldenwood` | 2 |
| `bee_harlequin_queen` | `sulphur` | 4 |
| `bee_honey_queen` | `coalore` | 10 |
| `bee_inventor_queen` | `silverbar` | 2 |
| `bee_isovapitdae_queen` | `mutavisksilk` | 1 |
| `bee_leafcutter_queen` | `fu_carbon` | 2 |
| `bee_loamzipper_queen` | `lead` | 4 |
| `bee_mason_queen` | `copperbar` | 2 |
| `bee_orchid_queen` | `beeflowerhead` | 4 |
| `bee_oremason_queen` | `ironbar` | 2 |
| `bee_plasterer_queen` | `silkfibre` | 2 |
| `bee_reaper_queen` | `leather` | 1 |
| `bee_redbanded_queen` | `blobbushjelly` | 1 |
| `bee_rimewing_queen` | `icecrystal` | 1 |
| `bee_sandprowler_queen` | `glass` | 4 |
| `bee_scoria_queen` | `corefragmentore` | 4 |
| `bee_shrouded_queen` | `effigiumbar` | 1 |
| `bee_squash_queen` | `tritium` | 1 |
| `bee_stalwart_queen` | `petalyellow` | 3 |
| `bee_stellar_queen` | `solariumore` | 1 |
| `bee_sweat_queen` | `bugshell` | 2 |
| `bee_tunguskudae_queen` | `uraniumore` | 1 |
| `bee_xenodaemonae_queen` | `liquidelderfluid` | 2 |

## Inventário e recuperação

A máquina simula o inventário depois da retirada para conferir se **a recompensa
inteira cabe**. Sem espaço suficiente, não retira as abelhas. Recompensas podem
empilhar ou ocupar slots liberados pela própria troca. Os limites de stack vêm
da configuração real dos itens, não de um valor universal inventado.

As entradas são conferidas novamente antes da retirada; uma falha parcial de
retirada devolve os descritores exatos, sem gerar recompensa. Uma falha inesperada
de inserção guarda apenas a recompensa ainda devida em `storage.exchangePending`.
Novas vendas aguardam a entrega, que retoma após reload e desconta inserções
parciais pelo delta real de cada slot. Isso também trata o retorno legado de
`containerPutItemsAt` do OpenStarbound 0.1.14 sem duplicar itens.

Ao quebrar a máquina, o engine derruba o inventário físico. O script tenta
derrubar apenas itens pendentes, uma vez. Se o próprio engine falhar ao gerar
esse drop, registra erro e o descritor; não há garantia de recuperação depois
da destruição nesse cenário excepcional. Save/reload e destruição precisam
ser verificados no jogo, pois os bindings do runner são simulados.

## Automação e interface

Grade nativa de **20 slots compartilhados**, offsets ITD **0–19**. Configure o
ITD para inserir apenas abelhas e extrair apenas recursos/Pixels; não há faixas
separadas de entrada/saída. Slots mantêm tamanho e espaçamento nativos de 19px.
A integração registra o container via a biblioteca real `transferUtil` do FU;
a interação real com ITD ainda precisa de teste no jogo.

A HUD compacta de 260×180 e o sprite de 48×40 são específicos da nova máquina.
Nenhum script, sprite, receita ou posição de slot do Queen Filter foi alterado.

## Validação e entrega

**120 grupos passaram**: Adapter 22, Queen Filter 40, interface 20, Bee Exchange
26 e assets 12. O grupo E1 executa individualmente todas as 105 trocas com as
receitas FU reais fixadas; E25 verifica que alterações de recompensa em runtime
são lidas. Os demais cobrem lotes, parâmetros, itens ignorados, capacidade,
recuperação, reload, retorno legado do engine e cadastro para automação.

O PAK nativo foi desempacotado com restauração de **39 arquivos**, assets
idênticos e metadata JSON equivalente. Hashes em `dist/SHA256SUMS`.
Build de desenvolvimento em `dev`, sem PR ou promoção de `main`.
Não representa publicação na Steam ou validação dentro do OpenStarbound.

```sh
python3 tools/check_version.py --development
python3 tools/run_checks.py --fetch
python3 tools/build_beeexchange_assets.py
python3 tools/package.py --output-dir .cache/deliveries
```

## Reteste no jogo

1. Feche o jogo, remova o PAK anterior e instale somente a 0.2.0-dev.
2. Obtenha novamente a Bee Station e confirme as duas receitas na aba Functional.
3. Fabrique a Bee Exchange com os três componentes e coloque-a no chão.
4. Deposite 1 Honey Queen: deve aparecer **10 Coal**; deposite 1 Cybernetic
   Queen: devem aparecer **2 Titanium Bars**, sem clique de venda.
5. Deposite 4 Honey Drones: devem ficar intactos. Acrescente o quinto (também
   com genes diferentes): devem render exatamente **7 Pixels**.
6. Deposite 1 Young Queen: deve render **10 Pixels**. Misture pedra, recursos
   e outra espécie de Drone: itens sem receita/lote completo ficam intactos.
7. Repita com GUI fechada, depois abra para conferir; teste inventário cheio,
   stacks parcialmente preenchidas e retomada após retirar a saída.
8. Configure ITD com filtros e offsets 0–19, inserindo abelhas e retirando
   recompensas; confirme que não remove abelhas antes de serem processadas.
9. Salve/recarregue o mundo e quebre a máquina com conteúdo: confira a conservação
   dos itens. Confirme que o Queen Filter e seu perfil anterior continuam funcionando.

Para administração: `/spawnitem fubeesgenetics_beeexchange`.
