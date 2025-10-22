import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/administrator.dart';
import '../models/representante.dart';
import '../models/proprietario.dart';
import '../models/inquilino.dart';

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
  Future<LoginResult> login(
    String email,
    String password,
    bool autoLogin,
  ) async {
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
        final passwordCheckResponse = await _supabase.rpc(
          'verify_password',
          params: {
            'input_password': password,
            'stored_hash': administrator.passwordHash,
          },
        );

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
      print('DEBUG AUTH: ========== TENTATIVA DE LOGIN ==========');
      print('DEBUG AUTH: Email fornecido: "$email"');
      print('DEBUG AUTH: Email processado: "$emailOriginal"');
      print('DEBUG AUTH: Tentando login como representante...');

      final representanteResponse = await _supabase
          .from('representantes')
          .select()
          .ilike(
            'email',
            emailOriginal,
          ) // Buscar representante por email (case-insensitive)
          .maybeSingle();

      print(
        'DEBUG AUTH: Resposta da busca de representante: ${representanteResponse != null ? 'ENCONTRADO' : 'NÃO ENCONTRADO'}',
      );

      // Debug: Listar todos os emails de representantes para comparação
      try {
        final todosRepresentantes = await _supabase
            .from('representantes')
            .select('email, nome_completo')
            .limit(10);
        print('DEBUG AUTH: Representantes cadastrados no sistema:');
        for (var rep in todosRepresentantes) {
          print(
            '  - Email: "${rep['email']}" | Nome: "${rep['nome_completo']}"',
          );
        }
      } catch (e) {
        print('DEBUG AUTH: Erro ao listar representantes: $e');
      }

      if (representanteResponse != null) {
        final representante = Representante.fromJson(representanteResponse);
        print(
          'DEBUG AUTH: Representante encontrado: ${representante.nomeCompleto}',
        );
        print('DEBUG AUTH: Verificando senha...');

        // Verificar senha diretamente (representantes usam senha simples)
        if (representante.senhaAcesso == password) {
          print('DEBUG AUTH: ✅ Login como representante APROVADO');
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
        } else {
          print('DEBUG AUTH: ❌ Senha incorreta para representante');
        }
      }

      // Se não encontrou representante, tentar como proprietário
      print('DEBUG AUTH: Tentando login como proprietário...');
      try {
        final proprietarioResponse = await _supabase
            .from('proprietarios')
            .select('*')
            .ilike('email', emailOriginal)
            .maybeSingle();

        print(
          'DEBUG AUTH: Resposta da busca de proprietário: ${proprietarioResponse != null ? 'ENCONTRADO' : 'NÃO ENCONTRADO'}',
        );

        if (proprietarioResponse != null) {
          final proprietario = Proprietario.fromJson(proprietarioResponse);
          print('DEBUG AUTH: Proprietário encontrado: ${proprietario.nome}');
          print('DEBUG AUTH: Verificando senha...');

          // Verificar senha diretamente (proprietários usam senha simples)
          if (proprietario.senhaAcesso == password) {
            print('DEBUG AUTH: ✅ Login como proprietário APROVADO');
            // Salvar estado de login como proprietário
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool(_isLoggedInKey, true);
            await prefs.setString(_userEmailKey, email);
            await prefs.setBool(_autoLoginKey, autoLogin);
            await prefs.setString(_userTypeKey, 'proprietario');

            return LoginResult(
              success: true,
              message: 'Login realizado com sucesso',
              proprietario: proprietario,
              userType: UserType.proprietario,
            );
          } else {
            print('DEBUG AUTH: ❌ Senha incorreta para proprietário');
          }
        }
      } catch (e) {
        print('DEBUG AUTH: ❌ ERRO ao buscar proprietário: $e');
        print('DEBUG AUTH: Tipo do erro: ${e.runtimeType}');
        if (e is PostgrestException) {
          print('DEBUG AUTH: Código do erro: ${e.code}');
          print('DEBUG AUTH: Mensagem do erro: ${e.message}');
          print('DEBUG AUTH: Detalhes do erro: ${e.details}');
        }
      }

      // Se não encontrou proprietário, tentar como inquilino
      print('DEBUG AUTH: Tentando login como inquilino...');
      try {
        final inquilinoResponse = await _supabase
            .from('inquilinos')
            .select('*')
            .ilike('email', emailOriginal)
            .maybeSingle();

        print(
          'DEBUG AUTH: Resposta da busca de inquilino: ${inquilinoResponse != null ? 'ENCONTRADO' : 'NÃO ENCONTRADO'}',
        );

        if (inquilinoResponse != null) {
          final inquilino = Inquilino.fromJson(inquilinoResponse);
          print('DEBUG AUTH: Inquilino encontrado: ${inquilino.nome}');
          print('DEBUG AUTH: Verificando senha...');

          // Verificar senha diretamente (inquilinos usam senha simples)
          if (inquilino.senhaAcesso == password) {
            print('DEBUG AUTH: ✅ Login como inquilino APROVADO');
            // Salvar estado de login como inquilino
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool(_isLoggedInKey, true);
            await prefs.setString(_userEmailKey, email);
            await prefs.setBool(_autoLoginKey, autoLogin);
            await prefs.setString(_userTypeKey, 'inquilino');

            return LoginResult(
              success: true,
              message: 'Login realizado com sucesso',
              inquilino: inquilino,
              userType: UserType.inquilino,
            );
          } else {
            print('DEBUG AUTH: ❌ Senha incorreta para inquilino');
          }
        }
      } catch (e) {
        print('DEBUG AUTH: ❌ ERRO ao buscar inquilino: $e');
        print('DEBUG AUTH: Tipo do erro: ${e.runtimeType}');
        if (e is PostgrestException) {
          print('DEBUG AUTH: Código do erro: ${e.code}');
          print('DEBUG AUTH: Mensagem do erro: ${e.message}');
          print('DEBUG AUTH: Detalhes do erro: ${e.details}');
        }
      }

      print('DEBUG AUTH: ❌ Nenhum usuário encontrado ou senha incorreta');

      return LoginResult(success: false, message: 'Credenciais inválidas');
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
    } else if (userTypeString == 'proprietario') {
      return UserType.proprietario;
    } else if (userTypeString == 'inquilino') {
      return UserType.inquilino;
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
        return LoginResult(
          success: false,
          message: 'Login automático desabilitado',
        );
      }

      final email = await getLoggedUserEmail();
      final userType = await getUserType();

      if (email == null || userType == null) {
        return LoginResult(
          success: false,
          message: 'Dados de login não encontrados',
        );
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
          return LoginResult(
            success: false,
            message: 'Administrador não encontrado',
          );
        }

        final administrator = Administrator.fromJson(response);
        return LoginResult(
          success: true,
          message: 'Login automático realizado',
          administrator: administrator,
          userType: UserType.administrator,
        );
      } else if (userType == UserType.representante) {
        // Verificar se o representante ainda existe no banco
        final response = await _supabase
            .from('representantes')
            .select()
            .ilike('email', email)
            .maybeSingle();

        if (response == null) {
          await logout();
          return LoginResult(
            success: false,
            message: 'Representante não encontrado',
          );
        }

        final representante = Representante.fromJson(response);
        return LoginResult(
          success: true,
          message: 'Login automático realizado',
          representante: representante,
          userType: UserType.representante,
        );
      } else if (userType == UserType.proprietario) {
        // Verificar se o proprietário ainda existe no banco
        final response = await _supabase
            .from('proprietarios')
            .select('*, unidades!inner(numero, bloco), condominios!inner(nome)')
            .ilike('email', email)
            .maybeSingle();

        if (response == null) {
          await logout();
          return LoginResult(
            success: false,
            message: 'Proprietário não encontrado',
          );
        }

        final proprietario = Proprietario.fromJson(response);
        return LoginResult(
          success: true,
          message: 'Login automático realizado',
          proprietario: proprietario,
          userType: UserType.proprietario,
        );
      } else if (userType == UserType.inquilino) {
        // Verificar se o inquilino ainda existe no banco
        final response = await _supabase
            .from('inquilinos')
            .select('*, unidades!inner(numero, bloco), condominios!inner(nome)')
            .ilike('email', email)
            .maybeSingle();

        if (response == null) {
          await logout();
          return LoginResult(
            success: false,
            message: 'Inquilino não encontrado',
          );
        }

        final inquilino = Inquilino.fromJson(response);
        return LoginResult(
          success: true,
          message: 'Login automático realizado',
          inquilino: inquilino,
          userType: UserType.inquilino,
        );
      }

      // Caso nenhum tipo de usuário seja reconhecido
      return LoginResult(
        success: false,
        message: 'Tipo de usuário não reconhecido',
      );
    } catch (e) {
      return LoginResult(
        success: false,
        message: 'Erro no login automático: ${e.toString()}',
      );
    }
  }
}

enum UserType { administrator, representante, proprietario, inquilino }

class LoginResult {
  final bool success;
  final String message;
  final Administrator? administrator;
  final Representante? representante;
  final Proprietario? proprietario;
  final Inquilino? inquilino;
  final UserType? userType;

  LoginResult({
    required this.success,
    required this.message,
    this.administrator,
    this.representante,
    this.proprietario,
    this.inquilino,
    this.userType,
  });

  // Getter para verificar se é administrador
  bool get isAdministrator => userType == UserType.administrator;

  // Getter para verificar se é representante
  bool get isRepresentante => userType == UserType.representante;

  // Getter para verificar se é proprietário
  bool get isProprietario => userType == UserType.proprietario;

  // Getter para verificar se é inquilino
  bool get isInquilino => userType == UserType.inquilino;
}
