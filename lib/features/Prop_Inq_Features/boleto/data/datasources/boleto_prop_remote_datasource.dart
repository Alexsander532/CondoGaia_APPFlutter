import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/boleto_prop_model.dart';
import '../../../../../services/laravel_api_service.dart';
import 'dart:convert';

/// Contrato abstrato do DataSource remoto
abstract class BoletoPropRemoteDataSource {
  Future<List<BoletoPropModel>> obterBoletos({
    required String moradorId,
    String? filtroStatus,
  });

  Future<BoletoPropModel?> obterBoletoPorId(String boletoId);

  /// Sincroniza o boleto com o Asaas e retorna a linha digitável (código de barras).
  /// Se o boleto já está registrado, apenas busca a linha digitável.
  /// Se não, registra primeiro e depois busca.
  Future<String> sincronizarBoleto(String boletoId);

  Future<Map<String, double>> obterComposicaoBoleto(String boletoId);

  Future<Map<String, dynamic>> obterDemonstrativoFinanceiro({
    required String moradorId,
    required int mes,
    required int ano,
  });

  Future<List<Map<String, dynamic>>> obterLeituras({
    required String unidadeId,
    required int mes,
    required int ano,
  });

  Future<Map<String, dynamic>> obterBalanceteOnline({
    required String condominioId,
    required int mes,
    required int ano,
  });
}

