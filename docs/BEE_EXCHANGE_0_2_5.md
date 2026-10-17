# Bee Exchange 0.2.5-dev

Display inferior: duas fases azuis nativas em ready (0,2 s) e seta amarela para
cima em work, extraída dos frames de envio do Terramart. Fullbright separado,
sem o símbolo azul pintado por baixo. LED ciano na metade superior da lateral.

Carcaça recomposta com pixels/paleta do Terramart Shipments 3.5 do FU fixado em
tools/upstream.json. Removidas a abertura escura na lateral e marcas isoladas
no painel direito; a posição antiga do LED foi preenchida com metal. Mantidos
placa Auto Refugee, vidro transparente, haste, inseto e teleporte aprovados.

Inspeção: textos próprios para Human, Apex, Avian, Floran, Glitch, Hylotl e
Novakid, com fallback genérico. A descrição e inspeções esclarecem o lote de
cinco drones da mesma espécie, que paga sete Pixels. Genéticas podem diferir.

O log fornecido pelo usuário confirmou 0.2.4-dev em OpenStarbound 0.1.14 e não
apresentou erro Lua da máquina. O usuário esclareceu que havia menos de cinco
drones ou espécies misturadas; por isso a venda não disparava. Mantida a lógica
original da tabela Bee Refuge, sem alterar taxas ou aceitar lotes mistos.
Os casos existentes E3/E4/E5 verificam essas condições e a troca de lote completo.

Reproduzir arte: python3 tools/build_beeexchange_work_assets.py (Pillow e cache
fixado dos checks). Preview: artwork/implemented/beeexchange-0.2.5.gif. A prévia
GIF arredonda os tempos; o animator mantém work em 1,25 s.

Validação: 126 grupos locais passaram, com bindings do jogo simulados e checks
estáticos; PAK SBAsset6 empacotado/extraído com ferramentas nativas e os 42
arquivos conferidos byte a byte (metadata por equivalência JSON). Teste visual
dentro do jogo pendente. Não houve mudança na lógica de trocas, receita, ID,
16 slots ou inventário. Substituir o PAK anterior, sem instalar duas cópias.
