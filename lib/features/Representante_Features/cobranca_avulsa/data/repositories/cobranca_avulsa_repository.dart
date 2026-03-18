import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cobranca_avulsa_model.dart';
import '../../domain/entities/cobranca_avulsa_entity.dart';
import 'dart:convert';
import 'package:condogaiaapp/services/laravel_api_service.dart';

class CobrancaAvulsaRepository {
  final SupabaseClient _supabase;

  CobrancaAvulsaRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  Future<List<CobrancaAvulsaEntity>> getCobrancasAvulsas(String condominioId) async {
    final response = await _supabase
        .from('cobrancas_avulsas')
        .select()
        .eq('condominio_id', condominioId)
        .order('created_at', ascending: false);

    return (response as List).map((e) => CobrancaAvulsaModel.fromJson(e)).toList();
  }

  Future<CobrancaAvulsaEntity> insertCobrancaAvulsa(CobrancaAvulsaEntity cobranca) async {
    final api = LaravelApiService();
    
    final payload = {
      'condominioId': cobranca.condominioId,
      'unidades': [cobranca.unidadeId],
      'valor': cobranca.valor,
      'dataVencimento': cobranca.dataVencimento?.toIso8601String().split('T')[0] ?? '',
      'descricao': cobranca.descricao ?? '',
      'recorrente': cobranca.recorrente,
      if (cobranca.recorrente) 'qtdMeses': cobranca.qtdMeses,
    };

    final response = await api.post('/asaas/cobrancas/gerar-avulsa', payload);

    if (response.statusCode == 201) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success'] == true) {
        return cobranca;
      } else {
        throw Exception(jsonResponse['message'] ?? 'Erro ao gerar cobrança no backend');
      }
    } else {
       final errorBody = response.body;
       try {
         final jsonErr = jsonDecode(errorBody);
         throw Exception(jsonErr['message'] ?? 'Erro na API: ${response.statusCode}');
       } catch (e) {
         throw Exception('Erro na API (${response.statusCode}): $errorBody');
       }
    }
  }

  Future<void> insertCobrancaAvulsaBatch({
    required String condominioId,
    required List<String> unidades,
    required double valor,
    required DateTime? dataVencimento,
    required String descricao,
    required bool recorrente,
    int? qtdMeses,
  }) async {
    final api = LaravelApiService();
    
    final payload = {
      'condominioId': condominioId,
      'unidades': unidades,
      'valor': valor,
      'dataVencimento': dataVencimento?.toIso8601String().split('T')[0] ?? '',
      'descricao': descricao,
      'recorrente': recorrente,
      if (recorrente) 'qtdMeses': qtdMeses,
    };

    final response = await api.post('/asaas/cobrancas/gerar-avulsa', payload);

    if (response.statusCode != 201) {
       final errorBody = response.body;
       try {
         final jsonErr = jsonDecode(errorBody);
         throw Exception(jsonErr['message'] ?? 'Erro na API: ${response.statusCode}');
       } catch (e) {
         throw Exception('Erro na API (${response.statusCode}): $errorBody');
       }
    }
  }

  Future<String?> uploadComprovante({
    required String condominioId,
    required File arquivo,
  }) async {
    try {
      final ext = arquivo.path.split('.').last.toLowerCase();
      final nomeArquivo = '${condominioId}_${DateTime.now().millisecondsSinceEpoch}.$ext';
      final path = 'comprovantes/$condominioId/$nomeArquivo';

      await _supabase.storage
          .from('cobrancas-avulsas')
          .upload(path, arquivo, fileOptions: const FileOptions(upsert: true));

      return _supabase.storage.from('cobrancas-avulsas').getPublicUrl(path);
    } catch (e) {
      print('⚠️ [CobrancaAvulsaRepository] Erro ao fazer upload do comprovante: $e');
      return null;
    }
  }

  Future<void> deleteCobrancaAvulsa(String id) async {
    await _supabase.from('cobrancas_avulsas').delete().eq('id', id);
  }
}
