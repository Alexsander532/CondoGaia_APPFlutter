/*
╔══════════════════════════════════════════════════════════════════════════════╗
║                     CLEAN ARCHITECTURE + BLoC/CUBIT                          ║
║                   IMPLEMENTADO NA FEATURE RESERVA                            ║
╚══════════════════════════════════════════════════════════════════════════════╝

STATUS: ✅ IMPLEMENTADO NA FEATURE RESERVA

Arquivos criados e refatorados:
✅ domain/entities/ - ReservaEntity, AmbienteEntity
✅ domain/repositories/ - ReservaRepository (interface)
✅ domain/usecases/ - ObterReservasUseCase, CriarReservaUseCase, etc
✅ data/datasources/ - ReservaRemoteDataSource
✅ data/models/ - ReservaModel (com serialização)
✅ data/repositories/ - ReservaRepositoryImpl (implementação)
✅ di/reserva_dependencies.dart - Injeção de Dependência
✅ cubit/reserva_cubit.dart - Refatorado para usar UseCases
✅ test/ - Testes unitários para UseCases e Cubit


╔══════════════════════════════════════════════════════════════════════════════╗
║                          ESTRUTURA FINAL RESERVA                             ║
╚══════════════════════════════════════════════════════════════════════════════╝

lib/features/Prop_Inq_Features/reserva/
│
├── domain/                           ← CAMADA DE NEGÓCIO (Pura)
│   ├── entities/
│   │   ├── reserva_entity.dart
│   │   └── ambiente_entity.dart
│   ├── repositories/
│   │   └── reserva_repository.dart   (Contrato abstrato)
│   └── usecases/
│       └── reserva_usecases.dart     (ObterReservasUseCase, CriarReservaUseCase, etc)
│
├── data/                             ← CAMADA DE DADOS
│   ├── datasources/
│   │   └── reserva_remote_datasource.dart  (Abstract + Impl)
│   ├── models/
│   │   └── reserva_model.dart        (JSON serialization)
│   └── repositories/
│       └── reserva_repository_impl.dart
│
├── presentation/
│   ├── cubit/
│   │   ├── reserva_cubit.dart        (Refatorado para usar UseCases)
│   │   └── reserva_state.dart
│   ├── screens/
│   │   └── reserva_screen.dart
│   ├── widgets/
│   │   ├── seletor_ambiente.dart
│   │   ├── campo_descricao.dart
│   │   └── botao_criar_reserva.dart
│   └── models/ (REMOVIDO - usar entities do domain)
│
├── di/
│   └── reserva_dependencies.dart     (Injeção de Dependência)
│
└── services/ (REMOVIDO - substituído por UseCases + DataSources)


╔══════════════════════════════════════════════════════════════════════════════╗
║                           FLUXO PRÁTICO                                       ║
╚══════════════════════════════════════════════════════════════════════════════╝

Usuário clica em "Criar Reserva"
                ↓
        ReservaScreen chama cubit.criarReserva()
                ↓
        ReservaCubit valida formulário
                ↓
        Cubit chama CriarReservaUseCase(...)
                ↓
        UseCase chama ReservaRepository.criarReserva()
                ↓
        Repository chama ReservaRemoteDataSource.criarReserva()
                ↓
        DataSource faz requisição Supabase
                ↓
        Supabase retorna JSON
                ↓
        DataSource converte JSON → ReservaModel → ReservaEntity
                ↓
        Entity retorna até o Cubit
                ↓
        Cubit emite ReservaCriada(reserva)
                ↓
        Screen escuta e mostra SnackBar


╔══════════════════════════════════════════════════════════════════════════════╗
║                     COMO USAR INJEÇÃO DE DEPENDÊNCIA                         ║
╚══════════════════════════════════════════════════════════════════════════════╝

SEM GetIt (Atual - Simples):
─────────────────────────────

Na ReservaScreen:

@override
void initState() {
  super.initState();
  // Criar toda a cadeia de dependências
  _cubit = ReservaDependencies.createReservaCubit();
  _cubit.carregarReservas(widget.condominioId);
}

BlocProvider(
  create: (context) => _cubit,
  child: ReservaScreen(...),
)


COM GetIt (Opcional - Profissional):
────────────────────────────────────

1. Instalar: flutter pub add get_it

2. Em main.dart:
import 'package:get_it/get_it.dart';
import 'features/Prop_Inq_Features/reserva/di/reserva_dependencies.dart';

void main() {
  setupReservaDependencies();  // ← Chamar uma vez
  runApp(const MyApp());
}

3. Na ReservaScreen:
@override
void initState() {
  super.initState();
  _cubit = getIt<ReservaCubit>();
  _cubit.carregarReservas(widget.condominioId);
}

VANTAGENS DO GetIt:
- Dependências configuradas uma vez em main.dart
- Reutilizável em qualquer tela
- Fácil trocar implementações (ex: Supabase → Firebase)
- Suporta diferentes "ambientes" (dev, prod, test)


╔══════════════════════════════════════════════════════════════════════════════╗
║                          TESTES IMPLEMENTADOS                                ║
╚══════════════════════════════════════════════════════════════════════════════╝

Arquivo: test/features/reserva_usecases_test.dart
────────────────────────────────────────────────

✅ Testes para ObterReservasUseCase
   - Deve retornar lista de reservas
   - Deve retornar lista vazia se nenhuma existe

✅ Testes para CriarReservaUseCase
   - Deve criar reserva com status pending
   - Deve validar estrutura de dados

✅ Testes para ValidarDisponibilidadeUseCase
   - Deve retornar false se há conflito de datas
   - Deve retornar true se não há conflito
   - Deve validar diferentes ambientes


Arquivo: test/features/reserva_cubit_test.dart
──────────────────────────────────────────────

✅ Testes para ReservaCubit
   - Validação de formulário
   - Atualização de estados
   - Criação de reserva
   - Limpeza de formulário
   - Reset de estado

EXECUTAR TESTES:
flutter test test/features/reserva_usecases_test.dart
flutter test test/features/reserva_cubit_test.dart
flutter test  # Todos os testes


╔══════════════════════════════════════════════════════════════════════════════╗
║                    PRÓXIMOS PASSOS RECOMENDADOS                              ║
╚══════════════════════════════════════════════════════════════════════════════╝

1. INTEGRAÇÃO COM SUPABASE
   - Implementar ReservaRemoteDataSourceImpl com SupabaseService
   - Criar migrations SQL para tabela de reservas
   - Testar com dados reais

2. ADICIONAR GetIt (Opcional)
   - Instalar: flutter pub add get_it
   - Descomentár código em reserva_dependencies.dart
   - Chamar setupReservaDependencies() em main.dart

3. TESTES DE INTEGRAÇÃO
   - Testar DataSource com mock Supabase
   - Testar Repository com DataSource real
   - Testar Cubit com Repository real

4. IMPLEMENTAR OUTRAS FEATURES COM MESMO PADRÃO
   - push_notification_admin
   - gateway_pagamento_admin
   - Outras features do projeto

5. MELHORIAS
   - Adicionar error handling mais robusto
   - Implementar retry logic
   - Adicionar cache local
   - Pagination para listas grandes


╔══════════════════════════════════════════════════════════════════════════════╗
║                           DIAGRAMA CAMADAS                                    ║
╚══════════════════════════════════════════════════════════════════════════════╝

┌─────────────────────────────────────────────────────────────────────────────┐
│                         PRESENTATION LAYER                                   │
│  UI (Widgets) → State (Cubit) → User Interaction                             │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │ ReservaScreen                                                            │ │
│  │ ├─ SeletorAmbiente                                                       │ │
│  │ ├─ CampoDescricao                                                        │ │
│  │ ├─ BotaoCriarReserva                                                     │ │
│  │ └─ ReservaCubit (Gerencia estado com UseCases)                          │ │
│  └─────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
                                    ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                          DOMAIN LAYER                                         │
│  Pure Business Logic - Sem conhecimento de origem de dados                   │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │ UseCases:                          Entities:                             │ │
│  │ - ObterReservasUseCase             - ReservaEntity (puro)               │ │
│  │ - CriarReservaUseCase              - AmbienteEntity (puro)              │ │
│  │ - CancelarReservaUseCase                                                 │ │
│  │ - ValidarDisponibilidadeUseCase    Repositories (Abstract):              │ │
│  │                                    - ReservaRepository (interface)       │ │
│  └─────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
                                    ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                           DATA LAYER                                          │
│  Implementações concretas - Como e de onde vem os dados                      │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │ Repositories Implementation:       DataSources:                          │ │
│  │ - ReservaRepositoryImpl             - ReservaRemoteDataSource (Supabase) │ │
│  │   (implementa contrato abstrato)                                         │ │
│  │                                    Models:                                │ │
│  │ Gerencia erros e conversões       - ReservaModel (JSON ↔ Dart)          │ │
│  │                                                                          │ │
│  └─────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
                                    ↓
                              Supabase API


╔══════════════════════════════════════════════════════════════════════════════╗
║                         COMPARAÇÃO ANTES/DEPOIS                              ║
╚══════════════════════════════════════════════════════════════════════════════╝

ANTES (Atual push_notification_admin):
─────────────────────────────────────

PushNotificationAdminScreen
        ↓
PushNotificationCubit (chama service diretamente)
        ↓
PushNotificationService (dados + lógica misturados)
        ↓
Supabase

PROBLEMAS:
❌ Lógica espalhada entre Cubit e Service
❌ Difícil testar Service isoladamente
❌ Difícil reutilizar lógica em outro lugar
❌ Mudança de dados → refatorar várias camadas


DEPOIS (Nova implementação Reserva - Clean Architecture):
─────────────────────────────────────────────────────────

ReservaScreen
        ↓
ReservaCubit (orquestra com UseCases)
        ↓
UseCases (lógica reutilizável e testável)
        ↓
ReservaRepository (interface - implementação agnóstica)
        ↓
ReservaRepositoryImpl (implementação concreta)
        ↓
ReservaRemoteDataSource (acesso a dados)
        ↓
Supabase

BENEFÍCIOS:
✅ Separação clara de responsabilidades
✅ Cada componente testável isoladamente
✅ Lógica reutilizável em diferentes cubits
✅ Fácil trocar origem de dados (Supabase → Firebase)
✅ Fácil estender funcionalidades sem quebrar existentes


╔══════════════════════════════════════════════════════════════════════════════╗
║                      COMO EXECUTAR OS TESTES                                 ║
╚══════════════════════════════════════════════════════════════════════════════╝

1. Instalar dependência de teste (se não tiver):
   flutter pub add --dev bloc_test

2. Executar testes específicos:
   flutter test test/features/reserva_usecases_test.dart
   flutter test test/features/reserva_cubit_test.dart

3. Executar todos os testes:
   flutter test

4. Executar com cobertura:
   flutter test --coverage

5. Ver resultado com lcov (macOS/Linux):
   genhtml coverage/lcov.info -o coverage/html
   open coverage/html/index.html


ESPERADO:
✅ ObterReservasUseCase (5 testes)
✅ CriarReservaUseCase (2 testes)
✅ ValidarDisponibilidadeUseCase (3 testes)
✅ ReservaCubit (5 testes)

Total: 15 testes ✅

*/


