import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

void main() async {
  print('Iniciando...');

  // Initialize Supabase with the project URL and Anon Key
  final supabase = SupabaseClient(
    'https://tukpgefrddfchmvtiujp.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR1a3BnZWZyZGRmY2htdnRpdWpwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI1MTg1NTEsImV4cCI6MjA2ODA5NDU1MX0.dZ1Pna1_dwelIJTlhrSN0iiH5nhuzL0y4p6llYJsLp8',
  );

  try {
    // Test SELECT
    final response = await supabase
        .from('textos_condominio_configuracoes')
        .select()
        .limit(1);
    print('Tabela existe. Dados atuais: $response');
    exit(0);
  } catch (e) {
    print('Erro ao acessar a tabela: $e');
    exit(1);
  }
}
