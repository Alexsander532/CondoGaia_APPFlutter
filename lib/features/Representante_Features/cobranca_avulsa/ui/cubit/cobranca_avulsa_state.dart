import 'dart:io';
import '../../domain/entities/cobranca_avulsa_entity.dart';

// ====================================================================
// ENUM FOR STATUS
// ====================================================================

enum CobrancaAvulsaStatus { initial, loading, success, error }

// ====================================================================
// STATE CLASS
// ====================================================================

class CobrancaAvulsaState {
  // ============ DADOS DO FORMULÁRIO ============
  String? contaContabilId;
  String? pesquisaUnidade;
  int mesSelecionado;
  int anoSelecionado;
  String? descricao;
  String? tipoCobranca; // 'Junto a Taxa Cond.' ou 'Boleto Avulso'
  int? dia;
  double? valorPorUnidade;
  bool recorrente;
  int? qtdMeses;
  DateTime? dataInicio;
  DateTime? dataFim;
  File? imagemArquivo;
  bool enviarParaRegistro;
  bool enviarPorEmail;

  // ============ CARRINHO (LOTE EM ELABORAÇÃO) ============
  List<CobrancaAvulsaEntity> itemsCarrinho;
  Set<String> itemsSelecionados; // IDs dos items selecionados

  // ============ LISTAGEM E FILTROS ============
  List<CobrancaAvulsaEntity> cobrancasCarregadas;
  
  // ============ UI STATE ============
  CobrancaAvulsaStatus status;
  String? errorMessage;
  bool isSaving;

  CobrancaAvulsaState({
    this.contaContabilId,
    this.pesquisaUnidade,
    this.mesSelecionado = 1,
    this.anoSelecionado = 2026,
    this.descricao,
    this.tipoCobranca,
    this.dia,
    this.valorPorUnidade,
    this.recorrente = false,
    this.qtdMeses,
    this.dataInicio,
    this.dataFim,
    this.imagemArquivo,
    this.enviarParaRegistro = false,
    this.enviarPorEmail = false,
    this.itemsCarrinho = const [],
    this.itemsSelecionados = const {},
    this.cobrancasCarregadas = const [],
    this.status = CobrancaAvulsaStatus.initial,
    this.errorMessage,
    this.isSaving = false,
  });

  // ============ MÉTODO COPYWITH ============
  CobrancaAvulsaState copyWith({
    String? contaContabilId,
    String? pesquisaUnidade,
    int? mesSelecionado,
    int? anoSelecionado,
    String? descricao,
    String? tipoCobranca,
    int? dia,
    double? valorPorUnidade,
    bool? recorrente,
    int? qtdMeses,
    DateTime? dataInicio,
    DateTime? dataFim,
    File? imagemArquivo,
    bool? enviarParaRegistro,
    bool? enviarPorEmail,
    List<CobrancaAvulsaEntity>? itemsCarrinho,
    Set<String>? itemsSelecionados,
    List<CobrancaAvulsaEntity>? cobrancasCarregadas,
    CobrancaAvulsaStatus? status,
    String? errorMessage,
    bool? clearErrorMessage,
    bool? isSaving,
    bool? clearImagemArquivo,
    bool? clearCarrinho,
  }) {
    return CobrancaAvulsaState(
      contaContabilId: contaContabilId ?? this.contaContabilId,
      pesquisaUnidade: pesquisaUnidade ?? this.pesquisaUnidade,
      mesSelecionado: mesSelecionado ?? this.mesSelecionado,
      anoSelecionado: anoSelecionado ?? this.anoSelecionado,
      descricao: descricao ?? this.descricao,
      tipoCobranca: tipoCobranca ?? this.tipoCobranca,
      dia: dia ?? this.dia,
      valorPorUnidade: valorPorUnidade ?? this.valorPorUnidade,
      recorrente: recorrente ?? this.recorrente,
      qtdMeses: qtdMeses ?? this.qtdMeses,
      dataInicio: dataInicio ?? this.dataInicio,
      dataFim: dataFim ?? this.dataFim,
      imagemArquivo: clearImagemArquivo == true ? null : (imagemArquivo ?? this.imagemArquivo),
      enviarParaRegistro: enviarParaRegistro ?? this.enviarParaRegistro,
      enviarPorEmail: enviarPorEmail ?? this.enviarPorEmail,
      itemsCarrinho: clearCarrinho == true ? [] : (itemsCarrinho ?? this.itemsCarrinho),
      itemsSelecionados: itemsSelecionados ?? this.itemsSelecionados,
      cobrancasCarregadas: cobrancasCarregadas ?? this.cobrancasCarregadas,
      status: status ?? this.status,
      errorMessage: clearErrorMessage == true ? null : (errorMessage ?? this.errorMessage),
      isSaving: isSaving ?? this.isSaving,
    );
  }

  // ============ GETTERS COMPUTADOS ============
  double get valorTotalCarrinho {
    return itemsCarrinho.fold(0.0, (sum, item) => sum + item.valor);
  }

  double get valorTotalCarregadas {
    return cobrancasCarregadas.fold(0.0, (sum, item) => sum + item.valor);
  }
}