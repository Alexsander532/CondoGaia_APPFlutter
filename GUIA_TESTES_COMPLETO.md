# 📋 Guia Completo de Testes - CondoGaia App

## 🎯 Visão Geral

Este guia descreve todos os testes que você pode fazer no seu app Flutter, organizados por:
1. **Tipo de teste** (integração, unidade, widget)
2. **Áreas funcionais** (ADMIN, Proprietário/Inquilino, Representante)
3. **Como rodar** cada um

---

## 🚀 Como Rodar Testes

### Teste de Integração (Device/Emulador)
```bash
# Rodar um teste específico
flutter test integration_test/login_flow_test.dart

# Rodar todos os testes de integração
flutter test integration_test

# Rodar em um emulador específico
flutter test integration_test --device-id=sdk_gphone64_x86_64
```

### Testes de Widget (sem device)
```bash
# Rodar todos os widget tests
flutter test test/

# Rodar um teste específico
flutter test test/widgets/login_screen_test.dart
```

### Testes de Unidade (puro Dart)
```bash
# Rodar testes unitários
flutter test test/unit/

# Com cobertura de código
flutter test --coverage
```

---

## 📱 ÁREA 1: LOGIN & AUTENTICAÇÃO

### ✅ Testes Disponíveis

#### 1.1 - Login do Representante
**Tipo:** Integração  
**Status:** ✅ Implementado  
**Arquivo:** `integration_test/login_flow_test.dart`

**O que testa:**
- Campo de email aceita entrada
- Campo de senha aceita entrada
- Botão "Entrar" funciona
- Credenciais válidas navegam para a home do Representante
- Splash screen aparece antes da tela de login

**Comando:**
```bash
flutter test integration_test/login_flow_test.dart
```

**Dados de teste:**
```
Email: alex@gmail.com
Senha: 123456
```

---

#### 1.2 - Login do Administrador
**Tipo:** Integração  
**Status:** 🔲 Sugerido  
**Próximos passos:**
- Validar email/senha do ADMIN
- Verificar navegação para ADMIN Home
- Testar logout

**Credenciais de teste:**
```
Email: admin@condogaia.com.br (ajustar conforme seu banco)
Senha: admin123
```

---

#### 1.3 - Login do Proprietário
**Tipo:** Integração  
**Status:** 🔲 Sugerido

**O que testar:**
- Login com credenciais de proprietário
- Redirecionamento para ProprietarioDashboard
- Visualização de unidades vinculadas

---

#### 1.4 - Login do Inquilino
**Tipo:** Integração  
**Status:** 🔲 Sugerido

**O que testar:**
- Login com credenciais de inquilino
- Redirecionamento para InquilinoDashboard
- Exibição de unidades alugadas

---

#### 1.5 - Validação de Email Inválido
**Tipo:** Widget Test  
**Status:** 🔲 Sugerido

**O que testar:**
- Campo rejeita email sem @
- Campo rejeita email sem domínio
- Mensagem de erro aparece
- Botão "Entrar" permanece desabilitado

---

#### 1.6 - Validação de Senha Vazia
**Tipo:** Widget Test  
**Status:** 🔲 Sugerido

**O que testar:**
- Botão "Entrar" desabilitado se senha vazia
- Mensagem de erro ao tentar enviar vazio
- Visibilidade da senha toggle

---

#### 1.7 - Auto-login Habilitado
**Tipo:** Integração  
**Status:** 🔲 Sugerido

**O que testar:**
- Checkbox "Login Automático" marca/desmarca
- Ao marcar, próximas vezes não pede credenciais
- Ao sair, limpa credenciais salvas

---

#### 1.8 - Erro de Conexão (sem internet)
**Tipo:** Integração  
**Status:** 🔲 Sugerido

**O que testar:**
- Mensagem de erro quando Supabase indisponível
- Botão "Tentar novamente" funciona
- Campo de email/senha permanece preenchido

---

## 🏢 ÁREA 2: ADMIN - Ambientes & Configuração

### ✅ Testes Disponíveis

#### 2.1 - Criar Ambiente
**Tipo:** Integração  
**Status:** 🔲 Sugerido

**O que testar:**
- Formulário de novo ambiente abre
- Preenche título, descrição, valor
- Ambiente aparece na listagem após salvar
- Validação obrigatória de campo title

