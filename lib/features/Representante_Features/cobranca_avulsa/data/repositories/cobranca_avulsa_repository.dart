import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cobranca_avulsa_model.dart';
import '../../domain/entities/cobranca_avulsa_entity.dart';

class CobrancaAvulsaRepository {
  final SupabaseClient _supabase;

  CobrancaAvulsaRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  Future<List<CobrancaAvulsaEntity>> getCobrancasAvulsas(String condominioId) async {
    final response = await _supabase
        .from('cobrancas_avulsas')
        .select()
        .eq('condominio_id', condominioId)
        .order('created_at', ascending: false);

    return (response as List).map((e) => CobrancaAvulsaModel.fromJson(e)).toList();
  }

  Future<CobrancaAvulsaEntity> insertCobrancaAvulsa(CobrancaAvulsaEntity cobranca) async {
    final model = CobrancaAvulsaModel(
      condominioId: cobranca.condominioId,
      valor: cobranca.valor,
      unidadeId: cobranca.unidadeId,
      moradorId: cobranca.moradorId,
      contaContabilId: cobranca.contaContabilId,
      dataVencimento: cobranca.dataVencimento,
      mesRef: cobranca.mesRef,
      anoRef: cobranca.anoRef,
      descricao: cobranca.descricao,
      tipoCobranca: cobranca.tipoCobranca,
      status: cobranca.status,
      anexoUrl: cobranca.anexoUrl,
    );

    final response = await _supabase
        .from('cobrancas_avulsas')
        .insert(model.toJson())
        .select()
        .single();

    return CobrancaAvulsaModel.fromJson(response);
  }

  Future<void> deleteCobrancaAvulsa(String id) async {
    await _supabase.from('cobrancas_avulsas').delete().eq('id', id);
  }
}
