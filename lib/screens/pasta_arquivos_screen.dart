import 'package:flutter/material.dart';

class PastaArquivosScreen extends StatefulWidget {
  final String nomePasta;
  final String condominioId;
  final String inquilinoId;
  
  const PastaArquivosScreen({
    super.key,
    required this.nomePasta,
    required this.condominioId,
    required this.inquilinoId,
  });

  @override
  State<PastaArquivosScreen> createState() => _PastaArquivosScreenState();
}

class _PastaArquivosScreenState extends State<PastaArquivosScreen> {
  
  // Dados mockados para demonstração
  List<Map<String, String>> arquivos = [];
  
  @override
  void initState() {
    super.initState();
    _carregarArquivosMockados();
  }
  
  void _carregarArquivosMockados() {
    // Dados mockados baseados no nome da pasta
    switch (widget.nomePasta.toLowerCase()) {
      case 'atas':
        arquivos = [
          {'nome': 'ataReuniao1808.pdf', 'data': '18/08/2024'},
          {'nome': 'ataReuniao1808.pdf', 'data': '15/07/2024'},
          {'nome': 'ataReuniao1808.pdf', 'data': '20/06/2024'},
        ];
        break;
      case 'convenção':
        arquivos = [
          {'nome': 'convencaoCondominio.pdf', 'data': '01/01/2024'},
          {'nome': 'alteracaoConvencao.pdf', 'data': '15/03/2024'},
        ];
        break;
      case 'regimento interno':
        arquivos = [
          {'nome': 'regimentoInterno2024.pdf', 'data': '01/01/2024'},
          {'nome': 'atualizacaoRegimento.pdf', 'data': '10/05/2024'},
        ];
        break;
      default:
        arquivos = [
          {'nome': 'documento1.pdf', 'data': '01/01/2024'},
          {'nome': 'documento2.pdf', 'data': '15/02/2024'},
        ];
    }
  }

  Widget _buildArquivoItem(Map<String, String> arquivo) {
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
            Icons.picture_as_pdf,
            color: Colors.red[600],
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  arquivo['nome']!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Adicionado em: ${arquivo['data']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              // TODO: Implementar visualização do PDF
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Abrindo ${arquivo['nome']}')),
              );
            },
            child: const Icon(
              Icons.visibility,
              color: Colors.blue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              // TODO: Implementar download do PDF
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Baixando ${arquivo['nome']}')),
              );
            },
            child: const Icon(
              Icons.download,
              color: Colors.green,
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
            // Cabeçalho superior padronizado (idêntico ao documentos_screen.dart)
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
              child: Text(
                'Home/Documentos/${widget.nomePasta}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            // Título da seção
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                widget.nomePasta,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF1E3A8A),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            // Subtítulo Arquivos
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: const Text(
                'Arquivos',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            // Lista de arquivos
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: arquivos.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhum arquivo encontrado',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : ListView(
                        children: arquivos.map((arquivo) => _buildArquivoItem(arquivo)).toList(),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}