**Passos:**
1. Login como ADMIN
2. Navegue para "Configurar Ambientes"
3. Clique em "Adicionar Ambiente"
4. Preencha: Título="Churrasqueira", Valor=R$ 200,00
5. Clique "Salvar"
6. Valide que aparece na lista

---

#### 2.2 - Upload de Termo de Locação (PDF)
**Tipo:** Integração  
**Status:** 🔲 Sugerido

**O que testar:**
- Botão de upload abre seletor de arquivo
- Arquivo PDF é enviado ao Supabase
- URL do PDF salva no ambiente
- Exibe nome do arquivo após upload
- Ao voltar para Reservas, termo aparece no modal

**Passos:**
1. Crie ou abra um ambiente existente
2. Clique "Adicionar Termo de Locação"
3. Selecione um PDF do dispositivo
4. Aguarde upload completar
5. Volte para Reservas (ReservasScreen vai recarregar)
6. Abra reserva → termo deve aparecer

**Nota importante:**
- Já corrigimos o reload: `await _carregarAmbientes()` após voltar de ConfigurarAmbientesScreen

---

#### 2.3 - Remover Termo de Locação
**Tipo:** Integração  
**Status:** ✅ Corrigido recentemente

**O que testar:**
- Clique no ícone ❌ ao lado do termo
- Botão "Salvar" atualiza o banco
- Termo desaparece da listagem
- Ao voltar para Reservas, termo não aparece mais

**Passos:**
1. Abra um ambiente com termo já salvo
2. Clique no ícone "X" vermelho (remover termo)
3. Mensagem "Termo removido" aparece
4. Clique "Salvar Alterações"
5. Volte para Reservas → recarrega e termo não aparece

**Implementação:**
- Backend: adicionado parâmetro `removerLocacao` em `AmbienteService.atualizarAmbiente()`
- Frontend: flag passa `true` quando `locacaoUrl == null && ambientes[index].locacaoUrl != null`

---

#### 2.4 - Editar Ambiente (valor, horário, etc)
**Tipo:** Integração  
**Status:** 🔲 Sugerido

**O que testar:**
- Clique em ambiente → modal de edição abre
- Mude valor (ex: R$ 200 → R$ 250)
- Mude limite horário (ex: 22h → 23h)
- Salve e volte para Reservas
- Valor atualizado aparece no card/modal de reserva

---

#### 2.5 - Marcar Dias Bloqueados
**Tipo:** Integração  
**Status:** 🔲 Sugerido

**O que testar:**
- Calendário permite selecionar múltiplos dias
- Dias selecionados aparecem destacados
- Ao tentar reservar em dia bloqueado, erro aparece
- Dias desbloqueados permitem reserva

---

#### 2.6 - Criar Blocos e Unidades
**Tipo:** Integração  
**Status:** 🔲 Sugerido

**O que testar:**
- Função `configurarCondominioCompleto()` cria 4 blocos com 6 unidades cada
- Unidades listadas em GestaoScreen organizadas por bloco
- Cada unidade tem numero único (A, B, C..., ou 1, 2, 3...)

---

## 🏠 ÁREA 3: PROPRIETÁRIO & INQUILINO

### 3.1 - Portaria Inquilino - Autorizar Visitante

#### 3.1.1 - Adicionar Autorizado
**Tipo:** Integração  
**Status:** 🔲 Sugerido

**O que testar:**
- Abra "Portaria Inquilino"
- Clique "Adicionar Autorizado"
- Preencha: nome, CPF, data início, data fim
- Clique "Salvar"
- Autorizado aparece na listagem
- Código QR foi gerado (gerado automático via `QrCodeGenerationService`)

**Dados de teste:**
```
Nome: João da Silva
CPF: 123.456.789-00
Início: 16/12/2025
Fim: 31/12/2025
```

---

#### 3.1.2 - Editar Autorizado
**Tipo:** Integração  
**Status:** 🔲 Sugerido

**O que testar:**
- Clique em autorizado → modal de edição
- Mude data de fim (ex: 31/12 → 10/01)
- Salve
- Listagem atualiza
- Código QR regenerado? (ou mantém original?)

---

#### 3.1.3 - Remover Autorizado
**Tipo:** Integração  
**Status:** 🔲 Sugerido

