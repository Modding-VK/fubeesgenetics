# Operação do repositório no GitHub

Revisão de 2026-10-17: conferidas as instruções do mantenedor no chat
**Bee Analyzer**, também aplicáveis ao chat Automatic Seller. Elas coincidem
com AGENTS.md e VERSIONING.md: dev para desenvolvimento; main para produção;
PR e promoção somente mediante pedido explícito. Atualizar o repositório ou
gerar um PAK não autoriza, por si só, promover para main.

## Estado atual

- Repositório: https://github.com/Modding-VK/fubeesgenetics.
- Código e PAK atuais: **0.2.14-dev**, commit de entrega
  `175aa42bf7c79ce729179b383d6811b0f7c02452`, armazenados em dev.
- Main preservada em `54afbe59309ca6481fc4f835f07f92706e5a14b9`.
- Não há nova release, tag estável, PR ou publicação Steam nesta atualização.
- A revisão documental posterior à entrega não muda o metadata nem os bytes do PAK.
- Validação da entrega: 148 grupos locais e pack/unpack nativo de 52 arquivos.
  O resultado do CI remoto não foi afirmado nesta revisão.

## Procedimento vigente

1. Conferir AGENTS.md, VERSIONING.md, estado local e HEAD remoto antes de escrever.
   Para clones limitados à main, buscar a ref dev explicitamente:
   `git fetch origin refs/heads/dev:refs/remotes/origin/dev`.
2. Trabalhar em dev a partir do histórico remoto, preservando alterações locais
   e trabalho de outros chats. Se o remoto avançar, integrar com o histórico
   existente; não usar reset/force push nem rebase de commits publicados.
3. Validar as alterações pertinentes. Para uma nova entrega, conferir versão
   `-dev`, gerar o PAK versionado com pack/unpack nativo e atualizar SHA256SUMS.
   Para documentação, manter o pacote existente e conferir links/versões/hashes.
4. Criar commit e push normal para dev. Preservar pacotes anteriores e fornecer
   downloads por SHA imutável. Não criar PR ou atualizar main automaticamente.
5. Confirmar a ref remota e informar o que foi verificado localmente, no CI e
   dentro do jogo, distinguindo esses resultados.

A convenção completa está em [VERSIONING](VERSIONING.md). O nome público futuro
não altera automaticamente metadata, IDs ou nomes de pacotes atuais.

## Registros históricos

Os registros abaixo explicam a recuperação e os problemas de autenticação
anteriores. Não são procedimentos para refazer o checkout atual.

# Histórico anterior de armazenamento e publicação

**Fluxo vigente:** desenvolvimento em `dev`, produção em `main`. PRs e promoção
somente com solicitação explícita do usuário. As instruções e tentativas antigas
abaixo são histórico; siga [VERSIONING](VERSIONING.md) e o AGENTS.md atual.

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
