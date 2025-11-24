# ✅ Implementação: Imobiliária por Unidade

## 📋 Mudanças Implementadas (Backend)

### **1. Modelo Imobiliaria (imobiliaria.dart)** ✅
- ✅ Adicionado campo `unidadeId` (String?)
- ✅ Atualizado `fromJson()` para parsear `unidade_id`
- ✅ Atualizado `toJson()` para incluir `unidade_id`
- ✅ Atualizado `copyWith()` com parâmetro `unidadeId`

### **2. Serviço (unidade_detalhes_service.dart)** ✅
- ✅ Modificado `buscarDetalhesUnidade()` para filtrar imobiliária por `unidade_id`
- ✅ Atualizado `criarImobiliaria()` para aceitar `unidadeId` como parâmetro obrigatório
- ✅ Alterado SQL INSERT para incluir `unidade_id`

### **3. Tela (detalhes_unidade_screen.dart)** ✅
- ✅ Atualizado `_salvarImobiliaria()` para passar `widget.unidade` como `unidadeId`

---

## 🗄️ SQL: Alterações no Banco de Dados

Execute os seguintes comandos no Supabase SQL Editor:

### **Passo 1: Adicionar coluna unidade_id**

```sql
-- Adicionar coluna unidade_id
ALTER TABLE imobiliarias 
ADD COLUMN unidade_id uuid NULL;

-- Adicionar chave estrangeira para unidade
ALTER TABLE imobiliarias 
ADD CONSTRAINT fk_imobiliarias_unidade 
FOREIGN KEY (unidade_id) REFERENCES unidades(id) ON DELETE CASCADE;

-- Criar índice para performance
CREATE INDEX IF NOT EXISTS idx_imobiliarias_unidade 
ON imobiliarias USING btree (unidade_id);
```

### **Passo 2: Atualizar constraints UNIQUE**

```sql
-- Remover constraints antigas (por condomínio)
ALTER TABLE imobiliarias 
DROP CONSTRAINT uk_imobiliarias_cnpj_condominio;

ALTER TABLE imobiliarias 
DROP CONSTRAINT uk_imobiliarias_email_condominio;

-- Adicionar constraints novas (por unidade)
ALTER TABLE imobiliarias 
ADD CONSTRAINT uk_imobiliarias_cnpj_unidade 
UNIQUE (cnpj, unidade_id);

ALTER TABLE imobiliarias 
ADD CONSTRAINT uk_imobiliarias_email_unidade 
UNIQUE (email, unidade_id);
```

### **Passo 3 (Opcional): Migrar dados existentes**

Se você tem imobiliárias no banco sem `unidade_id`, execute:

```sql
-- Atualizar imobiliárias existentes
-- Associar com a primeira unidade de cada condomínio
UPDATE imobiliarias i
SET unidade_id = (
  SELECT id FROM unidades u 
  WHERE u.condominio_id = i.condominio_id 
  LIMIT 1
)
WHERE unidade_id IS NULL AND condominio_id IS NOT NULL;
```

---

## 🔄 Novo Fluxo

```
User abre Detalhes da Unidade A (ID: "unit-123")
    ↓
buscarDetalhesUnidade("unit-123")
    ↓
SELECT * FROM imobiliarias 
WHERE unidade_id = "unit-123"
    ↓
Carrega imobiliária ESPECÍFICA da Unidade A
    ↓
User preenche dados da imobiliária e clica "SALVAR"
    ↓
_salvarImobiliaria() chamado
    ↓
Se não existe:
  criarImobiliaria(
    condominioId: "cond-456",
    unidadeId: "unit-123",  ← NOVO: específico da unidade
    nome: "ABC Imóveis",
    cnpj: "11.222.333/0001-81"
  )
    ↓
INSERT INTO imobiliarias (
  condominio_id, unidade_id, nome, cnpj
)
VALUES (
  "cond-456", "unit-123", "ABC Imóveis", "11.222.333/0001-81"
)
    ↓
✅ Imobiliária criada APENAS para Unidade A
    ↓
User abre Detalhes da Unidade B (ID: "unit-789")
    ↓
Busca imobiliária por unidade_id = "unit-789"
    ↓
Não encontra (Null)
    ↓
User pode criar imobiliária DIFERENTE para Unidade B
```

---

## ✨ Resultado Final

**Antes (Problema):**
```
Condomínio "Prédio A"
├── Unidade 101 → Imobiliária "ABC Imóveis" (ID: imob-001)
├── Unidade 102 → Imobiliária "ABC Imóveis" (mesma!) ← PROBLEMA
└── Unidade 103 → Imobiliária "ABC Imóveis" (mesma!) ← PROBLEMA
```

**Depois (Resolvido):**
```
Condomínio "Prédio A"
├── Unidade 101 → Imobiliária "ABC Imóveis" (ID: imob-001)
├── Unidade 102 → Imobiliária "XYZ Corretora" (ID: imob-002) ← DIFERENTE!
└── Unidade 103 → Imobiliária "ABC Imóveis" (ID: imob-003) ← DIFERENTE!
```

---

## 📝 Arquivos Modificados

| Arquivo | Mudanças |
|---------|----------|
| `lib/models/imobiliaria.dart` | Adicionado campo `unidadeId` |
| `lib/services/unidade_detalhes_service.dart` | Filtrar imob por unidade, adicionar unidadeId ao criar |
| `lib/screens/detalhes_unidade_screen.dart` | Passar `widget.unidade` ao criar imobiliária |

---

## ✅ Checklist

- ✅ Código Dart implementado
- ✅ Sem erros de compilação
- ⏳ **Aguardando:** Executar SQL no Supabase
- ⏳ **Depois:** Testar fluxo completo

---

## 🧪 Como Testar

1. **Executar SQL** no Supabase (copiar os comandos acima)
2. **Compilar** o app (dart deve estar sem erros)
3. **Abrir** Detalhes da Unidade A
4. **Criar** Imobiliária "ABC Imóveis"
5. **Abrir** Detalhes da Unidade B
6. **Criar** Imobiliária "XYZ Corretora"
7. **Voltar** para Unidade A
8. **Verificar:** Deve mostrar "ABC Imóveis" (não "XYZ")
9. **Voltar** para Unidade B
10. **Verificar:** Deve mostrar "XYZ Corretora" (não "ABC")

✅ Se passa nesse teste, problema resolvido!

---

## 🔍 Validações Implementadas

- ✅ Constraint UNIQUE por (CNPJ, unidade_id)
- ✅ Foreign Key em unidades (ON DELETE CASCADE)
- ✅ Índice em unidade_id para performance
- ✅ Campo unidade_id obrigatório na criação

---

## 📊 Status

- ✅ Backend Dart: Pronto
- ✅ Modelos: Atualizados
- ✅ Serviços: Atualizados
- ⏳ SQL: Aguardando execução no Supabase
- ⏳ Teste: Aguardando execução
