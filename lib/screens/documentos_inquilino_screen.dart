import 'package:flutter/material.dart';
import 'pasta_arquivos_screen.dart';
import '../models/documento.dart';
import '../services/documento_service.dart';

class DocumentosInquilinoScreen extends StatefulWidget {
  final String? condominioId;
  final String? inquilinoId;
  
  const DocumentosInquilinoScreen({
    super.key,
    this.condominioId,
    this.inquilinoId,
  });

  @override
  State<DocumentosInquilinoScreen> createState() => _DocumentosInquilinoScreenState();
}

class _DocumentosInquilinoScreenState extends State<DocumentosInquilinoScreen> {
  
  // IDs para operações
  String get condominioId => widget.condominioId ?? 'demo-condominio-id';
  String get inquilinoId => widget.inquilinoId ?? 'demo-inquilino-id';
  
  // Dados dinâmicos
  List<Documento> pastas = [];
  bool isLoading = false;
  String? errorMessage;
  
  @override
  void initState() {
    super.initState();
    _carregarPastas();
  }
  
  Future<void> _carregarPastas() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    
    print('🔍 Iniciando carregamento de pastas para o inquilino');
    print('📌 Condominio ID: $condominioId');
    
    try {
      final pastasCarregadas = await DocumentoService.getPastas(condominioId);
      setState(() {
        pastas = pastasCarregadas;
        isLoading = false;
      });
      print('✅ Documentos do inquilino carregados: ${pastas.length} pastas');
      for (var pasta in pastas) {
        print('📁 Pasta: ${pasta.nome} (ID: ${pasta.id})');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erro ao carregar pastas: $e';
        isLoading = false;
      });
      print('❌ Erro ao carregar pastas do inquilino: $e');
    }
  }

  Widget _buildPastaItem(Documento pasta) {
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
          Icon(
            Icons.folder,
            color: Colors.blue,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pasta.nome,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                if (pasta.descricao != null && pasta.descricao!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      pasta.descricao!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: Colors.grey,
            size: 20,
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
            // Cabeçalho superior padronizado (mesmo da tela do representante)
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
            
            // Título da página
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: const Text(
                'Home/Documentos',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            // Conteúdo principal
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    
                    // Título da seção
                    const Text(
                      'Pastas de Documento',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Lista de pastas ou estado de carregamento
                    Expanded(
                      child: isLoading
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : errorMessage != null
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        size: 48,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        errorMessage!,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: _carregarPastas,
                                        child: const Text('Tentar novamente'),
                                      ),
                                    ],
                                  ),
                                )
                              : pastas.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.folder_open,
                                            size: 48,
                                            color: Colors.grey[400],
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Nenhuma pasta disponível',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: pastas.length,
                                      itemBuilder: (context, index) {
                                        final pasta = pastas[index];
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => PastaArquivosScreen(
                                                  nomePasta: pasta.nome,
                                                  condominioId: condominioId,
                                                  inquilinoId: inquilinoId,
                                                ),
                                              ),
                                            );
                                          },
                                          child: _buildPastaItem(pasta),
                                        );
                                      },
                                    ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}