# Feature de Gestão de Email - Documentação Completa

## Visão Geral

A feature de **Gestão de Email** permite que o representante do condomínio envie comunicações formais para moradores (proprietários e inquilinos) através de emails. O sistema suporta diferentes tipos de comunicação, modelos salvos e anexos.

---

## 1. Regra de Negócio

### 1.1 Tipos de Tópicos/Comunicações

O sistema suporta **7 tipos de tópicos** para comunicação:

| Tópico | Descrição | Observação |
|--------|-----------|------------|
| **Cobrança** | Comunicações relacionadas a pagamentos | Padrão do sistema |
| **Comunicado** | Avisos gerais do condomínio | - |
| **Assembleia** | Convocações e informações de assembleias | - |
| **Advertência** | Advertências formais | Gravado no relatório da unidade |
| **Multa** | Notificações de multa | Gravado no relatório da unidade |
| **Convite Perfil** | Convites para acesso ao app | - |
| **Termo C. D. (acordo)** | Termos de compromisso de débito | - |

### 1.2 Destinatários

Os destinatários são divididos em **3 categorias**:

- **P (Proprietário)**: Donos das unidades
- **I (Inquilino)**: Moradores locatários
- **T (Tenant)**: Variante de inquilino

**Filtros disponíveis**:
- `TODOS`: Exibe todos os destinatários
- `PROPRIETARIOS`: Apenas proprietários (tipo P)
- `INQUILINOS`: Apenas inquilinos (tipo I ou T)

### 1.3 Modelos de Email

- Cada condomínio pode criar **modelos salvos** para reutilização
- Modelos são **associados a um tópico específico**
- Ao selecionar um tópico, os modelos daquele tópico são carregados automaticamente
- Campos do modelo: `titulo`, `assunto`, `corpo`

### 1.4 Anexos

- Suporte a **anexos de imagem** (JPEG, PNG, etc.)
- **Limite máximo**: 5MB por arquivo
- Anexos são convertidos para **Base64** para envio
- Funciona em **mobile e web** (cross-platform)

### 1.5 Fluxo de Envio

1. Representante seleciona o **tópico**
2. Opcionalmente seleciona um **modelo salvo**
3. Preenche **assunto** e **corpo** do email
4. Opcionalmente anexa uma **imagem**
5. **Filtra e seleciona destinatários**
6. Clica em **Enviar Email**

---

## 2. Implementação Flutter

### 2.1 Arquitetura

A feature segue o padrão **BLoC/Cubit** com a seguinte estrutura:

```
lib/features/Representante_Features/email_gestao/
├── cubit/
│   ├── email_gestao_cubit.dart      # Lógica de estado
│   └── email_gestao_state.dart      # Estados
├── models/
│   ├── recipient_model.dart         # Modelo de destinatário
│   ├── email_modelo_model.dart      # Modelo de template
│   └── email_attachment_model.dart  # Modelo de anexo
├── screens/
│   └── email_gestao_screen.dart     # UI principal
├── services/
│   └── email_gestao_service.dart    # Serviço de dados
└── widgets/
    └── recipient_table_widget.dart  # Tabela de destinatários
```

### 2.2 Estados (State Management)

```dart
// Estados definidos em email_gestao_state.dart

abstract class EmailGestaoState extends Equatable {}

class EmailGestaoInitial extends EmailGestaoState {}    // Estado inicial
class EmailGestaoLoading extends EmailGestaoState {}    // Carregando
class EmailGestaoLoaded extends EmailGestaoState {}     // Dados carregados
class EmailGestaoSuccess extends EmailGestaoState {}    // Sucesso
class EmailGestaoError extends EmailGestaoState {}      // Erro
```

**Estado principal (`EmailGestaoLoaded`)**:
- `allRecipients`: Lista completa de destinatários
- `filteredRecipients`: Destinatários filtrados (paginação)
- `selectedTopic`: Tópico selecionado (padrão: 'Cobrança')
- `modelos`: Modelos salvos do tópico
- `modeloSelecionado`: Modelo atualmente selecionado
- `attachment`: Anexo de imagem
- `isSending`: Flag de envio em progresso
- `page`: Página atual (paginação)

### 2.3 Cubit (Lógica de Negócio)

**Métodos principais do `EmailGestaoCubit`**:

| Método | Função |
|--------|--------|
| `loadRecipients()` | Carrega destinatários do Supabase |
| `updateTopic()` | Altera tópico e recarrega modelos |
| `updateFilterText()` | Filtra por nome/unidade |
| `updateRecipientFilterType()` | Filtra por tipo (P/I/T) |
| `toggleRecipientSelection()` | Seleciona/desseleciona destinatário |
| `toggleAllSelection()` | Seleciona/desseleciona todos |
| `attachBytes()` | Anexa arquivo (bytes) |
| `removeAttachment()` | Remove anexo |
| `carregarModelos()` | Carrega modelos do tópico |
| `salvarModelo()` | Salva novo modelo no Supabase |
| `excluirModelo()` | Exclui modelo |
| `sendEmail()` | Envia email via Laravel API |

