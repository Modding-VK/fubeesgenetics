# Fontes gráficas

machine-recovered.png e icon-recovered.png preservam os pixels do ZIP MVP
reenviado. O sprite final da máquina aprovado em uma sessão anterior não foi
recuperado; esses dois arquivos continuam provisórios e não foram redesenhados.

A GUI usa o tema aprovado em proposals/hud-fu-v1/preview.png, registrado em uma
branch separada e autorizado para implantação pelo usuário. O tema implementado
é gerado como primitivas em pixels nativos por tools/ui_theme.py, usando a
paleta e geometria de ui-theme.json. Não é um recorte/redução do mockup. Nenhum
PNG original de FU é redistribuído; eles serviram como referência visual.

interface-layout.json é a fonte da configuração. tools/build_assets.py gera
assets e config, preservando os callbacks dos 18 seletores, slots e tooltips.
Não escrever rótulos/valores de perfil no fundo: são widgets nativos do jogo.

implemented/hud-fu-0.1.3.png é uma revisão offline dos assets reais; sua fonte
HTML está ao lado e pode ser regenerada com tools/preview_ui.py. A tipografia
do navegador é aproximada: o jogo usa a fonte da instalação do jogador.
Essa imagem não é uma captura no OpenStarbound.
