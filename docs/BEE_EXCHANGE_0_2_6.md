# Bee Exchange 0.2.6-dev

Correção visual da 0.2.5: a carcaça agora vem do cropshipper.png vanilla,
ready.1, preservado no cache fixado por Git blob em tools/ui_upstream.json.
Isso remove as marcas de dano inferiores e superiores próprias do sprite FU.
A placa e o vidro/haste aprovados são conservados nas mesmas coordenadas.
As hastes externas acima da placa continuam removidas.

Ambos os LEDs laterais são copiados pixel por pixel do atlas fullbright vanilla,
sem redesenho: superior em (7,38)-(11,46), inferior em (7,57)-(11,65), caixas
com limites máximos exclusivos. A camada fullbright segue ready/work e mantém
as cores nativas. Display inferior azul/seta amarela mantido.

Sem alteração de inventário, trocas, inspeções, receita, inseto ou teleporte.
Reproduzir com tools/build_beeexchange_work_assets.py. Prévia em
artwork/implemented/beeexchange-0.2.6.gif.

126 grupos locais passaram; integridade do novo sprite vanilla conferida com
hash Git fixado. PAK nativo validado por pack/unpack dos 42 arquivos.
Conferência dentro do jogo pendente. Substituir o PAK anterior sem duplicação.
