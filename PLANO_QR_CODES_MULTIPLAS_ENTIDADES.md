# 📋 PLANO COMPLETO: QR CODES PARA UNIDADES, PROPRIETÁRIOS, INQUILINOS E IMOBILIÁRIAS

## 1. VISÃO GERAL

Implementar geração automática de QR codes para:
- ✅ **Unidades** - QR code com dados da unidade
- ✅ **Proprietários** - QR code com dados do proprietário
- ✅ **Inquilinos** - QR code com dados do inquilino
- ✅ **Imobiliárias** - QR code com dados da imobiliária

Cada QR code será gerado automaticamente quando o registro for criado no banco de dados.

---

## 2. FLUXO DE IMPLEMENTAÇÃO

```
┌─────────────────────────────────────┐
│  1. Estender QrCodeGenerationService │  ← Criar método genérico
└────────────────┬────────────────────┘
                 ↓
┌─────────────────────────────────────┐
│  2. Integrar em cada Service        │  ← unidade, proprietario, etc
└────────────────┬────────────────────┘
                 ↓
┌─────────────────────────────────────┐
│  3. Criar widgets de exibição       │  ← Cards com QR codes
└────────────────┬────────────────────┘
                 ↓
┌─────────────────────────────────────┐
│  4. Testar e validar                │  ← Verificar urls no banco
└─────────────────────────────────────┘
```

---

## 3. DETALHES DO PLANO

### FASE 1: Estender QrCodeGenerationService

**Arquivo:** `lib/services/qr_code_generation_service.dart`

**Novo método:**
```dart
static Future<String?> gerarESalvarQRCodeGenerico({
  required String tipo,              // 'unidade', 'proprietario', 'inquilino', 'imobiliaria'
  required String id,                // ID do registro
  required String nome,              // Nome/numero do registro
  required String tabelaNome,        // Nome da tabela para atualizar
  required Map<String, dynamic> dados, // Dados adicionais para codificar no QR
}) async
```

**Funcionalidade:**
- Recebe tipo genérico
- Monta dados dinamicamente
- Gera imagem PNG
- Faz upload para bucket qr_codes
- Salva URL na tabela correspondente

**Dados do QR Code:**

| Tipo | Dados | Exemplo |
|------|-------|---------|
| unidade | id, numero, bloco, condominio | `{id: "u-123", numero: "101", bloco: "A", condominio: "Condo XYZ"}` |
| proprietario | id, nome, cpf, telefone, email | `{id: "p-456", nome: "João", cpf: "xxx-xxx-xxx-xx", ...}` |
| inquilino | id, nome, cpf, telefone, email | `{id: "i-789", nome: "Maria", cpf: "xxx-xxx-xxx-xx", ...}` |
| imobiliaria | id, nome, cnpj, telefone, email | `{id: "im-123", nome: "XYZ Imob", cnpj: "xx.xxx.xxx/xxxx-xx", ...}` |

---

### FASE 2: Integração em Services

#### 2.1 UNIDADES - `unidade_service.dart`

**Onde:** Após sucesso em `insertUnidade()`
```dart
// Após inserção bem-sucedida
final unidade = await supabase.from('unidades').insert(...).select().single();

// Gerar QR code em background
_gerarQRCodeUnidadeAsync(unidade);
```

**Método auxiliar:**
```dart
void _gerarQRCodeUnidadeAsync(Map<String, dynamic> unidade) {
  Future.delayed(const Duration(milliseconds: 500), () async {
    try {
      final qrCodeUrl = await QrCodeGenerationService.gerarESalvarQRCodeGenerico(
        tipo: 'unidade',
        id: unidade['id'],
        nome: unidade['numero'],
        tabelaNome: 'unidades',
        dados: {
          'id': unidade['id'],
          'numero': unidade['numero'],
          'bloco': unidade['bloco'] ?? '',
          'condominio_id': unidade['condominio_id'],
          'data_criacao': DateTime.now().toIso8601String(),
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
      
      if (qrCodeUrl != null) {
        print('✅ [Unidade] QR Code gerado: $qrCodeUrl');
      } else {
        print('❌ [Unidade] Falha ao gerar QR Code');
      }
    } catch (e) {
      print('❌ [Unidade] Erro ao gerar QR Code: $e');
    }
  });
}
```

#### 2.2 PROPRIETÁRIOS - `proprietario_service.dart`

Mesma abordagem que Unidades:
- Tipo: `'proprietario'`
- Tabela: `'proprietarios'`
- Dados: id, nome, cpf, email, telefone, data_criacao

#### 2.3 INQUILINOS - `inquilino_service.dart`

Mesma abordagem:
- Tipo: `'inquilino'`
- Tabela: `'inquilinos'`
- Dados: id, nome, cpf, email, telefone, data_criacao

#### 2.4 IMOBILIÁRIAS - `imobiliaria_service.dart` ou `condicao_service.dart`

