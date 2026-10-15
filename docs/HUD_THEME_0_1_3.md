# Interface FU — 0.1.3-dev

O usuário aprovou a direção visual da prévia e autorizou a implantação.
A versão anterior 0.1.2-dev teve funcionamento e integração ITD confirmados
pelo usuário. Esta entrega troca a aparência da interface de contêiner.

## Tema implementado

- Painel azul-marinho, linhas discretas, moldura metálica com cantos recortados,
  circuitos nas margens e detalhes amarelos. Cabeçalho com ícone de DNA.
- Novo visual para Reset, fechar, seletores e fundos dos três slots, incluindo
  imagens hover/pressed/checked próprias.
- 388×332 pixels nativos. header/body/footer: 388×34, 388×286 e 388×12.
  DNA 20×20; slots 24×24; radios 18×18; Reset 100×20; fechar 12×12.
- Texto de perfil, valores e rótulos continuam widgets do engine. Ajustes de
  cor, posição do título/perfil e margem inferior mantêm leitura na moldura.

Referência: Bee Station do FU, revisão
17868d86c9bb7bc00f92038fb78b48cebd1b41b8, especialmente
interface/windowconfig/beestation.config e seus arquivos de fundo. Os assets
implementados são desenhados por código na resolução nativa; não redistribuem
os PNGs FU nem reduzem o mockup inteiro para incorporá-lo ao jogo.

## Verificações

- 91 grupos passaram: Adapter 22, máquina 40, interface 20, assets 9. Os checks
  estáticos incluem tamanhos nativos e referências aos novos arquivos.
- Comparação com 0.1.2: todos os scripts Lua de produção, objeto, receita e
  patch de unlock são idênticos. Dados dos 18 seletores, helpRegions/helpTexts,
  posição/tamanho dos grids e offsets ITD 1/0/2 continuam idênticos.
- tools/build_assets.py reproduz os novos PNGs byte a byte. Não requer Pillow
  ou um gerador de imagens externo. tools/ui_theme.py usa a biblioteca padrão.
- Revisão offline com PNGs reais encontrou os 18 radios e nenhum rótulo fora
  da moldura. Tipografia de navegador é aproximada, não prova a renderização
  na fonte/escala da instalação do usuário.
- O PAK nativo foi desempacotado e os 27 arquivos foram comparados com a fonte,
  com equivalência JSON no metadata e bytes idênticos nos assets.

Revisão visual offline: [PNG](../artwork/implemented/hud-fu-0.1.3.png).
Prévia interativa local: baixar/abrir artwork/implemented/hud-fu-0.1.3.html.
Seu perfil e modos são exemplos ilustrativos, sem conexão com o jogo.

## Instalação e reteste

Feche completamente o jogo e substitua o PAK anterior pela 0.1.3-dev na mesma
pasta de mods carregada. Não mantenha duas versões carregáveis do addon. Abra
a máquina existente: não é necessário quebrá-la ou usar Reset. Confira perfil
e modos já salvos, clique nos seletores, teste hover e tooltips, mova itens nos
três slots e repita o fluxo ITD usado anteriormente. Slots, lógica e inventário
permanecem os mesmos. O tema novo ainda requer confirmação visual no jogo.

O sprite da máquina no mundo não foi alterado. Arte final antiga da máquina e
anexo integral v1.2 continuam ausentes da recuperação; esta entrega não os
reconstitui nem afirma aprovação de release/publicação Steam.
