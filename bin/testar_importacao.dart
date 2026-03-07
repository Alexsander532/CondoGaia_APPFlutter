import 'dart:io';
import 'package:condogaiaapp/models/importacao_row.dart';
import 'package:condogaiaapp/models/importacao_entidades.dart';
import 'package:condogaiaapp/services/importacao_service.dart';
import 'package:condogaiaapp/services/logger_importacao.dart';

/// Script para testar importação de planilha
/// 
/// Uso:
/// 1. Coloque o arquivo Excel em assets/planilha_importacao.xlsx
/// 2. Execute: dart run bin/testar_importacao.dart

Future<void> main(List<String> args) async {
  try
   {
    // Ler arquivo da planilha
    final file =
        File('assets/planilha_importacao.xlsx');

    if (!file.existsSync()) {
      print('❌ ERRO: Arquivo não encontrado em assets/planilha_importacao.xlsx');
      print('');
      print('📝 Instruções:');
      print('1. Salve seu arquivo Excel em: assets/planilha_importacao.xlsx');
      print('2. Execute novamente: dart run bin/testar_importacao.dart');
      exit(1);
    }

    // Ler bytes do arquivo
    final bytes = await file.readAsBytes();
    LoggerImportacao.logInicio('planilha_importacao.xlsx');

    // ===== FASE 1 E 2: PARSING + VALIDAÇÃO =====
    print('\n⏳ Processando planilha...\n');

    final rowsValidadas = await ImportacaoService.parsarEValidarArquivo(
      bytes,
      enableLogging: true,
    );

    // Verificar se há linhas válidas
    final linhasValidas = rowsValidadas.where((r) => !r.temErros).toList();
    
    if (linhasValidas.isEmpty) {
      print('\n❌ ERRO: Nenhuma linha válida encontrada na planilha!');
      print('Por favor, corrija os erros acima.\n');
      exit(1);
    }

    // ===== FASE 3: MAPEAMENTO =====
    print('\n⏳ Mapeando dados...\n');
    LoggerImportacao.logMapeamentoInicio();

    final dadosMapeados = await ImportacaoService.mapearParaEntidades(
      rowsValidadas,
      condominioId: 'condo-demo-123',
    );

    // Extrair dados mapeados - tipos corretos
    final proprietarios = dadosMapeados['proprietarios'] as Map;
    final inquilinos = dadosMapeados['inquilinos'] as Map;
    final blocos = dadosMapeados['blocos'] as Map;
    final imobiliarias = dadosMapeados['imobiliarias'] as Map;
    final senhasProprietarios =
        dadosMapeados['senhasProprietarios'] as Map<String, String>;
    final senhasInquilinos =
        dadosMapeados['senhasInquilinos'] as Map<String, String>;

    // ===== EXIBIR RESULTADOS =====
    _exibirResultados(
      rowsValidadas,
      proprietarios,
      inquilinos,
      blocos,
      imobiliarias,
      senhasProprietarios,
      senhasInquilinos,
    );

    print('\n✅ TESTE CONCLUÍDO COM SUCESSO!\n');
  } catch (e, stackTrace) {
    print('\n❌ ERRO DURANTE TESTE:\n');
    print('Mensagem: $e');
    print('\nStack Trace:');
    print(stackTrace);
    exit(1);
  }
}

void _exibirResultados(
  List<ImportacaoRow> rowsValidadas,
  Map proprietarios,
  Map inquilinos,
  Map blocos,
  Map imobiliarias,
  Map<String, String> senhasProprietarios,
  Map<String, String> senhasInquilinos,
) {
  final totalLinhas = rowsValidadas.length;
  final linhasValidas = rowsValidadas.where((r) => r.errosValidacao.isEmpty).length;
  final linhasComErro = totalLinhas - linhasValidas;

  print('\n${'═' * 63}');
  print('📊 RESUMO DA IMPORTAÇÃO');
  print('${'═' * 63}');
  print('📁 Total de linhas: $totalLinhas');
  print('✅ Linhas válidas: $linhasValidas');
  print('❌ Linhas com erro: $linhasComErro');
  print('${'═' * 63}\n');

  // Propriet ários
  print('\n${'═' * 63}');
  print('👥 PROPRIETÁRIOS (${proprietarios.length})');
  print('${'═' * 63}');
  int idx = 1;
  for (final entry in proprietarios.entries) {
    final cpf = entry.key;
    final prop = entry.value as ProprietarioImportacao;
    final senha = senhasProprietarios[cpf] ?? 'N/A';

    print(
      '\n$idx. ${prop.nomeCompleto}\n'
      '   CPF: ${cpf.substring(0, 3)}***${cpf.substring(8)}\n'
      '   Email: ${prop.email}\n'
      '   Telefone: ${prop.telefone}\n'
      '   Unidades: ${prop.unidades.join(", ")}\n'
      '   🔑 Senha: $senha',
    );
    idx++;
  }
  print('\n${'═' * 63}\n');

  // Inquilinos
  if (inquilinos.isNotEmpty) {
    print('\n${'═' * 63}');
    print('🏠 INQUILINOS (${inquilinos.length})');
    print('${'═' * 63}');

    idx = 1;
    for (final entry in inquilinos.entries) {
      final inquilino = entry.value;
      final cpf = inquilino.cpf;
      final senha = senhasInquilinos[cpf] ?? 'N/A';

      print(
        '\n$idx. ${inquilino.nomeCompleto}\n'
        '   CPF: ${cpf.substring(0, 3)}***${cpf.substring(8)}\n'
        '   Email: ${inquilino.email}\n'
        '   Telefone: ${inquilino.telefone}\n'
        '   Unidade: ${inquilino.bloco}${inquilino.unidade}\n'
        '   🔑 Senha: $senha',
      );
      idx++;
    }
    print('\n${'═' * 63}\n');
  }

  // Blocos
  if (blocos.isNotEmpty) {
    print('\n${'═' * 63}');
    print('🏘️  BLOCOS (${blocos.length})');
    print('${'═' * 63}');
    int idx2 = 1;
    for (final entry in blocos.entries) {
      final bloco = entry.value;
      print('$idx2. ${bloco.nome}');
      idx2++;
    }
    print('${'═' * 63}\n');
  }

  // Imobiliárias
  if (imobiliarias.isNotEmpty) {
    print('\n${'═' * 63}');
    print('🏢 IMOBILIÁRIAS (${imobiliarias.length})');
    print('${'═' * 63}');
    idx = 1;
    for (final entry in imobiliarias.entries) {
      final imob = entry.value;
      print(
        '\n$idx. ${imob.nome}\n'
        '   CNPJ: ${imob.cnpj.substring(0, 2)}***${imob.cnpj.substring(9)}\n'
        '   Email: ${imob.email}\n'
        '   Telefone: ${imob.telefone}',
      );
      idx++;
    }
    print('\n${'═' * 63}\n');
  }

  // Resumo final
  print('\n${'═' * 63}');
  print('🎉 DADOS PRONTOS PARA IMPORTAÇÃO');
  print('${'═' * 63}');
  print('✓ Proprietários: ${proprietarios.length}');
  print('✓ Inquilinos: ${inquilinos.length}');
  print('✓ Blocos: ${blocos.length}');
  print('✓ Imobiliárias: ${imobiliarias.length}');
  print('✓ Total de senhas: ${senhasProprietarios.length + senhasInquilinos.length}');
  print('${'═' * 63}\n');
}
