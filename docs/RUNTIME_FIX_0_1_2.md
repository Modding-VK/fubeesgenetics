# Correção 0.1.2-dev — seletores de comparação

O log do teste da 0.1.1-dev confirma OpenStarbound 0.1.14 e FU 6.5.8, sem o erro
anterior de inicialização do Adapter. A captura fornecida pelo usuário mostra
Family/Subspecies/referências preenchidas e uma rejeição por critérios genéticos.
O usuário relata que selecionar <= ou ignore retorna rapidamente a >=.
O log pessoal não é incorporado ao repositório.

## Causa e mudança

WidgetParser adiciona cada botão do radioGroup com nome igual ao ID (0/1/2).
ButtonGroup::wasChecked passa o botão filho ao callback, e ContainerPane envia
widget.name e widget.data ao Lua. A GUI esperava o nome do grupo inteiro: a
linha não era encontrada, setMode não era enviado, e a próxima consulta ao
servidor redesenhava o modo que continuava armazenado, normalmente >=.

Os 18 botões recebem data.modeGroup com o nome de seu grupo. modeChanged usa
esse dado para identificar uma das seis linhas permitidas e consulta a opção
selecionada no grupo correto. As respostas do controlador continuam autoritativas,
sem contador de revisão e com uma única mutação pendente por pane. A seleção
anterior pode aparecer brevemente enquanto a resposta chega; após confirmação,
a opção escolhida deve permanecer. Não é necessário resetar o perfil existente.

Fontes examinadas na revisão instalada cd2d804f6feaa4c588df822f01eb5504ebd4ba55:
[WidgetParser](https://github.com/OpenStarbound/OpenStarbound/blob/cd2d804f6feaa4c588df822f01eb5504ebd4ba55/source/windowing/StarWidgetParsing.cpp),
[ButtonGroup](https://github.com/OpenStarbound/OpenStarbound/blob/cd2d804f6feaa4c588df822f01eb5504ebd4ba55/source/windowing/StarButtonGroup.cpp),
[ContainerPane](https://github.com/OpenStarbound/OpenStarbound/blob/cd2d804f6feaa4c588df822f01eb5504ebd4ba55/source/frontend/StarContainerInterface.cpp).

## Verificação

O harness de widgets agora reproduz o callback com nome do filho e seus dados,
incluindo callbacks de alterações programáticas. Antes da correção, U18 falhou
com Numeric child callback did not send a command for baseProduction. Depois:
91 grupos passaram (Adapter 22, máquina 40, interface 20, assets 9).
U18 cobre as seis linhas e as três opções, isolamento entre linhas e polling;
U19 rejeita dados sem grupo válido; U20 cobre resposta antiga descartada e
reabertura com o estado confirmado fornecido pelo controlador simulado.
Os bindings continuam simulados: isso não comprova persistência de mundo ou
execução real do engine. O teste na instalação do usuário segue pendente.

## Reteste no jogo

Feche o jogo e substitua a 0.1.1-dev pela 0.1.2-dev, deixando uma única cópia do
addon carregável. Abra a máquina existente e altere um seletor de cada vez,
aguardando a confirmação. Teste <=, ignore e >= nas seis linhas, aguarde mais
de um segundo e feche/reabra a interface. Confirme também após save/reload.
As referências não devem mudar apenas por alternar modos; Reset não é necessário.
Com saídas livres, use uma Queen analisada da mesma linhagem para verificar a
comparação. Qualquer saída ocupada pausa o processamento, mas não a configuração.
