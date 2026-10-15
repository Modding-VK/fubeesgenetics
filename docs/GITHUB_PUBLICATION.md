# Armazenamento e publicação no GitHub

Destino atual: https://github.com/Modding-VK/fubeesgenetics.
O repositório foi transferido para a organização Modding-VK, mantendo seu ID.
O histórico local recovered-mvp é sintético, não deve ser
forçado sobre main. O estado remoto verificado antes desta reconstrução tinha
somente README e MasterSpec original; nenhum código da entrega antiga.

O patch fubeesgenetics-mvp.patch é gerado contra a árvore original do GitHub.
Aplicar em clone atual em uma nova branch, verificar conflitos e rodar testes:

```sh
git switch -c feat/genetic-queen-filter-recovered
git apply --check /caminho/fubeesgenetics-mvp.patch
git apply /caminho/fubeesgenetics-mvp.patch
python3 tools/run_checks.py --fetch
git add .
git commit -m "Rebuild Genetic Queen Filter development MVP"
```

ZIP de fontes contém projeto completo, não .git/cache. O bundle separado
preserva o histórico reconstruído. Para retomar localmente:

```sh
git clone /caminho/fubeesgenetics-recovered.bundle fubeesgenetics
```

O conector anteriormente recusava escrita com 403. Não confundir permissões
pessoais push/admin com permissão do token/app. Nenhuma release deve ser publicada
sem os gates no jogo. O workflow CI ainda precisa executar no GitHub.
A reconstrução usa requisitos v1.2 do histórico e arte provisória do ZIP; PRs
precisam informar esses limites e os 85 grupos locais com bindings simulados.

## Tentativa de armazenamento desta reconstrução

Em 2026-10-14 (horário do usuário), a integração tentou criar a branch
`recovery/genetic-queen-filter-20261014` a partir do main remoto
`a677652b8a0685deec6d7f00f1db2f9a3b09f839`. O GitHub respondeu
`403 Resource not accessible by integration` no endpoint de criação de ref.
A branch não foi criada; nenhum código ou workflow foi enviado. A entrega
permanece nos ZIPs, patches e bundle locais, prontos para aplicação em clone.

## Publicação Steam Workshop

O formato requerido é PAK padrão. A entrega agora inclui PAK manual e uma
cópia idêntica chamada contents.pak. O fluxo Workshop e a distinção entre
pasta aberta para Mod Uploader e pasta pré-empacotada estão em
[WORKSHOP](WORKSHOP.md). GitHub e Steam são publicações independentes;
nenhum upload Steam foi efetuado nesta etapa.

## Organização Modding-VK — 2026-10-15

A integração agora reconhece a instalação do GitHub App na organização Modding-VK
para todos os repositórios. A criação da branch
`recovery/genetic-queen-filter-20261015` foi bem-sucedida, confirmando escrita.
Essa branch armazena o projeto de desenvolvimento e os arquivos de distribuição
em dist/, com histórico remoto baseado na main original. Não usa force push ou
os commits locais sintéticos como ancestrais da main. Nenhuma release Steam ou
merge em main é declarado por esse armazenamento.

Os links raw dos arquivos em dist/ e o ZIP de fontes gerado pelo próprio GitHub
fornecem uma alternativa de download fora dos links temporários do workspace.
A recusa 403 acima é um registro histórico da instalação anterior, não o estado
atual. Arte final e anexo integral v1.2 ainda não foram recuperados; testes no
jogo e validação de release continuam pendentes.
