import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/leitura_model.dart';
import '../models/leitura_configuracao_model.dart';
import '../../../../models/unidade.dart';

class LeituraService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<LeituraModel>> fetchLeituras({
    required String condominioId,
    required String tipo,
    required int month,
    required int year,
  }) async {
    try {
      final startDate = DateTime(
        year,
        month,
        1,
      ).toIso8601String().split('T').first;
      final endDate = DateTime(
        year,
        month + 1,
        0,
      ).toIso8601String().split('T').first;

      final response = await _supabase
          .from('leituras')
          .select()
          .eq('condominio_id', condominioId)
          .eq('tipo', tipo)
          .gte('data_leitura', startDate)
          .lte('data_leitura', endDate);

      return (response as List)
          .map((e) => LeituraModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      print('Erro ao buscar leituras: $e');
      return [];
    }
  }

  Future<List<Unidade>> fetchUnidades(String condominioId) async {
    try {
      final response = await _supabase
          .from('unidades')
          .select('*')
          .eq('condominio_id', condominioId)
          .eq('ativo', true);

      return (response as List).map((e) {
        final map = Map<String, dynamic>.from(e);
        // O campo 'bloco' já vem preenchido diretamente na tabela unidades
        return Unidade.fromJson(map);
      }).toList();
    } catch (e) {
      print('Erro ao buscar unidades: $e');
      return [];
    }
  }

  /// Busca todas as leituras do mês anterior por unidade (para preencher leitura_anterior)
  Future<Map<String, double>> fetchLeiturasAnteriores({
    required String condominioId,
    required String tipo,
    required int month,
    required int year,
  }) async {
    try {
      int prevMonth = month - 1;
      int prevYear = year;
      if (prevMonth < 1) {
        prevMonth = 12;
        prevYear--;
      }
      final startDate = DateTime(
        prevYear,
        prevMonth,
        1,
      ).toIso8601String().split('T').first;
      final endDate = DateTime(
        prevYear,
        prevMonth + 1,
        0,
      ).toIso8601String().split('T').first;

      final response = await _supabase
          .from('leituras')
          .select('unidade_id, leitura_atual')
          .eq('condominio_id', condominioId)
          .eq('tipo', tipo)
          .gte('data_leitura', startDate)
          .lte('data_leitura', endDate);

      final map = <String, double>{};
      for (final row in response as List) {
        final m = Map<String, dynamic>.from(row);
        map[m['unidade_id'] as String] = (m['leitura_atual'] ?? 0).toDouble();
      }
      return map;
    } catch (e) {
      return {};
    }
  }

  Future<LeituraConfiguracaoModel?> fetchConfiguracao({
    required String condominioId,
    required String tipo,
  }) async {
    try {
      final response = await _supabase
          .from('leitura_configuracoes')
          .select()
          .eq('condominio_id', condominioId)
          .eq('tipo', tipo)
          .maybeSingle();

      if (response == null) return null;
      return LeituraConfiguracaoModel.fromJson(
        Map<String, dynamic>.from(response),
      );
    } catch (e) {
      print('Erro ao buscar configuração de leitura: $e');
      return null;
    }
  }

  Future<List<LeituraConfiguracaoModel>> fetchTodasConfiguracoes(
    String condominioId,
  ) async {
    try {
      final response = await _supabase
          .from('leitura_configuracoes')
          .select()
          .eq('condominio_id', condominioId);

      return (response as List)
          .map(
            (e) =>
                LeituraConfiguracaoModel.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList();
    } catch (e) {
      print('Erro ao buscar configurações: $e');
      return [];
    }
  }

  Future<void> saveConfiguracao(LeituraConfiguracaoModel config) async {
    try {
      final data = config.toJson();
      data.remove('id');

      await _supabase.from('leitura_configuracoes').upsert({
        ...data,
        'condominio_id': config.condominioId,
      }, onConflict: 'condominio_id,tipo');
    } catch (e) {
      throw Exception('Erro ao salvar configuração: $e');
    }
  }

  Future<String?> uploadFotoLeitura({
    required String condominioId,
    required String unidadeId,
    required File file,
  }) async {
    try {
      final ext = file.path.split('.').last;
      final path =
          '$condominioId/${DateTime.now().millisecondsSinceEpoch}_$unidadeId.$ext';

      await _supabase.storage
          .from('leituras-fotos')
          .upload(path, file, fileOptions: const FileOptions(upsert: true));

      final url = _supabase.storage.from('leituras-fotos').getPublicUrl(path);
      return url;
    } catch (e) {
      print('Erro ao fazer upload da foto: $e');
      return null;
    }
  }

  Future<void> saveLeitura(
    LeituraModel leitura,
    String condominioId, {
    File? imagem,
  }) async {
    try {
      String? imagemUrl = leitura.imagemUrl;
      if (imagem != null) {
        imagemUrl = await uploadFotoLeitura(
          condominioId: condominioId,
          unidadeId: leitura.unidadeId,
          file: imagem,
        );
      }

      final data = leitura.toJson();
      data['condominio_id'] = condominioId;
      data['imagem_url'] = imagemUrl;
      data['data_leitura'] = leitura.dataLeitura
          .toIso8601String()
          .split('T')
          .first;

      if (leitura.id.isEmpty) {
        await _supabase.from('leituras').insert(data);
      } else {
        await _supabase.from('leituras').update(data).eq('id', leitura.id);
      }
    } catch (e) {
      throw Exception('Erro ao salvar leitura: $e');
    }
  }

  Future<void> deleteLeitura(String id) async {
    try {
      await _supabase.from('leituras').delete().eq('id', id);
    } catch (e) {
      throw Exception('Erro ao excluir leitura: $e');
    }
  }
}
