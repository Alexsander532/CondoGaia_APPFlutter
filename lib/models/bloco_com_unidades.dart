import 'bloco.dart';
import 'unidade.dart';

class BlocoComUnidades {
  final Bloco bloco;
  final List<Unidade> unidades;

  BlocoComUnidades({
    required this.bloco,
    required this.unidades,
  });

  // Converter do JSON retornado pela função listar_unidades_condominio
  factory BlocoComUnidades.fromJson(Map<String, dynamic> json) {
    final blocoData = json['bloco'] as Map<String, dynamic>;
    final unidadesData = json['unidades'] as List<dynamic>? ?? [];

    return BlocoComUnidades(
      bloco: Bloco(
        id: blocoData['id'] ?? '',
        condominioId: '', // Será preenchido pelo contexto
        nome: blocoData['nome'] ?? '',
        codigo: blocoData['codigo'] ?? '',
        ordem: blocoData['ordem'] ?? 0,
        ativo: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      unidades: unidadesData
          .map((unidadeData) => Unidade(
                id: unidadeData['id'] ?? '',
                condominioId: '', // Será preenchido pelo contexto
                numero: unidadeData['numero'] ?? '',
                bloco: blocoData['nome'] ?? '',
                ativo: unidadeData['ativo'] ?? true,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ))
          .toList(),
    );
  }

  // Estatísticas do bloco
  int get totalUnidades => unidades.length;
  // Como o novo modelo não tem mais temMoradores, consideramos todas as unidades ativas como potencialmente ocupadas
  int get unidadesOcupadas => unidades.where((u) => u.ativo).length;
  int get totalUnidadesOcupadas => unidadesOcupadas; // Alias para compatibilidade
  // Para unidades vazias, consideramos as inativas ou sem dados preenchidos
  int get unidadesVazias => unidades.where((u) => !u.ativo || (u.numero.isEmpty)).length;
  // Como não temos mais temImobiliaria, retornamos 0 por enquanto
  int get unidadesComImobiliaria => 0;

  // Ordenar unidades por número
  List<Unidade> get unidadesOrdenadas {
    final lista = List<Unidade>.from(unidades);
    lista.sort((a, b) {
      // Tentar converter para número, se falhar usar comparação de string
      try {
        final numA = int.parse(a.numero);
        final numB = int.parse(b.numero);
        return numA.compareTo(numB);
      } catch (e) {
        return a.numero.compareTo(b.numero);
      }
    });
    return lista;
  }

  @override
  String toString() {
    return 'BlocoComUnidades{bloco: ${bloco.nome}, unidades: ${unidades.length}}';
  }
}

// Classe para estatísticas do condomínio
class EstatisticasCondominio {
  final int totalBlocos;
  final int totalUnidades;
  final int unidadesComMoradores;
  final int unidadesComProprietario;
  final int unidadesComInquilino;
  final int unidadesComImobiliaria;
  final int totalProprietarios;
  final int totalInquilinos;
  final int totalImobiliarias;

  EstatisticasCondominio({
    required this.totalBlocos,
    required this.totalUnidades,
    required this.unidadesComMoradores,
    required this.unidadesComProprietario,
    required this.unidadesComInquilino,
    required this.unidadesComImobiliaria,
    required this.totalProprietarios,
    required this.totalInquilinos,
    required this.totalImobiliarias,
  });

  factory EstatisticasCondominio.fromJson(Map<String, dynamic> json) {
    return EstatisticasCondominio(
      totalBlocos: json['total_blocos'] ?? 0,
      totalUnidades: json['total_unidades'] ?? 0,
      unidadesComMoradores: json['unidades_com_moradores'] ?? 0,
      unidadesComProprietario: json['unidades_com_proprietario'] ?? 0,
      unidadesComInquilino: json['unidades_com_inquilino'] ?? 0,
      unidadesComImobiliaria: json['unidades_com_imobiliaria'] ?? 0,
      totalProprietarios: json['total_proprietarios'] ?? 0,
      totalInquilinos: json['total_inquilinos'] ?? 0,
      totalImobiliarias: json['total_imobiliarias'] ?? 0,
    );
  }

  // Percentual de ocupação
  double get percentualOcupacao {
    if (totalUnidades == 0) return 0.0;
    return (unidadesComMoradores / totalUnidades) * 100;
  }

  // Unidades vazias
  int get unidadesVazias => totalUnidades - unidadesComMoradores - unidadesComImobiliaria;
}