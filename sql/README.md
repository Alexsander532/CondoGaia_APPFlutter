# 🏢 Sistema de Configuração Dinâmica de Blocos e Unidades

## 📋 Visão Geral

Este sistema permite a configuração dinâmica de blocos e unidades em condomínios, com funcionalidade de importação via Excel. A estrutura foi projetada para ser flexível, escalável e fácil de manter.

## 🗂️ Estrutura do Banco de Dados

### 📊 Tabelas Principais

| Tabela | Propósito | Relacionamentos |
|--------|-----------|----------------|
| `configuracao_condominio` | Configurações de estrutura | 1:N com blocos |
| `blocos` | Definição dos blocos | 1:N com unidades |
| `unidades` | Unidades individuais | N:1 com proprietários, inquilinos, imobiliárias |
| `proprietarios` | Dados dos proprietários | 1:N com unidades |
| `inquilinos` | Dados dos locatários | 1:N com unidades |
| `imobiliarias` | Dados das imobiliárias | 1:N com unidades |
| `templates_excel` | Controle de templates | N:1 com configurações |

### 🔗 Relacionamentos

```
condominios (existente)
    ↓ 1:N
configuracao_condominio
    ↓ 1:N
blocos
    ↓ 1:N
unidades
    ↓ N:1
proprietarios, inquilinos, imobiliarias
```

## 📁 Arquivos SQL

### Ordem de Execução

1. **`00_migration_master.sql`** - Script principal que executa todas as migrações
2. **`01_create_configuracao_condominio.sql`** - Configurações de estrutura
3. **`02_create_blocos.sql`** - Definição de blocos
4. **`03_create_unidades.sql`** - Unidades reformuladas
5. **`04_create_proprietarios.sql`** - Dados de proprietários
6. **`05_create_inquilinos.sql`** - Dados de inquilinos
7. **`06_create_imobiliarias.sql`** - Dados de imobiliárias
8. **`07_create_templates_excel.sql`** - Controle de templates
9. **`08_create_views_indices.sql`** - Views e índices de otimização

## 🚀 Como Executar

### Opção 1: Execução Automática (Recomendada)
```sql
-- Execute apenas este arquivo
\i 00_migration_master.sql
```

### Opção 2: Execução Manual
```sql
-- Execute na ordem:
\i 01_create_configuracao_condominio.sql
\i 02_create_blocos.sql
\i 03_create_unidades.sql
\i 04_create_proprietarios.sql
\i 05_create_inquilinos.sql
\i 06_create_imobiliarias.sql
\i 07_create_templates_excel.sql
\i 08_create_views_indices.sql
```

## 🔍 Verificação do Sistema

### Verificar Integridade
```sql
SELECT * FROM verificar_integridade_sistema();
```

### Ver Estatísticas
```sql
SELECT * FROM view_dashboard_estatisticas;
```

### Inserir Dados de Exemplo
```sql
SELECT inserir_dados_exemplo('seu-condominio-id-aqui');
```

## 📊 Views Principais

### `view_estrutura_condominio`
Visão geral da estrutura e estatísticas do condomínio.

### `view_blocos_resumo`
Resumo de blocos com estatísticas de unidades.

### `view_unidades_completas`
Dados completos das unidades com todos os relacionamentos.

### `view_dashboard_estatisticas`
Dashboard completo com todas as estatísticas consolidadas.

## 🔧 Funções Úteis

### Configuração e Estrutura
- `gerar_blocos_automaticamente()` - Gera blocos baseado na configuração
- `gerar_unidades_bloco()` - Gera unidades para um bloco específico
- `atualizar_estatisticas_condominio()` - Calcula estatísticas atualizadas

### Busca e Consulta
- `buscar_proprietarios()` - Busca proprietários por termo
- `buscar_inquilinos()` - Busca inquilinos por termo
- `buscar_imobiliarias()` - Busca imobiliárias por termo
- `buscar_templates_excel()` - Busca templates disponíveis

### Templates Excel
- `marcar_templates_obsoletos()` - Marca templates como obsoletos
- `registrar_download_template()` - Registra download de template
- `registrar_importacao_template()` - Registra resultado de importação

### Contratos e Financeiro
- `buscar_contratos_vencendo()` - Contratos que vencem em X dias
- `buscar_imobiliarias_por_servico()` - Imobiliárias por tipo de serviço

## 🛡️ Segurança e Validação

### Validações Automáticas
- **CPF/CNPJ**: Validação com algoritmo oficial
- **Email**: Validação de formato
- **Telefones**: Formatação automática
- **Datas**: Validação de consistência
- **Valores**: Validação de ranges

### Triggers Automáticos
- **updated_at**: Atualização automática em todas as tabelas
- **Formatação**: CPF, CNPJ, telefones formatados automaticamente
- **Status**: Atualização automática de status baseado em regras
- **Identificação**: Geração automática de identificadores únicos

## 📈 Performance

### Índices Otimizados
- Índices compostos para consultas frequentes
- Índices de texto para busca full-text
- Índices parciais para dados ativos
- Índices para datas e valores financeiros

### Estratégias de Otimização
- Views materializadas para consultas complexas
- Índices GIN para busca de texto
- Particionamento por condomínio (futuro)
- Cache de estatísticas

## 🔄 Migração e Manutenção

### Log de Migrações
O sistema mantém um log completo de todas as migrações executadas:
```sql
SELECT * FROM migration_log ORDER BY executed_at DESC;
```

### Limpeza Automática
- Templates expirados são marcados como obsoletos
- Função para limpeza de dados antigos
- Arquivamento de registros inativos

## 🎯 Próximos Passos

### Implementação no Flutter
1. **Models**: Criar classes Dart para cada tabela
2. **Services**: Implementar serviços de API
3. **Repositories**: Camada de acesso aos dados
4. **Controllers**: Lógica de negócio
5. **UI**: Interfaces para configuração e importação

### Funcionalidades Futuras
- **Auditoria**: Log de todas as alterações
- **Backup**: Sistema de backup automático
- **Relatórios**: Relatórios avançados em PDF
- **API**: Endpoints REST para integração
- **Mobile**: Aplicativo mobile para síndicos

## 📞 Suporte

Para dúvidas ou problemas:
1. Verifique os logs de migração
2. Execute a função de verificação de integridade
3. Consulte a documentação das funções
4. Analise os comentários no código SQL

---

**Versão**: 1.0  
**Data**: 2024  
**Compatibilidade**: PostgreSQL 12+