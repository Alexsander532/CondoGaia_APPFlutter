📁 ESTRUTURA FINAL DA FEATURE RESERVA - CLEAN ARCHITECTURE

lib/features/Prop_Inq_Features/reserva/
│
├── 📁 domain/                          ← CAMADA DE NEGÓCIO (Pura - Sem dependências externas)
│   ├── entities/
│   │   ├── reserva_entity.dart        (ReservaEntity - sem serialização)
│   │   └── ambiente_entity.dart       (AmbienteEntity - sem serialização)
│   ├── repositories/
│   │   └── reserva_repository.dart    (Interface abstrata)
│   └── usecases/
│       └── reserva_usecases.dart      (4 UseCases reutilizáveis)
│           ├── ObterReservasUseCase
│           ├── CriarReservaUseCase
│           ├── CancelarReservaUseCase
│           └── ValidarDisponibilidadeUseCase
│
├── 📁 data/                            ← CAMADA DE DADOS (Implementações concretas)
│   ├── datasources/
│   │   └── reserva_remote_datasource.dart  (Interface + Impl para Supabase)
│   ├── models/
│   │   ├── reserva_model.dart         (ReservaModel - com JSON serialization)
│   │   └── ambiente_model.dart        (AmbienteModel - com JSON serialization)
│   └── repositories/
│       └── reserva_repository_impl.dart (Implementação concreta do contrato)
│
└── 📁 ui/                              ← CAMADA DE APRESENTAÇÃO (Interface do usuário)
    ├── 📁 cubit/                       (BLoC/Cubit - Gerenciamento de estado)
    │   ├── reserva_cubit.dart         (Orquestra UseCases)
    │   └── reserva_state.dart         (Estados da aplicação)
    │
    ├── 📁 screens/                     (Telas/Páginas)
    │   └── reserva_screen.dart        (Tela principal de reservas)
    │
    ├── 📁 widgets/                     (Componentes reutilizáveis)
    │   ├── seletor_ambiente.dart      (Dropdown de ambientes)
    │   ├── campo_descricao.dart       (Campo de texto com label obrigatório)
    │   └── botao_criar_reserva.dart   (Botão com cores dinâmicas)
    │
    └── 📁 di/                          (Dependency Injection - Configuração)
        └── reserva_dependencies.dart   (Factory para criar ReservaCubit)
                                        (Manual ou com GetIt)

---

✅ ESTRUTURA LIMPA E ORGANIZADA:
- Apenas 3 pastas principais: domain, data, ui
- Separação clara de responsabilidades
- Cada camada com seu próprio propósito
- Fácil de navegar e entender
- Pronto para escalar

---

⚠️ PASTAS ANTIGAS (REMOVER):
❌ /cubit (mover para ui/cubit) ✅ FEITO
❌ /screens (mover para ui/screens) ✅ FEITO
❌ /widgets (mover para ui/widgets) ✅ FEITO
❌ /di (mover para ui/di) ✅ FEITO
❌ /models (remover - usar data/models)
❌ /services (remover - substituído por UseCases)

---

🎯 PRÓXIMAS AÇÕES:
1. Remover pastas antigas (cubit, screens, widgets, di, models, services)
2. Validar que tudo ainda compila (flutter analyze)
3. Testar a aplicação (flutter test)
4. Atualizar qualquer import em outras telas que usem ReservaScreen
