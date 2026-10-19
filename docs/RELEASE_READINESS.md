# Bee Abusive Industry 0.2.19 — prontidão da release

## Estado

O mantenedor confirmou que a build `0.2.19-dev` foi validada no jogo e
autorizou promovê-la para `0.2.19`. A metadata estável preserva o nome técnico,
IDs, namespaces, receitas, scripts e saves. Não foi solicitado nem realizado
upload à Steam Workshop.

| Item | Estado |
| --- | --- |
| Validação no jogo | Confirmada pelo mantenedor para a build `0.2.19-dev` |
| Nome, autor, descrição e homepage | Aplicados; autor exibido: Goblin Man |
| Compatibilidade de IDs/saves e scripts | Preservada em relação à build validada |
| Ícone nativo | Cybernetic Queen do FU com diretivas nativas; fonte e créditos registrados |
| Preview e descrição Workshop | Preparados em `artwork/branding/workshop-preview.png` e `artwork/workshop/description.bbcode.txt` |
| PAK estável e conteúdo `contents.pak` | Gerados com ferramentas nativas e conferidos por round-trip |
| Git | Commit de release em `main` e tag anotada `v0.2.19` |
| Steam Workshop | Não enviado; requer ação separada no Mod Uploader |

A validação no jogo é a confirmação do mantenedor. O round-trip confere o
formato e os arquivos empacotados; não executa o mod no jogo. A suíte de testes
do projeto não foi executada como parte desta promoção.

## Identidade pública

Nome público e título Workshop: **[oSB][FU] Bee Abusive Industry**. O campo
`author` de `_metadata` é texto de apresentação e não autentica nem vincula a
conta Steam. O dono do item será a conta logada no uploader.

O ícone da lista usa `bees/bees/cybernetic.png:queen` do Frackin Universe fixado
em `17868d86c9bb7bc00f92038fb78b48cebd1b41b8`, com recorte e fundo laranja.
A textura fonte não é redistribuída. Créditos e licença estão em
`FUBeesGenetics/credits.txt`. Preview Workshop e ícones dos objetos são
recursos separados.

## Materiais de publicação

- Preview: `artwork/branding/workshop-preview.png` (512×512).
- Descrição BBCode: `artwork/workshop/description.bbcode.txt`.
- Título e dependências declaradas: `artwork/workshop/publication.json`.
- Item requerido na página Workshop: Frackin Universe, ID `729480149`.
- Runtime declarado: OpenStarbound; Improved Containers é opcional.

O campo `requires` do metadata declara Frackin Universe para carregamento do
mod, mas não configura sozinho a dependência entre itens Workshop.
