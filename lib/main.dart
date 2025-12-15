import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/ADMIN/home_screen.dart';
import 'screens/representante_dashboard_screen.dart';
import 'screens/representante_home_screen.dart';
import 'screens/proprietario_dashboard_screen.dart';
import 'screens/inquilino_dashboard_screen.dart';
import 'screens/inquilino_home_screen.dart';
import 'screens/upload_foto_perfil_screen.dart';
import 'screens/upload_foto_perfil_proprietario_screen.dart';
import 'screens/upload_foto_perfil_inquilino_screen.dart';
import 'screens/portaria_representante_screen.dart';
import 'screens/portaria_inquilino_screen.dart';
import 'screens/gestao_screen.dart';
import 'screens/documentos_screen.dart';
import 'screens/reservas_screen.dart';
import 'screens/conversas_list_screen.dart';
import 'services/auth_service.dart';
import 'services/supabase_service.dart';
import 'services/navigation_persistence_service.dart';

// Credenciais Supabase - carregadas dinamicamente
class _SupabaseConfig {
  static const String supabaseUrl = 'https://tukpgefrddfchmvtiujp.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR1a3BnZWZyZGRmY2htdnRpdWpwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI1MTg1NTEsImV4cCI6MjA2ODA5NDU1MX0.dZ1Pna1_dwelIJTlhrSN0iiH5nhuzL0y4p6llYJsLp8';
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  String supabaseUrl = _SupabaseConfig.supabaseUrl;
  String supabaseAnonKey = _SupabaseConfig.supabaseAnonKey;
  
  // Tentar carregar variáveis de ambiente do arquivo .env (funciona em mobile)
  try {
    await dotenv.load();
    debugPrint('[MAIN] ✅ Arquivo .env carregado com sucesso');
    
    // Tentar obter credenciais do .env
    final envUrl = dotenv.env['SUPABASE_URL'];
    final envKey = dotenv.env['SUPABASE_ANON_KEY'];
    
    if (envUrl != null && envUrl.isNotEmpty) {
      supabaseUrl = envUrl;
      debugPrint('[MAIN] Usando SUPABASE_URL do .env');
    }
    
    if (envKey != null && envKey.isNotEmpty) {
      supabaseAnonKey = envKey;
      debugPrint('[MAIN] Usando SUPABASE_ANON_KEY do .env');
    }
  } catch (e) {
    // Em web, .env não está disponível - usar credenciais hardcoded
    debugPrint('[MAIN] ⚠️ Não foi possível carregar .env: $e');
    debugPrint('[MAIN] ✅ Usando credenciais hardcoded padrão');
  }
  
  debugPrint('[MAIN] Inicializando Supabase...');
  debugPrint('[MAIN] URL: $supabaseUrl');
  
  // Inicializar Supabase com credenciais
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  
  debugPrint('[MAIN] ✅ Supabase inicializado com sucesso');
  
  runApp(const CondoGaiaApp());
}

class CondoGaiaApp extends StatelessWidget {
  const CondoGaiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CondoGaia',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Aguardar um pouco para mostrar a splash screen
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    // Verificar se o usuário está logado e se o login automático está habilitado
    final isLoggedIn = await _authService.isLoggedIn();
    final isAutoLoginEnabled = await _authService.isAutoLoginEnabled();
    
