# Bee Exchange 0.2.12-dev

O usuário relatou placa e display espelhados à esquerda depois da 0.2.11.
Identificada a seleção de atlas feita somente no init. A reprodução local mostrou
que uma mudança de direção posterior (ou perda da tag facingSuffix) deixava o
atlas direito ativo e o flip do engine invertia seus textos/símbolos.
Não houve reprodução dentro do jogo nem log novo para confirmar o gatilho exato
da ocorrência relatada. Os testes cobrem os estados que produzem o mesmo resultado.

syncFacing() agora roda no init e no início de cada update, antes de qualquer
retorno por intervalo, trava do IC, falta de espaço ou chave de liga/desliga.
Isso reaplica o atlas correto conforme object.direction(), inclusive quando a
tag é sobrescrita sem mudança de direção. Sprites PNG conservados byte a byte;
sem alterar arte, inventário, I/O, inspeções ou integração IC da versão anterior.

E39 falhou antes da correção e passou depois: direção após init, perda da tag e
volta à direita. O teste adicional com IC real verifica direção atualizada durante
a trava, restauração de conteúdo e recuperação após reset de tag.
145 grupos locais passaram (134 básicos + 11 com Lua real do IC e bindings
simulados). PAK nativo conferido por pack/unpack dos 51 arquivos.
Validação do resultado dentro do jogo pendente.

Fechar o jogo, substituir o PAK anterior e abrir novamente. Não precisa quebrar
nem recriar a máquina existente para carregar a lógica atualizada.
