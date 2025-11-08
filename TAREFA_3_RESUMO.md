# ✅ TAREFA 3 COMPLETA: LEITOR DE ARQUIVO EXCEL & VALIDAÇÕES

## 📊 ARQUIVOS CRIADOS

### 1. **ParseadorExcel** (`lib/models/parseador_excel.dart`)
- ✅ Lê arquivos Excel (.xlsx)
- ✅ Valida se colunas obrigatórias existem
- ✅ Extrai dados linha por linha
- ✅ Pula linhas vazias automaticamente
- ✅ Retorna `List<ImportacaoRow>` pronta para validação

**Métodos principais:**
```dart
ParseadorExcel.parseExcel(bytes)           // Parse completo
ParseadorExcel.descricaoColunas            // Descrição das colunas
```

---

### 2. **ImportacaoService** (`lib/services/importacao_service.dart`)
Implementa 3 fases principais:

#### **FASE 1: Parsing & Validação**
```dart
await ImportacaoService.parsarEValidarArquivo(
  bytes,
  cpfsExistentesNoBanco: {},
  emailsExistenteNoBanco: {},
)
```
- ✅ Faz parsing do Excel
- ✅ Valida CADA linha
- ✅ Detecta duplicatas (na planilha E no banco)
- ✅ Retorna `List<ImportacaoRow>` com erros identificados

#### **FASE 2: Validações Implementadas**
```
✅ Proprietário (Obrigatório):
   - Nome completo preenchido
   - CPF válido e 11 dígitos
   - CPF não duplicado (planilha + BD)
   - Email válido
   - Email não duplicado (planilha + BD)
   - Telefone 10-11 dígitos

✅ Inquilino (Opcional):
   - Se informar nome, todos os campos obrigatórios
   - Mesmas validações do proprietário
   - CPF/Email únicos

✅ Imobiliária (Opcional):
   - Se informar nome, todos os campos obrigatórios
   - CNPJ válido e 14 dígitos
   - Email válido
   - Telefone válido

✅ Unidade (Obrigatório):
   - Número preenchido
   - Fração ideal é número positivo
```

#### **FASE 3: Mapeamento para Entidades**
```dart
final mapeado = await ImportacaoService.mapearParaEntidades(
  rows,
  condominioId: 'condo_123',
)

// Retorna Map com:
mapeado['proprietarios']      // List<ProprietarioImportacao>
mapeado['inquilinos']         // List<InquilinoImportacao>
mapeado['imobiliarias']       // List<ImobiliarioImportacao>
mapeado['blocos']             // List<BlocoImportacao>
mapeado['senhasProprietarios'] // Map<cpf, senha>
mapeado['senhasInquilinos']   // Map<cpf, senha>
```

**Comportamentos:**
- ✅ Proprietário com múltiplas unidades = 1 registro
- ✅ Inquilino sempre 1:1 com unidade
- ✅ Blocos novos criados automaticamente
- ✅ Senhas geradas com `GeradorSenha.gerarSimples()`

---

### 3. **Modelos Auxiliares** (criados anteriormente)
- `ImportacaoRow` - Dados brutos + validações
- `ImportacaoResultado` - Resultado final com estatísticas
- `ProprietarioImportacao` - Proprietário com múltiplas unidades
- `InquilinoImportacao` - Inquilino 1:1
- `ImobiliarioImportacao` - Imobiliária
- `BlocoImportacao` - Bloco criado automaticamente
- `ValidadorImportacao` - Utilitários de validação
- `GeradorSenha` - Geração de senhas seguras

---

## 🔄 FLUXO COMPLETO

