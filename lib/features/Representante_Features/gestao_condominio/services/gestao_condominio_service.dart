import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../models/condominio.dart';
import '../../../../models/representante.dart';

class GestaoCondominioService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Obtém um condomínio pelo ID
  Future<Condominio?> obterCondominio(String condominioId) async {
    try {
      final response = await _supabase
          .from('condominios')
          .select()
          .eq('id', condominioId)
          .single();

      return Condominio.fromJson(response);
    } catch (e) {
      print('⚠️ [GestaoCondominioService] Erro ao obter condomínio: $e');
      return null;
    }
  }

  /// Obtém um representante pelo ID
  Future<Representante?> obterRepresentante(String representanteId) async {
    try {
      final response = await _supabase
          .from('representantes')
          .select()
          .eq('id', representanteId)
          .single();

      return Representante.fromJson(response);
    } catch (e) {
      print('⚠️ [GestaoCondominioService] Erro ao obter representante: $e');
      return null;
    }
  }
}
