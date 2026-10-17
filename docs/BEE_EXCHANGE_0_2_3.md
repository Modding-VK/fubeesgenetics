# Bee Exchange — 16 slots e Young Queens por recursos, 0.2.3-dev

## Alterações solicitadas

- Removidos os oito slots da fileira inferior: agora são **16 slots reais**,
  com offsets **0–15**, em uma grade 4×4.
- A interface usa o modelo **chest16** nativo, com o fundo, altura, imagem do
  objeto, posição da grade, contador e Take all próprios desse tamanho.
- **Young Queens recebem o mesmo recurso e a mesma quantidade das Queens
  adultas da respectiva espécie.** Cada receita padrão consome uma unidade.
  Honey Queen e Honey Young Queen → 10 Coal; Cybernetic Queen e Young Queen
  → 2 Titanium Bars; as demais seguem a mesma correspondência entre espécies.
- Drones continuam em lotes de **5 por 7 Pixels**. Itens sem receita ficam intactos.
- Receita, desbloqueio, ID, sprite/placa Auto Refugee e animações/sons do FU não mudam.

## Regras e fonte das recompensas

A máquina carrega as 105 receitas auditadas do Bee Refuge do FU. Depois de
carregar todas, substitui **apenas a recompensa** de cada `_youngQueen` por
uma cópia da recompensa de `_queen` da mesma espécie. Assim, a ordem da lista
não interfere no resultado, não há alias entre recompensas e os patches do FU
sobre as Queens adultas se refletem também nas Young Queens. Recompensas em
Pixels das receitas de larvas não são usadas na Bee Exchange a partir desta versão.
As quantidades de entrada de cada receita continuam respeitadas.

A [tabela das 35 Queens adultas](BEE_EXCHANGE_0_2_0.md#tabela-de-queens-adultas)
agora também se aplica às respectivas Young Queens. Isso é uma diferença
intencional em relação ao Bee Refuge, conforme solicitado pelo usuário.
Não exige inspeção genética; a venda continua automática, inclusive com GUI fechada.

## Atualizar uma máquina existente

**Antes de atualizar, retire os itens dos oito slots da fileira inferior.**
Feche o jogo e substitua o PAK anterior por `fubeesgenetics-mvp-0.2.3-dev.pak`,
mantendo uma única cópia instalada. Não é necessário fabricar a máquina novamente.
Configure o ITD para usar apenas os offsets **0–15**.

Fonte auditada: OpenStarbound v0.1.15.1, commit
`e604e078e89310f1212dd20f5cd01bd59d25300b`,
`source/game/objects/StarContainerObject.cpp`. Ao carregar o save,
`readStoredData` chama `resize(slotCount)` e guarda os itens dos slots removidos
em `m_lostItems`; no primeiro `update` do master, o engine gera drops desses
itens na posição da máquina. Portanto, conteúdo dos offsets **16–23** não é
mantido dentro do novo inventário. Esvaziá-los antes da atualização evita
depender da coleta de drops no mundo. Os slots 0–15 conservam seus índices.
Essa leitura do código não substitui o teste com um save real no jogo.

## Validação

**126 grupos locais passaram**: Adapter 22, Queen Filter 40, interface 20,
Bee Exchange 31 e assets 13. E1 executa as 105 entradas, incluindo as 35 Young
Queens com a recompensa adulta correspondente. E31 altera a recompensa adulta
e a recompensa de larva independentemente e verifica que a Young Queen segue
apenas a adulta, preserva parâmetros e não altera a recompensa por alias.
E27 testa processamento nos 16 slots sem acessar posições removidas.

S13 verifica o chest16 com imagens nativas fixadas por hash: 16 índices únicos,
sem grade extra, backing 18×18, spacing 19×19, centralização e posições nativas.
O runner verifica 124 fontes FU e 31 referências Starbound/OpenStarbound.
A prévia offline no Chromium confirmou 16 células, índices 0–15 e alternância
cheio/vazio. Sprite e animação seguem os mesmos assets originais do FU.

O PAK passou por round-trip nativo de **36 arquivos**, assets idênticos e
metadata JSON equivalente. Hashes em dist/SHA256SUMS. Teste dentro do jogo
continua pendente. Entrega somente em dev, sem PR ou alteração de main.

[Prévia offline](../artwork/implemented/beeexchange-0.2.3.png) e
[HTML interativo](../artwork/implemented/beeexchange-0.2.3.html).

## Reteste no jogo

1. Confira o inventário anterior após remover o conteúdo da fileira inferior e
   atualizar. A interface deve mostrar **16 SLOTS** e nenhuma fileira inferior.
2. Deposite uma Honey Young Queen: deve render **10 Coal**, não Pixels.
3. Deposite uma Cybernetic Young Queen: deve render **2 Titanium Bars**.
4. Repita com as Queens adultas e com um lote de cinco Drones: mesmas recompensas
   adultas; Drones continuam rendendo 7 Pixels. Confirme trocas com GUI fechada.
5. Teste Take all, cliques, animações, inventário cheio e ITD nos offsets 0–15.
