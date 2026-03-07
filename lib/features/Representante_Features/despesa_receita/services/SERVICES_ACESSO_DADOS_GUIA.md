# 🔌 Services — Feature Despesa/Receita

Esta pasta contém a **camada de acesso a dados** da feature, que se comunica diretamente com o banco de dados Supabase.

---

## Arquivos

| Arquivo | Responsabilidade |
|---|---|
| `i_despesa_receita_service.dart` | Interface abstrata (contrato) |
| `despesa_receita_service.dart` | Implementação real com Supabase |

---

## Interface `IDespesaReceitaService`

Define o contrato que qualquer implementação (real ou mock para testes) deve seguir:

```dart
// Dados de suporte (dropdowns)
listarContas(condominioId) → List<ContaBancaria>
listarCategorias(condominioId) → List<CategoriaFinanceira>

// Despesas
listarDespesas(condominioId, {mes, ano, contaId, categoriaId, subcategoriaId, palavraChave})
salvarDespesa(despesa)           // INSERT ou UPDATE
excluirDespesa(id)               // DELETE único
excluirDespesasMultiplas(ids)    // DELETE em lote

// Receitas
listarReceitas(condominioId, {mes, ano, contaId, contaContabil, tipo})
salvarReceita(receita)
excluirReceita(id)
excluirReceitasMultiplas(ids)

// Transferências
listarTransferencias(condominioId, {mes, ano, contaDebitoId, contaCreditoId})
salvarTransferencia(transferencia)
excluirTransferencia(id)
excluirTransferenciasMultiplas(ids)

// Resumo financeiro
calcularSaldoAnterior(condominioId, {mes, ano}) → double
```

---

## `DespesaReceitaService` — Detalhamento

Recebe um `SupabaseClient` opcional no construtor (default: `Supabase.instance.client`), facilitando testes.

---

### 📋 `listarContas`

```sql
SELECT * FROM contas_bancarias
WHERE condominio_id = ?
ORDER BY is_principal DESC, created_at ASC
```
> Retorna a conta principal primeiro na lista (para o dropdown).

---

### 📋 `listarCategorias`

```sql
SELECT *, subcategorias_financeiras(*)
FROM categorias_financeiras
WHERE condominio_id = ?
ORDER BY nome ASC
```
> Carrega todas as subcategorias junto (em uma única query via nested select do Supabase).
> As categorias incluem tanto tipo `'DESPESA'` quanto `'RECEITA'` — o `DespesaReceitaState` filtra via getters `categoriasDespesa` e `categoriasReceita`.

---

### 💸 `listarDespesas`

Filtros opcionais aplicados dinamicamente (só se preenchidos):
| Parâmetro | Operação |
|---|---|
| `contaId` | `.eq('conta_id', contaId)` |
| `categoriaId` | `.eq('categoria_id', categoriaId)` |
| `subcategoriaId` | `.eq('subcategoria_id', subcategoriaId)` |
| `palavraChave` | `.ilike('descricao', '%palavra%')` |
| `mes` + `ano` | `.gte/.lte('data_vencimento', inicio/fim do mês)` |

Join retornado: `contas_bancarias(banco)`, `categorias_financeiras(nome)`, `subcategorias_financeiras(nome)`

---

### 💰 `listarReceitas`

Filtros opcionais:
| Parâmetro | Operação |
|---|---|
| `contaId` | `.eq('conta_id', contaId)` |
| `contaContabil` | `.eq('conta_contabil', contaContabil)` |
| `tipo` | `.eq('tipo', tipo.toUpperCase())` — ignorado se `'Todos'` |
| `mes` + `ano` | `.gte/.lte('data_credito', inicio/fim do mês)` |

---

### 🔄 `listarTransferencias`

A query usa **aliases de join** porque há duas foreign keys para a mesma tabela `contas_bancarias`:
```dart
.select('*, conta_debito:contas_bancarias!conta_debito_id(banco), conta_credito:contas_bancarias!conta_credito_id(banco)')
```

Filtros:
| Parâmetro | Operação |
|---|---|
| `contaDebitoId` | `.eq('conta_debito_id', contaDebitoId)` |
| `contaCreditoId` | `.eq('conta_credito_id', contaCreditoId)` |
| `mes` + `ano` | `.gte/.lte('data_transferencia', inicio/fim do mês)` |

---

### 💾 `salvarDespesa` / `salvarReceita` / `salvarTransferencia`

O mesmo método faz **INSERT e UPDATE** dependendo da presença do `id`:

```dart
if (model.id != null) {
  // UPDATE
  await supabase.from('tabela').update(data).eq('id', model.id!);
} else {
  // INSERT
  data.remove('id');  // remove a chave 'id' do map (evita enviar null)
  await supabase.from('tabela').insert(data);
}
```

---

### 🗑️ `excluirMultiplas` (Lote)

Usa o operador `inFilter` do Supabase:
```dart
await supabase.from('tabela').delete().inFilter('id', ids);
```
> Executado apenas se há IDs selecionados (verificado no Cubit antes de chamar).

---

### 📊 `calcularSaldoAnterior`

Calcula o saldo do **mês imediatamente anterior** ao mês/ano fornecido:

```
1. Determina mesAnterior/anoAnterior (lida com virada de ano)
2. Busca SUM(receitas.valor) do mês anterior
3. Busca SUM(despesas.valor) do mês anterior
4. Retorna: totalReceitas - totalDespesas
```

> ⚠️ **Nota importante**: este cálculo considera apenas receitas e despesas do **mês anterior** — não é um saldo acumulado histórico. Para um cálculo de saldo real acumulado, seria necessário somar todos os meses anteriores.

---

## Tratamento de erros

- **Listas** (`listarDespesas`, `listarReceitas`, `listarTransferencias`): retornam lista vazia em erro (não lançam exceção) — a UI não quebra, apenas fica sem dados.
- **Operações de escrita** (`salvar`, `excluir`): lançam `Exception` com mensagem descritiva — o Cubit captura e emite `status: error`.
- Todos os erros são logados com `print('⚠️ [DespesaReceitaService] ...')`.

---

## ⚠️ Pontos de atenção para desenvolvimento

- Para **mockar o service em testes**, basta criar uma classe que `implements IDespesaReceitaService` — o Cubit aceita qualquer implementação.
- Os dados de suporte (`contas`, `categorias`) são carregados apenas no `carregarDados()` inicial. Se novas contas forem cadastradas, é necessário recarregar.
- A `calcularSaldoAnterior` faz **2 queries separadas** ao BD — em volumes grandes, considerar criar uma função/view no Supabase.
