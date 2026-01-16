import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'configurar_ambientes_screen.dart';
import '../models/ambiente.dart';
import '../models/representante.dart';
import '../models/reserva.dart';
import '../models/unidade.dart';
import '../services/ambiente_service.dart';
import '../services/reserva_service.dart';
import '../services/supabase_service.dart';
import '../services/excel_service.dart';

class ReservasScreen extends StatefulWidget {
  final Representante? representante;
  final String? condominioId;

  const ReservasScreen({super.key, this.representante, this.condominioId});

  @override
  State<ReservasScreen> createState() => _ReservasScreenState();
}

class _ReservasScreenState extends State<ReservasScreen> {
  // Variáveis para controle do calendário
  late final DateTime _today;
  late DateTime _selectedDate;
  late int _currentMonthIndex;
  late int _currentYear;
  final List<String> _months = const [
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

  // Controladores para os campos do formulário
  final TextEditingController _valorController = TextEditingController(
    text: 'R\$ 100,00',
  );
  final TextEditingController _horaInicioController = TextEditingController();
  final TextEditingController _horaFimController = TextEditingController();
  final TextEditingController _listaPresentesController =
      TextEditingController();

  // Variáveis para controle do formulário
  bool _isCondominio = true;
  bool _isBlocoUnid = false;
  bool _termoLocacaoAceito = false;

  // Unidades para Bloco/Unid
  List<Unidade> _unidades = [];
  String? _selectedUnidadeId;

  // Ambientes carregados
  List<Ambiente> _ambientes = [];
  bool _ambientesCarregando = false;
  String? _selectedAmbienteId;

  // Reservas carregadas
  List<Reserva> _reservas = [];
  Set<int> _diasComReservas = {};

  // Arquivo de lista de presentes
  String? _uploadedFileName;
  List<String> _listaPresentesArray =
      []; // Lista de presença como array para salvar no banco

  // Formata a lista de presença para exibição no MODAL (numerado)
  String _formatarListaPresencaModal(List<String> nomes) {
    final buffer = StringBuffer();
    for (int i = 0; i < nomes.length; i++) {
      buffer.write('${i + 1} - ${nomes[i]};');
      if (i < nomes.length - 1) {
        buffer.write('\n');
      }
    }
    return buffer.toString();
  }

  // Formata a lista de presença para exibição no CARD (simples, separado por vírgula)
  String _formatarListaPresencaCard(List<String> nomes) {
    return nomes.join(', ');
  }

  // Renderiza lista de presença para o CARD (formato simples)
  String _renderListaPresencaCard(String valor) {
    try {
      final decoded = jsonDecode(valor);
      if (decoded is List) {
        final nomes = decoded.map((e) => e.toString()).toList();
        return _formatarListaPresencaCard(nomes);
      }
    } catch (_) {
      // Ignora erro e retorna valor cru
    }
    return valor;
  }

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _selectedDate = _today;
    _currentMonthIndex = _selectedDate.month - 1;
    _currentYear = _selectedDate.year;
    _carregarAmbientes();
    _carregarUnidades();
    _carregarReservas();
  }

  Future<void> _carregarAmbientes() async {
    setState(() {
      _ambientesCarregando = true;
    });

    try {
      final ambientes = await AmbienteService.getAmbientes();
      setState(() {
        _ambientes = ambientes;
        if (ambientes.isNotEmpty) {
          _selectedAmbienteId = ambientes.first.id;
        }
        _ambientesCarregando = false;
      });
    } catch (e) {
      setState(() {
        _ambientesCarregando = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar ambientes: $e')),
        );
      }
    }
  }

  Future<void> _carregarUnidades() async {
    // Se o condomínio ID não está disponível, não carrega unidades
    if (widget.condominioId == null) return;

    try {
      // Buscar unidades do condomínio usando Supabase
      final unidadesResponse = await SupabaseService.client
          .from('unidades')
          .select()
          .eq('condominio_id', widget.condominioId!)
          .eq('ativo', true)
          .order('numero');

      final unidades = unidadesResponse
          .map<Unidade>((json) => Unidade.fromJson(json))
          .toList();

      setState(() {
        _unidades = unidades;
        if (unidades.isNotEmpty) {
          _selectedUnidadeId = unidades.first.id;
        }
      });
    } catch (e) {
      print('❌ Erro ao carregar unidades: $e');
    }
  }

  Future<Unidade?> _getUnidadeById(String unidadeId) async {
    try {
      final response = await SupabaseService.client
          .from('unidades')
          .select()
          .eq('id', unidadeId)
          .single();

      return Unidade.fromJson(response);
    } catch (e) {
      print('❌ Erro ao buscar unidade: $e');
      return null;
    }
  }

  Future<void> _carregarReservas() async {
    // Se representante não está disponível, não carrega reservas
    if (widget.representante == null) return;

    try {
      final reservas = await ReservaService.getReservasRepresentante(
        widget.representante!.id,
      );

      // Extrair os dias que têm reservas
      final diasComReservas = <int>{};
      for (var reserva in reservas) {
        // Se a reserva for no mesmo mês e ano, adiciona o dia
        if (reserva.dataReserva.month == _currentMonthIndex + 1 &&
            reserva.dataReserva.year == _currentYear) {
          diasComReservas.add(reserva.dataReserva.day);
        }
      }

      setState(() {
        _reservas = reservas;
        _diasComReservas = diasComReservas;
      });
    } catch (e) {
      print('❌ Erro ao carregar reservas: $e');
    }
  }