```
┌─────────────────────────────────────────────────────────────┐
│ 1️⃣ USER SELECIONA ARQUIVO                                  │
│    FilePicker → .xlsx recebido                             │
└─────────────────┬───────────────────────────────────────────┘
                  │
┌─────────────────┴───────────────────────────────────────────┐
│ 2️⃣ PARSING COM PARSEADOR_EXCEL                            │
│    - Lê arquivo Excel                                       │
│    - Valida colunas                                         │
│    - Extrai linhas                                          │
│    ↓ Retorna List<ImportacaoRow>                          │
└─────────────────┬───────────────────────────────────────────┘
                  │
┌─────────────────┴───────────────────────────────────────────┐
│ 3️⃣ VALIDAÇÃO COM IMPORTACAO_SERVICE                        │
│    - Valida cada linha                                      │
│    - Deteta duplicatas (planilha)                          │
│    - Deteta duplicatas (BD)                                │
│    - Popula errosValidacao em cada row                     │
│    ↓ Retorna List<ImportacaoRow> validadas               │
└─────────────────┬───────────────────────────────────────────┘
                  │
┌─────────────────┴───────────────────────────────────────────┐
│ 4️⃣ PREVIEW PARA USUARIO                                    │
│    - Mostra: ✅ 22 linhas válidas                          │
│    - Mostra: ❌ 3 linhas com erro                          │
│    - Mostra: Lista detalhada de erros                      │
│    - User clica: "Cancelar" ou "Confirmar"               │
└─────────────────┬───────────────────────────────────────────┘
                  │
        ┌─────────┴─────────┐
        │                   │
    ❌ CANCELAR        ✅ CONFIRMAR
        │                   │
        └─────────┬─────────┘
                  │
┌─────────────────┴───────────────────────────────────────────┐
│ 5️⃣ MAPEAMENTO PARA ENTIDADES                               │
│    - Filtra apenas linhas SEM ERRO                         │
│    - Agrupa proprietários (múltiplas unidades)            │
│    - Agrupa inquilinos (1:1)                              │
│    - Cria blocos automaticamente                          │
│    - Gera senhas para cada usuário                        │
│    ↓ Retorna Map com todas as entidades                  │
└─────────────────┬───────────────────────────────────────────┘
                  │
┌─────────────────┴───────────────────────────────────────────┐
│ 6️⃣ INSERÇÃO NO SUPABASE (PRÓXIMA TAREFA)                  │
│    - Inserir proprietários com senhas                      │
│    - Inserir inquilinos com senhas                         │
│    - Criar/atualizar blocos                               │
│    - Inserir imobiliárias                                  │
│    ↓ Retorna ImportacaoResultado                         │
└─────────────────┬───────────────────────────────────────────┘
                  │
┌─────────────────┴───────────────────────────────────────────┐
│ 7️⃣ MOSTRAR RESULTADO FINAL AO USER                         │
│    - ✅ 22 proprietários criados                           │
│    - ✅ 18 inquilinos criados                              │
│    - ✅ 5 imobiliárias criadas                             │
│    - ❌ 3 linhas não importadas                            │
│    - 🔐 Senhas para distribuição                          │
└─────────────────────────────────────────────────────────────┘
```

---

## 📝 EXEMPLO DE USO

```dart
// Seleção e processamento
final bytes = await _selecionarArquivo();

// 1. Validar com dados do banco
final cpfsExistentes = await _buscarCpfsNoSupabase();
final emailsExistentes = await _buscarEmailsNoSupabase();

final rows = await ImportacaoService.parsarEValidarArquivo(
  bytes,
  cpfsExistentesNoBanco: cpfsExistentes,
  emailsExistenteNoBanco: emailsExistentes,
);

// 2. Separar válidas e com erro
final validas = rows.where((r) => !r.temErros).toList();
final comErro = rows.where((r) => r.temErros).toList();

// 3. Mostrar preview
_mostrarPreview(
  linhasValidas: validas.length,
  linhasComErro: comErro.length,
  erros: comErro.expand((r) => r.errosValidacao).toList(),
);

// 4. Se user confirmar
if (userConfirmed) {
  // Mapear para entidades
  final mapeado = await ImportacaoService.mapearParaEntidades(
    validas,
    condominioId: widget.condominioId,
  );

  // Dados prontos para inserção
  final proprietarios = mapeado['proprietarios'];      // List<ProprietarioImportacao>
  final inquilinos = mapeado['inquilinos'];            // List<InquilinoImportacao>
  final blocos = mapeado['blocos'];                    // List<BlocoImportacao>
  final imobiliarias = mapeado['imobiliarias'];        // List<ImobiliarioImportacao>
  final senhasProprietarios = mapeado['senhasProprietarios']; // Map
  
  // TODO: Inserir no Supabase (próxima tarefa)
}
```

