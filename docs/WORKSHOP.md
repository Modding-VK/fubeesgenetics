# Distribuição padrão PAK e Steam Workshop

O usuário definiu publicação Steam Workshop, instalação padrão do Starbound e
carregamento desses mods pelo OpenStarbound. Este é o fluxo adotado pelo projeto.
O addon usa PAK padrão Starbound 1.4.4 (SBAsset6); não exige instalador próprio.
Seu runtime continua sendo OpenStarbound com FU, por causa da interface scriptável.

O nome do PAK manual inclui automaticamente a versão do _metadata, no formato
`bee-abusive-industry-<versão>.pak`. A release estável atual é 0.2.19. O arquivo instalado
pela Workshop mantém o nome padrão contents.pak.

## Arquivos entregues

| Arquivo | Finalidade |
| --- | --- |
| bee-abusive-industry-0.2.19.pak | Instalação manual em Starbound/mods |
| bee-abusive-industry-workshop-content.zip | Extrair para obter contents.pak, cópia idêntica pronta para fluxo pré-empacotado |
| bee-abusive-industry-mod.zip | Pasta FUBeesGenetics aberta para Mod Uploader, inspeção ou desenvolvimento |
| bee-abusive-industry-source.zip | Projeto completo com ferramentas/testes/documentação |

## Instalação

Manual: copiar bee-abusive-industry-0.2.19.pak para Starbound/mods e iniciar pelo
OpenStarbound configurado para carregar essa instalação, com FU disponível.
Não instalar junto uma pasta FUBeesGenetics antiga ou cópia Workshop do addon.

Workshop: a Steam baixa o item em
`steamapps/workshop/content/211820/<id-do-item>/contents.pak` da biblioteca
correspondente. OpenStarbound carrega as assinaturas com Steam em execução.
A instalação por assinatura não precisa de cópia manual para Starbound/mods.
Se OpenStarbound for uma instalação separada com outras fontes configuradas,
confirmar no starbound.log quais diretórios e itens foram carregados.

### Addon local com FU pela Workshop no OpenStarbound 0.1.14

A verificação de dependências dos mods locais ocorre antes da descoberta UGC.
Se FU está somente na Workshop, disponibilize sua pasta de item específica já
na primeira carga, preservando os demais campos de win/sbinit.config. Exemplo
para a biblioteca informada pelo usuário:

```json
"assetDirectories": [
  "../assets/",
  "../mods/",
  "M:/SteamLibrary/steamapps/workshop/content/211820/729480149/",
  "M:/SteamLibrary/steamapps/common/Starbound/mods/"
]
```

Adapte a unidade à instalação. Não use apenas a raiz 211820: o scanner não
percorre recursivamente cada contents.pak. Não remova requires para contornar
a dependência. Quando ambos estiverem na Workshop, serão descobertos juntos.

## Identidade e material de publicação

Título: **[oSB][FU] Bee Abusive Industry**. Autor exibido: **Goblin Man**.
O campo author do _metadata muda o texto no OpenStarbound; não consulta nem
vincula o perfil Steam. A conta logada no uploader será a proprietária do item.

Ícone da lista: metadata.icon referencia a Cybernetic Queen do FU e usa diretivas
nativas para fundo laranja. Não é a imagem da Workshop nem o ícone dos itens.
Imagem de apresentação: artwork/branding/workshop-preview.png (512×512).
Imagem adicional da galeria: artwork/workshop/hybrid-queens-gallery-1920x1080.png
(1920×1080, fundo branco, 144 rainhas híbridas distintas). Gerar novamente com
`python3 tools/build_workshop_queens_gallery.py`.
Texto pronto para a página: artwork/workshop/description.bbcode.txt.
Definição de título/dependência: artwork/workshop/publication.json.

## Item Workshop publicado

