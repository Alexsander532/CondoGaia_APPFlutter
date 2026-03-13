import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/despesa_model.dart';
import '../models/receita_model.dart';
import '../models/transferencia_model.dart';
import '../../gestao_condominio/models/conta_bancaria_model.dart';
import '../../gestao_condominio/models/categoria_financeira_model.dart';
import 'i_despesa_receita_service.dart';
import 'package:image_picker/image_picker.dart';

class DespesaReceitaService implements IDespesaReceitaService {
  final SupabaseClient _supabase;

  DespesaReceitaService({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  // ============================================================
  // CONTAS E CATEGORIAS (para dropdowns)
  // ============================================================

  Future<List<ContaBancaria>> listarContas(String condominioId) async {
    try {
      final response = await _supabase
          .from('contas_bancarias')
          .select()
          .eq('condominio_id', condominioId)
          .order('is_principal', ascending: false)
          .order('created_at');

      return (response as List).map((e) => ContaBancaria.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Erro ao listar contas: $e');
    }
  }

  Future<List<CategoriaFinanceira>> listarCategorias() async {
    try {
      final response = await _supabase
          .from('categorias_financeiras')
          .select('*, subcategorias_financeiras(*)')
          .order('nome');

      return (response as List)
          .map((e) => CategoriaFinanceira.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception('Erro ao listar categorias: $e');
    }
  }

  // ============================================================
  // DESPESAS
  // ============================================================

  Future<List<Despesa>> listarDespesas(
    String condominioId, {
    int? mes,
    int? ano,
    String? contaId,
    String? categoriaId,
    String? subcategoriaId,
    String? palavraChave,
  }) async {
    try {
      var query = _supabase
          .from('despesas')
          .select(
            '*, contas_bancarias(banco), categorias_financeiras(nome), subcategorias_financeiras(nome)',
          )
          .eq('condominio_id', condominioId);

      if (contaId != null && contaId.isNotEmpty) {
        query = query.eq('conta_id', contaId);
      }
      if (categoriaId != null && categoriaId.isNotEmpty) {
        query = query.eq('categoria_id', categoriaId);
      }
      if (subcategoriaId != null && subcategoriaId.isNotEmpty) {
        query = query.eq('subcategoria_id', subcategoriaId);
      }
      if (palavraChave != null && palavraChave.isNotEmpty) {
        query = query.ilike('descricao', '%$palavraChave%');
      }

      // Filtro por mês/ano na data_vencimento
      if (mes != null && ano != null) {
        final inicio = DateTime(ano, mes, 1);
        final fim = DateTime(ano, mes + 1, 0); // Último dia do mês
        query = query
            .gte('data_vencimento', inicio.toIso8601String().split('T').first)
            .lte('data_vencimento', fim.toIso8601String().split('T').first);
      }

      final response = await query.order('data_vencimento', ascending: false);

      return (response as List).map((e) => Despesa.fromJson(e)).toList();
    } catch (e) {
      print('⚠️ [DespesaReceitaService] Erro ao listar despesas: $e');
      return [];
    }
  }

  Future<void> salvarDespesa(Despesa despesa) async {
    try {
      final data = despesa.toJson();
      if (despesa.id != null) {
        await _supabase.from('despesas').update(data).eq('id', despesa.id!);
      } else {
        data.remove('id');
        await _supabase.from('despesas').insert(data);
      }
    } catch (e) {
      print('⚠️ [DespesaReceitaService] Erro ao salvar despesa: $e');
      throw Exception('Erro ao salvar despesa.');
    }
  }

  @override
  Future<String> uploadFotoDespesa(XFile arquivo) async {
    try {
      final bytes = await arquivo.readAsBytes();
      final extensao = arquivo.name.split('.').last.toLowerCase();
      final nomeArquivo =
          'despesa_${DateTime.now().millisecondsSinceEpoch}.$extensao';
      final caminhoCompleto = 'comprovantes/$nomeArquivo';

      // Bucket 'comprovantes_financeiros'
      await _supabase.storage
          .from('comprovantes_financeiros')
          .uploadBinary(caminhoCompleto, bytes);

      final urlPublica = _supabase.storage
          .from('comprovantes_financeiros')
          .getPublicUrl(caminhoCompleto);

      return urlPublica;
    } catch (e) {
      print('⚠️ [DespesaReceitaService] Erro no upload da foto: $e');
      throw Exception('Erro ao fazer upload da foto.');
    }
  }

  Future<void> excluirDespesa(String id) async {
    try {
      await _supabase.from('despesas').delete().eq('id', id);
    } catch (e) {
      print('⚠️ [DespesaReceitaService] Erro ao excluir despesa: $e');
      throw Exception('Erro ao excluir despesa.');
    }
  }

  Future<void> excluirDespesasMultiplas(List<String> ids) async {
    try {
      await _supabase.from('despesas').delete().inFilter('id', ids);
    } catch (e) {
      print('⚠️ [DespesaReceitaService] Erro ao excluir despesas: $e');
      throw Exception('Erro ao excluir despesas.');
    }
  }

  // ============================================================
  // RECEITAS
  // ============================================================

  Future<List<Receita>> listarReceitas(
    String condominioId, {
    int? mes,
    int? ano,
    String? contaId,
    String? categoriaId,
    String? subcategoriaId,
    String? contaContabil,
    String? tipo,
    String? palavraChave,
  }) async {
    try {
      var query = _supabase
          .from('receitas')
          .select(
            '*, contas_bancarias(banco), categorias_financeiras(nome), subcategorias_financeiras(nome)',
          )
          .eq('condominio_id', condominioId);

      if (contaId != null && contaId.isNotEmpty) {
        query = query.eq('conta_id', contaId);
      }
      if (categoriaId != null && categoriaId.isNotEmpty) {
        query = query.eq('categoria_id', categoriaId);
      }
      if (subcategoriaId != null && subcategoriaId.isNotEmpty) {
        query = query.eq('subcategoria_id', subcategoriaId);
      }
      if (contaContabil != null && contaContabil.isNotEmpty) {
        query = query.eq('conta_contabil', contaContabil);
      }
      if (tipo != null && tipo.isNotEmpty && tipo != 'Todos') {
        query = query.eq('tipo', tipo.toUpperCase());
      }
      if (palavraChave != null && palavraChave.isNotEmpty) {
        query = query.ilike('descricao', '%$palavraChave%');
      }

      if (mes != null && ano != null) {
        final inicio = DateTime(ano, mes, 1);
        final fim = DateTime(ano, mes + 1, 0);
        query = query
            .gte('data_credito', inicio.toIso8601String().split('T').first)
            .lte('data_credito', fim.toIso8601String().split('T').first);
      }

      final response = await query.order('data_credito', ascending: false);

      return (response as List).map((e) => Receita.fromJson(e)).toList();
    } catch (e) {
      print('⚠️ [DespesaReceitaService] Erro ao listar receitas: $e');
      return [];
    }
  }

  Future<void> salvarReceita(Receita receita) async {
    try {
      final data = receita.toJson();
      if (receita.id != null) {
        await _supabase.from('receitas').update(data).eq('id', receita.id!);
      } else {
        data.remove('id');
        await _supabase.from('receitas').insert(data);
      }
    } catch (e) {
      print('⚠️ [DespesaReceitaService] Erro ao salvar receita: $e');
      throw Exception('Erro ao salvar receita.');
    }
  }

  Future<void> excluirReceita(String id) async {
    try {
      await _supabase.from('receitas').delete().eq('id', id);
    } catch (e) {
      print('⚠️ [DespesaReceitaService] Erro ao excluir receita: $e');
      throw Exception('Erro ao excluir receita.');
    }
  }

  Future<void> excluirReceitasMultiplas(List<String> ids) async {
    try {
      await _supabase.from('receitas').delete().inFilter('id', ids);
    } catch (e) {
      print('⚠️ [DespesaReceitaService] Erro ao excluir receitas: $e');
      throw Exception('Erro ao excluir receitas.');
    }
  }

  // ============================================================
  // TRANSFERÊNCIAS
  // ============================================================

  Future<List<Transferencia>> listarTransferencias(
    String condominioId, {
    int? mes,
    int? ano,
    String? contaDebitoId,
    String? contaCreditoId,
    String? palavraChave,
  }) async {
    try {
      var query = _supabase
          .from('transferencias')
          .select(
            '*, conta_debito:contas_bancarias!conta_debito_id(banco), conta_credito:contas_bancarias!conta_credito_id(banco)',
          )
          .eq('condominio_id', condominioId);

      if (contaDebitoId != null && contaDebitoId.isNotEmpty) {
        query = query.eq('conta_debito_id', contaDebitoId);
      }
      if (contaCreditoId != null && contaCreditoId.isNotEmpty) {
        query = query.eq('conta_credito_id', contaCreditoId);
      }
      if (palavraChave != null && palavraChave.isNotEmpty) {
        query = query.ilike('descricao', '%$palavraChave%');
      }

      if (mes != null && ano != null) {
        final inicio = DateTime(ano, mes, 1);
        final fim = DateTime(ano, mes + 1, 0);
        query = query
            .gte(
              'data_transferencia',
              inicio.toIso8601String().split('T').first,
            )
            .lte('data_transferencia', fim.toIso8601String().split('T').first);
      }

      final response = await query.order(
        'data_transferencia',
        ascending: false,
      );

      return (response as List).map((e) => Transferencia.fromJson(e)).toList();
    } catch (e) {
      print('⚠️ [DespesaReceitaService] Erro ao listar transferências: $e');
      return [];
    }
  }

  Future<void> salvarTransferencia(Transferencia transferencia) async {
    try {
      final data = transferencia.toJson();
      if (transferencia.id != null) {
        await _supabase
            .from('transferencias')
            .update(data)
            .eq('id', transferencia.id!);
      } else {
        data.remove('id');
        await _supabase.from('transferencias').insert(data);
      }
    } catch (e) {
      print('⚠️ [DespesaReceitaService] Erro ao salvar transferência: $e');
      throw Exception('Erro ao salvar transferência.');
    }
  }

  Future<void> excluirTransferencia(String id) async {
    try {
      await _supabase.from('transferencias').delete().eq('id', id);
    } catch (e) {
      print('⚠️ [DespesaReceitaService] Erro ao excluir transferência: $e');
      throw Exception('Erro ao excluir transferência.');
    }
  }

  Future<void> excluirTransferenciasMultiplas(List<String> ids) async {
    try {
      await _supabase.from('transferencias').delete().inFilter('id', ids);
    } catch (e) {
      print('⚠️ [DespesaReceitaService] Erro ao excluir transferências: $e');
      throw Exception('Erro ao excluir transferências.');
    }
  }

  // ============================================================
  // RESUMO FINANCEIRO — SALDO ANTERIOR
  // ============================================================

  /// Calcula o saldo do mês anterior (total receitas − total despesas do mês
  /// imediatamente anterior ao [mes]/[ano] fornecidos).
  @override
  Future<double> calcularSaldoAnterior(
    String condominioId, {
    required int mes,
    required int ano,
  }) async {
    try {
      // Mês anterior
      int mesAnterior = mes - 1;
      int anoAnterior = ano;
      if (mesAnterior < 1) {
        mesAnterior = 12;
        anoAnterior--;
      }

      final inicio = DateTime(anoAnterior, mesAnterior, 1);
      final fim = DateTime(anoAnterior, mesAnterior + 1, 0);
      final inicioStr = inicio.toIso8601String().split('T').first;
      final fimStr = fim.toIso8601String().split('T').first;

      // Buscar receitas do mês anterior
      final receitasResp = await _supabase
          .from('receitas')
          .select('valor')
          .eq('condominio_id', condominioId)
          .gte('data_credito', inicioStr)
          .lte('data_credito', fimStr);

      final totalReceitas = (receitasResp as List).fold<double>(
        0,
        (sum, r) => sum + ((r['valor'] ?? 0) as num).toDouble(),
      );

      // Buscar despesas do mês anterior
      final despesasResp = await _supabase
          .from('despesas')
          .select('valor')
          .eq('condominio_id', condominioId)
          .gte('data_vencimento', inicioStr)
          .lte('data_vencimento', fimStr);

      final totalDespesas = (despesasResp as List).fold<double>(
        0,
        (sum, d) => sum + ((d['valor'] ?? 0) as num).toDouble(),
      );

      return totalReceitas - totalDespesas;
    } catch (e) {
      print('⚠️ [DespesaReceitaService] Erro ao calcular saldo anterior: $e');
      return 0;
    }
  }
}