### 2.4 Service (Camada de Dados)

**`EmailGestaoService`** - Responsável por:

1. **Buscar destinatários** (`fetchRecipients`):
   - Consulta tabela `unidades` (ativas)
   - Consulta tabela `proprietarios`
   - Consulta tabela `inquilinos`
   - Combina dados em `RecipientModel`

2. **CRUD de modelos** (`fetchModelos`, `salvarModelo`, `excluirModelo`):
   - Tabela Supabase: `email_modelos`
   - Campos: `condominio_id`, `topico`, `titulo`, `assunto`, `corpo`

3. **Envio de emails** (`sendEmail`, `enviarCircular`, `enviarAviso`, `enviarEmMassa`):
   - Envia payload para Laravel API
   - Endpoints: `/resend/gestao/circular`, `/resend/gestao/aviso`, `/resend/gestao/em-massa`

### 2.5 Models

**RecipientModel**:
```dart
class RecipientModel {
  final String id;
  final String name;
  final String type;        // 'P', 'I', 'T'
  final String unitBlock;   // "102 / B"
  final String email;
  final bool isSelected;
  final String? block;
  final String? unit;
}
```

**EmailModeloModel**:
```dart
class EmailModeloModel {
  final String id;
  final String condominioId;
  final String topico;
  final String titulo;
  final String assunto;
  final String corpo;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
}
```

**EmailAttachmentModel**:
```dart
class EmailAttachmentModel {
  final Uint8List bytes;      // Conteúdo binário (cross-platform)
  final String filename;      // Nome do arquivo
  final String mimeType;      // MIME type
  final int sizeBytes;        // Tamanho
  
  String toBase64();          // Conversão para envio
  bool get isValidSize;       // Validação (max 5MB)
  Map<String, dynamic> toJsonPayload();  // Formato para API
}
```

### 2.6 UI (Screen)

**`EmailGestaoScreen`** - Componentes principais:

1. **Dropdown de Tópico**: Seleção do tipo de comunicação
2. **Dropdown de Modelos**: Modelos salvos (se existirem)
3. **Campo de Assunto**: Input de texto
4. **Campo de Corpo**: Textarea para mensagem
5. **Botão Salvar Modelo**: Salva template atual
6. **Anexar Foto**: File picker para imagens
7. **Barra de Pesquisa**: Filtro por nome/unidade
8. **Dropdown de Filtro**: TODOS/PROPRIETARIOS/INQUILINOS
9. **Tabela de Destinatários**: Com checkboxes
10. **Botão Enviar Email**: Dispara envio

---

## 3. Integração com Resend (Backend)

### 3.1 Arquitetura de Comunicação

```
┌─────────────┐     HTTP POST      ┌─────────────┐     Resend API     ┌─────────────┐
│   Flutter   │ ───────────────>  │   Laravel   │ ───────────────>  │   Resend    │
│    App      │    /resend/...     │    API      │                    │   Service  │
└─────────────┘                    └─────────────┘                    └─────────────┘
```

### 3.2 LaravelApiService

Serviço singleton que gerencia comunicação com o backend Laravel:

```dart
class LaravelApiService {
  // URL base: do .env ou fallback local
  String get _baseUrl => dotenv.env['LARAVEL_API_URL'] ?? 'http://127.0.0.1:8000/api';
  
  // Autenticação: Bearer token (Laravel Sanctum)
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken(); // SharedPreferences
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}
```

### 3.3 Endpoints de Email

| Endpoint | Função | Service |
|----------|--------|---------|
| `POST /resend/gestao/circular` | Enviar circular | `EmailGestaoService` |
| `POST /resend/gestao/aviso` | Enviar aviso | `EmailGestaoService` |
| `POST /resend/gestao/em-massa` | Envio em massa | `EmailGestaoService` |
| `POST /resend/notificacao/atraso` | Notificar atraso | `NotificacaoEmailService` |
| `POST /resend/notificacao/leitura` | Notificar leitura | `NotificacaoEmailService` |
| `POST /resend/notificacao/reserva` | Notificar reserva | `NotificacaoEmailService` |
| `POST /resend/cobranca/confirmacao` | Confirmar pagamento | `CobrancaEmailService` |
| `POST /resend/cobranca/recibo` | Enviar recibo | `CobrancaEmailService` |

### 3.4 Payload de Envio

**Exemplo de payload para `/resend/gestao/circular`**:

```json
{
  "subject": "Assunto do Email",
  "body": "Corpo da mensagem...",
  "topic": "Cobrança",
  "condominioNome": "CondoGaia",
  "recipients": [
    {
      "email": "morador@email.com",
      "name": "João Silva",
      "type": "P"
    }
  ],
  "attachment": {
    "filename": "comunicado.jpg",
    "content": "base64_encoded_content..."
  }
}
```

### 3.5 Outros Services de Email

Além do `EmailGestaoService`, existem outros serviços especializados:

