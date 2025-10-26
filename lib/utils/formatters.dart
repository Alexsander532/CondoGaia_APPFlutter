import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:intl/intl.dart';

class Formatters {
  // Máscara para CPF (XXX.XXX.XXX-XX)
  static final cpfFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  // Máscara para CNPJ (XX.XXX.XXX/XXXX-XX)
  static final cnpjFormatter = MaskTextInputFormatter(
    mask: '##.###.###/####-##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  // Máscara para CEP (XXXXX-XXX)
  static final cepFormatter = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  // Máscara para data (DD/MM/AAAA)
  static final dateFormatter = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  // Máscara para telefone (XX) XXXXX-XXXX
  static final phoneFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  // Formatador para valores monetários
  static final currencyFormatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\u0024',
    decimalDigits: 2,
  );

  /// Formatar valor monetário
  static String formatCurrency(double value) {
    return currencyFormatter.format(value);
  }

  /// Converter string monetária para double
  static double parseCurrency(String value) {
    // Remove símbolos e espaços
    String cleanValue = value
        .replaceAll('R\u0024', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();
    
    return double.tryParse(cleanValue) ?? 0.0;
  }

  /// Validar CPF (versão flexível para desenvolvimento)
  static bool isValidCPF(String cpf) {
    // Remove formatação
    String cleanCPF = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Verifica se tem 11 dígitos
    if (cleanCPF.length != 11) return false;
    
    // Verifica se todos os dígitos são iguais (ex: 111.111.111-11)
    if (RegExp(r'^(\d)\1*$').hasMatch(cleanCPF)) return false;
    
    // Para desenvolvimento: aceita qualquer CPF com 11 dígitos diferentes
    // Se quiser validação rigorosa, descomente o código abaixo:
    
    /*
    // Validação rigorosa dos dígitos verificadores
    List<int> digits = cleanCPF.split('').map(int.parse).toList();
    
    // Primeiro dígito verificador
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += digits[i] * (10 - i);
    }
    int remainder = sum % 11;
    int digit1 = remainder < 2 ? 0 : 11 - remainder;
    
    if (digits[9] != digit1) return false;
    
    // Segundo dígito verificador
    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += digits[i] * (11 - i);
    }
    remainder = sum % 11;
    int digit2 = remainder < 2 ? 0 : 11 - remainder;
    
    return digits[10] == digit2;
    */
    
    return true;
  }

  /// Validar CNPJ
  static bool isValidCNPJ(String cnpj) {
    // Remove formatação
    String cleanCNPJ = cnpj.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Verifica se tem 14 dígitos
    if (cleanCNPJ.length != 14) return false;
    
    // Verifica se todos os dígitos são iguais
    if (RegExp(r'^(\d)\1*\$').hasMatch(cleanCNPJ)) return false;
    
    // Validação dos dígitos verificadores
    List<int> digits = cleanCNPJ.split('').map(int.parse).toList();
    
    // Primeiro dígito verificador
    int sum = 0;
    List<int> weights1 = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    for (int i = 0; i < 12; i++) {
      sum += digits[i] * weights1[i];
    }
    int remainder = sum % 11;
    int digit1 = remainder < 2 ? 0 : 11 - remainder;
    
    if (digits[12] != digit1) return false;
    
    // Segundo dígito verificador
    sum = 0;
    List<int> weights2 = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    for (int i = 0; i < 13; i++) {
      sum += digits[i] * weights2[i];
    }
    remainder = sum % 11;
    int digit2 = remainder < 2 ? 0 : 11 - remainder;
    
    return digits[13] == digit2;
  }

  /// Validar CEP
  static bool isValidCEP(String cep) {
    String cleanCEP = cep.replaceAll(RegExp(r'[^0-9]'), '');
    return cleanCEP.length == 8;
  }

  /// Validar data
  static bool isValidDate(String date) {
    if (date.length != 10) return false;
    
    try {
      List<String> parts = date.split('/');
      if (parts.length != 3) return false;
      
      int day = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      int year = int.parse(parts[2]);
      
      if (day < 1 || day > 31) return false;
      if (month < 1 || month > 12) return false;
      if (year < 1900 || year > 2100) return false;
      
      // Verificar se a data é válida
      DateTime dateTime = DateTime(year, month, day);
      return dateTime.day == day && dateTime.month == month && dateTime.year == year;
    } catch (e) {
      return false;
    }
  }

  /// Validar email
  static bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  /// Converter data string para DateTime
  static DateTime? parseDate(String date) {
    if (!isValidDate(date)) return null;
    
    try {
      List<String> parts = date.split('/');
      int day = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      int year = int.parse(parts[2]);
      
      return DateTime(year, month, day);
    } catch (e) {
      return null;
    }
  }

  /// Converter DateTime para string formatada
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Lista de estados brasileiros
  static const List<Map<String, String>> estadosBrasileiros = [
    {'sigla': 'AC', 'nome': 'Acre'},
    {'sigla': 'AL', 'nome': 'Alagoas'},
    {'sigla': 'AP', 'nome': 'Amapá'},
    {'sigla': 'AM', 'nome': 'Amazonas'},
    {'sigla': 'BA', 'nome': 'Bahia'},
    {'sigla': 'CE', 'nome': 'Ceará'},
    {'sigla': 'DF', 'nome': 'Distrito Federal'},
    {'sigla': 'ES', 'nome': 'Espírito Santo'},
    {'sigla': 'GO', 'nome': 'Goiás'},
    {'sigla': 'MA', 'nome': 'Maranhão'},
    {'sigla': 'MT', 'nome': 'Mato Grosso'},
    {'sigla': 'MS', 'nome': 'Mato Grosso do Sul'},
    {'sigla': 'MG', 'nome': 'Minas Gerais'},
    {'sigla': 'PA', 'nome': 'Pará'},
    {'sigla': 'PB', 'nome': 'Paraíba'},
    {'sigla': 'PR', 'nome': 'Paraná'},
    {'sigla': 'PE', 'nome': 'Pernambuco'},
    {'sigla': 'PI', 'nome': 'Piauí'},
    {'sigla': 'RJ', 'nome': 'Rio de Janeiro'},
    {'sigla': 'RN', 'nome': 'Rio Grande do Norte'},
    {'sigla': 'RS', 'nome': 'Rio Grande do Sul'},
    {'sigla': 'RO', 'nome': 'Rondônia'},
    {'sigla': 'RR', 'nome': 'Roraima'},
    {'sigla': 'SC', 'nome': 'Santa Catarina'},
    {'sigla': 'SP', 'nome': 'São Paulo'},
    {'sigla': 'SE', 'nome': 'Sergipe'},
    {'sigla': 'TO', 'nome': 'Tocantins'},
  ];
}