import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recipient_model.dart';
import '../models/email_modelo_model.dart';
import '../models/email_attachment_model.dart';
import '../../../../models/proprietario.dart';
import '../../../../models/inquilino.dart';
import '../../../../models/unidade.dart';
import '../../../../services/laravel_api_service.dart';

class EmailGestaoService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final LaravelApiService _apiService = LaravelApiService();

  // ─────────────────────────────────────────────────────────
  //  Recipients
  // ─────────────────────────────────────────────────────────

  Future<List<RecipientModel>> fetchRecipients({
    required String condominioId,
  }) async {
    try {
      final unidadesResponse = await _supabase
          .from('unidades')
          .select()
          .eq('condominio_id', condominioId)
          .eq('ativo', true);

      final units = (unidadesResponse as List)
          .map((e) => Unidade.fromJson(e))
          .toList();

      final Map<String, Unidade> unidadeMap = {for (var u in units) u.id: u};

      final ownersResponse = await _supabase
          .from('proprietarios')
          .select()
          .eq('condominio_id', condominioId);

      final owners = (ownersResponse as List)
          .map((e) => Proprietario.fromJson(e))
          .toList();

      final tenantsResponse = await _supabase
          .from('inquilinos')
          .select()
          .eq('condominio_id', condominioId);

      final tenants = (tenantsResponse as List)
          .map((e) => Inquilino.fromJson(e))
          .toList();

      List<RecipientModel> recipients = [];

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

      recipients.sort((a, b) => a.name.compareTo(b.name));
      return recipients;
    } catch (e) {
      throw Exception('Erro ao buscar destinatários: $e');
    }
  }

  // ─────────────────────────────────────────────────────────
  //  Modelos de Email (CRUD via Supabase)
  // ─────────────────────────────────────────────────────────

  /// Busca modelos de email do condomínio, filtrados por tópico.
  Future<List<EmailModeloModel>> fetchModelos({
    required String condominioId,
    String? topico,
  }) async {
    try {
      var query = _supabase
          .from('email_modelos')
          .select()
          .eq('condominio_id', condominioId);

      if (topico != null && topico.isNotEmpty) {
        query = query.eq('topico', topico);
      }

      final response = await query.order('criado_em', ascending: false);

      return (response as List)
          .map((e) => EmailModeloModel.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar modelos: $e');
    }
  }

  /// Salva um novo modelo de email no Supabase.
  Future<EmailModeloModel> salvarModelo({
    required String condominioId,
    required String topico,
    required String titulo,
    required String assunto,
    required String corpo,
  }) async {
    try {
      final response = await _supabase
          .from('email_modelos')
          .insert({
            'condominio_id': condominioId,
            'topico': topico,
            'titulo': titulo,
            'assunto': assunto,
            'corpo': corpo,
          })
          .select()
          .single();

      return EmailModeloModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao salvar modelo: $e');
    }
  }

  /// Exclui um modelo de email pelo ID.
  Future<void> excluirModelo(String id) async {
    try {
      await _supabase.from('email_modelos').delete().eq('id', id);
    } catch (e) {
      throw Exception('Erro ao excluir modelo: $e');
    }
  }

  // ─────────────────────────────────────────────────────────
  //  Email Sending
  // ─────────────────────────────────────────────────────────

  Future<void> sendEmail({
    required String subject,
    required String body,
    required String topic,
    required List<RecipientModel> recipients,
    EmailAttachmentModel? attachment,
  }) async {
    await enviarCircular(
      subject: subject,
      body: body,
      topic: topic,
      recipients: recipients,
      condominioNome: 'CondoGaia',
      attachment: attachment,
    );
  }

  Future<void> enviarCircular({
    required String subject,
    required String body,
    required String topic,
    required List<RecipientModel> recipients,
    required String condominioNome,
    EmailAttachmentModel? attachment,
  }) async {
    final payload = <String, dynamic>{
      'subject': subject,
      'body': body,
      'topic': topic,
      'condominioNome': condominioNome,
      'recipients': recipients
          .map((r) => {'email': r.email, 'name': r.name, 'type': r.type})
          .toList(),
    };

    if (attachment != null) {
      payload['attachment'] = attachment.toJsonPayload();
    }

    final response = await _apiService.post('/resend/gestao/circular', payload);

    if (response.statusCode != 200) {
      throw Exception(
        'Falha ao enviar circular: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> enviarAviso({
    required String subject,
    required String body,
    required List<RecipientModel> recipients,
    required String condominioNome,
    EmailAttachmentModel? attachment,
  }) async {
    final payload = <String, dynamic>{
      'subject': subject,
      'body': body,
      'condominioNome': condominioNome,
      'recipients': recipients
          .map((r) => {'email': r.email, 'name': r.name, 'type': r.type})
          .toList(),
    };

    if (attachment != null) {
      payload['attachment'] = attachment.toJsonPayload();
    }

    final response = await _apiService.post('/resend/gestao/aviso', payload);

    if (response.statusCode != 200) {
      throw Exception(
        'Falha ao enviar aviso: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> enviarEmMassa({
    required String subject,
    required String body,
    required String topic,
    required List<RecipientModel> recipients,
    required String condominioNome,
    EmailAttachmentModel? attachment,
  }) async {
    final payload = <String, dynamic>{
      'subject': subject,
      'body': body,
      'topic': topic,
      'condominioNome': condominioNome,
      'recipients': recipients
          .map((r) => {'email': r.email, 'name': r.name, 'type': r.type})
          .toList(),
    };

    if (attachment != null) {
      payload['attachment'] = attachment.toJsonPayload();
    }

    final response = await _apiService.post('/resend/gestao/em-massa', payload);

    if (response.statusCode != 200) {
      throw Exception(
        'Falha ao enviar e-mails em massa: ${response.statusCode} - ${response.body}',
      );
    }
  }
}
