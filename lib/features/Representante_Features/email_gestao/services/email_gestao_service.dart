import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import '../models/recipient_model.dart';
import '../../../../models/proprietario.dart';
import '../../../../models/inquilino.dart';
import '../../../../models/unidade.dart';

class EmailGestaoService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<RecipientModel>> fetchRecipients(String condominioId) async {
    try {
      // 1. Fetch Units (to map ID to Block/Number)
      final unidadesResponse = await _supabase
          .from('unidades')
          .select()
          .eq('condominio_id', condominioId)
          .eq('ativo', true);

      final unidades = (unidadesResponse as List)
          .map((e) => Unidade.fromJson(e))
          .toList();

      final Map<String, Unidade> unidadeMap = {for (var u in unidades) u.id: u};

      // 2. Fetch Owners (Proprietarios)
      final ownersResponse = await _supabase
          .from('proprietarios')
          .select()
          .eq('condominio_id', condominioId);
      //.eq('ativo', true); // Uncomment if 'ativo' column exists and is needed

      final owners = (ownersResponse as List)
          .map((e) => Proprietario.fromJson(e))
          .toList();

      // 3. Fetch Tenants (Inquilinos)
      final tenantsResponse = await _supabase
          .from('inquilinos')
          .select()
          .eq('condominio_id', condominioId);
      //.eq('ativo', true); // Uncomment if needed

      final tenants = (tenantsResponse as List)
          .map((e) => Inquilino.fromJson(e))
          .toList();

      List<RecipientModel> recipients = [];

      // Map Owners
      for (var owner in owners) {
        String unitInfo = '';
        if (owner.unidadeId != null) {
          final unit = unidadeMap[owner.unidadeId];
          if (unit != null) {
            unitInfo = '${unit.numero} / ${unit.bloco ?? ''}';
          }
        }

        // Skip if no email? The UI implies email is needed. Or keep it empty.
        // The mock had default emails. We use real ones here.
        recipients.add(
          RecipientModel(
            id: owner.id,
            name: owner.nome,
            email: owner.email ?? '',
            type: 'P',
            unitBlock: unitInfo,
          ),
        );
      }

      // Map Tenants
      for (var tenant in tenants) {
        String unitInfo = '';
        if (tenant.unidadeId.isNotEmpty) {
          final unit = unidadeMap[tenant.unidadeId];
          if (unit != null) {
            unitInfo = '${unit.numero} / ${unit.bloco ?? ''}';
          }
        }

        recipients.add(
          RecipientModel(
            id: tenant.id,
            name: tenant.nome,
            email: tenant.email ?? '',
            type: 'I',
            unitBlock: unitInfo,
          ),
        );
      }

      // Sort by Name
      recipients.sort((a, b) => a.name.compareTo(b.name));

      return recipients;
    } catch (e) {
      print('Error fetching recipients: $e');
      throw Exception('Erro ao buscar destinatários: $e');
    }
  }

  Future<void> sendEmail({
    required String subject,
    required String body,
    required String topic, // Added implementation for topic
    required List<RecipientModel> recipients,
    File? attachment,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));

    // In a real implementation:
    // await _supabase.functions.invoke('send-email', body: { ... });

    print('Sending email to: ${recipients.length} recipients');
    print('Subject: $subject');
    print('Topic: $topic');
    if (attachment != null) print('Attachment: ${attachment.path}');
  }
}
