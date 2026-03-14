import 'package:flutter_test/flutter_test.dart';
import 'package:condogaiaapp/features/Prop_Inq_Features/boleto/data/models/boleto_prop_model.dart';
import 'package:condogaiaapp/features/Prop_Inq_Features/boleto/ui/cubit/boleto_prop_state.dart';

void main() {
  group('BoletoPropModel Tests', () {
    final testJson = {
      'id': '123',
      'condominio_id': 'cond_1',
      'unidade_id': 'unid_1',
      'sacado': 'João Silva',
      'bloco_unidade': 'A',
      'referencia': 'JAN/2024',
      'data_vencimento': '2024-01-10',
      'valor': 500.0,
      'status': 'Pago',
      'tipo': 'Taxa Condominial',
      'classe': 'Normal',
      'cota_condominial': 400.0,
      'fundo_reserva': 50.0,
      'multa_infracao': 0.0,
      'controle': 0.0,
      'rateio_agua': 50.0,
      'desconto': 0.0,
      'valor_total': 500.0,
      'bank_slip_url': 'https://example.com/boleto.pdf',
      'bar_code': '123456789',
      'identification_field': '12345678901234567890123456789012345678901234',
      'invoice_url': 'https://example.com/invoice.pdf',
      'codigo_barras': '123456789',
      'descricao': 'Taxa condominial janeiro',
      'is_vencido': false,
    };

    test('Deve criar BoletoPropModel a partir do JSON', () {
      final model = BoletoPropModel.fromJson(testJson);
      
      expect(model.id, '123');
      expect(model.condominioId, 'cond_1');
      expect(model.unidadeId, 'unid_1');
      expect(model.sacado, 'João Silva');
      expect(model.valor, 500.0);
      expect(model.status, 'Pago');
      expect(model.isVencido, false);
    });

    test('Deve converter BoletoPropModel para JSON', () {
      final model = BoletoPropModel.fromJson(testJson);
      final json = model.toJson();
      
      expect(json['id'], '123');
      expect(json['condominio_id'], 'cond_1');
      expect(json['valor'], 500.0);
      expect(json['status'], 'Pago');
      // is_vencido não é salvo no JSON, é calculado
      expect(json['is_vencido'], null);
    });

    test('Deve realizar round-trip JSON completo', () {
      final model1 = BoletoPropModel.fromJson(testJson);
      final json = model1.toJson();
      final model2 = BoletoPropModel.fromJson(json);
      
      expect(model1.id, model2.id);
      expect(model1.condominioId, model2.condominioId);
      expect(model1.sacado, model2.sacado);
      expect(model1.valor, model2.valor);
      expect(model1.status, model2.status);
      expect(model1.isVencido, model2.isVencido);
    });

    test('Deve converter para Entity', () {
      final model = BoletoPropModel.fromJson(testJson);
      
      expect(model.id, '123');
      expect(model.condominioId, 'cond_1');
      expect(model.sacado, 'João Silva');
      expect(model.valor, 500.0);
      expect(model.status, 'Pago');
      expect(model.isVencido, false);
    });

    test('Deve lidar com JSON incompleto', () {
      final incompleteJson = {
        'id': '123',
        'condominio_id': 'cond_1',
        'data_vencimento': '2024-01-10',
        'valor': 500.0,
        'status': 'Pago',
      };
      
      final model = BoletoPropModel.fromJson(incompleteJson);
      
      expect(model.id, '123');
      expect(model.condominioId, 'cond_1');
      expect(model.valor, 500.0);
      expect(model.status, 'Pago');
      expect(model.unidadeId, null);
      expect(model.sacado, null);
    });
  });

  group('BoletoPropState Tests', () {
    final testBoletos = [
      BoletoPropModel.fromJson({
        'id': '1',
        'condominio_id': 'cond_1',
        'data_vencimento': '2024-01-10',
        'valor': 500.0,
        'status': 'Pago',
        'is_vencido': false,
      }),
      BoletoPropModel.fromJson({
        'id': '2',
        'condominio_id': 'cond_1',
        'data_vencimento': '2024-01-15',
        'valor': 600.0,
        'status': 'Aberto',
        'is_vencido': true,
      }),
    ];

    test('Deve filtrar boletos como "Pago"', () {
      final state = BoletoPropState(
        boletos: testBoletos,
        filtroSelecionado: 'Pago',
      );
      
      final filtrados = state.boletosFiltrados;
      expect(filtrados.length, 1);
      expect(filtrados.first.status, 'Pago');
    });

    test('Deve filtrar boletos como "Vencido/ A Vencer"', () {
      final state = BoletoPropState(
        boletos: testBoletos,
        filtroSelecionado: 'Vencido/ A Vencer',
      );
      
      final filtrados = state.boletosFiltrados;
      expect(filtrados.length, 1);
      expect(filtrados.first.status, 'Aberto');
    });

    test('Deve retornar todos boletos não pagos', () {
      final state = BoletoPropState(
        boletos: testBoletos,
        filtroSelecionado: 'Vencido/ A Vencer',
      );
      
      final filtrados = state.boletosFiltrados;
      expect(filtrados.every((b) => b.status != 'Pago'), true);
    });

    test('copyWith deve manter valores não alterados', () {
      final originalState = BoletoPropState(
        status: BoletoPropStatus.loading,
        boletos: testBoletos,
        filtroSelecionado: 'Pago',
        mesSelecionado: 1,
        anoSelecionado: 2024,
      );
      
      final newState = originalState.copyWith(
        status: BoletoPropStatus.success,
      );
      
      expect(newState.status, BoletoPropStatus.success);
      expect(newState.boletos, testBoletos);
      expect(newState.filtroSelecionado, 'Pago');
      expect(newState.mesSelecionado, 1);
      expect(newState.anoSelecionado, 2024);
    });

    test('copyWith com clearBoletoExpandido deve limpar ID', () {
      final originalState = BoletoPropState(
        boletoExpandidoId: '123',
      );
      
      final newState = originalState.copyWith(clearBoletoExpandido: true);
      
      expect(newState.boletoExpandidoId, null);
    });

    test('copyWith deve atualizar múltiplos campos', () {
      final originalState = BoletoPropState();
      
      final newState = originalState.copyWith(
        status: BoletoPropStatus.error,
        errorMessage: 'Test error',
        mesSelecionado: 2,
        anoSelecionado: 2025,
        composicaoBoletoExpandida: true,
      );
      
      expect(newState.status, BoletoPropStatus.error);
      expect(newState.errorMessage, 'Test error');
      expect(newState.mesSelecionado, 2);
      expect(newState.anoSelecionado, 2025);
      expect(newState.composicaoBoletoExpandida, true);
    });

    test('Props deve incluir todos campos relevantes', () {
      final state = BoletoPropState(
        status: BoletoPropStatus.loading,
        boletos: testBoletos,
        filtroSelecionado: 'Pago',
        boletoExpandidoId: '123',
        mesSelecionado: 1,
        anoSelecionado: 2024,
        composicaoBoletoExpandida: true,
        leiturasExpandida: false,
        balanceteOnlineExpandido: true,
        composicaoBoleto: {'cotaCondominial': 400.0},
        demonstrativoFinanceiro: {'totalValor': 500.0},
        leituras: [],
        balanceteOnline: {'saldo': 100.0},
        errorMessage: 'Error',
        successMessage: 'Success',
      );
      
      final props = state.props;
      expect(props.length, 15);
      expect(props.contains(state.status), true);
      expect(props.contains(state.boletos), true);
      expect(props.contains(state.filtroSelecionado), true);
      expect(props.contains(state.errorMessage), true);
      expect(props.contains(state.successMessage), true);
    });

    test('Deve lidar com lista vazia de boletos', () {
      final state = BoletoPropState(
        boletos: [],
        filtroSelecionado: 'Pago',
      );
      
      final filtrados = state.boletosFiltrados;
      expect(filtrados.isEmpty, true);
    });
  });
}
