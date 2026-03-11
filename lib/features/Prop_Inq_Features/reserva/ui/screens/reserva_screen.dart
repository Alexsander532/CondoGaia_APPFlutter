import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../services/excel_service.dart';
import '../di/reserva_dependencies.dart';
import '../cubit/reserva_cubit.dart';
import '../cubit/reserva_state.dart';
import '../../domain/entities/reserva_entity.dart';

class ReservaScreen extends StatefulWidget {
  final String condominioId;
  final String usuarioId;
  final bool isInquilino;
  final bool isProprietario;

  const ReservaScreen({
    Key? key,
    required this.condominioId,
    required this.usuarioId,
    this.isInquilino = true,
    this.isProprietario = false,
  }) : super(key: key);

  @override
  State<ReservaScreen> createState() => _ReservaScreenState();
}

class _ReservaScreenState extends State<ReservaScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _horaInicioController = TextEditingController();
  final TextEditingController _horaFimController = TextEditingController();
  final TextEditingController _listaPresentesController =
      TextEditingController();
  final _horaInicioFormatter = MaskTextInputFormatter(
    mask: '##:##',
    filter: {"#": RegExp(r'[0-9]')},
  );
  final _horaFimFormatter = MaskTextInputFormatter(
    mask: '##:##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  bool _termoLocacaoAceito = false;
  String? _uploadedFileName;
  List<String> _listaPresentesArray = [];
  bool _isSaving = false;

  late ReservaCubit _cubit;
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cubit = ReservaDependencies.createReservaCubit();
    _cubit.inicializarCalendario();
    _cubit.carregarTudo(widget.condominioId);
  }

  @override
  void dispose() {
    _horaInicioController.dispose();
    _horaFimController.dispose();
    _listaPresentesController.dispose();
    _tabController.dispose();
    _cubit.close();
    super.dispose();
  }

  // ─── Formato de lista de presença ─────────────────────────────────────────

  String _formatarListaModal(List<String> nomes) {
    final buffer = StringBuffer();
    for (int i = 0; i < nomes.length; i++) {
      buffer.write('${i + 1} - ${nomes[i]}');
      if (i < nomes.length - 1) buffer.write('\n');
    }
    return buffer.toString();
  }

  String _listaParaJson(List<String> nomes) => jsonEncode(nomes);

  void _resetListaPresentes({StateSetter? setModalState}) {
    void update() {
      _listaPresentesController.clear();
      _listaPresentesArray = [];
      _uploadedFileName = null;
    }

    if (setModalState != null) {
      setModalState(update);
    } else {
      setState(update);
    }
  }

  // ─── Confirmação de exclusão ───────────────────────────────────────────────

  void _confirmarExclusao(
    BuildContext ctx,
    ReservaEntity reserva,
    ReservaCubit cubit,
  ) {
    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Cancelar Reserva'),
        content: Text(
          'Tem certeza que deseja cancelar a reserva de "${reserva.local}" em '
          '${reserva.dataReserva.day}/${reserva.dataReserva.month}/${reserva.dataReserva.year}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Não'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(dialogCtx);
              cubit.cancelarReserva(reserva.id);
            },
            child: const Text(
              'Confirmar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Modal de Criar Reserva ────────────────────────────────────────────────

  void _showReservationModal(DateTime selectedDate, ReservaCubit cubit) {
    _horaInicioController.clear();
    _horaFimController.clear();
    _listaPresentesController.clear();
    _listaPresentesArray = [];
    _uploadedFileName = null;
    _termoLocacaoAceito = false;
    _isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => StatefulBuilder(
        builder: (modalContext, setModalState) => Container(
          height: MediaQuery.of(modalContext).size.height * 0.85,
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
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Título do modal
                Text(
                  'Reservar — ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF003E7E),
                  ),
                ),
                const SizedBox(height: 20),

                // Conteúdo do formulário
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildReservationForm(
                      selectedDate,
                      setModalState,
                      cubit,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Formulário de Reserva ─────────────────────────────────────────────────

  Widget _buildReservationForm(
    DateTime selectedDate,
    StateSetter setModalState,
    ReservaCubit cubit,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Ambiente
        _buildLabel('Ambiente', required: true),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButton<String>(
            isExpanded: true,
            underline: const SizedBox(),
            hint: const Text('Selecione um ambiente'),
            value: cubit.ambienteSelecionado?.id,
            onChanged: (value) {
              if (value != null) {
                final ambiente = cubit.ambientes.firstWhere(
                  (a) => a.id == value,
                );
                setModalState(() {
                  cubit.atualizarAmbienteSelecionado(ambiente);
                });
              }
            },
            items: cubit.ambientes
                .map(
                  (ambiente) => DropdownMenuItem(
                    value: ambiente.id,
                    child: Text(
                      '${ambiente.nome} — R\$ ${ambiente.valor.toStringAsFixed(2)}',
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 16),

        // ── Valor da Locação (somente leitura)
        if (cubit.ambienteSelecionado != null) ...[
          _buildLabel('Valor da Locação'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[50],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Text(
              'R\$ ${cubit.ambienteSelecionado!.valor.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // ── Horários
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Hora de Início', required: true),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _horaInicioController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [_horaInicioFormatter],
                    onChanged: (value) =>
                        _atualizarDataInicio(value, selectedDate, cubit),
                    decoration: _inputDecoration('HH:MM'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Hora de Fim', required: true),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _horaFimController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [_horaFimFormatter],
                    onChanged: (value) =>
                        _atualizarDataFim(value, selectedDate, cubit),
                    decoration: _inputDecoration('HH:MM'),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ── Lista de Presentes
        _buildLabel('Lista de Presentes'),
        const SizedBox(height: 8),
        TextField(
          controller: _listaPresentesController,
          onChanged: (_) {
            setModalState(() {
              _listaPresentesArray = [];
            });
          },
          maxLines: 4,
          decoration: _inputDecoration(
            'Digite os nomes dos presentes ou faça upload de planilha...',
          ),
        ),
        const SizedBox(height: 8),

        // Botão de upload Excel
        GestureDetector(
          onTap: () async => _pickExcelFile(setModalState),
          child: Row(
            children: [
              const Icon(
                Icons.cloud_upload_outlined,
                color: Color(0xFF003E7E),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _uploadedFileName ?? 'Fazer Upload da Lista (.xlsx)',
                  style: TextStyle(
                    color:
                        _uploadedFileName != null &&
                            _uploadedFileName!.contains('✓')
                        ? Colors.green[700]
                        : const Color(0xFF003E7E),
                    fontSize: 13,
                    fontWeight:
                        _uploadedFileName != null &&
                            _uploadedFileName!.contains('✓')
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (_uploadedFileName != null)
                GestureDetector(
                  onTap: () =>
                      _resetListaPresentes(setModalState: setModalState),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(Icons.close, size: 18, color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Termo de Locação
        Row(
          children: [
            Checkbox(
              value: _termoLocacaoAceito,
              activeColor: const Color(0xFF003E7E),
              onChanged: (value) {
                setModalState(() {
                  _termoLocacaoAceito = value ?? false;
                });
              },
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  final url = cubit.ambienteSelecionado?.locacaoUrl;
                  if (url != null && url.isNotEmpty) {
                    _abrirTermoLocacao(url);
                  }
                },
                child: Text(
                  cubit.ambienteSelecionado?.locacaoUrl != null &&
                          cubit.ambienteSelecionado!.locacaoUrl!.isNotEmpty
                      ? 'Aceitar Termo de Locação (Ver Termo)'
                      : 'Aceitar Termo de Locação',
                  style: TextStyle(
                    fontSize: 13,
                    color: const Color(0xFF003E7E),
                    fontStyle: FontStyle.italic,
                    decoration:
                        cubit.ambienteSelecionado?.locacaoUrl != null &&
                            cubit.ambienteSelecionado!.locacaoUrl!.isNotEmpty
                        ? TextDecoration.underline
                        : TextDecoration.none,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ── Botão Salvar
        SizedBox(
          width: double.infinity,
          child: StatefulBuilder(
            builder: (ctx, setSaveState) => ElevatedButton(
              onPressed: _isSaving
                  ? null
                  : () => _salvarReserva(
                      cubit: cubit,
                      selectedDate: selectedDate,
                      setModalState: setModalState,
                      setSaveState: setSaveState,
                    ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003E7E),
                disabledBackgroundColor: Colors.grey[400],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
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
        const SizedBox(height: 16),
      ],
    );
  }

  // ─── Salvar Reserva (aguarda async antes de fechar modal) ─────────────────

  Future<void> _salvarReserva({
    required ReservaCubit cubit,
    required DateTime selectedDate,
    required StateSetter setModalState,
    required StateSetter setSaveState,
  }) async {
    setSaveState(() => _isSaving = true);

    // Montar listaPresentes
    String? listaPresentes;
    if (_listaPresentesArray.isNotEmpty) {
      listaPresentes = _listaParaJson(_listaPresentesArray);
    } else if (_listaPresentesController.text.trim().isNotEmpty) {
      listaPresentes = _listaPresentesController.text.trim();
    }

    await cubit.criarReserva(
      condominioId: widget.condominioId,
      usuarioId: widget.usuarioId,
      termoLocacaoAceito: _termoLocacaoAceito,
      isInquilino: widget.isInquilino,
      isProprietario: widget.isProprietario,
      listaPresentes: listaPresentes,
      para: 'Bloco/Unid',
    );

    setSaveState(() => _isSaving = false);

    if (!mounted) return;

    // Fechar modal apenas se não houve erro (estado emit pelo cubit)
    final state = cubit.state;
    if (state is ReservaCriada) {
      Navigator.pop(context);
    }
  }

  // ─── Upload de Excel ───────────────────────────────────────────────────────

  Future<void> _pickExcelFile(StateSetter setModalState) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result == null) return;

      setModalState(() {
        _uploadedFileName = '${result.files.single.name} (lendo...)';
      });

      try {
        final nomes = await ExcelService.lerColuna(result.files.single);

        if (nomes.isNotEmpty) {
          final listaNumerada = _formatarListaModal(nomes);
          setModalState(() {
            _listaPresentesController.text = listaNumerada;
            _listaPresentesArray = nomes;
            _uploadedFileName =
                '${result.files.single.name} ✓ (${nomes.length} nomes)';
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✓ ${nomes.length} nome(s) importado(s)!'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } else {
          setModalState(() => _uploadedFileName = null);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('❌ Nenhum nome encontrado na coluna A'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      } catch (e) {
        setModalState(() => _uploadedFileName = null);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Erro ao ler arquivo: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (_) {
      // Usuário cancelou o picker
    }
  }

  // ─── Abrir Termo de Locação PDF ──────────────────────────────────────────

  Future<void> _abrirTermoLocacao(String locacaoUrl) async {
    try {
      final Uri url = Uri.parse(locacaoUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Não foi possível abrir o termo de locação'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao abrir documento: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Widget _buildLabel(String text, {bool required = false}) {
    if (!required) {
      return Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      );
    }
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const TextSpan(
            text: ' *',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      hintText: hint,
    );
  }

  void _atualizarDataInicio(
    String horaStr,
    DateTime dataBase,
    ReservaCubit cubit,
  ) {
    if (horaStr.length == 5 && horaStr.contains(':')) {
      final partes = horaStr.split(':');
      final hora = int.tryParse(partes[0]);
      final minuto = int.tryParse(partes[1]);
      if (hora != null && minuto != null) {
        cubit.atualizarDataInicio(
          DateTime(dataBase.year, dataBase.month, dataBase.day, hora, minuto),
        );
      }
    } else {
      cubit.atualizarDataInicio(null);
    }
  }

  void _atualizarDataFim(
    String horaStr,
    DateTime dataBase,
    ReservaCubit cubit,
  ) {
    if (horaStr.length == 5 && horaStr.contains(':')) {
      final partes = horaStr.split(':');
      final hora = int.tryParse(partes[0]);
      final minuto = int.tryParse(partes[1]);
      if (hora != null && minuto != null) {
        cubit.atualizarDataFim(
          DateTime(dataBase.year, dataBase.month, dataBase.day, hora, minuto),
        );
      }
    } else {
      cubit.atualizarDataFim(null);
    }
  }

  // ─── Drawer ───────────────────────────────────────────────────────────────

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF003E7E)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/logo_CondoGaia.png', height: 40),
                const SizedBox(height: 16),
                const Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.arrow_back, color: Colors.black),
            title: const Text('Voltar'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sair', style: TextStyle(color: Colors.red)),
            onTap: () {
              // TODO: Implementar logout
            },
          ),
        ],
      ),
    );
  }

  // ─── Build Principal ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _cubit,
      child: BlocListener<ReservaCubit, ReservaState>(
        listener: (context, state) {
          if (state is ReservaCriada) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.mensagem),
                backgroundColor: Colors.green,
              ),
            );
            // Recarregar após criar/atualizar
            _cubit.carregarReservas(widget.condominioId);
          } else if (state is ReservaCancelada) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.mensagem),
                backgroundColor: Colors.orange,
              ),
            );
          } else if (state is ReservaErro) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.mensagem),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.white,
          drawer: _buildDrawer(),
          body: SafeArea(
            child: Column(
              children: [
                // Cabeçalho
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => _scaffoldKey.currentState?.openDrawer(),
                        child: const Icon(
                          Icons.menu,
                          size: 24,
                          color: Colors.black,
                        ),
                      ),
                      const Spacer(),
                      Image.asset(
                        'assets/images/logo_CondoGaia.png',
                        height: 32,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {},
                            child: Image.asset(
                              'assets/images/Sino_Notificacao.png',
                              width: 24,
                              height: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () {},
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
                Container(height: 1, color: Colors.grey[300]),

                // Breadcrumb
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back_ios,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Home / Reservas',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(height: 1, color: Colors.grey[300]),

                // TabBar
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.black87,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: const Color(0xFF003E7E),
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(text: 'Calendário'),
                      Tab(text: 'Minhas Reservas'),
                    ],
                  ),
                ),

                // Conteúdo
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [_buildCalendarTab(), _buildMinhasReservasTab()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Aba Calendário ───────────────────────────────────────────────────────

  Widget _buildCalendarTab() {
    return BlocBuilder<ReservaCubit, ReservaState>(
      builder: (context, state) {
        final cubit = context.read<ReservaCubit>();

        if (state is ReservaLoading && cubit.reservas.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMonthSelector(cubit),
              const SizedBox(height: 20),
              _buildCalendarHeader(),
              const SizedBox(height: 10),
              _buildCalendarGrid(cubit),
              const SizedBox(height: 24),

              // Título + botão adicionar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Reservas — ${cubit.dataSelecionada.day}/${cubit.dataSelecionada.month}/${cubit.dataSelecionada.year}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        _showReservationModal(cubit.dataSelecionada, cubit),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF003E7E), // Azul CondoGaia
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Reservas do dia
              if (cubit.reservasDoDia.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Nenhuma reserva neste dia',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ...cubit.reservasDoDia.map(
                  (reserva) => _buildReservaCard(reserva, cubit, context),
                ),
            ],
          ),
        );
      },
    );
  }

  // ─── Aba Minhas Reservas ──────────────────────────────────────────────────

  Widget _buildMinhasReservasTab() {
    return BlocBuilder<ReservaCubit, ReservaState>(
      builder: (context, state) {
        final cubit = context.read<ReservaCubit>();

        if (state is ReservaLoading && cubit.reservas.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final now = DateTime.now();
        final startOfToday = DateTime(now.year, now.month, now.day);

        // Filtrar reservas:
        // 1) O usuário logado deve ser o inquilino ou proprietário
        // 2) A reserva deve ser para hoje ou alguma data no futuro
        final minhasReservas = cubit.reservas.where((reserva) {
          final isOwner =
              reserva.inquilinoId == widget.usuarioId ||
              reserva.proprietarioId == widget.usuarioId;
          final isFutureOrToday = !reserva.dataReserva.isBefore(startOfToday);
          return isOwner && isFutureOrToday;
        }).toList();

        // Ordenar as reservas da data mais próxima para a mais distante
        minhasReservas.sort((a, b) => a.dataReserva.compareTo(b.dataReserva));

        if (minhasReservas.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Nenhuma reserva futura encontrada',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: minhasReservas.length,
          itemBuilder: (context, index) {
            final reserva = minhasReservas[index];
            return _buildReservaCard(reserva, cubit, context);
          },
        );
      },
    );
  }

  // ─── Card de Reserva ──────────────────────────────────────────────────────

  Widget _buildReservaCard(
    ReservaEntity reserva,
    ReservaCubit cubit,
    BuildContext ctx,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[900]!, Colors.blue[800]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            reserva.local,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Data: ${reserva.dataReserva.day}/${reserva.dataReserva.month}/${reserva.dataReserva.year}',
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
          Text(
            'Horário: ${reserva.horaInicio} — ${reserva.horaFim}',
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
          Text(
            'Para: ${reserva.para}',
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            'Valor: R\$ ${reserva.valorLocacao.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.greenAccent,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (reserva.listaPresentes != null &&
              reserva.listaPresentes!.isNotEmpty) ...[
            const SizedBox(height: 4),
            const Text(
              'Lista de presentes cadastrada ✓',
              style: TextStyle(
                fontSize: 11,
                color: Colors.greenAccent,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 12),
          // Exibir o botão de cancelar apenas se a reserva pertencer ao usuário
          if (reserva.inquilinoId == widget.usuarioId ||
              reserva.proprietarioId == widget.usuarioId)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => _confirmarExclusao(ctx, reserva, cubit),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red[400],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Cancelar Reserva',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // ─── Calendário ───────────────────────────────────────────────────────────

  Widget _buildMonthSelector(ReservaCubit cubit) {
    const meses = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            cubit.mesAnterior();
            setState(() {});
          },
          icon: const Icon(Icons.chevron_left, size: 28),
        ),
        Text(
          '${meses[cubit.mesAtual]} ${cubit.anoAtual}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        IconButton(
          onPressed: () {
            cubit.proximoMes();
            setState(() {});
          },
          icon: const Icon(Icons.chevron_right, size: 28),
        ),
      ],
    );
  }

  Widget _buildCalendarHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: const ['DOM', 'SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SÁB']
          .map(
            (day) => Expanded(
              child: Center(
                child: Text(
                  day,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildCalendarGrid(ReservaCubit cubit) {
    final daysInMonth = _getDaysInMonth(cubit.mesAtual + 1, cubit.anoAtual);
    final firstDayOfWeek = _getFirstDayOfWeek(
      cubit.mesAtual + 1,
      cubit.anoAtual,
    );

    final List<Widget> days = [];

    for (int i = 0; i < firstDayOfWeek; i++) {
      days.add(Container());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(cubit.anoAtual, cubit.mesAtual + 1, day);
      final isSelected =
          date.day == cubit.dataSelecionada.day &&
          date.month == cubit.dataSelecionada.month &&
          date.year == cubit.dataSelecionada.year;
      final isToday =
          date.day == cubit.today.day &&
          date.month == cubit.today.month &&
          date.year == cubit.today.year;
      final hasReservation = cubit.reservas.any(
        (r) =>
            r.dataReserva.day == day &&
            r.dataReserva.month == cubit.mesAtual + 1 &&
            r.dataReserva.year == cubit.anoAtual,
      );

      days.add(
        _buildCalendarDay(
          day: day,
          isSelected: isSelected,
          isToday: isToday,
          hasReservation: hasReservation,
          onTap: () {
            cubit.selecionarDia(day);
            setState(() {});
          },
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: days,
    );
  }

  Widget _buildCalendarDay({
    required int day,
    required bool isSelected,
    required bool isToday,
    required bool hasReservation,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF003E7E)
              : isToday
              ? Colors.blue[100]
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: isToday
              ? Border.all(color: const Color(0xFF003E7E), width: 2)
              : null,
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                day.toString(),
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : isToday
                      ? const Color(0xFF003E7E)
                      : Colors.black87,
                  fontWeight: isSelected || isToday
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
            if (hasReservation)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── Utilitários de Calendário ────────────────────────────────────────────

  int _getDaysInMonth(int month, int year) {
    if (month == 2) {
      return (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)) ? 29 : 28;
    } else if ([4, 6, 9, 11].contains(month)) {
      return 30;
    } else {
      return 31;
    }
  }

  int _getFirstDayOfWeek(int month, int year) {
    return DateTime(year, month, 1).weekday % 7;
  }
}
