import 'dart:convert';
import 'package:condogaiaapp/services/supabase_service.dart';
import 'package:flutter/material.dart';
import '../models/proprietario.dart';
import '../services/auth_service.dart';
import '../services/navigation_persistence_service.dart';
import '../screens/login_screen.dart';
import '../screens/inquilino_home_screen.dart';

class ProprietarioDashboardScreen extends StatefulWidget {
  final Proprietario proprietario;

  const ProprietarioDashboardScreen({super.key, required this.proprietario});

  @override
  State<ProprietarioDashboardScreen> createState() =>
      _ProprietarioDashboardScreenState();
}

class _ProprietarioDashboardScreenState
    extends State<ProprietarioDashboardScreen> {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _condominio;
  Map<String, dynamic>? _unidade;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCondominioAndUnidade();
  }

  Future<void> _loadCondominioAndUnidade() async {
    try {
      // Buscar dados do condomínio
      final condominio = await SupabaseService.getCondominioById(
        widget.proprietario.condominioId,
      );

      // Buscar dados da unidade
      final unidade = await SupabaseService.getUnidadeById(
        widget.proprietario.unidadeId!,
      );

      print('🔵 Unidade carregada: $unidade');

      setState(() {
        _condominio = condominio;
        _unidade = unidade;
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar dados: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sair'),
          content: const Text('Deseja realmente sair da sua conta?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _authService.logout();
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                }
              },
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileImage() {
    if (widget.proprietario.temFotoPerfil) {
      try {
        final fotoUrl = widget.proprietario.fotoPerfil!;
        
        // Verificar se é URL (começa com http) ou Base64
        if (fotoUrl.startsWith('http')) {
          // É URL do Storage - usar Image.network
          return ClipOval(
            child: Image.network(
              fotoUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.green,
                  child: Icon(Icons.person, size: 40, color: Colors.white),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                );
              },
            ),
          );
        } else {
          // É Base64 - decodificar e usar Image.memory
          String base64String = fotoUrl;
          if (base64String.startsWith('data:image')) {
            base64String = base64String.split(',')[1];
          }

          return ClipOval(
            child: Image.memory(
              base64Decode(base64String),
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          );
        }
      } catch (e) {
        // Se houver erro ao decodificar, mostrar ícone padrão
        return const CircleAvatar(
          radius: 40,
          backgroundColor: Colors.green,
          child: Icon(Icons.person, size: 40, color: Colors.white),
        );
      }
    } else {
      return const CircleAvatar(
        radius: 40,
        backgroundColor: Colors.green,
        child: Icon(Icons.person, size: 40, color: Colors.white),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Salvar navegação atual para persistir em caso de refresh na web
    NavigationPersistenceService.saveCurrentRoute('proprietario_dashboard', {
      'proprietarioId': widget.proprietario.id,
    });
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _handleLogout),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header com informações do proprietário
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Foto de perfil
                    _buildProfileImage(),
                    const SizedBox(height: 16),

                    // Nome
                    Text(
                      widget.proprietario.nome,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // CPF/CNPJ
                    Text(
                      '${widget.proprietario.isPessoaFisica ? 'CPF' : 'CNPJ'}: ${widget.proprietario.cpfCnpjFormatado}',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),

                    // Badge de proprietário
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Proprietário',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Seção de condomínio e unidade
              const Text(
                'Minha Propriedade',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // Informações do condomínio e unidade
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_condominio == null || _unidade == null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Erro ao carregar informações',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: [
                    // Card do condomínio COM unidade aninhada
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Cabeçalho do condomínio
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.apartment,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _condominio!['nome_condominio'] ??
                                          'Condomínio',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      'CNPJ: ${_condominio!['cnpj'] ?? 'N/A'}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Divisor
                          Container(
                            height: 1,
                            color: Colors.grey[200],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Unidade dentro do condomínio
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => InquilinoHomeScreen(
                                    condominioId: _condominio!['id'].toString(),
                                    condominioNome:
                                        _condominio!['nome_condominio'] ??
                                        'Condomínio',
                                    condominioCnpj: _condominio!['cnpj'] ?? 'N/A',
                                    proprietarioId: widget.proprietario.id,
                                    unidadeId: _unidade!['id'].toString(),
                                    unidadeNome:
                                        'Unidade ${_unidade!['numero_unidade'] ?? _unidade!['numero'] ?? _unidade!['unidade'] ?? 'N/A'}',
                                  ),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 16),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.home_mini,
                                      color: Colors.orange,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Unidade ${_unidade!['numero_unidade'] ?? _unidade!['numero'] ?? _unidade!['unidade'] ?? 'N/A'}',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      // Mostrar bloco apenas se temBlocos = true
                                      if (_condominio != null && (_condominio!['tem_blocos'] ?? true) == true)
                                        Text(
                                          'Bloco: ${_unidade!['bloco'] ?? 'N/A'}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Entrar',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 32),

              // Informações adicionais ou ações futuras podem ser adicionadas aqui
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 32,
                      color: Colors.green[700],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Dashboard do Proprietário',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.green[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Aqui você pode visualizar suas propriedades',
                      style: TextStyle(fontSize: 14, color: Colors.green[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
