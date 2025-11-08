/// Logger de importação para debug detalhado no terminal
/// Mostra todos os passos do processo: parsing, validação, mapeamento
class LoggerImportacao {
  static const String _separator =
      '═══════════════════════════════════════════════════════════════';

  /// Log do início do processamento
  static void logInicio(String nomeArquivo) {
    print('\n$_separator');
    print('🚀 INICIANDO IMPORTAÇÃO DE PLANILHA');
    print('$_separator');
    print('📁 Arquivo: $nomeArquivo');
    print('⏰ Hora: ${DateTime.now()}');
    print('$_separator\n');
  }

  /// Log do parsing
  static void logParsing(int totalLinhas) {
    print('\n📖 FASE 1: PARSING DO ARQUIVO');
    print('─' * 63);
    print('✓ Arquivo lido com sucesso');
    print('✓ Total de linhas encontradas: $totalLinhas');
    print('');
  }

  /// Log de cada linha parseada
  static void logLinhaParseada(
    int numero,
    String bloco,
    String unidade,
    String proprietarioNome,
    String proprietarioCpf,
  ) {
    print(
      '  📄 Linha $numero: Bloco $bloco | Un. $unidade | '
      '$proprietarioNome | CPF: ${proprietarioCpf.substring(0, 3)}***${proprietarioCpf.substring(8)}',
    );
  }

  /// Log de validação iniciada
  static void logValidacaoInicio() {
    print('\n✔️ FASE 2: VALIDAÇÃO DE DADOS');
    print('─' * 63);
  }

  /// Log de linha válida
  static void logLinhaValida(
    int numero,
    String proprietarioNome,
    String? inquilinoNome,
  ) {
    final inquilinoInfo =
        inquilinoNome != null ? ' → Inquilino: $inquilinoNome' : '';
    print('  ✅ Linha $numero OK: $proprietarioNome$inquilinoInfo');
  }

  /// Log de erro em linha
  static void logLinhaErro(int numero, List<String> erros) {
    print('  ❌ Linha $numero ERROS:');
    for (final erro in erros) {
      print('     • $erro');
    }
  }

  /// Log de resumo de validação
  static void logResumoValidacao(
    int totalLinhas,
    int validas,
    int comErros,
  ) {
    final percentualValidas = totalLinhas > 0
        ? ((validas / totalLinhas) * 100).toStringAsFixed(1)
        : '0';

    print('\n$_separator');
    print('📊 RESUMO DA VALIDAÇÃO');
    print('$_separator');
    print('📈 Total de linhas: $totalLinhas');
    print('✅ Linhas válidas: $validas ($percentualValidas%)');
    print('❌ Linhas com erro: $comErros');

    if (comErros > 0) {
      print('\n⚠️  ATENÇÃO: ${comErros > 1 ? 'Existem $comErros erros' : 'Existe 1 erro'} que precisa ser corrigido na planilha!');
    } else {
      print('\n✓ Nenhum erro encontrado! Dados prontos para mapeamento.');
    }
    print('$_separator\n');
  }

  /// Log de mapeamento iniciado
  static void logMapeamentoInicio() {
    print('\n🔄 FASE 3: MAPEAMENTO DE DADOS');
    print('─' * 63);
    print('Agrupando dados de proprietários, inquilinos e imobiliárias...\n');
  }

  /// Log de proprietário mapeado
  static void logProprietarioMapeado(
    String nome,
    String cpf,
    int quantidadeUnidades,
    String senha,
  ) {
    print(
      '  👤 Proprietário: $nome\n'
      '     • CPF: ${cpf.substring(0, 3)}***${cpf.substring(8)}\n'
      '     • Unidades: $quantidadeUnidades\n'
      '     • Senha: $senha\n',
    );
  }

  /// Log de inquilino mapeado
  static void logInquilino(
    String nome,
    String cpf,
    String unidade,
    String senha,
  ) {
    print(
      '  🏠 Inquilino: $nome\n'
      '     • CPF: ${cpf.substring(0, 3)}***${cpf.substring(8)}\n'
      '     • Unidade: $unidade\n'
      '     • Senha: $senha\n',
    );
  }

  /// Log de bloco criado automaticamente
  static void logBlocoCriadoAutomaticamente(String bloco) {
    print('  🏘️  Bloco criado automaticamente: $bloco');
  }