**O que testar:**
- Clique no ícone de deletar ao lado do autorizado
- Confirmação de remoção aparece
- Clique "Confirmar"
- Autorizado desaparece da lista
- Não pode mais usar esse QR para entrada

---

### 3.2 - Portaria Inquilino - Encomendas

#### 3.2.1 - Registrar Encomenda
**Tipo:** Integração  
**Status:** 🔲 Sugerido

**O que testar:**
- Abra aba "Encomendas"
- Clique "Nova Encomenda"
- Preencha: descrição, data entrega esperada, foto (opcional)
- Salve
- Encomenda aparece na listagem com status "Aguardando retirada"

---

#### 3.2.2 - Marcar Encomenda como Retirada
**Tipo:** Integração  
**Status:** 🔲 Sugerido

**O que testar:**
- Clique em encomenda pendente
- Botão "Marcar como Retirada" aparece
- Clique
- Status muda para "Retirada"
- Data de retirada é registrada

---

### 3.3 - Documentos

#### 3.3.1 - Visualizar Documento
**Tipo:** Integração  
**Status:** 🔲 Sugerido

**O que testar:**
- Abra "Documentos" (em Inquilino ou Representante)
- Lista de documentos aparece por pasta
- Clique em documento
- PDF abre no visualizador (flutter_pdfview)
- Pode navegar páginas, fazer zoom

---

#### 3.3.2 - Filtrar Documentos
**Tipo:** Integração  
**Status:** 🔲 Sugerido

**O que testar:**
- Campo de busca filtra por nome
- Apenas documentos com o termo aparecem
- Campo vazio mostra todos novamente

---

### 3.4 - Agenda/Eventos

#### 3.4.1 - Criar Evento na Agenda
**Tipo:** Integração  
**Status:** 🔲 Sugerido

**O que testar:**
- Abra "Agenda"
- Clique em dia do calendário
- Modal de novo evento abre
- Preencha: título, hora, descrição
- Salve
- Evento aparece no calendário naquele dia
- Clique no evento → detalhes aparecem

---

#### 3.4.2 - Editar Evento
**Tipo:** Integração  
**Status:** 🔲 Sugerido

**O que testar:**
- Clique em evento existente
- Mude título/hora/descrição
- Salve
- Calendário atualiza
- Eventos em dia diferente são movidos corretamente

---

## 👥 ÁREA 4: REPRESENTANTE

### 4.1 - Portaria Representante

#### 4.1.1 - Cadastrar Visitante
**Tipo:** Integração  
**Status:** 🔲 Sugerido (+ feature importante)

**O que testar:**
- Abra "Portaria"
- Clique "Adicionar Visitante"
- Preencha: nome, CPF, unidade de destino, data/hora entrada
- Clique "Salvar"
- ✅ **Feature auto-registro:** Entrada registrada automaticamente em `historico_acessos`
- Visitante aparece na listagem
- Código QR gerado

**Dados de teste:**
```
Nome: Maria dos Santos
CPF: 987.654.321-00
Unidade: Bloco A, Apto 101
Data/Hora: 16/12/2025 14:30
```

**Validação importante:**
- Verificar que `visitante_portaria_service.insertVisitante()` chama `historicoService.registrarEntrada()` automaticamente
- Ver em `historico_acessos` novo registro com `tipo='entrada'`

---

#### 4.1.2 - Registrar Saída de Visitante
**Tipo:** Integração  
**Status:** 🔲 Sugerido

**O que testar:**
- Visitante já cadastrado aparece em "Visitantes Presentes"
- Clique no visitante
- Botão "Registrar Saída" aparece
- Clique
- Entrada em `historico_acessos` é finalizada (saída registrada)
- Visitante move para "Visitantes Saídos"

---

#### 4.1.3 - Autorizar Acesso por QR
**Tipo:** Integração  
**Status:** 🔲 Sugerido

**O que testar:**
- Visitante já cadastrado tem QR code
- Escaneie QR (simule ou use câmera em device real)
- Sistema valida QR
- Se válido: registra entrada automática
- Se expirado: erro "QR expirado" ou similar

---

### 4.2 - Conversas/Chat

#### 4.2.1 - Abrir Lista de Conversas
**Tipo:** Integração  
**Status:** 🔲 Sugerido

