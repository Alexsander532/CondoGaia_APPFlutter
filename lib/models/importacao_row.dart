/// Representa uma linha da planilha de importação
/// Contém todos os dados brutos da planilha + erros de validação
class ImportacaoRow {
  final int linhaNumero; // Número da linha na planilha (para referência)

  // Dados da unidade
  String? bloco; // Se vazio, será automaticamente "A"
  String? unidade;
  String? fracaoIdeal;

  // Dados do proprietário
  String? proprietarioNomeCompleto;
  String? proprietarioCpf;
  String? proprietarioCel;
  String? proprietarioEmail;

  // Dados do inquilino
  String? inquilinoNomeCompleto;
  String? inquilinoCpf;
  String? inquilinoCel;
  String? inquilinoEmail;

  // Dados da imobiliária
  String? nomeImobiliaria;
  String? cnpjImobiliaria;
  String? celImobiliaria;
  String? emailImobiliaria;

  // Validações
  final List<String> errosValidacao = [];
  
  // Para armazenar IDs gerados após inserção
  String? proprietarioId;
  String? inquilinoId;
  String? blocoId;
  String? senhaProprietario;
  String? senhaInquilino;

  ImportacaoRow({
    required this.linhaNumero,
    this.bloco,
    this.unidade,
    this.fracaoIdeal,
    this.proprietarioNomeCompleto,
    this.proprietarioCpf,
    this.proprietarioCel,
    this.proprietarioEmail,
    this.inquilinoNomeCompleto,
    this.inquilinoCpf,
    this.inquilinoCel,
    this.inquilinoEmail,
    this.nomeImobiliaria,
    this.cnpjImobiliaria,
    this.celImobiliaria,
    this.emailImobiliaria,
  }) {
    // Se bloco estiver vazio, define como "A"
    if (bloco == null || bloco!.isEmpty) {
      bloco = "A";
    }
  }

  /// Retorna true se há erros de validação
  bool get temErros => errosValidacao.isNotEmpty;

  /// Adiciona um erro de validação
  void adicionarErro(String erro) {
    errosValidacao.add('Linha $linhaNumero: $erro');
  }

  /// Retorna um sumário dos dados para exibição
  String get sumario => '''
Bloco: $bloco | Unidade: $unidade | Fração: $fracaoIdeal
Proprietário: $proprietarioNomeCompleto ($proprietarioCpf)
Inquilino: ${inquilinoNomeCompleto ?? 'N/A'} (${inquilinoCpf ?? 'N/A'})
Imobiliária: ${nomeImobiliaria ?? 'N/A'}''';
}
