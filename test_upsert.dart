import 'package:supabase/supabase.dart';
import 'dart:io';

void main() async {
  final supabase = SupabaseClient(
    'https://tukpgefrddfchmvtiujp.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR1a3BnZWZyZGRmY2htdnRpdWpwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI1MTg1NTEsImV4cCI6MjA2ODA5NDU1MX0.dZ1Pna1_dwelIJTlhrSN0iiH5nhuzL0y4p6llYJsLp8',
  );

  try {
    final listCondominios = await supabase
        .from('condominios')
        .select('id, nome_condominio')
        .limit(1);
    final condominioId = listCondominios.first['id'];

    final dataParams = {
      'condominio_id': condominioId,
      'comunicado_boleto_cota':
          'Teste upsert onConflict. Agradecemos sua colaboração!',
    };

    // Test the exact upsert done by the service
    await supabase
        .from('textos_condominio_configuracoes')
        .upsert(dataParams, onConflict: 'condominio_id');
    print('Upsert test successful!');
    exit(0);
  } catch (e) {
    print('Upsert failed: $e');
    exit(1);
  }
}
