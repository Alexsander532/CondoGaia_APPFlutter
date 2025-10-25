import 'dart:convert';
import 'package:condogaiaapp/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'inquilino_home_screen.dart';
import '../models/inquilino.dart';
import '../services/auth_service.dart';
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

  Widget _buildProfileImage() {
    if (widget.inquilino.temFotoPerfil) {
      try {
        // Remover o prefixo data:image/jpeg;base64, se existir
        String base64String = widget.inquilino.fotoPerfil!;
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
          IconButton(icon: const Icon(Icons.logout), onPressed: _handleLogout),
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
                    // Card do condomínio
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
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
                      child: Row(
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
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  'CNPJ: ${_condominio!['cnpj'] ?? 'N/A'}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Card da unidade
                    GestureDetector(
                      onTap: () {
                        // Navegar para a tela home do inquilino
                        // DEBUG: Log dos dados antes da navegação
                        print('=== DEBUG NAVEGAÇÃO PARA HOME ===');
                        print('Condominio ID: ${_condominio!['id']}');
                        print('Unidade ID: ${_unidade!['id']}');
                        print('Inquilino ID: ${widget.inquilino.id}');
                        print('=====================================');

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
                                  'Unidade ${_unidade!['numero_unidade'] ?? 'N/A'}',
                            ),
                          ),
                        );
                      },
                      child: Container(
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
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.home,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Unidade ${_unidade!['numero_unidade'] ?? 'N/A'}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    'Bloco: ${_unidade!['bloco'] ?? 'N/A'}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Ícone indicando que é clicável
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey[400],
                            ),
                          ],
                        ),
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
