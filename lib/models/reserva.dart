class Reserva {
  final String? id;
  final String ambienteId;
  final String representanteId;
  final DateTime dataReserva;
  final String horaInicio;
  final String horaFim;
  final String para; // Condomínio ou Bloco/Unid
  final String local; // Local da reserva
  final double valorLocacao; // Valor da locação
  final String? listaPresentes; // Lista de presentes (opcional)
  final DateTime? criadoEm;
  final DateTime? atualizadoEm;

  const Reserva({
    this.id,
    required this.ambienteId,
    required this.representanteId,
    required this.dataReserva,
    required this.horaInicio,
    required this.horaFim,
    required this.para,
    required this.local,
    required this.valorLocacao,
    this.listaPresentes,
    this.criadoEm,
    this.atualizadoEm,
  });

  // Construtor para criar uma instância a partir de JSON (Supabase)
  factory Reserva.fromJson(Map<String, dynamic> json) {
    return Reserva(
      id: json['id']?.toString(),
      ambienteId: json['ambiente_id']?.toString() ?? '',
      representanteId: json['representante_id']?.toString() ?? '',
      dataReserva: DateTime.parse(json['data_reserva']),
      horaInicio: json['hora_inicio'] ?? '',
      horaFim: json['hora_fim'] ?? '',
      para: json['para'] ?? 'Condomínio',
      local: json['local'] ?? '',
      valorLocacao: (json['valor_locacao'] ?? 0.0).toDouble(),
      listaPresentes: json['lista_presentes'],
      criadoEm: json['created_at'] != null 
          ? DateTime.parse(json['created_at'])
          : null,
      atualizadoEm: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  // Converter para JSON (para enviar ao Supabase)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'ambiente_id': ambienteId,
      'representante_id': representanteId,
      'data_reserva': dataReserva.toIso8601String().split('T')[0], // Apenas a data
      'hora_inicio': horaInicio,
      'hora_fim': horaFim,
      'para': para,
      'local': local,
      'valor_locacao': valorLocacao,
      if (listaPresentes != null) 'lista_presentes': listaPresentes,
      if (criadoEm != null) 'created_at': criadoEm!.toIso8601String(),
      if (atualizadoEm != null) 'updated_at': atualizadoEm!.toIso8601String(),
    };
  }

  // Método para criar uma cópia com alterações
  Reserva copyWith({
    String? id,
    String? ambienteId,
    String? representanteId,
    DateTime? dataReserva,
    String? horaInicio,
    String? horaFim,
    String? para,
    String? local,
    double? valorLocacao,
    String? listaPresentes,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) {
    return Reserva(
      id: id ?? this.id,
      ambienteId: ambienteId ?? this.ambienteId,
      representanteId: representanteId ?? this.representanteId,
      dataReserva: dataReserva ?? this.dataReserva,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFim: horaFim ?? this.horaFim,
      para: para ?? this.para,
      local: local ?? this.local,
      valorLocacao: valorLocacao ?? this.valorLocacao,
      listaPresentes: listaPresentes ?? this.listaPresentes,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }

  // Método para validar se a reserva está configurada corretamente
  bool get isValid {
    return ambienteId.isNotEmpty && 
           representanteId.isNotEmpty && 
           horaInicio.isNotEmpty && 
           horaFim.isNotEmpty &&
           valorLocacao >= 0;
  }

  // Método para verificar se a reserva é para hoje
  bool get isHoje {
    final hoje = DateTime.now();
    return dataReserva.year == hoje.year &&
           dataReserva.month == hoje.month &&
           dataReserva.day == hoje.day;
  }

  // Método para verificar se a reserva é futura
  bool get isFutura {
    final hoje = DateTime.now();
    return dataReserva.isAfter(hoje);
  }

  // Método para formatar a data da reserva
  String get dataFormatada {
    return '${dataReserva.day.toString().padLeft(2, '0')}/'
           '${dataReserva.month.toString().padLeft(2, '0')}/'
           '${dataReserva.year}';
  }

  // Método para formatar o horário da reserva
  String get horarioFormatado {
    return '$horaInicio às $horaFim';
  }

  // Método para formatar o valor como moeda
  String get valorFormatado {
    return 'R\$ ${valorLocacao.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  // Método para calcular a duração da reserva em horas
  double get duracaoEmHoras {
    try {
      final inicio = _parseHora(horaInicio);
      final fim = _parseHora(horaFim);
      
      if (fim.isBefore(inicio)) {
        // Caso a reserva passe da meia-noite
        final duracao1 = Duration(hours: 24) - inicio.difference(DateTime(0));
        final duracao2 = fim.difference(DateTime(0));
        return (duracao1 + duracao2).inMinutes / 60.0;
      } else {
        return fim.difference(inicio).inMinutes / 60.0;
      }
    } catch (e) {
      return 0.0;
    }
  }

  // Método auxiliar para converter string de hora em DateTime
  DateTime _parseHora(String hora) {
    final partes = hora.split(':');
    final horas = int.parse(partes[0]);
    final minutos = partes.length > 1 ? int.parse(partes[1]) : 0;
    return DateTime(0, 1, 1, horas, minutos);
  }

  // Método para verificar se há conflito com outra reserva
  bool temConflitoCom(Reserva outraReserva) {
    if (ambienteId != outraReserva.ambienteId) return false;
    if (dataReserva != outraReserva.dataReserva) return false;
    
    try {
      final inicioThis = _parseHora(horaInicio);
      final fimThis = _parseHora(horaFim);
      final inicioOutra = _parseHora(outraReserva.horaInicio);
      final fimOutra = _parseHora(outraReserva.horaFim);
      
      return !(fimThis.isBefore(inicioOutra) || inicioThis.isAfter(fimOutra));
    } catch (e) {
      return false;
    }
  }

  @override
  String toString() {
    return 'Reserva{id: $id, ambiente: $ambienteId, data: $dataFormatada, horario: $horarioFormatado}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Reserva && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}