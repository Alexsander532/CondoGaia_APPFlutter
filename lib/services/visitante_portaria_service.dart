import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/visitante_portaria.dart';
import 'supabase_service.dart';

/// Serviço para gerenciar visitantes da portaria do representante
class VisitantePortariaService {
  static SupabaseClient get _client => SupabaseService.client;
  static const String _tableName =
      'autorizados_visitantes_portaria_representante';

  /// Insere um novo visitante
  static Future<VisitantePortaria?> insertVisitante(
    Map<String, dynamic> visitanteData,
  ) async {
    try {
      // Validações básicas
      if (!_validarDadosObrigatorios(visitanteData)) {
        throw Exception(
          'Dados obrigatórios não fornecidos (nome, CPF, celular)',
        );
      }

      if (!_validarCPF(visitanteData['cpf'])) {
        throw Exception('CPF inválido');
      }

      if (!_validarCelular(visitanteData['celular'])) {
        throw Exception('Celular inválido');
      }

      if (!_validarTipoAutorizacao(visitanteData)) {
        throw Exception('Tipo de autorização inválido ou dados inconsistentes');
      }

      // Validar se já existe visitante com mesmo CPF na data
      final cpfExistente = await _verificarCPFExistenteNaData(
        visitanteData['cpf'],
        visitanteData['condominio_id'],
        visitanteData['data_visita'],
      );

      if (cpfExistente) {
        throw Exception(
          'Já existe um visitante com este CPF agendado para esta data',
        );
      }

      final response = await _client
          .from(_tableName)
          .insert(visitanteData)
          .select()
          .single();

      return VisitantePortaria.fromJson(response);
    } catch (e) {
      print('Erro ao inserir visitante: $e');
      rethrow;
    }
  }

  /// Busca visitantes por condomínio com filtros opcionais
  static Future<List<VisitantePortaria>> getVisitantesByCondominio(
    String condominioId, {
    DateTime? dataInicio,
    DateTime? dataFim,
    String? status,
  }) async {
    try {
      dynamic query = _client
          .from(_tableName)
          .select()
          .eq('condominio_id', condominioId)
          .eq('ativo', true);

      // Filtro por data de início
      if (dataInicio != null) {
        query = query.gte(
          'data_visita',
          dataInicio.toIso8601String().split('T')[0],
        );
      }

      // Filtro por data de fim
      if (dataFim != null) {
        query = query.lte(
          'data_visita',
          dataFim.toIso8601String().split('T')[0],
        );
      }

      // Filtro por status
      if (status != null && status.isNotEmpty) {
        query = query.eq('status_visita', status);
      }

      query = query
          .order('data_visita', ascending: false)
          .order('created_at', ascending: false);

      final response = await query;

      return response
          .map<VisitantePortaria>((json) => VisitantePortaria.fromJson(json))
          .toList();
    } catch (e) {
      print('Erro ao buscar visitantes por condomínio: $e');
      rethrow;
    }
  }

  /// Busca visitantes por unidade
  static Future<List<VisitantePortaria>> getVisitantesByUnidade(
    String unidadeId, {
    DateTime? dataInicio,
    DateTime? dataFim,
  }) async {
    try {
      dynamic query = _client
          .from(_tableName)
          .select()
          .eq('unidade_id', unidadeId)
          .eq('ativo', true);

      // Filtro por data de início
      if (dataInicio != null) {
        query = query.gte(
          'data_visita',
          dataInicio.toIso8601String().split('T')[0],
        );
      }

      // Filtro por data de fim
      if (dataFim != null) {
        query = query.lte(
          'data_visita',
          dataFim.toIso8601String().split('T')[0],
        );
      }

      query = query.order('data_visita', ascending: false);

      final response = await query;

      return response
          .map<VisitantePortaria>((json) => VisitantePortaria.fromJson(json))
          .toList();
    } catch (e) {
      print('Erro ao buscar visitantes por unidade: $e');
      rethrow;
    }
  }

  /// Busca um visitante por ID
  static Future<VisitantePortaria?> getVisitanteById(String id) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('id', id)
          .single();

