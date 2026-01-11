import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../di/reserva_dependencies.dart';
import '../cubit/reserva_cubit.dart';
import '../cubit/reserva_state.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class ReservaScreen extends StatefulWidget {
  final String condominioId;
  final String usuarioId;

  const ReservaScreen({
    Key? key,
    required this.condominioId,
    required this.usuarioId,
  }) : super(key: key);

  @override
  State<ReservaScreen> createState() => _ReservaScreenState();
}

class _ReservaScreenState extends State<ReservaScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _horaInicioController = TextEditingController();
  final TextEditingController _horaFimController = TextEditingController();
  bool _termoLocacaoAceito = false;
  late ReservaCubit _cubit;
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    print('🟢 ReservaScreen INIT START - condominioId: ${widget.condominioId}');
    _tabController = TabController(length: 2, vsync: this);
    // Injetar dependências
    _cubit = ReservaDependencies.createReservaCubit();
    print('🟢 ReservaCubit criado');
    _cubit.inicializarCalendario();
    print('🟢 Calendário inicializado');
    _cubit.carregarAmbientes();
    print('🟢 Começou a carregar ambientes');
    _cubit.carregarReservas(widget.condominioId);
    print('🟢 Começou a carregar reservas');
  }

  @override
  void dispose() {
    _horaInicioController.dispose();
    _horaFimController.dispose();
    _tabController.dispose();
    _cubit.close();
    super.dispose();
  }

  /// Abre o modal de criação de reserva
