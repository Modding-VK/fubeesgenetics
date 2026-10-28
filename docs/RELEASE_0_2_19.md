# Bee Abusive Industry — release 0.2.19

O mantenedor confirmou que a build `0.2.19-dev` foi validada no jogo e
autorizou sua promoção para a versão estável `0.2.19`. O commit foi publicado
em `main` e identificado pela tag anotada `v0.2.19`.

## Conteúdo

- Nome público `[oSB][FU] Bee Abusive Industry`, autor exibido Goblin Man,
  homepage do projeto e ícone Cybernetic Queen do FU em fundo laranja.
- Funcionalidade e compatibilidade da build validada preservadas: IDs,
  namespaces, receitas, scripts e inventários não mudaram na promoção.
- O PAK estável inclui 53 arquivos e foi conferido por pack/unpack com as
  ferramentas nativas. O ZIP Workshop contém o mesmo PAK como `contents.pak`.
- Preview e descrição para Workshop estão preparados nos caminhos documentados
  em `RELEASE_READINESS.md`.

O usuário validou a build no jogo. Não foram executados novamente os testes do
projeto nesta promoção. A verificação de round-trip confirma o pacote e seus
arquivos, mas não substitui a validação manual ingame.

## Pacotes e integridade

Os pacotes versionados estão em `dist/`; seus SHA-256 constam em
[`dist/SHA256SUMS`](../dist/SHA256SUMS). Instalação manual: copiar
`bee-abusive-industry-0.2.19.pak` para `Starbound/mods`, substituindo a cópia
anterior e mantendo apenas uma instalação do addon.

O conteúdo não foi enviado à Steam Workshop nesta release. A publicação do
item Workshop é uma etapa separada; siga `WORKSHOP.md` quando for publicar.
