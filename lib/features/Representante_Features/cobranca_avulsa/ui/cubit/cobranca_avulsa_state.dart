import 'dart:io';
import '../../domain/entities/cobranca_avulsa_entity.dart';
import 'package:condogaiaapp/models/bloco_com_unidades.dart';

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
  Map<String, double> valoresPorUnidade;
  bool recorrente;
  int? qtdMeses;
  DateTime? dataInicio;
  DateTime? dataFim;
  File? imagemArquivo;
  bool enviarParaRegistro;
  bool enviarPorEmail;

  // ============ PESQUISA DE UNIDADES ============
  List<BlocoComUnidades> unidadesPesquisadas;
  Set<String> unidadesSelecionadas; // IDs das unidades selecionadas
  bool loadingUnidades;

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
    this.valoresPorUnidade = const {},
    this.recorrente = false,
    this.qtdMeses,
    this.dataInicio,
    this.dataFim,
    this.imagemArquivo,
    this.enviarParaRegistro = false,
    this.enviarPorEmail = false,
    this.unidadesPesquisadas = const [],
    this.unidadesSelecionadas = const {},
    this.loadingUnidades = false,
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
    Map<String, double>? valoresPorUnidade,
    bool? recorrente,
    int? qtdMeses,
    DateTime? dataInicio,
    DateTime? dataFim,
    File? imagemArquivo,
    bool? enviarParaRegistro,
    bool? enviarPorEmail,
    List<BlocoComUnidades>? unidadesPesquisadas,
    Set<String>? unidadesSelecionadas,
    bool? loadingUnidades,
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
      valoresPorUnidade: valoresPorUnidade ?? this.valoresPorUnidade,
      recorrente: recorrente ?? this.recorrente,
      qtdMeses: qtdMeses ?? this.qtdMeses,
      dataInicio: dataInicio ?? this.dataInicio,
      dataFim: dataFim ?? this.dataFim,
      imagemArquivo: clearImagemArquivo == true ? null : (imagemArquivo ?? this.imagemArquivo),
      enviarParaRegistro: enviarParaRegistro ?? this.enviarParaRegistro,
      enviarPorEmail: enviarPorEmail ?? this.enviarPorEmail,
      unidadesPesquisadas: unidadesPesquisadas ?? this.unidadesPesquisadas,
      unidadesSelecionadas: unidadesSelecionadas ?? this.unidadesSelecionadas,
      loadingUnidades: loadingUnidades ?? this.loadingUnidades,
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