import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';
import '../screens/ADMIN/home_screen.dart';
import '../screens/representante_dashboard_screen.dart';
import '../screens/proprietario_dashboard_screen.dart';
import '../screens/inquilino_dashboard_screen.dart';
import '../screens/representante_home_screen.dart';
import '../screens/inquilino_home_screen.dart';
import '../screens/upload_foto_perfil_screen.dart';
import '../screens/upload_foto_perfil_proprietario_screen.dart';
import '../screens/upload_foto_perfil_inquilino_screen.dart';
import '../screens/portaria_representante_screen.dart';

class LoginScreen extends StatefulWidget {
  final String? usuarioDeletado; // Nome do usuário que foi deletado

  const LoginScreen({super.key, this.usuarioDeletado});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isPasswordVisible = false;
  bool _autoLogin = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Mostrar mensagem se um usuário foi deletado
    if (widget.usuarioDeletado != null && widget.usuarioDeletado!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Usuário "${widget.usuarioDeletado}" foi deletado com sucesso!',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // DEBUG: Log dos dados de entrada
      print('DEBUG LOGIN SCREEN: Email digitado: "${_emailController.text}"');
      print(
        'DEBUG LOGIN SCREEN: Senha digitada: "${_passwordController.text}"',
      );
      print('DEBUG LOGIN SCREEN: Auto login: $_autoLogin');

      final result = await _authService.login(
        _emailController.text,
        _passwordController.text,
        _autoLogin,
      );

      if (mounted) {
        if (result.success) {
          // Redirecionar conforme o tipo de usuário
          if (result.userType == UserType.administrator) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else if (result.userType == UserType.representante) {
            // Verificar se representante tem foto de perfil
            if (result.representante?.fotoPerfil == null ||
                result.representante!.fotoPerfil!.isEmpty) {
              // Primeira vez - ir para upload de foto
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => UploadFotoPerfilScreen(
                    representante: result.representante!,
                  ),
                ),
              );
            } else {
              // Já tem foto - verificar se tem múltiplas unidades/condominios
              _redirectRepresentante(result);
            }
          } else if (result.userType == UserType.proprietario) {
            // Verificar se proprietário tem foto de perfil
            if (result.proprietario?.fotoPerfil == null ||
                result.proprietario!.fotoPerfil!.isEmpty) {
              // Primeira vez - ir para upload de foto
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => UploadFotoPerfilProprietarioScreen(
                    proprietario: result.proprietario!,
                  ),
                ),
              );
            } else {
              // Já tem foto - verificar se tem múltiplas unidades/condominios
              _redirectProprietario(result);
            }
          } else if (result.userType == UserType.inquilino) {
            // Verificar se inquilino tem foto de perfil
            if (result.inquilino?.fotoPerfil == null ||
                result.inquilino!.fotoPerfil!.isEmpty) {
              // Primeira vez - ir para upload de foto
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => UploadFotoPerfilInquilinoScreen(
                    inquilino: result.inquilino!,
                  ),
                ),
              );
            } else {
              // Já tem foto - verificar se tem múltiplas unidades/condominios
              _redirectInquilino(result);
            }
          } else if (result.userType == UserType.porteiro) {
            // Porteiro vai direto para a tela de Portaria
            _redirectPorteiro(result);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Verifica se o representante tem apenas 1 condomínio e 1 unidade
  /// Se sim, vai direto para a home; senão, vai para o dashboard
  Future<void> _redirectRepresentante(result) async {
    try {
      // Buscar condominios do representante
      final condominios = await SupabaseService.client
          .from('condominios')
          .select('id, nome_condominio, cnpj')
          .eq('representante_id', result.representante!.id);

      if (condominios.isEmpty) {
        // Sem condominios, ir para dashboard (que mostrará erro)
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => RepresentanteDashboardScreen(
                representante: result.representante!,
              ),
            ),
          );
        }
        return;
      }

      // Se tem apenas 1 condomínio
      if (condominios.length == 1) {
        final condominio = condominios[0];

        // Ir direto para a home desse condomínio
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => RepresentanteHomeScreen(
                representante: result.representante!,
                condominioId: condominio['id'],
                condominioNome: condominio['nome_condominio'] ?? 'Condomínio',
                condominioCnpj: condominio['cnpj'] ?? 'N/A',
              ),
            ),
          );
        }
        return;
      }

      // Se tem múltiplos condominios, ir para dashboard
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => RepresentanteDashboardScreen(
              representante: result.representante!,
            ),
          ),
        );
      }
    } catch (e) {
      print('Erro ao verificar condominios: $e');
      // Em caso de erro, ir para dashboard
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => RepresentanteDashboardScreen(
              representante: result.representante!,
            ),
          ),
        );
      }
    }
  }

  /// Verifica se o proprietário tem apenas 1 condomínio e 1 unidade
  /// Se sim, vai direto para a home; senão, vai para o dashboard
  Future<void> _redirectProprietario(result) async {
    try {
      // ✅ MULTI-UNIT: Buscar unidades por CPF (não por ID único)
      final unidades = await SupabaseService.client
          .from('proprietarios')
          .select('id, unidade_id')
          .eq('cpf_cnpj', result.proprietario!.cpfCnpj);

      if (unidades.isEmpty) {
        // Sem unidades, ir para dashboard
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => ProprietarioDashboardScreen(
                proprietario: result.proprietario!,
              ),
            ),
          );
        }
        return;
      }

      // Se tem apenas 1 unidade
      if (unidades.length == 1) {
        final unidadeId = unidades[0]['unidade_id'];

        // Buscar dados da unidade
        final unidadeData = await SupabaseService.client
            .from('unidades')
            .select('id, numero, bloco, condominio_id')
            .eq('id', unidadeId)
            .single();

        // Buscar dados do condomínio
        final condominioData = await SupabaseService.client
            .from('condominios')
            .select('id, nome_condominio, cnpj')
            .eq('id', unidadeData['condominio_id'])
            .single();

        // Ir direto para a home
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => InquilinoHomeScreen(
                condominioId: condominioData['id'],
                condominioNome:
                    condominioData['nome_condominio'] ?? 'Condomínio',
                condominioCnpj: condominioData['cnpj'] ?? 'N/A',
                proprietarioId:
                    unidades[0]['id'], // Usar o ID do registro específico
                unidadeId: unidadeData['id'],
                unidadeNome: 'Unidade ${unidadeData['numero'] ?? 'N/A'}',
                proprietarioData: result.proprietario,
              ),
            ),
          );
        }
        return;
      }

      // Se tem múltiplas unidades, ir para dashboard
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                ProprietarioDashboardScreen(proprietario: result.proprietario!),
          ),
        );
      }
    } catch (e) {
      print('Erro ao verificar unidades: $e');
      // Em caso de erro, ir para dashboard
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                ProprietarioDashboardScreen(proprietario: result.proprietario!),
          ),
        );
      }
    }
  }

  /// Verifica se o inquilino tem apenas 1 condomínio e 1 unidade
  /// Se sim, vai direto para a home; senão, vai para o dashboard
  Future<void> _redirectInquilino(result) async {
    try {
      // Buscar unidades do inquilino
      final unidades = await SupabaseService.client
          .from('inquilinos')
          .select('unidade_id')
          .eq('id', result.inquilino!.id);

      if (unidades.isEmpty) {
        // Sem unidades, ir para dashboard
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) =>
                  InquilinoDashboardScreen(inquilino: result.inquilino!),
            ),
          );
        }
        return;
      }

      // Se tem apenas 1 unidade
      if (unidades.length == 1) {
        final unidadeId = unidades[0]['unidade_id'];

        // Buscar dados da unidade
        final unidadeData = await SupabaseService.client
            .from('unidades')
            .select('id, numero, bloco, condominio_id')
            .eq('id', unidadeId)
            .single();

        // Buscar dados do condomínio
        final condominioData = await SupabaseService.client
            .from('condominios')
            .select('id, nome_condominio, cnpj')
            .eq('id', unidadeData['condominio_id'])
            .single();

        // Ir direto para a home
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => InquilinoHomeScreen(
                condominioId: condominioData['id'],
                condominioNome:
                    condominioData['nome_condominio'] ?? 'Condomínio',
                condominioCnpj: condominioData['cnpj'] ?? 'N/A',
                inquilinoId: result.inquilino!.id,
                unidadeId: unidadeData['id'],
                unidadeNome: 'Unidade ${unidadeData['numero'] ?? 'N/A'}',
              ),
            ),
          );
        }
        return;
      }

      // Se tem múltiplas unidades, ir para dashboard
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                InquilinoDashboardScreen(inquilino: result.inquilino!),
          ),
        );
      }
    } catch (e) {
      print('Erro ao verificar unidades: $e');
      // Em caso de erro, ir para dashboard
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                InquilinoDashboardScreen(inquilino: result.inquilino!),
          ),
        );
      }
    }
  }

  /// Redireciona porteiro diretamente para a tela de Portaria
  Future<void> _redirectPorteiro(LoginResult result) async {
    try {
      // Buscar dados do condomínio do porteiro
      final condominioData = await SupabaseService.client
          .from('condominios')
          .select('id, nome_condominio, cnpj, tem_blocos')
          .eq('id', result.porteiro!.condominioId)
          .single();

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => PortariaRepresentanteScreen(
              condominioId: condominioData['id'],
              condominioNome: condominioData['nome_condominio'] ?? 'Condomínio',
              condominioCnpj: condominioData['cnpj'] ?? 'N/A',
              temBlocos: condominioData['tem_blocos'] ?? true,
            ),
          ),
        );
      }
    } catch (e) {
      print('Erro ao redirecionar porteiro: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar dados do condomínio: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleForgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade em desenvolvimento'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Título
                const Text(
                  'Acesso',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w300,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Campo E-mail
                const Text(
                  'E-mail',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  key: const Key('login_email'),
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
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, digite seu e-mail';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Por favor, digite um e-mail válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Campo Senha
                const Text(
                  'Senha',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  key: const Key('login_password'),
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
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
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
                      return 'Por favor, digite sua senha';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Link Esqueci a senha
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _handleForgotPassword,
                    child: const Text(
                      'Esqueci a senha',
                      style: TextStyle(color: Colors.blue, fontSize: 14),
                    ),
                  ),
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
                      activeColor: Colors.blue,
                    ),
                    const Text(
                      'Login Automático',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Botão Entrar
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    key: const Key('login_submit'),
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
