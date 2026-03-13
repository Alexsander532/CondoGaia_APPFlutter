import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../services/laravel_api_service.dart';
import '../models/boleto_model.dart';
import 'boleto_email_service.dart';
import 'dart:convert';

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
          .select('*, contas_bancarias(banco)')
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

      // Filtro por pesquisa (unidade/bloco ou nome) - Removido sacado.ilike pois sacado é UUID
      if (pesquisa != null && pesquisa.isNotEmpty) {
        query = query.ilike('bloco_unidade', '%$pesquisa%');
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
      
      if ((response as List).isEmpty) {
        return [];
      }

      final List boletosData = response;
      
      // Busca os nomes dos sacados da view moradores
      final sacadosIds = boletosData.map((b) => b['sacado']?.toString()).where((id) => id != null && id.isNotEmpty).toSet().toList();
      Map<String, Map<String, dynamic>> moradoresMap = {};
      
      if (sacadosIds.isNotEmpty) {
        final moradoresResponse = await _supabase
            .from('moradores')
            .select('id, nome, email')
            .inFilter('id', sacadosIds);
        
        for (var m in (moradoresResponse as List)) {
          moradoresMap[m['id'].toString()] = {
            'id': m['id'],
            'nome': m['nome'],
            'email': m['email'],
          };
        }
      }

      List<Boleto> result = boletosData.map((data) {
        if (data['sacado'] != null && moradoresMap.containsKey(data['sacado'].toString())) {
          data['moradores'] = moradoresMap[data['sacado'].toString()];
        }
        return Boleto.fromJson(data);
      }).toList();

      // Filtro manual em Dart para busca por nome (já que não conseguimos fazer Join com Like no Supabase nas views)
      if (pesquisa != null && pesquisa.isNotEmpty) {
        final search = pesquisa.toLowerCase();
        result = result.where((b) {
          final blocoUnid = (b.blocoUnidade ?? '').toLowerCase();
          final nome = (b.sacadoNome ?? '').toLowerCase();
          return blocoUnid.contains(search) || nome.contains(search);
        }).toList();
      }

      return result;
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
      var query = _supabase
          .from('unidades')
          .select('id, bloco, numero, nome_pagador_boleto')
          .eq('condominio_id', condominioId);

      if (unidadeIds != null && unidadeIds.isNotEmpty) {
        query = query.inFilter('id', unidadeIds);
      }

      final unidades = await query;

      if ((unidades as List).isEmpty) {
        return; // Empty list so nothing to generate
      }

      // Busca proprietarios e inquilinos para extrair o id do sacado
      final proprietarios = await _supabase.from('proprietarios').select('id, unidade_id').eq('condominio_id', condominioId);
      final inquilinos = await _supabase.from('inquilinos').select('id, unidade_id').eq('condominio_id', condominioId);

      Map<String, String> proprietariosMap = { for (var p in (proprietarios as List)) p['unidade_id'].toString(): p['id'].toString() };
      Map<String, String> inquilinosMap = { for (var i in (inquilinos as List)) i['unidade_id'].toString(): i['id'].toString() };

      // Calcula o valor total do boleto
      final valor =
          cotaCondominial +
          fundoReserva +
          multaInfracao +
          controle +
          rateioAgua -
          desconto;

      // dataVencimento vem como DD/MM/YYYY
      final dateParts = dataVencimento.split('/');
      final formattedDate = '${dateParts[2]}-${dateParts[1]}-${dateParts[0]}';

      // Cria um boleto para cada unidade
      final boletos = [];
      for(var unidade in (unidades as List)) {
        final bloco = unidade['bloco'] ?? '';
        final unid = unidade['numero'] ?? '';
        final blocoUnidade = bloco.isNotEmpty ? '$bloco/$unid' : unid;
        
        final isPagadorInquilino = unidade['nome_pagador_boleto'] == 'inquilino';
        final sacadoId = (isPagadorInquilino ? inquilinosMap[unidade['id']] : proprietariosMap[unidade['id']]) 
                          ?? proprietariosMap[unidade['id']] // Fallback se o inquilino não existir
                          ?? inquilinosMap[unidade['id']]; // Fallback se o proprietário não existir

        // Se não houver nenhum sacado para a unidade, não gera o boleto para evitar erros no ASAAS
        if (sacadoId == null) {
          print('⚠️ [BoletoService] Unidade $blocoUnidade sem responsável vinculado. Boleto ignorado.');
          continue;
        }

        boletos.add({
          'condominio_id': condominioId,
          'bloco_unidade': blocoUnidade,
          'sacado': sacadoId,
          'referencia': dataVencimento.substring(3), // MM/YYYY
          'data_vencimento': formattedDate,
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
        });
      }

      if (boletos.isNotEmpty) {
        await _supabase.from('boletos').insert(boletos);

        if (enviarPorEmail) {
          // Busca e-mails dos moradores
          final proprietariosRes = await _supabase
              .from('proprietarios')
              .select('unidade_id, email')
              .eq('condominio_id', condominioId);

          final inquilinosRes = await _supabase
              .from('inquilinos')
              .select('unidade_id, email')
              .eq('condominio_id', condominioId);

          Map<String, String> emailsIquilinos = {};
          for (var i in (inquilinosRes as List)) {
            if (i['unidade_id'] != null && i['email'] != null) {
              emailsIquilinos[i['unidade_id']] = i['email'];
            }
          }

          Map<String, String> emailsProprietarios = {};
          for (var p in (proprietariosRes as List)) {
            if (p['unidade_id'] != null && p['email'] != null) {
              emailsProprietarios[p['unidade_id']] = p['email'];
            }
          }

          List<Map<String, dynamic>> boletosParaEmail = [];

          for (var unidade in (unidades as List)) {
            String? email;
            String pagador = unidade['nome_pagador_boleto'] ?? 'proprietario';
            String unidId = unidade['id'];

            if (pagador == 'inquilino') {
              email = emailsIquilinos[unidId] ?? emailsProprietarios[unidId];
            } else {
              email = emailsProprietarios[unidId] ?? emailsIquilinos[unidId];
            }

            if (email != null && email.isNotEmpty) {
              boletosParaEmail.add({
                'email': email,
                'nome': unidade['morador_nome'] ?? 'Condômino',
                'valor': valor,
                'dataVencimento': dataVencimento,
              });
            }
          }

          await enviarBoletosPorEmail(
            condominioId: condominioId,
            boletosData: boletosParaEmail,
          );
        }
      }
    } catch (e) {
      print('⚠️ [BoletoService] Erro ao gerar cobrança mensal: $e');
      throw Exception('Erro ao gerar cobrança mensal.');
    }
  }

  // ============================================================
  // ENVIAR POR E-MAIL
  // ============================================================

  Future<void> enviarBoletosPorEmail({
    required String condominioId,
    List<Map<String, dynamic>>? boletosData,
    List<String>? boletoIds,
  }) async {
    try {
      if (boletosData == null && boletoIds == null) return;

      List<Map<String, dynamic>> finalBoletosParaEmail = [];

      if (boletosData != null) {
        finalBoletosParaEmail = boletosData;
      } else if (boletoIds != null && boletoIds.isNotEmpty) {
        // Needs to fetch boleto details from Supabase using their IDs
        var boletos = await _supabase
            .from('boletos')
            .select('id, unidade_id, sacado, valor, data_vencimento')
            .inFilter('id', boletoIds);

        // Fetch unidades
        var unidades = await _supabase
            .from('unidades')
            .select('id, nome_pagador_boleto')
            .eq('condominio_id', condominioId);

        Map<String, String> pagadorMap = {
          for (var u in (unidades as List))
            u['id']: u['nome_pagador_boleto'] ?? 'proprietario',
        };

        // Fetch emails dos moradores
        final proprietariosRes = await _supabase
            .from('proprietarios')
            .select('unidade_id, email')
            .eq('condominio_id', condominioId);

        final inquilinosRes = await _supabase
            .from('inquilinos')
            .select('unidade_id, email')
            .eq('condominio_id', condominioId);

        Map<String, String> emailsIquilinos = {};
        for (var i in (inquilinosRes as List)) {
          if (i['unidade_id'] != null && i['email'] != null) {
            emailsIquilinos[i['unidade_id']] = i['email'];
          }
        }

        Map<String, String> emailsProprietarios = {};
        for (var p in (proprietariosRes as List)) {
          if (p['unidade_id'] != null && p['email'] != null) {
            emailsProprietarios[p['unidade_id']] = p['email'];
          }
        }

        for (var b in (boletos as List)) {
          String unidId = b['unidade_id'];
          String? email;
          String pagador = pagadorMap[unidId] ?? 'proprietario';

          if (pagador == 'inquilino') {
            email = emailsIquilinos[unidId] ?? emailsProprietarios[unidId];
          } else {
            email = emailsProprietarios[unidId] ?? emailsIquilinos[unidId];
          }

          if (email != null && email.isNotEmpty) {
            finalBoletosParaEmail.add({
              'email': email,
              'nome': b['sacado'] ?? 'Condômino',
              'valor': (b['valor'] ?? 0).toDouble(),
              'dataVencimento': b['data_vencimento'],
            });
          }
        }
      }

      if (finalBoletosParaEmail.isNotEmpty) {
        final BoletoEmailService emailService = BoletoEmailService();
        await emailService.enviarLote(finalBoletosParaEmail);
      }
    } catch (e) {
      print('⚠️ [BoletoService] Erro ao enviar boletos por email: $e');
      throw Exception('Erro ao enviar boletos por email.');
    }
  }

  // ============================================================
  // ENVIAR PARA REGISTRO (ASAAS)
  // ============================================================

  Future<Map<String, dynamic>> registrarBoletoNoAsaas(String boletoId) async {
    try {
      final api = LaravelApiService();
      final response = await api.post('/asaas/boletos/registrar-individual', {
        'boletoId': boletoId,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Erro ao registrar boleto no ASAAS.');
      }
    } catch (e) {
      print('⚠️ [BoletoService] Erro ao registrar boleto no ASAAS: $e');
      throw Exception('Erro ao registrar boleto no ASAAS: $e');
    }
  }

  Future<Map<String, dynamic>> enviarParaRegistro(
    List<String> boletoIds,
  ) async {
    try {
      final api = LaravelApiService();
      final response = await api.post('/asaas/boletos/verificar-registro', {
        'paymentIds': boletoIds,
      });

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erro ao verificar registro de boletos.');
      }
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
          .select('id, bloco, numero')
          .eq('condominio_id', condominioId);

      if (pesquisa != null && pesquisa.isNotEmpty) {
        query = query.or(
          'bloco.ilike.%$pesquisa%,numero.ilike.%$pesquisa%',
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
