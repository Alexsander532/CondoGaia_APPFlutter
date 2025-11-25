# 🚀 INSTRUÇÕES PARA INTEGRAR QR CODES EM PROPRIETÁRIOS, INQUILINOS E IMOBILIÁRIAS

## 📝 TAREFA 4: Integrar QR na Criação de Proprietários

**Local:** `lib/services/unidade_detalhes_service.dart`

**Método:** `criarProprietario()` (linha ~122)

### Passos:

1. **Adicionar import no topo do arquivo:**
```dart
import 'qr_code_generation_service.dart';
```

2. **Modificar o método `criarProprietario()` para adicionar geração de QR:**

```dart
/// Cria um novo proprietário
Future<Proprietario> criarProprietario({
  required String condominioId,
  required String unidadeId,
  required String nome,
  required String cpfCnpj,
  // ... outros parâmetros ...
}) async {
  try {
    final response = await _supabase
        .from('proprietarios')
        .insert({
          'condominio_id': condominioId,
          'unidade_id': unidadeId,
          'nome': nome,
          'cpf_cnpj': cpfCnpj,
          // ... outros campos ...
        })
        .select()
        .single();

    final proprietario = Proprietario.fromJson(response);
    
    // ✅ NOVO: Gerar QR code em background
    _gerarQRCodeProprietarioAsync(proprietario, cpfCnpj);
    
    return proprietario;
  } catch (e) {
    throw Exception('Erro ao criar proprietário: $e');
  }
}
```

3. **Adicionar método auxiliar:**

```dart
/// Gera QR code para o proprietário em background
void _gerarQRCodeProprietarioAsync(Proprietario proprietario, String cpfCnpj) {
  Future.delayed(const Duration(milliseconds: 500), () async {
    try {
      print('🔄 [Proprietário] Iniciando geração de QR Code para: ${proprietario.nome}');

      final qrCodeUrl = await QrCodeGenerationService.gerarESalvarQRCodeGenerico(
        tipo: 'proprietario',
        id: proprietario.id,
        nome: proprietario.nome,
        tabelaNome: 'proprietarios',
        dados: {
          'id': proprietario.id,
          'nome': proprietario.nome,
          'cpf': _sanitizarCPF(cpfCnpj),
          'email': proprietario.email ?? '',
          'telefone': proprietario.celular ?? proprietario.telefone ?? '',
          'condominio_id': proprietario.condominioId,
          'data_criacao': DateTime.now().toIso8601String(),
        },
      );

      if (qrCodeUrl != null) {
        print('✅ [Proprietário] QR Code gerado e salvo: $qrCodeUrl');
      } else {
        print('❌ [Proprietário] Falha ao gerar QR Code');
      }
    } catch (e) {
      print('❌ [Proprietário] Erro ao gerar QR Code: $e');
    }
  });
}

/// Sanitiza o CPF para exibição (apenas últimos 4 dígitos)
String _sanitizarCPF(String cpf) {
  final cpfLimpo = cpf.replaceAll(RegExp(r'[^\d]'), '');
  if (cpfLimpo.length < 4) return cpfLimpo;
  return cpfLimpo.substring(cpfLimpo.length - 4);
}
```

---

## 📝 TAREFA 5: Integrar QR na Criação de Inquilinos

**Local:** `lib/services/unidade_detalhes_service.dart`

**Método:** `criarInquilino()` (linha ~190 aproximadamente)

### Passos idênticos à Tarefa 4:

1. Adicionar import (já está feito)
2. Modificar `criarInquilino()` adicionar geração de QR
3. Criar método `_gerarQRCodeInquilinoAsync()` com padrão semelhante

**Diferenças:**
- `tipo: 'inquilino'`
- `tabelaNome: 'inquilinos'`
- Use `nome` do inquilino

---

## 📝 TAREFA 6: Integrar QR na Criação de Imobiliárias

**Possível Local:** `lib/services/unidade_detalhes_service.dart` OU um novo serviço

**Método:** Procure por `criarImobiliaria()` ou você pode criar

### Passos idênticos:

1. Adicionar import
2. Modificar método de criação de imobiliária
3. Criar método `_gerarQRCodeImobiliariaAsync()`

**Diferenças:**
- `tipo: 'imobiliaria'`
- `tabelaNome: 'imobiliarias'`
- Use `nome` da imobiliária
- Sanitize CNPJ (últimos 4 dígitos, não CPF)

---

## ✅ RESUMO DOS IMPORTS NECESSÁRIOS

```dart
// Em unidade_detalhes_service.dart (ou serviço de imobiliária)
import 'qr_code_generation_service.dart';
```

## 🎯 MÉTODO GENÉRICO JÁ ESTÁ PRONTO

O `QrCodeGenerationService.gerarESalvarQRCodeGenerico()` já foi criado e suporta:
- ✅ unidade
- ✅ proprietario
- ✅ inquilino
- ✅ imobiliaria

Você só precisa chamar com os parâmetros corretos!

---

## 📊 CHECKLIST DAS 3 TAREFAS

### Tarefa 4: Proprietários
- [ ] Adicionar import em unidade_detalhes_service.dart
- [ ] Modificar criarProprietario() para chamar _gerarQRCodeProprietarioAsync()
- [ ] Adicionar método _gerarQRCodeProprietarioAsync()
- [ ] Adicionar método auxiliar _sanitizarCPF()

### Tarefa 5: Inquilinos
- [ ] Modificar criarInquilino() para chamar _gerarQRCodeInquilinoAsync()
- [ ] Adicionar método _gerarQRCodeInquilinoAsync()

### Tarefa 6: Imobiliárias
- [ ] Encontrar ou criar criarImobiliaria()
- [ ] Modificar para chamar _gerarQRCodeImobiliariaAsync()
- [ ] Adicionar método _gerarQRCodeImobiliariaAsync()

---

**⏱️ Tempo estimado:** 15-20 minutos por tarefa
**💪 Dificuldade:** Repetição/Copy-Paste com ajustes menores

Quer que eu faça essas 3 tarefas ou você prefere prosseguir com as tarefas 7 e 8 (widgets e testes)?
