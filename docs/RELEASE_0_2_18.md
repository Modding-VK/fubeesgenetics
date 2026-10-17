# Candidata à produção — 0.2.18

O mantenedor confirmou todas as alterações validadas e prontas e solicitou
Pull Request. A candidata parte da dev 6de1050114e865e119a434698c25b4ec4ed67b13,
versão 0.2.18-dev. release/0.2.18 contém a preparação para revisão contra main;
a dev conserva seu identificador e histórico. Não foi executado merge.

## Conteúdo desde a main 0.1.3-dev

- Auto Refugee: troca automática com as receitas do Bee Refuge, 16 slots,
  Young Queens com recompensas adultas e cinco drones da mesma espécie por lote.
- Arte com placa amarela, vidro, LEDs, teleporte e texturas legíveis nos dois
  lados; chave on/off, rede FU/ITD, inspeções raciais e integração opcional IC 2.11.
- Filter compacto 304×332, valores de referência centralizados, molduras estáticas
  e itens centralizados em slots nativos, setas e nomes claros dos comparadores.
- Cabeçalho com logo centralizado, nome laranja e descrição curta; Reset Profile
  centralizado entre barras, listras na faixa metálica e tooltips contidos na pane.
- Receita do Filter soma 10 Healing Water, 5 Sulphuric Acid e 2 Unknown Gene.
- PAKs versionados, histórico de entregas e fluxo dev/main com promoção explícita.

## Verificação e pacote

- Mantenedor confirmou validação manual das alterações e pediu este PR.
- 135 grupos básicos passam com referências FU/vanilla/OpenStarbound fixadas.
- Os 13 casos IC opcionais não foram repetidos: o PAK original não está neste
  ambiente. Os registros anteriores de execução permanecem preservados.
- check_version.py --release --tag v0.2.18 passa sem criar tags.
- PAK SBAsset6 estável empacotado/extraído com ferramentas nativas: 52 arquivos,
  assets idênticos e metadata JSON equivalente. Workshop contents.pak é idêntico.
- Todos os arquivos de produção, exceto _metadata, são byte a byte iguais à dev
  validada. Scripts, IDs, inventários, receitas e sprites não mudaram nesta preparação.

Instalar fubeesgenetics-mvp-0.2.18.pak com o jogo fechado, substituindo o PAK
anterior. Usar OpenStarbound com FU e apenas uma cópia do addon. Não precisa
resetar o perfil do Filter ou reconstruir máquinas. PAKs antigos preservados.

## Integração

O PR aguarda revisão/merge autorizado. main permanece inalterada; nenhuma tag
estável, release GitHub ou publicação Steam foi criada. A tag anotada v0.2.18
fica reservada à operação posterior autorizada, no commit efetivo de produção.
As limitações históricas de recuperação do Analyzer continuam documentadas;
a confirmação do mantenedor não reconstrói anexos/arquivos indisponíveis.
