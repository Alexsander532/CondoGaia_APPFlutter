import 'dart:math';

/// Utilitário para geração automática de senhas para representantes
class PasswordGenerator {
  static const String _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  static const int _defaultLength = 8;
  
  /// Gera uma senha aleatória para representante
  /// 
  /// [length] - Tamanho da senha (padrão: 8 caracteres)
  /// 
  /// Retorna uma senha contendo letras maiúsculas e números
  /// Exemplo: "A7B2C9D1"
  static String generatePassword({int length = _defaultLength}) {
    final random = Random();
    final buffer = StringBuffer();
    
    for (int i = 0; i < length; i++) {
      buffer.write(_chars[random.nextInt(_chars.length)]);
    }
    
    return buffer.toString();
  }
  
  /// Gera uma senha baseada no nome do representante
  /// 
  /// [nomeCompleto] - Nome completo do representante
  /// 
  /// Retorna uma senha no formato: primeiras 4 letras do nome + 4 números aleatórios
  /// Exemplo: "JOAO1234"
  static String generatePasswordFromName(String nomeCompleto) {
    if (nomeCompleto.isEmpty) {
      return generatePassword();
    }
    
    // Remove espaços e caracteres especiais, converte para maiúsculo
    final nomeClean = nomeCompleto
        .replaceAll(RegExp(r'[^a-zA-Z]'), '')
        .toUpperCase();
    
    // Pega as primeiras 4 letras do nome (ou menos se o nome for menor)
    final prefixo = nomeClean.length >= 4 
        ? nomeClean.substring(0, 4)
        : nomeClean.padRight(4, 'X');
    
    // Gera 4 números aleatórios
    final random = Random();
    final numeros = List.generate(4, (_) => random.nextInt(10)).join();
    
    return '$prefixo$numeros';
  }
  
  /// Valida se uma senha atende aos critérios mínimos
  /// 
  /// [password] - Senha a ser validada
  /// 
  /// Retorna true se a senha tem pelo menos 6 caracteres
  static bool isValidPassword(String password) {
    return password.length >= 6;
  }
}