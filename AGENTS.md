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
- Antes de publicar uma tag de release, conferir que não existe, que corresponde
  ao metadata e ao commit aprovado da `main`, e registrar o hash do PAK.
- Nunca usar os commits locais sintéticos da recuperação como ancestrais remotos.
  Basear commits publicados no HEAD remoto verificado e atualizar refs com lease.
- Consultar `docs/VERSIONING.md` para a convenção adotada. Mudanças nessas regras
  exigem nova instrução do usuário, não inferência a partir de tarefas rotineiras.

# Direção futura do projeto

- Nome público planejado: Abusive Bee Industry. Título Workshop planejado:
  [oSB][FU] Abusive Bee Industry, identificando OpenStarbound e Frackin Universe.
- Essa mudança foi informada como futura; não renomear o pacote, metadata ou
  IDs internos automaticamente a partir de uma tarefa de manutenção.
- Recurso futuro: máquina que troca abelhas por recursos, com referências no
  Bee Refuge do FU e na mecânica de Terramart Shipments 3.5. Consultar ROADMAP.
- A referência ao Terramart não estabelece, por si só, dependência técnica.
