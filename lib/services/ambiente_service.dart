import '../models/ambiente.dart';
import 'supabase_service.dart';

class AmbienteService {
  /// Buscar todos os ambientes ativos
  /// Nota: Como a tabela não tem condominio_id nem ativo, buscaremos todos os ambientes
  static Future<List<Ambiente>> getAmbientes() async {
    try {
      final response = await SupabaseService.client
          .from('ambientes')
          .select()
          .order('titulo');
      
      return response.map((json) => Ambiente.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar ambientes: $e');
    }
  }

  /// Buscar um ambiente específico por ID
  static Future<Ambiente?> getAmbiente(String ambienteId) async {
    try {
      final response = await SupabaseService.client
          .from('ambientes')
          .select()
          .eq('id', ambienteId)
          .single();
      
      return Ambiente.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Criar um novo ambiente
  static Future<Ambiente> criarAmbiente({
    required String titulo,
    String? descricao,
    required double valor,
    String? limiteHorario,
    String? limiteTempoDuracao,
    String? diasBloqueados,
    bool inadimplentePodemReservar = false,
    String? createdBy,
  }) async {
    try {
      final ambiente = Ambiente(
        titulo: titulo,
        descricao: descricao,
        valor: valor,
        limiteHorario: limiteHorario,
        limiteTempoDuracao: limiteTempoDuracao,
        diasBloqueados: diasBloqueados,
        inadimplentePodemReservar: inadimplentePodemReservar,
        createdBy: createdBy,
      );

      final response = await SupabaseService.client
          .from('ambientes')
          .insert(ambiente.toJson())
          .select()
          .single();
      
      return Ambiente.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao criar ambiente: $e');
    }
  }

  /// Atualizar um ambiente existente
  static Future<Ambiente> atualizarAmbiente(
    String ambienteId, {
    String? titulo,
    String? descricao,
    double? valor,
    String? limiteHorario,
    String? limiteTempoDuracao,
    String? diasBloqueados,
    bool? inadimplentePodemReservar,
    String? updatedBy,
  }) async {
    try {
      final dados = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      if (titulo != null) dados['titulo'] = titulo;
      if (descricao != null) dados['descricao'] = descricao;
      if (valor != null) dados['valor'] = valor;
      if (limiteHorario != null) dados['limite_horario'] = limiteHorario;
      if (limiteTempoDuracao != null) dados['limite_tempo_duracao'] = limiteTempoDuracao;
      if (diasBloqueados != null) dados['dias_bloqueados'] = diasBloqueados;
      if (inadimplentePodemReservar != null) dados['inadiplente_podem_assinar'] = inadimplentePodemReservar;
      if (updatedBy != null) dados['updated_by'] = updatedBy;

      final response = await SupabaseService.client
          .from('ambientes')
          .update(dados)
          .eq('id', ambienteId)
          .select()
          .single();
      
      return Ambiente.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao atualizar ambiente: $e');
    }
  }

  /// Deletar um ambiente permanentemente
  /// Nota: Como não há campo 'ativo', implementamos delete real
  static Future<bool> deletarAmbiente(String ambienteId) async {
    try {
      await SupabaseService.client
          .from('ambientes')
          .delete()
          .eq('id', ambienteId);
      
      return true;
    } catch (e) {
      throw Exception('Erro ao deletar ambiente: $e');
    }
  }

  /// Método mantido para compatibilidade (agora faz delete real)
  static Future<bool> desativarAmbiente(String ambienteId, {String? atualizadoPor}) async {
    return await deletarAmbiente(ambienteId);
  }

  /// Verificar se um ambiente pode ser reservado
  static Future<bool> podeReservar(String ambienteId, {bool? inadimplente}) async {
    try {
      final ambiente = await getAmbiente(ambienteId);
      if (ambiente == null) return false;
      
      // Se o usuário é inadimplente, verificar se inadimplentes podem reservar
      if (inadimplente == true && !ambiente.inadimplentePodemReservar) {
        return false;
      }
      
      return true; // Ambiente existe, pode reservar
    } catch (e) {
      return false;
    }
  }

  /// Verificar se um dia da semana está bloqueado para um ambiente
  static Future<bool> isDiaBloqueado(String ambienteId, dynamic dia) async {
    try {
      final ambiente = await getAmbiente(ambienteId);
      if (ambiente == null) return true;
      
      return ambiente.diasBloqueados?.contains(dia) ?? true;
    } catch (e) {
      return true;
    }
  }

  /// Buscar ambientes disponíveis para reserva
  static Future<List<Ambiente>> getAmbientesDisponiveis({bool? inadimplente}) async {
    try {
      final ambientes = await getAmbientes();
      
      if (inadimplente == true) {
        // Filtrar apenas ambientes que permitem inadimplentes
        return ambientes.where((ambiente) => ambiente.inadimplentePodemReservar).toList();
      }
      
      return ambientes;
    } catch (e) {
      throw Exception('Erro ao buscar ambientes disponíveis: $e');
    }
  }

  /// Buscar ambientes por título (busca parcial)
  static Future<List<Ambiente>> buscarAmbientesPorTitulo(String termo) async {
    try {
      final response = await SupabaseService.client
          .from('ambientes')
          .select()
          .ilike('titulo', '%$termo%')
          .order('titulo');
      
      return response.map((json) => Ambiente.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar ambientes por título: $e');
    }
  }

  /// Buscar ambientes por faixa de valor
  static Future<List<Ambiente>> buscarAmbientesPorValor({
    double? valorMinimo,
    double? valorMaximo,
  }) async {
    try {
      var query = SupabaseService.client.from('ambientes').select();
      
      if (valorMinimo != null) {
        query = query.gte('valor', valorMinimo);
      }
      
      if (valorMaximo != null) {
        query = query.lte('valor', valorMaximo);
      }
      
      final response = await query.order('valor');
      
      return response.map((json) => Ambiente.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar ambientes por valor: $e');
    }
  }
}