import 'package:equatable/equatable.dart';
import '../models/localizacao_model.dart';
import '../models/condominio_model.dart';

abstract class PushNotificationState extends Equatable {
  const PushNotificationState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class PushNotificationInitial extends PushNotificationState {
  const PushNotificationInitial();
}

/// Estado carregando
class PushNotificationLoading extends PushNotificationState {
  const PushNotificationLoading();
}

/// Estado de sucesso ao enviar notificação
class PushNotificationEnviada extends PushNotificationState {
  final String mensagem;

  const PushNotificationEnviada({
    this.mensagem = 'Notificação enviada com sucesso!',
  });

  @override
  List<Object?> get props => [mensagem];
}

/// Estado de erro
class PushNotificationErro extends PushNotificationState {
  final String mensagem;

  const PushNotificationErro({required this.mensagem});

  @override
  List<Object?> get props => [mensagem];
}

/// Estado atualizado com formulário
class PushNotificationFormularioAtualizado extends PushNotificationState {
  final String titulo;
  final String mensagem;
  final bool sindicosInclusos;
  final List<CondominioModel> condominiosSelecionados;
  final EstadoModel? estadoSelecionado;
  final CidadeModel? cidadeSelecionada;
  final bool formularioValido;

  const PushNotificationFormularioAtualizado({
    required this.titulo,
    required this.mensagem,
    required this.sindicosInclusos,
    required this.condominiosSelecionados,
    required this.estadoSelecionado,
    required this.cidadeSelecionada,
    required this.formularioValido,
  });

  @override
  List<Object?> get props => [
    titulo,
    mensagem,
    sindicosInclusos,
    condominiosSelecionados,
    estadoSelecionado,
    cidadeSelecionada,
    formularioValido,
  ];
}