**O que testar:**
- Abra "Mensagens"
- Lista de conversas aparece
- Cada conversa mostra: avatar, nome, última mensagem, data
- Ordenação por mensagem mais recente (top)

---

#### 4.2.2 - Enviar Mensagem
**Tipo:** Integração  
**Status:** 🔲 Sugerido

**O que testar:**
- Abra conversa
- Campo de mensagem aparece
- Digita mensagem
- Clica enviar ou pressiona "Enter"
- Mensagem aparece no chat com seu avatar
- Timestamp é registrado

---

#### 4.2.3 - Receber Mensagem (Real-time)
**Tipo:** Integração  
**Status:** 🔲 Sugerido

**O que testar:**
- Abra chat em dois dispositivos/emuadores (ou outro usuário)
- Envie mensagem de um lado
- Outro lado vê mensagem em tempo real
- Validar que Supabase realtime está funcionando

---

### 4.3 - Gestão (Unidades/Moradores)

#### 4.3.1 - Visualizar Unidades
**Tipo:** Integração  
**Status:** 🔲 Sugerido

**O que testar:**
- Abra "Gestão"
- Unidades aparecem organizadas por bloco
- Clique em unidade → detalhes (nome, bloco, moradores, etc)

---

#### 4.3.2 - Adicionar Morador à Unidade
**Tipo:** Integração  
**Status:** 🔲 Sugerido

**O que testar:**
- Abra unidade
- Clique "Adicionar Morador"
- Selecione proprietário da lista
- Clique "Confirmar"
- Morador aparece na unidade
- Pode visualizar documentos/agenda da unidade agora

---

### 4.4 - Reservas

#### 4.4.1 - Criar Reserva
**Tipo:** Integração  
**Status:** 🔲 Sugerido

**O que testar:**
- Abra "Reservas"
- Clique em dia no calendário
- Modal de nova reserva abre
- Selecione: Local (ambiente), Hora Início, Hora Fim
- Valide que: Hora Fim > Hora Início
- Valide que: Data é futura
- Aceite termo de locação (checkbox)
- Clique "Reservar"
- Reserva aparece no calendário com marcador
- Card de reserva exibe informações

**Validações importantes:**
```
- Hora Fim deve ser DEPOIS de Hora Início
- Não pode reservar data passada (validado com timezone de Brasília)
- Termo de locação obrigatório se houver
- Lista de presentes é opcional (JSON ou texto)
```

---

#### 4.4.2 - Editar Reserva
**Tipo:** Integração  
**Status:** 🔲 Sugerido

**O que testar:**
- Clique em reserva existente (card azul)
- Modal de edição abre
- Mude horário/ambiente
- Salve
- Calendário atualiza
- Card reflete mudanças

---

#### 4.4.3 - Deletar Reserva
**Tipo:** Integração  
**Status:** 🔲 Sugerido

**O que testar:**
- Clique em reserva
- Botão "Excluir" aparece
- Confirmação dialogo aparece
- Clique "Deletar"
- Reserva desaparece do calendário e lista

---

#### 4.4.4 - Upload de Lista de Presentes
**Tipo:** Integração  
**Status:** 🔲 Sugerido

**O que testar:**
- Ao criar/editar reserva, clique "Carregar Arquivo"
- Selecione arquivo Excel (.xlsx, .xls)
- Nomes são lidos e parseados
- Campo "Lista de Presentes" preenchido com nomes numerados
- Salve reserva
- Lista de presentes mantém ordem

**Dados esperados:**
- Arquivo Excel com coluna de nomes
- ExcelService lê e converte para `List<String>`
- JSON salvo em `reservas.lista_presentes`

---

## 📊 ÁREA 5: TESTES UNITÁRIOS (SERVICES)

### 5.1 - AuthService

#### 5.1.1 - Login válido retorna LoginResult
**Tipo:** Unit Test  
**Status:** 🔲 Sugerido

```dart
test('login com credenciais válidas retorna sucesso', () async {
  final result = await authService.login('alex@gmail.com', '123456', false);
  
  expect(result.success, true);
  expect(result.userType, UserType.representante);
  expect(result.representante, isNotNull);
});
```

---

#### 5.1.2 - Login inválido retorna erro
**Tipo:** Unit Test  
**Status:** 🔲 Sugerido

