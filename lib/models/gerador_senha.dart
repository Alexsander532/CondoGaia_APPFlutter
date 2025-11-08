import 'dart:math';

/// Utilitário para geração de senhas seguras
class GeradorSenha {
  static const String _maiusculas = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String _minusculas = 'abcdefghijklmnopqrstuvwxyz';
  static const String _numeros = '0123456789';
  static const String _caracteresespeciais = '@#\$%!&*';

  /// Gera uma senha segura aleatória
  /// Formato: Maiúscula + Minúsculas + Números + Caractere especial
  /// Exemplo: "Cd7@Kx9#Qm2"
  static String gerar({int tamanho = 12}) {
    assert(tamanho >= 8, 'Senha deve ter pelo menos 8 caracteres');

    final random = Random.secure();
    final todosCaracteres = '$_maiusculas$_minusculas$_numeros$_caracteresespeciais';
    
    final senhaBuffer = <String>[];
    
    // Garante que tem pelo menos um de cada tipo
    senhaBuffer.add(_maiusculas[random.nextInt(_maiusculas.length)]);
    senhaBuffer.add(_minusculas[random.nextInt(_minusculas.length)]);
    senhaBuffer.add(_numeros[random.nextInt(_numeros.length)]);
    senhaBuffer.add(_caracteresespeciais[random.nextInt(_caracteresespeciais.length)]);
    
    // Completa o restante com caracteres aleatórios
    for (int i = senhaBuffer.length; i < tamanho; i++) {
      senhaBuffer.add(todosCaracteres[random.nextInt(todosCaracteres.length)]);
    }
    
    // Embaralha a senha
    senhaBuffer.shuffle(random);
    
    return senhaBuffer.join();
  }

  /// Gera uma senha mais simples (letras maiúsculas + números)
  /// Mais fácil de memorizar e compartilhar
  /// Exemplo: "CG2024ABC123"
  static String gerarSimples({int tamanho = 10}) {
    assert(tamanho >= 6, 'Senha deve ter pelo menos 6 caracteres');

    final random = Random.secure();
    final todosCaracteres = '$_maiusculas$_numeros';
    
    final senhaBuffer = <String>[];
    
    // Começa com "CG" (CondoGaia)
    senhaBuffer.add('C');
    senhaBuffer.add('G');
    
    // Adiciona ano
    final ano = DateTime.now().year.toString().substring(2);
    senhaBuffer.addAll(ano.split(''));
    
    // Completa com caracteres aleatórios
    for (int i = senhaBuffer.length; i < tamanho; i++) {
      senhaBuffer.add(todosCaracteres[random.nextInt(todosCaracteres.length)]);
    }
    
    return senhaBuffer.join();
  }

  /// Gera uma lista de senhas únicas
  static List<String> gerarMultiplas(int quantidade, {bool simples = false}) {
    final senhas = <String>{};
    
    while (senhas.length < quantidade) {
      senhas.add(simples ? gerarSimples() : gerar());
    }
    
    return senhas.toList();
  }

  /// Valida se uma senha é segura
  /// Verifica: minimo 8 caracteres, maiúscula, minúscula, número e caractere especial
  static bool validarSeguranca(String senha) {
    if (senha.length < 8) return false;
    if (!RegExp(r'[A-Z]').hasMatch(senha)) return false;
    if (!RegExp(r'[a-z]').hasMatch(senha)) return false;
    if (!RegExp(r'[0-9]').hasMatch(senha)) return false;
    if (!RegExp(r'[@#\$%!&*]').hasMatch(senha)) return false;
    
    return true;
  }
}