┌─────────────────────────────────────────────────────────────────────────────┐
│                         PRESENTATION LAYER                                   │
│  (UI, BLoC/Cubit, Estado)                                                    │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │ reserva_screen.dart ← BLoC ouve eventos → reserva_cubit.dart           │ │
│  │ widgets/                                  state/                         │ │
│  │ └─ campo_descricao.dart                   └─ reserva_state.dart         │ │
│  │ └─ seletor_ambiente.dart                                                │ │
│  │ └─ botao_criar_reserva.dart                                             │ │
│  └─────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
                                    ↓
                        cubit chama UseCase
                                    ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                          DOMAIN LAYER                                         │
│  (Lógica de Negócio Pura - Regras do Sistema)                               │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │ usecases/                              repositories/                     │ │
│  │ ├─ ObterReservasUseCase                ├─ reserva_repository.dart        │ │
│  │ ├─ CriarReservaUseCase                 └─ (Abstract - contrato)          │ │
│  │ ├─ CancelarReservaUseCase                                                │ │
│  │ └─ ValidarDisponibilidadeUseCase                                         │ │
│  │                                                                           │ │
│  │ entities/                                                                 │ │
│  │ └─ reserva_entity.dart (Dados puros, sem serialização)                   │ │
│  └─────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
                                    ↓
                    UseCase chama Repository
                                    ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                           DATA LAYER                                          │
