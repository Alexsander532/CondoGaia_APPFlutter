# Changelog

Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.

## [Não Lançado] - 2025-01-17

### Adicionado
- Nova tela `ContatosChatRepresentanteScreen` para listar contatos disponíveis para chat do representante
- Funcionalidade de busca de proprietários e inquilinos do condomínio para o chat
- Cards de contato com identificação (P) para proprietário e (I) para inquilino
- Exibição de informações de unidade (bloco/número) nos cards de contato
- Campo de busca para filtrar contatos por nome
- Navegação integrada do menu Chat do representante para a tela de contatos

### Corrigido
- Erro do getter 'supabase' na tela de contatos do chat (alterado para `SupabaseService.client`)
- Parâmetros obrigatórios ausentes na navegação para `ContatosChatRepresentanteScreen`
- Imports duplicados e não utilizados no arquivo `representante_home_screen.dart`

### Técnico
- Implementação de queries Supabase para buscar proprietários e inquilinos com dados de unidade
- Combinação e ordenação de listas de contatos por nome
- Estrutura de dados padronizada para exibição de contatos