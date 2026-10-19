# Bee Exchange 0.2.10-dev

Ícone: madeira substituída por câmara de vidro vazia em 4×3 pixels, com face lateral
mais escura, frente ciano com alfa parcial, reflexo e haste de um pixel. Preservadas
a placa amarela #F4BB42, moldura nativa e dimensões de 16×16. Alteração limitada ao
ícone, sem efeito sobre os sprites do mundo ou o inventário.

Compatibilidade de storage: usuário confirmou Improved Containers 2.11 original,
sem Post-Load Mega-Patch. Investigação e patch preparado (não aplicado) em
artwork/proposals/storage-compat-v1. Necessário obter o contents.pak original ou
fonte para verificar a integração dos scripts do objeto com init/update/die e
recompensas pendentes. Não adicionados scripts externos nem dependência obrigatória.
O uiConfig permanece privado nesta versão para evitar migrar para uma janela IC
sem os callbacks/handlers de objeto correspondentes. Compatibilidade completa
com IC, rename e retenção de itens ao quebrar ainda não foi validada.

E37/E38 exercitam reordenação, inserção externa e take-all contra o controlador
real com bindings simulados. Não executam Improved Containers. 133 grupos locais
passaram; PAK nativo conferido por pack/unpack de 48 arquivos. Novo ícone ainda
precisa de conferência no jogo. Substituir PAK anterior sem duplicar o mod.
