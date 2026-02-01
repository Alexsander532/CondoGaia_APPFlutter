import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/leitura_model.dart';
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
      // Fetch readings for specific month/year/type
      // Assuming a 'leituras' table exists
      final startDate = DateTime(year, month, 1).toIso8601String();
      final endDate = DateTime(
        year,
        month + 1,
        0,
      ).toIso8601String(); // End of month

      final response = await _supabase
          .from('leituras')
          .select()
          .eq('condominio_id', condominioId)
          .eq('tipo', tipo)
          .gte('data_leitura', startDate)
          .lte('data_leitura', endDate);

      final List<LeituraModel> leituras = (response as List)
          .map((e) => LeituraModel.fromJson(e))
          .toList();

      return leituras;
    } catch (e) {
      // Return empty if table doesn't exist or error, for UI dev purposes
      print('Erro ao buscar leituras: $e');
      return [];
    }
  }

  Future<List<Unidade>> fetchUnidades(String condominioId) async {
    try {
      final response = await _supabase
          .from('unidades')
          .select()
          .eq('condominio_id', condominioId)
          .eq('ativo', true);

      return (response as List).map((e) => Unidade.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveLeitura(LeituraModel leitura, String condominioId) async {
    try {
      final data = leitura.toJson();
      data['condominio_id'] = condominioId;

      // Remove local-only fields if necessary, but toJson handles it.
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

  // Mocked for now - or fetch from a settings table
  Future<double> fetchTaxaPorUnidade(String condominioId, String tipo) async {
    // In real app, fetch from 'taxas_condominio' or similar
    await Future.delayed(const Duration(milliseconds: 500));
    return tipo == 'Agua' ? 30.0 : 15.0; // Mock values
  }
}
