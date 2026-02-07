import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../models/condominio.dart';
import '../../../../models/representante.dart';
import '../models/configuracao_financeira_model.dart';
import '../models/conta_bancaria_model.dart';
import '../models/textos_condominio_model.dart';
import '../models/categoria_financeira_model.dart';

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

  /// Obtém a configuração financeira do condomínio
  Future<ConfiguracaoFinanceira?> obterConfiguracaoFinanceira(
    String condominioId,
  ) async {
    try {
      final response = await _supabase
          .from('financeiro_configuracoes')
          .select()
          .eq('condominio_id', condominioId)
          .maybeSingle();

      if (response == null) return null;
      return ConfiguracaoFinanceira.fromJson(response);
    } catch (e) {
      print(
        '⚠️ [GestaoCondominioService] Erro ao obter configuração financeira: $e',
      );
      // Se a tabela não existir ou der erro, retorna null.
      // Em produção, talvez queira distinguir erros.
      return null;
    }
  }

  /// Salva ou atualiza a configuração financeira
  Future<void> salvarConfiguracaoFinanceira(
    ConfiguracaoFinanceira config,
  ) async {
    final data = config.toJson();
    // Remove null IDs to let DB generate or match Constraint
    if (config.id == null) {
      data.remove('id');
    }

    // Upsert baseado no condominio_id (Unique Key)
    await _supabase
        .from('financeiro_configuracoes')
        .upsert(data, onConflict: 'condominio_id');
  }
  // --- Contas Bancárias ---

  Future<List<ContaBancaria>> listarContas(String condominioId) async {
    try {
      final response = await _supabase
          .from('contas_bancarias')
          .select()
          .eq('condominio_id', condominioId)
          .order('is_principal', ascending: false) // Principal primeiro
          .order('created_at');

      return (response as List).map((e) => ContaBancaria.fromJson(e)).toList();
    } catch (e) {
      print('⚠️ [GestaoCondominioService] Erro ao listar contas: $e');
      throw Exception('Erro ao listar contas bancárias.');
    }
  }

  Future<void> salvarConta(ContaBancaria conta) async {
    try {
      if (conta.isPrincipal) {
        // Se for principal, desmarcar as outras antes de salvar esta
        await _desmarcarPrincipais(conta.condominioId, conta.id);
      }

      await _supabase.from('contas_bancarias').upsert(conta.toJson());
    } catch (e) {
      print('⚠️ [GestaoCondominioService] Erro ao salvar conta: $e');
      throw Exception('Erro ao salvar conta bancária.');
    }
  }

  Future<void> excluirConta(String id) async {
    try {
      // Verifica se é principal antes de excluir
      final conta = await _supabase
          .from('contas_bancarias')
          .select()
          .eq('id', id)
          .single();

      if (conta['is_principal'] == true) {
        throw Exception(
          'Não é possível excluir a conta principal. Defina outra como principal primeiro.',
        );
      }

      await _supabase.from('contas_bancarias').delete().eq('id', id);
    } catch (e) {
      print('⚠️ [GestaoCondominioService] Erro ao excluir conta: $e');
      if (e.toString().contains('Não é possível excluir')) {
        rethrow;
      }
      throw Exception('Erro ao excluir conta.');
    }
  }

  Future<void> definirContaPrincipal(
    String contaId,
    String condominioId,
  ) async {
    try {
      // 1. Desmarcar todas
      await _supabase
          .from('contas_bancarias')
          .update({'is_principal': false})
          .eq('condominio_id', condominioId);

      // 2. Marcar a escolhida
      await _supabase
          .from('contas_bancarias')
          .update({'is_principal': true})
          .eq('id', contaId);
    } catch (e) {
      print('⚠️ [GestaoCondominioService] Erro ao definir conta principal: $e');
      throw Exception('Erro ao atualizar conta principal.');
    }
  }

  // --- Textos Condomínio ---

  Future<TextosCondominio?> obterTextos(String condominioId) async {
    try {
      final response = await _supabase
          .from('textos_condominio_configuracoes')
          .select()
          .eq('condominio_id', condominioId)
          .maybeSingle();

      if (response == null) return null;
      return TextosCondominio.fromJson(response);
    } catch (e) {
      print('⚠️ [GestaoCondominioService] Erro ao obter textos: $e');
      return null;
    }
  }

  Future<void> salvarTextos(TextosCondominio textos) async {
    try {
      final data = textos.toJson();
      if (textos.id == null) {
        data.remove('id');
      }

      await _supabase
          .from('textos_condominio_configuracoes')
          .upsert(data, onConflict: 'condominio_id');
    } catch (e) {
      print('⚠️ [GestaoCondominioService] Erro ao salvar textos: $e');
      throw Exception('Erro ao salvar configurações de texto.');
    }
  }

  // Helper privado
  Future<void> _desmarcarPrincipais(
    String condominioId,
    String? currentId,
  ) async {
    await _supabase
        .from('contas_bancarias')
        .update({'is_principal': false})
        .eq('condominio_id', condominioId);
  }
  // --- Categorias e Subcategorias ---

  Future<List<CategoriaFinanceira>> listarCategorias(
    String condominioId,
  ) async {
    try {
      final response = await _supabase
          .from('categorias_financeiras')
          .select('*, subcategorias_financeiras(*)')
          .eq('condominio_id', condominioId)
          .order('nome');

      return (response as List)
          .map((e) => CategoriaFinanceira.fromJson(e))
          .toList();
    } catch (e) {
      print('⚠️ [GestaoCondominioService] Erro ao listar categorias: $e');
      throw Exception('Erro ao listar categorias.');
    }
  }

  Future<void> salvarCategoria(CategoriaFinanceira categoria) async {
    try {
      final data = categoria.toJson();
      if (categoria.id != null) {
        await _supabase
            .from('categorias_financeiras')
            .update(data)
            .eq('id', categoria.id!);
      } else {
        await _supabase.from('categorias_financeiras').insert(data);
      }
    } catch (e) {
      print('⚠️ [GestaoCondominioService] Erro ao salvar categoria: $e');
      throw Exception('Erro ao salvar categoria.');
    }
  }

  Future<void> excluirCategoria(String id) async {
    try {
      await _supabase.from('categorias_financeiras').delete().eq('id', id);
    } catch (e) {
      print('⚠️ [GestaoCondominioService] Erro ao excluir categoria: $e');
      throw Exception('Erro ao excluir categoria.');
    }
  }

  Future<void> salvarSubcategoria(SubcategoriaFinanceira sub) async {
    try {
      final data = sub.toJson();
      if (sub.id != null) {
        await _supabase
            .from('subcategorias_financeiras')
            .update(data)
            .eq('id', sub.id!);
      } else {
        await _supabase.from('subcategorias_financeiras').insert(data);
      }
    } catch (e) {
      print('⚠️ [GestaoCondominioService] Erro ao salvar subcategoria: $e');
      throw Exception('Erro ao salvar subcategoria.');
    }
  }

  Future<void> excluirSubcategoria(String id) async {
    try {
      await _supabase.from('subcategorias_financeiras').delete().eq('id', id);
    } catch (e) {
      print('⚠️ [GestaoCondominioService] Erro ao excluir subcategoria: $e');
      throw Exception('Erro ao excluir subcategoria.');
    }
  }
}