Mesma abordagem:
- Tipo: `'imobiliaria'`
- Tabela: `'imobiliarias'`
- Dados: id, nome, cnpj, email, telefone, data_criacao

---

### FASE 3: Widgets de Exibição

**Opções:**

1. **Reutilizar `QrCodeDisplayWidget`:**
   - Genérico o suficiente para aceitar qualquer tipo
   - Passar tipo como parâmetro se necessário

2. **Criar `QrCodeGenericWidget`:**
   - Versão melhorada que funciona para todos os tipos
   - Mostra tipo de entidade (Unidade, Proprietário, etc)

**Exemplo de uso em Card:**
```dart
ExpansionTile(
  title: Text('Unidade 101'),
  children: [
    QrCodeDisplayWidget(
      qrCodeUrl: unidade['qr_code_url'],
      visitanteNome: unidade['numero'],
      visitanteCpf: unidade['bloco'] ?? '',
      unidade: '',
    ),
    // Botão de compartilhar
  ],
)
```

---

### FASE 4: Dados Armazenados no QR Code

Cada QR code conterá um JSON com informações da entidade:

**Exemplo - Unidade:**
```json
{
  "tipo": "unidade",
  "id": "u-123456",
  "numero": "101",
  "bloco": "A",
  "condominio_id": "cond-789",
  "data_criacao": "2025-11-25T10:30:00Z",
  "timestamp": 1732516200000
}
```

**Exemplo - Proprietário:**
```json
{
  "tipo": "proprietario",
  "id": "p-456789",
  "nome": "João Silva",
  "cpf": "***-***-***-12",
  "email": "joao@email.com",
  "telefone": "(11) 9xxxx-xxxx",
  "data_criacao": "2025-11-25T10:30:00Z",
  "timestamp": 1732516200000
}
```

---

## 4. ARQUIVOS A MODIFICAR

| Arquivo | Mudança |
|---------|---------|
| `qr_code_generation_service.dart` | ✅ Adicionar `gerarESalvarQRCodeGenerico()` |
| `unidade_service.dart` | ❌ Importar + integrar geração de QR |
| `proprietario_service.dart` | ❌ Importar + integrar geração de QR |
| `inquilino_service.dart` | ❌ Importar + integrar geração de QR |
| `imobiliaria_service.dart` | ❌ Importar + integrar geração de QR |
| `qr_code_display_widget.dart` | ⚠️ Verificar se precisa adaptar |
| Screens (unidade, prop, inq, imob) | ⚠️ Adicionar widgets de exibição |

---

## 5. ESTRUTURA DO BUCKET QR_CODES

```
qr_codes/
├── qr_unidade_101_A_1732516200_a7f3.png
├── qr_unidade_102_A_1732516300_b8g4.png
├── qr_proprietario_joao_silva_1732516400_c9h5.png
├── qr_inquilino_maria_santos_1732516500_d0i6.png
└── qr_imobiliaria_xyz_imob_1732516600_e1j7.png
```

**Padrão:** `qr_{tipo}_{identificador}_{timestamp}_{uuid}.png`

---

## 6. URLS ARMAZENADAS NO BANCO

Após sucesso, URLs serão armazenadas assim:

**Unidade:**
```
https://tukpgefrddfchmvtiujp.supabase.co/storage/v1/object/public/qr_codes/qr_unidade_101_A_1732516200_a7f3.png
```

**Proprietário:**
```
https://tukpgefrddfchmvtiujp.supabase.co/storage/v1/object/public/qr_codes/qr_proprietario_joao_silva_1732516400_c9h5.png
```

---

## 7. BENEFÍCIOS

✅ **Automático** - QR code gerado na criação do registro
✅ **Único** - Cada entidade tem seu próprio QR code
✅ **Rastreável** - Código contém dados da entidade
✅ **Compartilhável** - Pode ser compartilhado via chat, email, etc
✅ **Seguro** - Armazenado em Supabase Storage com URL pública
✅ **Escalável** - Mesmo padrão para todas as entidades

---

## 8. TIMELINE ESTIMADA

| Fase | Tarefa | Tempo |
|------|--------|-------|
| 1 | Estender QrCodeGenerationService | 30 min |
| 2 | Integrar em 4 services | 60 min |
| 3 | Criar widgets/screens | 45 min |
| 4 | Testes e validação | 30 min |
| **TOTAL** | | **2h 45min** |

---

## 9. PRÓXIMOS PASSOS

1. ✅ Executar SQL (coluna adicionada)
2. 🔄 Estender QrCodeGenerationService
3. 🔄 Integrar em cada service
4. 🔄 Criar widgets de exibição
5. 🔄 Testar geração e visualização
6. 🔄 Corrigir URLs duplicadas em contexto geral

---

**Status:** Pronto para implementação ✅
