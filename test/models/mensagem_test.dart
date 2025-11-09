import 'package:flutter_test/flutter_test.dart';
import 'package:condogaiaapp/models/mensagem.dart';

void main() {
  group('Mensagem Model Tests', () {
    // Dados de teste comum
    final now = DateTime.now();
    final nowIso = now.toIso8601String();
    final agora2HorasAtras = now.subtract(Duration(hours: 2));

    final mensagemJson = {
      'id': 'msg-123',
      'conversa_id': 'conv-1',
      'condominio_id': 'condo-1',
      'remetente_tipo': 'usuario',
      'remetente_id': 'user-1',
      'remetente_nome': 'João Silva',
      'conteudo': 'Olá, preciso de ajuda com o vazamento de água no A/400',
      'tipo_conteudo': 'texto',
      'anexo_url': null,
      'anexo_tipo': null,
      'anexo_nome': null,
      'anexo_tamanho': null,
      'status': 'entregue',
      'lida': true,
      'data_leitura': agora2HorasAtras.toIso8601String(),
      'resposta_a_mensagem_id': null,
      'editada': false,
      'data_edicao': null,
      'conteudo_original': null,
      'prioridade': 'normal',
      'categoria': null,
      'created_at': nowIso,
      'updated_at': nowIso,
    };

    final mensagemRepresentanteJson = {
      'id': 'msg-124',
      'conversa_id': 'conv-1',
      'condominio_id': 'condo-1',
      'remetente_tipo': 'representante',
      'remetente_id': 'rep-1',
      'remetente_nome': 'Portaria',
      'conteudo': 'Entendo, vou enviar o encanador hoje',
      'tipo_conteudo': 'texto',
      'anexo_url': null,
      'anexo_tipo': null,
      'anexo_nome': null,
      'anexo_tamanho': null,
      'status': 'lida',
      'lida': true,
      'data_leitura': nowIso,
      'resposta_a_mensagem_id': 'msg-123',
      'editada': false,
      'data_edicao': null,
      'conteudo_original': null,
      'prioridade': 'normal',
      'categoria': null,
      'created_at': nowIso,
      'updated_at': nowIso,
    };

    final mensagemComAnexoJson = {
      'id': 'msg-125',
      'conversa_id': 'conv-1',
      'condominio_id': 'condo-1',
      'remetente_tipo': 'usuario',
      'remetente_id': 'user-1',
      'remetente_nome': 'João Silva',
      'conteudo': 'Veja as fotos do problema',
      'tipo_conteudo': 'imagem',
      'anexo_url':
          'https://bucket.supabase.co/storage/v1/object/public/uploads/img_001.jpg',
      'anexo_tipo': 'image/jpeg',
      'anexo_nome': 'foto_vazamento.jpg',
      'anexo_tamanho': 2048576,
      'status': 'entregue',
      'lida': false,
      'data_leitura': null,
      'resposta_a_mensagem_id': null,
      'editada': false,
      'data_edicao': null,
      'conteudo_original': null,
      'prioridade': 'normal',
      'categoria': null,
      'created_at': nowIso,
      'updated_at': nowIso,
    };

    // ============================================
    // TESTES DE CRIAÇÃO
    // ============================================

    test('Mensagem deve ser criada com construtor padrão', () {
      final msg = Mensagem(
        id: 'msg-1',
        conversaId: 'conv-1',
        condominioId: 'condo-1',
        remetenteTipo: 'usuario',
        remetenteId: 'user-1',
        remetenteNome: 'João',
        conteudo: 'Olá',
        tipoConteudo: 'texto',
        createdAt: now,
        updatedAt: now,
      );

      expect(msg.id, 'msg-1');
      expect(msg.remetenteNome, 'João');
      expect(msg.conteudo, 'Olá');
    });

    test('Mensagem deve ter valores padrão', () {
      final msg = Mensagem(
        id: 'msg-1',
        conversaId: 'conv-1',
        condominioId: 'condo-1',
        remetenteTipo: 'usuario',
        remetenteId: 'user-1',
        remetenteNome: 'João',
        conteudo: 'Olá',
        tipoConteudo: 'texto',
        createdAt: now,
        updatedAt: now,
      );

      expect(msg.tipoConteudo, 'texto');
      expect(msg.status, 'enviada');
      expect(msg.lida, false);
      expect(msg.anexoUrl, null);
      expect(msg.dataLeitura, null);
    });

    // ============================================
    // TESTES DE JSON
    // ============================================

    test('Mensagem deve ser criada a partir de JSON (fromJson)', () {
      final msg = Mensagem.fromJson(mensagemJson);

      expect(msg.id, 'msg-123');
      expect(msg.conversaId, 'conv-1');
      expect(msg.remetenteTipo, 'usuario');
      expect(msg.remetenteNome, 'João Silva');
      expect(msg.conteudo, contains('preciso de ajuda'));
      expect(msg.status, 'entregue');
    });

    test('Mensagem deve ser convertida para JSON (toJson)', () {
      final msg = Mensagem.fromJson(mensagemJson);
      final json = msg.toJson();

      expect(json['id'], 'msg-123');
      expect(json['remetente_nome'], 'João Silva');
      expect(json['status'], 'entregue');
    });

    test('JSON roundtrip deve preservar todos os dados', () {
      final original = Mensagem.fromJson(mensagemJson);
      final json = original.toJson();
      final restored = Mensagem.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.remetenteNome, original.remetenteNome);
      expect(restored.conteudo, original.conteudo);
      expect(restored.status, original.status);
    });

    test('fromJson deve lidar com campos opcionais nulos', () {
      final minimalJson = {
        'id': 'msg-1',
        'conversa_id': 'conv-1',
        'condominio_id': 'condo-1',
        'remetente_tipo': 'usuario',
        'remetente_id': 'user-1',
        'remetente_nome': 'João',
        'conteudo': 'Olá',
        'created_at': nowIso,
        'updated_at': nowIso,
      };

      final msg = Mensagem.fromJson(minimalJson);

      expect(msg.id, 'msg-1');
      expect(msg.conteudo, 'Olá');
      expect(msg.anexoUrl, null);
      expect(msg.dataLeitura, null);
      expect(msg.respostaAMensagemId, null);
      expect(msg.dataEdicao, null);
    });

    // ============================================
    // TESTES DE COPYWITH
    // ============================================

    test('copyWith deve modificar campos específicos', () {
      final original = Mensagem.fromJson(mensagemJson);
      final modified = original.copyWith(
        status: 'lida',
        conteudo: 'Olá modificado',
      );

      expect(modified.status, 'lida');
      expect(modified.conteudo, 'Olá modificado');
      expect(modified.remetenteNome, original.remetenteNome);
      expect(modified.id, original.id);
    });

    test('copyWith deve retornar nova instância (imutabilidade)', () {
      final original = Mensagem.fromJson(mensagemJson);
      final modified = original.copyWith(status: 'lida');

      expect(original.status, 'entregue');
      expect(modified.status, 'lida');
      expect(identical(original, modified), false);
    });

    test('copyWith com null deve usar valores originais', () {
      final original = Mensagem.fromJson(mensagemJson);
      final modified = original.copyWith();

      expect(modified.id, original.id);
      expect(modified.conteudo, original.conteudo);
      expect(modified.status, original.status);
    });

    // ============================================
    // TESTES DE GETTERS HELPERS
    // ============================================

    test('isRepresentante deve retornar true para remetente tipo representante',
        () {
      final msg = Mensagem.fromJson(mensagemRepresentanteJson);

      expect(msg.isRepresentante, true);
    });

    test('isRepresentante deve retornar false para remetente tipo usuario', () {
      final msg = Mensagem.fromJson(mensagemJson);

      expect(msg.isRepresentante, false);
    });

    test('isUsuario deve retornar true para remetente tipo usuario', () {
      final msg = Mensagem.fromJson(mensagemJson);

      expect(msg.isUsuario, true);
    });

    test('isUsuario deve retornar false para remetente tipo representante', () {
      final msg = Mensagem.fromJson(mensagemRepresentanteJson);

      expect(msg.isUsuario, false);
    });

    test('isTexto deve retornar true para tipo_conteudo texto', () {
      final msg = Mensagem.fromJson(mensagemJson);

      expect(msg.isTexto, true);
    });

    test('isTexto deve retornar false para tipo_conteudo imagem', () {
      final msg = Mensagem.fromJson(mensagemComAnexoJson);

      expect(msg.isTexto, false);
    });

    test('temAnexo deve retornar true se anexo_url não nulo', () {
      final msg = Mensagem.fromJson(mensagemComAnexoJson);

      expect(msg.temAnexo, true);
    });

    test('temAnexo deve retornar false se anexo_url nulo', () {
      final msg = Mensagem.fromJson(mensagemJson);

      expect(msg.temAnexo, false);
    });

    test('horaFormatada deve retornar formato HH:MM', () {
      final msg = Mensagem.fromJson(mensagemJson);
      final hora = msg.horaFormatada;

      expect(hora, matches(RegExp(r'^\d{2}:\d{2}$')));
    });

    test('dataHoraFormatada deve retornar formato DD/MM HHhMM', () {
      final msg = Mensagem.fromJson(mensagemJson);
      final dataHora = msg.dataHoraFormatada;

      expect(dataHora, matches(RegExp(r'^\d{2}/\d{2} \d{2}h\d{2}$')));
    });

    test('iconeStatus deve retornar ✓ para enviada', () {
      final json = Map<String, dynamic>.from(mensagemJson);
      json['status'] = 'enviada';
      final msg = Mensagem.fromJson(json);

      expect(msg.iconeStatus, '✓');
    });

    test('iconeStatus deve retornar ✓✓ para entregue', () {
      final msg = Mensagem.fromJson(mensagemJson);

      expect(msg.iconeStatus, '✓✓');
    });

    test('iconeStatus deve retornar ✓✓ azul para lida', () {
      final msg = Mensagem.fromJson(mensagemRepresentanteJson);

      expect(msg.iconeStatus, '✓✓');
    });

    test('iconeStatus deve retornar ⚠ para erro', () {
      final json = Map<String, dynamic>.from(mensagemJson);
      json['status'] = 'erro';
      final msg = Mensagem.fromJson(json);

      expect(msg.iconeStatus, '⚠');
    });

    test('corStatus deve retornar código hex válido', () {
      final msg = Mensagem.fromJson(mensagemJson);
      final cor = msg.corStatus;

      expect(cor, matches(RegExp(r'^#[0-9A-Fa-f]{6}$')));
    });

    test('corStatus deve retornar verde para entregue', () {
      final msg = Mensagem.fromJson(mensagemJson);

      expect(msg.corStatus, '#4CAF50');
    });

    test('corStatus deve retornar cinza para enviada', () {
      final json = Map<String, dynamic>.from(mensagemJson);
      json['status'] = 'enviada';
      final msg = Mensagem.fromJson(json);

      expect(msg.corStatus, '#9E9E9E');
    });

    test('corStatus deve retornar azul para lida', () {
      final msg = Mensagem.fromJson(mensagemRepresentanteJson);

      expect(msg.corStatus, '#2196F3');
    });

    test('corStatus deve retornar vermelho para erro', () {
      final json = Map<String, dynamic>.from(mensagemJson);
      json['status'] = 'erro';
      final msg = Mensagem.fromJson(json);

      expect(msg.corStatus, '#F44336');
    });

    // ============================================
    // TESTES DE IGUALDADE
    // ============================================

    test('Mensagens com mesmo ID devem ser iguais', () {
      final msg1 = Mensagem.fromJson(mensagemJson);
      final msg2 = Mensagem.fromJson(mensagemJson);

      expect(msg1, msg2);
    });

    test('Mensagens com IDs diferentes devem ser diferentes', () {
      final json1 = Map<String, dynamic>.from(mensagemJson);
      final json2 = Map<String, dynamic>.from(mensagemJson);
      json2['id'] = 'msg-999';

      final msg1 = Mensagem.fromJson(json1);
      final msg2 = Mensagem.fromJson(json2);

      expect(msg1, isNot(msg2));
    });

    test('hashCode deve ser igual para mensagens iguais', () {
      final msg1 = Mensagem.fromJson(mensagemJson);
      final msg2 = Mensagem.fromJson(mensagemJson);

      expect(msg1.hashCode, msg2.hashCode);
    });

    test('hashCode deve ser diferente para mensagens diferentes', () {
      final json1 = Map<String, dynamic>.from(mensagemJson);
      final json2 = Map<String, dynamic>.from(mensagemJson);
      json2['id'] = 'msg-999';

      final msg1 = Mensagem.fromJson(json1);
      final msg2 = Mensagem.fromJson(json2);

      expect(msg1.hashCode, isNot(msg2.hashCode));
    });

    test('Mensagem deve funcionar em Set (usando hashCode e ==)', () {
      final msg1 = Mensagem.fromJson(mensagemJson);
      final msg2 = Mensagem.fromJson(mensagemJson);
      final json3 = Map<String, dynamic>.from(mensagemJson);
      json3['id'] = 'msg-999';
      final msg3 = Mensagem.fromJson(json3);

      final set = {msg1, msg2, msg3};

      expect(set.length, 2);
    });

    // ============================================
    // TESTES DE VALIDAÇÃO DE DADOS
    // ============================================

    test('Mensagem deve aceitar tipos de remetente válidos', () {
      final tipos = ['usuario', 'representante'];

      for (final tipo in tipos) {
        final json = Map<String, dynamic>.from(mensagemJson);
        json['remetente_tipo'] = tipo;

        final msg = Mensagem.fromJson(json);
        expect(msg.remetenteTipo, tipo);
      }
    });

    test('Mensagem deve aceitar tipos de conteúdo válidos', () {
      final tipos = ['texto', 'imagem', 'arquivo', 'audio'];

      for (final tipo in tipos) {
        final json = Map<String, dynamic>.from(mensagemJson);
        json['tipo_conteudo'] = tipo;

        final msg = Mensagem.fromJson(json);
        expect(msg.tipoConteudo, tipo);
      }
    });

    test('Mensagem deve aceitar status válidos', () {
      final status = ['enviada', 'entregue', 'lida', 'erro'];

      for (final s in status) {
        final json = Map<String, dynamic>.from(mensagemJson);
        json['status'] = s;

        final msg = Mensagem.fromJson(json);
        expect(msg.status, s);
      }
    });

    test('Mensagem com conteúdo vazio deve ser válida', () {
      final json = Map<String, dynamic>.from(mensagemJson);
      json['conteudo'] = '';

      final msg = Mensagem.fromJson(json);
      expect(msg.conteudo, '');
    });

    // ============================================
    // TESTES DE ANEXOS
    // ============================================

    test('Mensagem com anexo deve conter todas as informações', () {
      final msg = Mensagem.fromJson(mensagemComAnexoJson);

      expect(msg.temAnexo, true);
      expect(msg.anexoUrl, isNotNull);
      expect(msg.anexoTipo, 'image/jpeg');
      expect(msg.anexoNome, 'foto_vazamento.jpg');
    });

    test('Mensagem sem anexo deve ter anexoUrl nulo', () {
      final msg = Mensagem.fromJson(mensagemJson);

      expect(msg.temAnexo, false);
      expect(msg.anexoUrl, null);
      expect(msg.anexoTipo, null);
      expect(msg.anexoNome, null);
    });

    // ============================================
    // TESTES DE RESPOSTAS
    // ============================================

    test('Mensagem com resposta deve conter informações da mensagem original',
        () {
      final msg = Mensagem.fromJson(mensagemRepresentanteJson);

      expect(msg.respostaAMensagemId, 'msg-123');
    });

    test('Mensagem sem resposta deve ter respostaAMensagemId nulo', () {
      final msg = Mensagem.fromJson(mensagemJson);

      expect(msg.respostaAMensagemId, null);
    });

    // ============================================
    // TESTES DE LEITURA
    // ============================================

    test('Mensagem com dataLeitura deve estar marcada como lida', () {
      final msg = Mensagem.fromJson(mensagemJson);

      expect(msg.lida, true);
      expect(msg.dataLeitura, isNotNull);
    });

    test('Mensagem sem dataLeitura deve estar não lida', () {
      final msg = Mensagem.fromJson(mensagemComAnexoJson);

      expect(msg.lida, false);
      expect(msg.dataLeitura, null);
    });

    // ============================================
    // TESTES DE EDIÇÃO
    // ============================================

    test('Mensagem sem edição deve ter dataEdicao nula', () {
      final msg = Mensagem.fromJson(mensagemJson);

      expect(msg.editada, false);
      expect(msg.dataEdicao, null);
    });

    test('Mensagem editada deve ter dataEdicao', () {
      final json = Map<String, dynamic>.from(mensagemJson);
      json['editada'] = true;
      json['data_edicao'] = now.toIso8601String();

      final msg = Mensagem.fromJson(json);
      expect(msg.editada, true);
      expect(msg.dataEdicao, isNotNull);
    });

    // ============================================
    // TESTES DE TOSTRING
    // ============================================

    test('toString deve incluir informações úteis', () {
      final msg = Mensagem.fromJson(mensagemJson);
      final str = msg.toString();

      expect(str, contains('Mensagem'));
      expect(str, contains('msg-123'));
      expect(str, contains('João Silva'));
      expect(str, contains('entregue'));
    });

    // ============================================
    // TESTES DE TIMESTAMPS
    // ============================================

    test('Mensagem deve ter timestamps válidos', () {
      final msg = Mensagem.fromJson(mensagemJson);

      expect(msg.createdAt, isNotNull);
      expect(msg.updatedAt, isNotNull);
      expect(msg.createdAt.isBefore(msg.updatedAt) ||
          msg.createdAt.isAtSameMomentAs(msg.updatedAt), true);
    });

    // ============================================
    // TESTES DE PRIORIDADE
    // ============================================

    test('Mensagem deve aceitar prioridades válidas', () {
      final prioridades = ['baixa', 'normal', 'alta', 'urgente'];

      for (final p in prioridades) {
        final json = Map<String, dynamic>.from(mensagemJson);
        json['prioridade'] = p;

        final msg = Mensagem.fromJson(json);
        expect(msg.prioridade, p);
      }
    });
  });
}