void _showReservationModal(DateTime selectedDate, ReservaCubit cubit) {
  _horaInicioController.clear();
  _horaFimController.clear();
  _termoLocacaoAceito = false;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (modalContext) => BlocProvider.value(
      value: cubit,
      child: ScaffoldMessenger(
        child: Builder(
          builder: (context) => Scaffold(
            backgroundColor: Colors.transparent,
            // Usamos o Builder para garantir que o contexto do BlocListener
            // encontre o ScaffoldMessenger acima
            body: BlocListener<ReservaCubit, ReservaState>(
              listener: (context, state) {
                if (state is ReservaErro) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.mensagem),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating, // Flutuante para ficar mais visível
                      margin: EdgeInsets.only(
                        bottom: MediaQuery.of(context).size.height - 100, // Ajuste altura
                        left: 10,
                        right: 10,
                      ),
                    ),
                  );
                } else if (state is ReservaCriada) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.mensagem),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.of(modalContext).pop();
                }
              },
              child: StatefulBuilder(
                builder: (context, setModalState) => Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: MediaQuery.of(modalContext).size.height * 0.75,
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
                          Text(
                            'Reservar Dia ${DateFormat('dd/MM/yyyy').format(selectedDate)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Conteúdo do formulário
                          Expanded(
                            child: SingleChildScrollView(
                              child: _buildReservationForm(context, selectedDate, setModalState, cubit),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

  /// Constrói o formulário de reserva
  Widget _buildReservationForm(BuildContext context, DateTime selectedDate, StateSetter setModalState, ReservaCubit cubit) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Seletor de Ambiente
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Ambiente',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              TextSpan(
                text: ' *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
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
            value: cubit.ambienteSelecionado?.id,
            onChanged: (value) {
              if (value != null) {
                final ambiente =
                    cubit.ambientes.firstWhere((a) => a.id == value);
                setModalState(() {
                  cubit.atualizarAmbienteSelecionado(ambiente);
                });
              }
            },
            items: cubit.ambientes
                .map((ambiente) => DropdownMenuItem(
                      value: ambiente.id,
                      child: Text('${ambiente.nome} - R\$ ${ambiente.valor.toStringAsFixed(2)}'),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 16),

        // Valor da Locação
        if (cubit.ambienteSelecionado != null) ...[
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'Valor da Locação',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
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

        // Horários
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Hora de Início',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
                        ),
                        TextSpan(
                          text: ' *',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _horaInicioController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      MaskTextInputFormatter(
                        mask: '##:##', 
                        filter: { "#": RegExp(r'[0-9]') },
                        type: MaskAutoCompletionType.lazy,
                      )
                    ],
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      hintText: 'HH:MM',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Hora de Fim',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
                        ),
                        TextSpan(
                          text: ' *',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _horaFimController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      MaskTextInputFormatter(
                        mask: '##:##', 
                        filter: { "#": RegExp(r'[0-9]') },
                        type: MaskAutoCompletionType.lazy,
                      )
                    ],
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      hintText: 'HH:MM',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Checkbox Aceitar Termo
        Row(
          children: [
            Checkbox(
              value: _termoLocacaoAceito,
              onChanged: (value) {
                setModalState(() {
                  _termoLocacaoAceito = value ?? false;
                });
              },
            ),
            Expanded(
              child: RichText(
                text: const TextSpan(
                  children: [
                     TextSpan(
                      text: 'Aceitar Termo de Locação',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    TextSpan(
                      text: ' *',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Botão Salvar
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Parse dos horários
              final inicioParts = _horaInicioController.text.split(':');
              final fimParts = _horaFimController.text.split(':');

              if (inicioParts.length != 2 || fimParts.length != 2) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Formato de hora inválido. Use HH:MM')),
                );
                return;
              }

              final horaInicio = int.tryParse(inicioParts[0]);
              final minutoInicio = int.tryParse(inicioParts[1]);
              final horaFim = int.tryParse(fimParts[0]);
              final minutoFim = int.tryParse(fimParts[1]);

              if (horaInicio == null || minutoInicio == null ||
                  horaFim == null || minutoFim == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Horário inválido.')),
                );
                return;              
              }

              final dataBase = cubit.dataSelecionada;
              final dataInicio = DateTime(
                dataBase.year, dataBase.month, dataBase.day, horaInicio, minutoInicio);
              final dataFim = DateTime(
                dataBase.year, dataBase.month, dataBase.day, horaFim, minutoFim);

              // Atualizar cubit com datas processadas
              cubit.atualizarDataInicio(dataInicio);
              cubit.atualizarDataFim(dataFim);

              cubit.criarReserva(
                condominioId: widget.condominioId,
                usuarioId: widget.usuarioId,
                termoLocacaoAceito: _termoLocacaoAceito,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[900],
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
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
      ],
    );
  }

  /// Constrói o drawer (menu lateral)
  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header do drawer
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue[900],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo_CondoGaia.png',
                  height: 40,
                ),
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
          // Botão Voltar
          ListTile(
            leading: const Icon(Icons.arrow_back, color: Colors.black),
            title: const Text('Voltar'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pop(context); // Fechar drawer e voltar
            },
          ),
          const Divider(),
          // Botão Sair
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Sair',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              // TODO: Implementar logout
            },
          ),
        ],
      ),
    );
  }

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
            Navigator.pop(context); // Fecha o modal se estiver aberto (e talvez a tela se não estiver)
            // Precisamos garantir que fecha apenas o modal. 
            // O modal é uma rota no Flutter, então pop deve funcionar.
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
                // Cabeçalho superior com menu hamburger
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      // Botão de menu (hamburger)
                      GestureDetector(
                        onTap: () {
                          _scaffoldKey.currentState?.openDrawer();
                        },
                        child: const Icon(
                          Icons.menu,
                          size: 24,
                          color: Colors.black,
                        ),
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

                // Caminho de navegação com seta
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      // Seta de voltar
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(
                          Icons.arrow_back_ios,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Breadcrumb
                      Expanded(
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Home',
                                style: TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                              const Text(
                                ' / ',
                                style: TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                              const Text(
                                'Reservas',
                                style: TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Linha de separação
                Container(
                  height: 1,
                  color: Colors.grey[300],
                ),

                // TabBar com abas brancas
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.black87,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.blue[900],
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(text: 'Calendário'),
                      Tab(text: 'Minhas Reservas'),
                    ],
                  ),
                ),

                // Conteúdo das abas
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCalendarTab(),
                      _buildMinhasReservasTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarTab() {
    return BlocBuilder<ReservaCubit, ReservaState>(
      builder: (context, state) {
        print('📊 ReservaState: ${state.runtimeType}');
        
        final cubit = context.read<ReservaCubit>();

        if (state is ReservaLoading && cubit.reservas.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Seletor de Mês
              _buildMonthSelector(cubit),
              const SizedBox(height: 20),

              // Cabeçalho do Calendário (Dom, Seg, Ter, etc)
              _buildCalendarHeader(),
              const SizedBox(height: 10),

              // Grid do Calendário
              _buildCalendarGrid(cubit),
              const SizedBox(height: 24),

              // Título de Reservas do dia
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Reservados - Dia ${DateFormat('dd/MM/yyyy').format(cubit.dataSelecionada)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      final now = DateTime.now();
                      final tomorrow = DateTime(now.year, now.month, now.day + 1);
                      final selectedDate = DateTime(
                          cubit.dataSelecionada.year,
                          cubit.dataSelecionada.month,
                          cubit.dataSelecionada.day);

                      if (selectedDate.isBefore(tomorrow)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Reservas só podem ser feitas para dias futuros.')),
                        );
                        return;
                      }
                      _showReservationModal(cubit.dataSelecionada, cubit);
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[200],
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

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
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cubit.reservasDoDia.length,
                  itemBuilder: (context, index) {
                    final reserva = cubit.reservasDoDia[index];
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
                          // Título (Local da Reserva)
                          Text(
                            reserva.local,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Horários
                          Text(
                            'Horário: ${reserva.horaInicio} - ${reserva.horaFim}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),

                          // Valor da Locação
                          const SizedBox(height: 4),
                          Text(
                            'Valor: R\$ ${reserva.valorLocacao.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          // Para (Responsável)
                          if (reserva.para != 'Condomínio')
                            Text(
                              'Para: ${reserva.para}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          const SizedBox(height: 12),

                          const SizedBox(height: 12),

                            // Botão deletar
                          if (reserva.representanteId == widget.usuarioId)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    context.read<ReservaCubit>().cancelarReserva(reserva.id);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.red[300],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'Deletar',
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
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMonthSelector(ReservaCubit cubit) {
    final meses = [
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
            cubit.mesPosterior();
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
    final daysInMonth =
        _getDaysInMonth(cubit.mesAtual + 1, cubit.anoAtual);
    final firstDayOfWeek =
        _getFirstDayOfWeek(cubit.mesAtual + 1, cubit.anoAtual);

    List<Widget> days = [];

    // Dias vazios do mês anterior
    for (int i = 0; i < firstDayOfWeek; i++) {
      days.add(Container());
    }

    // Dias do mês
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(cubit.anoAtual, cubit.mesAtual + 1, day);
      final isSelected = date.day == cubit.dataSelecionada.day &&
          date.month == cubit.dataSelecionada.month &&
          date.year == cubit.dataSelecionada.year;
      final isToday = date.day == cubit.today.day &&
          date.month == cubit.today.month &&
          date.year == cubit.today.year;
      final hasReservation = cubit.reservas.any((r) =>
          r.dataReserva.day == day &&
          r.dataReserva.month == cubit.mesAtual + 1 &&
          r.dataReserva.year == cubit.anoAtual);

      days.add(_buildCalendarDay(
        day: day,
        isSelected: isSelected,
        isToday: isToday,
        hasReservation: hasReservation,
        onTap: () {
          cubit.selecionarDia(day);
          setState(() {});
        },
      ));
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
              ? Colors.blue[900]
              : isToday
                  ? Colors.blue[100]
                  : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: isToday ? Border.all(color: Colors.blue, width: 2) : null,
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
                          ? Colors.blue[900]
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



  Widget _buildMinhasReservasTab() {
    return BlocBuilder<ReservaCubit, ReservaState>(
      builder: (context, state) {
        final cubit = context.read<ReservaCubit>();

        // Filtrar apenas as reservas do usuário logado (Inquilino ou Representante)
        final minhasReservas = cubit.reservas.where((r) {
          return r.inquilinoId == widget.usuarioId || 
                 r.representanteId == widget.usuarioId;
        }).toList();

        if (state is ReservaLoading && cubit.reservas.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (minhasReservas.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Nenhuma reserva criada',
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
                  // Titulo (Local da Reserva)
                  Text(
                    reserva.local,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Responsável (Para)
                  if (reserva.para != 'Condomínio')
                    Text(
                      'Para: ${reserva.para}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                  const SizedBox(height: 8),

                  // Data
                  Text(
                    'Data: ${DateFormat('dd/MM/yyyy').format(reserva.dataReserva)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),

                  // Horários
                  Text(
                    'Horário: ${reserva.horaInicio} - ${reserva.horaFim}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),

                  // Valor da Locação
                  const SizedBox(height: 4),
                  Text(
                    'Valor: R\$ ${reserva.valorLocacao.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Botão deletar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          cubit.cancelarReserva(reserva.id);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.red[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Deletar',
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
          },
        );
      },
    );
  }

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
