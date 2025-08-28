import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/administrator.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userEmailKey = 'user_email';
  static const String _autoLoginKey = 'auto_login';

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

  // Fazer login
  Future<LoginResult> login(String email, String password, bool autoLogin) async {
    try {
      // Buscar administrador no Supabase
      final response = await _supabase
          .from('administrators')
          .select()
          .eq('email', email.toLowerCase().trim())
          .maybeSingle();

      if (response == null) {
        return LoginResult(
          success: false,
          message: 'Email não encontrado',
        );
      }

      final administrator = Administrator.fromJson(response);
      
      // Verificar senha usando a função crypt do PostgreSQL
      final passwordCheckResponse = await _supabase
          .rpc('verify_password', params: {
            'input_password': password,
            'stored_hash': administrator.passwordHash,
          });

      if (passwordCheckResponse != true) {
        return LoginResult(
          success: false,
          message: 'Senha incorreta',
        );
      }

      // Salvar estado de login
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setString(_userEmailKey, email);
      await prefs.setBool(_autoLoginKey, autoLogin);

      return LoginResult(
        success: true,
        message: 'Login realizado com sucesso',
        administrator: administrator,
      );
    } catch (e) {
      return LoginResult(
        success: false,
        message: 'Erro ao fazer login: ${e.toString()}',
      );
    }
  }

  // Fazer logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_autoLoginKey);
  }

  // Tentar login automático
  Future<LoginResult> tryAutoLogin() async {
    try {
      final isAutoEnabled = await isAutoLoginEnabled();
      if (!isAutoEnabled) {
        return LoginResult(success: false, message: 'Login automático desabilitado');
      }

      final email = await getLoggedUserEmail();
      if (email == null) {
        return LoginResult(success: false, message: 'Email não encontrado');
      }

      // Verificar se o usuário ainda existe no banco
      final response = await _supabase
          .from('administrators')
          .select()
          .eq('email', email)
          .maybeSingle();

      if (response == null) {
        await logout();
        return LoginResult(success: false, message: 'Usuário não encontrado');
      }

      final administrator = Administrator.fromJson(response);
      return LoginResult(
        success: true,
        message: 'Login automático realizado',
        administrator: administrator,
      );
    } catch (e) {
      return LoginResult(
        success: false,
        message: 'Erro no login automático: ${e.toString()}',
      );
    }
  }
}

class LoginResult {
  final bool success;
  final String message;
  final Administrator? administrator;

  LoginResult({
    required this.success,
    required this.message,
    this.administrator,
  });
}