O item oficial do mod é [Bee Abusive Industry](https://steamcommunity.com/sharedfiles/filedetails/?id=3822748368), com `publishedfileid` `3822748368`. Para atualizar esse item, use a conta Steam proprietária e selecione o item existente no Mod Uploader. Não use `publishedfileid=0`, pois isso cria um item novo.

## Publicar

**Mod Uploader:** selecionar a pasta aberta FUBeesGenetics/ do ZIP do mod ou do
projeto. O uploader já empacota os assets em contents.pak. Não selecionar uma
pasta contendo apenas contents.pak nesse uploader: ele esperaria assets abertos
e poderia criar um PAK contendo outro PAK. Esse fluxo é diferente de um publisher
que aceite conteúdo pré-empacotado.

**Conteúdo pré-empacotado:** extrair bee-abusive-industry-workshop-content.zip para uma
pasta de conteúdo que terá somente contents.pak. Usar essa pasta no fluxo de
upload escolhido que envie arquivos prontos, por exemplo workshop_build_item
com VDF corretamente configurado. AppID Starbound: 211820. publishedfileid=0
somente para criar novo item; conservar o ID retornado para atualizações.
O guia oficial Valve documenta SteamCMD para testes; o Mod Uploader é o fluxo
normal do jogo. Nenhum login ou upload é executado pelas ferramentas do projeto.

Preparar preview/título/descrição e marcar FU como item requerido na página.
Declarar explicitamente OpenStarbound e a build testada; requires do metadata
refere-se a FrackinUniverse e não cria uma dependência entre itens Steam.
Preservar o `steamContentId`/link e o ID `3822748368` gerados pelo uploader para atualizar o mesmo item.
A release 0.2.19 foi validada ingame pelo mantenedor; o item Workshop oficial já está publicado no ID `3822748368`. A imagem de preview do Workshop é separada do ícone de inventário.

## Gerar novamente

Somente a Action **Build development PAK** gera novos arquivos `.pak`. Ela
é iniciada somente pelo mantenedor em GitHub → Actions → Build development PAK
→ Run workflow, selecionando `dev`. Pushes de código ou assets não a iniciam.
O resultado fica no artefato da execução por 90 dias: PAK com a versão do
`_metadata`, ZIP com `contents.pak` para Workshop e `SHA256SUMS`. O GitHub baixa
esse artefato como ZIP; extraia o PAK antes de instalar. A Action usa as
ferramentas OpenStarbound fixadas em `tools/pak_toolchain.json`, confere seus
hashes, desempacota o PAK para conferir os arquivos e não publica release,
Steam Workshop ou commits. Os pacotes já versionados em `dist/` são históricos.
Para obter um novo pacote, usar o artefato da execução correspondente no GitHub.
O workflow gera o PAK, desempacota em pasta temporária e confere lista de
arquivos, bytes dos assets e valores do metadata. A raiz virtual é /objects,
/scripts, /interface etc., sem uma pasta FUBeesGenetics extra dentro do PAK.

Ferramentas usadas nesta entrega: OpenStarbound v0.1.15.1 para Starbound 1.4.4,
Source ID e hashes registrados em [pak_toolchain.json](../tools/pak_toolchain.json).
Foram restaurados 53 arquivos: 52 assets byte a byte e metadata JSON equivalente.
Isso valida empacotamento e paths; não executa o mod no jogo.

## Fontes primárias

- [OpenStarbound: instalação e assinaturas Steam](https://github.com/OpenStarbound/OpenStarbound#installation).
- [Ferramentas da release estável](https://github.com/OpenStarbound/OpenStarbound/releases/tag/v0.1.15.1).
- [Formato PackedAssetSource](https://github.com/OpenStarbound/OpenStarbound/blob/v0.1.15.1/source/base/StarPackedAssetSource.cpp).
- [Mod Uploader: contents.pak e metadata](https://github.com/OpenStarbound/OpenStarbound/blob/v0.1.15.1/source/mod_uploader/StarModUploader.cpp).
- [Valve: Workshop e VDF](https://partner.steamgames.com/doc/features/workshop/implementation).
