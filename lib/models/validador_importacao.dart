/// Utilitário para validações comuns
class ValidadorImportacao {
  /// Valida se um CPF tem o formato correto (11 dígitos)
  /// Não valida o algoritmo, apenas o formato
  static bool validarCpf(String? cpf) {
    if (cpf == null || cpf.isEmpty) return false;
    
    // Remove caracteres especiais
    final cpfLimpo = cpf.replaceAll(RegExp(r'[^\d]'), '');
    
    // Deve ter 11 dígitos
    if (cpfLimpo.length != 11) return false;
    
    // Não pode ser todos iguais (111.111.111-11, etc)
    if (RegExp(r'^(\d)\1{10}$').hasMatch(cpfLimpo)) return false;
    
    return true;
  }

  /// Valida se um CNPJ tem o formato correto (14 dígitos)
  static bool validarCnpj(String? cnpj) {
    if (cnpj == null || cnpj.isEmpty) return false;
    
    // Remove caracteres especiais
    final cnpjLimpo = cnpj.replaceAll(RegExp(r'[^\d]'), '');
    
    // Deve ter 14 dígitos
    if (cnpjLimpo.length != 14) return false;
    
    // Não pode ser todos iguais
    if (RegExp(r'^(\d)\1{13}$').hasMatch(cnpjLimpo)) return false;
    
    return true;
  }

  /// Valida se um email tem formato correto
  static bool validarEmail(String? email) {
    if (email == null || email.isEmpty) return false;
    
    final pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    return RegExp(pattern).hasMatch(email);
  }

  /// Valida se um telefone tem o formato correto (10-11 dígitos)
  static bool validarTelefone(String? telefone) {
    if (telefone == null || telefone.isEmpty) return false;
    
    // Remove caracteres especiais
    final telLimpo = telefone.replaceAll(RegExp(r'[^\d]'), '');
    
    // Deve ter 10 ou 11 dígitos
    return telLimpo.length == 10 || telLimpo.length == 11;
  }

  /// Valida se uma fração ideal é um número válido (maior que 0)
  static bool validarFracaoIdeal(String? fracao) {
    if (fracao == null || fracao.isEmpty) return false;
    
    try {
      final valor = double.parse(fracao);
      return valor > 0;
    } catch (e) {
      return false;
    }
  }

  /// Remove caracteres especiais de um CPF
  static String limparCpf(String cpf) {
    return cpf.replaceAll(RegExp(r'[^\d]'), '');
  }

  /// Remove caracteres especiais de um CNPJ
  static String limparCnpj(String cnpj) {
    return cnpj.replaceAll(RegExp(r'[^\d]'), '');
  }

  /// Remove caracteres especiais de um telefone
  static String limparTelefone(String telefone) {
    return telefone.replaceAll(RegExp(r'[^\d]'), '');
  }

  /// Limpa uma string removendo espaços extras
  static String limparTexto(String? texto) {
    if (texto == null) return '';
    return texto.trim();
  }
}
