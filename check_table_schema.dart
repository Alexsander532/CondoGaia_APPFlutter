import 'package:supabase/supabase.dart';
import 'dart:io';

void main() async {
  final supabase = SupabaseClient(
    'https://tukpgefrddfchmvtiujp.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR1a3BnZWZyZGRmY2htdnRpdWpwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI1MTg1NTEsImV4cCI6MjA2ODA5NDU1MX0.dZ1Pna1_dwelIJTlhrSN0iiH5nhuzL0y4p6llYJsLp8',
  );

  try {
    print('Checking receitas:');
    final receitas = await supabase.from('receitas').select().limit(1);
    print(receitas);

    print('\nChecking despesas:');
    final despesas = await supabase.from('despesas').select().limit(1);
    print(despesas);

    exit(0);
  } catch (e) {
    print('Erro: $e');
    exit(1);
  }
}
