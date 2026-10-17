# Bee Exchange — 24 slots e sprite Auto Refugee, 0.2.2-dev

Solicitação do usuário após validar a melhora da 0.2.1: acrescentar quatro
slots para completar visualmente a fileira inferior e substituir o sprite por
uma máquina semelhante ao Terramart, com placa amarela levemente alaranjada
**Auto Refugee** no lugar da placa vermelha.

## Inventário

- **24 slots reais**, conforme a nova instrução (substitui o limite anterior de 20).
- Grade superior direita: 4×4, offsets **0–15**, origem (81,62).
- Fileira inferior: **8×1**, offsets **16–23**, origem **(4,43)**.
- Layout igual ao chest24 nativo, com backingImage empty.png de 18×18 e spacing
  de 19×19. Centros e contagens nativos; cabeçalho `<slots> SLOTS` mostra 24.
- Os slots anteriores conservam os índices; os quatro novos são **20–23**.
- Todos são compartilhados entre entrada/saída e participam da troca automática.
  O controlador já lê slotCount da configuração; nenhuma regra de troca mudou.
- Para ITD, ampliar o intervalo para **0–23**, mantendo os filtros por item.

O engine OpenStarbound v0.1.15.1, `StarContainerObject.cpp::readStoredData`,
carrega o inventário anterior e aplica `resize(configValue("slotCount"))`.
O aumento preserva os índices existentes; não requer quebrar a máquina.
O cenário é simulado nos testes, mas o reload de um save real ainda precisa
ser conferido dentro do jogo.

## Sprite e animações originais do FU

Conforme a orientação adicional do usuário, a máquina agora usa **diretamente**
o sprite original do Terramart Shipments 3.5 do FU, sem redesenho ou resize:
`/objects/generic/cropshipper/cropshipperkhe.png`, frames nativos de **64×80**.
O ícone é o nativo de 16×16. A única arte nova é a placa transparente
**AUTO / REFUGEE**, amarela levemente alaranjada, com favos e letras escuras de
3×5 pixels, sobreposta no lugar da placa vermelha. Nome e ID do item continuam
Bee Exchange e `fubeesgenetics_beeexchange`.

A configuração parte de `cropshipperkhe.animation` do FU: frames, ciclos,
transições, fullbright e sons são iguais; caminhos relativos são convertidos
para absolutos e a placa é adicionada como camada superior. S10 compara essa
configuração com a referência FU real. Nenhum spritesheet ou som nativo é
incorporado ao PAK; continuam vindo das dependências instaladas.

Quando uma troca consome suas entradas confirmadas, o controller aciona
**ship**: 23 frames em 2 segundos, transição automática para **closed**.
Aos 3,5 segundos aciona **open**, cujos 4 frames em 0,4 segundo retornam a
**ready**. Fullbright e sons são os definidos pelo FU. Trocas simultâneas
compartilham um ciclo visual e não reiniciam a animação já em andamento.
A animação não cria uma segunda venda nem interfere nas recompensas: as trocas
continuam automáticas durante o ciclo. Itens ignorados, lotes incompletos e
falhas de retirada não acionam envio. Não há lançamento extra de projétil.

A placa vem de `tools/build_beeexchange_assets.py`, em pixels nativos e alpha
binário, sem dependências gráficas de build. O footprint físico de 6×5 tiles
é conservado. Sprite e animação usam a mesma origem (-8,0); os trilhos e bordas
excedentes são decorativos. Fonte/procedência em
[artwork/machines/auto-refugee](../artwork/machines/auto-refugee/README.md).

[Prévia offline da interface e sprite](../artwork/implemented/beeexchange-0.2.2.png),
[sequência de envio em GIF](../artwork/implemented/beeexchange-0.2.2-shipment.gif) e
[HTML interativo](../artwork/implemented/beeexchange-0.2.2.html).
São renderizações de revisão com fonte aproximada, não capturas do engine.
A prévia opcional usa Pillow/Chromium; build do PAK não depende deles.

## Validação

**125 grupos locais passaram**: Adapter 22, Queen Filter 40, interface 20,
Bee Exchange 30 e assets 13. O novo E27 preenche os 20 offsets anteriores com
itens e processa Queens nos quatro novos slots sem alterar os itens antigos.
S13 verifica 24 posições sem repetição ou sobreposição, fundo e centralização
nativos. Frames, transições, fullbright, sons, camada da placa, footprint e posição
também conferidos. E28–E30 verificam acionamento na venda, retomada e ausência
de reinícios em vendas contínuas.

A revisão no Chromium confirmou 24 células e cliques nos novos offsets, com
alternância cheio/vazio. O PAK passou por desempacotamento nativo de **36 arquivos**,
assets idênticos e metadata JSON equivalente. Hashes em dist/SHA256SUMS.
Entrega em dev, sem PR ou alteração em main; teste no jogo ainda pendente.

## Instalação e reteste

1. Feche o jogo, substitua o PAK anterior por **fubeesgenetics-mvp-0.2.2-dev.pak**
   e mantenha apenas uma cópia. Não quebre nem refaça a máquina existente.
2. Ao recarregar, confira seus itens anteriores, o sprite Auto Refugee e **24 SLOTS**.
3. Confira a fileira inferior completa, ícone, Take all e os quatro últimos slots.
4. Deposite Honey Queens nos novos slots: cada uma deve render 10 Coal. Faça
   também um lote de cinco Honey Drones para confirmar 7 Pixels.
5. Confira sprite sobre o chão, objeto espelhado se aplicável, encaixe da placa,
   cliques na área física e convivência com outros objetos. A referência 6×5
   de colisão é a mesma da máquina anterior, apesar dos trilhos mais altos.
6. Venda abelhas e confira animação de envio, fechamento, reabertura, sons e
   retorno a ready; vendas contínuas não devem reiniciar o movimento no meio.
7. Amplie os offsets ITD para 0–23 e repita o roteiro de trocas com GUI fechada.
