import 'package:equatable/equatable.dart';
import '../../domain/entities/boleto_prop_entity.dart';

enum BoletoPropStatus { initial, loading, success, error }

class BoletoPropState extends Equatable {
  final BoletoPropStatus status;
  final List<BoletoPropEntity> boletos;

  // Filtro selecionado: 'Vencido/ A Vencer' ou 'Pago'
  final String filtroSelecionado;

  // Boleto expandido (por id)
  final String? boletoExpandidoId;

  // Demonstrativo Financeiro
  final int mesSelecionado;
  final int anoSelecionado;

  // Seções expansíveis
  final bool composicaoBoletoExpandida;
  final bool leiturasExpandida;
  final bool balanceteOnlineExpandido;

  // Dados das seções
  final Map<String, double>? composicaoBoleto;
  final Map<String, dynamic>? demonstrativoFinanceiro;
  final List<Map<String, dynamic>>? leituras;
  final Map<String, dynamic>? balanceteOnline;

  // Mensagens
  final String? errorMessage;
  final String? successMessage;

  const BoletoPropState({
    this.status = BoletoPropStatus.initial,
    this.boletos = const [],
    this.filtroSelecionado = 'Vencido/ A Vencer',
    this.boletoExpandidoId,
    this.mesSelecionado = 1,
    this.anoSelecionado = 2022,
    this.composicaoBoletoExpandida = false,
    this.leiturasExpandida = false,
    this.balanceteOnlineExpandido = false,
    this.composicaoBoleto,
    this.demonstrativoFinanceiro,
    this.leituras,
    this.balanceteOnline,
    this.errorMessage,
    this.successMessage,
  });

  /// Boletos filtrados conforme o filtro selecionado
  List<BoletoPropEntity> get boletosFiltrados {
    if (filtroSelecionado == 'Pago') {
      return boletos.where((b) => b.status == 'Pago').toList();
    }
    // 'Vencido/ A Vencer' → Ativo (vencido ou a vencer)
    return boletos.where((b) => b.status != 'Pago').toList();
  }

  BoletoPropState copyWith({
    BoletoPropStatus? status,
    List<BoletoPropEntity>? boletos,
    String? filtroSelecionado,
    String? boletoExpandidoId,
    bool clearBoletoExpandido = false,
    int? mesSelecionado,
    int? anoSelecionado,
    bool? composicaoBoletoExpandida,
    bool? leiturasExpandida,
    bool? balanceteOnlineExpandido,
    Map<String, double>? composicaoBoleto,
    Map<String, dynamic>? demonstrativoFinanceiro,
    List<Map<String, dynamic>>? leituras,
    Map<String, dynamic>? balanceteOnline,
    String? errorMessage,
    String? successMessage,
  }) {
    return BoletoPropState(
      status: status ?? this.status,
      boletos: boletos ?? this.boletos,
      filtroSelecionado: filtroSelecionado ?? this.filtroSelecionado,
      boletoExpandidoId: clearBoletoExpandido
          ? null
          : (boletoExpandidoId ?? this.boletoExpandidoId),
      mesSelecionado: mesSelecionado ?? this.mesSelecionado,
      anoSelecionado: anoSelecionado ?? this.anoSelecionado,
      composicaoBoletoExpandida:
          composicaoBoletoExpandida ?? this.composicaoBoletoExpandida,
      leiturasExpandida: leiturasExpandida ?? this.leiturasExpandida,
      balanceteOnlineExpandido:
          balanceteOnlineExpandido ?? this.balanceteOnlineExpandido,
      composicaoBoleto: composicaoBoleto ?? this.composicaoBoleto,
      demonstrativoFinanceiro: demonstrativoFinanceiro ?? this.demonstrativoFinanceiro,
      leituras: leituras ?? this.leituras,
      balanceteOnline: balanceteOnline ?? this.balanceteOnline,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    boletos,
    filtroSelecionado,
    boletoExpandidoId,
    mesSelecionado,
    anoSelecionado,
    composicaoBoletoExpandida,
    leiturasExpandida,
    balanceteOnlineExpandido,
    composicaoBoleto,
    demonstrativoFinanceiro,
    leituras,
    balanceteOnline,
    errorMessage,
    successMessage,
  ];
}