      return VisitantePortaria.fromJson(response);
    } catch (e) {
      print('Erro ao buscar visitante por ID: $e');
      return null;
    }
  }

  /// Atualiza um visitante existente
  static Future<VisitantePortaria?> updateVisitante(
    String id,
    Map<String, dynamic> visitanteData,
  ) async {
    try {
      final response = await _client
          .from(_tableName)
          .update(visitanteData)
          .eq('id', id)
          .select()
          .single();

      return VisitantePortaria.fromJson(response);
    } catch (e) {
      print('Erro ao atualizar visitante: $e');
      rethrow;
    }
  }

  /// Atualiza o status de um visitante
  static Future<VisitantePortaria?> updateStatusVisitante(
    String id,
    String novoStatus, {
    String? horaEntrada,
    String? horaSaida,
  }) async {
    try {
      final updateData = <String, dynamic>{'status_visita': novoStatus};

      if (horaEntrada != null) {
        updateData['hora_entrada'] = horaEntrada;
      }

      if (horaSaida != null) {
        updateData['hora_saida'] = horaSaida;
      }

      final response = await _client
          .from(_tableName)
          .update(updateData)
          .eq('id', id)
          .select()
          .single();

      return VisitantePortaria.fromJson(response);
    } catch (e) {
      print('Erro ao atualizar status do visitante: $e');
      rethrow;
    }
  }

  /// Desativa um visitante (soft delete)
  static Future<bool> deleteVisitante(String id) async {
    try {
      await _client.from(_tableName).update({'ativo': false}).eq('id', id);

      return true;
    } catch (e) {
      print('Erro ao desativar visitante: $e');
      return false;
    }
  }

  /// Busca visitantes por CPF
  static Future<List<VisitantePortaria>> getVisitantesByCpf(
    String cpf,
    String condominioId,
  ) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('cpf', cpf)
          .eq('condominio_id', condominioId)
          .eq('ativo', true)
          .order('data_visita', ascending: false);

      return response
          .map<VisitantePortaria>((json) => VisitantePortaria.fromJson(json))
          .toList();
    } catch (e) {
      print('Erro ao buscar visitantes por CPF: $e');
      rethrow;
    }
  }

  // =====================================================
  // MÉTODOS PRIVADOS DE VALIDAÇÃO
  // =====================================================

  /// Valida se os dados obrigatórios estão presentes
  static bool _validarDadosObrigatorios(Map<String, dynamic> data) {
    final nome = data['nome']?.toString().trim();
    final cpf = data['cpf']?.toString().trim();
    final celular = data['celular']?.toString().trim();
    final condominioId = data['condominio_id']?.toString().trim();

    return nome != null &&
        nome.isNotEmpty &&
        cpf != null &&
        cpf.isNotEmpty &&
        celular != null &&
        celular.isNotEmpty &&
        condominioId != null &&
        condominioId.isNotEmpty;
  }

  /// Valida o formato do CPF
  static bool _validarCPF(String? cpf) {
    if (cpf == null || cpf.isEmpty) return false;

    // Remove caracteres não numéricos
    final cpfLimpo = cpf.replaceAll(RegExp(r'[^0-9]'), '');

    // Verifica se tem 11 dígitos
    if (cpfLimpo.length != 11) return false;

    // Verifica se não são todos os dígitos iguais
    if (RegExp(r'^(\d)\1{10}$').hasMatch(cpfLimpo)) return false;

    // Validação dos dígitos verificadores
    int soma = 0;
    for (int i = 0; i < 9; i++) {
      soma += int.parse(cpfLimpo[i]) * (10 - i);
    }
    int digito1 = 11 - (soma % 11);
    if (digito1 >= 10) digito1 = 0;

    soma = 0;
    for (int i = 0; i < 10; i++) {
      soma += int.parse(cpfLimpo[i]) * (11 - i);
    }
    int digito2 = 11 - (soma % 11);
    if (digito2 >= 10) digito2 = 0;

    return int.parse(cpfLimpo[9]) == digito1 &&
        int.parse(cpfLimpo[10]) == digito2;
  }

  /// Valida o formato do celular
  static bool _validarCelular(String? celular) {
    if (celular == null || celular.isEmpty) return false;

    // Remove caracteres não numéricos
    final celularLimpo = celular.replaceAll(RegExp(r'[^0-9]'), '');

    // Verifica se tem 10 ou 11 dígitos (com DDD)
    return celularLimpo.length == 10 || celularLimpo.length == 11;
  }

  /// Valida o tipo de autorização e dados relacionados
  static bool _validarTipoAutorizacao(Map<String, dynamic> data) {
    final tipoAutorizacao = data['tipo_autorizacao']?.toString();
    final unidadeId = data['unidade_id']?.toString();
    final quemAutorizou = data['quem_autorizou']?.toString();

    if (tipoAutorizacao == null || tipoAutorizacao.isEmpty) {
      return false;
    }

    // Se tipo é 'unidade', deve ter unidade_id
    if (tipoAutorizacao == 'unidade') {
      return unidadeId != null && unidadeId.isNotEmpty;
    }

    // Se tipo é 'condominio', deve ter quem_autorizou e não deve ter unidade_id
    if (tipoAutorizacao == 'condominio') {
      return (quemAutorizou != null && quemAutorizou.isNotEmpty) &&
          (unidadeId == null || unidadeId.isEmpty);
    }

    return false;
  }

  /// Verifica se já existe visitante com mesmo CPF na data
  static Future<bool> _verificarCPFExistenteNaData(
    String cpf,
    String condominioId,
    String dataVisita,
  ) async {
    try {
      final response = await _client
          .from(_tableName)
          .select('id')
          .eq('cpf', cpf)
          .eq('condominio_id', condominioId)
          .eq('data_visita', dataVisita)
          .eq('ativo', true);

      return response.isNotEmpty;
    } catch (e) {
      print('Erro ao verificar CPF existente: $e');
      return false;
    }
  }

  /// Formata CPF para o padrão 000.000.000-00
  static String formatarCPF(String cpf) {
    final cpfLimpo = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    if (cpfLimpo.length != 11) return cpf;

    return '${cpfLimpo.substring(0, 3)}.${cpfLimpo.substring(3, 6)}.${cpfLimpo.substring(6, 9)}-${cpfLimpo.substring(9, 11)}';
  }

  /// Formata celular para o padrão (00) 00000-0000
  static String formatarCelular(String celular) {
    final celularLimpo = celular.replaceAll(RegExp(r'[^0-9]'), '');

    if (celularLimpo.length == 11) {
      return '(${celularLimpo.substring(0, 2)}) ${celularLimpo.substring(2, 7)}-${celularLimpo.substring(7, 11)}';
    } else if (celularLimpo.length == 10) {
      return '(${celularLimpo.substring(0, 2)}) ${celularLimpo.substring(2, 6)}-${celularLimpo.substring(6, 10)}';
    }

    return celular;
  }

  /// Faz upload de foto de visitante para Supabase Storage
  static Future<String?> uploadFotoVisitante({
    required String condominioId,
    required File arquivo,
    required String nomeArquivo,
  }) async {
    try {
      print('📸 Iniciando upload de foto para visitante...');
      print('   - Condomínio: $condominioId');
      print('   - Arquivo: $nomeArquivo');

      // Caminho no storage: condominio_id/nomeArquivo
      final caminhoStorage = '$condominioId/$nomeArquivo';

      // Fazer upload para o bucket 'visitante_adicionado_pelo_representante'
      final response = await _client.storage
          .from('visitante_adicionado_pelo_representante')
          .upload(
            caminhoStorage,
            arquivo,
            fileOptions: const FileOptions(
              cacheControl: '3600', // Cache de 1 hora
              upsert: true, // Sobrescrever se já existir
            ),
          );

      print('✅ Upload realizado com sucesso: $response');

      // Gerar URL pública
      final urlPublica = _client.storage
          .from('visitante_adicionado_pelo_representante')
          .getPublicUrl(caminhoStorage);

      print('🔗 URL Pública: $urlPublica');
      return urlPublica;
    } catch (e) {
      print('❌ Erro ao fazer upload de foto: $e');
      rethrow;
    }
  }
}
