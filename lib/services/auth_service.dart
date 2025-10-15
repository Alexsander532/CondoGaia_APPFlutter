import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/administrator.dart';
import '../models/representante.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userEmailKey = 'user_email';
  static const String _autoLoginKey = 'auto_login';
  static const String _userTypeKey = 'user_type';

  // Verificar se o usuário está logado
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Verificar se o login automático está habilitado
  Future<bool> isAutoLoginEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoLoginKey) ?? false;
  }

  // Obter email do usuário logado
  Future<String?> getLoggedUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  // Método alternativo para obter email do usuário atual
  Future<String?> getCurrentUserEmail() async {
    return await getLoggedUserEmail();
  }

  // Criptografar senha
  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Fazer login (detecta automaticamente se é admin ou representante)
  Future<LoginResult> login(String email, String password, bool autoLogin) async {
    try {
      // Primeiro, tentar login como administrador
      final adminResponse = await _supabase
          .from('administrators')
          .select()
          .eq('email', email.toLowerCase().trim())
          .maybeSingle();

      if (adminResponse != null) {
        final administrator = Administrator.fromJson(adminResponse);
        
        // Verificar senha usando a função crypt do PostgreSQL
        final passwordCheckResponse = await _supabase
            .rpc('verify_password', params: {
              'input_password': password,
              'stored_hash': administrator.passwordHash,
            });

        if (passwordCheckResponse == true) {
          // Salvar estado de login como administrador
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(_isLoggedInKey, true);
          await prefs.setString(_userEmailKey, email);
          await prefs.setBool(_autoLoginKey, autoLogin);
          await prefs.setString(_userTypeKey, 'administrator');

          return LoginResult(
            success: true,
            message: 'Login realizado com sucesso',
            administrator: administrator,
            userType: UserType.administrator,
          );
        }
      }

      // Se não encontrou admin ou senha incorreta, tentar como representante
      final emailOriginal = email.trim();
      print('DEBUG: Tentando login como representante');
      print('DEBUG: Email original: "$email"');
      print('DEBUG: Email para busca: "$emailOriginal"');
      
      final representanteResponse = await _supabase
          .from('representantes')
          .select()
          .ilike('email', emailOriginal) // Buscar representante por email (case-insensitive)
          .maybeSingle();

      print('DEBUG: Resposta da busca de representante: $representanteResponse');
      
      // Debug: Listar todos os emails de representantes para comparação
      try {
        final todosRepresentantes = await _supabase
            .from('representantes')
            .select('email, nome_completo')
            .limit(10);
        print('DEBUG: Todos os representantes na tabela:');
        for (var rep in todosRepresentantes) {
          print('  - Email: "${rep['email']}" | Nome: "${rep['nome_completo']}"');
        }
      } catch (e) {
        print('DEBUG: Erro ao listar representantes: $e');
      }

      if (representanteResponse != null) {
        final representante = Representante.fromJson(representanteResponse);
        print('DEBUG: Representante encontrado: ${representante.nomeCompleto}');
        print('DEBUG: Senha armazenada no banco: "${representante.senhaAcesso}"');
        print('DEBUG: Senha fornecida pelo usuário: "$password"');
        print('DEBUG: Senhas são iguais? ${representante.senhaAcesso == password}');
        
        // Verificar senha diretamente (representantes usam senha simples)
        if (representante.senhaAcesso == password) {
          // Salvar estado de login como representante
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(_isLoggedInKey, true);
          await prefs.setString(_userEmailKey, email);
          await prefs.setBool(_autoLoginKey, autoLogin);
          await prefs.setString(_userTypeKey, 'representante');

          return LoginResult(
            success: true,
            message: 'Login realizado com sucesso',
            representante: representante,
            userType: UserType.representante,
          );
        }
      }

      return LoginResult(
        success: false,
        message: 'Credenciais inválidas',
      );
    } catch (e) {
      return LoginResult(
        success: false,
        message: 'Erro ao fazer login: ${e.toString()}',
      );
    }
  }

  // Obter tipo de usuário logado
  Future<UserType?> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    final userTypeString = prefs.getString(_userTypeKey);
    if (userTypeString == 'administrator') {
      return UserType.administrator;
    } else if (userTypeString == 'representante') {
      return UserType.representante;
    }
    return null;
  }

  // Fazer logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_autoLoginKey);
    await prefs.remove(_userTypeKey);
  }

  // Tentar login automático
  Future<LoginResult> tryAutoLogin() async {
    try {
      final isAutoEnabled = await isAutoLoginEnabled();
      if (!isAutoEnabled) {
        return LoginResult(success: false, message: 'Login automático desabilitado');
      }

      final email = await getLoggedUserEmail();
      final userType = await getUserType();
      
      if (email == null || userType == null) {
        return LoginResult(success: false, message: 'Dados de login não encontrados');
      }

      if (userType == UserType.administrator) {
        // Verificar se o administrador ainda existe no banco
        final response = await _supabase
            .from('administrators')
            .select()
            .eq('email', email)
            .maybeSingle();

        if (response == null) {
          await logout();
          return LoginResult(success: false, message: 'Administrador não encontrado');
        }

        final administrator = Administrator.fromJson(response);
        return LoginResult(
          success: true,
          message: 'Login automático realizado',
          administrator: administrator,
          userType: UserType.administrator,
        );
      } else {
        // Verificar se o representante ainda existe no banco
        final response = await _supabase
            .from('representantes')
            .select()
            .ilike('email', email)
            .maybeSingle();

        if (response == null) {
          await logout();
          return LoginResult(success: false, message: 'Representante não encontrado');
        }

        final representante = Representante.fromJson(response);
        return LoginResult(
          success: true,
          message: 'Login automático realizado',
          representante: representante,
          userType: UserType.representante,
        );
      }
    } catch (e) {
      return LoginResult(
        success: false,
        message: 'Erro no login automático: ${e.toString()}',
      );
    }
  }
}

enum UserType {
  administrator,
  representante,
}

class LoginResult {
  final bool success;
  final String message;
  final Administrator? administrator;
  final Representante? representante;
  final UserType? userType;

  LoginResult({
    required this.success,
    required this.message,
    this.administrator,
    this.representante,
    this.userType,
  });

  // Getter para verificar se é administrador
  bool get isAdministrator => userType == UserType.administrator;
  
  // Getter para verificar se é representante
  bool get isRepresentante => userType == UserType.representante;
}