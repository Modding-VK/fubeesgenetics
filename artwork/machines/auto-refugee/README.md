# Auto Refugee — placa da Bee Exchange, 0.2.2-dev

A máquina usa **diretamente** o sprite animado do Terramart Shipments 3.5 do FU:
`/objects/generic/cropshipper/cropshipperkhe.png`. Não há redesenho nem redução
ou ampliação do spritesheet de 64×80 por frame. O ícone também é o nativo,
`/objects/generic/cropshipper/cropshippericon.png`, de 16×16.

A única arte nova é uma placa transparente 64×80, desenhada por
`tools/build_beeexchange_assets.py`. Seu conteúdo ocupa a placa frontal no
sprite original; o resto é transparente. O fundo amarelo levemente alaranjado,
os favos e as letras **AUTO / REFUGEE** são desenhados em pixels inteiros.
O gerador é reproduzível e usa somente a biblioteca padrão do Python.

A animação de origem `cropshipperkhe.animation` é reutilizada com os mesmos
frames, durações, transições, fullbright e sons, ajustando apenas os caminhos
relativos para absolutos e adicionando a placa como camada superior (zLevel 2).
O sprite e os sons originais ficam nas dependências FU/Starbound; o PAK novo
não os duplica. Hashes das referências em tools/upstream.json e ui_upstream.json.

O footprint físico original de 6×5 tiles da Bee Exchange é preservado. A origem
(-8,0) centraliza a largura de 64 pixels sobre os 48 pixels da área física.
Trilhos superiores e bordas excedentes são decorativos.
