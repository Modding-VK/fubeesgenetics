# Operação de Git e entregas

Instruções explícitas do mantenedor, recebidas nesta conversa:

- `dev` é a branch de desenvolvimento. Alterações, correções, documentação e
  novos PAKs devem ser armazenados nela por padrão.
- `main` é produção. Não promover conteúdo de `dev`, criar pull requests ou
  fazer merge sem solicitação explícita do usuário para essa operação.
  Pedidos de implementação ou geração de PAK não autorizam PR/promoção.
- Não automatizar criação de PRs ou promoção de versões. O CI pode validar
  pushes e PRs que o usuário tenha solicitado explicitamente.
- Preservar histórico compartilhado: novos commits, sem force push, reset de
  branches remotas, rebase de histórico publicado ou substituição de tags.
- Desenvolvimento usa versão `X.Y.Z-dev` no `_metadata`; a próxima promoção
  autorizada deve usar `X.Y.Z`, com tag anotada `vX.Y.Z` no commit de produção.
  Não criar tags de release para conteúdo ainda somente em `dev`.
- O PAK de download manual deve incluir a versão do _metadata no nome:
  bee-abusive-industry-X.Y.Z-dev.pak (ou X.Y.Z em produção). Não fornecer
  um PAK manual sem versão. O conteúdo Workshop continua contents.pak.
- Antes de publicar uma tag de release, conferir que não existe, que corresponde
  ao metadata e ao commit aprovado da `main`, e registrar o hash do PAK.
- Nunca usar os commits locais sintéticos da recuperação como ancestrais remotos.
  Basear commits publicados no HEAD remoto verificado e atualizar refs com lease.
- Consultar `docs/VERSIONING.md` para a convenção adotada. Mudanças nessas regras
  exigem nova instrução do usuário, não inferência a partir de tarefas rotineiras.

# Identidade pública

- O usuário solicitou executar o rebranding: nome público Bee Abusive Industry;
  título Workshop e friendlyName: [oSB][FU] Bee Abusive Industry.
- Autor exibido no metadata: Goblin Man. É texto de apresentação, não autenticação
  Steam. O proprietário da Workshop é a conta Steam usada no upload.
- Novos PAKs manuais usam bee-abusive-industry-<metadata.version>.pak; contents.pak
  continua sendo o arquivo Workshop. Manter os pacotes/links antigos no histórico.
- Preservar name técnico FUBeesGenetics, IDs, namespaces e saves; não renomear
  o repositório automaticamente. O nome público é independente desses campos.
- Ícone da lista: Cybernetic Queen do FU em fundo laranja, por diretivas nativas;
  conservar créditos e a referência FU fixada. Não redesenhar a textura original.
- Auto Refugee já está implementada; consultar ROADMAP e RELEASE_READINESS.

# Slots da interface

- Approved/Input/Rejected usam molduras estáticas independentes, com
  mouseTransparent=true e camada inferior aos slots nativos. Não usar a
  moldura do mod como backingImage que some ao preencher o slot.
- Conservar dimensões/centralização nativas e offsets ITD 1/0/2. Consultar
  docs/HUD_SLOTS_0_1_5.md antes de alterar posições ou assets dos slots.

- Após a compactação 0.2.16, as posições atuais dos slots e o tamanho da pane
  estão em docs/HUD_COMPACT_0_2_16.md. O documento 0.1.5 explica a geometria
  nativa preservada, mas registra as coordenadas históricas anteriores.
