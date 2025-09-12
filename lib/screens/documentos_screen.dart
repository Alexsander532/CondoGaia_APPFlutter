import 'package:flutter/material.dart';
import 'editar_documentos_screen.dart';
import 'nova_pasta_screen.dart';

class DocumentosScreen extends StatefulWidget {
  const DocumentosScreen({super.key});

  @override
  State<DocumentosScreen> createState() => _DocumentosScreenState();
}

class _DocumentosScreenState extends State<DocumentosScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> pastas = [
    'Atas',
    'Convenção',
    'Regimento Interno',
  ];
  
  final List<String> arquivosBalancete = [
    'Intimacao 28-8-22.pdf',
    'Parecer adv. 28-8-21.pdf',
    'Parecer Juiz 28-8-20.pdf',
  ];
  
  String selectedMonth = 'Janeiro';
  String selectedYear = '2024';
  String selectedPrivacy = 'Público';
  final TextEditingController _linkController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Widget _buildPastaItem(String nome) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              nome,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditarDocumentosScreen(nomePasta: nome),
                ),
              );
            },
            child: const Icon(
              Icons.edit,
              color: Colors.grey,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Cabeçalho superior padronizado
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Botão de voltar
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 24),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Spacer(),
                  // Logo CondoGaia
                  Image.asset(
                    'assets/images/logo_CondoGaia.png',
                    height: 32,
                  ),
                  const Spacer(),
                  // Ícones do lado direito
                  Row(
                    children: [
                      // Ícone de notificação
                      GestureDetector(
                        onTap: () {
                          // TODO: Implementar notificações
                        },
                        child: Image.asset(
                          'assets/images/Sino_Notificacao.png',
                          width: 24,
                          height: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Ícone de fone de ouvido
                      GestureDetector(
                        onTap: () {
                          // TODO: Implementar suporte/ajuda
                        },
                        child: Image.asset(
                          'assets/images/Fone_Ouvido_Cabecalho.png',
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Linha de separação
            Container(
              height: 1,
              color: Colors.grey[300],
            ),
            
            // Título da página dinâmico
            AnimatedBuilder(
              animation: _tabController,
              builder: (context, child) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    _tabController.index == 0 ? 'Home/Documentos' : 'Home/Anexar Balancete',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
            
            // TabBar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: TabBar(
                controller: _tabController,
                labelColor: const Color(0xFF1E3A8A),
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: const Color(0xFF1E3A8A),
                indicatorWeight: 3,
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                tabs: const [
                  Tab(text: 'Pastas de Documento'),
                  Tab(text: 'Anexo Balancete'),
                ],
              ),
            ),
            
            // Conteúdo das abas
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDocumentosTab(),
                  _buildBalanceteTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDocumentosTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          // Lista de pastas
          Expanded(
            child: ListView(
              children: [
                ...pastas.map((pasta) => _buildPastaItem(pasta)),
                const SizedBox(height: 20),
        
                // Botão Adicionar Nova Pasta
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NovaPastaScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.blue,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Adicionar',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Text(
                          'Nova Pasta',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBalanceteTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // Título da seção
            const Text(
              'Anexo Balancete',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E3A8A),
              ),
            ),
          const SizedBox(height: 20),
          
          // Seletor de Mês/Ano
          Row(
            children: [
              IconButton(
                onPressed: () {
                  // TODO: Implementar navegação de mês anterior
                },
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Text(
                  'Mês/Ano',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  // TODO: Implementar navegação de próximo mês
                },
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Privacidade
          Row(
            children: [
              const Text(
                'Privacidade:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 20),
              Row(
                children: [
                  Radio<String>(
                    value: 'Público',
                    groupValue: selectedPrivacy,
                    onChanged: (value) {
                      setState(() {
                        selectedPrivacy = value!;
                      });
                    },
                  ),
                  const Text('Público'),
                  const SizedBox(width: 20),
                  Radio<String>(
                    value: 'Privado',
                    groupValue: selectedPrivacy,
                    onChanged: (value) {
                      setState(() {
                        selectedPrivacy = value!;
                      });
                    },
                  ),
                  const Text('Privado'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),
          
          // Adicionar Arquivos
          const Text(
            'Adicionar Arquivos',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 15),
          
          // Campo Link
          TextField(
            controller: _linkController,
            decoration: InputDecoration(
              labelText: 'Link:',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Botões de ação
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      // TODO: Implementar tirar foto
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tirar foto em desenvolvimento')),
                      );
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        size: 30,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tirar foto',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      // TODO: Implementar upload PDF
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Upload PDF em desenvolvimento')),
                      );
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: const Icon(
                        Icons.upload_file_outlined,
                        size: 30,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Fazer Upload PDF',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),
          
          // Botão Adicionar arquivo
          Center(
            child: ElevatedButton(
              onPressed: () {
                // TODO: Implementar adicionar arquivo
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Adicionar arquivo em desenvolvimento')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Adicionar arquivo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          
          // Lista de Arquivos
          const Text(
            'Arquivos',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 15),
          
          ...arquivosBalancete.map((arquivo) {
            int index = arquivosBalancete.indexOf(arquivo);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      arquivo,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // TODO: Implementar deletar arquivo
                      setState(() {
                        arquivosBalancete.removeAt(index);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Arquivo removido')),
                      );
                    },
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          ],
        ),
      ),
    );
  }
}