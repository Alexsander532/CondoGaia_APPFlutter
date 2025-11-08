/// Representa um proprietário que pode ter múltiplas unidades
/// Usado para agrupar dados do proprietário antes de inserção
class ProprietarioImportacao {
  final String cpf;
  final String nomeCompleto;
  final String email;
  final String telefone;
  final String senha; // Senha gerada
  
  /// Lista de unidades que este proprietário possui
  /// Formato: "bloco-unidade-fracaoIdeal"
  final List<String> unidades = [];

  ProprietarioImportacao({
    required this.cpf,
    required this.nomeCompleto,
    required this.email,
    required this.telefone,
    required this.senha,
  });

  /// Adiciona uma unidade ao proprietário
  void adicionarUnidade(String bloco, String unidade, String fracaoIdeal) {
    unidades.add('$bloco-$unidade-$fracaoIdeal');
  }

  @override
  String toString() {
    return 'ProprietarioImportacao($cpf, $nomeCompleto, ${unidades.length} unidades)';
  }
}

/// Representa um inquilino com sua unidade (1:1)
/// Usado para agrupar dados do inquilino antes de inserção
class InquilinoImportacao {
  final String cpf;
  final String nomeCompleto;
  final String email;
  final String telefone;
  final String senha; // Senha gerada
  
  /// Bloco e unidade onde o inquilino mora
  final String bloco;
  final String unidade;

  InquilinoImportacao({
    required this.cpf,
    required this.nomeCompleto,
    required this.email,
    required this.telefone,
    required this.senha,
    required this.bloco,
    required this.unidade,
  });

  @override
  String toString() {
    return 'InquilinoImportacao($cpf, $nomeCompleto, $bloco-$unidade)';
  }
}

/// Representa uma imobiliária
/// Pode estar associada a múltiplas unidades
class ImobiliarioImportacao {
  final String cnpj;
  final String nome;
  final String email;
  final String telefone;

  ImobiliarioImportacao({
    required this.cnpj,
    required this.nome,
    required this.email,
    required this.telefone,
  });

  @override
  String toString() {
    return 'ImobiliarioImportacao($cnpj, $nome)';
  }
}

/// Representa um bloco que será criado automaticamente
class BlocoImportacao {
  final String nome;
  final String condominioId;

  BlocoImportacao({
    required this.nome,
    required this.condominioId,
  });

  @override
  String toString() {
    return 'BlocoImportacao($nome)';
  }
}
