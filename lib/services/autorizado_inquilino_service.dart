import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/autorizado_inquilino.dart';
import 'supabase_service.dart';

class AutorizadoInquilinoService {
  static SupabaseClient get _client => SupabaseService.client;

  /// Busca todos os autorizados de uma unidade específica
  static Future<List<AutorizadoInquilino>> getAutorizadosByUnidade(
    String unidadeId,
  ) async {
    try {
      final response = await _client
          .from('autorizados_inquilinos')
          .select()
          .eq('unidade_id', unidadeId)
          .eq('ativo', true)
          .order('created_at', ascending: false);

      return response
          .map<AutorizadoInquilino>((json) => AutorizadoInquilino.fromJson(json))
          .toList();
    } catch (e) {
      print('Erro ao buscar autorizados da unidade: $e');
      rethrow;
    }
  }

  /// Busca todos os autorizados de um inquilino específico
  static Future<List<AutorizadoInquilino>> getAutorizadosByInquilino(
    String inquilinoId,
  ) async {
    try {
      final response = await _client
          .from('autorizados_inquilinos')
          .select()
          .eq('inquilino_id', inquilinoId)
          .eq('ativo', true)
          .order('created_at', ascending: false);

      return response
          .map<AutorizadoInquilino>((json) => AutorizadoInquilino.fromJson(json))
          .toList();
    } catch (e) {
      print('Erro ao buscar autorizados do inquilino: $e');
      rethrow;
    }
  }

  /// Busca todos os autorizados de um proprietário específico
  static Future<List<AutorizadoInquilino>> getAutorizadosByProprietario(
    String proprietarioId,
  ) async {
    try {
      final response = await _client
          .from('autorizados_inquilinos')
          .select()
          .eq('proprietario_id', proprietarioId)
          .eq('ativo', true)
          .order('created_at', ascending: false);

      return response
          .map<AutorizadoInquilino>((json) => AutorizadoInquilino.fromJson(json))
          .toList();
    } catch (e) {
      print('Erro ao buscar autorizados do proprietário: $e');
      rethrow;
    }
  }

  /// Busca um autorizado específico pelo ID
  static Future<AutorizadoInquilino?> getAutorizadoById(String id) async {
    try {
      final response = await _client
          .from('autorizados_inquilinos')
          .select()
          .eq('id', id)
          .single();

      return AutorizadoInquilino.fromJson(response);
    } catch (e) {
      print('Erro ao buscar autorizado por ID: $e');
      return null;
    }
  }

  /// Insere um novo autorizado
  static Future<AutorizadoInquilino?> insertAutorizado(
    Map<String, dynamic> autorizadoData,
  ) async {
    try {
      // Validações básicas
      if (!_validarDadosObrigatorios(autorizadoData)) {
        throw Exception('Dados obrigatórios não fornecidos');
      }

      if (!_validarCPF(autorizadoData['cpf'])) {
        throw Exception('CPF inválido');
      }

      if (!_validarVinculo(autorizadoData)) {
        throw Exception('Autorizado deve estar vinculado a um inquilino OU proprietário');
      }

      // Validar se já existe autorizado com mesmo CPF na unidade
      final cpfExistente = await _verificarCPFExistente(
        autorizadoData['cpf'],
        autorizadoData['unidade_id'],
      );

      if (cpfExistente) {
        throw Exception('Já existe um autorizado com este CPF nesta unidade');
      }

      final response = await _client
          .from('autorizados_inquilinos')
          .insert(autorizadoData)
          .select()
          .single();

      return AutorizadoInquilino.fromJson(response);
    } catch (e) {
      print('Erro ao inserir autorizado: $e');
      rethrow;
    }
  }

  /// Atualiza um autorizado existente
  static Future<AutorizadoInquilino?> updateAutorizado(
    String id,
    Map<String, dynamic> autorizadoData,
  ) async {
    try {
      // Validações básicas
      if (autorizadoData.containsKey('cpf') && !_validarCPF(autorizadoData['cpf'])) {
        throw Exception('CPF inválido');
      }

      // Adicionar timestamp de atualização
      autorizadoData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .from('autorizados_inquilinos')
          .update(autorizadoData)
          .eq('id', id)
          .select()
          .single();

      return AutorizadoInquilino.fromJson(response);
    } catch (e) {
      print('Erro ao atualizar autorizado: $e');
      rethrow;
    }
  }

