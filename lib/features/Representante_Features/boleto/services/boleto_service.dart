import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/boleto_model.dart';

class BoletoService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ============================================================
  // LISTAR BOLETOS
  // ============================================================

  Future<List<Boleto>> listarBoletos(
    String condominioId, {
    int? mes,
    int? ano,
    String? tipoEmissao,
    String? situacao,
    String? dataInicio,
    String? dataFim,
    String? nossoNumero,
    String? pesquisa,
  }) async {
    try {
      var query = _supabase
          .from('boletos')
          .select('*, moradores(nome), contas_bancarias(banco)')
          .eq('condominio_id', condominioId);

      // Filtro por tipo de emissão
      if (tipoEmissao != null &&
          tipoEmissao.isNotEmpty &&
          tipoEmissao != 'Todos') {
        query = query.eq('tipo', tipoEmissao);
      }

      // Filtro por situação/status
      if (situacao != null && situacao.isNotEmpty && situacao != 'Todos') {
        if (situacao == 'A vencer') {
          query = query
              .eq('status', 'Ativo')
              .gte(
                'data_vencimento',
                DateTime.now().toIso8601String().split('T').first,
              );
        } else if (situacao == 'Cancelado acordo') {
          query = query.eq('status', 'Cancelado por Acordo');
        } else {
          query = query.eq('status', situacao);
        }
      }

      // Filtro por nosso número
      if (nossoNumero != null && nossoNumero.isNotEmpty) {
        query = query.eq('nosso_numero', nossoNumero);
      }

      // Filtro por pesquisa (unidade/bloco ou nome)
      if (pesquisa != null && pesquisa.isNotEmpty) {
        query = query.or(
          'bloco_unidade.ilike.%$pesquisa%,sacado.ilike.%$pesquisa%',
        );
      }

      // Filtro por intervalo de datas específico
      if (dataInicio != null && dataInicio.isNotEmpty) {
        query = query.gte('data_vencimento', dataInicio);
      }
      if (dataFim != null && dataFim.isNotEmpty) {
        query = query.lte('data_vencimento', dataFim);
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

      return (response as List).map((e) => Boleto.fromJson(e)).toList();
    } catch (e) {
      print('⚠️ [BoletoService] Erro ao listar boletos: $e');
      return [];
    }
  }

  // ============================================================
  // RECEBER BOLETO (registrar pagamento)
  // ============================================================

  Future<void> receberBoleto({
    required String boletoId,
    required String contaBancariaId,
    required String dataPagamento,
    required double juros,
    required double multa,
    required double outrosAcrescimos,
    required double valorTotal,
    String? obs,
  }) async {
    try {
      await _supabase
          .from('boletos')
          .update({
            'status': 'Pago',
            'conta_bancaria_id': contaBancariaId,
            'data_pagamento': dataPagamento,
            'juros': juros,
            'multa': multa,
            'outros_acrescimos': outrosAcrescimos,
            'valor_total': valorTotal,
            'obs': obs,
            'pgto': 'SIM',
          })
          .eq('id', boletoId);
    } catch (e) {
      print('⚠️ [BoletoService] Erro ao receber boleto: $e');
      throw Exception('Erro ao receber boleto.');
    }
  }

  // ============================================================
  // EXCLUIR BOLETOS
  // ============================================================

  Future<void> excluirBoleto(String id) async {
    try {
      await _supabase.from('boletos').delete().eq('id', id);
    } catch (e) {
      print('⚠️ [BoletoService] Erro ao excluir boleto: $e');
      throw Exception('Erro ao excluir boleto.');
    }
  }

  Future<void> excluirBoletosMultiplos(List<String> ids) async {
    try {
      await _supabase.from('boletos').delete().inFilter('id', ids);
    } catch (e) {
      print('⚠️ [BoletoService] Erro ao excluir boletos: $e');
      throw Exception('Erro ao excluir boletos.');
    }
  }

  // ============================================================
  // GERAR COBRANÇA MENSAL
  // ============================================================

  Future<void> gerarCobrancaMensal({
    required String condominioId,
    required String dataVencimento,
    required double cotaCondominial,
    required double fundoReserva,
    required double multaInfracao,
    required double controle,
    required double rateioAgua,
    required double desconto,
    required bool enviarParaRegistro,
    required bool enviarPorEmail,
    List<String>? unidadeIds,
  }) async {
    try {
      // Busca as unidades do condomínio (ou as selecionadas)
      var query = _supabase
          .from('unidades')
          .select('id, bloco, unidade, morador_nome')
          .eq('condominio_id', condominioId);

      if (unidadeIds != null && unidadeIds.isNotEmpty) {
        query = query.inFilter('id', unidadeIds);
      }

      final unidades = await query;

      // Calcula o valor total do boleto
      final valor =
          cotaCondominial +
          fundoReserva +
          multaInfracao +
          controle +
          rateioAgua -
          desconto;

      // Cria um boleto para cada unidade
      final boletos = (unidades as List).map((unidade) {
        final bloco = unidade['bloco'] ?? '';
        final unid = unidade['unidade'] ?? '';
        final blocoUnidade = bloco.isNotEmpty ? '$bloco/$unid' : unid;

        return {
          'condominio_id': condominioId,
          'bloco_unidade': blocoUnidade,
          'sacado': unidade['morador_nome'] ?? '',
          'referencia': dataVencimento.substring(3), // MM/YYYY
          'data_vencimento': dataVencimento,
          'valor': valor,
          'status': 'Ativo',
          'tipo': 'Mensal',
          'baixa': 'Manual',
          'boleto_registrado': enviarParaRegistro ? 'PENDENTE' : 'NAO',
          'unidade_id': unidade['id'],
          'cota_condominial': cotaCondominial,
          'fundo_reserva': fundoReserva,
          'multa_infracao': multaInfracao,
          'controle': controle,
          'rateio_agua': rateioAgua,
          'desconto': desconto,
          'valor_total': valor,
        };
      }).toList();

      if (boletos.isNotEmpty) {
        await _supabase.from('boletos').insert(boletos);
      }
    } catch (e) {
      print('⚠️ [BoletoService] Erro ao gerar cobrança mensal: $e');
      throw Exception('Erro ao gerar cobrança mensal.');
    }
  }

  // ============================================================
  // ENVIAR PARA REGISTRO
  // ============================================================

  Future<Map<String, dynamic>> enviarParaRegistro(
    List<String> boletoIds,
  ) async {
    try {
      // Atualiza status de registro dos boletos
      await _supabase
          .from('boletos')
          .update({'boleto_registrado': 'PENDENTE'})
          .inFilter('id', boletoIds);

      return {'sucesso': boletoIds.length, 'erros': <Map<String, String>>[]};
    } catch (e) {
      print('⚠️ [BoletoService] Erro ao enviar para registro: $e');
      throw Exception('Erro ao enviar para registro.');
    }
  }

  // ============================================================
  // AGRUPAR BOLETOS
  // ============================================================

  Future<void> agruparBoletos(List<String> boletoIds) async {
    try {
      // Busca os boletos selecionados
      final boletos = await _supabase
          .from('boletos')
          .select()
          .inFilter('id', boletoIds);

      if ((boletos as List).isEmpty) return;

      // Agrupa somando os valores
      double valorTotal = 0;
      for (final b in boletos) {
        valorTotal += (b['valor'] ?? 0).toDouble();
      }

      // Atualiza o primeiro boleto com o valor agrupado
      await _supabase
          .from('boletos')
          .update({
            'valor': valorTotal,
            'valor_total': valorTotal,
            'tipo': 'Acordo',
            'classe': 'ACORDO(${boletos.length})',
          })
          .eq('id', boletos.first['id']);

      // Cancela os demais
      final idsParaCancelar = boletoIds.skip(1).toList();
      if (idsParaCancelar.isNotEmpty) {
        await _supabase
            .from('boletos')
            .update({'status': 'Cancelado por Acordo'})
            .inFilter('id', idsParaCancelar);
      }
    } catch (e) {
      print('⚠️ [BoletoService] Erro ao agrupar boletos: $e');
      throw Exception('Erro ao agrupar boletos.');
    }
  }

  // ============================================================
  // LISTAR CONTAS BANCÁRIAS (para dropdown do receber)
  // ============================================================

  Future<List<Map<String, dynamic>>> listarContasBancarias(
    String condominioId,
  ) async {
    try {
      final response = await _supabase
          .from('contas_bancarias')
          .select('id, banco')
          .eq('condominio_id', condominioId)
          .order('is_principal', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('⚠️ [BoletoService] Erro ao listar contas bancárias: $e');
      return [];
    }
  }

  // ============================================================
  // LISTAR UNIDADES (para dialog de seleção)
  // ============================================================

  Future<List<Map<String, dynamic>>> listarUnidades(
    String condominioId, {
    String? pesquisa,
  }) async {
    try {
      var query = _supabase
          .from('unidades')
          .select('id, bloco, unidade, morador_nome')
          .eq('condominio_id', condominioId);

      if (pesquisa != null && pesquisa.isNotEmpty) {
        query = query.or(
          'bloco.ilike.%$pesquisa%,unidade.ilike.%$pesquisa%,morador_nome.ilike.%$pesquisa%',
        );
      }

      final response = await query.order('bloco').order('unidade');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('⚠️ [BoletoService] Erro ao listar unidades: $e');
      return [];
    }
  }
}
