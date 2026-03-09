import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import '../models/recipient_model.dart';
import '../../../../models/proprietario.dart';
import '../../../../models/inquilino.dart';
import '../../../../models/unidade.dart';
import '../../../../services/laravel_api_service.dart';

class EmailGestaoService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final LaravelApiService _apiService = LaravelApiService();

  Future<List<RecipientModel>> fetchRecipients({
    required String condominioId,
  }) async {
    try {
      // 1. Fetch Units
      final unidadesResponse = await _supabase
          .from('unidades')
          .select()
          .eq('condominio_id', condominioId)
          .eq('ativo', true);

      final units = (unidadesResponse as List)
          .map((e) => Unidade.fromJson(e))
          .toList();

      final Map<String, Unidade> unidadeMap = {for (var u in units) u.id: u};

      // 2. Fetch Owners
      final ownersResponse = await _supabase
          .from('proprietarios')
          .select()
          .eq('condominio_id', condominioId);

      final owners = (ownersResponse as List)
          .map((e) => Proprietario.fromJson(e))
          .toList();

      // 3. Fetch Tenants
      final tenantsResponse = await _supabase
          .from('inquilinos')
          .select()
          .eq('condominio_id', condominioId);

      final tenants = (tenantsResponse as List)
          .map((e) => Inquilino.fromJson(e))
          .toList();

      List<RecipientModel> recipients = [];

      // Map Owners
      for (var owner in owners) {
        String unitInfo = '';
        String? blockName;
        String? unitNum;

        if (owner.unidadeId != null) {
          final unit = unidadeMap[owner.unidadeId];
          if (unit != null) {
            unitInfo = '${unit.numero} / ${unit.bloco ?? ''}';
            blockName = unit.bloco;
            unitNum = unit.numero;
          }
        }

        recipients.add(
          RecipientModel(
            id: owner.id,
            name: owner.nome,
            email: owner.email ?? '',
            type: 'P',
            unitBlock: unitInfo,
            block: blockName,
            unit: unitNum,
          ),
        );
      }

      // Map Tenants
      for (var tenant in tenants) {
        String unitInfo = '';
        String? blockName;
        String? unitNum;

        if (tenant.unidadeId.isNotEmpty) {
          final unit = unidadeMap[tenant.unidadeId];
          if (unit != null) {
            unitInfo = '${unit.numero} / ${unit.bloco ?? ''}';
            blockName = unit.bloco;
            unitNum = unit.numero;
          }
        }

        recipients.add(
          RecipientModel(
            id: tenant.id,
            name: tenant.nome,
            email: tenant.email ?? '',
            type: 'I',
            unitBlock: unitInfo,
            block: blockName,
            unit: unitNum,
          ),
        );
      }

      // Sort by Name
      recipients.sort((a, b) => a.name.compareTo(b.name));

      return recipients;
    } catch (e) {
      throw Exception('Erro ao buscar destinatários: $e');
    }
  }

  /// Sends a Circular to multiple recipients (single email with multiple BCCs or similar via Laravel)
  Future<void> enviarCircular({
    required String subject,
    required String body,
    required String topic,
    required List<RecipientModel> recipients,
    required String condominioNome,
    File?
    attachment, // Backend does not support attachment yet, skipped for now
  }) async {
    final payload = {
      'subject': subject,
      'body': body,
      'topic': topic,
      'condominioNome': condominioNome,
      'recipients': recipients
          .map((r) => {'email': r.email, 'name': r.name, 'type': r.type})
          .toList(),
    };

    final response = await _apiService.post('/resend/gestao/circular', payload);

    if (response.statusCode != 200) {
      throw Exception(
        'Falha ao enviar circular: ${response.statusCode} - ${response.body}',
      );
    }
  }

  /// Backward compatible generic send logic (defaults to Circular if topic provided, otherwise Aviso)
  Future<void> sendEmail({
    required String subject,
    required String body,
    required String topic,
    required List<RecipientModel> recipients,
    File? attachment,
  }) async {
    // Determine which endpoint to call based on the original intent
    if (topic.isNotEmpty) {
      await enviarCircular(
        subject: subject,
        body: body,
        topic: topic,
        recipients: recipients,
        condominioNome: 'CondoGaia', // Hardcoded for now, ideal if passed
      );
    } else {
      await enviarAviso(
        subject: subject,
        body: body,
        recipients: recipients,
        condominioNome: 'CondoGaia',
      );
    }
  }

  /// Sends a warning to specific recipients
  Future<void> enviarAviso({
    required String subject,
    required String body,
    required List<RecipientModel> recipients,
    required String condominioNome,
  }) async {
    final payload = {
      'subject': subject,
      'body': body,
      'condominioNome': condominioNome,
      'recipients': recipients
          .map((r) => {'email': r.email, 'name': r.name, 'type': r.type})
          .toList(),
    };

    final response = await _apiService.post('/resend/gestao/aviso', payload);

    if (response.statusCode != 200) {
      throw Exception(
        'Falha ao enviar aviso: ${response.statusCode} - ${response.body}',
      );
    }
  }

  /// Sends emails in mass (each recipient gets an individual email)
  Future<void> enviarEmMassa({
    required String subject,
    required String body,
    required String topic,
    required List<RecipientModel> recipients,
    required String condominioNome,
  }) async {
    final payload = {
      'subject': subject,
      'body': body,
      'topic': topic,
      'condominioNome': condominioNome,
      'recipients': recipients
          .map((r) => {'email': r.email, 'name': r.name, 'type': r.type})
          .toList(),
    };

    final response = await _apiService.post('/resend/gestao/em-massa', payload);

    if (response.statusCode != 200) {
      throw Exception(
        'Falha ao enviar e-mails em massa: ${response.statusCode} - ${response.body}',
      );
    }
  }
}
