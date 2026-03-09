import '../models/despesa_model.dart';
import '../models/receita_model.dart';
import '../models/transferencia_model.dart';
import '../../gestao_condominio/models/conta_bancaria_model.dart';
import '../../gestao_condominio/models/categoria_financeira_model.dart';

abstract class IDespesaReceitaService {
  Future<List<ContaBancaria>> listarContas(String condominioId);
  Future<List<CategoriaFinanceira>> listarCategorias(String condominioId);

  Future<List<Despesa>> listarDespesas(
    String condominioId, {
    int? mes,
    int? ano,
    String? contaId,
    String? categoriaId,
    String? subcategoriaId,
    String? palavraChave,
  });

  Future<void> salvarDespesa(Despesa despesa);
  Future<void> excluirDespesa(String id);
  Future<void> excluirDespesasMultiplas(List<String> ids);

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
  });

  Future<void> salvarReceita(Receita receita);
  Future<void> excluirReceita(String id);
  Future<void> excluirReceitasMultiplas(List<String> ids);

  Future<List<Transferencia>> listarTransferencias(
    String condominioId, {
    int? mes,
    int? ano,
    String? contaDebitoId,
    String? contaCreditoId,
    String? palavraChave,
  });

  Future<void> salvarTransferencia(Transferencia transferencia);
  Future<void> excluirTransferencia(String id);
  Future<void> excluirTransferenciasMultiplas(List<String> ids);

  Future<double> calcularSaldoAnterior(
    String condominioId, {
    required int mes,
    required int ano,
  });
}
