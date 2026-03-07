# 📦 Models — Feature Despesa/Receita

Esta pasta contém as **entidades de domínio** da feature. Cada model representa uma tabela no banco de dados Supabase e segue o padrão:
- Imutável com `Equatable`
- `fromJson()` para deserializar resposta do Supabase
- `toJson()` para enviar ao Supabase (INSERT/UPDATE)
- `copyWith()` para criar versões modificadas imutavelmente

---

## Tabelas Supabase correspondentes

| Model | Tabela |
|---|---|
| `Despesa` | `despesas` |
| `Receita` | `receitas` |
| `Transferencia` | `transferencias` |

---

## `Despesa` (`despesa_model.dart`)

Representa uma saída financeira do condomínio.

### Campos principais
| Campo | Tipo | Coluna no BD | Observação |
|---|---|---|---|
| `id` | `String?` | `id` | Null ao criar novo |
| `condominioId` | `String` | `condominio_id` | Obrigatório |
| `contaId` | `String?` | `conta_id` | FK para `contas_bancarias` |
| `categoriaId` | `String?` | `categoria_id` | FK para `categorias_financeiras` |
| `subcategoriaId` | `String?` | `subcategoria_id` | FK para `subcategorias_financeiras` |
| `descricao` | `String?` | `descricao` | Usado no filtro de palavra-chave |
| `valor` | `double` | `valor` | Default `0` |
| `dataVencimento` | `DateTime?` | `data_vencimento` | Filtro de mês/ano usa este campo |
| `recorrente` | `bool` | `recorrente` | Default `false` |
| `qtdMeses` | `int?` | `qtd_meses` | Null = infinito |
| `meAvisar` | `bool` | `me_avisar` | Avisar vencimento |
| `link` | `String?` | `link` | URL de comprovante |
| `fotoUrl` | `String?` | `foto_url` | ⚠️ Upload não implementado ainda |
| `tipo` | `String` | `tipo` | `'MANUAL'` ou `'AUTOMATICO'` |

### Campos auxiliares (join)
Esses campos vêm de joins do Supabase e **não são enviados no `toJson()`**:
- `contaNome` → `contas_bancarias.banco`
- `categoriaNome` → `categorias_financeiras.nome`
- `subcategoriaNome` → `subcategorias_financeiras.nome`

### Query de leitura (no Service)
```sql
SELECT *, contas_bancarias(banco), categorias_financeiras(nome), subcategorias_financeiras(nome)
FROM despesas
WHERE condominio_id = ?
  AND data_vencimento BETWEEN inicio AND fim
  [AND conta_id = ?, categoria_id = ?, subcategoria_id = ?, descricao ILIKE '%palavra%']
ORDER BY data_vencimento DESC
```

---

## `Receita` (`receita_model.dart`)

Representa uma entrada financeira do condomínio.

### Campos principais
| Campo | Tipo | Coluna no BD | Observação |
|---|---|---|---|
| `id` | `String?` | `id` | Null ao criar novo |
| `condominioId` | `String` | `condominio_id` | Obrigatório |
| `contaId` | `String?` | `conta_id` | FK para `contas_bancarias` |
| `contaContabil` | `String?` | `conta_contabil` | Enum: `'Controle'`, `'Fundo Reserva'`, `'Obras'` |
| `descricao` | `String?` | `descricao` | |
| `valor` | `double` | `valor` | Default `0` |
| `dataCredito` | `DateTime?` | `data_credito` | Filtro de mês/ano usa este campo |
| `recorrente` | `bool` | `recorrente` | Default `false` |
| `qtdMeses` | `int?` | `qtd_meses` | Null = infinito |
| `tipo` | `String` | `tipo` | `'MANUAL'` ou `'AUTOMATICO'` |

### Campo auxiliar (join)
- `contaNome` → `contas_bancarias.banco`

> 💡 Receitas **não têm** `categoriaId` — o campo equivalente é `contaContabil` (tipo de conta contábil).

---

## `Transferencia` (`transferencia_model.dart`)

Representa uma movimentação **entre contas** do condomínio (não entra nem sai do caixa consolidado).

### Campos principais
| Campo | Tipo | Coluna no BD | Observação |
|---|---|---|---|
| `id` | `String?` | `id` | Null ao criar novo |
| `condominioId` | `String` | `condominio_id` | Obrigatório |
| `contaDebitoId` | `String?` | `conta_debito_id` | Conta de origem (debita) |
| `contaCreditoId` | `String?` | `conta_credito_id` | Conta de destino (credita) |
| `descricao` | `String?` | `descricao` | |
| `valor` | `double` | `valor` | Default `0` |
| `dataTransferencia` | `DateTime?` | `data_transferencia` | Filtro de mês/ano usa este campo |
| `recorrente` | `bool` | `recorrente` | Default `false` |
| `qtdMeses` | `int?` | `qtd_meses` | Null = infinito |
| `tipo` | `String` | `tipo` | `'MANUAL'` ou `'AUTOMATICO'` |

### Campos auxiliares (join com alias)
O Supabase usa aliases de join porque há duas FKs para a mesma tabela:
```sql
SELECT *,
  conta_debito:contas_bancarias!conta_debito_id(banco),
  conta_credito:contas_bancarias!conta_credito_id(banco)
```
- `contaDebitoNome` → `conta_debito.banco`
- `contaCreditoNome` → `conta_credito.banco`

---

## Padrão `toJson` x `fromJson`

### Ao **ler** do Supabase (`fromJson`)
- Datas são parseadas com `DateTime.tryParse()`
- Valores `null` recebem defaults seguros (`valor = 0`, `tipo = 'MANUAL'`)
- Campos de join acessam via nested map: `json['contas_bancarias']?['banco']`

### Ao **salvar** no Supabase (`toJson`)
- Datas são convertidas para `'yyyy-MM-dd'` (`.split('T').first`)
- O campo `id` é **omitido do map** se for null (para INSERT)
- Se `id != null`, é incluído (para UPDATE feito com `.eq('id', id)`)

---

## ⚠️ Pontos de atenção para desenvolvimento

- **`fotoUrl`** em `Despesa`: o campo existe no model e no BD, mas o upload de foto ainda não foi implementado na UI.
- **`qtdMeses = null`** significa recorrência infinita; `0` não é válido — sempre use `null` para "sem limite".
- **Transferências não afetam** `totalReceitas` nem `totalDespesas` do `DespesaReceitaState` — são contabilizadas separadamente.
- Para adicionar novos campos ao model, lembre de atualizar `fromJson`, `toJson`, `copyWith` e a lista `props` do `Equatable`.