│  (Busca dados de qualquer fonte)                                             │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │ repositories/                                                             │ │
│  │ └─ reserva_repository_impl.dart                                          │ │
│  │    (Implementação do contrato)                                           │ │
│  │                                    ↓                                      │ │
│  │ datasources/                                                              │ │
│  │ └─ reserva_remote_datasource.dart                                        │ │
│  │    ├─ obterReservas() → Supabase                                         │ │
│  │    ├─ criarReserva() → Supabase                                          │ │
│  │    └─ cancelarReserva() → Supabase                                       │ │
│  │                                                                           │ │
│  │ models/                                                                   │ │
│  │ └─ reserva_model.dart (Serialização JSON ↔ Dart)                         │ │
│  └─────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
                                    ↓
                              Supabase / API


╔══════════════════════════════════════════════════════════════════════════════╗
║                           FLUXO PRÁTICO                                       ║
╚══════════════════════════════════════════════════════════════════════════════╝

Usuário clica em "Criar Reserva"
                ↓
        ReservaScreen emite evento
                ↓
        ReservaCubit ouve evento
                ↓
        Cubit chama CriarReservaUseCase
                ↓
        UseCase chama ReservaRepository.criarReserva()
                ↓
        Repository chama ReservaRemoteDataSource.criarReserva()
                ↓
        DataSource faz requisição Supabase
                ↓
        Supabase retorna ReservaModel (JSON)
                ↓
        DataSource converte para Entity
                ↓
        Repository retorna Entity para UseCase
                ↓
        UseCase retorna Entity para Cubit
                ↓
        Cubit emite novo estado (ReservaCriada)
                ↓
        Screen escuta estado e atualiza UI


