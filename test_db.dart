import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

void main() async {
  await Supabase.initialize(
    url: 'https://tukpgefrddfchmvtiujp.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR1a3BnZWZyZGRmY2htdnRpdWpwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI1MTg1NTEsImV4cCI6MjA2ODA5NDU1MX0.dZ1Pna1_dwelIJTlhrSN0iiH5nhuzL0y4p6llYJsLp8'
  );

  final client = Supabase.instance.client;
  
  try {
    final categorias = await client.from('categorias_financeiras').select('*, subcategorias_financeiras(*)');
    print('Categorias: ${categorias.length}');
    for (var c in categorias) {
      print('- ${c['nome']} (Tipo: "${c['tipo']}")');
    }
  } catch (e) {
    print('Erro: $e');
  }
  exit(0);
}
