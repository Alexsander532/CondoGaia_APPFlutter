import 'package:supabase_flutter/supabase_flutter.dart';

/// Script temporário para corrigir inconsistência de maiúsculas/minúsculas nos emails
/// ATENÇÃO: Este arquivo deve ser removido após a correção
class EmailCaseFixer {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Corrige todos os emails dos representantes para minúsculas
  static Future<void> fixRepresentantesEmailCase() async {
    try {
      print('🔧 Iniciando correção de emails dos representantes...');
      
      // Buscar todos os representantes
      final representantes = await _supabase
          .from('representantes')
          .select('id, email, nome_completo');
      
      print('📋 Encontrados ${representantes.length} representantes');
      
      int corrigidos = 0;
      
      for (var rep in representantes) {
        final emailOriginal = rep['email'] as String;
        final emailCorrigido = emailOriginal.toLowerCase();
        
        if (emailOriginal != emailCorrigido) {
          print('📧 Corrigindo: "$emailOriginal" → "$emailCorrigido"');
          
          await _supabase
              .from('representantes')
              .update({'email': emailCorrigido})
              .eq('id', rep['id']);
          
          corrigidos++;
        }
      }
      
      print('✅ Correção concluída! $corrigidos emails foram corrigidos.');
      
      // Verificar resultado
      final verificacao = await _supabase
          .from('representantes')
          .select('email, nome_completo')
          .order('email');
      
      print('📋 Emails após correção:');
      for (var rep in verificacao) {
        print('  - ${rep['email']} | ${rep['nome_completo']}');
      }
      
    } catch (e) {
      print('❌ Erro ao corrigir emails: $e');
    }
  }
}