/// Comprehensive unit tests for Despesa/Receita/Transferencia models.
///
/// Tests cover:
/// - Construction with required/optional params
/// - fromJson deserialization (incl. nested join fields)
/// - toJson serialization
/// - copyWith immutability
/// - Equatable equality / inequality

import 'package:flutter_test/flutter_test.dart';
import 'package:condogaiaapp/features/Representante_Features/despesa_receita/models/despesa_model.dart';
import 'package:condogaiaapp/features/Representante_Features/despesa_receita/models/receita_model.dart';
import 'package:condogaiaapp/features/Representante_Features/despesa_receita/models/transferencia_model.dart';
import 'package:condogaiaapp/features/Representante_Features/gestao_condominio/models/categoria_financeira_model.dart';

void main() {
  // ════════════════════════════════════════════════════════
  //  DESPESA MODEL
  // ════════════════════════════════════════════════════════

  group('Despesa Model', () {
    late Map<String, dynamic> fullJson;

    setUp(() {
      fullJson = {
        'id': 'desp-001',
        'condominio_id': 'cond-001',
        'conta_id': 'conta-001',
        'categoria_id': 'cat-001',
        'subcategoria_id': 'sub-001',
        'descricao': 'Manutenção elevador',
        'valor': 1500.50,
        'data_vencimento': '2026-03-15',
        'recorrente': true,
        'qtd_meses': 12,
        'me_avisar': true,
        'link': 'https://example.com/nota.pdf',
        'foto_url': 'https://example.com/foto.jpg',
        'tipo': 'AUTOMATICO',
        'created_at': '2026-01-10T10:30:00',
        'contas_bancarias': {'banco': 'Banco do Brasil'},
        'categorias_financeiras': {'nome': 'Manutenção'},
        'subcategorias_financeiras': {'nome': 'Elevadores'},
      };
    });

    test('deve criar Despesa com valores padrão', () {
      const despesa = Despesa(condominioId: 'cond-001');

      expect(despesa.id, isNull);
      expect(despesa.condominioId, 'cond-001');
      expect(despesa.valor, 0);
      expect(despesa.recorrente, false);
      expect(despesa.meAvisar, false);
      expect(despesa.tipo, 'MANUAL');
    });

    test('deve criar Despesa a partir de JSON completo', () {
      final despesa = Despesa.fromJson(fullJson);

      expect(despesa.id, 'desp-001');
      expect(despesa.condominioId, 'cond-001');
      expect(despesa.contaId, 'conta-001');
      expect(despesa.categoriaId, 'cat-001');
      expect(despesa.subcategoriaId, 'sub-001');
      expect(despesa.descricao, 'Manutenção elevador');
      expect(despesa.valor, 1500.50);
      expect(despesa.dataVencimento, DateTime(2026, 3, 15));
      expect(despesa.recorrente, true);
      expect(despesa.qtdMeses, 12);
      expect(despesa.meAvisar, true);
      expect(despesa.link, 'https://example.com/nota.pdf');
      expect(despesa.fotoUrl, 'https://example.com/foto.jpg');
      expect(despesa.tipo, 'AUTOMATICO');
      expect(despesa.contaNome, 'Banco do Brasil');
      expect(despesa.categoriaNome, 'Manutenção');
      expect(despesa.subcategoriaNome, 'Elevadores');
    });

    test('deve tratar JSON com valores nulos graciosamente', () {
      final minimalJson = {'condominio_id': 'cond-001'};
      final despesa = Despesa.fromJson(minimalJson);

      expect(despesa.condominioId, 'cond-001');
      expect(despesa.valor, 0.0);
      expect(despesa.recorrente, false);
      expect(despesa.meAvisar, false);
      expect(despesa.tipo, 'MANUAL');
      expect(despesa.contaNome, isNull);
      expect(despesa.categoriaNome, isNull);
    });

    test('fromJson sem condominio_id deve usar string vazia', () {
      final despesa = Despesa.fromJson({});
      expect(despesa.condominioId, '');
    });

    test('toJson deve produzir mapa correto', () {
      final despesa = Despesa.fromJson(fullJson);
      final json = despesa.toJson();

      expect(json['id'], 'desp-001');
      expect(json['condominio_id'], 'cond-001');
      expect(json['valor'], 1500.50);
      expect(json['recorrente'], true);
      expect(json['tipo'], 'AUTOMATICO');
      // Join fields should NOT be in toJson
      expect(json.containsKey('contas_bancarias'), false);
      expect(json.containsKey('categorias_financeiras'), false);
    });

    test('toJson sem id não deve incluir chave id', () {
      const despesa = Despesa(condominioId: 'cond-001');
      final json = despesa.toJson();
      expect(json.containsKey('id'), false);
    });

    test('copyWith deve preservar campos não alterados', () {
      final original = Despesa.fromJson(fullJson);
      final copy = original.copyWith(valor: 2000.00);

      expect(copy.valor, 2000.00);
      expect(copy.descricao, original.descricao);
      expect(copy.id, original.id);
      expect(copy.condominioId, original.condominioId);
    });

    test('Equatable: despesas com mesmos dados devem ser iguais', () {
      final d1 = Despesa.fromJson(fullJson);
      final d2 = Despesa.fromJson(fullJson);
      expect(d1, equals(d2));
    });

    test('Equatable: despesas com dados diferentes devem ser desiguais', () {
      final d1 = Despesa.fromJson(fullJson);
      final d2 = d1.copyWith(valor: 9999);
      expect(d1, isNot(equals(d2)));
    });
  });

  // ════════════════════════════════════════════════════════
  //  RECEITA MODEL
  // ════════════════════════════════════════════════════════

  group('Receita Model', () {
    late Map<String, dynamic> fullJson;

    setUp(() {
      fullJson = {
        'id': 'rec-001',
        'condominio_id': 'cond-001',
        'conta_id': 'conta-001',
        'categoria_id': 'cat-002',
        'subcategoria_id': 'sub-002',
        'conta_contabil': 'Controle',
        'descricao': 'Taxa condominial',
        'valor': 850.00,
        'data_credito': '2026-03-01',
        'recorrente': true,
        'qtd_meses': 6,
        'tipo': 'MANUAL',
        'created_at': '2026-01-05T08:00:00',
        'contas_bancarias': {'banco': 'Itaú'},
        'categorias_financeiras': {'nome': 'Taxas'},
        'subcategorias_financeiras': {'nome': 'Condominial'},
      };
    });

    test('deve criar Receita com valores padrão', () {
      const receita = Receita(condominioId: 'cond-001');
      expect(receita.valor, 0);
      expect(receita.recorrente, false);
      expect(receita.tipo, 'MANUAL');
    });

    test('deve criar Receita a partir de JSON completo', () {
      final receita = Receita.fromJson(fullJson);

      expect(receita.id, 'rec-001');
      expect(receita.contaContabil, 'Controle');
      expect(receita.valor, 850.00);
      expect(receita.dataCredito, DateTime(2026, 3, 1));
      expect(receita.contaNome, 'Itaú');
      expect(receita.categoriaNome, 'Taxas');
      expect(receita.subcategoriaNome, 'Condominial');
    });

    test('deve tratar JSON mínimo (nullable fields)', () {
      final receita = Receita.fromJson({'condominio_id': 'c1'});
      expect(receita.condominioId, 'c1');
      expect(receita.dataCredito, isNull);
      expect(receita.contaNome, isNull);
    });

    test('toJson deve incluir id quando presente', () {
      final receita = Receita.fromJson(fullJson);
      final json = receita.toJson();
      expect(json['id'], 'rec-001');
      expect(json['conta_contabil'], 'Controle');
    });

    test('toJson não deve incluir campos auxiliares de join', () {
      final json = Receita.fromJson(fullJson).toJson();
      expect(json.containsKey('contas_bancarias'), false);
      expect(json.containsKey('categorias_financeiras'), false);
      expect(json.containsKey('contaNome'), false);
    });

    test('copyWith deve alterar apenas campos especificados', () {
      final original = Receita.fromJson(fullJson);
      final copy = original.copyWith(descricao: 'Novo descricao', valor: 999);

      expect(copy.descricao, 'Novo descricao');
      expect(copy.valor, 999);
      expect(copy.id, original.id);
      expect(copy.contaContabil, original.contaContabil);
    });

    test('Equatable: receitas idênticas devem ser iguais', () {
      final r1 = Receita.fromJson(fullJson);
      final r2 = Receita.fromJson(fullJson);
      expect(r1, equals(r2));
    });
  });

  // ════════════════════════════════════════════════════════
  //  TRANSFERENCIA MODEL
  // ════════════════════════════════════════════════════════

  group('Transferencia Model', () {
    late Map<String, dynamic> fullJson;

    setUp(() {
      fullJson = {
        'id': 'transf-001',
        'condominio_id': 'cond-001',
        'conta_debito_id': 'conta-001',
        'conta_credito_id': 'conta-002',
        'descricao': 'Transferência entre contas',
        'valor': 5000.00,
        'data_transferencia': '2026-02-20',
        'recorrente': false,
        'qtd_meses': null,
        'tipo': 'MANUAL',
        'created_at': '2026-02-20T14:00:00',
        'conta_debito': {'banco': 'Banco do Brasil'},
        'conta_credito': {'banco': 'Itaú'},
      };
    });

    test('deve criar Transferencia com valores padrão', () {
      const t = Transferencia(condominioId: 'cond-001');
      expect(t.valor, 0);
      expect(t.recorrente, false);
      expect(t.tipo, 'MANUAL');
    });

    test('deve parsear JSON completo', () {
      final t = Transferencia.fromJson(fullJson);

      expect(t.id, 'transf-001');
      expect(t.contaDebitoId, 'conta-001');
      expect(t.contaCreditoId, 'conta-002');
      expect(t.valor, 5000.00);
      expect(t.dataTransferencia, DateTime(2026, 2, 20));
      expect(t.contaDebitoNome, 'Banco do Brasil');
      expect(t.contaCreditoNome, 'Itaú');
    });

    test('toJson com id deve incluí-lo', () {
      final json = Transferencia.fromJson(fullJson).toJson();
      expect(json['id'], 'transf-001');
      expect(json['conta_debito_id'], 'conta-001');
    });

    test('toJson sem id não deve incluí-lo', () {
      const t = Transferencia(condominioId: 'c1');
      expect(t.toJson().containsKey('id'), false);
    });

    test('toJson não deve incluir campos de join', () {
      final json = Transferencia.fromJson(fullJson).toJson();
      expect(json.containsKey('conta_debito'), false);
      expect(json.containsKey('conta_credito'), false);
    });

    test('copyWith deve manter dados originais', () {
      final original = Transferencia.fromJson(fullJson);
      final copy = original.copyWith(valor: 1000);

      expect(copy.valor, 1000);
      expect(copy.descricao, original.descricao);
    });

    test('Equatable: igualdade e desigualdade', () {
      final t1 = Transferencia.fromJson(fullJson);
      final t2 = Transferencia.fromJson(fullJson);
      final t3 = t1.copyWith(valor: 1);
      expect(t1, equals(t2));
      expect(t1, isNot(equals(t3)));
    });
  });

  // ════════════════════════════════════════════════════════
  //  CATEGORIA FINANCEIRA MODEL
  // ════════════════════════════════════════════════════════

  group('CategoriaFinanceira Model', () {
    test('deve parsear JSON com subcategorias', () {
      final json = {
        'id': 'cat-001',
        'nome': 'Manutenção',
        'tipo': 'DESPESA',
        'condominio_id': 'cond-001',
        'subcategorias_financeiras': [
          {'id': 'sub-001', 'nome': 'Elevadores', 'categoria_id': 'cat-001'},
          {'id': 'sub-002', 'nome': 'Piscina', 'categoria_id': 'cat-001'},
        ],
      };

      final cat = CategoriaFinanceira.fromJson(json);

      expect(cat.id, 'cat-001');
      expect(cat.nome, 'Manutenção');
      expect(cat.tipo, 'DESPESA');
      expect(cat.subcategorias, hasLength(2));
      expect(cat.subcategorias[0].nome, 'Elevadores');
      expect(cat.subcategorias[1].nome, 'Piscina');
    });

    test('deve tratar JSON sem subcategorias', () {
      final json = {
        'id': 'cat-002',
        'nome': 'Taxas',
        'tipo': 'RECEITA',
        'condominio_id': 'cond-001',
      };
      final cat = CategoriaFinanceira.fromJson(json);
      expect(cat.subcategorias, isEmpty);
    });
  });

  // ════════════════════════════════════════════════════════
  //  SUBCATEGORIA FINANCEIRA MODEL
  // ════════════════════════════════════════════════════════

  group('SubcategoriaFinanceira Model', () {
    test('deve parsear JSON corretamente', () {
      final json = {
        'id': 'sub-001',
        'nome': 'Elevadores',
        'categoria_id': 'cat-001',
      };

      final sub = SubcategoriaFinanceira.fromJson(json);
      expect(sub.id, 'sub-001');
      expect(sub.nome, 'Elevadores');
      expect(sub.categoriaId, 'cat-001');
    });
  });
}
