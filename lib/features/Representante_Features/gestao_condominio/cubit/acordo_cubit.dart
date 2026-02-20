import 'package:flutter_bloc/flutter_bloc.dart';
import 'acordo_state.dart';
import '../models/acordo_model.dart';

class AcordoCubit extends Cubit<AcordoState> {
  final String condominioId;

  AcordoCubit({required this.condominioId}) : super(const AcordoState());

  /// Carrega dados mock iniciais
  void carregarDados() {
    emit(state.copyWith(status: AcordoStatus.loading));

    // Dados mock para demonstração
    final acordosMock = [
      Acordo(
        id: '1',
        blUnid: 'A-102',
        parcela: '1/5',
        mesAno: '05/2022',
        dataVencimento: DateTime(2022, 8, 10),
        valor: 111.00,
        tipo: 'MENSAL',
        situacao: 'PAGO',
        nome: 'Maria da Silva',
      ),
      Acordo(
        id: '2',
        blUnid: 'A-102',
        parcela: '2/5',
        mesAno: '05/2022',
        dataVencimento: DateTime(2022, 9, 10),
        valor: 111.00,
        tipo: 'MENSAL',
        situacao: 'ATIVO',
        nome: 'Maria da Silva',
      ),
      Acordo(
        id: '3',
        blUnid: 'B-201',
        parcela: '1/3',
        mesAno: '06/2022',
        dataVencimento: DateTime(2022, 10, 15),
        valor: 250.00,
        tipo: 'AVULSO',
        situacao: 'A VENCER',
        nome: 'João Oliveira',
      ),
    ];

    final historicoMock = [
      HistoricoAcordo(
        id: '1',
        blUnid: 'A/102',
        data: DateTime(2022, 9, 11),
        hora: '09H',
        descricao: 'LIGUEI E DISSE QUE VAI FALAR COM O MARIDO E ME RETORNAR.',
      ),
    ];

    emit(
      state.copyWith(
        status: AcordoStatus.loaded,
        acordos: acordosMock,
        historico: historicoMock,
      ),
    );
  }

  /// Alterna seleção de um acordo
  void toggleSelecionarAcordo(String id) {
    final novaLista = state.acordos.map((a) {
      if (a.id == id) {
        return a.copyWith(selecionado: !a.selecionado);
      }
      return a;
    }).toList();
    emit(state.copyWith(acordos: novaLista));
  }

  /// Selecionar/desselecionar todos
  void toggleSelecionarTodos(bool selecionar) {
    final novaLista = state.acordos
        .map((a) => a.copyWith(selecionado: selecionar))
        .toList();
    emit(state.copyWith(acordos: novaLista));
  }

  /// Retorna somente os acordos selecionados
  List<Acordo> get acordosSelecionados =>
      state.acordos.where((a) => a.selecionado).toList();

  /// Simula as parcelas de negociação
  void simularParcelas({
    required int numParcelas,
    required double jurosPercent,
    required double multaPercent,
    required double indicePercent,
    required DateTime primeiroVencimento,
    double outrosAcrescimos = 0,
    bool temEntrada = false,
    double valorEntrada = 0,
  }) {
    final selecionados = acordosSelecionados;
    if (selecionados.isEmpty) return;

    final totalBase = selecionados.fold<double>(0, (sum, a) => sum + a.valor);
    double totalComDesconto = totalBase;
    if (temEntrada) {
      totalComDesconto -= valorEntrada;
    }

    final List<ParcelaAcordo> parcelas = [];
    final valorParcela = totalComDesconto / numParcelas;

    for (int i = 0; i < numParcelas; i++) {
      final dataVenc = DateTime(
        primeiroVencimento.year,
        primeiroVencimento.month + i,
        primeiroVencimento.day,
      );
      final mesAnoStr =
          '${dataVenc.month.toString().padLeft(2, '0')}/${dataVenc.year}';
      final jurosVal = valorParcela * (jurosPercent / 100);
      final multaVal = valorParcela * (multaPercent / 100);
      final indiceVal = valorParcela * (indicePercent / 100);
      final acrescimosParcela = outrosAcrescimos / numParcelas;
      final totalParcela =
          valorParcela + jurosVal + multaVal + indiceVal + acrescimosParcela;

      parcelas.add(
        ParcelaAcordo(
          id: 'p_${i + 1}',
          blUnid: selecionados.first.blUnid,
          parcela: '${i + 1}/$numParcelas',
          mesAno: mesAnoStr,
          dataVencimento: dataVenc,
          valor: valorParcela,
          juros: jurosVal,
          multa: multaVal,
          indice: indiceVal,
          outrosAcrescimos: acrescimosParcela,
          total: totalParcela,
        ),
      );
    }

    emit(state.copyWith(parcelas: parcelas));
  }

  /// Alterna seleção de uma parcela simulada
  void toggleSelecionarParcela(String id) {
    final novaLista = state.parcelas.map((p) {
      if (p.id == id) {
        return p.copyWith(selecionado: !p.selecionado);
      }
      return p;
    }).toList();
    emit(state.copyWith(parcelas: novaLista));
  }

  /// Adiciona entrada no histórico
  void adicionarHistorico(String blUnid, String descricao) {
    final agora = DateTime.now();
    final novoItem = HistoricoAcordo(
      id: 'h_${state.historico.length + 1}',
      blUnid: blUnid,
      data: agora,
      hora: '${agora.hour.toString().padLeft(2, '0')}H',
      descricao: descricao,
    );
    emit(state.copyWith(historico: [...state.historico, novoItem]));
  }

  /// Cancela o acordo (stub)
  void cancelarAcordo() {
    // Stub — futura integração com backend
  }

  /// Remove uma parcela
  void excluirParcela(String id) {
    final novaLista = state.parcelas.where((p) => p.id != id).toList();
    emit(state.copyWith(parcelas: novaLista));
  }
}
