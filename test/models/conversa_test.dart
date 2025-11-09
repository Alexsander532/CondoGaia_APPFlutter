import 'package:flutter_test/flutter_test.dart';
import 'package:condogaiaapp/models/conversa.dart';

void main() {
  group('Conversa Model Tests', () {
    // Dados de teste comum
    final now = DateTime.now();
    final nowIso = now.toIso8601String();

    final conversaJson = {
      'id': 'conv-123',
      'condominio_id': 'condo-1',
      'unidade_id': 'unit-1',
      'usuario_tipo': 'proprietario',
      'usuario_id': 'user-1',
      'usuario_nome': 'João Moreira',
      'unidade_numero': 'A/400',
      'representante_id': 'rep-1',
      'representante_nome': 'Portaria',
      'assunto': 'Problema com água',
      'status': 'ativa',
      'total_mensagens': 5,
      'mensagens_nao_lidas_usuario': 2,
      'mensagens_nao_lidas_representante': 1,
      'ultima_mensagem_data': nowIso,
      'ultima_mensagem_por': 'usuario',
      'ultima_mensagem_preview': 'Olá, preciso de ajuda',
      'notificacoes_ativas': true,
      'prioridade': 'normal',
      'created_at': nowIso,
      'updated_at': nowIso,
    };

    // ============================================
    // TESTES DE CRIAÇÃO
    // ============================================
    
    test('Conversa deve ser criada com construtor padrão', () {
      final conversa = Conversa(
        id: 'conv-1',
        condominioId: 'condo-1',
        unidadeId: 'unit-1',
        usuarioTipo: 'proprietario',
        usuarioId: 'user-1',
        usuarioNome: 'João',
        status: 'ativa',
        totalMensagens: 0,
        mensagensNaoLidasUsuario: 0,
        mensagensNaoLidasRepresentante: 0,
        createdAt: now,
        updatedAt: now,
      );

      expect(conversa.id, 'conv-1');
      expect(conversa.usuarioNome, 'João');
      expect(conversa.status, 'ativa');
    });

    test('Conversa deve ser criada com valores padrão', () {
      final conversa = Conversa(
        id: 'conv-1',
        condominioId: 'condo-1',
        unidadeId: 'unit-1',
        usuarioTipo: 'proprietario',
        usuarioId: 'user-1',
        usuarioNome: 'João',
        status: 'ativa',
        totalMensagens: 0,
        mensagensNaoLidasUsuario: 0,
        mensagensNaoLidasRepresentante: 0,
        createdAt: now,
        updatedAt: now,
      );

      expect(conversa.notificacoesAtivas, true);
      expect(conversa.prioridade, 'normal');
      expect(conversa.assunto, null);
    });

    // ============================================
    // TESTES DE JSON
    // ============================================

    test('Conversa deve ser criada a partir de JSON (fromJson)', () {
      final conversa = Conversa.fromJson(conversaJson);

      expect(conversa.id, 'conv-123');
      expect(conversa.usuarioNome, 'João Moreira');
      expect(conversa.unidadeNumero, 'A/400');
      expect(conversa.status, 'ativa');
      expect(conversa.totalMensagens, 5);
      expect(conversa.mensagensNaoLidasUsuario, 2);
      expect(conversa.mensagensNaoLidasRepresentante, 1);
    });

    test('Conversa deve ser convertida para JSON (toJson)', () {
      final conversa = Conversa.fromJson(conversaJson);
      final json = conversa.toJson();

      expect(json['id'], 'conv-123');
      expect(json['usuario_nome'], 'João Moreira');
      expect(json['status'], 'ativa');
      expect(json['total_mensagens'], 5);
    });

    test('JSON roundtrip deve preservar todos os dados', () {
      final original = Conversa.fromJson(conversaJson);
      final json = original.toJson();
      final restored = Conversa.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.usuarioNome, original.usuarioNome);
      expect(restored.status, original.status);
      expect(restored.totalMensagens, original.totalMensagens);
      expect(restored.mensagensNaoLidasUsuario,
          original.mensagensNaoLidasUsuario);
    });

    test('fromJson deve lidar com campos opcionais nulos', () {
      final minimalJson = {
        'id': 'conv-1',
        'condominio_id': 'condo-1',
        'unidade_id': 'unit-1',
        'usuario_tipo': 'proprietario',
        'usuario_id': 'user-1',
        'usuario_nome': 'João',
        'created_at': nowIso,
        'updated_at': nowIso,
      };

      final conversa = Conversa.fromJson(minimalJson);

      expect(conversa.id, 'conv-1');
      expect(conversa.usuarioNome, 'João');
      expect(conversa.unidadeNumero, null);
      expect(conversa.representanteId, null);
      expect(conversa.assunto, null);
      expect(conversa.ultimaMensagemData, null);
    });

    // ============================================
    // TESTES DE COPYWITH
    // ============================================

    test('copyWith deve modificar campos específicos', () {
      final original = Conversa.fromJson(conversaJson);
      final modified = original.copyWith(
        status: 'arquivada',
        totalMensagens: 10,
      );

      expect(modified.status, 'arquivada');
      expect(modified.totalMensagens, 10);
      expect(modified.usuarioNome, original.usuarioNome); // não foi modificado
      expect(modified.id, original.id); // não foi modificado
    });

    test('copyWith deve retornar nova instância (imutabilidade)', () {
      final original = Conversa.fromJson(conversaJson);
      final modified = original.copyWith(status: 'bloqueada');

      expect(original.status, 'ativa'); // original não muda
      expect(modified.status, 'bloqueada');
      expect(identical(original, modified), false); // são objetos diferentes
    });

    test('copyWith com null deve usar valores originais', () {
      final original = Conversa.fromJson(conversaJson);
      final modified = original.copyWith();

      expect(modified.id, original.id);
      expect(modified.status, original.status);
      expect(modified.totalMensagens, original.totalMensagens);
    });

    // ============================================
    // TESTES DE GETTERS HELPERS
    // ============================================

    test('temMensagensNaoLidasParaUsuario deve retornar true se > 0', () {
      final conversa = Conversa.fromJson(conversaJson);

      expect(conversa.temMensagensNaoLidasParaUsuario, true);

      final semNaoLidas = conversa.copyWith(mensagensNaoLidasUsuario: 0);
      expect(semNaoLidas.temMensagensNaoLidasParaUsuario, false);
    });

    test(
        'temMensagensNaoLidasParaRepresentante deve retornar true se > 0', () {
      final conversa = Conversa.fromJson(conversaJson);

      expect(conversa.temMensagensNaoLidasParaRepresentante, true);

      final semNaoLidas =
          conversa.copyWith(mensagensNaoLidasRepresentante: 0);
      expect(semNaoLidas.temMensagensNaoLidasParaRepresentante, false);
    });

    test('nomeParaBadge deve retornar nome formatado', () {
      final conversa = Conversa.fromJson(conversaJson);

      expect(conversa.nomeParaBadge, 'Chat com João Moreira');
    });

    test('subtituloPadrao deve retornar preview se disponível', () {
      final conversa = Conversa.fromJson(conversaJson);

      expect(conversa.subtituloPadrao, 'Olá, preciso de ajuda');
    });

    test(
        'subtituloPadrao deve truncar preview longo (> 50 caracteres)',
        () {
      final previewLongo =
          'Lorem ipsum dolor sit amet consectetur adipiscing elit sed do eiusmod tempor incididunt';
      final json = Map<String, dynamic>.from(conversaJson);
      json['ultima_mensagem_preview'] = previewLongo;

      final conversa = Conversa.fromJson(json);

      expect(conversa.subtituloPadrao.length, 53); // 50 + "..."
      expect(conversa.subtituloPadrao.endsWith('...'), true);
    });

    test('subtituloPadrao deve retornar padrão se preview null', () {
      final json = Map<String, dynamic>.from(conversaJson);
      json['ultima_mensagem_preview'] = null;

      final conversa = Conversa.fromJson(json);

      expect(conversa.subtituloPadrao, 'Nenhuma mensagem ainda');
    });

    test('ultimaMensagemDataFormatada deve retornar "Agora" para minutos recentes',
        () {
      final recente = now.subtract(Duration(minutes: 2));
      final json = Map<String, dynamic>.from(conversaJson);
      json['ultima_mensagem_data'] = recente.toIso8601String();

      final conversa = Conversa.fromJson(json);

      
    });

    test('ultimaMensagemDataFormatada deve retornar formato de horas', () {
      final horas3Atras = now.subtract(Duration(hours: 3));
      final json = Map<String, dynamic>.from(conversaJson);
      json['ultima_mensagem_data'] = horas3Atras.toIso8601String();

      final conversa = Conversa.fromJson(json);

      expect(conversa.ultimaMensagemDataFormatada, contains('h'));
    });

    test('ultimaMensagemDataFormatada deve retornar vazio se null', () {
      final json = Map<String, dynamic>.from(conversaJson);
      json['ultima_mensagem_data'] = null;

      final conversa = Conversa.fromJson(json);

      expect(conversa.ultimaMensagemDataFormatada, '');
    });

    // ============================================
    // TESTES DE IGUALDADE
    // ============================================

    test('Conversas com mesmo ID devem ser iguais', () {
      final conversa1 = Conversa.fromJson(conversaJson);
      final conversa2 = Conversa.fromJson(conversaJson);

      expect(conversa1, conversa2);
    });

    test('Conversas com IDs diferentes devem ser diferentes', () {
      final json1 = Map<String, dynamic>.from(conversaJson);
      final json2 = Map<String, dynamic>.from(conversaJson);
      json2['id'] = 'conv-999';

      final conversa1 = Conversa.fromJson(json1);
      final conversa2 = Conversa.fromJson(json2);

      expect(conversa1, isNot(conversa2));
    });

    test('hashCode deve ser igual para conversas iguais', () {
      final conversa1 = Conversa.fromJson(conversaJson);
      final conversa2 = Conversa.fromJson(conversaJson);

      expect(conversa1.hashCode, conversa2.hashCode);
    });

    test('hashCode deve ser diferente para conversas diferentes', () {
      final json1 = Map<String, dynamic>.from(conversaJson);
      final json2 = Map<String, dynamic>.from(conversaJson);
      json2['id'] = 'conv-999';

      final conversa1 = Conversa.fromJson(json1);
      final conversa2 = Conversa.fromJson(json2);

      expect(conversa1.hashCode, isNot(conversa2.hashCode));
    });

    test('Conversa deve funcionar em Set (usando hashCode e ==)', () {
      final conversa1 = Conversa.fromJson(conversaJson);
      final conversa2 = Conversa.fromJson(conversaJson);
      final json3 = Map<String, dynamic>.from(conversaJson);
      json3['id'] = 'conv-999';
      final conversa3 = Conversa.fromJson(json3);

      final set = {conversa1, conversa2, conversa3};

      expect(set.length, 2); // conversa1 e conversa2 são iguais
    });

    // ============================================
    // TESTES DE VALIDAÇÃO DE DADOS
    // ============================================

    test('Conversa deve aceitar todos os status válidos', () {
      final status = ['ativa', 'arquivada', 'bloqueada'];

      for (final s in status) {
        final json = Map<String, dynamic>.from(conversaJson);
        json['status'] = s;

        final conversa = Conversa.fromJson(json);
        expect(conversa.status, s);
      }
    });

    test('Conversa deve aceitar tipos de usuário válidos', () {
      final tipos = ['proprietario', 'inquilino'];

      for (final tipo in tipos) {
        final json = Map<String, dynamic>.from(conversaJson);
        json['usuario_tipo'] = tipo;

        final conversa = Conversa.fromJson(json);
        expect(conversa.usuarioTipo, tipo);
      }
    });

    test('Conversa deve aceitar prioridades válidas', () {
      final prioridades = ['baixa', 'normal', 'alta', 'urgente'];

      for (final p in prioridades) {
        final json = Map<String, dynamic>.from(conversaJson);
        json['prioridade'] = p;

        final conversa = Conversa.fromJson(json);
        expect(conversa.prioridade, p);
      }
    });

    test('Conversa deve ter contadores >= 0', () {
      final conversa = Conversa.fromJson(conversaJson);

      expect(conversa.totalMensagens, greaterThanOrEqualTo(0));
      expect(conversa.mensagensNaoLidasUsuario, greaterThanOrEqualTo(0));
      expect(conversa.mensagensNaoLidasRepresentante, greaterThanOrEqualTo(0));
    });

    // ============================================
    // TESTES DE TOSTRING
    // ============================================

    test('toString deve incluir informações úteis', () {
      final conversa = Conversa.fromJson(conversaJson);
      final str = conversa.toString();

      expect(str, contains('Conversa'));
      expect(str, contains('conv-123'));
      expect(str, contains('João Moreira'));
      expect(str, contains('ativa'));
    });

    // ============================================
    // TESTES DE EDGE CASES
    // ============================================

    test('Conversa com usuarioNome vazio deve ser válida', () {
      final json = Map<String, dynamic>.from(conversaJson);
      json['usuario_nome'] = '';

      final conversa = Conversa.fromJson(json);
      expect(conversa.usuarioNome, '');
    });

    test('Conversa com preview vazio deve retornar "Nenhuma mensagem"', () {
      final json = Map<String, dynamic>.from(conversaJson);
      json['ultima_mensagem_preview'] = '';

      final conversa = Conversa.fromJson(json);
      expect(conversa.subtituloPadrao, 'Nenhuma mensagem ainda');
    });

    test('Conversa sem timestamps deve usar valor padrão', () {
      final json = Map<String, dynamic>.from(conversaJson);
      final now = DateTime.now();

      final conversa = Conversa.fromJson(json);

      expect(conversa.createdAt, isNotNull);
      expect(conversa.updatedAt, isNotNull);
    });
  });
}
