import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:condogaiaapp/features/Representante_Features/leitura/services/leitura_service.dart';
import 'package:condogaiaapp/features/Representante_Features/leitura/services/cache_service.dart';
import 'package:condogaiaapp/features/Representante_Features/leitura/models/leitura_configuracao_model.dart';
import 'package:condogaiaapp/models/unidade.dart';

// Mocks
class MockCacheService extends Mock implements CacheService {}

class MockSupabaseClient extends Mock implements SupabaseClient {}

class FakeTransformSingle extends Fake
    implements PostgrestTransformBuilder<Map<String, dynamic>?> {
  final dynamic _data;
  FakeTransformSingle(this._data);

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #then) {
      final onValue = invocation.positionalArguments[0];
      final onError = invocation.namedArguments[#onError];
      return Future<Map<String, dynamic>?>.value(
        _data,
      ).then(onValue, onError: onError);
    }
    return this;
  }
}

class FakeFilterList extends Fake
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {
  final dynamic _data;
  FakeFilterList(this._data);

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #maybeSingle) {
      return FakeTransformSingle(_data is List ? _data.firstOrNull : _data);
    }
    if (invocation.memberName == #then) {
      final onValue = invocation.positionalArguments[0];
      final onError = invocation.namedArguments[#onError];
      return Future<List<Map<String, dynamic>>>.value(
        _data,
      ).then(onValue, onError: onError);
    }
    return this;
  }
}

class FakeQueryBuilder extends Fake implements SupabaseQueryBuilder {
  final dynamic _data;
  FakeQueryBuilder(this._data);

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #select) {
      return FakeFilterList(_data);
    }
    if (invocation.memberName == #insert ||
        invocation.memberName == #update ||
        invocation.memberName == #upsert) {
      return FakeFilterList([]);
    }
    return this;
  }
}

void main() {
  late MockSupabaseClient mockSupabase;
  late MockCacheService mockCache;
  late LeituraService service;

  setUpAll(() {
    registerFallbackValue(
      LeituraConfiguracaoModel(condominioId: '1', tipo: '1'),
    );
  });

  setUp(() {
    mockSupabase = MockSupabaseClient();
    mockCache = MockCacheService();

    when(() => mockCache.init()).thenAnswer((_) async {});

    service = LeituraService(supabase: mockSupabase, cache: mockCache);
  });

  group('LeituraService Tests', () {
    test('fetchConfiguracao: deve retornar do cache se existir', () async {
      final tConfig = LeituraConfiguracaoModel(
        condominioId: 'cond-1',
        tipo: 'Agua',
        valorBase: 10,
      );

      when(
        () => mockCache.getCachedData<LeituraConfiguracaoModel>(any(), any()),
      ).thenAnswer((_) async => tConfig);

      final result = await service.fetchConfiguracao(
        condominioId: 'cond-1',
        tipo: 'Agua',
      );

      expect(result, isNotNull);
      expect(result?.valorBase, 10);
      verify(
        () => mockCache.getCachedData<LeituraConfiguracaoModel>(any(), any()),
      ).called(1);
      verifyNever(() => mockSupabase.from(any()));
    });

    test(
      'fetchConfiguracao: deve buscar do Supabase se cache for nulo',
      () async {
        when(
          () => mockCache.getCachedData<LeituraConfiguracaoModel>(any(), any()),
        ).thenAnswer((_) async => null);

        when(
          () => mockCache.cacheData<LeituraConfiguracaoModel>(
            any(),
            any(),
            any(),
          ),
        ).thenAnswer((_) async {});

        final fakeData = {
          'condominio_id': 'cond-1',
          'tipo': 'Agua',
          'valor_base': 12.0,
        };

        when(
          () => mockSupabase.from('leitura_configuracoes'),
        ).thenAnswer((_) => FakeQueryBuilder([fakeData]));

        final result = await service.fetchConfiguracao(
          condominioId: 'cond-1',
          tipo: 'Agua',
        );

        expect(result, isNotNull);
        expect(result?.valorBase, 12.0);
        verify(
          () => mockCache.cacheData<LeituraConfiguracaoModel>(
            any(),
            any(),
            any(),
          ),
        ).called(1);
      },
    );

    test('fetchLeituras: deve buscar leituras do Supabase', () async {
      final fakeData = [
        {
          'id': '1',
          'unidade_id': 'uni-1',
          'condominio_id': 'cond-1',
          'tipo': 'Agua',
          'leitura_anterior': 100.0,
          'leitura_atual': 110.0,
          'valor': 100.0,
          'data_leitura': '2026-02-05',
        },
      ];

      when(
        () => mockSupabase.from('leituras'),
      ).thenAnswer((_) => FakeQueryBuilder(fakeData));

      final result = await service.fetchLeituras(
        condominioId: 'cond-1',
        tipo: 'Agua',
        month: 2,
        year: 2026,
      );

      expect(result.isNotEmpty, true);
      expect(result.first.leituraAtual, 110.0);
    });

    test('fetchUnidades: deve retornar do cache se existir', () async {
      final tUnidade = Unidade(
        id: 'uni-1',
        condominioId: 'cond-1',
        bloco: 'A',
        numero: '101',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(
        () => mockCache.getCachedList<Unidade>(any(), any(), any()),
      ).thenAnswer((_) async => [tUnidade]);

      final result = await service.fetchUnidades('cond-1');

      expect(result.isNotEmpty, true);
      expect(result.first.numero, '101');
      verifyNever(() => mockSupabase.from('unidades'));
    });

    test(
      'fetchUnidades: deve buscar do Supabase e fazer cache se não existir',
      () async {
        when(
          () => mockCache.getCachedList<Unidade>(any(), any(), any()),
        ).thenAnswer((_) async => null);
        when(
          () => mockCache.cacheList<Unidade>(any(), any(), any(), any()),
        ).thenAnswer((_) async {});

        final fakeData = [
          {
            'id': 'uni-2',
            'condominio_id': 'cond-1',
            'bloco': 'B',
            'numero': '102',
          },
        ];

        when(
          () => mockSupabase.from('unidades'),
        ).thenAnswer((_) => FakeQueryBuilder(fakeData));

        final result = await service.fetchUnidades('cond-1');

        expect(result.isNotEmpty, true);
        expect(result.first.numero, '102');
        verify(() => mockSupabase.from('unidades')).called(1);
        verify(
          () => mockCache.cacheList<Unidade>(any(), any(), any(), any()),
        ).called(1);
      },
    );
  });
}
