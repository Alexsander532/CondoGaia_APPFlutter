import 'instituicao_financeira_model.dart';
import 'plano_assinatura_model.dart';
import 'tipo_pagamento_model.dart';

class GatewayPagamentoModel {
  final String id;
  final InstituicaoFinanceiraModel instituicao;
  final PlanoAssinaturaModel plano;
  final TipoPagamentoModel tipoPagamento;
  final String token; // Token do gateway
  final DateTime dataCriacao;
  final bool ativo;

  GatewayPagamentoModel({
    required this.id,
    required this.instituicao,
    required this.plano,
    required this.tipoPagamento,
    required this.token,
    required this.dataCriacao,
    required this.ativo,
  });

  GatewayPagamentoModel copyWith({
    String? id,
    InstituicaoFinanceiraModel? instituicao,
    PlanoAssinaturaModel? plano,
    TipoPagamentoModel? tipoPagamento,
    String? token,
    DateTime? dataCriacao,
    bool? ativo,
  }) {
    return GatewayPagamentoModel(
      id: id ?? this.id,
      instituicao: instituicao ?? this.instituicao,
      plano: plano ?? this.plano,
      tipoPagamento: tipoPagamento ?? this.tipoPagamento,
      token: token ?? this.token,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      ativo: ativo ?? this.ativo,
    );
  }

  @override
  String toString() => 'GatewayPagamentoModel(id: $id, instituicao: ${instituicao.nome})';
}
