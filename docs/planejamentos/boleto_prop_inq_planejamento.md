# Planejamento de Implementação — Feature Boleto (Proprietário/Inquilino)

**Data:** 13/03/2026  
**Versão:** 1.0  
**Estimativa Total:** ~8-12 horas de desenvolvimento  
**Pré-requisito:** Relatório `boleto_prop_inq_relatorio.md`

---

## Objetivo

Transformar a feature de Boleto do Proprietário/Inquilino de **UI com dados mock** para **funcionalidade 100% integrada com Supabase**, permitindo que moradores visualizem, filtrem e interajam com seus boletos reais.

---

## Fase 1 — Correção da Navegação (30 min)

### 1.1 Atualizar `BoletoPropScreen` para receber `moradorId`

**Arquivo:** `boleto/ui/screens/boleto_prop_screen.dart`

- Adicionar parâmetro `moradorId` (String) ao construtor
- Passar `moradorId` para o `BoletoPropCubit`

### 1.2 Atualizar navegação na Home

**Arquivo:** `screens/inquilino_home_screen.dart` (linha ~633)

```dart
// ANTES:
BoletoPropScreen(condominioId: widget.condominioId)

// DEPOIS:
BoletoPropScreen(
  condominioId: widget.condominioId,
  moradorId: widget.inquilinoId ?? widget.proprietarioId ?? '',
)
```

### Entregável:
- [x] `BoletoPropScreen` recebe `condominioId` + `moradorId`
- [x] Home passa os IDs corretos

---

## Fase 2 — Expandir Entity e Model (1h)

### 2.1 Expandir `BoletoPropEntity`

**Arquivo:** `boleto/domain/entities/boleto_prop_entity.dart`

Adicionar campos que existem na tabela `boletos` do Supabase:
```dart
class BoletoPropEntity {
  final String id;
  final String condominioId;
  final String? unidadeId;
  final String? sacado;
  final String? blocoUnidade;
  final String? referencia;
  final DateTime dataVencimento;
  final double valor;
  final String status;
  final String tipo;
  final String? classe;
  
  // Composição do boleto
  final double cotaCondominial;
  final double fundoReserva;
  final double multaInfracao;
  final double controle;
  final double rateioAgua;
  final double desconto;
  final double valorTotal;
  
  // ASAAS
  final String? bankSlipUrl;
  final String? barCode;
  final String? identificationField;
  final String? invoiceUrl;
  
  // Calculado
  final bool isVencido;
}
```

### 2.2 Atualizar `BoletoPropModel`

**Arquivo:** `boleto/data/models/boleto_prop_model.dart`

- Atualizar `fromJson()` para mapear todos os campos da tabela `boletos`
- Atualizar `toJson()` (se necessário)
- Usar mesmos nomes de colunas que a tabela Supabase

### Entregável:
- [x] Entity com todos os campos necessários (20+ campos)
- [x] Model com serialização JSON completa

---

## Fase 3 — Implementar DataSource Supabase (2h)

### 3.1 Implementar `BoletoPropRemoteDataSourceImpl`

**Arquivo:** `boleto/data/datasources/boleto_prop_remote_datasource.dart`

Implementar 4 métodos com queries Supabase reais:

#### `obterBoletos(moradorId, filtroStatus)`
```dart
// Query principal:
final response = await _supabase
    .from('boletos')
    .select('*')
    .eq('sacado', moradorId)  // Filtra pelo morador logado
    .order('data_vencimento', ascending: false);

// Aplicar filtro de status:
// 'Vencido/ A Vencer' → status != 'Pago'
// 'Pago' → status == 'Pago'
```

#### `obterBoletoPorId(boletoId)`
```dart
final response = await _supabase
    .from('boletos')
    .select('*')
    .eq('id', boletoId)
    .maybeSingle();
```

#### `obterComposicaoBoleto(boletoId)`
```dart
// Retorna Map<String, double> com campos de composição:
// cota_condominial, fundo_reserva, rateio_agua, etc.
```

#### `obterDemonstrativoFinanceiro(moradorId, mes, ano)`
```dart
// Busca boletos do morador no mês/ano específico
// Retorna totais agrupados
```

### 3.2 Injetar SupabaseClient

- Adicionar `SupabaseClient` como dependência do DataSource
- Usar `Supabase.instance.client` (padrão já usado no projeto)