**NotificacaoEmailService**:
- `notificarAtraso()`: Aviso de pagamento em atraso
- `notificarLeitura()`: Confirmação de leitura de medidores
- `notificarReserva()`: Status de reserva de ambiente

**CobrancaEmailService**:
- `enviarConfirmacao()`: Confirmação de pagamento
- `enviarRecibo()`: Recibo digital

---

## 4. Fluxo de Dados

```
┌──────────────────────────────────────────────────────────────────────────┐
│                           FLUXO DE ENVIO                                  │
└──────────────────────────────────────────────────────────────────────────┘

1. USUÁRIO
   │
   ├─> Seleciona tópico (dropdown)
   ├─> Seleciona modelo (opcional)
   ├─> Preenche assunto e corpo
   ├─> Anexa imagem (opcional)
   ├─> Filtra e seleciona destinatários
   └─> Clica em "Enviar Email"
         │
         ▼
2. EMAIL_GESTAO_CUBIT (sendEmail)
   │
   ├─> Valida destinatários selecionados
   ├─> Emite estado isSending: true
   └─> Chama EmailGestaoService.sendEmail()
         │
         ▼
3. EMAIL_GESTAO_SERVICE (sendEmail → enviarCircular)
   │
   ├─> Monta payload JSON
   ├─> Converte anexo para Base64 (se existir)
   └─> Chama LaravelApiService.post('/resend/gestao/circular', payload)
         │
         ▼
4. LARAVEL_API_SERVICE
   │
   ├─> Obtém token de autenticação
   ├─> Monta headers HTTP
   └─> Executa POST request
         │
         ▼
5. BACKEND LARAVEL
   │
   ├─> Recebe e valida payload
   ├─> Processa lista de destinatários
   ├─> Chama API do Resend
   └─> Retorna status HTTP
         │
         ▼
6. RESPOSTA
   │
   ├─> Sucesso (200): Emite EmailGestaoSuccess
   └─> Erro: Emite EmailGestaoError
```

---

## 5. Armazenamento de Dados

### 5.1 Supabase (Tabelas)

**Tabela `email_modelos`**:
| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id` | UUID | ID único |
| `condominio_id` | UUID | FK para condomínio |
| `topico` | VARCHAR | Tópico do email |
| `titulo` | VARCHAR | Nome do modelo |
| `assunto` | TEXT | Assunto padrão |
| `corpo` | TEXT | Corpo padrão |
| `criado_em` | TIMESTAMP | Data de criação |
| `atualizado_em` | TIMESTAMP | Data de atualização |

**Tabelas de destinatários**:
- `unidades`: Dados das unidades (bloco, número)
- `proprietarios`: Dados dos proprietários
- `inquilinos`: Dados dos inquilinos

### 5.2 SharedPreferences

- `laravel_token`: Token de autenticação Sanctum

---

## 6. Dependências Flutter

```yaml
dependencies:
  flutter_bloc: ^8.x.x    # Gerenciamento de estado
  equatable: ^2.x.x        # Comparação de estados
  supabase_flutter: ^2.x.x # Cliente Supabase
  http: ^1.x.x             # Requisições HTTP
  flutter_dotenv: ^5.x.x   # Variáveis de ambiente
  shared_preferences: ^2.x.x # Armazenamento local
  file_picker: ^6.x.x      # Seletor de arquivos
```

---

## 7. Considerações Técnicas

### 7.1 Cross-Platform

- **Anexos**: Usam `Uint8List` em vez de `dart:io File` para funcionar em mobile e web
- **FilePicker**: Configurado com `withData: true` para garantir bytes

### 7.2 Paginação

- Destinatários carregados em lotes de 10
- Botão "Carregar mais" para paginação infinita

### 7.3 Validações

- Anexos limitados a 5MB
- Campos obrigatórios: título, assunto, corpo (para salvar modelo)
- Pelo menos um destinatário deve ser selecionado para envio

---

## 8. Arquivos Relacionados

| Arquivo | Caminho |
|---------|---------|
| Cubit | `lib/features/Representante_Features/email_gestao/cubit/email_gestao_cubit.dart` |
| State | `lib/features/Representante_Features/email_gestao/cubit/email_gestao_state.dart` |
| Service | `lib/features/Representante_Features/email_gestao/services/email_gestao_service.dart` |
| Screen | `lib/features/Representante_Features/email_gestao/screens/email_gestao_screen.dart` |
| RecipientModel | `lib/features/Representante_Features/email_gestao/models/recipient_model.dart` |
| EmailModeloModel | `lib/features/Representante_Features/email_gestao/models/email_modelo_model.dart` |
| EmailAttachmentModel | `lib/features/Representante_Features/email_gestao/models/email_attachment_model.dart` |
| LaravelApiService | `lib/services/laravel_api_service.dart` |
| NotificacaoEmailService | `lib/features/Representante_Features/notificacao/services/notificacao_email_service.dart` |
| CobrancaEmailService | `lib/features/Representante_Features/cobranca/services/cobranca_email_service.dart` |
