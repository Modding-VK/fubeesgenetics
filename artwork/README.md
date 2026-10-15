# Arte recuperada, provisória

machine-recovered.png e icon-recovered.png são cópias byte a byte dos PNGs do
ZIP MVP reenviado. Não são o modelo final aprovado posteriormente pelo usuário,
que não foi recuperado. Não foram redesenhados ou recoloridos nesta reconstrução.

`tools/build_assets.py` copia esses arquivos sem reescala/quantização e usa
interface-layout.json para regenerar a config corrigida. A fonte desta GUI
mantém os assets originais do ZIP e adiciona ajuda desenhada em canvas.
Aparência e legibilidade dependem de teste no engine; mockup GUI ainda precisa
ser aprovado. Recuperar o PNG final permitirá integração exata, sem nova geração.