/// Implementação do DataSource remoto (Supabase)
class BoletoPropRemoteDataSourceImpl implements BoletoPropRemoteDataSource {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<List<BoletoPropModel>> obterBoletos({
    required String moradorId,
    String? filtroStatus,
  }) async {
    try {
      var query = _supabase
          .from('boletos')
          .select('*')
          .eq('sacado', moradorId);

      // Aplicar filtro de status
      if (filtroStatus != null && filtroStatus.isNotEmpty) {
        if (filtroStatus == 'Vencido/ A Vencer') {
          // Boletos que não estão pagos
          query = query.not('status', 'eq', 'Pago');
        } else if (filtroStatus == 'Pago') {
          query = query.eq('status', 'Pago');
        }
      }

      // Ordenar após aplicar filtros
      final response = await query.order('data_vencimento', ascending: false);
      
      return (response as List)
          .map((json) => BoletoPropModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Erro ao obter boletos: $e');
      rethrow;
    }
  }

  @override
  Future<BoletoPropModel?> obterBoletoPorId(String boletoId) async {
    try {
      final response = await _supabase
          .from('boletos')
          .select('*')
          .eq('id', boletoId)
          .maybeSingle();

      if (response == null) return null;
      
      return BoletoPropModel.fromJson(response);
    } catch (e) {
      print('Erro ao obter boleto por ID: $e');
      rethrow;
    }
  }

  @override
  Future<String> sincronizarBoleto(String boletoId) async {
    try {
      // 1. Buscar boleto no Supabase para ver se já tem asaas_payment_id
      final boletoResponse = await _supabase
          .from('boletos')
          .select('asaas_payment_id, identification_field, bar_code')
          .eq('id', boletoId)
          .maybeSingle();

      String? asaasPaymentId = boletoResponse?['asaas_payment_id'];
      
      // 2. Se já tem código no banco, retornar direto (sem chamar backend)
      final codigoNoBanco = boletoResponse?['identification_field'] 
                          ?? boletoResponse?['bar_code'];
      if (codigoNoBanco != null && codigoNoBanco.toString().isNotEmpty) {
        return codigoNoBanco.toString();
      }

      final api = LaravelApiService();

      // 3. Se não está registrado no Asaas ainda, registrar agora
      if (asaasPaymentId == null || asaasPaymentId.isEmpty) {
        final registroResponse = await api.post('/asaas/boletos/registrar-individual', {
          'boletoId': boletoId,
        });

        if (registroResponse.statusCode != 200 && registroResponse.statusCode != 201) {
          final error = jsonDecode(registroResponse.body);
          throw Exception(error['message'] ?? 'Erro ao registrar boleto com Asaas.');
        }

        final registroData = jsonDecode(registroResponse.body);
        
        // Verificar se o registro já retornou o identification_field
        final boletoRegistrado = registroData['data']?['boleto'];
        final codigoRetornado = boletoRegistrado?['identification_field'] 
                              ?? boletoRegistrado?['bar_code'];
        
        if (codigoRetornado != null && codigoRetornado.toString().isNotEmpty) {
          return codigoRetornado.toString();
        }
        
        // Obter o asaas_payment_id do registro para continuar
        asaasPaymentId = registroData['data']?['paymentId'];
        if (asaasPaymentId == null || asaasPaymentId.isEmpty) {
          throw Exception('Boleto registrado mas sem ID do Asaas retornado.');
        }
      }

      // 4. Buscar linha digitável usando o ID do Asaas
      final linhaResponse = await api.get('/asaas/boletos/$asaasPaymentId/linha-digitavel');

      if (linhaResponse.statusCode != 200) {
        final error = jsonDecode(linhaResponse.body);
        throw Exception(error['message'] ?? 'Erro ao buscar linha digitável.');
      }

      final linhaData = jsonDecode(linhaResponse.body);
      final codigo = linhaData['data']?['identificationField'] 
                   ?? linhaData['data']?['barCode']
                   ?? linhaData['data']?.toString();
      
      if (codigo == null || codigo.isEmpty) {
        throw Exception('Código de barras não disponível no Asaas');
      }

      return codigo;
    } catch (e) {
      print('Erro ao sincronizar boleto: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, double>> obterComposicaoBoleto(String boletoId) async {
    try {
      final response = await _supabase
          .from('boletos')
          .select('''
            cota_condominial,
            fundo_reserva,
            rateio_agua,
            multa_infracao,
            controle,
            desconto,
            valor_total
          ''')
          .eq('id', boletoId)
          .maybeSingle();

      if (response == null) return {};

      return {
        'cotaCondominial': (response['cota_condominial'] ?? 0).toDouble(),
        'fundoReserva': (response['fundo_reserva'] ?? 0).toDouble(),
        'rateioAgua': (response['rateio_agua'] ?? 0).toDouble(),
        'multaInfracao': (response['multa_infracao'] ?? 0).toDouble(),
        'controle': (response['controle'] ?? 0).toDouble(),
        'desconto': (response['desconto'] ?? 0).toDouble(),
        'valorTotal': (response['valor_total'] ?? 0).toDouble(),
      };
    } catch (e) {
      print('Erro ao obter composição do boleto: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> obterDemonstrativoFinanceiro({
    required String moradorId,
    required int mes,
    required int ano,
  }) async {
    try {
      // Buscar boletos do morador no mês/ano específico
      final response = await _supabase
          .from('boletos')
          .select('*')
          .eq('sacado', moradorId)
          .gte('data_vencimento', '$ano-$mes-01')
          .lte('data_vencimento', '$ano-$mes-31')
          .order('data_vencimento', ascending: false);

      final boletos = (response as List)
          .map((json) => BoletoPropModel.fromJson(json))
          .toList();

      // Calcular totais
      final totalValor = boletos.fold<double>(0, (sum, b) => sum + b.valor);
      final totalPago = boletos
          .where((b) => b.status == 'Pago')
          .fold<double>(0, (sum, b) => sum + b.valor);
      final totalEmAberto = totalValor - totalPago;

      return {
        'boletos': boletos.map((b) => b.toJson()).toList(),
        'totalValor': totalValor,
        'totalPago': totalPago,
        'totalEmAberto': totalEmAberto,
        'quantidadeBoletos': boletos.length,
        'quantidadePagos': boletos.where((b) => b.status == 'Pago').length,
        'quantidadeEmAberto': boletos.where((b) => b.status != 'Pago').length,
      };
    } catch (e) {
      print('Erro ao obter demonstrativo financeiro: $e');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> obterLeituras({
    required String unidadeId,
    required int mes,
    required int ano,
  }) async {
    try {
      final response = await _supabase
          .from('leituras')
          .select('*')
          .eq('unidade_id', unidadeId)
          .gte('data_leitura', '$ano-$mes-01')
          .lte('data_leitura', '$ano-$mes-31')
          .order('data_leitura', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erro ao obter leituras: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> obterBalanceteOnline({
    required String condominioId,
    required int mes,
    required int ano,
  }) async {
    try {
      final response = await _supabase
          .from('balancetes')
          .select('*')
          .eq('condominio_id', condominioId)
          .eq('mes', mes)
          .eq('ano', ano)
          .maybeSingle();

      if (response == null) {
        throw Exception('Balancete não encontrado para o período');
      }

      return Map<String, dynamic>.from(response);
    } catch (e) {
      print('Erro ao obter balancete online: $e');
      rethrow;
    }
  }
}
