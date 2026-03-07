# 📊 Testes de Leitura de Arquivo Excel

Este diretório contém testes para leitura e processamento de arquivos Excel (.xlsx) no projeto CondoGaia.

## 📁 Arquivos de Teste

### 1. `excel_reader_test.dart`
Teste simples em Dart puro (sem dependências do Flutter) que lê um arquivo Excel e imprime os nomes da coluna A no terminal.

**Como usar:**
```bash
dart run test/excel_reader_test.dart
```

**Output esperado:**
```
════════════════════════════════════════════════════════════════
TESTE DE LEITURA DE ARQUIVO EXCEL (.xlsx)
════════════════════════════════════════════════════════════════
✅ Arquivo encontrado!
📂 Caminho: assets/planilha_importacao.xlsx

📋 NOMES ENCONTRADOS:
────────────────────────────────────────────────────────────────
1 - João Silva
2 - Maria Santos
3 - Pedro Oliveira
...
────────────────────────────────────────────────────────────────
✅ Total de nomes encontrados: 150
════════════════════════════════════════════════════════════════
```

### 2. `excel_reader_flutter_test.dart`
Testes unitários do Flutter com validações automáticas.

**Como usar:**
```bash
flutter test test/excel_reader_flutter_test.dart
```

**Testes inclusos:**
- ✅ Leitura básica de arquivo Excel
- ✅ Validação de formatação (sem espaços extras)
- ✅ Contagem de registros

### 3. `excel_service_test.dart`
Testes usando o `ExcelService` reutilizável com exemplos de processamento customizado.

**Como usar:**
```bash
flutter test test/excel_service_test.dart
```

## 🛠️ ExcelService (Serviço Reutilizável)

Arquivo: `lib/services/excel_service.dart`

Fornece funções auxiliares para leitura e processamento de arquivos Excel:

### Métodos Disponíveis

#### 1. `lerColuna()` - Leitura simples de coluna
```dart
final nomes = await ExcelService.lerColuna(
  'assets/planilha_importacao.xlsx',
  colunaIndex: 0, // Coluna A
);
print(nomes); // ['João Silva', 'Maria Santos', ...]
```

#### 2. `lerComProcessador()` - Processamento customizado
```dart
final dados = await ExcelService.lerComProcessador<Map<String, dynamic>>(
  'assets/planilha_importacao.xlsx',
  (linha) {
    return {
      'nome': linha[0]?.toString() ?? '',
      'email': linha[1]?.toString() ?? '',
      'telefone': linha[2]?.toString() ?? '',
    };
  },
);
```

#### 3. `imprimirDados()` - Formatação de saída
```dart
ExcelService.imprimirDados(nomes, titulo: 'NOMES ENCONTRADOS');
// Imprime de forma formatada:
// 1 - João Silva
// 2 - Maria Santos
// ...
```

## 📋 Estrutura Esperada do Arquivo Excel

```
┌─────────────────────────────┐
│ Coluna A                    │
├─────────────────────────────┤
│ João Silva      (Linha 1)   │
│ Maria Santos    (Linha 2)   │
│ Pedro Oliveira  (Linha 3)   │
│ Ana Costa       (Linha 4)   │
│ ...             (...)       │
└─────────────────────────────┘
```

**Requisitos:**
- Arquivo em formato .xlsx
- Nomes na **Coluna A** (primeira coluna)
- A partir da **Linha 1** (sem cabeçalho)
- Leitura dinâmica até encontrar linhas vazias

## 🚀 Executar Todos os Testes

```bash
# Executar todos os testes do projeto
flutter test

# Executar apenas testes de Excel
flutter test test/excel_*

# Executar com verbose (mais detalhes)
flutter test test/excel_reader_flutter_test.dart -v
```

## 📝 Exemplos de Uso na Aplicação

### Exemplo 1: Importar nomes em um formulário
```dart
import 'package:condogaiaapp/services/excel_service.dart';

// Na sua tela ou serviço
final nomes = await ExcelService.lerColuna('assets/planilha_importacao.xlsx');

for (String nome in nomes) {
  // Usar cada nome
  await MinhaService.criar(nome: nome);
}
```

### Exemplo 2: Processar dados complexos
```dart
final pessoas = await ExcelService.lerComProcessador<Pessoa>(
  'assets/planilha_importacao.xlsx',
  (linha) => Pessoa(
    nome: linha[0]?.toString() ?? '',
    cpf: linha[1]?.toString() ?? '',
    telefone: linha[2]?.toString() ?? '',
  ),
);
```

### Exemplo 3: Importação em lote
```dart
try {
  final nomes = await ExcelService.lerColuna('assets/planilha_importacao.xlsx');
  ExcelService.imprimirDados(nomes, titulo: 'Importando pessoas');
  
  for (String nome in nomes) {
    await proprietarioService.criar(nome: nome);
  }
} catch (e) {
  print('Erro na importação: $e');
}
```

## 🔧 Dependências Necessárias

O projeto já possui a dependência no `pubspec.yaml`:
```yaml
dependencies:
  excel: ^2.0.0
```

Se precisar adicionar:
```bash
flutter pub add excel
```

## ⚙️ Configuração do Arquivo

No `pubspec.yaml`, certifique-se que a pasta `assets/` está incluída:
```yaml
flutter:
  assets:
    - assets/
    - assets/images/
```

## 📊 Output Formatado

Os testes exibem saída no terminal assim:

```
════════════════════════════════════════════════════════════════════
📋 NOMES ENCONTRADOS
════════════════════════════════════════════════════════════════════
1 - João Silva
2 - Maria Santos
3 - Pedro Oliveira
4 - Ana Costa
5 - Carlos Mendes
────────────────────────────────────────────────────────────────────
✅ Total: 5 registro(s)
════════════════════════════════════════════════════════════════════
```

## ✅ Validações Implementadas

- ✅ Verificação de existência do arquivo
- ✅ Validação do formato Excel
- ✅ Remoção de espaços em branco
- ✅ Detecção automática de fim de dados
- ✅ Contagem de registros
- ✅ Tratamento de erros

## 🐛 Troubleshooting

### Erro: "Arquivo não encontrado"
- Certifique-se que o arquivo está em `assets/planilha_importacao.xlsx`
- Verifique que `assets/` está configurado em `pubspec.yaml`

### Erro: "Arquivo Excel vazio ou inválido"
- Abra o arquivo em um editor de Excel
- Certifique-se que tem dados na coluna A
- Salve como `.xlsx` (não `.xls`)

### Nomes não aparecem
- Verifique que os nomes estão na **Coluna A**
- Confirme que começam na **Linha 1**
- Não deve haver cabeçalho

## 📚 Referências

- [Package Excel](https://pub.dev/packages/excel)
- [Flutter Testing Documentation](https://flutter.dev/docs/testing)
- [Dart Testing Guide](https://dart.dev/guides/testing)

---

**Autor:** CondoGaia Development Team
**Data:** Novembro 2025
**Status:** ✅ Completo e Testado
