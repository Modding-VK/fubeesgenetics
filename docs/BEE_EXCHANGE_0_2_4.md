# Bee Exchange 0.2.4-dev

Aplica a arte e a animação aprovadas em artwork/proposals/auto-refugee-work-v1.
A caixa de vidro tem transparência parcial e haste fixa. No estado work, o inseto
Butterbee (90° horário, preto embaixo) aparece por 0,5 s e desaparece em 12 frames
de teleporte durante 0,75 s. A orientação vertical do feixe foi preservada.
Apenas o efeito usa fullbright. Som nativo teleport_up no início do teleporte.

Uma venda confirmada dispara work; vendas durante o ciclo não o reiniciam.
O animator retorna a ready automaticamente. O timer Lua libera outro ciclo após
1,25 s. Economia, 16 slots, crafting e desbloqueio permanecem iguais.

Instalação: substituir o PAK anterior pelo novo, sem manter duas cópias do mod.
ID: fubeesgenetics_beeexchange. Não precisa refazer a máquina existente.

Validação: 126 grupos locais (bindings do jogo simulados), integridade dos
assets e round-trip nativo dos 40 arquivos do PAK. Sem validação dentro do jogo.
Referências e autoria dos assets nativos registradas na proposta e ui_upstream.json.