    if (isLoggedIn && isAutoLoginEnabled) {
      // Tentar login automático
      final result = await _authService.tryAutoLogin();
      
      if (mounted) {
        if (result.success) {
          // Verificar se há uma rota salva para restaurar
          if (NavigationPersistenceService.hasSavedRoute()) {
            await _restorePreviousRoute(result);
          } else {
            // Redirecionar conforme o tipo de usuário
            await _redirectByUserType(result);
          }
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      }
    } else {
      // Ir para tela de login
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  /// Restaura a rota anterior antes do refresh
  Future<void> _restorePreviousRoute(LoginResult result) async {
    if (!mounted) return;

    final savedRoute = NavigationPersistenceService.getSavedRoute();
    final savedParams = NavigationPersistenceService.getSavedParams();

    debugPrint('[Main] 🔄 Tentando restaurar rota: $savedRoute');

    // ===== REPRESENTANTE =====
    if (savedRoute == 'portaria_representante') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => PortariaRepresentanteScreen(
            condominioId: savedParams['condominioId'],
            condominioNome: savedParams['condominioNome'],
            condominioCnpj: savedParams['condominioCnpj'],
            representanteId: savedParams['representanteId'],
            temBlocos: savedParams['temBlocos'] ?? false,
          ),
        ),
      );
    } else if (savedRoute == 'representante_home') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => RepresentanteHomeScreen(
            representante: result.representante!,
            condominioId: savedParams['condominioId'],
            condominioNome: savedParams['condominioNome'],
            condominioCnpj: savedParams['condominioCnpj'],
          ),
        ),
      );
    } else if (savedRoute == 'gestao') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => GestaoScreen(
            condominioId: savedParams['condominioId'],
            condominioNome: savedParams['condominioNome'],
            condominioCnpj: savedParams['condominioCnpj'],
          ),
        ),
      );
    } else if (savedRoute == 'documentos') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => DocumentosScreen(
            condominioId: savedParams['condominioId'],
            representanteId: savedParams['representanteId'],
          ),
        ),
      );
    } else if (savedRoute == 'reservas') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ReservasScreen(
            representante: result.representante,
            condominioId: savedParams['condominioId'],
          ),
        ),
      );
    } else if (savedRoute == 'conversas_list') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ConversasListScreen(
            condominioId: savedParams['condominioId'] ?? '',
            representanteId: savedParams['representanteId'] ?? '',
            representanteName: savedParams['representanteName'] ?? '',
          ),
        ),
      );
    }
    // ===== PROPRIETÁRIO =====
    else if (savedRoute == 'proprietario_dashboard') {
      if (result.proprietario != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ProprietarioDashboardScreen(
              proprietario: result.proprietario!,
            ),
          ),
        );
      }
    }
    // ===== INQUILINO =====
    else if (savedRoute == 'inquilino_dashboard') {
      if (result.inquilino != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => InquilinoDashboardScreen(
              inquilino: result.inquilino!,
            ),
          ),
        );
      }
    } else if (savedRoute == 'inquilino_home') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => InquilinoHomeScreen(
            condominioId: savedParams['condominioId'] ?? '',
            condominioNome: savedParams['condominioNome'] ?? '',
            condominioCnpj: savedParams['condominioCnpj'] ?? '',
            inquilinoId: savedParams['inquilinoId'],
            proprietarioId: savedParams['proprietarioId'],
            unidadeId: savedParams['unidadeId'] ?? '',
            unidadeNome: savedParams['unidadeNome'] ?? '',
          ),
        ),
      );
    } else if (savedRoute == 'portaria_inquilino') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => PortariaInquilinoScreen(
            condominioId: savedParams['condominioId'],
            condominioNome: savedParams['condominioNome'],
            condominioCnpj: savedParams['condominioCnpj'],
            inquilinoId: savedParams['inquilinoId'],
            proprietarioId: savedParams['proprietarioId'],
            unidadeId: savedParams['unidadeId'],
          ),
        ),
      );
    } else {
      // Se a rota não for reconhecida, limpar e ir para redirecionamento padrão
      NavigationPersistenceService.clearSavedRoute();
      await _redirectByUserType(result);
    }
  }

  /// Redireciona o usuário para a tela correta baseado no tipo de usuário
  Future<void> _redirectByUserType(LoginResult result) async {
    if (!mounted) return;

    if (result.userType == UserType.administrator) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else if (result.userType == UserType.representante) {
      // Verificar se representante tem foto de perfil
      if (result.representante?.fotoPerfil == null || result.representante!.fotoPerfil!.isEmpty) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => UploadFotoPerfilScreen(representante: result.representante!)),
        );
      } else {
        await _redirectRepresentante(result);
      }
    } else if (result.userType == UserType.proprietario) {
      // Verificar se proprietário tem foto de perfil
      if (result.proprietario?.fotoPerfil == null || result.proprietario!.fotoPerfil!.isEmpty) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => UploadFotoPerfilProprietarioScreen(proprietario: result.proprietario!)),
        );
      } else {
        await _redirectProprietario(result);
      }
    } else if (result.userType == UserType.inquilino) {
      // Verificar se inquilino tem foto de perfil
      if (result.inquilino?.fotoPerfil == null || result.inquilino!.fotoPerfil!.isEmpty) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => UploadFotoPerfilInquilinoScreen(inquilino: result.inquilino!)),
        );
      } else {
        await _redirectInquilino(result);
      }
    } else {
      // Tipo desconhecido - ir para login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  /// Verifica se o representante tem apenas 1 condomínio
  /// Se sim, vai direto para a home; senão, vai para o dashboard
  Future<void> _redirectRepresentante(LoginResult result) async {
    try {
      final condominios = await SupabaseService.client
          .from('condominios')
          .select('id, nome_condominio, cnpj')
          .eq('representante_id', result.representante!.id);
      
      if (condominios.isEmpty || condominios.length > 1) {
        // Sem condominios ou múltiplos - ir para dashboard
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => RepresentanteDashboardScreen(
              representante: result.representante!,
            )),
          );
        }
        return;
      }
      
      // Se tem apenas 1 condomínio - ir direto para home
      final condominio = condominios[0];
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => RepresentanteHomeScreen(
            representante: result.representante!,
            condominioId: condominio['id'],
            condominioNome: condominio['nome_condominio'] ?? 'Condomínio',
            condominioCnpj: condominio['cnpj'] ?? 'N/A',
          )),
        );
      }
    } catch (e) {
      print('Erro ao verificar condominios: $e');
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => RepresentanteDashboardScreen(
            representante: result.representante!,
          )),
        );
      }
    }
  }

  /// Verifica se o proprietário tem apenas 1 unidade
  /// Se sim, vai direto para a home; senão, vai para o dashboard
  Future<void> _redirectProprietario(LoginResult result) async {
    try {
      final unidades = await SupabaseService.client
          .from('proprietarios')
          .select('unidade_id')
          .eq('id', result.proprietario!.id);
      
      if (unidades.isEmpty || unidades.length > 1) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => ProprietarioDashboardScreen(
              proprietario: result.proprietario!,
            )),
          );
        }
        return;
      }
      
      // Se tem apenas 1 unidade
      final unidadeId = unidades[0]['unidade_id'];
      final unidadeData = await SupabaseService.client
          .from('unidades')
          .select('id, numero, bloco, condominio_id')
          .eq('id', unidadeId)
          .single();
      
      final condominioData = await SupabaseService.client
          .from('condominios')
          .select('id, nome_condominio, cnpj')
          .eq('id', unidadeData['condominio_id'])
          .single();
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => InquilinoHomeScreen(
            condominioId: condominioData['id'],
            condominioNome: condominioData['nome_condominio'] ?? 'Condomínio',
            condominioCnpj: condominioData['cnpj'] ?? 'N/A',
            proprietarioId: result.proprietario!.id,
            unidadeId: unidadeData['id'],
            unidadeNome: 'Unidade ${unidadeData['numero'] ?? 'N/A'}',
            proprietarioData: result.proprietario,
          )),
        );
      }
    } catch (e) {
      print('Erro ao verificar unidades do proprietário: $e');
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => ProprietarioDashboardScreen(
            proprietario: result.proprietario!,
          )),
        );
      }
    }
  }

  /// Verifica se o inquilino tem apenas 1 unidade
  /// Se sim, vai direto para a home; senão, vai para o dashboard
  Future<void> _redirectInquilino(LoginResult result) async {
    try {
      final unidades = await SupabaseService.client
          .from('inquilinos')
          .select('unidade_id')
          .eq('id', result.inquilino!.id);
      
      if (unidades.isEmpty || unidades.length > 1) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => InquilinoDashboardScreen(
              inquilino: result.inquilino!,
            )),
          );
        }
        return;
      }
      
      // Se tem apenas 1 unidade
      final unidadeId = unidades[0]['unidade_id'];
      final unidadeData = await SupabaseService.client
          .from('unidades')
          .select('id, numero, bloco, condominio_id')
          .eq('id', unidadeId)
          .single();
      
      final condominioData = await SupabaseService.client
          .from('condominios')
          .select('id, nome_condominio, cnpj')
          .eq('id', unidadeData['condominio_id'])
          .single();
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => InquilinoHomeScreen(
            condominioId: condominioData['id'],
            condominioNome: condominioData['nome_condominio'] ?? 'Condomínio',
            condominioCnpj: condominioData['cnpj'] ?? 'N/A',
            inquilinoId: result.inquilino!.id,
            unidadeId: unidadeData['id'],
            unidadeNome: 'Unidade ${unidadeData['numero'] ?? 'N/A'}',
          )),
        );
      }
    } catch (e) {
      print('Erro ao verificar unidades do inquilino: $e');
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => InquilinoDashboardScreen(
            inquilino: result.inquilino!,
          )),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo ou ícone do app
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.home,
                size: 60,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 32),
            
            // Nome do app
            const Text(
              'CondoGaia',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            
            // Subtítulo
            const Text(
              'Sistema de Gestão Condominial',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 48),
            
            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
