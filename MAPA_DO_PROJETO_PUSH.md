# 🗺️ MAPA DO PROJETO - Push Notification Feature

## 📍 Localização dos Arquivos

### ✅ Arquivos Criados

```
lib/features/push_notification_admin/
├── models/
│   ├── localizacao_model.dart              ← Estados e Cidades
│   ├── morador_model.dart                  ← Morador
│   └── push_notification_model.dart        ← Notificação Push
├── services/
│   └── push_notification_service.dart      ← Lógica + Dados Mockados
├── widgets/
│   ├── campo_titulo.dart                   ← Input Title
│   ├── campo_mensagem.dart                 ← TextArea Message
│   ├── checkbox_sindicatos_moradores.dart  ← Checkboxes
│   ├── seletor_moradores.dart              ← Selector with Search
│   ├── seletor_uf_cidade.dart              ← Cascading Dropdowns
│   └── botao_enviar.dart                   ← Submit Button
└── screens/
    └── push_notification_admin_screen.dart ← Main Screen
```

### ✅ Arquivo Modificado

```
lib/screens/ADMIN/
└── home_screen.dart                        ← MODIFICADO (integração)
```

### 📚 Documentação Criada

```
DOCUMENTACAO_FEATURE_PUSH.md                ← Documentação técnica
GUIA_USO_PUSH_NOTIFICATION.md               ← Guia de uso
RESUMO_FEATURE_PUSH.md                      ← Sumário rápido
SUMARIO_EXECUTIVO_PUSH.md                   ← Executivo
MAPA_VISUAL_PUSH.txt                        ← Estrutura visual
MAPA_DO_PROJETO_PUSH.md                     ← Este arquivo
```

---

## 🔗 Dependências Entre Arquivos

```
push_notification_admin_screen.dart
├── Importa models/
│   ├── push_notification_model.dart
│   ├── morador_model.dart
│   └── localizacao_model.dart
├── Importa services/
│   └── push_notification_service.dart
└── Importa widgets/
    ├── campo_titulo.dart
    ├── campo_mensagem.dart
    ├── checkbox_sindicatos_moradores.dart
    ├── seletor_moradores.dart
    ├── seletor_uf_cidade.dart
    └── botao_enviar.dart

seletor_moradores.dart
├── Importa models/
│   └── morador_model.dart
└── Importa services/
    └── push_notification_service.dart

seletor_uf_cidade.dart
├── Importa models/
│   └── localizacao_model.dart
└── Importa services/
    └── push_notification_service.dart

home_screen.dart
└── Importa screens/
    └── push_notification_admin_screen.dart
```

---

## 📊 Fluxo de Dados

```
home_screen.dart
    │
    └─ [Clique em "Push"]
        │
        └─ Navega para PushNotificationAdminScreen
            │
            ├─ Carrega CampoTitulo
            ├─ Carrega CampoMensagem
            ├─ Carrega CheckboxSindicatos
            ├─ Carrega SeletorMoradores
            │   └─ Chama push_notification_service.obterMoradores()
            ├─ Carrega SeletorUfCidade
            │   ├─ Chama push_notification_service.obterEstados()
            │   └─ Chama push_notification_service.obterCidadesPorEstado()
            └─ Carrega BotaoEnviar
                │
                └─ [Clique em "ENVIAR"]
                    │
                    ├─ Valida com service.validarNotificacao()
                    ├─ Mostra confirmação
                    └─ Chama service.enviarNotificacao()
                        │
                        └─ Mostra resultado
```

---

## 🎯 Como Usar Each File

### Models

**localizacao_model.dart**
```dart
import 'package:condogaiaapp/features/push_notification_admin/models/localizacao_model.dart';

// Usar EstadoModel
EstadoModel sp = EstadoModel(sigla: 'SP', nome: 'São Paulo');

// Usar CidadeModel
CidadeModel saoPaulo = CidadeModel(id: 1, nome: 'São Paulo', estadoSigla: 'SP');
```

**morador_model.dart**
```dart
import 'package:condogaiaapp/features/push_notification_admin/models/morador_model.dart';

// Criar morador
MoradorModel joao = MoradorModel(
  id: '1',
  nome: 'João Silva',
  unidade: '101',
  bloco: 'A',
);

// Usar copyWith
MoradorModel joaoSelecionado = joao.copyWith(selecionado: true);
```

**push_notification_model.dart**
```dart
import 'package:condogaiaapp/features/push_notification_admin/models/push_notification_model.dart';

// Criar notificação
PushNotificationModel notificacao = PushNotificationModel(
  titulo: 'Teste',
  mensagem: 'Mensagem de teste',
);

// Verificar se está completa
if (notificacao.estaCompleta) {
  // Enviar
}
```

### Service

**push_notification_service.dart**
```dart
import 'package:condogaiaapp/features/push_notification_admin/services/push_notification_service.dart';

final service = PushNotificationService();

// Obter estados
final estados = await service.obterEstados();

// Obter cidades
final cidades = await service.obterCidadesPorEstado('SP');

// Obter moradores
final moradores = await service.obterMoradores(filtro: 'João');

// Validar
final erros = service.validarNotificacao(
  titulo: titulo,
  mensagem: mensagem,
  sindicosInclusos: true,
  moradoresSelecionados: [],
  estadoSelecionado: estado,
  cidadeSelecionada: cidade,
);

// Enviar
final sucesso = await service.enviarNotificacao(...);
```

### Widgets

