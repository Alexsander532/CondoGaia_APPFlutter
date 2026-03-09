import 'package:supabase/supabase.dart';
import 'dart:io';

void main() async {
  print(
    'Iniciando script de população para textos_condominio_configuracoes...',
  );

  final supabase = SupabaseClient(
    'https://tukpgefrddfchmvtiujp.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR1a3BnZWZyZGRmY2htdnRpdWpwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI1MTg1NTEsImV4cCI6MjA2ODA5NDU1MX0.dZ1Pna1_dwelIJTlhrSN0iiH5nhuzL0y4p6llYJsLp8',
  );

  try {
    // Busca todos os condominios
    final listCondominios = await supabase
        .from('condominios')
        .select('id, nome_condominio');
    print('Encontrados \${listCondominios.length} condomínios no banco.');

    if (listCondominios.isEmpty) {
      print('Nenhum condomínio encontrado para popular.');
      exit(0);
    }

    for (var cond in listCondominios) {
      String condominioId = cond['id'];

      // Checa se já possui configuração
      final configExistente = await supabase
          .from('textos_condominio_configuracoes')
          .select('id')
          .eq('condominio_id', condominioId)
          .maybeSingle();

      if (configExistente != null) {
        print(
          "O condomínio ${cond['nome_condominio']} já possui configuração de textos. Pulando...",
        );
        continue;
      }

      // Insere um default
      final dataParams = {
        'condominio_id': condominioId,
        'comunicado_boleto_cota':
            'Sr(a) Condômino(a), o pagamento da sua cota condominial é muito importante para a manutenção e investimentos no nosso condomínio. Agradecemos sua colaboração!',
        'comunicado_boleto_acordo':
            'Este boleto é referente ao acordo firmado. Mantenha os pagamentos em dia para evitar cancelamento do acordo.',
        'texto_boleto_taxa':
            'Esta taxa extra foi aprovada em assembleia geral para melhorias e manutenções excepcionais.',
        'texto_boleto_acordo':
            'Refere-se ao Termo de Confissão de Dívida e Acordo.',
        'responsavel_tecnico_nome': 'Administradora Exemplo',
        'responsavel_tecnico_cpf': '00000000000',
        'responsavel_tecnico_conselho': 'CRA-12345/OAB-67890',
        'responsavel_tecnico_funcoes': 'Administrador; Síndico Profissional',
        'exibir_data_demonstrativo': true,
      };

      await supabase.from('textos_condominio_configuracoes').insert(dataParams);
      print(
        "-> Configuração padrão inserida com sucesso para: ${cond['nome_condominio']}",
      );
    }

    print('População finalizada com sucesso!');
    exit(0);
  } catch (e) {
    print('Erro ocorreu ao popular banco: $e');
    exit(1);
  }
}