---

## 🎯 O QUE ESTÁ PRONTO PARA USAR

✅ **Leitura de arquivo Excel** - Parse completo, columns validation
✅ **Validações de dados** - CPF, email, telefone, fração, campos obrigatórios
✅ **Detecção de duplicatas** - Planilha + Banco de dados
✅ **Geração de senhas** - Simples e seguras
✅ **Mapeamento de entidades** - Proprietário N:1, Inquilino 1:1
✅ **Relatórios de erro** - Mensagens claras por linha

---

## 🚀 PRÓXIMAS TAREFAS

**Tarefa 7:** Implementar inserção em BD com transações
- Usar dados mapeados
- Inserir no Supabase com transações
- Tratamento de erro/rollback

**Tarefa 8:** Criar UI modal
- Seleção arquivo
- Preview validações
- Confirmação
- Progresso
- Resultado final

---

## 📚 ARQUIVOS CRIADOS

| Arquivo | Função |
|---------|--------|
| `parseador_excel.dart` | Faz parsing do Excel |
| `importacao_service.dart` | Valida + mapeia dados |
| `importacao_service_exemplos.dart` | Exemplos de uso |
| `importacao_row.dart` ✅ | Modelo de linha |
| `importacao_resultado.dart` ✅ | Resultado final |
| `importacao_entidades.dart` ✅ | Modelos (Proprietario, Inquilino, etc) |
| `validador_importacao.dart` ✅ | Validações |
| `gerador_senha.dart` ✅ | Geração de senhas |
| `FORMATO_PLANILHA_IMPORTACAO.md` ✅ | Guia de formato |

---

## 🧪 TESTES JÁ COBERTOS

- ✅ Parsing de arquivo válido
- ✅ Parsing de arquivo com colunas ausentes (erro claro)
- ✅ Validação de CPF (formato, duplicata, BD)
- ✅ Validação de email (formato, duplicata, BD)
- ✅ Validação de telefone (10-11 dígitos)
- ✅ Validação de fração ideal (número positivo)
- ✅ Validação de campos obrigatórios
- ✅ Mapeamento de proprietário com múltiplas unidades
- ✅ Mapeamento de inquilino 1:1
- ✅ Criação automática de blocos
- ✅ Geração de senhas únicas

---

## 💡 DECISÕES DE DESIGN

1. **Validação em 2 fases:**
   - Phase 1: Validar na planilha (duplicatas internas)
   - Phase 2: Validar contra BD (duplicatas externas)

2. **Proprietário com múltiplas unidades:**
   - Groupado por CPF
   - Pode ter N unidades em diferentes blocos

3. **Inquilino 1:1:**
   - Sempre associado a uma unidade específica
   - Um inquilino por unidade

4. **Blocos automáticos:**
   - Se vazio = "A"
   - Se novo = criado automaticamente

5. **Senhas simples:**
   - Formato: CG2024XYZ123
   - Fácil de memorizar e distribuir
   - Exibidas no relatório (Opção A do usuário)

---

## ⚠️ LIMITAÇÕES CONHECIDAS

- Arquivo Excel deve estar formatado com as colunas exatas
- Linhas completamente vazias são ignoradas
- CPF/Email não permite duplicatas (por design)
- Transações BD implementadas na próxima tarefa

---

✅ **TAREFA 3 COMPLETA!** Está pronto para integração com o Supabase na Tarefa 7.
