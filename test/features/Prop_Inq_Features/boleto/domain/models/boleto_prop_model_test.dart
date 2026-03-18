import 'package:flutter_test/flutter_test.dart';
import 'package:condogaiaapp/features/Prop_Inq_Features/boleto/data/models/boleto_prop_model.dart';

void main() {
  group('BoletoPropModel', () {
    test('deve criar um BoletoPropModel a partir de um JSON válido', () {
      final json = {
        'id': 'uuid-1234',
        'condominio_id': 'cond-1234',
        'unidade_id': 'unid-1234',
        'sacado': 'morador-1234',
        'bloco_unidade': 'A 101',
        'referencia': '03/2026',
        'data_vencimento': '2026-03-30T00:00:00',
        'valor': 500.50,
        'status': 'Pendente',
        'tipo': 'Mensal',
        'cota_condominial': 300.0,
        'fundo_reserva': 30.0,
        'rateio_agua': 170.50,
        'asaas_payment_id': 'pay_123',
      };

      final model = BoletoPropModel.fromJson(json);

      expect(model.id, 'uuid-1234');
      expect(model.condominioId, 'cond-1234');
      expect(model.unidadeId, 'unid-1234');
      expect(model.sacado, 'morador-1234');
      expect(model.blocoUnidade, 'A 101');
      expect(model.referencia, '03/2026');
      expect(model.valor, 500.50);
      expect(model.status, 'Pendente');
      expect(model.tipo, 'Mensal');
      expect(model.cotaCondominial, 300.0);
      expect(model.fundoReserva, 30.0);
      expect(model.rateioAgua, 170.50);
      expect(model.asaasPaymentId, 'pay_123');
      expect(model.isVencido, false);
      expect(model.dataVencimento.year, 2026);
      expect(model.dataVencimento.month, 3);
      expect(model.dataVencimento.day, 30);
    });

    test('deve criar um BoletoPropModel com isVencido=true se data_vencimento passou e status != Pago', () {
      final json = {
        'id': 'uuid-1234',
        'condominio_id': 'cond-1234',
        'data_vencimento': '2000-01-01T00:00:00', // data no passado
        'status': 'Pendente',
        'valor': 100.0,
      };

      final model = BoletoPropModel.fromJson(json);
      expect(model.isVencido, true);
    });

    test('isVencido deve ser false se o boleto está pago, mesmo com data no passado', () {
      final json = {
        'id': 'uuid-1234',
        'condominio_id': 'cond-1234',
        'data_vencimento': '2000-01-01T00:00:00',
        'status': 'Pago',
        'valor': 100.0,
      };

      final model = BoletoPropModel.fromJson(json);
      expect(model.isVencido, false);
    });

    test('deve converter BoletoPropModel para JSON corretamente', () {
      final dataVenc = DateTime(2026, 3, 30);
      final model = BoletoPropModel(
        id: 'uuid-1234',
        condominioId: 'cond-1234',
        dataVencimento: dataVenc,
        valor: 500.50,
        status: 'Pendente',
        tipo: 'Mensal',
      );

      final json = model.toJson();

      expect(json['id'], 'uuid-1234');
      expect(json['condominio_id'], 'cond-1234');
      expect(json['data_vencimento'], '2026-03-30');
      expect(json['valor'], 500.50);
      expect(json['status'], 'Pendente');
      expect(json['tipo'], 'Mensal');
    });
  });
}
