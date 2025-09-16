import 'package:flutter/material.dart';
import 'pasta_arquivos_screen.dart';

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
  
  // Lista de pastas de documentos do inquilino
  final List<Map<String, dynamic>> pastasDocumentos = [
    {
      'nome': 'Atas',
      'icone': Icons.folder,
      'cor': Colors.blue,
    },
    {
      'nome': 'Convenção',
      'icone': Icons.folder,
      'cor': Colors.blue,
    },
    {
      'nome': 'Regimento Interno',
      'icone': Icons.folder,
      'cor': Colors.blue,
    },
  ];

  Widget _buildPastaItem(Map<String, dynamic> pasta) {
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
            pasta['icone'],
            color: pasta['cor'],
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              pasta['nome'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
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
                    
                    // Lista de pastas
                    Expanded(
                      child: ListView.builder(
                        itemCount: pastasDocumentos.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PastaArquivosScreen(
                                    nomePasta: pastasDocumentos[index]['nome']!,
                                    condominioId: condominioId,
                                    inquilinoId: inquilinoId,
                                  ),
                                ),
                              );
                            },
                            child: _buildPastaItem(pastasDocumentos[index]),
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