**campo_titulo.dart**
```dart
import 'package:condogaiaapp/features/push_notification_admin/widgets/campo_titulo.dart';

CampoTitulo(
  controller: _tituloController,
  onChanged: (value) => print('Título: $value'),
  validator: (value) {
    if (value?.isEmpty ?? true) return 'Obrigatório';
    return null;
  },
)
```

**seletor_moradores.dart**
```dart
import 'package:condogaiaapp/features/push_notification_admin/widgets/seletor_moradores.dart';

SeletorMoradores(
  moradoresSelecionados: _moradoresSelecionados,
  onChanged: (moradores) {
    setState(() => _moradoresSelecionados = moradores);
  },
)
```

**seletor_uf_cidade.dart**
```dart
import 'package:condogaiaapp/features/push_notification_admin/widgets/seletor_uf_cidade.dart';

SeletorUfCidade(
  estadoSelecionado: _estado,
  cidadeSelecionada: _cidade,
  onEstadoChanged: (estado) {
    setState(() => _estado = estado);
  },
  onCidadeChanged: (cidade) {
    setState(() => _cidade = cidade);
  },
)
```

**botao_enviar.dart**
```dart
import 'package:condogaiaapp/features/push_notification_admin/widgets/botao_enviar.dart';

BotaoEnviar(
  onPressed: () => _enviarNotificacao(),
  carregando: _carregando,
  desabilitado: !_formularioValido,
  texto: 'ENVIAR',
)
```

### Screen

**push_notification_admin_screen.dart**
```dart
import 'package:condogaiaapp/features/push_notification_admin/screens/push_notification_admin_screen.dart';

// Navegar
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => const PushNotificationAdminScreen(),
  ),
);
```

---

## 🔄 Fluxo Completo de Exemplo

```
1. HomeScreen exibe botão "Push"
   ↓
2. Usuário clica em "Push"
   ↓
3. HomeScreen navega para PushNotificationAdminScreen
   ↓
4. PushNotificationAdminScreen carrega:
   - Campos do formulário
   - Chama service.obterEstados()
   - Carrega SeletorMoradores que chama service.obterMoradores()
   ↓
5. Usuário preenche formulário
   ↓
6. Usuário clica "ENVIAR"
   ↓
7. PushNotificationAdminScreen chama service.validarNotificacao()
   ↓
8. Se OK, mostra diálogo de confirmação
   ↓
9. Usuário clica "Confirmar"
   ↓
10. PushNotificationAdminScreen chama service.enviarNotificacao()
    ↓
11. Mostra loading (2 segundos)
    ↓
12. Mostra sucesso
    ↓
13. Limpa formulário
    ↓
14. Volta para HomeScreen
```

---

## 🎯 Estrutura de Pastas Comparativa

### Antes
```
lib/screens/ADMIN/
└── home_screen.dart (TODO: Navegar para push)
```

### Depois
```
lib/
├── features/
│   └── push_notification_admin/
│       ├── models/ (3 arquivos)
│       ├── services/ (1 arquivo)
│       ├── widgets/ (6 arquivos)
│       └── screens/ (1 arquivo)
└── screens/ADMIN/
    └── home_screen.dart (MODIFICADA - Integrada)
```

---

## 🔍 Como Navegar no Código

### Adicionar Nova Feature Similar
1. Copie `lib/features/push_notification_admin/`
2. Renomeie para sua nova feature
3. Adapte models, service, widgets
4. Crie nova screen
5. Integre na tela pai

### Modificar Validações
Arquivo: `lib/features/push_notification_admin/services/push_notification_service.dart`
Método: `validarNotificacao()`

### Adicionar Novo Campo
1. Crie widget em `lib/features/push_notification_admin/widgets/`
2. Adicione campo ao `PushNotificationModel`
3. Integre na `push_notification_admin_screen.dart`
4. Atualize validações no service

### Modificar Dados Mockados
Arquivo: `lib/features/push_notification_admin/services/push_notification_service.dart`
Listas: `_estados`, `_cidadesPorEstado`, `_moradores`

---

## 📊 Importações Necessárias

```dart
// Models
import 'package:condogaiaapp/features/push_notification_admin/models/localizacao_model.dart';
import 'package:condogaiaapp/features/push_notification_admin/models/morador_model.dart';
import 'package:condogaiaapp/features/push_notification_admin/models/push_notification_model.dart';

// Services
import 'package:condogaiaapp/features/push_notification_admin/services/push_notification_service.dart';

// Widgets
import 'package:condogaiaapp/features/push_notification_admin/widgets/campo_titulo.dart';
import 'package:condogaiaapp/features/push_notification_admin/widgets/campo_mensagem.dart';
import 'package:condogaiaapp/features/push_notification_admin/widgets/checkbox_sindicatos_moradores.dart';
import 'package:condogaiaapp/features/push_notification_admin/widgets/seletor_moradores.dart';
import 'package:condogaiaapp/features/push_notification_admin/widgets/seletor_uf_cidade.dart';
import 'package:condogaiaapp/features/push_notification_admin/widgets/botao_enviar.dart';

// Screens
import 'package:condogaiaapp/features/push_notification_admin/screens/push_notification_admin_screen.dart';
```

---

## ✅ Checklist de Verificação

- [x] Estrutura de pastas criada
- [x] Todos os arquivos no lugar
- [x] Imports corretos
- [x] Sem erros de compilação
- [x] HomeScreen integrada
- [x] Documentação completa
- [x] Exemplos de uso
- [x] Pronto para testes

---

**🎉 Tudo pronto para navegar e usar!**
