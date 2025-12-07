import '../models/instituicao_financeira_model.dart';
import '../models/plano_assinatura_model.dart';
import '../models/tipo_pagamento_model.dart';
import '../models/gateway_pagamento_model.dart';

class GatewayPagamentoService {
  /// Lista de instituições financeiras - dados mockados
  static final List<InstituicaoFinanceiraModel> _instituicoes = [
    InstituicaoFinanceiraModel(
      id: '1',
      nome: 'ASAAS',
      sigla: 'ASA',
      icone: 'assets/images/asaas.png',
    ),
    InstituicaoFinanceiraModel(
      id: '2',
      nome: 'PayPal',
      sigla: 'PP',
      icone: 'assets/images/paypal.png',
    ),
    InstituicaoFinanceiraModel(
      id: '3',
      nome: 'Stripe',
      sigla: 'STR',
      icone: 'assets/images/stripe.png',
    ),
    InstituicaoFinanceiraModel(
      id: '4',
      nome: 'PagSeguro',
      sigla: 'PSG',
      icone: 'assets/images/pagseguro.png',
    ),
    InstituicaoFinanceiraModel(
      id: '5',
      nome: 'Mercado Pago',
      sigla: 'MP',
      icone: 'assets/images/mercado_pago.png',
    ),
  ];

  /// Lista de planos de assinatura - dados mockados
  static final List<PlanoAssinaturaModel> _planos = [
    PlanoAssinaturaModel(
      id: '1',
      nome: 'Plano Básico',
      descricao: 'Perfeito para pequenos condomínios',
      valor: 99.90,
      frequencia: 'Mensal',
      diasTentativa: 3,
    ),
    PlanoAssinaturaModel(
      id: '2',
      nome: 'Plano Profissional',
      descricao: 'Ideal para condomínios médios',
      valor: 199.90,
      frequencia: 'Mensal',
      diasTentativa: 5,
    ),
    PlanoAssinaturaModel(
      id: '3',
      nome: 'Plano Empresarial',
      descricao: 'Para grandes condomínios e redes',
      valor: 399.90,
      frequencia: 'Mensal',
      diasTentativa: 7,
    ),
    PlanoAssinaturaModel(
      id: '4',
      nome: 'Plano Mensal',
      descricao: 'Pagamento mensal com flexibilidade',
      valor: 99.90,
      frequencia: 'Mensal',
      diasTentativa: 3,
    ),
    PlanoAssinaturaModel(
      id: '5',
      nome: 'Plano Trimestral',
      descricao: '10% de desconto em 3 meses',
      valor: 269.73,
      frequencia: 'Trimestral',
      diasTentativa: 5,
    ),
    PlanoAssinaturaModel(
      id: '6',
      nome: 'Plano Semestral',
      descricao: '15% de desconto em 6 meses',
      valor: 509.46,
      frequencia: 'Semestral',
      diasTentativa: 7,
    ),
    PlanoAssinaturaModel(
      id: '7',
      nome: 'Plano Anual',
      descricao: '20% de desconto pagando anualmente',
      valor: 959.04,
      frequencia: 'Anual',
      diasTentativa: 10,
    ),
  ];

  /// Lista de tipos de pagamento - dados mockados
  static final List<TipoPagamentoModel> _tiposPagamento = [
    TipoPagamentoModel(
      id: '1',
      nome: 'Boleto',
      descricao: 'Pagamento via boleto bancário',
      ativo: true,
    ),
    TipoPagamentoModel(
      id: '2',
      nome: 'Cartão de Crédito',
      descricao: 'Pagamento com cartão de crédito',
      ativo: true,
    ),
    TipoPagamentoModel(
      id: '3',
      nome: 'PIX',
      descricao: 'Pagamento instantâneo via PIX',
      ativo: true,
    ),
    TipoPagamentoModel(
      id: '4',
      nome: 'Transferência Bancária',
      descricao: 'Pagamento por transferência bancária',
      ativo: false,
    ),
  ];

  /// Lista de gateways já configurados - dados mockados
  static final List<GatewayPagamentoModel> _gateways = [
    GatewayPagamentoModel(
      id: '1',
      instituicao: _instituicoes[0],
      plano: _planos[0],
      tipoPagamento: _tiposPagamento[0],
      token: 'ajkfcsabqss2s15651f16s1as1as6',
      dataCriacao: DateTime(2024, 1, 15),
      ativo: true,
    ),
  ];

  /// Obtém a lista de instituições financeiras (síncrono)
  List<InstituicaoFinanceiraModel> obterInstituicoesSync() {
    return _instituicoes;
  }

  /// Obtém a lista de instituições financeiras (assíncrono)
  Future<List<InstituicaoFinanceiraModel>> obterInstituicoes() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _instituicoes;
  }

  /// Obtém a lista de planos de assinatura (síncrono)
  List<PlanoAssinaturaModel> obterPlanosSync() {
    return _planos;
  }

  /// Obtém a lista de planos de assinatura (assíncrono)
  Future<List<PlanoAssinaturaModel>> obterPlanos() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _planos;
  }

  /// Obtém a lista de tipos de pagamento (síncrono)
  List<TipoPagamentoModel> obterTiposPagamentoSync() {
    return _tiposPagamento;
  }

  /// Obtém a lista de tipos de pagamento (assíncrono)

  /// Obtém a lista de gateways configurados
  Future<List<GatewayPagamentoModel>> obterGatewaysConfigigurados() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _gateways;
  }

  /// Valida os dados de configuração do gateway
  /// Retorna uma lista de mensagens de erro (vazia se válido)
  List<String> validarConfiguracao({
    required InstituicaoFinanceiraModel? instituicaoSelecionada,
    required PlanoAssinaturaModel? planoSelecionado,
    required TipoPagamentoModel? tipoPagamentoSelecionado,
    required String token,
  }) {
    final erros = <String>[];

    if (instituicaoSelecionada == null) {
      erros.add('Selecione uma instituição financeira');
    }

    if (planoSelecionado == null) {
      erros.add('Selecione um plano de assinatura');
    }

    if (tipoPagamentoSelecionado == null) {
      erros.add('Selecione um tipo de pagamento');
    }

    if (token.trim().isEmpty) {
      erros.add('O token é obrigatório');
    } else if (token.length < 10) {
      erros.add('O token deve ter no mínimo 10 caracteres');
    }

    return erros;
  }

  /// Simula o salvamento da configuração do gateway
  /// Retorna um Future que resolve após alguns segundos
  Future<bool> salvarConfiguracao({
    required InstituicaoFinanceiraModel instituicao,
    required PlanoAssinaturaModel plano,
    required TipoPagamentoModel tipoPagamento,
    required String token,
  }) async {
    // Validar antes de salvar
    final erros = validarConfiguracao(
      instituicaoSelecionada: instituicao,
      planoSelecionado: plano,
      tipoPagamentoSelecionado: tipoPagamento,
      token: token,
    );

    if (erros.isNotEmpty) {
      throw Exception(erros.join('\n'));
    }

    // Simulando uma chamada à API com delay
    await Future.delayed(const Duration(seconds: 2));

    // Adicionar novo gateway à lista de mockdata (para simular persistência)
    final novoGateway = GatewayPagamentoModel(
      id: '${_gateways.length + 1}',
      instituicao: instituicao,
      plano: plano,
      tipoPagamento: tipoPagamento,
      token: token,
      dataCriacao: DateTime.now(),
      ativo: true,
    );
    _gateways.add(novoGateway);

    // Por enquanto, sempre retorna true (sucesso)
    return true;
  }
}
