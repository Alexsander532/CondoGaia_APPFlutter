import 'package:flutter/material.dart';
import '../models/representante.dart';
import '../services/supabase_service.dart';
import 'chat_representante_screen.dart';

class ContatosChatRepresentanteScreen extends StatefulWidget {
  final Representante representante;
  final String condominioId;
  final String condominioNome;

  const ContatosChatRepresentanteScreen({
    super.key,
    required this.representante,
    required this.condominioId,
    required this.condominioNome,
  });

  @override
  State<ContatosChatRepresentanteScreen> createState() => _ContatosChatRepresentanteScreenState();
}

class _ContatosChatRepresentanteScreenState extends State<ContatosChatRepresentanteScreen> {
  List<Map<String, dynamic>> _contatos = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadContatos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContatos() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Buscar proprietários do condomínio
      final proprietarios = await _buscarProprietarios();
      
      // Buscar inquilinos do condomínio
      final inquilinos = await _buscarInquilinos();

      // Combinar e ordenar os contatos
      final contatos = <Map<String, dynamic>>[];
      contatos.addAll(proprietarios);
      contatos.addAll(inquilinos);
      
      // Ordenar por nome
      contatos.sort((a, b) => a['nome'].toString().compareTo(b['nome'].toString()));

      setState(() {
        _contatos = contatos;
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar contatos: $e');
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar contatos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<List<Map<String, dynamic>>> _buscarProprietarios() async {
    try {
      final response = await SupabaseService.client
          .from('proprietarios')
          .select('''
            id,
            nome,
            email,
            celular,
            unidade_id,
            unidades!inner(
              id,
              numero_unidade,
              bloco,
              identificacao
            )
          ''')
          .eq('condominio_id', widget.condominioId)
          .eq('ativo', true);

      return (response as List).map((item) {
        final unidade = item['unidades'];
        return {
          'id': item['id'],
          'nome': item['nome'] ?? 'Nome não informado',
          'email': item['email'] ?? '',
          'celular': item['celular'] ?? '',
          'tipo': 'proprietario',
          'tipoLabel': '(P)',
          'unidade': unidade != null 
              ? 'Bloco ${unidade['bloco'] ?? 'N/A'} - Unidade ${unidade['numero_unidade'] ?? 'N/A'}'
              : 'Unidade não informada',
          'unidadeId': item['unidade_id'],
        };
      }).toList();
    } catch (e) {
      print('Erro ao buscar proprietários: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _buscarInquilinos() async {
    try {
      final response = await SupabaseService.client
          .from('inquilinos')
          .select('''
            id,
            nome,
            email,
            celular,
            unidade_id,
            unidades!inner(
              id,
              numero_unidade,
              bloco,
              identificacao
            )
          ''')
          .eq('condominio_id', widget.condominioId)
          .eq('ativo', true);

      return (response as List).map((item) {
        final unidade = item['unidades'];
        return {
          'id': item['id'],
          'nome': item['nome'] ?? 'Nome não informado',
          'email': item['email'] ?? '',
          'celular': item['celular'] ?? '',
          'tipo': 'inquilino',
          'tipoLabel': '(I)',
          'unidade': unidade != null 
              ? 'Bloco ${unidade['bloco'] ?? 'N/A'} - Unidade ${unidade['numero_unidade'] ?? 'N/A'}'
              : 'Unidade não informada',
          'unidadeId': item['unidade_id'],
        };
      }).toList();
    } catch (e) {
      print('Erro ao buscar inquilinos: $e');
      return [];
    }
  }

  List<Map<String, dynamic>> get _contatosFiltrados {
    if (_searchQuery.isEmpty) {
      return _contatos;
    }
    
    return _contatos.where((contato) {
      final nome = contato['nome'].toString().toLowerCase();
      final unidade = contato['unidade'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      
      return nome.contains(query) || unidade.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contatos',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              widget.condominioNome,
              style: const TextStyle(
                color: Color(0xFF7F8C8D),
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Campo de busca
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Buscar contatos...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF7F8C8D)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Color(0xFF7F8C8D)),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2E7D32)),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ),
          
          // Lista de contatos
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _contatosFiltrados.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'Nenhum contato encontrado'
                                  : 'Nenhum contato disponível',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadContatos,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _contatosFiltrados.length,
                          itemBuilder: (context, index) {
                            final contato = _contatosFiltrados[index];
                            return _buildContatoCard(contato);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildContatoCard(Map<String, dynamic> contato) {
    final isProprietario = contato['tipo'] == 'proprietario';
    final corTipo = isProprietario ? Colors.blue : Colors.orange;
    
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
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: corTipo.withOpacity(0.1),
          child: Text(
            contato['nome'].toString().isNotEmpty 
                ? contato['nome'].toString()[0].toUpperCase()
                : '?',
            style: TextStyle(
              color: corTipo,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                contato['nome'],
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: corTipo.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                contato['tipoLabel'],
                style: TextStyle(
                  color: corTipo,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              contato['unidade'],
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            if (contato['celular'].toString().isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                contato['celular'],
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
        trailing: const Icon(
          Icons.chat_bubble_outline,
          color: Color(0xFF2E7D32),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatRepresentanteScreen(
                nomeContato: contato['nome'],
                apartamento: contato['unidade'],
              ),
            ),
          );
        },
      ),
    );
  }
}