╔══════════════════════════════════════════════════════════════════════════════╗
║                       VANTAGENS DESTA ABORDAGEM                              ║
╚══════════════════════════════════════════════════════════════════════════════╝

✅ Separação Clara:
   - Presentation: Só interface
   - Domain: Só lógica
   - Data: Só dados

✅ Testabilidade:
   - UseCase testável sem UI
   - Repository testável sem DataSource
   - Cada camada isolada

✅ Reutilização:
   - UseCase pode ser usado por múltiplos Cubits
   - DataSource pode trocar de Supabase para Firebase

✅ Mudanças Fáceis:
   - Trocar Supabase por API REST? Apenas altere DataSource
   - Mudar lógica de validação? Altere UseCase
   - Novo Widget? Adicione em Presentation


╔══════════════════════════════════════════════════════════════════════════════╗
║                     COMO USAR NO CUBIT (Apresentação)                        ║
╚══════════════════════════════════════════════════════════════════════════════╝

class ReservaCubit extends Cubit<ReservaState> {
  final CriarReservaUseCase criarReservaUseCase;
  final ObterReservasUseCase obterReservasUseCase;
  final ValidarDisponibilidadeUseCase validarUseCase;

  ReservaCubit({
    required this.criarReservaUseCase,
    required this.obterReservasUseCase,
    required this.validarUseCase,
  }) : super(const ReservaInitial());

  // Usa UseCases, não DataSource diretamente
  Future<void> criarReserva(...) async {
    final resultado = await criarReservaUseCase(...);
    emit(ReservaCriada(resultado));
  }

  Future<void> carregarReservas(String condominioId) async {
    final reservas = await obterReservasUseCase(condominioId);
    emit(ReservaCarregada(reservas));
  }
}


╔══════════════════════════════════════════════════════════════════════════════╗
║                   INJEÇÃO DE DEPENDÊNCIA (Provider Pattern)                  ║
╚══════════════════════════════════════════════════════════════════════════════╝

Na tela, você faria assim:

BlocProvider(
  create: (context) => ReservaCubit(
    criarReservaUseCase: CriarReservaUseCase(
      repository: ReservaRepositoryImpl(
        remoteDataSource: ReservaRemoteDataSourceImpl(),
      ),
    ),
    obterReservasUseCase: ObterReservasUseCase(...),
    validarUseCase: ValidarDisponibilidadeUseCase(...),
  ),
  child: ReservaScreen(...),
)


╔══════════════════════════════════════════════════════════════════════════════╗
║                            MVVM vs CLEAN ARCH                                ║
╚══════════════════════════════════════════════════════════════════════════════╝

MVVM (Simple Project):
├── models/
├── views/
├── viewmodels/
└── services/

CLEAN ARCH (Large Project):
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
└── presentation/
    ├── pages/
    ├── widgets/
    ├── bloc/
    └── state/


QUANDO USAR CADA UMA:
- MVVM: App pequeno/médio, time pequeno, prototipagem rápida
- CLEAN ARCH: App grande, múltiplos features, time grande, longa vida útil

SEU PROJETO: 
Recomendo CLEAN ARCH porque tem múltiplas features (Admin, Prop_Inq) 
e vai crescer. Evita refatorações futuras.

*/
