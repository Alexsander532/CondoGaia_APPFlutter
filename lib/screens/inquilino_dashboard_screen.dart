import 'dart:convert';
import 'package:condogaiaapp/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'inquilino_home_screen.dart';
import '../models/inquilino.dart';
import '../services/auth_service.dart';
import '../services/unidade_detalhes_service.dart';
import '../screens/login_screen.dart';

class InquilinoDashboardScreen extends StatefulWidget {
  final Inquilino inquilino;

  const InquilinoDashboardScreen({super.key, required this.inquilino});

  @override
  State<InquilinoDashboardScreen> createState() =>
      _InquilinoDashboardScreenState();
}

class _InquilinoDashboardScreenState extends State<InquilinoDashboardScreen> {
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
      // DEBUG: Log dos dados do inquilino
      print('=== DEBUG INQUILINO DASHBOARD ===');
      print('Inquilino ID: ${widget.inquilino.id}');
      print('Condominio ID: ${widget.inquilino.condominioId}');
      print('Unidade ID: ${widget.inquilino.unidadeId}');
      print('Nome: ${widget.inquilino.nome}');
      print('==================================');

      // Buscar dados do condomínio
      final condominio = await SupabaseService.getCondominioById(
        widget.inquilino.condominioId,
      );

      // Buscar dados da unidade
      final unidade = await SupabaseService.getUnidadeById(
        widget.inquilino.unidadeId,
      );

      // DEBUG: Log dos dados carregados
      print('=== DEBUG DADOS CARREGADOS ===');
      print('Condominio carregado: $condominio');
      print('Unidade carregada: $unidade');
      print('==============================');

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

  Future<void> _handleDeleteAccount() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Excluir Conta'),
          content: const Text('Tem certeza que deseja excluir sua conta? Esta ação é irreversível!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  final service = UnidadeDetalhesService();
                  
                  // Deletar o inquilino
                  print('🗑️ Deletando inquilino: ${widget.inquilino.id}');
                  await service.deletarInquilino(inquilinoId: widget.inquilino.id);
                  print('✅ Inquilino deletado com sucesso!');
                  
                  // Fazer logout
                  print('🚪 Realizando logout...');
                  await _authService.logout();
                  print('✅ Logout realizado!');
                  
                  // Navegar para login (SEM usar ScaffoldMessenger pois a tela foi destruída)
                  if (mounted) {
                    print('🔄 Navegando para login...');
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(usuarioDeletado: 'Inquilino'),
                      ),
                      (route) => false,
                    );
                  }
                } catch (e) {
                  print('❌ ERRO ao excluir conta: $e');
                  // NÃO mostrar snackbar aqui pois a tela já foi destruída
                }
              },
              child: const Text('Excluir', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }


  Widget _buildProfileImage() {
    if (widget.inquilino.temFotoPerfil) {
      try {
        final fotoUrl = widget.inquilino.fotoPerfil!;
        
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
                  backgroundColor: Colors.purple,
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
          backgroundColor: Colors.purple,
          child: Icon(Icons.person, size: 40, color: Colors.white),
        );
      }
    } else {
      return const CircleAvatar(
        radius: 40,
        backgroundColor: Colors.purple,
        child: Icon(Icons.person, size: 40, color: Colors.white),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                onTap: _handleLogout,
                child: const Row(
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 12),
                    Text('Sair'),
                  ],
                ),
              ),
              PopupMenuItem(
                onTap: _handleDeleteAccount,
                child: const Row(
                  children: [
                    Icon(Icons.delete_outline, size: 20, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Excluir Conta', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header com informações do inquilino
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
                      widget.inquilino.nome,
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
                      '${widget.inquilino.isPessoaFisica ? 'CPF' : 'CNPJ'}: ${widget.inquilino.cpfCnpjFormatado}',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),

                    // Badge de inquilino
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Inquilino',
                        style: TextStyle(
                          color: Colors.purple,
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
                'Minha Residência',
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
                                  color: Colors.purple.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.apartment,
                                  color: Colors.purple,
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
                                    inquilinoId: widget.inquilino.id,
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
                                      Icons.home,
                                      color: Colors.orange,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
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
                                      if (_condominio != null && (_condominio!['tem_blocos'] ?? true))
                                        Text(
                                          'Bloco: ${_unidade!['bloco'] ?? 'N/A'}',
                                          style: TextStyle(
                                            fontSize: 13,
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
                                    const Icon(Icons.chevron_right, color: Colors.grey),
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
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 32,
                      color: Colors.purple[700],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Dashboard do Inquilino',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.purple[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Aqui você pode visualizar sua unidade',
                      style: TextStyle(fontSize: 14, color: Colors.purple[600]),
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
