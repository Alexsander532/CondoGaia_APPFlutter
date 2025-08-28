# Guia de Implementação - Código Completo do Sistema de Login

## 1. Configuração Inicial

### 1.1 Atualizar pubspec.yaml

```yaml
name: condogaiaapp
description: "Aplicativo de gestão do condomínio Gaia"
publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: ^3.9.0

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  sqflite: ^2.3.0
  crypto: ^3.0.3
  shared_preferences: ^2.2.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

flutter:
  uses-material-design: true
```

### 1.2 Criar arquivo .env.example

```env
# Configurações do Banco de Dados
DB_NAME=condogaia.db
DB_VERSION=1

# Configurações de Segurança
PASSWORD_SALT=condogaia_salt_2024
SESSION_TIMEOUT=3600

# Configurações da Aplicação
APP_NAME=CondoGaia
DEBUG_MODE=false
```

## 2. Modelos de Dados

### 2.1 lib/models/admin.dart

```dart
class Admin {
  final int? id;
  final String email;
  final String passwordHash;
  final DateTime createdAt;
  final DateTime updatedAt;

  Admin({
    this.id,
    required this.email,
    required this.passwordHash,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password_hash': passwordHash,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Admin.fromMap(Map<String, dynamic> map) {
    return Admin(
      id: map['id']?.toInt(),
      email: map['email'] ?? '',
      passwordHash: map['password_hash'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}

class LoginResult {
  final bool success;
  final String? errorMessage;
  final Admin? admin;

  LoginResult({
    required this.success,
    this.errorMessage,
    this.admin,
  });
}
```

## 3. Serviços de Banco de Dados

### 3.1 lib/services/database\_helper.dart

```dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/admin.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'condogaia.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE administrators (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Criar índices
    await db.execute('CREATE INDEX idx_administrators_email ON administrators(email)');
    
    // Inserir administrador padrão
    await _insertDefaultAdmin(db);
  }

  Future<void> _insertDefaultAdmin(Database db) async {
    String defaultPassword = _hashPassword('123456');
    DateTime now = DateTime.now();
    
    await db.insert('administrators', {
      'email': 'alexsanderaugusto142019@gmail.com',
      'password_hash': defaultPassword,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });
  }

  String _hashPassword(String password) {
    var bytes = utf8.encode(password + 'condogaia_salt_2024');
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<LoginResult> authenticateUser(String email, String password) async {
    try {
      final db = await database;
      String hashedPassword = _hashPassword(password);
      
      final List<Map<String, dynamic>> maps = await db.query(
        'administrators',
        where: 'email = ? AND password_hash = ?',
        whereArgs: [email, hashedPassword],
      );

      if (maps.isNotEmpty) {
        Admin admin = Admin.fromMap(maps.first);
        return LoginResult(success: true, admin: admin);
      } else {
        return LoginResult(
          success: false, 
          errorMessage: 'Email ou senha incorretos'
        );
      }
    } catch (e) {
      return LoginResult(
        success: false, 
        errorMessage: 'Erro interno: ${e.toString()}'
      );
    }
  }

  Future<void> insertAdmin(String email, String password) async {
    final db = await database;
    String hashedPassword = _hashPassword(password);
    DateTime now = DateTime.now();
    
    await db.insert('administrators', {
      'email': email,
      'password_hash': hashedPassword,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });
  }
}
```

### 3.2 lib/services/auth\_service.dart

```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';
import '../models/admin.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();
  static const String _autoLoginKey = 'auto_login';
  static const String _userEmailKey = 'user_email';

  Future<LoginResult> login(String email, String password, bool autoLogin) async {
    LoginResult result = await _dbHelper.authenticateUser(email, password);
    
    if (result.success && autoLogin) {
      await _saveAutoLoginPreference(email);
    }
    
    return result;
  }

  Future<void> _saveAutoLoginPreference(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoLoginKey, true);
    await prefs.setString(_userEmailKey, email);
  }

  Future<bool> hasAutoLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoLoginKey) ?? false;
  }

  Future<String?> getAutoLoginEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_autoLoginKey);
    await prefs.remove(_userEmailKey);
  }
}
```

## 4. Telas da Aplicação

### 4.1 lib/screens/login\_screen.dart

```dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/admin.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  
  bool _isPasswordVisible = false;
  bool _autoLogin = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    if (await _authService.hasAutoLogin()) {
      String? email = await _authService.getAutoLoginEmail();
      if (email != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      LoginResult result = await _authService.login(
        _emailController.text.trim(),
        _passwordController.text,
        _autoLogin,
      );

      if (result.success) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        _showErrorDialog(result.errorMessage ?? 'Erro desconhecido');
      }
    } catch (e) {
      _showErrorDialog('Erro interno: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erro de Login'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Esqueci a Senha'),
        content: const Text('Entre em contato com o administrador do sistema para recuperar sua senha.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Acesso',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF424242),
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // Campo E-mail
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'E-mail',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF424242),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Digite seu e-mail',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF2196F3)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira seu e-mail';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Por favor, insira um e-mail válido';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Campo Senha
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Senha',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF424242),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          hintText: 'Digite sua senha',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF2196F3)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              color: Colors.grey[600],
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira sua senha';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Checkbox Login Automático
                  Row(
                    children: [
                      Checkbox(
                        value: _autoLogin,
                        onChanged: (value) {
                          setState(() {
                            _autoLogin = value ?? false;
                          });
                        },
                        activeColor: const Color(0xFF2196F3),
                      ),
                      const Text(
                        'Login Automático',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF424242),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Botão Entrar
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Entrar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Link Esqueci a senha
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _showForgotPasswordDialog,
                      child: const Text(
                        'Esqueci a senha',
                        style: TextStyle(
                          color: Color(0xFF2196F3),
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
```

### 4.2 lib/screens/main\_screen.dart

```dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await AuthService().logout();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CondoGaia - Dashboard'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Sair',
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home,
              size: 64,
              color: Color(0xFF2196F3),
            ),
            SizedBox(height: 16),
            Text(
              'Bem-vindo ao CondoGaia!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF424242),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Login realizado com sucesso.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF666666),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 4.3 lib/main.dart

```dart
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const CondoGaiaApp());
}

class CondoGaiaApp extends StatelessWidget {
  const CondoGaiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CondoGaia',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
```

## 5. Instruções de Instalação

1. **Atualizar dependências:**

   ```bash
   flutter pub get
   ```

2. **Executar o aplicativo:**

   ```bash
   flutter run
   ```

3. **Credenciais padrão:**

   * Email: `alexsanderaugusto142019@gmail.com`

   * Senha: `123456`

## 6. Relatório de Segurança e Escalabilidade

**Pontos Fortes:**

* Senhas são criptografadas com SHA-256 e salt personalizado

* Validação robusta de entrada de dados

* Separação clara de responsabilidades entre camadas

* Uso de SharedPreferences para persistência segura de preferências

* Interface responsiva e acessível

**Sugestões de Melhorias:**

* Implementar rate limiting para tentativas de login

* Adicionar logs de auditoria para tentativas de acesso

* Considerar implementação de autenticação biométrica

* Adicionar timeout de sessão automático

* Implementar backup e sincronização de dados

* Adicionar testes unitários e de integração

