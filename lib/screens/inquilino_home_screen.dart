import 'package:flutter/material.dart';
import 'documentos_inquilino_screen.dart';
import 'agenda_inquilino_screen.dart';
import 'portaria_inquilino_screen.dart';

class InquilinoHomeScreen extends StatefulWidget {
  final String condominioId;
  final String condominioNome;
  final String condominioCnpj;
  final String? inquilinoId;
  final String? proprietarioId;
  final String unidadeId;
  final String unidadeNome;

  const InquilinoHomeScreen({
    super.key,
    required this.condominioId,
    required this.condominioNome,
    required this.condominioCnpj,
    this.inquilinoId,
    this.proprietarioId,
    required this.unidadeId,
    required this.unidadeNome,
  }) : assert(
         inquilinoId != null || proprietarioId != null,
         'Deve fornecer inquilinoId ou proprietarioId',
       );

  @override
  State<InquilinoHomeScreen> createState() => _InquilinoHomeScreenState();
}

class _InquilinoHomeScreenState extends State<InquilinoHomeScreen> {
  Widget _buildMenuCard({
    required String imagePath,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                    height: 60,
                    width: 60,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
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
                  Image.asset('assets/images/logo_CondoGaia.png', height: 32),
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
            Container(height: 1, color: Colors.grey[300]),

            // Grid de funcionalidades do inquilino
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.9,
                  children: [
                    _buildMenuCard(
                      imagePath:
                          'assets/images/Representante/HOME/Imagem_chat.png',
                      title: 'Chat',
                      onTap: () {
                        // TODO: Implementar navegação para chat
                      },
                    ),
                    _buildMenuCard(
                      imagePath:
                          'assets/images/Representante/HOME/Imagem_Classificados.png',
                      title: 'Classificados',
                      onTap: () {
                        // TODO: Implementar navegação para classificados
                      },
                    ),
                    _buildMenuCard(
                      imagePath:
                          'assets/images/Representante/HOME/Imagem_Documentos.png',
                      title: 'Documentos',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DocumentosInquilinoScreen(
                              condominioId: widget.condominioId,
                              inquilinoId:
                                  widget.inquilinoId ?? widget.proprietarioId!,
                            ),
                          ),
                        );
                      },
                    ),
                    _buildMenuCard(
                      imagePath:
                          'assets/images/Representante/HOME/Imagem_DiarioAgenda.png',
                      title: 'Diário/Agenda',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AgendaInquilinoScreen(
                              condominioId: widget.condominioId,
                            ),
                          ),
                        );
                      },
                    ),
                    _buildMenuCard(
                      imagePath:
                          'assets/images/Representante/HOME/Imagem_Controle.png',
                      title: 'Controle',
                      onTap: () {
                        // TODO: Implementar navegação para controle
                      },
                    ),
                    _buildMenuCard(
                      imagePath:
                          'assets/images/Representante/HOME/Imagem_Reservas.png',
                      title: 'Reservas',
                      onTap: () {
                        // TODO: Implementar navegação para reservas
                      },
                    ),
                    _buildMenuCard(
                      imagePath:
                          'assets/images/HOME_Inquilino/Boleto_icone_Inquilino.png',
                      title: 'Boletos',
                      onTap: () {
                        // TODO: Implementar navegação para boletos
                      },
                    ),
                    _buildMenuCard(
                      imagePath:
                          'assets/images/HOME_Inquilino/Portaria_icone_Inquilino.png',
                      title: 'Portaria',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PortariaInquilinoScreen(
                              condominioId: widget.condominioId,
                              condominioNome: widget.condominioNome,
                              condominioCnpj: widget.condominioCnpj,
                              inquilinoId:
                                  widget.inquilinoId ?? widget.proprietarioId!,
                              proprietarioId: widget.proprietarioId,
                              unidadeId: widget.unidadeId,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Footer com informações do condomínio
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          widget.condominioNome,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Unidade: ${widget.unidadeNome}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  // Setas de mudança de condomínio no canto inferior direito
                  Padding(
                    padding: const EdgeInsets.only(left: 0.0),
                    child: GestureDetector(
                      onTap: () {
                        // Voltar para o dashboard anterior
                        Navigator.pop(context);
                      },
                      child: Image.asset(
                        'assets/images/Representante/HOME/Setas_Mudancadecomdominio.png',
                        height: 35,
                        width: 35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}