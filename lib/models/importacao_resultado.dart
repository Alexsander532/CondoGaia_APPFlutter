/// Representa o resultado da importação de uma planilha
/// Contém resumo de sucessos e erros
class ImportacaoResultado {
  final int totalLinhas;
  final int proprietariosCriados;
  final int inquilinosCriados;
  final int imobiliariosCriados;
  final int blocosCriados;
  
  /// Lista de erros encontrados (cada erro já inclui o número da linha)
  final List<String> errosDetalhados;
  
  /// Map com proprietário CPF -> senha gerada
  final Map<String, String> senhasProprietarios;
  
  /// Map com inquilino CPF -> senha gerada
  final Map<String, String> senhasInquilinos;

  ImportacaoResultado({
    required this.totalLinhas,
    required this.proprietariosCriados,
    required this.inquilinosCriados,
    required this.imobiliariosCriados,
    required this.blocosCriados,
    required this.errosDetalhados,
    required this.senhasProprietarios,
    required this.senhasInquilinos,
  });

  /// Retorna true se a importação foi totalmente bem-sucedida (sem erros)
  bool get sucesso => errosDetalhados.isEmpty;

  /// Retorna a quantidade total de erros
  int get totalErros => errosDetalhados.length;

  /// Retorna a quantidade de linhas processadas com sucesso
  int get linhasComSucesso => proprietariosCriados + inquilinosCriados;

  /// Retorna um sumário legível do resultado
  String get sumario {
    return '''
═══ RESULTADO DA IMPORTAÇÃO ═══
✅ Proprietários criados: $proprietariosCriados
✅ Inquilinos criados: $inquilinosCriados
✅ Imobiliárias criadas: $imobiliariosCriados
✅ Blocos criados: $blocosCriados
❌ Total de erros: $totalErros
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Total de linhas processadas: $linhasComSucesso / $totalLinhas
''';
  }

  /// Retorna um relatório formatado de erros
  String get relatorioErros {
    if (errosDetalhados.isEmpty) {
      return "✅ Nenhum erro encontrado!";
    }
    
    final buffer = StringBuffer();
    buffer.writeln("❌ ERROS ENCONTRADOS:");
    buffer.writeln("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    
    for (final erro in errosDetalhados) {
      buffer.writeln("• $erro");
    }
    
    return buffer.toString();
  }
}
