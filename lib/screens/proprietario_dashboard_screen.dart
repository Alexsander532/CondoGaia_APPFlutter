import 'dart:convert';
import 'package:condogaiaapp/services/supabase_service.dart';
import 'package:flutter/material.dart';
import '../models/proprietario.dart';
import '../services/auth_service.dart';
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

  // ✅ MULTI-UNIT: Lista de todas as unidades do proprietário
  List<Map<String, dynamic>> _todasUnidades = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodasUnidades();
  }

  /// ✅ MULTI-UNIT: Carrega TODAS as unidades do proprietário pelo CPF
  Future<void> _loadTodasUnidades() async {
    try {
      print(
        '🔵 Buscando todas as unidades para CPF: ${widget.proprietario.cpfCnpj}',
      );

      // Buscar todos os registros de proprietário com este CPF
      final registros = await SupabaseService.client
          .from('proprietarios')
          .select('id, unidade_id, condominio_id')
          .eq('cpf_cnpj', widget.proprietario.cpfCnpj);

      print('🔵 Encontrados ${registros.length} registros');

      List<Map<String, dynamic>> unidadesCompletas = [];

      for (var registro in registros) {
        try {
          // Buscar dados da unidade
          final unidade = await SupabaseService.client
              .from('unidades')
              .select('id, numero, bloco')
              .eq('id', registro['unidade_id'])
              .maybeSingle();

          // Buscar dados do condomínio
          final condominio = await SupabaseService.client
              .from('condominios')
              .select('id, nome_condominio, cnpj, tem_blocos')
              .eq('id', registro['condominio_id'])
              .maybeSingle();

          if (unidade != null && condominio != null) {
            unidadesCompletas.add({
              'proprietario_id': registro['id'],
              'unidade_id': unidade['id'],
              'unidade_numero': unidade['numero'] ?? 'N/A',
              'bloco': unidade['bloco'],
              'condominio_id': condominio['id'],
              'condominio_nome': condominio['nome_condominio'] ?? 'Condomínio',
              'condominio_cnpj': condominio['cnpj'] ?? 'N/A',
              'tem_blocos': condominio['tem_blocos'] ?? true,
            });
          }
        } catch (e) {
          print('⚠️ Erro ao carregar unidade: $e');
        }
      }

      setState(() {
        _todasUnidades = unidadesCompletas;
        _isLoading = false;
      });

      print('✅ Carregadas ${_todasUnidades.length} unidades');
    } catch (e) {
      print('❌ Erro ao carregar unidades: $e');
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

        if (fotoUrl.startsWith('http')) {
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

  /// ✅ MULTI-UNIT: Constrói card de uma unidade
  Widget _buildUnidadeCard(Map<String, dynamic> unidadeInfo) {
    final temBlocos = unidadeInfo['tem_blocos'] ?? true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InquilinoHomeScreen(
                  condominioId: unidadeInfo['condominio_id'].toString(),
                  condominioNome: unidadeInfo['condominio_nome'],
                  condominioCnpj: unidadeInfo['condominio_cnpj'],
                  proprietarioId: unidadeInfo['proprietario_id'].toString(),
                  unidadeId: unidadeInfo['unidade_id'].toString(),
                  unidadeNome:
                      '${(temBlocos && unidadeInfo['bloco'] != null) ? "Bloco ${unidadeInfo['bloco']} - " : ""}Unidade ${unidadeInfo['unidade_numero']}',
                  proprietarioData: widget.proprietario,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Ícone da unidade
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.home_mini, color: Colors.orange),
                ),
                const SizedBox(width: 16),

                // Informações da unidade
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Unidade ${unidadeInfo['unidade_numero']}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (temBlocos && unidadeInfo['bloco'] != null)
                        Text(
                          'Bloco: ${unidadeInfo['bloco']}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      Text(
                        unidadeInfo['condominio_nome'],
                        style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),

                // Seta para entrar
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Entrar',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.green[600],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.green[600],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
                    _buildProfileImage(),
                    const SizedBox(height: 16),

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

                    Text(
                      '${widget.proprietario.isPessoaFisica ? 'CPF' : 'CNPJ'}: ${widget.proprietario.cpfCnpjFormatado}',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),

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

              // ✅ MULTI-UNIT: Título com contagem de unidades
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Minhas Propriedades',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  if (!_isLoading)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_todasUnidades.length} ${_todasUnidades.length == 1 ? 'unidade' : 'unidades'}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.green[700],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // ✅ MULTI-UNIT: Lista de unidades
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_todasUnidades.isEmpty)
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
                        Icons.home_work_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhuma unidade encontrada',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: _todasUnidades
                      .map((unidade) => _buildUnidadeCard(unidade))
                      .toList(),
                ),

              const SizedBox(height: 32),

              // Info box
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
                      'Selecione uma unidade para acessar suas funcionalidades',
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
