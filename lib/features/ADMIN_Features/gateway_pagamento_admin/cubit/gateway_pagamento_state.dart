import 'package:equatable/equatable.dart';
import '../models/instituicao_financeira_model.dart';
import '../models/plano_assinatura_model.dart';
import '../models/tipo_pagamento_model.dart';


//Estado abstrato para Lavar Louça (Estado padrão para poder comparar com os outros estados) --> Classe base
abstract class LavarLoucaState extends Equatable{
  late int x;
}

class LavarLoucaInitial implements LavarLoucaState{
  @override
  late int x;

  LavarLoucaInitial({required this.x});

  @override
  List<Object?> get props => [x];

  @override
  bool? get stringify => true;
}




/// Estado abstrato para Gateway de Pagamento
abstract class GatewayPagamentoState extends Equatable {
  const GatewayPagamentoState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class GatewayPagamentoInitial extends GatewayPagamentoState {
  const GatewayPagamentoInitial();
}

/// Estado de carregamento
class GatewayPagamentoLoading extends GatewayPagamentoState {
  const GatewayPagamentoLoading();
}

/// Estado de configuração salva com sucesso
class GatewayPagamentoSalva extends GatewayPagamentoState {
  final String mensagem;

  const GatewayPagamentoSalva({required this.mensagem});

  @override
  List<Object?> get props => [mensagem];
}

/// Estado de erro
class GatewayPagamentoErro extends GatewayPagamentoState {
  final String mensagem;

  const GatewayPagamentoErro({required this.mensagem});

  @override
  List<Object?> get props => [mensagem];
}

/// Estado do formulário atualizado
class GatewayPagamentoFormularioAtualizado extends GatewayPagamentoState {
  final String token;
  final InstituicaoFinanceiraModel? instituicaoSelecionada;
  final PlanoAssinaturaModel? planoSelecionado;
  final TipoPagamentoModel? tipoPagamentoSelecionado;
  final bool formularioValido;

  const GatewayPagamentoFormularioAtualizado({
    required this.token,
    required this.instituicaoSelecionada,
    required this.planoSelecionado,
    required this.tipoPagamentoSelecionado,
    required this.formularioValido,
  });

  @override
  List<Object?> get props => [
    token,
    instituicaoSelecionada,
    planoSelecionado,
    tipoPagamentoSelecionado,
    formularioValido,
  ];
}
