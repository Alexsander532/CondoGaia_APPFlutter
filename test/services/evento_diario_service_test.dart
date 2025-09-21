import 'package:flutter_test/flutter_test.dart';
import 'package:condogaiaapp/models/evento_diario.dart';
import 'package:condogaiaapp/services/evento_diario_service.dart';

void main() {
  group('EventoDiario Model Tests', () {
    test('deve criar EventoDiario com dados válidos', () {
      final evento = EventoDiario(
        id: '1',
        representanteId: 'rep123',
        condominioId: 'cond456',
        titulo: 'Reunião de Condomínio',
        descricao: 'Discussão sobre melhorias',
        dataEvento: DateTime(2024, 1, 15),
        status: 'ativo',
        criadoEm: DateTime.now(),
        atualizadoEm: DateTime.now(),
      );

      expect(evento.id, '1');
      expect(evento.titulo, 'Reunião de Condomínio');
      expect(evento.status, 'ativo');
      expect(evento.isAtivo, true);
    });

    test('deve validar status corretamente', () {
      final evento = EventoDiario(
        id: '1',
        representanteId: 'rep123',
        condominioId: 'cond456',
        titulo: 'Teste',
        dataEvento: DateTime.now(),
        status: 'ativo',
        criadoEm: DateTime.now(),
        atualizadoEm: DateTime.now(),
      );

      expect(evento.isAtivo, true);
      expect(evento.isCancelado, false);
      expect(evento.isConcluido, false);
    });

    test('deve converter para JSON corretamente', () {
      final evento = EventoDiario(
        id: '1',
        representanteId: 'rep123',
        condominioId: 'cond456',
        titulo: 'Teste JSON',
        descricao: 'Teste de conversão',
        dataEvento: DateTime(2024, 1, 15),
        status: 'ativo',
        criadoEm: DateTime(2024, 1, 15, 10, 0),
        atualizadoEm: DateTime(2024, 1, 15, 10, 0),
      );

      final json = evento.toJson();

      expect(json['id'], '1');
      expect(json['titulo'], 'Teste JSON');
      expect(json['data_evento'], '2024-01-15');
      expect(json['status'], 'ativo');
    });

    test('deve criar EventoDiario a partir de JSON', () {
      final json = {
        'id': '1',
        'representante_id': 'rep123',
        'condominio_id': 'cond456',
        'titulo': 'Teste FromJSON',
        'descricao': 'Teste de criação',
        'data_evento': '2024-01-15',
        'status': 'ativo',
        'criado_em': '2024-01-15T10:00:00Z',
        'atualizado_em': '2024-01-15T10:00:00Z',
      };

      final evento = EventoDiario.fromJson(json);

      expect(evento.id, '1');
      expect(evento.titulo, 'Teste FromJSON');
      expect(evento.dataEvento, DateTime(2024, 1, 15));
      expect(evento.status, 'ativo');
    });

    test('deve criar dados para inserção corretamente', () {
      final evento = EventoDiario(
        id: '1',
        representanteId: 'rep123',
        condominioId: 'cond456',
        titulo: 'Teste Insert',
        descricao: 'Teste de inserção',
        dataEvento: DateTime(2024, 1, 15),
        status: 'ativo',
        criadoEm: DateTime.now(),
        atualizadoEm: DateTime.now(),
      );

      final insertData = evento.toInsert();

      expect(insertData['representante_id'], 'rep123');
      expect(insertData['titulo'], 'Teste Insert');
      expect(insertData['data_evento'], '2024-01-15');
      expect(insertData.containsKey('id'), false); // ID não deve estar presente
    });

    test('deve formatar data corretamente', () {
      final evento = EventoDiario(
        id: '1',
        representanteId: 'rep123',
        condominioId: 'cond456',
        titulo: 'Teste Data',
        dataEvento: DateTime(2024, 1, 15),
        status: 'ativo',
        criadoEm: DateTime.now(),
        atualizadoEm: DateTime.now(),
      );

      expect(evento.dataEventoFormatada, '15/01/2024');
    });

    test('deve criar cópia com alterações', () {
      final evento = EventoDiario(
        id: '1',
        representanteId: 'rep123',
        condominioId: 'cond456',
        titulo: 'Título Original',
        dataEvento: DateTime(2024, 1, 15),
        status: 'ativo',
        criadoEm: DateTime.now(),
        atualizadoEm: DateTime.now(),
      );

      final eventoCopia = evento.copyWith(
        titulo: 'Título Alterado',
        status: 'concluido',
      );

      expect(eventoCopia.titulo, 'Título Alterado');
      expect(eventoCopia.status, 'concluido');
      expect(eventoCopia.id, '1'); // Campos não alterados permanecem
      expect(eventoCopia.representanteId, 'rep123');
    });
  });

  group('EventoDiario Validation Tests', () {
    test('deve validar status válidos', () {
      expect(EventoDiario.isStatusValido('ativo'), true);
      expect(EventoDiario.isStatusValido('concluido'), true);
      expect(EventoDiario.isStatusValido('cancelado'), true);
      expect(EventoDiario.isStatusValido('inativo'), true);
      expect(EventoDiario.isStatusValido('invalido'), false);
    });

    test('deve retornar lista de status válidos', () {
      final statusValidos = EventoDiario.statusValidos;
      
      expect(statusValidos.contains('ativo'), true);
      expect(statusValidos.contains('concluido'), true);
      expect(statusValidos.contains('cancelado'), true);
      expect(statusValidos.contains('inativo'), true);
      expect(statusValidos.length, 4);
    });
  });
}