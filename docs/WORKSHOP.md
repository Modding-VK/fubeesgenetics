# Distribuição padrão PAK e Steam Workshop

O usuário definiu publicação Steam Workshop, instalação padrão do Starbound e
carregamento desses mods pelo OpenStarbound. Este é o fluxo adotado pelo projeto.
O addon usa PAK padrão Starbound 1.4.4 (SBAsset6); não exige instalador próprio.
Seu runtime continua sendo OpenStarbound com FU, por causa da interface scriptável.

O nome do PAK manual inclui automaticamente a versão do _metadata, no formato
`fubeesgenetics-mvp-<versão>.pak`. Exemplo atual: 0.1.5-dev. O arquivo instalado
pela Workshop mantém o nome padrão contents.pak.

## Arquivos entregues

| Arquivo | Finalidade |
| --- | --- |
| fubeesgenetics-mvp-0.1.5-dev.pak | Instalação manual em Starbound/mods |
| fubeesgenetics-workshop-content.zip | Extrair para obter contents.pak, cópia idêntica pronta para fluxo pré-empacotado |
| fubeesgenetics-mvp-mod.zip | Pasta FUBeesGenetics aberta para Mod Uploader, inspeção ou desenvolvimento |
| fubeesgenetics-mvp-source.zip | Projeto completo com ferramentas/testes/documentação |

## Instalação

Manual: copiar fubeesgenetics-mvp-0.1.5-dev.pak para Starbound/mods e iniciar pelo
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

## Publicar

**Mod Uploader:** selecionar a pasta aberta FUBeesGenetics/ do ZIP do mod ou do
projeto. O uploader já empacota os assets em contents.pak. Não selecionar uma
pasta contendo apenas contents.pak nesse uploader: ele esperaria assets abertos
e poderia criar um PAK contendo outro PAK. Esse fluxo é diferente de um publisher
que aceite conteúdo pré-empacotado.

**Conteúdo pré-empacotado:** extrair fubeesgenetics-workshop-content.zip para uma
pasta de conteúdo que terá somente contents.pak. Usar essa pasta no fluxo de
upload escolhido que envie arquivos prontos, por exemplo workshop_build_item
com VDF corretamente configurado. AppID Starbound: 211820. publishedfileid=0
somente para criar novo item; conservar o ID retornado para atualizações.
O guia oficial Valve documenta SteamCMD para testes; o Mod Uploader é o fluxo
normal do jogo. Nenhum login ou upload é executado pelas ferramentas do projeto.

Preparar preview/título/descrição e marcar FU como item requerido na página.
Declarar explicitamente OpenStarbound e a build testada; requires do metadata
refere-se a FrackinUniverse e não cria uma dependência entre itens Steam.
Preservar steamContentId/link gerados pelo uploader para atualizar o mesmo item.
Não publicar como release validada antes dos testes no jogo e da arte final.
A imagem de preview do Workshop é separada do ícone de inventário.

## Gerar novamente

Requer Python e asset_packer/asset_unpacker da instalação Starbound/OpenStarbound.
Os executáveis não são redistribuídos. Exemplo (substituir caminhos):

```sh
python3 tools/package.py --asset-packer /caminho/asset_packer --asset-unpacker /caminho/asset_unpacker
```

Windows: usar os caminhos dos executáveis .exe. O script aceita ferramentas no
PATH ou na pasta de cache local, e procura unpacker ao lado de packer quando
seu caminho não foi informado. O script gera PAK, desempacota em pasta temporária,
confere lista de arquivos, bytes dos assets e valores do metadata, e só depois
gera os pacotes de entrega. A raiz virtual é /objects, /scripts, /interface etc.,
sem uma pasta FUBeesGenetics extra dentro do PAK.

Ferramentas usadas nesta entrega: OpenStarbound v0.1.15.1 para Starbound 1.4.4,
Source ID e hashes registrados em [pak_toolchain.json](../tools/pak_toolchain.json).
Foram restaurados 27 arquivos: 26 assets byte a byte e metadata JSON equivalente.
Isso valida empacotamento e paths; não executa o mod no jogo.

## Fontes primárias

- [OpenStarbound: instalação e assinaturas Steam](https://github.com/OpenStarbound/OpenStarbound#installation).
- [Ferramentas da release estável](https://github.com/OpenStarbound/OpenStarbound/releases/tag/v0.1.15.1).
- [Formato PackedAssetSource](https://github.com/OpenStarbound/OpenStarbound/blob/v0.1.15.1/source/base/StarPackedAssetSource.cpp).
- [Mod Uploader: contents.pak e metadata](https://github.com/OpenStarbound/OpenStarbound/blob/v0.1.15.1/source/mod_uploader/StarModUploader.cpp).
- [Valve: Workshop e VDF](https://partner.steamgames.com/doc/features/workshop/implementation).
