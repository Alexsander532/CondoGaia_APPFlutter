/// EXEMPLO DE USO DO IMPORTACAO SERVICE
///
/// Este arquivo demonstra como usar o ImportacaoService para:
/// 1. Fazer parsing de um arquivo Excel
/// 2. Validar os dados
/// 3. Mapear para entidades
/// 4. Gerar resultado

/*

// ============================================================================
// EXEMPLO 1: USO BÁSICO
// ============================================================================

import 'package:file_picker/file_picker.dart';
import 'package:condogaiaapp/services/importacao_service.dart';

Future<void> importarPlanilha() async {
  // 1. Selecionar arquivo
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['xlsx', 'xls'],
  );

  if (result == null) return;

  final bytes = result.files.first.bytes;
  if (bytes == null) return;

  try {
    // 2. Fazer parsing e validação
    final rows = await ImportacaoService.parsarEValidarArquivo(
      bytes,
      cpfsExistentesNoBanco: await _buscarCpfsExistentes(),
      emailsExistenteNoBanco: await _buscarEmailsExistentes(),
    );

    // 3. Mostrar preview
    final validas = rows.where((r) => !r.temErros).length;
    final comErro = rows.where((r) => r.temErros).length;

    print('✅ Linhas válidas: $validas');
    print('❌ Linhas com erro: $comErro');

    // 4. Mapear para entidades (se não houver erros críticos)
    final mapeado = await ImportacaoService.mapearParaEntidades(
      rows,
      condominioId: 'condo_123',
    );

    print('Proprietários: ${mapeado['proprietarios'].length}');
    print('Inquilinos: ${mapeado['inquilinos'].length}');
    print('Imobiliárias: ${mapeado['imobiliarias'].length}');
    print('Blocos: ${mapeado['blocos'].length}');

    // 5. Inserir no banco (próxima tarefa)
    // await _inserirNoBanco(mapeado);

  } catch (e) {
    print('❌ Erro: $e');
  }
}

// ============================================================================
// EXEMPLO 2: COM TRATAMENTO DE ERROS E PREVIEW
// ============================================================================

Future<void> importarComPreview() async {
  try {
    final bytes = ...; // Arquivo selecionado pelo usuário

    // Fazer parsing e validação
    final rows = await ImportacaoService.parsarEValidarArquivo(
      bytes,
      cpfsExistentesNoBanco: <String>{},
      emailsExistenteNoBanco: <String>{},
    );

    // Separar válidas e com erro
    final validas = rows.where((r) => !r.temErros).toList();
    final comErro = rows.where((r) => r.temErros).toList();

    // Mostrar preview ao usuário
    _mostrarPreview(
      totalLinhas: rows.length,
      linhasValidas: validas.length,
      linhasComErro: comErro.length,
      erros: comErro.expand((r) => r.errosValidacao).toList(),
    );

    // Se o usuário confirmar (clicou botão)
    if (userConfirmed) {
      // Mapear para entidades
      final mapeado = await ImportacaoService.mapearParaEntidades(
        validas, // Apenas as válidas!
        condominioId: widget.condominioId,
      );

      // Inserir no banco de dados
      // final resultado = await _inserirNoSupabase(mapeado);
      
      // Mostrar resultado
      // _mostrarResultado(resultado);
    }

  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro: $e')),
    );
  }
}

// ============================================================================
// EXEMPLO 3: VALIDAÇÃO CUSTOMIZADA
// ============================================================================

Future<void> importarComValidacaoCustomizada() async {
  final bytes = ...; // Arquivo

  // 1. Parse básico
  final rows = await ParseadorExcel.parseExcel(bytes);

  print('Total de linhas: ${rows.length}');
  
  // Linhas vazias são puladas automaticamente
  // Linhas com dados são convertidas em ImportacaoRow

  // 2. Buscar dados existentes no banco
  final cpfsExistentes = await supabase
      .from('proprietarios')
      .select('cpf')
      .then((data) => data.map((d) => d['cpf'].toString()).toSet());

  // 3. Validar com dados do banco
  final rowsValidadas = await ImportacaoService.parsarEValidarArquivo(
    bytes,
    cpfsExistentesNoBanco: cpfsExistentes,
    emailsExistenteNoBanco: <String>{},
  );

  // 4. Processar apenas válidas
  final validas = rowsValidadas.where((r) => !r.temErros);

  for (final row in validas) {
    print('✅ ${row.proprietarioNomeCompleto}');
  }
}

// ============================================================================
// EXEMPLO 4: GERAÇÃO DE SENHAS
// ============================================================================

Future<void> exemploSenhas() async {
  final rows = await ImportacaoService.parsarEValidarArquivo(bytes);
  
  final mapeado = await ImportacaoService.mapearParaEntidades(
    rows,
    condominioId: 'condo_123',
  );

  // As senhas já foram geradas!
  final senhasProprietarios = mapeado['senhasProprietarios'] as Map<String, String>;
  
  // Exemplo: senhasProprietarios = {
  //   '12345678901': 'CG2024Abc123',
  //   '11122233344': 'CG2024Xyz789',
  // }

  // Exibir senhas
  for (final entry in senhasProprietarios.entries) {
    print('CPF: ${entry.key} | Senha: ${entry.value}');
  }
}

// ============================================================================
// EXEMPLO 5: ERRO - COLUNAS AUSENTES
// ============================================================================

Future<void> exemploErrosColunas() async {
  try {
    // Se o arquivo não tem a coluna 'proprietario_cpf'
    final rows = await ParseadorExcel.parseExcel(bytes);
    // Vai lançar Exception com mensagem:
    // "Coluna obrigatória "proprietario_cpf" não encontrada na planilha.
    //  Colunas esperadas: bloco, unidade, ..."
  } catch (e) {
    print('❌ Erro: $e');
  }
}

// ============================================================================
// EXEMPLO 6: ERRO - MÚLTIPLOS ERROS NA MESMA LINHA
// ============================================================================

Future<void> exemploMultiplosErros() async {
  final rows = await ImportacaoService.parsarEValidarArquivo(bytes);

  final rowComErro = rows.firstWhere(
    (r) => r.linhaNumero == 5,
  );

  // Podem haver múltiplos erros
  print('Erros na linha 5:');
  for (final erro in rowComErro.errosValidacao) {
    print('  - $erro');
  }

  // Exemplo de saída:
  // Erros na linha 5:
  //   - Linha 5: CPF "123" inválido - CPF deve conter 11 dígitos
  //   - Linha 5: Email "joao@" inválido - Formato correto: usuario@dominio.com
  //   - Linha 5: Telefone "11" inválido - Deve ter 10 ou 11 dígitos
}

// ============================================================================
// EXEMPLO 7: VERIFICAÇÃO DE DUPLICATAS
// ============================================================================

Future<void> exemploDuplicatas() async {
  // Se na planilha existe CPF duplicado
  // Exemplo: linha 5 e linha 15 têm o mesmo CPF

  final rows = await ImportacaoService.parsarEValidarArquivo(bytes);

  final row5 = rows.firstWhere((r) => r.linhaNumero == 5);
  final row15 = rows.firstWhere((r) => r.linhaNumero == 15);

  print('Linha 5 tem erro? ${row5.temErros}'); // true
  print('Linha 15 tem erro? ${row15.temErros}'); // true

  // Erros serão algo como:
  // Linha 15: CPF "123.456.789-01" duplicado
  //   → Este CPF já existe em outra linha (Linha 5) desta importação
}

// ============================================================================
// EXEMPLO 8: FLUXO COMPLETO (UI)
// ============================================================================

// No seu widget de importação:

class ImportacaoPlanilhaScreen extends StatefulWidget {
  @override
  State<ImportacaoPlanilhaScreen> createState() => _ImportacaoPlanilhaScreenState();
}

class _ImportacaoPlanilhaScreenState extends State<ImportacaoPlanilhaScreen> {
  List<ImportacaoRow>? _rowsValidadas;
  bool _carregando = false;

  Future<void> _selecionarArquivo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result == null) return;

    setState(() => _carregando = true);

    try {
      final bytes = result.files.first.bytes!;

      // Validar
      _rowsValidadas = await ImportacaoService.parsarEValidarArquivo(
        bytes,
        cpfsExistentesNoBanco: <String>{},
        emailsExistenteNoBanco: <String>{},
      );

      // Mostrar preview
      _mostrarPreview();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Erro: $e')),
      );
    } finally {
      setState(() => _carregando = false);
    }
  }

  void _mostrarPreview() {
    final validas = _rowsValidadas!.where((r) => !r.temErros).length;
    final comErro = _rowsValidadas!.where((r) => r.temErros).length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Preview da Importação'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('✅ Válidas: $validas'),
            Text('❌ Com erro: $comErro'),
            SizedBox(height: 16),
            if (comErro > 0) ...[
              Text('Erros encontrados:'),
              ..._rowsValidadas!
                  .where((r) => r.temErros)
                  .expand((r) => r.errosValidacao)
                  .map((e) => Text('• $e')),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          if (validas > 0)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _confirmarImportacao();
              },
              child: Text('Importar (${validas} linhas)'),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmarImportacao() async {
    final validas = _rowsValidadas!.where((r) => !r.temErros).toList();

    try {
      // Mapear para entidades
      final mapeado = await ImportacaoService.mapearParaEntidades(
        validas,
        condominioId: widget.condominioId,
      );

      // TODO: Inserir no banco (próxima tarefa)
      // final resultado = await _inserirNoSupabase(mapeado);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Importação realizada com sucesso!')),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Erro: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Importar Planilha')),
      body: Center(
        child: _carregando
            ? CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _selecionarArquivo,
                child: Text('Selecionar Arquivo'),
              ),
      ),
    );
  }
}

*/
