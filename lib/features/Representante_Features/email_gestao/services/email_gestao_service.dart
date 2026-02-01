import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import '../models/recipient_model.dart';
import '../../../../models/proprietario.dart';
import '../../../../models/inquilino.dart';
import '../../../../models/unidade.dart';

class EmailGestaoService {
  final SupabaseClient _supabase = Supabase.instance.client;

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

  Future<void> sendEmail({
    required String subject,
    required String body,
    required String topic,
    required List<RecipientModel> recipients,
    File? attachment,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    print('Sending email to: ${recipients.length} recipients');
    print('Subject: $subject');
    print('Topic: $topic');
    if (attachment != null) print('Attachment: ${attachment.path}');
  }
}
