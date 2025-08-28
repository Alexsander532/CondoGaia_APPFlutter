import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://tukpgefrddfchmvtiujp.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR1a3BnZWZyZGRmY2htdnRpdWpwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI1MTg1NTEsImV4cCI6MjA2ODA5NDU1MX0.dZ1Pna1_dwelIJTlhrSN0iiH5nhuzL0y4p6llYJsLp8';

  static SupabaseClient get client => Supabase.instance.client;

  /// Inicializa o Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  /// Insere um novo condomínio na tabela condominios
  static Future<Map<String, dynamic>?> insertCondominio(Map<String, dynamic> condominioData) async {
    try {
      final response = await client
          .from('condominios')
          .insert(condominioData)
          .select()
          .single();
      
      return response;
    } catch (e) {
      print('Erro ao inserir condomínio: $e');
      rethrow;
    }
  }

  /// Busca todos os condomínios
  static Future<List<Map<String, dynamic>>> getCondominios() async {
    try {
      final response = await client
          .from('condominios')
          .select()
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erro ao buscar condomínios: $e');
      rethrow;
    }
  }

  /// Busca um condomínio por ID
  static Future<Map<String, dynamic>?> getCondominioById(String id) async {
    try {
      final response = await client
          .from('condominios')
          .select()
          .eq('id', id)
          .single();
      
      return response;
    } catch (e) {
      print('Erro ao buscar condomínio por ID: $e');
      rethrow;
    }
  }

  /// Atualiza um condomínio
  static Future<Map<String, dynamic>?> updateCondominio(String id, Map<String, dynamic> condominioData) async {
    try {
      final response = await client
          .from('condominios')
          .update(condominioData)
          .eq('id', id)
          .select()
          .single();
      
      return response;
    } catch (e) {
      print('Erro ao atualizar condomínio: $e');
      rethrow;
    }
  }

  /// Deleta um condomínio
  static Future<void> deleteCondominio(String id) async {
    try {
      await client
          .from('condominios')
          .delete()
          .eq('id', id);
    } catch (e) {
      print('Erro ao deletar condomínio: $e');
      rethrow;
    }
  }
}