```dart
test('login com senha errada retorna erro', () async {
  final result = await authService.login('alex@gmail.com', 'senhaerrada', false);
  
  expect(result.success, false);
  expect(result.errorMessage, contains('Senha'));
});
```

---

### 5.2 - UnidadeService

#### 5.2.1 - Buscar unidades por termo
**Tipo:** Unit Test  
**Status:** 🔲 Sugerido

```dart
test('buscarUnidades filtra por número corretamente', () async {
  final resultados = await unidadeService.buscarUnidades(
    condominioId: 'condo-123',
    termo: '101'
  );
  
  expect(resultados.isNotEmpty, true);
  expect(resultados[0].unidades.any((u) => u.numero.contains('101')), true);
});
```

---

### 5.3 - ReservaService

#### 5.3.1 - Validar regras de horário
**Tipo:** Unit Test  
**Status:** 🔲 Sugerido

```dart
test('não permite hora_fim anterior à hora_inicio', () async {
  expect(
    () => reservaService.criarReserva(
      representanteId: 'rep-1',
      ambienteId: 'amb-1',
      dataReserva: DateTime.now().add(Duration(days: 1)),
      horaInicio: '14:00',
      horaFim: '13:00', // Antes da inicial
      valorLocacao: 100,
      ...
    ),
    throwsException,
  );
});
```

---

## 🎬 ROTEIRO DE TESTES PROGRESSIVOS

### Phase 1: Smoke Tests (Sem falhar)
```
1. Login Representante ✅ (já implementado)
2. Login ADMIN 🔲
3. Login Prop/Inq 🔲
4. Navegar para Portaria 🔲
5. Navegar para Reservas 🔲
```

### Phase 2: Fluxos Críticos
```
1. Criar e remover ambiente 🔲
2. Cadastrar visitante (com auto-registro) 🔲
3. Criar reserva 🔲
4. Upload PDF de termo 🔲 (valide o recarregamento)
```

### Phase 3: Edge Cases
```
1. Tentar reservar em dia bloqueado 🔲
2. Tentar reservar com hora_fim <= hora_inicio 🔲
3. Remover termo e validar remoção 🔲
4. Upload de arquivo grande (>10MB) 🔲
```

---

## 📝 Checklist de Implementação

### Para Começar
- [ ] Rodar `flutter test integration_test/login_flow_test.dart` com sucesso
- [ ] Preparar credenciais de staging (ADMIN, Prop, Inq)
- [ ] Documentar quais endpoints/tabelas você quer testar prioridade

### Próximos Testes
- [ ] 2.1 - Criar Ambiente
- [ ] 2.2 - Upload de Termo (validar recarregamento)
- [ ] 2.3 - Remover Termo (validar nulificação no BD)
- [ ] 4.1.1 - Cadastrar Visitante (validar auto-registro em histórico)
- [ ] 4.4.1 - Criar Reserva (com validações)

---

## 🔧 Dicas Técnicas

### Waits & Timeouts
```dart
// Aguarda elemento aparecer (até 5 segundos)
await tester.pumpAndSettle(Duration(seconds: 5));

// Aguarda por widget específico
await tester.pumpWidget(MyApp());
await tester.pumpAndSettle();

// Timeout customizado
expect(find.byKey(key), findsOneWidget, timeout: Duration(seconds: 10));
```

### Mock de Supabase (Futuro)
Para testes sem device, considere mockar Supabase:
```dart
// Instalado: mockito, fake_cloud_firestore (ou similar para Supabase)
final mockSupabaseClient = MockSupabaseClient();
when(mockSupabaseClient.from('ambientes').select())
  .thenReturn(Future.value([...]));
```

### Screenshots/Golden Tests (Futuro)
```dart
await tester.binding.window.physicalSizeTestValue = Size(1080, 1920);
addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

await expectLater(
  find.byType(LoginScreen),
  matchesGoldenFile('golden/login_screen.png'),
);
```

---

## 📞 Próximos Passos

1. **Escolha 3 testes** da lista acima para implementar primeiro
2. **Prepare dados de staging** (credenciais, condominios, ambientes)
3. **Comunique** qual suite priorizar (ADMIN → Representante → Proprietário)

Qual deles quer que eu implemente agora?
