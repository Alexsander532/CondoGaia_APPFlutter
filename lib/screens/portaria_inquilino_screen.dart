import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:io';
import 'chat_inquilino_v2_screen.dart';
import '../services/photo_picker_service.dart';
import '../models/autorizado_inquilino.dart';
import '../services/autorizado_inquilino_service.dart';
import '../models/encomenda.dart';
import '../services/encomenda_service.dart';
import '../widgets/qr_code_widget.dart';

class PortariaInquilinoScreen extends StatefulWidget {
  final String? condominioId;
  final String? condominioNome;
  final String? condominioCnpj;
  final String? inquilinoId;
  final String? proprietarioId;
  final String? unidadeId;

  const PortariaInquilinoScreen({
    super.key,
    this.condominioId,
    this.condominioNome,
    this.condominioCnpj,
    this.inquilinoId,
    this.proprietarioId,
    this.unidadeId,
  });

  @override
  State<PortariaInquilinoScreen> createState() =>
      _PortariaInquilinoScreenState();
}

class _PortariaInquilinoScreenState extends State<PortariaInquilinoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Lista de autorizados carregada do banco
  List<AutorizadoInquilino> _autorizados = [];
  bool _isLoading = false;

  // Lista de encomendas carregada do banco
  List<Encomenda> _encomendas = [];
  bool _isLoadingEncomendas = false;
  final EncomendaService _encomendaService = EncomendaService();

  // Controladores para o modal de adicionar autorizado
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _parentescoController = TextEditingController();
  final TextEditingController _carroMotoController = TextEditingController();
  final TextEditingController _marcaController = TextEditingController();
  final TextEditingController _placaController = TextEditingController();
  final TextEditingController _modeloController = TextEditingController();
  final TextEditingController _corController = TextEditingController();

  // Máscara para CPF
  final _cpfMask = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  // Variáveis de estado para o modal
  String _permissaoSelecionada = 'qualquer'; // 'qualquer' ou 'determinado'
  List<bool> _diasSemana = List.filled(
    7,
    false,
  ); // DOM, SEG, TER, QUA, QUI, SEX, SAB
  String _horarioInicio = '08:00';
  String _horarioFim = '18:00';
  XFile? _fotoAutorizado; // Usar XFile em vez de File para compatibilidade web

  // 🆕 Variáveis para seleção de dias/horários (Passo 2)
  String _tipoSelecaoDias = 'dias_semana'; // 'dias_semana' ou 'dias_especificos'
  List<bool> _diasSemanasSelecionados = List.filled(7, false); // Dias da semana selecionados
  List<DateTime> _diasEspecificosSelecionados = []; // Datas selecionadas (DateTime, convertidas para ISO ao salvar)

  // Lista de horários disponíveis (00:00 até 23:00)
  final List<String> _horariosDisponiveis = List.generate(24, (index) {
    return '${index.toString().padLeft(2, '0')}:00';
  });

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Debug: Verificar se os IDs estão sendo passados corretamente
    print('DEBUG - PortariaInquilinoScreen initState:');
    print('  condominioId: ${widget.condominioId}');
    print('  inquilinoId: ${widget.inquilinoId}');
    print('  proprietarioId: ${widget.proprietarioId}');
    print('  unidadeId: ${widget.unidadeId}');

    _carregarAutorizados(); // Carregar autorizados ao inicializar
    _carregarEncomendas(); // Carregar encomendas ao inicializar
  }

  // Método para carregar autorizados do banco de dados
  Future<void> _carregarAutorizados() async {
    if (widget.unidadeId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      List<AutorizadoInquilino> autorizados;

      // Debug
      print('🔵 _carregarAutorizados():');
      print('   inquilinoId: ${widget.inquilinoId}');
      print('   proprietarioId: ${widget.proprietarioId}');
      print('   unidadeId: ${widget.unidadeId}');

      // Buscar por inquilino ou proprietário dependendo do contexto
      if (widget.inquilinoId != null) {
        print('   → Buscando por inquilinoId: ${widget.inquilinoId}');
        autorizados =
            await AutorizadoInquilinoService.getAutorizadosByInquilino(
              widget.inquilinoId!,
            );
      } else if (widget.proprietarioId != null) {
        print('   → Buscando por proprietarioId: ${widget.proprietarioId}');
        autorizados =
            await AutorizadoInquilinoService.getAutorizadosByProprietario(
              widget.proprietarioId!,
            );
      } else {
        print('   → Buscando por unidadeId: ${widget.unidadeId}');
        // Se não tiver nem inquilino nem proprietário, buscar por unidade
        autorizados = await AutorizadoInquilinoService.getAutorizadosByUnidade(
          widget.unidadeId!,
        );
      }

      print('   Autorizados encontrados: ${autorizados.length}');

      setState(() {
        _autorizados = autorizados;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar autorizados: $e'),
            backgroundColor: const Color(0xFFE74C3C),
          ),
        );
      }
    }
  }

  // Método para carregar encomendas do banco de dados
  Future<void> _carregarEncomendas() async {
    if (widget.unidadeId == null) return;

    setState(() {
      _isLoadingEncomendas = true;
    });

    try {
      // Debug
      print('🔵 _carregarEncomendas():');
      print('   inquilinoId: ${widget.inquilinoId}');
      print('   proprietarioId: ${widget.proprietarioId}');
      print('   unidadeId: ${widget.unidadeId}');

      // Usar o novo método que filtra por pessoa específica
      final encomendas = await _encomendaService.listarEncomendasPessoa(
        unidadeId: widget.unidadeId!,
        proprietarioId: widget.proprietarioId,
        inquilinoId: widget.inquilinoId,
      );

      print('   Encomendas encontradas: ${encomendas.length}');

      setState(() {
        _encomendas = encomendas;
        _isLoadingEncomendas = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingEncomendas = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar encomendas: $e'),
            backgroundColor: const Color(0xFFE74C3C),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nomeController.dispose();
    _cpfController.dispose();
    _parentescoController.dispose();
    _carroMotoController.dispose();
    _marcaController.dispose();
    _placaController.dispose();
    _modeloController.dispose();
    _corController.dispose();
    super.dispose();
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

            // Título da página
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: const Text(
                'Home/Gestão/Portaria',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // TabBar com as três abas - Design igual à imagem
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: TabBar(
                controller: _tabController,
                indicator: const UnderlineTabIndicator(
                  borderSide: BorderSide(width: 3.0, color: Color(0xFF4A90E2)),
                  insets: EdgeInsets.symmetric(horizontal: 0.0),
                ),
                indicatorColor: const Color(0xFF4A90E2),
                labelColor: const Color(0xFF4A90E2),
                unselectedLabelColor: Colors.grey[600],
                labelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                dividerColor: Colors.grey[300],
                tabs: const [
                  Tab(text: 'Autorizados'),
                  Tab(text: 'Mensagem'),
                  Tab(text: 'Encomendas'),
                ],
              ),
            ),

            // Conteúdo das abas
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Aba Autorizados
                  _buildAutorizadosTab(),
                  // Aba Mensagem
                  _buildMensagemTab(),
                  // Aba Encomendas
                  _buildEncomendasTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para a aba Autorizados
  Widget _buildAutorizadosTab() {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: Column(
        children: [
          // Botão Adicionar Autorizado
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () {
                _showAdicionarAutorizadoModal();
              },
              icon: const Icon(Icons.add, color: Colors.white, size: 20),
              label: const Text(
                'Adicionar Autorizado',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90E2),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
            ),
          ),

          // Lista de autorizados
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF4A90E2)),
                  )
                : _autorizados.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_off_outlined,
                          size: 64,
                          color: Color(0xFF7F8C8D),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Nenhum autorizado cadastrado',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF7F8C8D),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Toque no botão acima para adicionar',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF95A5A6),
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _carregarAutorizados,
                    color: const Color(0xFF4A90E2),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _autorizados.length,
                      itemBuilder: (context, index) {
                        final autorizado = _autorizados[index];
                        return _buildAutorizadoCardFromModel(autorizado);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // Widget do card de pessoa autorizada usando o modelo
  Widget _buildAutorizadoCardFromModel(AutorizadoInquilino autorizado) {
    return Column(
      children: [
        // Card com informações do autorizado
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Foto ou ícone de pessoa
                  GestureDetector(
                    onTap: autorizado.fotoUrl != null && autorizado.fotoUrl!.isNotEmpty
                        ? () => _mostrarFotoAmpliadaAutorizado(autorizado.fotoUrl!)
                        : null,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF4A90E2).withOpacity(0.1),
                        border: autorizado.fotoUrl != null && autorizado.fotoUrl!.isNotEmpty
                            ? Border.all(
                                color: const Color(0xFF4A90E2),
                                width: 2,
                              )
                            : null,
                      ),
                      child: autorizado.fotoUrl != null && autorizado.fotoUrl!.isNotEmpty
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipOval(
                                  child: Image.network(
                                    autorizado.fotoUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.person,
                                        size: 30,
                                        color: Color(0xFF4A90E2),
                                      );
                                    },
                                  ),
                                ),
                                Positioned(
                                  bottom: -2,
                                  right: -2,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFF4A90E2),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.zoom_in,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : const Icon(
                              Icons.person,
                              size: 30,
                              color: Color(0xFF4A90E2),
                            ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Informações da pessoa
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nome
                        Text(
                          autorizado.nome,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E3A59),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // CPF (primeiros 3 dígitos)
                        if (autorizado.cpf.isNotEmpty)
                          Text(
                            'CPF: ${autorizado.cpf.substring(0, 3)}***',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF666666),
                            ),
                          ),
                        // Parentesco
                        if (autorizado.parentesco?.isNotEmpty == true) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Text(
                                'Parentesco: ',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF666666),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Text(
                                autorizado.parentesco!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF2E3A59),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Ícones de ação
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Ícone de editar
                      GestureDetector(
                        onTap: () {
                          _editarAutorizado(autorizado);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.edit_outlined,
                            size: 20,
                            color: Color(0xFF4A90E2),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Ícone de excluir
                      GestureDetector(
                        onTap: () {
                          _showDeleteConfirmationFromModel(context, autorizado);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: Color(0xFFE74C3C),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Informações adicionais (horários, veículo, etc.)
              if ((autorizado.diasSemanaPermitidos?.isNotEmpty ?? false) ||
                  (autorizado.diasEspecificos?.isNotEmpty ?? false) ||
                  autorizado.temVeiculo) ...[
                const SizedBox(height: 12),
                const Divider(color: Color(0xFFE0E0E0)),
                const SizedBox(height: 8),

                // Horários permitidos - Dias da semana
                if (autorizado.diasSemanaPermitidos?.isNotEmpty ?? false) ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: Color(0xFF666666),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${autorizado.diasSemanaFormatados} - ${autorizado.horarioFormatado}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],

                // Horários permitidos - Datas específicas
                if (autorizado.diasEspecificos?.isNotEmpty ?? false) ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Color(0xFF666666),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${autorizado.diasEspecificosFormatados} - ${autorizado.horarioFormatado}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],

                // Informações do veículo
                if (autorizado.temVeiculo) ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.directions_car,
                        size: 16,
                        color: Color(0xFF666666),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          autorizado.veiculoFormatado,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ],
          ),
        ),
        // QR Code Widget integrado dentro do card
        const SizedBox(height: 2),
        //const Divider(color: Color(0xFFE0E0E0)),
        const SizedBox(height: 2),
        QrCodeWidget(
          dados: autorizado.gerarDadosQR(
            unidade: widget.unidadeId,
            tipoAutorizado: 'inquilino',
          ),
          nome: autorizado.nome,
          qrCodeUrl: autorizado.qrCodeUrl,
        ),
        const SizedBox(height: 24),
        const Divider(color: Color(0xFFE0E0E0)),
        const SizedBox(height: 8),

      ],
    );
  }

  // Método para editar autorizado
  void _editarAutorizado(AutorizadoInquilino autorizado) {
    _showAdicionarAutorizadoModal(autorizado);
  }

  // Método para mostrar confirmação de exclusão usando o modelo
  void _showDeleteConfirmationFromModel(
    BuildContext context,
    AutorizadoInquilino autorizado,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text(
            'Deseja realmente remover ${autorizado.nome} da lista de autorizados?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Color(0xFF666666)),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _excluirAutorizado(autorizado);
              },
              child: const Text(
                'Excluir',
                style: TextStyle(color: Color(0xFFE74C3C)),
              ),
            ),
          ],
        );
      },
    );
  }

  // Método para excluir autorizado
  Future<void> _excluirAutorizado(AutorizadoInquilino autorizado) async {
    try {
      await AutorizadoInquilinoService.deleteAutorizado(autorizado.id);

      // Recarregar a lista
      await _carregarAutorizados();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${autorizado.nome} removido da lista de autorizados',
            ),
            backgroundColor: const Color(0xFF27AE60),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir autorizado: $e'),
            backgroundColor: const Color(0xFFE74C3C),
          ),
        );
      }
    }
  }

  // Método para mostrar foto ampliada do autorizado
  void _mostrarFotoAmpliadaAutorizado(String fotoUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(10),
          child: Stack(
            children: [
              // Foto ampliada
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  color: Colors.black87,
                  child: Center(
                    child: InteractiveViewer(
                      minScale: 1.0,
                      maxScale: 4.0,
                      child: Image.network(
                        fotoUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.image_not_supported,
                                color: Colors.white,
                                size: 64,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Erro ao carregar a foto',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              // Botão fechar (X)
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _mostrarFotoAmpliadaEncomenda(String fotoUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(10),
          child: Stack(
            children: [
              // Foto ampliada
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  color: Colors.black87,
                  child: Center(
                    child: InteractiveViewer(
                      minScale: 1.0,
                      maxScale: 4.0,
                      child: Image.network(
                        fotoUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.image_not_supported,
                                color: Colors.white,
                                size: 64,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Erro ao carregar a foto',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              // Botão fechar (X)
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Método para salvar autorizado (adicionar ou editar)
  // ========== MÉTODOS DE VALIDAÇÃO ==========

  /// Valida se dias foram selecionados de acordo com o tipo escolhido
  bool _validarPermissoes() {
    if (_permissaoSelecionada == 'determinado') {
      // Validar tipo de seleção de dias
      if (_tipoSelecaoDias == 'dias_semana') {
        // Verificar se pelo menos um dia da semana foi selecionado
        // 🔧 Usar _diasSemanasSelecionados (a variável que a UI realmente modifica)
        if (_diasSemanasSelecionados.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Selecione pelo menos um dia da semana'),
              backgroundColor: Color(0xFFE74C3C),
            ),
          );
          return false;
        }
      } else if (_tipoSelecaoDias == 'dias_especificos') {
        // Verificar se pelo menos uma data específica foi selecionada
        if (_diasEspecificosSelecionados.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Selecione pelo menos uma data específica'),
              backgroundColor: Color(0xFFE74C3C),
            ),
          );
          return false;
        }
      }
    }
    return true;
  }

  Future<void> _salvarAutorizado([
    AutorizadoInquilino? autorizadoExistente,
  ]) async {
    // Validações básicas
    String nome = _nomeController.text.trim();
    String cpf = _cpfController.text.trim();

    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha o nome do autorizado'),
          backgroundColor: Color(0xFFE74C3C),
        ),
      );
      return;
    }

    if (cpf.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha o CPF do autorizado'),
          backgroundColor: Color(0xFFE74C3C),
        ),
      );
      return;
    }

    // 🆕 Validar permissões (dias/horários)
    if (!_validarPermissoes()) {
      return;
    }

    if (widget.unidadeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro: ID da unidade não encontrado'),
          backgroundColor: Color(0xFFE74C3C),
        ),
      );
      return;
    }

    try {
      // Criar o mapa de dados para o autorizado
      
      // 🆕 Preparar datas específicas em formato ISO
      List<String> diasEspecificosISO = [];
      if (_tipoSelecaoDias == 'dias_especificos' && _diasEspecificosSelecionados.isNotEmpty) {
        diasEspecificosISO = _diasEspecificosSelecionados
            .map((date) => date.toIso8601String().split('T')[0]) // Formato YYYY-MM-DD
            .toList();
      }

      final autorizadoData = {
        'unidade_id': widget.unidadeId!,
        'inquilino_id': widget.inquilinoId,
        'proprietario_id': widget.proprietarioId,
        'nome': nome,
        'cpf': cpf,
        'parentesco': _parentescoController.text.trim().isEmpty
            ? null
            : _parentescoController.text.trim(),
        // Horários e dias da semana
        'dias_semana_permitidos': _permissaoSelecionada == 'determinado'
            ? _diasSemana
                  .asMap()
                  .entries
                  .where((entry) => entry.value == true)
                  .map((entry) => entry.key)
                  .toList()
            : null,
        'horario_inicio': _permissaoSelecionada == 'determinado'
            ? _horarioInicio
            : null,
        'horario_fim': _permissaoSelecionada == 'determinado'
            ? _horarioFim
            : null,
        // 🆕 Tipo de seleção de dias e datas específicas
        'tipo_selecao_dias': _permissaoSelecionada == 'determinado'
            ? _tipoSelecaoDias
            : 'dias_semana', // Valor padrão se não for 'determinado'
        'dias_especificos': diasEspecificosISO,
        // Dados do veículo
        'veiculo_marca': _marcaController.text.trim().isEmpty
            ? null
            : _marcaController.text.trim(),
        'veiculo_modelo': _modeloController.text.trim().isEmpty
            ? null
            : _modeloController.text.trim(),
        'veiculo_cor': _corController.text.trim().isEmpty
            ? null
            : _corController.text.trim(),
        'veiculo_placa': _placaController.text.trim().isEmpty
            ? null
            : _placaController.text.trim(),
        'ativo': true,
      };

      // DEBUG: Mostrar dados que estão sendo enviados
      print('=== DEBUG ADICIONAR AUTORIZADO ===');
      print('Dados do autorizado sendo enviados:');
      print('- unidade_id: ${autorizadoData['unidade_id']}');
      print('- inquilino_id: ${autorizadoData['inquilino_id']}');
      print('- proprietario_id: ${autorizadoData['proprietario_id']}');
      print('- nome: ${autorizadoData['nome']}');
      print('- cpf: ${autorizadoData['cpf']}');
      print('- parentesco: ${autorizadoData['parentesco']}');
      print(
        '- dias_semana_permitidos: ${autorizadoData['dias_semana_permitidos']}',
      );
      print('- horario_inicio: ${autorizadoData['horario_inicio']}');
      print('- horario_fim: ${autorizadoData['horario_fim']}');
      print('- veiculo_marca: ${autorizadoData['veiculo_marca']}');
      print('- veiculo_modelo: ${autorizadoData['veiculo_modelo']}');
      print('- veiculo_cor: ${autorizadoData['veiculo_cor']}');
      print('- veiculo_placa: ${autorizadoData['veiculo_placa']}');
      print('- ativo: ${autorizadoData['ativo']}');
      print('- _permissaoSelecionada: $_permissaoSelecionada');
      print('- _diasSemana: $_diasSemana');
      print('===================================');

      // Fazer upload da foto se houver uma selecionada
      if (_fotoAutorizado != null) {
        try {
          print('🔵 Iniciando upload da foto do autorizado...');
          
          // Gerar nome único para a foto
          final String nomeArquivo = 'autorizado_${DateTime.now().millisecondsSinceEpoch}.jpg';
          
          // Fazer upload para Supabase Storage
          // Bucket: visitante_adicionado_pelo_inquilino
          // Caminho: /condominio_id/unidade_id/autorizado_id/foto.jpg
          final fotoUrlPublica = await AutorizadoInquilinoService.uploadFotoAutorizado(
            condominioId: widget.condominioId!,
            unidadeId: widget.unidadeId!,
            arquivo: _fotoAutorizado!,
            nomeArquivo: nomeArquivo,
          );
          
          if (fotoUrlPublica != null) {
            autorizadoData['foto_url'] = fotoUrlPublica;
            print('✅ Upload da foto realizado com sucesso: $fotoUrlPublica');
          }
        } catch (e) {
          print('⚠️ Erro ao fazer upload da foto: $e');
          // Continuar mesmo se falhar o upload (foto é opcional)
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Aviso: Erro ao fazer upload da foto: $e'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }

      // Salvar no banco de dados
      AutorizadoInquilino? resultado;
      if (autorizadoExistente != null) {
        // Editar autorizado existente
        resultado = await AutorizadoInquilinoService.updateAutorizado(
          autorizadoExistente.id!,
          autorizadoData,
        );
      } else {
        // Adicionar novo autorizado
        resultado = await AutorizadoInquilinoService.insertAutorizado(
          autorizadoData,
        );
      }

      // Recarregar a lista
      await _carregarAutorizados();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              autorizadoExistente != null
                  ? '$nome atualizado com sucesso'
                  : '$nome adicionado à lista de autorizados',
            ),
            backgroundColor: const Color(0xFF27AE60),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar autorizado: $e'),
            backgroundColor: const Color(0xFFE74C3C),
          ),
        );
      }
    }
  }

  // Widget para título de seção
  Widget _buildSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: const BoxDecoration(
              color: Color(0xFF4A90E2),
              borderRadius: BorderRadius.all(Radius.circular(2)),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E3A59),
            ),
          ),
        ],
      ),
    );
  }

  // Widget para campo de texto
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    MaskTextInputFormatter? mask,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2E3A59),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          inputFormatters: mask != null ? [mask] : null,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF4A90E2)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  // Widget para dropdown de horário
  Widget _buildHorarioDropdown(
    String label,
    String valorSelecionado,
    StateSetter setModalState,
    bool isInicio,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2E3A59),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(6),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: valorSelecionado,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF2E3A59),
                size: 20,
              ),
              style: const TextStyle(
                color: Color(0xFF2E3A59),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              items: _horariosDisponiveis.map((String horario) {
                return DropdownMenuItem<String>(
                  value: horario,
                  child: Text(horario),
                );
              }).toList(),
              onChanged: (String? novoHorario) {
                if (novoHorario != null) {
                  setModalState(() {
                    if (isInicio) {
                      _horarioInicio = novoHorario;
                      // Se o horário de início for maior que o de fim, ajustar o fim
                      int inicioIndex = _horariosDisponiveis.indexOf(
                        novoHorario,
                      );
                      int fimIndex = _horariosDisponiveis.indexOf(_horarioFim);
                      if (inicioIndex >= fimIndex) {
                        if (inicioIndex < _horariosDisponiveis.length - 1) {
                          _horarioFim = _horariosDisponiveis[inicioIndex + 1];
                        }
                      }
                    } else {
                      _horarioFim = novoHorario;
                      // Se o horário de fim for menor que o de início, ajustar o início
                      int inicioIndex = _horariosDisponiveis.indexOf(
                        _horarioInicio,
                      );
                      int fimIndex = _horariosDisponiveis.indexOf(novoHorario);
                      if (fimIndex <= inicioIndex) {
                        if (fimIndex > 0) {
                          _horarioInicio = _horariosDisponiveis[fimIndex - 1];
                        }
                      }
                    }
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  // Widget para checkbox de dia da semana
  Widget _buildDiaCheckbox(String dia, int index, StateSetter setModalState) {
    return Column(
      children: [
        Text(
          dia,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2E3A59),
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () {
            setModalState(() {
              _diasSemana[index] = !_diasSemana[index];
              
              // 🔧 Sincronizar com _diasSemanasSelecionados também
              _diasSemanasSelecionados[index] = !_diasSemanasSelecionados[index];
              
              print('[DEBUG] Dias selecionados: $_diasSemanasSelecionados');
            });
          },
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _diasSemana[index]
                  ? const Color(0xFF4A90E2)
                  : Colors.white,
              border: Border.all(
                color: _diasSemana[index]
                    ? const Color(0xFF4A90E2)
                    : Colors.grey[300]!,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: _diasSemana[index]
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
        ),
      ],
    );
  }

  // Métodos auxiliares para o modal de adicionar autorizado
  void _limparCamposModal() {
    try {
      if (_nomeController.text.isNotEmpty) _nomeController.clear();
      if (_cpfController.text.isNotEmpty) _cpfController.clear();
      if (_parentescoController.text.isNotEmpty) _parentescoController.clear();
      if (_carroMotoController.text.isNotEmpty) _carroMotoController.clear();
      if (_marcaController.text.isNotEmpty) _marcaController.clear();
      if (_placaController.text.isNotEmpty) _placaController.clear();
      if (_modeloController.text.isNotEmpty) _modeloController.clear();
      if (_corController.text.isNotEmpty) _corController.clear();
      _fotoAutorizado = null; // Limpar a foto também
    } catch (e) {
      print('Erro ao limpar controladores: $e');
      // Em caso de erro, recriar os controladores
      _recriarControladores();
    }
  }

  void _recriarControladores() {
    // Como os controladores são final, apenas limpamos o texto
    try {
      _nomeController.text = '';
      _cpfController.text = '';
      _parentescoController.text = '';
      _carroMotoController.text = '';
      _marcaController.text = '';
      _placaController.text = '';
      _modeloController.text = '';
      _corController.text = '';
    } catch (e) {
      print('Erro ao limpar texto dos controladores: $e');
    }
  }

  void _resetarVariaveisEstado() {
    if (mounted) {
      setState(() {
        _permissaoSelecionada = 'qualquer';
        _diasSemana = List.filled(7, false);
        _horarioInicio = '08:00';
        _horarioFim = '18:00';
        // 🔧 Resetar também as novas variáveis
        _tipoSelecaoDias = 'dias_semana';
        _diasSemanasSelecionados = List.filled(7, false);
        _diasEspecificosSelecionados = [];
      });
    }
  }

  // Método para preencher campos com dados do autorizado existente
  void _preencherCamposParaEdicao(AutorizadoInquilino autorizado) {
    try {
      // Preencher campos básicos
      _nomeController.text = autorizado.nome;
      _cpfController.text = autorizado.cpf ?? '';
      _parentescoController.text = autorizado.parentesco ?? '';

      // Preencher dados do veículo
      _marcaController.text = autorizado.veiculoMarca ?? '';
      _modeloController.text = autorizado.veiculoModelo ?? '';
      _corController.text = autorizado.veiculoCor ?? '';
      _placaController.text = autorizado.veiculoPlaca ?? '';

      // Determinar tipo de veículo baseado nos dados existentes
      if (autorizado.veiculoMarca != null ||
          autorizado.veiculoModelo != null ||
          autorizado.veiculoCor != null ||
          autorizado.veiculoPlaca != null) {
        _carroMotoController.text = 'Carro'; // Valor padrão, pode ser ajustado
      } else {
        _carroMotoController.text = '';
      }

      if (mounted) {
        setState(() {
          // Configurar permissões baseadas nos dados existentes
          if (autorizado.diasSemanaPermitidos != null &&
              autorizado.diasSemanaPermitidos!.isNotEmpty) {
            _permissaoSelecionada = 'determinado';

            // Converter lista de inteiros para lista de booleans
            _diasSemana = List.filled(7, false);
            _diasSemanasSelecionados = List.filled(7, false); // 🔧 Sincronizar

            for (int dia in autorizado.diasSemanaPermitidos!) {
              if (dia >= 0 && dia < 7) {
                _diasSemana[dia] = true;
                _diasSemanasSelecionados[dia] = true; // 🔧 Sincronizar
              }
            }

            // Configurar horários - converter formato HH:00:00 para HH:00
            String horarioInicioFormatado = autorizado.horarioInicio ?? '08:00';
            String horarioFimFormatado = autorizado.horarioFim ?? '18:00';

            // Remover segundos se existirem (converter HH:00:00 para HH:00)
            if (horarioInicioFormatado.length > 5) {
              horarioInicioFormatado = horarioInicioFormatado.substring(0, 5);
            }
            if (horarioFimFormatado.length > 5) {
              horarioFimFormatado = horarioFimFormatado.substring(0, 5);
            }

            _horarioInicio = horarioInicioFormatado;
            _horarioFim = horarioFimFormatado;

            // 🆕 Carregar tipo de seleção de dias e datas específicas
            _tipoSelecaoDias = autorizado.tipoSelecaoDias ?? 'dias_semana';
            
            if (autorizado.diasEspecificos != null && autorizado.diasEspecificos!.isNotEmpty) {
              _diasEspecificosSelecionados = autorizado.diasEspecificos!
                  .map((dateStr) => DateTime.parse(dateStr))
                  .toList();
            } else {
              _diasEspecificosSelecionados = [];
            }
          } else {
            _permissaoSelecionada = 'qualquer';
            _diasSemana = List.filled(7, false);
            _diasSemanasSelecionados = List.filled(7, false); // 🔧 Sincronizar
            _horarioInicio = '08:00';
            _horarioFim = '18:00';
            // 🆕 Resetar também os novos campos
            _tipoSelecaoDias = 'dias_semana';
            _diasEspecificosSelecionados = [];
          }
        });
      }
    } catch (e) {
      print('Erro ao preencher campos para edição: $e');
      // Em caso de erro, usar valores padrão
      _limparCamposModal();
      _resetarVariaveisEstado();
    }
  }

  // Método para mostrar o modal de adicionar autorizado
  void _showAdicionarAutorizadoModal([
    AutorizadoInquilino? autorizadoExistente,
  ]) {
    // Se for edição, preencher campos com dados existentes
    if (autorizadoExistente != null) {
      _preencherCamposParaEdicao(autorizadoExistente);
    } else {
      // Limpar campos ao abrir o modal com verificação de segurança
      _limparCamposModal();

      // Resetar variáveis de estado
      _resetarVariaveisEstado();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título do modal
                    Row(
                      children: [
                        Text(
                          autorizadoExistente != null
                              ? 'Editar Autorizado'
                              : 'Adicionar Autorizado',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.close,
                            color: Color(0xFF7F8C8D),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Conteúdo do modal com scroll
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Seção Visitante
                            _buildSectionTitle('Visitante'),
                            const SizedBox(height: 12),

                            _buildTextField(
                              controller: _nomeController,
                              label: 'Nome*',
                              hint: 'José Marcos da Silva',
                            ),
                            const SizedBox(height: 12),

                            _buildTextField(
                              controller: _cpfController,
                              label: 'CPF*',
                              hint: '000.000.000-00',
                              mask: _cpfMask,
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'APARECERÁ OS 3 PRIMEIROS DÍGITOS PARA A PORTARIA',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 12),

                            _buildTextField(
                              controller: _parentescoController,
                              label: 'Parentesco',
                              hint: 'Pai',
                            ),
                            const SizedBox(height: 20),

                            // Seção Foto
                            _buildSectionTitle('Foto do Autorizado'),
                            const SizedBox(height: 12),

                            // Widget para selecionar/capturar foto
                            GestureDetector(
                              onTap: () async {
                                await _mostrarDialogSelecaoFotoAutorizado(setModalState);
                              },
                              child: Container(
                                height: 150,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFF4A90E2),
                                    width: 2,
                                  ),
                                ),
                                child: _fotoAutorizado == null
                                    ? Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.camera_alt,
                                            size: 48,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Toque para tirar foto',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            '(ou selecionar da galeria)',
                                            style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: kIsWeb
                                                ? Image.network(
                                                    _fotoAutorizado!.path,
                                                    fit: BoxFit.cover,
                                                  )
                                                : Image.file(
                                                    File(_fotoAutorizado!.path),
                                                    fit: BoxFit.cover,
                                                  ),
                                          ),
                                          Positioned(
                                            top: 4,
                                            right: 4,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                              child: IconButton(
                                                onPressed: () {
                                                  setModalState(() {
                                                    _fotoAutorizado = null;
                                                  });
                                                },
                                                icon: const Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(
                                                  minWidth: 32,
                                                  minHeight: 32,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Seção Permissões
                            _buildSectionTitle('Permissões'),
                            const SizedBox(height: 12),

                            // Radio buttons para permissões
                            Column(
                              children: [
                                RadioListTile<String>(
                                  title: const Text(
                                    'Permissão em qualquer dia e horário',
                                  ),
                                  value: 'qualquer',
                                  groupValue: _permissaoSelecionada,
                                  onChanged: (value) {
                                    setModalState(() {
                                      _permissaoSelecionada = value!;
                                      // Resetar quando muda para 'qualquer'
                                      _diasSemana.fillRange(0, 7, false);
                                      _diasSemanasSelecionados.fillRange(0, 7, false);
                                      _diasEspecificosSelecionados.clear();
                                    });
                                  },
                                  activeColor: const Color(0xFF4A90E2),
                                ),
                                RadioListTile<String>(
                                  title: const Text(
                                    'Permissão em dias e horários determinado',
                                  ),
                                  value: 'determinado',
                                  groupValue: _permissaoSelecionada,
                                  onChanged: (value) {
                                    setModalState(() {
                                      _permissaoSelecionada = value!;
                                      // Garantir que tipo de seleção está definido
                                      if (_tipoSelecaoDias.isEmpty) {
                                        _tipoSelecaoDias = 'dias_semana';
                                      }
                                    });
                                  },
                                  activeColor: const Color(0xFF4A90E2),
                                ),
                              ],
                            ),

                            // 🆕 Seção para escolher tipo de seleção de dias (só aparece se "determinado" estiver selecionado)
                            if (_permissaoSelecionada == 'determinado') ...[
                              const SizedBox(height: 16),
                              const Text(
                                'Como deseja selecionar os dias?',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFFE0E0E0),
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    RadioListTile<String>(
                                      title: const Text('Dias da Semana'),
                                      value: 'dias_semana',
                                      groupValue: _tipoSelecaoDias,
                                      onChanged: (value) {
                                        setModalState(() {
                                          _tipoSelecaoDias = value!;
                                          // Limpar dias específicos quando mudar para dias_semana
                                          _diasEspecificosSelecionados.clear();
                                        });
                                      },
                                      activeColor: const Color(0xFF4A90E2),
                                    ),
                                    Container(
                                      height: 1,
                                      color: const Color(0xFFE0E0E0),
                                    ),
                                    RadioListTile<String>(
                                      title: const Text('Datas específicas'),
                                      subtitle: const Text('Permissão por data'),
                                      value: 'dias_especificos',
                                      groupValue: _tipoSelecaoDias,
                                      onChanged: (value) {
                                        setModalState(() {
                                          _tipoSelecaoDias = value!;
                                          // Limpar dias semana quando mudar para dias_especificos
                                          _diasSemana.fillRange(0, 7, false);
                                        });
                                      },
                                      activeColor: const Color(0xFF4A90E2),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            // Horários permitidos (só aparece se "determinado" estiver selecionado)
                            if (_permissaoSelecionada == 'determinado') ...[
                              const SizedBox(height: 16),
                              const Text(
                                'Horários permitida a entrada:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Seleção de horários
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildHorarioDropdown(
                                      'Início',
                                      _horarioInicio,
                                      setModalState,
                                      true,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Text(
                                    ' - ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF2E3A59),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildHorarioDropdown(
                                      'Fim',
                                      _horarioFim,
                                      setModalState,
                                      false,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // 🆕 Dias da semana - condicional (só aparece se selecionado modo dias_semana)
                              if (_tipoSelecaoDias == 'dias_semana') ...[
                                const Text(
                                  'Dias da Semana:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildDiaCheckbox('DOM', 0, setModalState),
                                    _buildDiaCheckbox('SEG', 1, setModalState),
                                    _buildDiaCheckbox('TER', 2, setModalState),
                                    _buildDiaCheckbox('QUA', 3, setModalState),
                                    _buildDiaCheckbox('QUI', 4, setModalState),
                                    _buildDiaCheckbox('SEX', 5, setModalState),
                                    _buildDiaCheckbox('SAB', 6, setModalState),
                                  ],
                                ),
                              ],

                              // 🆕 Datas específicas - condicional (só aparece se selecionado modo dias_especificos)
                              // 🆕 Datas específicas - condicional (só aparece se selecionado modo dias_especificos)
                              if (_tipoSelecaoDias == 'dias_especificos') ...[
                                _buildDiasEspecificosUI(setModalState),
                              ],
                            ],

                            const SizedBox(height: 20),

                            // Seção Veículo
                            _buildSectionTitle('Veículo(s)'),
                            const SizedBox(height: 12),

                            _buildTextField(
                              controller: _carroMotoController,
                              label: 'Carro/Moto',
                              hint: 'Carro',
                            ),
                            const SizedBox(height: 12),

                            _buildTextField(
                              controller: _marcaController,
                              label: 'Marca',
                              hint: 'Fiat',
                            ),
                            const SizedBox(height: 12),

                            _buildTextField(
                              controller: _placaController,
                              label: 'Placa',
                              hint: 'ABC1243',
                            ),
                            const SizedBox(height: 12),

                            _buildTextField(
                              controller: _modeloController,
                              label: 'Modelo',
                              hint: 'Fiat Argo',
                            ),
                            const SizedBox(height: 12),

                            _buildTextField(
                              controller: _corController,
                              label: 'Cor',
                              hint: 'Preto',
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),

                    // Botão Salvar fixo na parte inferior
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            await _salvarAutorizado(autorizadoExistente);
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A90E2),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Salvar',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Widget para a aba Mensagem
  Widget _buildMensagemTab() {
    // Contato único da portaria
    final Map<String, dynamic> contatoPortaria = {
      'nome': 'Portaria',
      'data': 'Disponível 24h',
      'icone': Icons.security,
      'corFundo': const Color(
        0xFF2E7D32,
      ), // Verde escuro para representar segurança
    };

    return Container(
      color: const Color(0xFFF5F5F5),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: _buildMensagemCard(
          nome: contatoPortaria['nome'],
          data: contatoPortaria['data'],
          icone: contatoPortaria['icone'],
          corFundo: contatoPortaria['corFundo'],
        ),
      ),
    );
  }

  // Widget do card de mensagem - INTEGRADO COM DADOS REAIS
  Widget _buildMensagemCard({
    required String nome,
    required String data,
    required IconData icone,
    required Color corFundo,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: corFundo,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icone, color: Colors.white, size: 24),
        ),
        title: Text(
          nome,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        subtitle: Text(
          data,
          style: const TextStyle(fontSize: 14, color: Color(0xFF7F8C8D)),
        ),
        onTap: () {
          // Abre ChatInquilinoV2Screen com dados reais
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatInquilinoV2Screen(
                condominioId: widget.condominioId ?? '',
                unidadeId: widget.unidadeId ?? '',
                usuarioId: widget.inquilinoId ??
                    widget.proprietarioId ??
                    '', // Inquilino ou Proprietário
                usuarioNome: widget.inquilinoId != null
                    ? 'Inquilino'
                    : 'Proprietário', // Nome real seria obtido do banco
                usuarioTipo: widget.inquilinoId != null
                    ? 'inquilino'
                    : 'proprietario',
                unidadeNumero:
                    'Sua Unidade', // Seria obtido do banco (B/501)
              ),
            ),
          );
        },
      ),
    );
  }

  // Widget do card de encomenda com dados reais
  Widget _buildEncomendaCardReal(Encomenda encomenda) {
    // Formatação de data e hora
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
    final DateFormat timeFormat = DateFormat('HH:mm');

    // Usar createdAt que é preenchido automaticamente pelo Supabase em horário de Brasília
    final String dataCadastro = dateFormat.format(encomenda.createdAt);
    final String horaCadastro = timeFormat.format(encomenda.createdAt);

    // Status da encomenda
    final bool foiRetirada = encomenda.recebido;
    final String status = foiRetirada
        ? 'Objeto Retirado'
        : 'Pendente de Retirada';
    final Color statusCor = foiRetirada
        ? const Color(0xFF4CAF50)
        : const Color(0xFFFF8C00);

    // Data e hora de retirada (se aplicável)
    String? dataRetirada;
    String? horaRetirada;
    if (foiRetirada && encomenda.dataRecebimento != null) {
      dataRetirada = dateFormat.format(encomenda.dataRecebimento!);
      horaRetirada = timeFormat.format(encomenda.dataRecebimento!);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Conteúdo principal
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Foto da encomenda ou ícone padrão
                GestureDetector(
                  onTap: encomenda.temFoto
                      ? () => _mostrarFotoAmpliadaEncomenda(encomenda.fotoUrl!)
                      : null,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                      boxShadow: encomenda.temFoto
                          ? [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 4,
                              ),
                            ]
                          : null,
                    ),
                    child: encomenda.temFoto
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              encomenda.fotoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.inventory_2_outlined,
                                  color: Color(0xFF7F8C8D),
                                  size: 24,
                                );
                              },
                            ),
                          )
                        : const Icon(
                            Icons.inventory_2_outlined,
                            color: Color(0xFF7F8C8D),
                            size: 24,
                          ),
                  ),
                ),
                const SizedBox(width: 12),

                // Informações da encomenda
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Data e hora de cadastro
                      Row(
                        children: [
                          const Text(
                            'Data: ',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          Text(
                            dataCadastro,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Text(
                            'Hora: ',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          Text(
                            horaCadastro,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Status
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusCor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          status,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      // Informações de retirada (se aplicável)
                      if (foiRetirada &&
                          dataRetirada != null &&
                          horaRetirada != null) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'Retirado em:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Text(
                              'Data: ',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF7F8C8D),
                              ),
                            ),
                            Text(
                              dataRetirada,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF7F8C8D),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Text(
                              'Hora: ',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF7F8C8D),
                              ),
                            ),
                            Text(
                              horaRetirada,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF7F8C8D),
                              ),
                            ),
                          ],
                        ),
                        
                        // Informação de quem recebeu (se disponível)
                        if (encomenda.recebidoPor != null && encomenda.recebidoPor!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Text(
                                'Recebido por: ',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF7F8C8D),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  encomenda.recebidoPor!,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF7F8C8D),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget para a aba Encomendas
  Widget _buildEncomendasTab() {
    if (_isLoadingEncomendas) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF4A90E2)),
      );
    }

    if (_encomendas.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Nenhuma encomenda encontrada',
                style: TextStyle(color: Colors.grey, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: const Color(0xFFF5F5F5),
      child: RefreshIndicator(
        onRefresh: _carregarEncomendas,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: _encomendas.length,
          itemBuilder: (context, index) {
            final encomenda = _encomendas[index];
            return _buildEncomendaCardReal(encomenda);
          },
        ),
      ),
    );
  }

  // ========== MÉTODOS PARA DATAS ESPECÍFICAS (PASSO 4) ==========

  /// Widget para seleção de datas específicas
  Widget _buildDiasEspecificosUI(StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        ElevatedButton.icon(
          icon: const Icon(Icons.calendar_today),
          label: const Text('Selecionar Datas'),
          onPressed: () => _abrirCalendario(setModalState),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4A90E2),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
        ),
        const SizedBox(height: 16),
        // Exibir datas selecionadas
        if (_diasEspecificosSelecionados.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Datas selecionadas (${_diasEspecificosSelecionados.length}):',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _diasEspecificosSelecionados
                      .map(
                        (data) {
                          final formatted = DateFormat('dd/MM/yyyy').format(data);
                          return Chip(
                            label: Text(formatted),
                            onDeleted: () {
                              setModalState(() {
                                _diasEspecificosSelecionados.remove(data);
                              });
                            },
                            backgroundColor: const Color(0xFF4A90E2),
                            labelStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                            deleteIcon: const Icon(
                              Icons.close,
                              size: 18,
                              color: Colors.white,
                            ),
                          );
                        },
                      )
                      .toList(),
                ),
              ),
            ],
          )
        else
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'Nenhuma data selecionada',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Abre o calendário para seleção de datas
  Future<void> _abrirCalendario(StateSetter setModalState) async {
    final result = await showDialog<List<DateTime>>(
      context: context,
      builder: (context) => _buildCalendarioDialog(),
    );

    if (result != null && result.isNotEmpty) {
      setModalState(() {
        _diasEspecificosSelecionados = result;
      });
    }
  }

  /// Constrói o dialog do calendário com seleção de múltiplas datas
  Widget _buildCalendarioDialog() {
    List<DateTime> selectedDates = List.from(_diasEspecificosSelecionados);
    late DateTime _focusedDay = DateTime.now();

    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: const Text('Selecionar Datas'),
          contentPadding: const EdgeInsets.all(20),
          content: SingleChildScrollView(
            child: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Calendário com TableCalendar
                  TableCalendar(
                    firstDay: DateTime(2020),
                    lastDay: DateTime(2030),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) {
                      return selectedDates.any((date) =>
                          date.year == day.year &&
                          date.month == day.month &&
                          date.day == day.day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _focusedDay = focusedDay;
                        final isSelected = selectedDates.any((date) =>
                            date.year == selectedDay.year &&
                            date.month == selectedDay.month &&
                            date.day == selectedDay.day);

                        if (isSelected) {
                          selectedDates.removeWhere((date) =>
                              date.year == selectedDay.year &&
                              date.month == selectedDay.month &&
                              date.day == selectedDay.day);
                        } else {
                          selectedDates.add(selectedDay);
                        }
                      });
                    },
                    calendarStyle: CalendarStyle(
                      selectedDecoration: BoxDecoration(
                        color: const Color(0xFF4A90E2),
                        shape: BoxShape.circle,
                      ),
                      selectedTextStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      todayDecoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      defaultDecoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      weekendDecoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Datas selecionadas
                  if (selectedDates.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${selectedDates.length} data(s) selecionada(s):',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: selectedDates
                                .map(
                                  (date) => Chip(
                                    label: Text(
                                      DateFormat('dd/MM').format(date),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    onDeleted: () {
                                      setState(() {
                                        selectedDates.remove(date);
                                      });
                                    },
                                    backgroundColor: const Color(0xFF4A90E2),
                                    labelStyle: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                    ),
                                    deleteIcon: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      'Clique nos dias para selecionar datas',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Color(0xFF7F8C8D)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Ordenar datas antes de confirmar
                selectedDates.sort();
                Navigator.pop(context, selectedDates);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90E2),
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  // ========== MÉTODOS PARA SELEÇÃO DE FOTO DO AUTORIZADO ==========

  /// Mostra diálogo perguntando se quer usar câmera ou galeria
  Future<void> _mostrarDialogSelecaoFotoAutorizado(
    StateSetter setModalState,
  ) async {
    // Na web, usar apenas galeria
    if (kIsWeb) {
      await _selecionarFotoAutorizadoGaleria(setModalState);
      return;
    }

    // Em mobile, mostrar diálogo com opções
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Selecionar Foto',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E3A59),
            ),
          ),
          content: const Text(
            'De onde você gostaria de tirar a foto?',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
          ),
          actions: [
            // Botão Câmera
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _selecionarFotoAutorizadoCamera(setModalState);
              },
              icon: const Icon(
                Icons.camera_alt,
                color: Color(0xFF1976D2),
                size: 24,
              ),
              label: const Text(
                'Câmera',
                style: TextStyle(
                  color: Color(0xFF1976D2),
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            // Botão Galeria
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _selecionarFotoAutorizadoGaleria(setModalState);
              },
              icon: const Icon(
                Icons.image,
                color: Color(0xFF1976D2),
                size: 24,
              ),
              label: const Text(
                'Galeria',
                style: TextStyle(
                  color: Color(0xFF1976D2),
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Tirar foto com a câmera do celular
  Future<void> _selecionarFotoAutorizadoCamera(StateSetter setModalState) async {
    try {
      final photoPickerService = PhotoPickerService();
      final XFile? image = await photoPickerService.pickImageFromCamera();

      if (image != null) {
        setModalState(() {
          _fotoAutorizado = image;
        });
      }
    } catch (e) {
      print('Erro ao tirar foto da câmera: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao tirar foto: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Selecionar foto da galeria
  Future<void> _selecionarFotoAutorizadoGaleria(
    StateSetter setModalState,
  ) async {
    try {
      final photoPickerService = PhotoPickerService();
      final XFile? image = await photoPickerService.pickImage();

      if (image != null) {
        setModalState(() {
          _fotoAutorizado = image;
        });
      }
    } catch (e) {
      print('Erro ao selecionar foto da galeria: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar foto: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
