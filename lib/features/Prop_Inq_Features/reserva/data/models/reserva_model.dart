/// Model é a representação dos dados que vêm do servidor/banco de dados
/// Responsável por serialização/desserialização
/// Estende Entity para herdar as propriedades do domínio
import '../../domain/entities/reserva_entity.dart';

class ReservaModel extends ReservaEntity {
  ReservaModel({
    required String id,
    required String ambienteId,
    String? representanteId,
    String? inquilinoId,
    String? proprietarioId,
    required DateTime dataReserva,
    required String horaInicio,
    required String horaFim,
    required String local,
    required double valorLocacao,
    required bool termoLocacao,
    required String para,
    required DateTime dataCriacao,
    required DateTime dataAtualizacao,
    String? listaPresentes,
    String? blocoUnidadeId,
  }) : super(
         id: id,
         ambienteId: ambienteId,
         representanteId: representanteId,
         inquilinoId: inquilinoId,
         proprietarioId: proprietarioId,
         dataReserva: dataReserva,
         horaInicio: horaInicio,
         horaFim: horaFim,
         local: local,
         valorLocacao: valorLocacao,
         termoLocacao: termoLocacao,
         para: para,
         dataCriacao: dataCriacao,
         dataAtualizacao: dataAtualizacao,
         listaPresentes: listaPresentes,
         blocoUnidadeId: blocoUnidadeId,
       );

  /// Converte JSON para Model
  factory ReservaModel.fromJson(Map<String, dynamic> json) {
    // Lógica para definir o nome de quem fez a reserva (Para)
    String? nomeResponsavel;
    if (json['inquilinos'] != null) {
      nomeResponsavel = json['inquilinos']['nome'];
    } else if (json['representantes'] != null) {
      nomeResponsavel = json['representantes']['nome_completo'];
    } else if (json['proprietarios'] != null) {
      // Adicionado suporte para Proprietário
      nomeResponsavel = json['proprietarios']['nome'];
    }

    return ReservaModel(
      id: json['id'] as String? ?? '',
      ambienteId: json['ambiente_id'] as String? ?? '',
      representanteId: json['representante_id'] as String?,
      inquilinoId: json['inquilino_id'] as String?,
      proprietarioId: json['proprietario_id'] as String?,
      dataReserva: json['data_reserva'] != null
          ? DateTime.parse(json['data_reserva'] as String)
          : DateTime.now(),
      horaInicio: json['hora_inicio'] as String? ?? '00:00',
      horaFim: json['hora_fim'] as String? ?? '00:00',
      local: json['local'] as String? ?? '',
      valorLocacao: (json['valor_locacao'] as num?)?.toDouble() ?? 0.0,
      termoLocacao: json['termo_locacao'] as bool? ?? false,
      para: nomeResponsavel ?? json['para'] as String? ?? 'Condomínio',
      dataCriacao: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      dataAtualizacao: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      listaPresentes: json['lista_presentes'] as String?,
      blocoUnidadeId: json['bloco_unidade_id'] as String?,
    );
  }

  /// Converte Model para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ambiente_id': ambienteId,
      'representante_id': representanteId,
      'inquilino_id': inquilinoId,
      'proprietario_id': proprietarioId,
      'data_reserva': dataReserva.toIso8601String().split('T')[0],
      'hora_inicio': horaInicio,
      'hora_fim': horaFim,
      'local': local,
      'valor_locacao': valorLocacao,
      'termo_locacao': termoLocacao,
      'para': para,
      'lista_presentes': listaPresentes,
      'bloco_unidade_id': blocoUnidadeId,
    };
  }
}
