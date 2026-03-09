import 'package:flutter_test/flutter_test.dart';
import 'package:condogaiaapp/features/Representante_Features/gestao_condominio/models/textos_condominio_model.dart';

void main() {
  group('TextosCondominio Model - ', () {
    test('Should serialize to JSON correctly without id', () {
      final textos = TextosCondominio(
        condominioId: 'cond-123',
        comunicadoBoletoCota: 'Cota text',
        comunicadoBoletoAcordo: 'Acordo text',
        textoBoletoTaxa: 'Taxa extra text',
        textoBoletoAcordo: 'Extra acordo',
        responsavelTecnicoNome: 'João Silva',
        responsavelTecnicoCpf: '12345678900',
        responsavelTecnicoConselho: 'CRC/SP 12345',
        responsavelTecnicoFuncoes: 'Síndico',
        exibirDataDemonstrativo: true,
      );

      final json = textos.toJson();

      expect(json['id'], isNull); // ID should not be in JSON if null
      expect(json['condominio_id'], 'cond-123');
      expect(json['comunicado_boleto_cota'], 'Cota text');
      expect(json['exibir_data_demonstrativo'], true);
    });

    test('Should parse from JSON correctly', () {
      final json = {
        'id': 'text-123',
        'condominio_id': 'cond-123',
        'comunicado_boleto_cota': 'Cota text',
        'exibir_data_demonstrativo': false,
      };

      final textos = TextosCondominio.fromJson(json);

      expect(textos.id, 'text-123');
      expect(textos.condominioId, 'cond-123');
      expect(textos.comunicadoBoletoCota, 'Cota text');
      expect(textos.comunicadoBoletoAcordo, ''); // Default fallback
      expect(textos.exibirDataDemonstrativo, false);
    });

    test('Should apply copyWith correctly', () {
      final textos = TextosCondominio(
        condominioId: 'cond-123',
        comunicadoBoletoCota: 'Original',
      );

      final updated = textos.copyWith(
        comunicadoBoletoCota: 'Changed',
        exibirDataDemonstrativo: false,
      );

      expect(updated.condominioId, 'cond-123');
      expect(updated.comunicadoBoletoCota, 'Changed');
      expect(updated.exibirDataDemonstrativo, false);
    });
  });
}
