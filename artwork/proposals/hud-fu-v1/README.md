# Proposta visual HUD FU — v1

Estado: prévia para avaliação do usuário, anterior à implementação.
A imagem é um mockup gerado, não uma captura do jogo nem um spritesheet pronto
para instalar. A resolução da prévia não define a resolução dos assets nativos.
Nenhum arquivo em FUBeesGenetics/ ou PAK foi alterado nesta proposta.

Referência examinada: Bee Station de Frackin Universe, revisão
17868d86c9bb7bc00f92038fb78b48cebd1b41b8, arquivo
interface/windowconfig/beestation.config. Esse arquivo utiliza
interface/windowconfig/newuiheader.png, interface/crafting/newbody.png e
interface/windowconfig/newuifooter.png. Os PNGs de referência foram examinados
no cache; não são redistribuídos nesta pasta. O ícone de DNA de referência foi
interface/crafting/fuhelixon.png. A composição proposta usa uma janela única.

Direção visual: painel azul-marinho com linhas horizontais sutis, moldura
metálica cinza com cantos recortados, circuitos discretos nas margens e detalhes
amarelos. Tipografia clara e seleção ciano. Approved verde, Input ciano e
Rejected coral. Manter seis traits, três modos exclusivos, Reset, tooltips e
três slots nativos na ordem Approved/Input/Rejected, offsets ITD 1/0/2.

Os valores, perfil e modos mistos da imagem são exemplos ilustrativos.
Para implementação, reconstruir os elementos na resolução nativa da interface,
usando texto/widgets reais em vez de incorporar rótulos ao fundo. Conferir
alinhamento, legibilidade das linhas de fundo, tamanho do cabeçalho, área útil,
hover/pressed/checked dos controles e alinhamento dos tooltips. Não reduzir o
mockup inteiro para obter a interface; separar fundo/moldura/ícones de controles.
Manter os callbacks corrigidos na 0.1.2 e a integração ITD validada pelo usuário.

O usuário confirmou na conversa que a versão 0.1.2 funcionou perfeitamente e
que o ITD está 100% funcional em seu teste. Isso registra a confirmação recebida,
sem afirmar execução de cenários de save/reload, multiplayer ou falhas que não
foram descritos. A modificação visual ainda não foi testada no engine.
