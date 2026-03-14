import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/boleto_prop_model.dart';

/// Contrato abstrato do DataSource remoto
abstract class BoletoPropRemoteDataSource {
  Future<List<BoletoPropModel>> obterBoletos({
    required String moradorId,
    String? filtroStatus,
  });

  Future<BoletoPropModel?> obterBoletoPorId(String boletoId);

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
