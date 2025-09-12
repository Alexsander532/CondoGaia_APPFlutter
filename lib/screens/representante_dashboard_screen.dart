import 'dart:convert';
import 'package:condogaiaapp/services/supabase_service.dart';
import 'package:flutter/material.dart';
import '../models/representante.dart';
import '../services/auth_service.dart';
import '../screens/login_screen.dart';
import '../screens/representante_home_screen.dart';

class RepresentanteDashboardScreen extends StatefulWidget {
  final Representante representante;

  const RepresentanteDashboardScreen({
    super.key,
    required this.representante,
  });

  @override
  State<RepresentanteDashboardScreen> createState() => _RepresentanteDashboardScreenState();
}

class _RepresentanteDashboardScreenState extends State<RepresentanteDashboardScreen> {
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> _condominios = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCondominios();
  }

  Future<void> _loadCondominios() async {
    try {
      final condominios = await SupabaseService.getCondominiosByRepresentante(widget.representante.id);
      setState(() {
        _condominios = condominios;
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar condomínios: $e');
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
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
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
    if (widget.representante.temFotoPerfil) {
      try {
        // Remover o prefixo data:image/jpeg;base64, se existir
        String base64String = widget.representante.fotoPerfil!;
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
          backgroundColor: Colors.blue,
          child: Icon(
            Icons.person,
            size: 40,
            color: Colors.white,
          ),
        );
      }
    } else {
      return const CircleAvatar(
        radius: 40,
        backgroundColor: Colors.blue,
        child: Icon(
          Icons.person,
          size: 40,
          color: Colors.white,
        ),
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
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header com informações do representante
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
                      widget.representante.nomeCompleto,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    
                    // CPF
                    Text(
                      'CPF: ${widget.representante.cpfFormatado}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Badge de representante
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Representante',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Seção de condomínios
              const Text(
                'Condomínios',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              
              // Lista de condomínios
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                )
              else if (_condominios.isEmpty)
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
                        Icons.apartment,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum condomínio associado',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              else
                ..._condominios.map(
                  (condominio) => GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RepresentanteHomeScreen(
                            representante: widget.representante,
                            condominioId: condominio['id'],
                            condominioNome: condominio['nome_condominio'] ?? 'Condomínio',
                            condominioCnpj: condominio['cnpj'] ?? 'N/A',
                          ),
                        ),
                      );
                    },
                    child: Container(
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
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.apartment,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  condominio['nome_condominio'] ?? 'Condomínio',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  'CNPJ: ${condominio['cnpj'] ?? 'N/A'}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey[400],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

            ],
          ),
        ),
      ),
    );
  }


}