# Bee Abusive Industry — identidade e prontidão

## Identidade solicitada

Nome público e título Workshop: [oSB][FU] Bee Abusive Industry. Autor exibido:
Goblin Man. O nome segue a correção registrada no planejamento e no AGENTS.
name=FUBeesGenetics, IDs, namespaces, receitas e scripts são preservados.
Arquivos novos usam bee-abusive-industry-<versão>.pak; não instalar junto ao PAK
antigo, pois ambos contêm o mesmo addon. Nenhum perfil precisa de reset.

No OpenStarbound 0.1.14, StarModsMenu.cpp lê friendlyName, author, version, icon
 e link do metadata. author é texto: não autentica, não consulta nem vincula um
perfil Steam. O proprietário da Workshop é a conta que efetuar o upload.

## Ícone nativo

O default da lista mede 15×14; o novo ícone é quadrado 14×14, sem ultrapassar a
altura da linha. A textura é bees/bees/cybernetic.png:queen do FU fixado em
17868d86c9bb7bc00f92038fb78b48cebd1b41b8, com frame 28×28. O recorte (4,6)-(20,22)
isola a Queen; scalenearest=0.75 produz 12×12 e a composição laranja deixa
1 pixel de margem. As operações crop/border são suportadas no engine auditado.
A textura original é lida do FU instalado, sem redistribuição dentro do addon.
Créditos e licença CC BY 4.0 estão no credits.txt distribuído.

A prévia reproduz as operações nas coordenadas nativas do engine, inclusive o
arredondamento de scaleNearest e o eixo vertical. Não executa o cliente do jogo.
A tipografia do cartão é aproximada. O ícone da lista, a imagem Workshop e os
ícones dos objetos são recursos diferentes.

## Resultado da revisão

| Item | Resultado |
| --- | --- |
| Funcionalidade anterior | Mantenedor confirmou todas as alterações validadas |
| Nome/autor/descrição/homepage | Corrigidos no metadata |
| Compatibilidade de IDs/saves e scripts | Preservada |
| Ícone e referência FU | Origem e diretivas conferidas; checagem visual nova no jogo pendente |
| Testes básicos | 135 grupos; referências fixadas por hash |
| IC opcional | 13 casos não repetidos neste ambiente; registros anteriores preservados |
| PAK e Workshop contents.pak | SBAsset6, round-trip de 53 arquivos e cópias idênticas |
| Preview e descrição da Workshop | Preparados, separados do ícone nativo |
| PR #5 | Candidata estável em revisão; main ainda não atualizada |
| Tag/release GitHub | Ainda não criadas |
| Item Steam, propriedade e dependência na página | Configurar/publicar na conta Steam do mantenedor |

Portanto, não declarar publicação oficial 100% concluída: falta conferir a nova
apresentação no jogo e concluir as operações de promoção/publicação. Não há
necessidade de refazer os testes funcionais já confirmados apenas por trocar
nome, autor e apresentação. Novas falhas concretas exigem diagnóstico próprio.

## Publicação

O PR existente contém a candidata estável 0.2.18. A dev de identidade usa
0.2.19-dev; a candidata recebe a mesma apresentação mantendo sua versão estável
não publicada. Downloads anteriores continuam disponíveis por SHA.

Depois de aprovar a candidata, autorizar merge em main e a tag anotada v0.2.18.
Publicação GitHub e upload Steam são ações separadas. Usar o título definido,
artwork/branding/workshop-preview.png e artwork/workshop/description.bbcode.txt.
Adicionar FU (item 729480149) como obrigatório na página e declarar OpenStarbound.
IC 2.11 é opcional e não deve virar requisito obrigatório. O uploader pode gerar
steamContentId/link: conservar o mesmo ID nas atualizações, sem inventar valores.

## Fontes

- OpenStarbound cd2d804f6feaa4c588df822f01eb5504ebd4ba55:
  source/frontend/StarModsMenu.cpp, source/core/StarImageProcessing.cpp e StarImageScaling.cpp.
- Vanilla mirror 3b370d25c27923155badb38c414a664e1ee2abfc:
  assets/packed/interface/modsmenu/modsmenu.config e modicon.png.
- FU fixado: cybernetic_queen.item, cybernetic.png, default.frames e LICENSE.txt.
