# Auto Refugee — proposta de animação work

Prévia em escala nativa de 64×80. Não altera os assets ativos nem o PAK.

- `ready`: caixa vazia, haste descoberta.
- `work`: Butterbee sobre a haste durante 0,5 s; depois 12 frames de teleporte em 0,75 s, retornando à caixa vazia. Ciclo total: 1,25 s.
- Referência: beamout/beamaway nativos do Starbound, com silhueta azul, branco, compressão e feixe vertical. Origem registrada em references.json.
- Inseto original de 3×3 girado 90° no sentido horário (parte preta para baixo) e ampliado 2× sem suavização. A silhueta inicial acompanha o inseto; a compressão e o feixe de teleporte conservam a orientação original. O efeito fica dentro do vidro e acima da haste.
- A base aprovada permanece intacta. Como seu vidro já está achatado no PNG, a tonalidade do vidro é aplicada aos pixels do inseto/efeito, sobrepostos à base para manter sua leitura. Apenas a camada do teleporte usa fullbright no blueprint.

Abra `preview.html` para reprodução, pausa e comparação em 1×, 3× e 6×. `work-preview.gif` é a prévia compartilhável; o GIF arredonda a duração por frame para centésimos de segundo. HTML e work.animation mantêm o ciclo exato.

`work.animation`, `default.frames`, `specimen.png`, `teleport.png` e `static.png` formam um blueprint ainda não conectado ao objeto ou ao Lua de venda. A prévia não inclui áudio; o blueprint indica o som nativo de teleporte no começo do efeito.

Reproduzir: `python3 artwork/proposals/auto-refugee-work-v1/build_preview.py` na raiz do repositório, com Pillow instalado. Fonte estática: proposta auto-refugee-glass-native-v1.

Validação: dimensões, contenção, conservação de pixels fora do efeito e igualdade entre o último frame e a base verificadas pelo gerador. Reprodução e retorno ao estado parado verificados em Chromium via Playwright. Sem teste dentro do jogo. Sem alteração de versão ou PAK.