  // Função para formatar hora removendo segundos
  String _formatarHora(String hora) {
    try {
      // Se vier no formato HH:MM:SS, remove os segundos
      if (hora.length >= 5) {
        return hora.substring(0, 5); // Retorna apenas HH:MM
      }
      return hora;
    } catch (e) {
      return hora;
    }
  }

  Future<void> _salvarReserva([BuildContext? context]) async {
    final ctx = context ?? this.context;
    try {
      // Validar campos obrigatórios
      if (_selectedAmbienteId == null || _selectedAmbienteId!.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(content: Text('Selecione um ambiente')),
          );
        }
        return;
      }

      if (_horaInicioController.text.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(content: Text('Preencha a hora de início')),
          );
        }
        return;
      }

      if (_horaFimController.text.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(content: Text('Preencha a hora de fim')),
          );
        }
        return;
      }

      // Validar se hora de fim é maior que hora de início
      final horaInicio = _horaInicioController.text;
      final horaFim = _horaFimController.text;

      if (horaFim.compareTo(horaInicio) <= 0) {
        if (mounted) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(
              content: Text('Hora de fim deve ser posterior à hora de início'),
            ),
          );
        }
        return;
      }

      // Validar se o termo de locação foi aceito
      if (!_termoLocacaoAceito) {
        if (mounted) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(
              content: Text(
                'Você deve aceitar os termos e condições de locação',
              ),
              backgroundColor: Color(0xFFE74C3C),
            ),
          );
        }
        return;
      }

      // Validar se a data é no futuro (usando horário de Brasília)
      final agora = DateTime.now().toUtc();
      final agoraBrasilia = agora.add(const Duration(hours: -3));
      final todayBrasilia = DateTime(
        agoraBrasilia.year,
        agoraBrasilia.month,
        agoraBrasilia.day,
      );
      final selectedDateWithoutTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
      );

      if (selectedDateWithoutTime.isBefore(todayBrasilia) ||
          selectedDateWithoutTime.isAtSameMomentAs(todayBrasilia)) {
        if (mounted) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(
              content: Text('A reserva deve ser para uma data futura'),
            ),
          );
        }
        return;
      }

      // Obter o ambiente selecionado para pegar o nome (local)
      final ambiente = _ambientes.firstWhere(
        (a) => a.id == _selectedAmbienteId,
        orElse: () => Ambiente(titulo: '', valor: 0),
      );

      // Obter o valor da locação (remover 'R$ ' e converter)
      double valorLocacao = 0.0;
      try {
        final valorText = _valorController.text
            .replaceAll('R\$ ', '')
            .replaceAll('.', '')
            .replaceAll(',', '.');
        valorLocacao = double.parse(valorText);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            ctx,
          ).showSnackBar(const SnackBar(content: Text('Valor inválido')));
        }
        return;
      }

      // Mostrar indicador de carregamento
      if (mounted) {
        showDialog(
          context: ctx,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return const Dialog(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Salvando reserva...'),
                  ],
                ),
              ),
            );
          },
        );
      }

      // Validar se representante está disponível
      if (widget.representante == null) {
        if (mounted) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(
              content: Text('Erro: Representante não identificado'),
            ),
          );
        }
        return;
      }

      // Validar se unidade foi selecionada quando é Bloco/Unid
      if (_isBlocoUnid && _selectedUnidadeId == null) {
        if (mounted) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(
              content: Text('Selecione uma unidade para continuar'),
            ),
          );
        }
        return;
      }

      // Criar a reserva
      print('🔵 [ReservasScreen] Iniciando save da reserva...');
      print(
        '🔵 [ReservasScreen] Representante ID: ${widget.representante!.id}',
      );
      print('🔵 [ReservasScreen] Ambiente ID: $_selectedAmbienteId');

      // Converter lista de presentes em JSON se houver
      String? listaPresEntesJson;
      if (_listaPresentesArray.isNotEmpty) {
        listaPresEntesJson = jsonEncode(_listaPresentesArray);
      }

      await ReservaService.criarReserva(
        representanteId: widget.representante!.id,
        ambienteId: _selectedAmbienteId!,
        dataReserva: _selectedDate,
        horaInicio: horaInicio,
        horaFim: horaFim,
        valorLocacao: valorLocacao,
        para: _isCondominio ? 'Condomínio' : 'Bloco/Unid',
        local: ambiente.titulo,
        listaPresentes:
            listaPresEntesJson ??
            (_listaPresentesController.text.isNotEmpty
                ? _listaPresentesController.text
                : null),
        termoLocacao: _termoLocacaoAceito,
        blocoUnidadeId: _isBlocoUnid ? _selectedUnidadeId : null,
      );

      // Fechar o diálogo de carregamento
      if (mounted) {
        Navigator.of(ctx, rootNavigator: false).pop(); // Fecha apenas o dialog
      }

      print('✅ [ReservasScreen] Reserva criada com sucesso!');

      // Mostrar mensagem de sucesso
      if (mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(
            content: Text('Reserva criada com sucesso!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
      // Recarregar reservas para aparecer automaticamente
      await _carregarReservas();

      // Limpar os campos
      _horaInicioController.clear();
      _horaFimController.clear();
      _listaPresentesController.clear();
      _listaPresentesArray = [];
      _valorController.text = 'R\$ 100,00';

      // Fechar o modal após um curto delay
      await Future.delayed(const Duration(milliseconds: 00));
      if (mounted) {
        Navigator.of(ctx, rootNavigator: false).pop(); // Fecha apenas o modal
      }
    } catch (e, stackTrace) {
      print('❌ [ReservasScreen] ERRO: $e');
      print('❌ [ReservasScreen] Stack trace: $stackTrace');

      // Fechar o diálogo de carregamento se estiver aberto
      //if (mounted) {
      //  Navigator.of(context, rootNavigator: false).pop(); // Fecha apenas o dialog
      //}

      // Mostrar mensagem de erro
      if (mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar reserva: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _editarReserva(Reserva reserva) async {
    // Preencher os campos com os dados da reserva
    _selectedAmbienteId = reserva.ambienteId;

    // Encontrar a hora inicial e final
    final horaInicio = reserva.horaInicio;
    final horaFim = reserva.horaFim;

    _horaInicioController.text = horaInicio;
    _horaFimController.text = horaFim;

    _listaPresentesArray = [];
    if (reserva.listaPresentes != null && reserva.listaPresentes!.isNotEmpty) {
      final rawLista = reserva.listaPresentes!;
      bool conseguiuConverter = false;
      try {
        final decoded = jsonDecode(rawLista);
        if (decoded is List) {
          _listaPresentesArray = decoded.map((e) => e.toString()).toList();
          _listaPresentesController.text = _formatarListaPresencaModal(
            _listaPresentesArray,
          );
          conseguiuConverter = true;
        }
      } catch (_) {
        conseguiuConverter = false;
      }

      if (!conseguiuConverter) {
        _listaPresentesController.text = rawLista;
      }
    } else {
      _listaPresentesController.clear();
    }

    final ambiente = _ambientes.firstWhere(
      (a) => a.id == reserva.ambienteId,
      orElse: () => Ambiente(titulo: '', valor: 0),
    );
    _valorController.text = 'R\$ ${ambiente.valor.toStringAsFixed(2)}';

    // Determinar se é condomínio ou bloco/unid
    _isCondominio = reserva.para == 'Condomínio';
    _isBlocoUnid = !_isCondominio;

    // Mostrar o modal de edição
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Builder(
              builder: (innerContext) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'Editar Reserva dia $_selectedDayLabel',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF003E7E),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () => Navigator.of(
                              context,
                              rootNavigator: false,
                            ).pop(),
                            child: const Icon(
                              Icons.close,
                              color: Color(0xFF003E7E),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: SingleChildScrollView(
                          child: _buildReservationForm(
                            isEditing: true,
                            setModalState: setModalState,
                            context: innerContext,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () =>
                                  _atualizarReserva(reserva, innerContext),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF003E7E),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Salvar Alterações',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
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
          ),
        ),
      ),
    );
  }

  Future<void> _atualizarReserva(
    Reserva reserva, [
    BuildContext? context,
  ]) async {
    final ctx = context ?? this.context;
    try {
      // Validar campos
      if (_selectedAmbienteId == null || _selectedAmbienteId!.isEmpty) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(
            content: Text('Selecione um ambiente'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_horaInicioController.text.isEmpty ||
          _horaFimController.text.isEmpty) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(
            content: Text('Preencha os horários'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final horaInicio = _horaInicioController.text;
      final horaFim = _horaFimController.text;

      // Validar se a data é no futuro (usando horário de Brasília)
      final agora = DateTime.now().toUtc();
      final agoraBrasilia = agora.add(const Duration(hours: -3));
      final todayBrasilia = DateTime(
        agoraBrasilia.year,
        agoraBrasilia.month,
        agoraBrasilia.day,
      );
      final selectedDateWithoutTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
      );

      if (selectedDateWithoutTime.isBefore(todayBrasilia) ||
          selectedDateWithoutTime.isAtSameMomentAs(todayBrasilia)) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(
            content: Text('A reserva deve ser para uma data futura'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Mostrar loading
      if (mounted) {
        showDialog(
          context: ctx,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Atualizando reserva...'),
              ],
            ),
          ),
        );
      }

      final ambiente = _ambientes.firstWhere(
        (a) => a.id == _selectedAmbienteId,
        orElse: () => Ambiente(titulo: '', valor: 0),
      );

      final valorLocacao = ambiente.valor;

      // Converter lista de presença em JSON se houver upload estruturado
      String? listaPresencaJson;
      if (_listaPresentesArray.isNotEmpty) {
        listaPresencaJson = jsonEncode(_listaPresentesArray);
      }

      // Atualizar a reserva
      await ReservaService.atualizarReserva(
        reserva.id ?? '',
        ambienteId: _selectedAmbienteId!,
        dataReserva: _selectedDate,
        horaInicio: horaInicio,
        horaFim: horaFim,
        valorLocacao: valorLocacao,
        para: _isCondominio ? 'Condomínio' : 'Bloco/Unid',
        local: ambiente.titulo,
        listaPresentes:
            listaPresencaJson ??
            (_listaPresentesController.text.isNotEmpty
                ? _listaPresentesController.text
                : null),
      );

      // Fechar o diálogo de carregamento
      if (mounted) {
        Navigator.of(ctx, rootNavigator: false).pop();
      }

      // Mostrar mensagem de sucesso
      if (mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(
            content: Text('Reserva atualizada com sucesso!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Recarregar as reservas
      await _carregarReservas();

      // Fechar o modal após um curto delay
      await Future.delayed(const Duration(milliseconds: 1000));
      if (mounted) {
        Navigator.of(ctx, rootNavigator: false).pop();
      }
    } catch (e) {
      print('❌ [ReservasScreen] ERRO ao atualizar: $e');

      // Fechar o diálogo de carregamento se estiver aberto
      if (mounted) {
        Navigator.of(ctx, rootNavigator: false).pop();
      }

      // Mostrar mensagem de erro
      if (mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar reserva: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _confirmarDelecaoReserva(Reserva reserva) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deletar Reserva'),
        content: Text(
          'Tem certeza que deseja deletar a reserva de ${reserva.dataReserva.day}/${reserva.dataReserva.month}/${reserva.dataReserva.year}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Fechar o diálogo
              await _deletarReserva(reserva);
            },
            child: const Text('Deletar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deletarReserva(Reserva reserva) async {
    try {
      // Mostrar loading
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Deletando reserva...'),
              ],
            ),
          ),
        );
      }

      // Deletar a reserva
      await ReservaService.deletarReserva(reserva.id ?? '');

      // Fechar o diálogo de carregamento
      if (mounted) {
        Navigator.of(context, rootNavigator: false).pop();
      }

      // Mostrar mensagem de sucesso
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reserva deletada com sucesso!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Recarregar as reservas
      await _carregarReservas();

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('❌ [ReservasScreen] ERRO ao deletar: $e');

      // Fechar o diálogo de carregamento se estiver aberto
      if (mounted) {
        Navigator.of(context, rootNavigator: false).pop();
      }

      // Mostrar mensagem de erro
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao deletar reserva: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _valorController.dispose();
    _horaInicioController.dispose();
    _horaFimController.dispose();
    _listaPresentesController.dispose();
    super.dispose();
  }

  String get _selectedDayLabel {
    final monthName = _months[_selectedDate.month - 1].toUpperCase();
    return '${_selectedDate.day.toString().padLeft(2, '0')}/$monthName/${_selectedDate.year}';
  }

  // Função para obter o nome do mês
  // Função para verificar se o ano é bissexto
  bool _isLeapYear(int year) {
    return (year % 4 == 0) && ((year % 100 != 0) || (year % 400 == 0));
  }

  // Função para obter o número de dias em um mês
  int _getDaysInMonth(int month, int year) {
    const daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    if (month == 2 && _isLeapYear(year)) {
      return 29;
    }
    return daysInMonth[month - 1];
  }

  // Função para obter o primeiro dia da semana do mês (0 = Domingo, 1 = Segunda, ...)
  int _getFirstDayOfWeekFromMonth(int month, int year) {
    return DateTime(year, month, 1).weekday % 7;
  }

  // Função para abrir o termo de locação em PDF
  Future<void> _abrirTermoLocacao(String? locacaoUrl) async {
    if (locacaoUrl == null || locacaoUrl.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nenhum termo de locação disponível'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

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

  // Função para navegar para o mês anterior
  void _previousMonth() {
    setState(() {
      if (_currentMonthIndex == 0) {
        _currentMonthIndex = 11;
        _currentYear--;
      } else {
        _currentMonthIndex--;
      }

      final daysInNewMonth = _getDaysInMonth(
        _currentMonthIndex + 1,
        _currentYear,
      );
      final selectedDay = _selectedDate.day > daysInNewMonth
          ? daysInNewMonth
          : _selectedDate.day;
      _selectedDate = DateTime(
        _currentYear,
        _currentMonthIndex + 1,
        selectedDay,
      );
    });
  }

  // Função para navegar para o próximo mês
  void _nextMonth() {
    setState(() {
      if (_currentMonthIndex == 11) {
        _currentMonthIndex = 0;
        _currentYear++;
      } else {
        _currentMonthIndex++;
      }

      final daysInNewMonth = _getDaysInMonth(
        _currentMonthIndex + 1,
        _currentYear,
      );
      final selectedDay = _selectedDate.day > daysInNewMonth
          ? daysInNewMonth
          : _selectedDate.day;
      _selectedDate = DateTime(
        _currentYear,
        _currentMonthIndex + 1,
        selectedDay,
      );
    });
  }

  // Função para construir o seletor de mês
  Widget _buildMonthSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: _previousMonth,
          icon: const Icon(Icons.chevron_left, size: 28),
        ),
        Text(
          '${_months[_currentMonthIndex]} $_currentYear',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        IconButton(
          onPressed: _nextMonth,
          icon: const Icon(Icons.chevron_right, size: 28),
        ),
      ],
    );
  }

  // Cabeçalho com os dias da semana
  Widget _buildCalendarHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: const ['DOM', 'SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SÁB']
          .map(
            (day) => Expanded(
              child: Center(
                child: Text(
                  day,
                  style: TextStyle(
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

  // Formatador customizado para entrada de hora (HH:MM)
  TextInputFormatter _TimeInputFormatter() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      String text = newValue.text;

      // Remove caracteres inválidos
      text = text.replaceAll(RegExp(r'[^0-9]'), '');

      // Limita a 4 dígitos
      if (text.length > 4) {
        text = text.substring(0, 4);
      }

      // Formata para HH:MM
      if (text.length >= 3) {
        final hh = text.substring(0, 2);
        final mm = text.substring(2, text.length > 4 ? 4 : text.length);

        // Valida horas (00-23)
        final hhInt = int.tryParse(hh) ?? 0;
        if (hhInt > 23) {
          return oldValue;
        }

        // Valida minutos (00-59)
        if (mm.isNotEmpty) {
          final mmInt = int.tryParse(mm) ?? 0;
          if (mmInt > 59) {
            return oldValue;
          }
        }

        if (mm.isEmpty) {
          text = '$hh:';
        } else {
          text = '$hh:$mm';
        }
      } else if (text.length == 2) {
        final hhInt = int.tryParse(text) ?? 0;
        if (hhInt <= 23) {
          text = '$text:';
        } else {
          return oldValue;
        }
      }

      return TextEditingValue(
        text: text,
        selection: TextSelection.fromPosition(
          TextPosition(offset: text.length),
        ),
      );
    });
  }

  // Função para construir o grid do calendário
  Widget _buildCalendarGrid() {
    final List<Widget> days = [];
    final monthNumber = _currentMonthIndex + 1;
    final daysInMonth = _getDaysInMonth(monthNumber, _currentYear);
    final firstDayOfWeek = _getFirstDayOfWeekFromMonth(
      monthNumber,
      _currentYear,
    );

    for (int i = 0; i < firstDayOfWeek; i++) {
      days.add(Container());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_currentYear, monthNumber, day);
      final isSelected =
          date.day == _selectedDate.day &&
          date.month == _selectedDate.month &&
          date.year == _selectedDate.year;
      final isToday =
          date.day == _today.day &&
          date.month == _today.month &&
          date.year == _today.year;
      final hasReservation = _hasReservationOn(date);

      days.add(
        _buildCalendarDay(
          day: day,
          isSelected: isSelected,
          isToday: isToday,
          hasReservation: hasReservation,
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: days,
    );
  }

  Widget _buildCalendarDay({
    required int day,
    required bool isSelected,
    required bool isToday,
    required bool hasReservation,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = DateTime(_currentYear, _currentMonthIndex + 1, day);
        });
      },
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E3A8A) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: !isSelected && isToday
              ? Border.all(color: const Color(0xFF1E3A8A))
              : null,
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                day.toString(),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (hasReservation)
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : const Color(0xFF1E3A8A),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _hasReservationOn(DateTime date) {
    return _diasComReservas.contains(date.day) &&
        date.month == _currentMonthIndex + 1 &&
        date.year == _currentYear;
  }

  // Função para verificar se há reservas para o dia selecionado
  bool _hasReservationsForSelectedDay() {
    return _hasReservationOn(_selectedDate);
  }

  // Função para construir a seção "Adicionar nova tarefa"
  Widget _buildAddEventSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: _showReservationModal,
            child: Container(
              width: 48.0,
              height: 48.0,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF003E7E),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 24.0),
            ),
          ),
          const SizedBox(height: 16.0),
          GestureDetector(
            onTap: _showReservationModal,
            child: const Text(
              'Adicionar nova reserva',
              style: TextStyle(
                color: Color(0xFF003E7E),
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Função para mostrar o modal de reserva
  void _showReservationModal() {
    // Limpar todos os campos antes de abrir o modal
    _horaInicioController.clear();
    _horaFimController.clear();
    _listaPresentesController.clear();
    _listaPresentesController.clear();
    _valorController.clear();
    _uploadedFileName = null;
    _isCondominio = true;
    _isBlocoUnid = false;
    _termoLocacaoAceito = false;
    _selectedAmbienteId = _ambientes.isNotEmpty ? _ambientes.first.id : null;
    if (_selectedAmbienteId != null) {
      final ambiente = _ambientes.firstWhere(
        (a) => a.id == _selectedAmbienteId,
        orElse: () => _ambientes.first,
      );
      _valorController.text = 'R\$ ${ambiente.valor.toStringAsFixed(2)}';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Builder(
              builder: (innerContext) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título do modal
                      Text(
                        'Reservar Dia $_selectedDayLabel',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF003E7E),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Conteúdo do formulário
                      Expanded(
                        child: SingleChildScrollView(
                          child: _buildReservationForm(
                            setModalState: setModalState,
                            context: innerContext,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // Função para construir os cards de reserva existentes
  Widget _buildReservationCard() {
    // Filtra reservas para o dia selecionado
    final reservasDoDia = _reservas.where((reserva) {
      return reserva.dataReserva.day == _selectedDate.day &&
          reserva.dataReserva.month == _selectedDate.month &&
          reserva.dataReserva.year == _selectedDate.year;
    }).toList();

    if (reservasDoDia.isEmpty) {
      return _buildAddEventSection();
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reservasDoDia.length,
      itemBuilder: (context, index) {
        final reserva = reservasDoDia[index];
        final ambiente = _ambientes.firstWhere(
          (a) => a.id == reserva.ambienteId,
          orElse: () =>
              Ambiente(id: '', titulo: 'Ambiente desconhecido', valor: 0),
        );

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color(0xFF003E7E),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Primeira linha: Título e Horário
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Reserva dia ${reserva.dataReserva.day} - ${ambiente.titulo}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                  Text(
                    '${_formatarHora(reserva.horaInicio)} - ${_formatarHora(reserva.horaFim)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4.0),

              // Segunda linha: Descrição
              Text(
                reserva.para,
                style: const TextStyle(color: Colors.white70, fontSize: 13.0),
              ),

              // Exibir unidade se for Bloco/Unid
              if (reserva.para == 'Bloco/Unid' &&
                  reserva.blocoUnidadeId != null)
                FutureBuilder<Unidade?>(
                  future: _getUnidadeById(reserva.blocoUnidadeId!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.data != null) {
                      final unidade = snapshot.data!;
                      return Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(
                          'Unidade: ${unidade.bloco != null && unidade.bloco!.isNotEmpty ? "${unidade.bloco} - " : ""}${unidade.numero}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13.0,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

              if (reserva.local.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Text(
                    reserva.local,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13.0,
                    ),
                  ),
                ),

              const SizedBox(height: 12.0),

              // Lista de Presentes (se houver)
              if (reserva.listaPresentes != null &&
                  reserva.listaPresentes!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    _renderListaPresencaCard(reserva.listaPresentes!),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12.0,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

              // Terceira linha: Botões
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _editarReserva(reserva),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Editar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white70),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  ElevatedButton.icon(
                    onPressed: () => _confirmarDelecaoReserva(reserva),
                    icon: const Icon(Icons.delete, size: 16),
                    label: const Text('Excluir'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
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
  }

  // Função para construir o formulário de reserva
  Widget _buildReservationForm({
    bool isEditing = false,
    Function? setModalState,
    BuildContext? context,
  }) {
    final ctx = context ?? this.context;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16.0),
          const Text(
            'Para',
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8.0),
          Wrap(
            spacing: 8.0,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Radio(
                    value: true,
                    groupValue: _isCondominio,
                    onChanged: (value) {
                      if (setModalState != null) {
                        setModalState(() {
                          _isCondominio = true;
                          _isBlocoUnid = false;
                        });
                      } else {
                        setState(() {
                          _isCondominio = true;
                          _isBlocoUnid = false;
                        });
                      }
                    },
                    activeColor: const Color(0xFF003E7E),
                  ),
                  const Text('Condomínio'),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Radio(
                    value: true,
                    groupValue: _isBlocoUnid,
                    onChanged: (value) {
                      if (setModalState != null) {
                        setModalState(() {
                          _isCondominio = false;
                          _isBlocoUnid = true;
                        });
                      } else {
                        setState(() {
                          _isCondominio = false;
                          _isBlocoUnid = true;
                        });
                      }
                    },
                    activeColor: const Color(0xFF003E7E),
                  ),
                  const Text('Bloco/Unid.'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          // Campo Bloco/Unidade (mostrado apenas quando Bloco/Unid está selecionado)
          if (_isBlocoUnid)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Bloco/Unidade:',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Text(
                      ' *',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                if (_unidades.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 12.0,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.orange),
                      borderRadius: BorderRadius.circular(4.0),
                      color: Colors.orange[50],
                    ),
                    child: const Text(
                      '⚠️ Nenhuma unidade disponível no condomínio.',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedUnidadeId,
                        hint: const Text('Selecione uma unidade'),
                        items: _unidades.map<DropdownMenuItem<String>>((
                          Unidade unidade,
                        ) {
                          return DropdownMenuItem<String>(
                            value: unidade.id,
                            child: Text(
                              '${unidade.bloco != null && unidade.bloco!.isNotEmpty ? "${unidade.bloco} - " : ""}${unidade.numero}',
                            ),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          if (setModalState != null) {
                            setModalState(() {
                              _selectedUnidadeId = value;
                            });
                          } else {
                            setState(() {
                              _selectedUnidadeId = value;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                const SizedBox(height: 16.0),
              ],
            ),
          // Campo Local
          Row(
            children: [
              const Text(
                'Local:',
                style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),
              ),
              const Text(
                ' *',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: _ambientesCarregando
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedAmbienteId,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          if (setModalState != null) {
                            setModalState(() {
                              _selectedAmbienteId = newValue;
                              final ambiente = _ambientes.firstWhere(
                                (a) => a.id == newValue,
                                orElse: () => _ambientes.first,
                              );
                              _valorController.text =
                                  'R\$ ${ambiente.valor.toStringAsFixed(2)}';
                            });
                          } else {
                            setState(() {
                              _selectedAmbienteId = newValue;
                              final ambiente = _ambientes.firstWhere(
                                (a) => a.id == newValue,
                                orElse: () => _ambientes.first,
                              );
                              _valorController.text =
                                  'R\$ ${ambiente.valor.toStringAsFixed(2)}';
                            });
                          }
                        }
                      },
                      items: _ambientes.map<DropdownMenuItem<String>>((
                        Ambiente ambiente,
                      ) {
                        return DropdownMenuItem<String>(
                          value: ambiente.id,
                          child: Text(ambiente.titulo),
                        );
                      }).toList(),
                    ),
                  ),
          ),
          const SizedBox(height: 16.0),
          // Valor da locação
          Row(
            children: [
              const Text(
                'Valor da locação:',
                style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),
              ),
              const Text(
                ' *',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          TextField(
            controller: _valorController,
            readOnly: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          // Hora de início e fim
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Hora de Início',
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Text(
                          ' *',
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    TextField(
                      controller: _horaInicioController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [_TimeInputFormatter()],
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 8.0,
                        ),
                        hintText: 'HH:MM',
                        counterText: '',
                      ),
                      maxLength: 5,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Hora de Fim',
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Text(
                          ' *',
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    TextField(
                      controller: _horaFimController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [_TimeInputFormatter()],
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 8.0,
                        ),
                        hintText: 'HH:MM',
                        counterText: '',
                      ),
                      maxLength: 5,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          const Text(
            'Lista de Presentes',
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8.0),
          TextField(
            controller: _listaPresentesController,
            onChanged: (_) {
              // Quando usuário edita manualmente, limpar array para evitar dados inconsistentes
              _listaPresentesArray = [];
            },
            maxLines: 4,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              hintText:
                  'Ex: Reserva da área da churrasqueira para a unidade 201/A',
            ),
          ),
          const SizedBox(height: 8.0),
          GestureDetector(
            onTap: () async {
              try {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['xlsx', 'xls'],
                );

                if (result != null) {
                  // Mostrar indicador de carregamento
                  if (setModalState != null) {
                    setModalState(() {
                      _uploadedFileName =
                          '${result.files.single.name} (lendo...)';
                    });
                  } else {
                    setState(() {
                      _uploadedFileName =
                          '${result.files.single.name} (lendo...)';
                    });
                  }

                  try {
                    // Ler os nomes do arquivo Excel
                    // Passar o PlatformFile direto (funciona em web e mobile)
                    final nomes = await ExcelService.lerColuna(
                      result.files.single,
                    );

                    if (nomes.isNotEmpty) {
                      final listaNumerada = _formatarListaPresencaModal(nomes);

                      // Atualizar o controller com a lista formatada e guardar o array
                      if (setModalState != null) {
                        setModalState(() {
                          _listaPresentesController.text = listaNumerada;
                          _listaPresentesArray =
                              nomes; // Guardar o array de nomes
                          _uploadedFileName =
                              '${result.files.single.name} ✓ (${nomes.length} nomes)';
                        });
                      } else {
                        setState(() {
                          _listaPresentesController.text = listaNumerada;
                          _listaPresentesArray =
                              nomes; // Guardar o array de nomes
                          _uploadedFileName =
                              '${result.files.single.name} ✓ (${nomes.length} nomes)';
                        });
                      }

                      // Mostrar sucesso
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(
                          content: Text(
                            '✓ ${nomes.length} nome(s) importado(s) com sucesso!',
                          ),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    } else {
                      // Nenhum nome encontrado
                      if (setModalState != null) {
                        setModalState(() {
                          _uploadedFileName = null;
                        });
                      } else {
                        setState(() {
                          _uploadedFileName = null;
                        });
                      }

                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(
                          content: Text('❌ Nenhum nome encontrado na coluna A'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  } catch (e) {
                    print('Erro ao ler Excel: $e');

                    if (setModalState != null) {
                      setModalState(() {
                        _uploadedFileName = null;
                      });
                    } else {
                      setState(() {
                        _uploadedFileName = null;
                      });
                    }

                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(
                        content: Text('❌ Erro ao ler arquivo: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } catch (e) {
                print('Erro ao selecionar arquivo: $e');
              }
            },
            child: Row(
              children: [
                const Icon(
                  Icons.cloud_upload_outlined,
                  color: Color(0xFF003E7E),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _uploadedFileName ?? 'Fazer Upload da Lista',
                    style: TextStyle(
                      color:
                          _uploadedFileName != null &&
                              _uploadedFileName!.contains('✓')
                          ? Colors.green
                          : Colors.black87,
                      fontSize: 14,
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
                    onTap: () {
                      if (setModalState != null) {
                        setModalState(() {
                          _uploadedFileName = null;
                          _listaPresentesController.clear();
                          _listaPresentesArray = [];
                        });
                      } else {
                        setState(() {
                          _uploadedFileName = null;
                          _listaPresentesController.clear();
                          _listaPresentesArray = [];
                        });
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Icon(Icons.close, size: 18, color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          // Seção de Termo de Locação
          StatefulBuilder(
            builder: (context, setState) {
              // Obter o ambiente selecionado
              final ambienteSelecionado = _ambientes.firstWhere(
                (a) => a.id == _selectedAmbienteId,
                orElse: () => Ambiente(titulo: '', valor: 0),
              );

              final temTermoLocacao =
                  ambienteSelecionado.locacaoUrl != null &&
                  ambienteSelecionado.locacaoUrl!.isNotEmpty;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Se tem termo: mostrar termo com opções de abrir/trocar/excluir
                  if (temTermoLocacao) ...[
                    Row(
                      children: [
                        const Text(
                          'Termo de Locação',
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Text(
                          ' *',
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4.0),
                        color: Colors.grey[50],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.description,
                                color: Color(0xFF1E3A8A),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Termo de locação',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    GestureDetector(
                                      onTap: () => _abrirTermoLocacao(
                                        ambienteSelecionado.locacaoUrl,
                                      ),
                                      child: const Text(
                                        'Clique para abrir no navegador',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 12,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Se não tem termo: mostrar opção de anexar
                    Row(
                      children: [
                        const Text(
                          'Termo de Locação',
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Text(
                          ' *',
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    GestureDetector(
                      onTap: () async {
                        try {
                          FilePickerResult? result = await FilePicker.platform
                              .pickFiles(
                                type: FileType.custom,
                                allowedExtensions: ['pdf'],
                              );

                          if (result != null && result.files.isNotEmpty) {
                            final file = result.files.single;

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Enviando termo...'),
                                  duration: Duration(seconds: 5),
                                ),
                              );
                            }

                            final pdfUrl =
                                await AmbienteService.uploadLocacaoPdfAmbiente(
                                  file,
                                  nomeArquivo: file.name,
                                );

                            final ambienteAtualizado =
                                await AmbienteService.atualizarAmbiente(
                                  ambienteSelecionado.id!,
                                  locacaoUrl: pdfUrl,
                                );

                            final ambienteIndex = _ambientes.indexWhere(
                              (a) => a.id == ambienteSelecionado.id,
                            );
                            if (ambienteIndex != -1) {
                              setState(() {
                                _ambientes[ambienteIndex] = ambienteAtualizado;
                              });
                            }

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Termo carregado com sucesso!'),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          print('Erro ao fazer upload do termo: $e');
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Erro: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4.0),
                          color: Colors.grey[50],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.cloud_upload_outlined,
                              color: Color(0xFF1E3A8A),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Anexar termo em PDF',
                              style: TextStyle(
                                color: Color(0xFF1E3A8A),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16.0),
                  // Checkbox para aceitar termo de locação
                  CheckboxListTile(
                    title: const Text(
                      'Aceitar termos e condições',
                      style: TextStyle(fontSize: 14.0),
                    ),
                    subtitle: const Text(
                      'Declaro que aceito os termos e condições de locação',
                      style: TextStyle(fontSize: 12.0),
                    ),
                    value: _termoLocacaoAceito,
                    onChanged: (bool? value) {
                      setState(() {
                        _termoLocacaoAceito = value ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0.0),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16.0),
          // Botão de reservar (apenas na criação, não na edição)
          if (!isEditing)
            Center(
              child: ElevatedButton(
                onPressed: () => _salvarReserva(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003E7E),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32.0,
                    vertical: 12.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                child: const Text(
                  'Reservar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Cabeçalho superior padronizado
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
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

              // Caminho de navegação
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Home',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      const Text(
                        ' / ',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      const Text(
                        'Gestão',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      const Text(
                        ' / ',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      const Text(
                        'Reservas',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),

              // Botão Configurar Ambientes
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Navegar para ConfigurarAmbientesScreen e aguardar resultado
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const ConfigurarAmbientesScreen(),
                        ),
                      );

                      // Recarregar os ambientes quando retornar
                      await _carregarAmbientes();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF003E7E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                    child: const Text(
                      'Configurar Ambientes',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),

              // Calendário
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 16.0,
                ),
                child: Column(
                  children: [
                    _buildMonthSelector(),
                    const SizedBox(height: 20),
                    _buildCalendarHeader(),
                    const SizedBox(height: 10),
                    _buildCalendarGrid(),
                  ],
                ),
              ),

              // Reservas do dia selecionado
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Reservados - Dia $_selectedDayLabel',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    GestureDetector(
                      onTap: _showReservationModal,
                      child: Container(
                        width: 24.0,
                        height: 24.0,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF003E7E),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 16.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Verificar se há reservas para o dia selecionado
              _hasReservationsForSelectedDay()
                  ? _buildReservationCard()
                  : _buildAddEventSection(),
            ],
          ),
        ),
      ),
    );
  }
}
