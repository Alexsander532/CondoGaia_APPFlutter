# Documentação: Feature de Reservas

Esta documentação explica detalhadamente como a funcionalidade de Reservas está arquitetada e como ela funciona atualmente, após a refatoração para **Clean Architecture** e correção dos bugs estruturais.

---

## 🏗️ Arquitetura (Clean Architecture)
A feature foi dividida em três camadas principais para garantir separação de responsabilidades, testabilidade e escalabilidade:

```text
lib/features/Prop_Inq_Features/reserva/
├── domain/       # Regras de Negócio (Puro, sem dependências externas)
├── data/         # Implementação de acesso a dados (Supabase, APIs)
└── ui/           # Interface do Usuário e Gerência de Estado (Telas e Cubit)
```

### 1. Camada de Domínio (`domain/`)
É o coração da funcionalidade. Aqui definimos **o que** o app faz, sem nos importar com **como** os dados são salvos (Supabase).
- **Entities (`reserva_entity.dart`, `ambiente_entity.dart`):** Objetos puros contendo apenas os dados (ex: `dataReserva`, `horaInicio`, `valorLocacao`).
- **Repositories (`reserva_repository.dart`):** Contratos (interfaces) abstratos. Eles dizem "Eu preciso de um método `criarReserva`", mas não implementam o código real.
- **Use Cases (`reserva_usecases.dart`):** Onde as regras de negócio vivem. Cada ação do usuário é um UseCase isolado:
  - `ObterReservasUseCase`
  - `ObterAmbientesUseCase`
  - `CriarReservaUseCase`
  - `AtualizarReservaUseCase`
  - `CancelarReservaUseCase`
  - `ValidarDisponibilidadeUseCase` (Impede que uma mesma churrasqueira seja reservada duas vezes no mesmo horário).

### 2. Camada de Dados (`data/`)
Responsável por buscar/salvar as informações no mundo externo (neste caso, **Supabase**).
- **Models (`reserva_model.dart`, `ambiente_model.dart`):** Estendem as Entities, adicionando a capacidade de converter os dados de/para JSON (`fromJson` e `toJson`). O Model também trata relacionamentos (ex: extrair o nome do Inquilino ou Representante das tabelas estrangeiras).
- **DataSources (`reserva_remote_datasource.dart`):** Contém o código real do Supabase (`Supabase.instance.client.from('reservas')...`).
- **Repository Impl (`reserva_repository_impl.dart`):** Implementa a interface do domínio. Ele chama o DataSource, recebe o `Model`, converte para `Entity` e lida com exceções (blocos try/catch).

### 3. Camada de Apresentação (`ui/`)
Responsável pela tela e interação do usuário.
- **Telas e Componentes (`screens/`, `widgets/`):** Contém a `ReservaScreen`, que possui um calendário interativo e uma aba "Minhas Reservas". 
- **Injeção de Dependências (`di/reserva_dependencies.dart`):** Uma classe Factory que liga todas as camadas. Ela cria o DataSource, injeta no Repository, injeta nos UseCases e, finalmente, cria o `ReservaCubit`.
- **Cubit / Gerência de Estado (`cubit/reserva_cubit.dart` e `reserva_state.dart`):** 
  - O Cubit recebe as ações da tela (ex: "Mudou a data", "Clicou em Salvar").
  - Ele orquestra os UseCases e emite novos `Estados` (como `ReservaLoading`, `ReservaErro`, ou `ReservaCriada`).

---

## 🔄 Fluxo Completo: Como uma Reserva é Criada?

1. **Interação na Tela:**
   - O usuário seleciona um dia no calendário.
   - Um Modal se abre (`_showReservationModal`).
   - O usuário escolhe o Ambiente (ex: "Salão de Festas"). O Cubit guarda o ambiente selecionado.
   - O usuário digita a Hora de Início e Fim (ex: 10:00 às 14:00). A tela usa os métodos `_atualizarDataInicio` e `_atualizarDataFim` para converter a string formatada em objetos `DateTime` e enviá-los ao Cubit.
   - O usuário marca o Checkbox "Aceitar Termo de Locação".
   - O usuário clica em **Salvar**.

2. **Cubit Orquestrando:**
   - A função `cubit.criarReserva(...)` é chamada.
   - O Cubit confere se os dados obrigatórios estão preenchidos.
   - **Validação de Negócio:** O Cubit chama o `ValidarDisponibilidadeUseCase`, que baixa as reservas do condomínio e checa se há colisão/sobreposição de horários e datas para aquele mesmo ambiente. Se houver, emite um `ReservaErro("Ambiente indisponível")`.
   - Se estiver livre, o Cubit emite um `ReservaLoading`.
   - O Cubit chama o `CriarReservaUseCase`.

3. **Salvando os Dados:**
   - O UseCase passa os dados para o `ReservaRepositoryImpl`.
   - O Repository repassa para o `ReservaRemoteDataSourceImpl`.
   - O DataSource formata os dados para o padrão do Supabase (`yyyy-MM-dd` e `HH:mm`) e faz o `insert` na tabela `reservas`.
   - O Supabase retorna os dados salvos (incluindo o ID gerado e o nome das relações do usuário).
   - O DataSource converte esse JSON para um `ReservaModel`.
   - A resposta volta subindo as camadas (DataSource -> Repository -> UseCase -> Cubit).

4. **Retorno à Tela:**
   - O Cubit atualiza sua lista local `_reservas.add(novaReserva)`.
   - O Cubit emite `ReservaCriada("Reserva criada com sucesso")`.
   - A tela (via `BlocListener`) escuta o evento de sucesso, fecha o loading e exibe um `SnackBar` verde confirmando a ação. A tela principal e o calendário são atualizados automaticamente contendo o novo pontinho vermelho indicando a reserva no dia.

---

## ✅ Resumo da Qualidade e Segurança (Testes)
A feature possui uma suite rigorosa com **36 testes unitários** mapeando 100% das etapas acima. Os arquivos de testes residem em `test/features/reserva/`. Isso significa que:
- Se alguém quebrar a lógica do calendário, os testes do `ReservaCubit` falham antes do App rodar.
- Se alguém modificar como o Supabase lida com formatos de data, os testes de conversões JSON (`ReservaModel`) falham acusando o erro com precisão.
- Se alguém mexer na regra que impede choque de horários numa churrasqueira, o teste `ValidarDisponibilidadeUseCase` falhará avisando a regressão.