### Entregável:
- [x] DataSource com queries Supabase reais
- [x] Tratamento de erros com try/catch
- [x] Log de erros com print (padrão do projeto)

---

## Fase 4 — Conectar Cubit com Use Cases (1.5h)

### 4.1 Atualizar `BoletoPropCubit`

**Arquivo:** `boleto/ui/cubit/boleto_prop_cubit.dart`

**Mudanças:**
1. Receber `ObterBoletosPropUseCase` no construtor (injeção de dependência)
2. Receber `moradorId` e `condominioId`
3. Substituir dados mock por chamadas reais ao UseCase
4. Implementar `verBoleto()` — abrir `bank_slip_url` com `url_launcher`
5. Implementar `copiarCodigoBarras()` — melhorar passando identification_field
6. Implementar `compartilharBoleto()` — compartilhar via `share_plus`

```dart
class BoletoPropCubit extends Cubit<BoletoPropState> {
  final ObterBoletosPropUseCase _obterBoletos;
  final String moradorId;
  final String condominioId;

  BoletoPropCubit({
    required ObterBoletosPropUseCase obterBoletos,
    required this.moradorId,
    required this.condominioId,
  }) : _obterBoletos = obterBoletos, super(...);

  Future<void> carregarBoletos() async {
    emit(state.copyWith(status: BoletoPropStatus.loading));
    try {
      final boletos = await _obterBoletos.call(moradorId: moradorId);
      emit(state.copyWith(status: BoletoPropStatus.success, boletos: boletos));
    } catch (e) {
      emit(state.copyWith(status: BoletoPropStatus.error, errorMessage: e.toString()));
    }
  }
}
```

### 4.2 Atualizar `BoletoPropScreen` para instanciar dependências

**Arquivo:** `boleto/ui/screens/boleto_prop_screen.dart`

```dart
BlocProvider(
  create: (context) {
    final dataSource = BoletoPropRemoteDataSourceImpl();
    final repository = BoletoPropRepositoryImpl(remoteDataSource: dataSource);
    final useCase = ObterBoletosPropUseCase(repository: repository);
    return BoletoPropCubit(
      obterBoletos: useCase,
      moradorId: moradorId,
      condominioId: condominioId,
    )..carregarBoletos();
  },
  child: ...
)
```

### Entregável:
- [x] Cubit conectado aos Use Cases
- [x] Dados reais do Supabase carregados
- [x] Injeção de dependência completa

---

## Fase 5 — Implementar Ações (2h)

### 5.1 Ver Boleto (PDF)

**Dependência:** pacote `url_launcher` (já disponível no projeto)

```dart
void verBoleto(String boletoId) async {
  final boleto = state.boletos.firstWhere((b) => b.id == boletoId);
  if (boleto.bankSlipUrl != null) {
    await launchUrl(Uri.parse(boleto.bankSlipUrl!));
  }
}
```

### 5.2 Copiar Código de Barras

Já funciona parcialmente no widget. Melhorar para usar `identification_field` (linha digitável) ao invés de `barCode`:
```dart
// Priorizar identification_field (linha digitável) > barCode
final texto = boleto.identificationField ?? boleto.barCode ?? '';
```

### 5.3 Compartilhar Boleto

**Dependência:** pacote `share_plus`

```dart
void compartilharBoleto(String boletoId) async {
  final boleto = state.boletos.firstWhere((b) => b.id == boletoId);
  final texto = '''
Boleto CondoGaia
Vencimento: ${DateFormat('dd/MM/yyyy').format(boleto.dataVencimento)}
Valor: R\$ ${boleto.valor.toStringAsFixed(2)}
Código: ${boleto.identificationField ?? boleto.barCode ?? 'N/A'}
''';
  await Share.share(texto);
}
```

### Entregável:
- [x] Ver Boleto abre PDF via URL ASAAS
- [x] Copiar código de barras usa identification_field
- [x] Compartilhar gera texto e usa share_plus

---

## Fase 6 — Conectar Seções com Dados Reais (1.5h)

### 6.1 Composição do Boleto

**Arquivo:** `boleto/ui/widgets/secoes_expansiveis_widget.dart`