  /// Log de imobiliária mapeada
  static void logImobiliariaMapeada(String nome, String cnpj) {
    print(
      '  🏢 Imobiliária: $nome\n'
      '     • CNPJ: ${cnpj.substring(0, 2)}***${cnpj.substring(9)}\n',
    );
  }

  /// Log de resumo final
  static void logResumoFinal(
    int proprietarios,
    int inquilinos,
    int blocos,
    int imobiliarias,
    int totalSenhas,
  ) {
    print('\n$_separator');
    print('🎉 RESULTADO FINAL DA IMPORTAÇÃO');
    print('$_separator');
    print('👥 Proprietários a criar: $proprietarios');
    print('🏠 Inquilinos a criar: $inquilinos');
    print('🏘️  Blocos a criar: $blocos');
    print('🏢 Imobiliárias a criar: $imobiliarias');
    print('🔑 Total de senhas geradas: $totalSenhas');
    print('$_separator\n');
  }

  /// Log de erro geral
  static void logErro(String mensagem) {
    print('\n❌ ERRO: $mensagem\n');
  }

  /// Log de tabela de proprietários
  static void logTabelaProprietarios(
    Map<String, Map<String, dynamic>> proprietarios,
  ) {
    print('\n📋 TABELA DE PROPRIETÁRIOS');
    print('$_separator');

    int idx = 1;
    for (final entry in proprietarios.entries) {
      final cpf = entry.key;
      final dados = entry.value;
      final unidades = dados['unidades'] as List<String>;

      print(
        '$idx. ${dados['nome']}\n'
        '   CPF: ${cpf.substring(0, 3)}***${cpf.substring(8)}\n'
        '   Email: ${dados['email']}\n'
        '   Telefone: ${dados['telefone']}\n'
        '   Unidades: ${unidades.join(", ")}\n'
        '   Senha: ${dados['senha']}\n',
      );
      idx++;
    }
    print('$_separator\n');
  }

  /// Log de tabela de inquilinos
  static void logTabelaInquilinos(
    Map<String, Map<String, dynamic>> inquilinos,
  ) {
    print('\n📋 TABELA DE INQUILINOS');
    print('$_separator');

    int idx = 1;
    for (final entry in inquilinos.entries) {
      final cpf = entry.key;
      final dados = entry.value;

      print(
        '$idx. ${dados['nome']}\n'
        '   CPF: ${cpf.substring(0, 3)}***${cpf.substring(8)}\n'
        '   Email: ${dados['email']}\n'
        '   Telefone: ${dados['telefone']}\n'
        '   Unidade: ${dados['unidade']}\n'
        '   Senha: ${dados['senha']}\n',
      );
      idx++;
    }
    print('$_separator\n');
  }

  /// Log de tabela de blocos
  static void logTabelaBlocos(List<String> blocos) {
    print('\n📋 TABELA DE BLOCOS');
    print('$_separator');

    for (int i = 0; i < blocos.length; i++) {
      print('${i + 1}. ${blocos[i]}');
    }
    print('$_separator\n');
  }

  /// Log de tabela de imobiliárias
  static void logTabelaImobiliarias(
    Map<String, Map<String, dynamic>> imobiliarias,
  ) {
    print('\n📋 TABELA DE IMOBILIÁRIAS');
    print('$_separator');

    int idx = 1;
    for (final entry in imobiliarias.entries) {
      final cnpj = entry.key;
      final dados = entry.value;

      print(
        '$idx. ${dados['nome']}\n'
        '   CNPJ: ${cnpj.substring(0, 2)}***${cnpj.substring(9)}\n'
        '   Email: ${dados['email']}\n'
        '   Telefone: ${dados['telefone']}\n',
      );
      idx++;
    }
    print('$_separator\n');
  }

  /// Log com formatação de título
  static void logTitulo(String titulo) {
    print('\n$_separator');
    print(titulo);
    print('$_separator\n');
  }

  /// Log simples de informação
  static void logInfo(String mensagem) {
    print('ℹ️  $mensagem');
  }

  /// Log com destaque
  static void logDestaque(String mensagem) {
    print('\n⭐ $mensagem\n');
  }
}
