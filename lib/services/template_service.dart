import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';

class TemplateService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Upload do arquivo ODS template para o Supabase Storage
  static Future<String> uploadTemplateODS(Uint8List bytes) async {
    try {
      const String fileName = 'Template_Unidade_Morador_Condogaia_V1.ods';
      const String bucket = 'documentos';
      const String filePath = 'templates/$fileName';

      // Upload do arquivo para Supabase Storage
      await _supabase.storage.from(bucket).uploadBinary(
        filePath,
        bytes,
        fileOptions: const FileOptions(
          cacheControl: '3600',
          upsert: true, // Sobrescreve se já existir
        ),
      );

      // Gera URL pública do arquivo
      final String publicUrl = _supabase.storage
          .from(bucket)
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('Erro ao fazer upload do template: $e');
    }
  }

  /// Obtém a URL do template ODS armazenado
  static Future<String> getTemplateUrl() async {
    try {
      const String bucket = 'documentos';
      const String filePath = 'templates/Template_Unidade_Morador_Condogaia_V1.ods';

      final String publicUrl = _supabase.storage
          .from(bucket)
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('Erro ao obter URL do template: $e');
    }
  }
}