Substituir dados hardcoded pela composição real do boleto selecionado:
```
Cota Condominial .... R$ {cotaCondominial}
Fundo de Reserva .... R$ {fundoReserva}
Rateio Água ........ R$ {rateioAgua}
Multa Infração ..... R$ {multaInfracao}
Controle ........... R$ {controle}
Desconto ........... R$ -{desconto}
─────────────────────────────
Total .............. R$ {valor}
```

### 6.2 Leituras

Buscar leituras da tabela `leituras` para a unidade do morador no mês/ano selecionado.

**Query:**
```dart
final response = await supabase
    .from('leituras')
    .select('*')
    .eq('unidade_id', unidadeId)
    .gte('data_leitura', inicioMes)
    .lte('data_leitura', fimMes);
```

### 6.3 Balancete Online

Buscar balancetes da tabela `balancetes` para o condomínio no mês/ano selecionado.

**Query:**
```dart
final response = await supabase
    .from('balancetes')
    .select('*')
    .eq('condominio_id', condominioId)
    .eq('mes', mes.toString())
    .eq('ano', ano.toString());
```

### Entregável:
- [x] Composição do boleto com dados reais
- [x] Leituras integradas
- [x] Balancete com link para download

---

## Fase 7 — Testes Automatizados (2h)

### 7.1 Testes de Model
- `BoletoPropModel.fromJson()` com dados completos
- `BoletoPropModel.fromJson()` com campos nulos
- `BoletoPropModel.toJson()` round-trip

### 7.2 Testes de State
- `boletosFiltrados` com filtro "Pago"
- `boletosFiltrados` com filtro "Vencido/ A Vencer"
- `copyWith` com clearBoletoExpandido

### 7.3 Testes de Cubit
- `carregarBoletos` emite Loading → Success
- `carregarBoletos` emite Loading → Error (falha)
- `alterarFiltro` emite estado correto
- `toggleBoletoExpandido` toggle funciona

### Entregável:
- [x] Mínimo 10 testes unitários
- [x] Cobertura de Model, State e Cubit

---

## Fase 8 — Polimento e UX (1h)

### 8.1 Loading states
- Skeleton/shimmer durante carregamento
- Pull-to-refresh na lista de boletos

### 8.2 Estado vazio
- Tela bonita quando não há boletos
- Diferenciar "nenhum boleto" de "erro de conexão"

### 8.3 Tratamento de boleto sem ASAAS
- Quando `bankSlipUrl` é null e boleto não está vencido: mostrar botão "Ver Boleto" desabilitado com tooltip explicativo
- Quando `barCode` é null: esconder botão "Copiar Código de Barras"

---

## Resumo das Fases

| Fase | Descrição | Estimativa | Prioridade |
|---|---|---|---|
| 1 | Correção da navegação | 30 min | 🔴 Crítica |
| 2 | Expandir Entity/Model | 1h | 🔴 Crítica |
| 3 | Implementar DataSource Supabase | 2h | 🔴 Crítica |
| 4 | Conectar Cubit com Use Cases | 1.5h | 🔴 Crítica |
| 5 | Implementar ações (Ver/Copiar/Compartilhar) | 2h | 🟡 Alta |
| 6 | Conectar seções com dados reais | 1.5h | 🟡 Alta |
| 7 | Testes automatizados | 2h | 🟢 Média |
| 8 | Polimento e UX | 1h | 🟢 Média |
| **Total** | | **~11.5h** | |

---

## Dependências de Pacotes

| Pacote | Uso | Status |
|---|---|---|
| `supabase_flutter` | Queries ao banco | ✅ Já instalado |
| `flutter_bloc` | Gerenciamento de estado | ✅ Já instalado |
| `equatable` | Comparação de states | ✅ Já instalado |
| `intl` | Formatação de datas/valores | ✅ Já instalado |
| `url_launcher` | Abrir PDF do boleto | ⚠️ Verificar se instalado |
| `share_plus` | Compartilhar boleto | ⚠️ Verificar se instalado |

---

## Ordem de Implementação Recomendada

```
Fase 1 (Navegação) → Fase 2 (Entity/Model) → Fase 3 (DataSource) 
→ Fase 4 (Cubit) → Fase 5 (Ações) → Fase 6 (Seções) 
→ Fase 7 (Testes) → Fase 8 (Polimento)
```

> **⚠️ IMPORTANTE:** As fases 1-4 são pré-requisito obrigatório para qualquer funcionalidade. Começar por elas garante que os dados reais estarão fluindo antes de implementar ações e seções.
