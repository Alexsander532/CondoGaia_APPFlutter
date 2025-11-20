# 📋 Importação de Lista de Presença em Reservas

## 🎯 Funcionalidade

Nova funcionalidade que permite importar uma lista de presença (nomes) a partir de um arquivo Excel (.xlsx) diretamente no modal de criação/edição de reservas.

## 📊 Estrutura do Arquivo Excel

O arquivo deve ter os nomes na **Coluna A**, começando da **Linha 1**:

```
┌─────────────────────────────────┐
│ Coluna A (Nomes)               │
├─────────────────────────────────┤
│ João Silva          (Linha 1)   │
│ Maria Santos        (Linha 2)   │
│ Pedro Oliveira      (Linha 3)   │
│ Ana Costa           (Linha 4)   │
│ Carlos Mendes       (Linha 5)   │
│ ...                 (...)       │
└─────────────────────────────────┘
```

## 🚀 Como Usar

### Passo 1: Abrir Modal de Criação/Edição de Reserva
- Clique em criar nova reserva ou editar uma existente
- O modal será aberto

### Passo 2: Localizar o Botão "Fazer Upload da Lista"
Na seção de "Observações", abaixo do campo de texto principal, você verá:

```
📤 Fazer Upload da Lista
```

### Passo 3: Selecionar Arquivo Excel
- Clique no botão
- Selecione um arquivo `.xlsx` com os nomes na coluna A
- O sistema irá ler automaticamente

### Passo 4: Confirmação de Importação
Após a importação bem-sucedida, você verá:

```
✓ Arquivo_Name.xlsx ✓ (5 nomes)
```

E o campo de observações será preenchido automaticamente:

```
1. João Silva
2. Maria Santos
3. Pedro Oliveira
4. Ana Costa
5. Carlos Mendes
```

## 💾 Onde os Dados são Salvos

Os dados importados são salvos no campo `lista_presentes` da tabela `reservas`:

```sql
CREATE TABLE reservas (
  ...
  lista_presentes text null,  -- ← Os dados aqui
  ...
)
```

Formato armazenado no banco:
```
1. João Silva
2. Maria Santos
3. Pedro Oliveira
```

## 🔄 Processamento de Dados

### Fluxo Completo

```
Arquivo Excel
    ↓
ExcelService.lerColuna()
    ↓
Ler Coluna A
    ↓
Formatar com números: 1. Nome, 2. Nome, etc
    ↓
Preencher campo "_listaPresentesController"
    ↓
Salvar em "lista_presentes" na reserva
```

### Tratamento de Erros

| Erro | Ação |
|------|------|
| Arquivo inválido | Mensagem de erro em vermelho |
| Coluna A vazia | Aviso em laranja |
| Arquivo muito grande | Importa até encontrar célula vazia |
| Caracteres especiais | Preserva conforme no Excel |

## ⚙️ Validações Implementadas

- ✅ Aceita apenas arquivos `.xlsx` ou `.xls`
- ✅ Lê apenas até encontrar linhas vazias
- ✅ Remove espaços em branco extras dos nomes
- ✅ Formata automaticamente com números (1., 2., etc)
- ✅ Mostra quantidade de nomes importados
- ✅ Indicador visual de sucesso (verde com ✓)

## 🎨 Interface

### Estados do Botão

#### Estado Padrão
```
📤 Fazer Upload da Lista
```

#### Carregando
```
📤 Arquivo.xlsx (lendo...)
```

#### Sucesso
```
✓ Arquivo.xlsx ✓ (5 nomes)
[X]  ← Botão para remover
```

#### Campo Preenchido
```
Observações (Digite o nome e descrição da reserva)

[1. João Silva        ]
[2. Maria Santos      ]
[3. Pedro Oliveira    ]
[4. Ana Costa         ]
[5. Carlos Mendes     ]
```

## 📝 Exemplos de Uso

### Exemplo 1: Importar Lista de Presença Simples

1. Arquivo: `lista_presenca.xlsx`
   ```
   João Silva
   Maria Santos
   Pedro Oliveira
   ```

2. Resultado no campo:
   ```
   1. João Silva
   2. Maria Santos
   3. Pedro Oliveira
   ```

3. Salvo na base como:
   ```sql
   INSERT INTO reservas (lista_presentes, ...) 
   VALUES ('1. João Silva
   2. Maria Santos
   3. Pedro Oliveira', ...)
   ```

### Exemplo 2: Importar Lista Longa

O sistema importa automaticamente até encontrar uma linha vazia:

- Arquivo: `todos_moradores.xlsx` (200 nomes)
- Sistema importa todos os 200 nomes
- Campo fica preenchido com: `1. Nome 1` até `200. Nome 200`

## 🔧 Integração com Banco de Dados

### Criação de Reserva
```dart
await ReservaService.criarReserva(
  ...
  listaPresentes: _listaPresentesController.text, // ← Dados importados
);
```

### Edição de Reserva
```dart
await ReservaService.atualizarReserva(
  reservaId,
  listaPresentes: _listaPresentesController.text, // ← Dados importados
);
```

## 🐛 Troubleshooting

### Problema: "Nenhum nome encontrado na coluna A"
**Solução:**
- Verifique se os nomes estão na **Coluna A**
- Confirme que começam na **Linha 1** (sem cabeçalho)
- Salve o arquivo como `.xlsx` (não `.xls`)

### Problema: Arquivo não abre
**Solução:**
- Verifique se é um arquivo válido do Excel
- Tente abrir no Excel e salvar novamente
- Certifique-se da extensão `.xlsx`

### Problema: Nomes com espaços especiais
**Solução:**
- O sistema preserva os nomes exatamente como estão no Excel
- Acentos, caracteres especiais são mantidos

## 📚 Código Implementado

### Arquivo: `lib/services/excel_service.dart`
Serviço principal para leitura de arquivos Excel

### Arquivo: `lib/screens/reservas_screen.dart`
Integração do botão de upload na tela de reservas

### Mudanças:
1. ✅ Import do `ExcelService`
2. ✅ Substituição do file picker para aceitar apenas `.xlsx`
3. ✅ Lógica de leitura e formatação dos nomes
4. ✅ Feedback visual com sucesso/erro

## 🎯 Próximos Passos (Opcional)

- [ ] Adicionar suporte a múltiplas colunas (Email, Telefone, etc)
- [ ] Permitir edição individual dos nomes importados
- [ ] Exportar lista de presença para Excel
- [ ] Adicionar validação de nomes duplicados
- [ ] Permite upload de foto junto com lista

## 📖 Referências

- [ExcelService Documentation](../test/EXCEL_TESTS_README.md)
- [Package Excel](https://pub.dev/packages/excel)
- [Reserva Model](../models/reserva.dart)
- [Reserva Service](../services/reserva_service.dart)

---

**Status:** ✅ Implementado e Testado
**Data:** Novembro 2025
**Versão:** 1.0

