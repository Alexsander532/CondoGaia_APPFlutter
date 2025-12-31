import 'morador_model.dart';
import 'localizacao_model.dart';

class PushNotificationModel {
  final String? id;
  final String titulo;
  final String mensagem;
  final bool sindicosInclusos;
  final List<MoradorModel> moradoresSelecionados;
  final EstadoModel? estadoSelecionado;
  final CidadeModel? cidadeSelecionada;
  final DateTime? dataCriacao;
  final bool enviado;

  PushNotificationModel({
    this.id,
    required this.titulo,
    required this.mensagem,
    this.sindicosInclusos = false,
    this.moradoresSelecionados = const [],
    this.estadoSelecionado,
    this.cidadeSelecionada,
    this.dataCriacao,
    this.enviado = false,
  });

  /// Cria uma cópia do modelo com valores modificados
  PushNotificationModel copyWith({
    String? id,
    String? titulo,
    String? mensagem,
    bool? sindicosInclusos,
    List<MoradorModel>? moradoresSelecionados,
    EstadoModel? estadoSelecionado,
    CidadeModel? cidadeSelecionada,
    DateTime? dataCriacao,
    bool? enviado,
  }) {
    return PushNotificationModel(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      mensagem: mensagem ?? this.mensagem,
      sindicosInclusos: sindicosInclusos ?? this.sindicosInclusos,
      moradoresSelecionados: moradoresSelecionados ?? this.moradoresSelecionados,
      estadoSelecionado: estadoSelecionado ?? this.estadoSelecionado,
      cidadeSelecionada: cidadeSelecionada ?? this.cidadeSelecionada,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      enviado: enviado ?? this.enviado,
    );
  }

  /// Verifica se a notificação tem todos os dados obrigatórios preenchidos
  bool get estaCompleta {
    return titulo.isNotEmpty &&
        mensagem.isNotEmpty &&
        (sindicosInclusos || moradoresSelecionados.isNotEmpty) &&
        estadoSelecionado != null &&
        cidadeSelecionada != null;
  }

  /// Retorna a quantidade de destinatários
  int get totalDestinatarios {
    int total = moradoresSelecionados.length;
    if (sindicosInclusos) {
      total += 1; // Adicionando 1 para os síndicos
    }
    return total;
  }
}
