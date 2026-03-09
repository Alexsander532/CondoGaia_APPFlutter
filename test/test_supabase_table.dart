import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('Test Supabase textos_condominio_configuracoes Table', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});

    // Initialize Supabase with the project URL and Anon Key
    await Supabase.initialize(
      url: 'https://tukpgefrddfchmvtiujp.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR1a3BnZWZyZGRmY2htdnRpdWpwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI1MTg1NTEsImV4cCI6MjA2ODA5NDU1MX0.dZ1Pna1_dwelIJTlhrSN0iiH5nhuzL0y4p6llYJsLp8',
    );

    final supabase = Supabase.instance.client;

    try {
      // Test SELECT
      final response = await supabase
          .from('textos_condominio_configuracoes')
          .select()
          .limit(1);
      print('Table exists. Data: $response');
    } catch (e) {
      print('Error accessing table: $e');
      fail('Table might not exist, or access failed: $e');
    }
  });
}
