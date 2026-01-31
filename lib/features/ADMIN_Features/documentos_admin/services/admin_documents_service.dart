import 'dart:io';
import '../../../../models/condominio.dart';
import '../../../../services/supabase_service.dart';

class AdminDocumentsService {
  final _supabase = SupabaseService.client;

  /// Busca todos os condomínios cadastrados
  Future<List<Condominio>> fetchCondominios() async {
    try {
      final response = await _supabase
          .from('condominios')
          .select()
          .order('nome_condominio');

      final data = response as List<dynamic>;
      return data.map((json) => Condominio.fromJson(json)).toList();
    } catch (e) {
      // Em caso de erro ou tabela vazia, retorna lista vazia ou lança erro
      // Para desenvolvimento, podemos retornar dados mockados se necessário
      print('Erro ao buscar condomínios: $e');
      return [];
    }
  }

  /// Envia os documentos selecionados para o storage
  Future<void> uploadDocuments({
    required String condominioId,
    required Map<String, File> files,
  }) async {
    try {
      // Simulação de upload ou implementação real
      // TODO: Implementar upload real para bucket do Supabase
      // files keys: 'ata', 'cnh', 'selfie'

      /*
      await Future.forEach(files.entries, (entry) async {
        final docType = entry.key;
        final file = entry.value;
        final fileName = '${condominioId}_$docType.jpg'; // ou extensão real
        
        await _supabase.storage
            .from('documentos_condominio')
            .upload(fileName, file);
      });
      */

      // Simula delay de rede
      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      throw Exception('Falha ao enviar documentos: $e');
    }
  }
}