  /// Remove um autorizado (soft delete - marca como inativo)
  static Future<bool> deleteAutorizado(String id) async {
    try {
      await _client
          .from('autorizados_inquilinos')
          .update({
            'ativo': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);

      return true;
    } catch (e) {
      print('Erro ao remover autorizado: $e');
      return false;
    }
  }

  /// Remove um autorizado permanentemente (hard delete)
  static Future<bool> deleteAutorizadoPermanente(String id) async {
    try {
      await _client
          .from('autorizados_inquilinos')
          .delete()
          .eq('id', id);

      return true;
    } catch (e) {
      print('Erro ao remover autorizado permanentemente: $e');
      return false;
    }
  }

  /// Busca autorizados por nome (busca parcial)
  static Future<List<AutorizadoInquilino>> searchAutorizadosByNome(
    String unidadeId,
    String nome,
  ) async {
    try {
      final response = await _client
          .from('autorizados_inquilinos')
          .select()
          .eq('unidade_id', unidadeId)
          .eq('ativo', true)
          .ilike('nome', '%$nome%')
          .order('nome', ascending: true);

      return response
          .map<AutorizadoInquilino>((json) => AutorizadoInquilino.fromJson(json))
          .toList();
    } catch (e) {
      print('Erro ao buscar autorizados por nome: $e');
      rethrow;
    }
  }

  /// Busca autorizados por CPF
  static Future<List<AutorizadoInquilino>> searchAutorizadosByCPF(
    String unidadeId,
    String cpf,
  ) async {
    try {
      final response = await _client
          .from('autorizados_inquilinos')
          .select()
          .eq('unidade_id', unidadeId)
          .eq('ativo', true)
          .eq('cpf', cpf);

      return response
          .map<AutorizadoInquilino>((json) => AutorizadoInquilino.fromJson(json))
          .toList();
    } catch (e) {
      print('Erro ao buscar autorizados por CPF: $e');
      rethrow;
    }
  }

  /// Reativa um autorizado inativo
  static Future<AutorizadoInquilino?> reativarAutorizado(String id) async {
    try {
      final response = await _client
          .from('autorizados_inquilinos')
          .update({
            'ativo': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();

      return AutorizadoInquilino.fromJson(response);
    } catch (e) {
      print('Erro ao reativar autorizado: $e');
      rethrow;
    }
  }

  // MÉTODOS PRIVADOS DE VALIDAÇÃO

  /// Valida se os dados obrigatórios foram fornecidos
  static bool _validarDadosObrigatorios(Map<String, dynamic> data) {
    return data.containsKey('unidade_id') &&
           data.containsKey('nome') &&
           data.containsKey('cpf') &&
           data['unidade_id'] != null &&
           data['nome'] != null &&
           data['cpf'] != null &&
           data['nome'].toString().trim().isNotEmpty &&
           data['cpf'].toString().trim().isNotEmpty;
  }

  /// Valida se o autorizado está vinculado a um inquilino OU proprietário
  static bool _validarVinculo(Map<String, dynamic> data) {
    final temInquilino = data.containsKey('inquilino_id') && data['inquilino_id'] != null;
    final temProprietario = data.containsKey('proprietario_id') && data['proprietario_id'] != null;
    
    // Deve ter um OU outro, mas não ambos
    return (temInquilino && !temProprietario) || (!temInquilino && temProprietario);
  }

  /// Valida formato básico do CPF
  static bool _validarCPF(String cpf) {
    if (cpf.isEmpty) return false;
    
    // Remove caracteres não numéricos
    final cpfLimpo = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Verifica se tem 11 dígitos
    if (cpfLimpo.length != 11) return false;
    
    // Verifica se não são todos os dígitos iguais
    if (RegExp(r'^(\d)\1{10}$').hasMatch(cpfLimpo)) return false;
    
    return true;
  }

  /// Verifica se já existe um autorizado com o mesmo CPF na unidade
  static Future<bool> _verificarCPFExistente(String cpf, String unidadeId) async {
    try {
      final response = await _client
          .from('autorizados_inquilinos')
          .select('id')
          .eq('unidade_id', unidadeId)
          .eq('cpf', cpf)
          .eq('ativo', true);

      return response.isNotEmpty;
    } catch (e) {
      print('Erro ao verificar CPF existente: $e');
      return false;
    }
  }

  /// Valida formato da placa do veículo (formato brasileiro)
  static bool validarPlaca(String? placa) {
    if (placa == null || placa.isEmpty) return true; // Placa é opcional
    
    final placaLimpa = placa.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
    
    // Formato antigo: ABC1234
    final formatoAntigo = RegExp(r'^[A-Z]{3}[0-9]{4}$');
    
    // Formato Mercosul: ABC1D23
    final formatoMercosul = RegExp(r'^[A-Z]{3}[0-9][A-Z][0-9]{2}$');
    
    return formatoAntigo.hasMatch(placaLimpa) || formatoMercosul.hasMatch(placaLimpa);
  }

  /// Valida formato do horário (HH:MM)
  static bool validarHorario(String? horario) {
    if (horario == null || horario.isEmpty) return true; // Horário é opcional
    
    final regex = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$');
    return regex.hasMatch(horario);
  }

  /// Valida se os dias da semana estão no intervalo correto (0-6)
  static bool validarDiasSemana(List<int>? dias) {
    if (dias == null || dias.isEmpty) return true; // Dias são opcionais
    
    return dias.every((dia) => dia >= 0 && dia <= 6);
  }
}