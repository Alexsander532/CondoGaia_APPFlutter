import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import '../models/evento_agenda.dart';
import '../models/evento_diario.dart';
import '../models/representante.dart';
import '../services/evento_agenda_service.dart';
import '../services/evento_diario_service.dart';
import '../services/supabase_service.dart';

class TimeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    // Remove todos os caracteres não numéricos
    final digitsOnly = text.replaceAll(RegExp(r'[^0-9]'), '');

    // Limita a 4 dígitos (HHMM)
    final limitedDigits = digitsOnly.length > 4
        ? digitsOnly.substring(0, 4)
        : digitsOnly;

    String formattedText = '';
    int cursorPosition = limitedDigits.length;

    if (limitedDigits.isNotEmpty) {
      // Adiciona os primeiros dois dígitos (horas)
      formattedText += limitedDigits.substring(
        0,
        limitedDigits.length >= 2 ? 2 : limitedDigits.length,
      );

      // Adiciona os dois pontos se tiver mais de 2 dígitos
      if (limitedDigits.length > 2) {
        formattedText += ':';
        // Adiciona os minutos
        formattedText += limitedDigits.substring(2);
        cursorPosition = formattedText.length;
      }
    }

    // Validação básica de hora (00-23) e minutos (00-59)
    if (formattedText.length >= 2) {
      final hours = int.tryParse(formattedText.substring(0, 2)) ?? 0;
      if (hours > 23) {
        formattedText =
            '23${formattedText.length > 2 ? formattedText.substring(2) : ''}';
      }
    }

    if (formattedText.length >= 5) {
      final minutes = int.tryParse(formattedText.substring(3, 5)) ?? 0;
      if (minutes > 59) {
        formattedText = '${formattedText.substring(0, 3)}59';
      }
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}

class AgendaScreen extends StatefulWidget {
  final Representante representante;

  const AgendaScreen({super.key, required this.representante});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  late int selectedDay;
  late String currentMonth;
  late int currentYear;

  // Controllers para o formulário de evento
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  // Variáveis de estado para o formulário
  String _eventType = 'Agenda';
  bool _isRecurrent = false;
  int _recurrentMonths = 1;
  bool _notifyAll = false;
  dynamic
  _fotoEvento; // Foto selecionada para o evento (File mobile, XFile web)
  dynamic
  _fotoDiario; // Foto selecionada para o evento diário (File mobile, XFile web)

  // Condomínios do representante
  String? _selectedCondominioId;
  bool _notifyMe = false;

  // Variáveis para gerenciar eventos
  List<EventoAgenda> _eventos = [];
  List<EventoDiario> _eventosDiarios = [];
  bool _isLoading = false;
  bool _isSaving = false;

  // Controllers para o modal de edição
  final TextEditingController _editTitleController = TextEditingController();
  final TextEditingController _editDescriptionController =
      TextEditingController();
  final TextEditingController _editStartTimeController =
      TextEditingController();
  final TextEditingController _editEndTimeController = TextEditingController();

  // Variáveis de estado para o modal de edição
  bool _editNotifyAll = false;
  String? _editSelectedCondominioId;
  bool _editNotifyMe = false;
  EventoAgenda? _eventBeingEdited;
  dynamic
  _editFotoEvento; // Foto sendo editada para evento agenda (File mobile, XFile web)
  bool _removerFotoEvento = false; // Flag para remover foto do evento agenda

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    selectedDay = now.day;
    currentMonth = months[now.month - 1];
    currentYear = now.year;
    _loadCondominios();
    _loadEvents();
  }

  Future<void> _loadCondominios() async {
    try {
      final condominios = await SupabaseService.getCondominiosByRepresentante(
        widget.representante.id,
      );
      setState(() {
        // Seleciona o primeiro condomínio como padrão, se existir
        if (condominios.isNotEmpty) {
          _selectedCondominioId = condominios.first['id'];
        }
      });
    } catch (e) {
      print('Erro ao carregar condomínios: $e');
    }
  }

  Future<void> _refreshData() async {
    await _loadCondominios();
    await _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Carregar eventos do mês atual
      DateTime startDate = DateTime(currentYear, currentMonthIndex + 1, 1);
      DateTime endDate = DateTime(currentYear, currentMonthIndex + 2, 0);

      // Carregar eventos de agenda
      final eventos = await EventoAgendaService.buscarEventosPorPeriodo(
        representanteId: widget.representante.id,
        dataInicio: startDate,
        dataFim: endDate,
      );

      // Carregar eventos diários
      final eventosDiarios = await EventoDiarioService.buscarEventosPorPeriodo(
        representanteId: widget.representante.id,
        dataInicio: startDate,
        dataFim: endDate,
      );

      setState(() {
        _eventos = eventos ?? [];
        _eventosDiarios = eventosDiarios ?? [];
      });
    } catch (e) {
      print('Erro ao carregar eventos: $e');
      // Garantir que as listas não sejam null mesmo em caso de erro
      setState(() {
        _eventos = [];
        _eventosDiarios = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar eventos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  final List<String> months = [
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

  int get currentMonthIndex {
    int index = months.indexOf(currentMonth);
    if (index == -1) {
      print('Erro: currentMonth não encontrado na lista: $currentMonth');
      // Retorna o mês atual como fallback
      return DateTime.now().month - 1;
    }
    return index;
  }

  // Função para verificar se o ano é bissexto
  bool _isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  // Função para obter o número de dias do mês
  int _getDaysInMonth(int month, int year) {
    switch (month) {
      case 1: // Janeiro
      case 3: // Março
      case 5: // Maio
      case 7: // Julho
      case 8: // Agosto
      case 10: // Outubro
      case 12: // Dezembro
        return 31;
      case 4: // Abril
      case 6: // Junho
      case 9: // Setembro
      case 11: // Novembro
        return 30;
      case 2: // Fevereiro
        return _isLeapYear(year) ? 29 : 28;
      default:
        return 31;
    }
  }

  // Função para obter o primeiro dia da semana do mês (0 = domingo)
  int _getFirstDayOfMonth(int month, int year) {
    DateTime firstDay = DateTime(year, month, 1);
    // DateTime.weekday retorna 1-7 (segunda a domingo)
    // Convertemos para 0-6 (domingo a sábado)
    return firstDay.weekday == 7 ? 0 : firstDay.weekday;
  }

  void _previousMonth() {
    setState(() {
      if (currentMonthIndex > 0) {
        currentMonth = months[currentMonthIndex - 1];
      } else {
        currentMonth = months[11];
        currentYear--;
      }
      // Ajustar o dia selecionado se não existir no novo mês
      int daysInNewMonth = _getDaysInMonth(currentMonthIndex + 1, currentYear);
      if (selectedDay > daysInNewMonth) {
        selectedDay = 1;
      }
    });
    _loadEvents(); // Recarregar eventos do novo mês
  }

  void _nextMonth() {
    setState(() {
      if (currentMonthIndex < 11) {
        currentMonth = months[currentMonthIndex + 1];
      } else {
        currentMonth = months[0];
        currentYear++;
      }
      // Ajustar o dia selecionado se não existir no novo mês
      int daysInNewMonth = _getDaysInMonth(currentMonthIndex + 1, currentYear);
      if (selectedDay > daysInNewMonth) {
        selectedDay = 1;
      }
    });
    _loadEvents(); // Recarregar eventos do novo mês
  }

  bool _hasEventsOnDay(int day) {
    try {
      // Verificações defensivas
      if (currentMonthIndex < 0 || currentMonthIndex > 11) {
        print('Erro: currentMonthIndex inválido: $currentMonthIndex');
        return false;
      }

      if (day < 1 || day > 31) {
        print('Erro: dia inválido: $day');
        return false;
      }

      DateTime dayDate = DateTime(currentYear, currentMonthIndex + 1, day);

      // Verificar eventos de agenda (com verificação de null safety)
      bool hasAgendaEvents =
          _eventos.isNotEmpty &&
          _eventos.any(
            (evento) =>
                evento.dataEvento != null &&
                evento.dataEvento.year == dayDate.year &&
                evento.dataEvento.month == dayDate.month &&
                evento.dataEvento.day == dayDate.day,
          );

      // Verificar eventos diários (com verificação de null safety)
      bool hasDiaryEvents =
          _eventosDiarios.isNotEmpty &&
          _eventosDiarios.any(
            (evento) =>
                evento.dataEvento != null &&
                evento.dataEvento.year == dayDate.year &&
                evento.dataEvento.month == dayDate.month &&
                evento.dataEvento.day == dayDate.day,
          );

      return hasAgendaEvents || hasDiaryEvents;
    } catch (e) {
      print('Erro em _hasEventsOnDay: $e');
      return false;
    }
  }

  List<EventoAgenda> _getEventsForDay(int day) {
    try {
      // Verificações defensivas
      if (currentMonthIndex < 0 || currentMonthIndex > 11) {
        print(
          'Erro: currentMonthIndex inválido em _getEventsForDay: $currentMonthIndex',
        );
        return [];
      }

      if (day < 1 || day > 31) {
        print('Erro: dia inválido em _getEventsForDay: $day');
        return [];
      }

      DateTime dayDate = DateTime(currentYear, currentMonthIndex + 1, day);
      return _eventos
          .where(
            (evento) =>
                evento.dataEvento != null &&
                evento.dataEvento.year == dayDate.year &&
                evento.dataEvento.month == dayDate.month &&
                evento.dataEvento.day == dayDate.day,
          )
          .toList();
    } catch (e) {
      print('Erro em _getEventsForDay: $e');
      return [];
    }
  }

  List<EventoDiario> _getDiaryEventsForDay(int day) {
    try {
      // Verificações defensivas
      if (currentMonthIndex < 0 || currentMonthIndex > 11) {
        print(
          'Erro: currentMonthIndex inválido em _getDiaryEventsForDay: $currentMonthIndex',
        );
        return [];
      }

      if (day < 1 || day > 31) {
        print('Erro: dia inválido em _getDiaryEventsForDay: $day');
        return [];
      }

      DateTime dayDate = DateTime(currentYear, currentMonthIndex + 1, day);
      return _eventosDiarios
          .where(
            (evento) =>
                evento.dataEvento != null &&
                evento.dataEvento.year == dayDate.year &&
                evento.dataEvento.month == dayDate.month &&
                evento.dataEvento.day == dayDate.day,
          )
          .toList();
    } catch (e) {
      print('Erro em _getDiaryEventsForDay: $e');
      return [];
    }
  }

  Widget _buildCalendarDay(int day, {bool isSelected = false}) {
    bool hasEvents = _hasEventsOnDay(day);

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDay = day;
        });
      },
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E3A8A) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: hasEvents
              ? Border.all(color: const Color(0xFF1E3A8A), width: 2)
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
            if (hasEvents && !isSelected)
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E3A8A),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showAddEventModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
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
                  // Título do modal (fixo)
                  Text(
                    'Reservar Dia ${selectedDay.toString().padLeft(2, '0')}/${_getMonthName(currentMonthIndex + 1)}/$currentYear',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Conteúdo com scroll
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tipo: Agenda/Diário
                          Row(
                            children: [
                              const Text(
                                'Tipo:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Row(
                                children: [
                                  Radio<String>(
                                    value: 'Agenda',
                                    groupValue: _eventType,
                                    onChanged: (value) {
                                      setModalState(() {
                                        _eventType = value!;
                                      });
                                    },
                                    activeColor: Color(0xFF1E3A8A),
                                  ),
                                  const Text('Agenda'),
                                  const SizedBox(width: 20),
                                  Radio<String>(
                                    value: 'Diário',
                                    groupValue: _eventType,
                                    onChanged: (value) {
                                      setModalState(() {
                                        _eventType = value!;
                                      });
                                    },
                                    activeColor: Color(0xFF1E3A8A),
                                  ),
                                  const Text('Diário'),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Título
                          const Text(
                            'Título:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFF1E3A8A),
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Descrição
                          const Text(
                            'Descrição:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _descriptionController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFF1E3A8A),
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Campos específicos para Agenda
                          if (_eventType == 'Agenda') ...[
                            // Hora de Início e Fim
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Hora de Início',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF1E3A8A),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextField(
                                        controller: _startTimeController,
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [TimeInputFormatter()],
                                        decoration: InputDecoration(
                                          hintText: 'hh:mm',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.grey[300]!,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.grey[300]!,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Color(0xFF1E3A8A),
                                            ),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 12,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Hora de Fim',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF1E3A8A),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextField(
                                        controller: _endTimeController,
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [TimeInputFormatter()],
                                        decoration: InputDecoration(
                                          hintText: 'hh:mm',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.grey[300]!,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.grey[300]!,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Color(0xFF1E3A8A),
                                            ),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 12,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Recorrente
                            Row(
                              children: [
                                Checkbox(
                                  value: _isRecurrent,
                                  onChanged: (value) {
                                    setModalState(() {
                                      _isRecurrent = value!;
                                    });
                                  },
                                  activeColor: Color(0xFF1E3A8A),
                                ),
                                const Text(
                                  'Recorrente',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF1E3A8A),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                if (_isRecurrent) ...[
                                  const Text(
                                    'a cada',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 50,
                                    child: TextField(
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey[300]!,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey[300]!,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              vertical: 8,
                                            ),
                                      ),
                                      onChanged: (value) {
                                        _recurrentMonths =
                                            int.tryParse(value) ?? 1;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'meses',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Checkboxes de notificação
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Avisar todos os cond. por email',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF1E3A8A),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _notifyAll,
                                      onChanged: (value) {
                                        setModalState(() {
                                          _notifyAll = value!;
                                        });
                                      },
                                      activeColor: Color(0xFF1E3A8A),
                                    ),
                                    const Text(
                                      'Sim',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Me avisar por email apenas',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF1E3A8A),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _notifyMe,
                                      onChanged: (value) {
                                        setModalState(() {
                                          _notifyMe = value!;
                                        });
                                      },
                                      activeColor: Color(0xFF1E3A8A),
                                    ),
                                    const Text(
                                      'Sim',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],

                          // Widget de seleção de foto para eventos de Agenda
                          if (_eventType == 'Agenda') ...[
                            const SizedBox(height: 20),
                            const Text(
                              'Foto do Evento (Opcional):',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: () async {
                                // Mostrar diálogo com opções de câmera ou galeria
                                final ImageSource? source =
                                    await showDialog<ImageSource>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text(
                                            'Selecionar Imagem',
                                          ),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ListTile(
                                                leading: const Icon(
                                                  Icons.camera_alt,
                                                ),
                                                title: const Text('Câmera'),
                                                onTap: () => Navigator.pop(
                                                  context,
                                                  ImageSource.camera,
                                                ),
                                              ),
                                              ListTile(
                                                leading: const Icon(
                                                  Icons.photo_library,
                                                ),
                                                title: const Text('Galeria'),
                                                onTap: () => Navigator.pop(
                                                  context,
                                                  ImageSource.gallery,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );

                                if (source != null) {
                                  final ImagePicker picker = ImagePicker();
                                  try {
                                    final XFile? image = await picker.pickImage(
                                      source: source,
                                      maxWidth: 800,
                                      maxHeight: 600,
                                      imageQuality: 80,
                                    );

                                    if (image != null) {
                                      setModalState(() {
                                        // Converter XFile para File no mobile, manter XFile na web
                                        if (kIsWeb) {
                                          _fotoEvento = image;
                                        } else {
                                          _fotoEvento = File(image.path);
                                        }
                                      });
                                    }
                                  } catch (e) {
                                    print('Erro ao selecionar imagem: $e');
                                  }
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                height: 200,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.grey[50],
                                ),
                                child: _fotoEvento != null
                                    ? Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            child: kIsWeb
                                                ? Image.network(
                                                    _fotoEvento!.path,
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                  )
                                                : Image.file(
                                                    _fotoEvento!,
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                  ),
                                          ),
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: GestureDetector(
                                              onTap: () {
                                                setModalState(() {
                                                  _fotoEvento = null;
                                                });
                                              },
                                              child: Container(
                                                decoration: const BoxDecoration(
                                                  color: Colors.red,
                                                  shape: BoxShape.circle,
                                                ),
                                                padding: const EdgeInsets.all(
                                                  4,
                                                ),
                                                child: const Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 8,
                                            right: 8,
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                color: Colors.blue,
                                                shape: BoxShape.circle,
                                              ),
                                              padding: const EdgeInsets.all(8),
                                              child: const Icon(
                                                Icons.zoom_in,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.camera_alt,
                                            size: 48,
                                            color: Colors.grey[400],
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'Clique para adicionar foto',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ],

                          // Widget de seleção de foto para eventos Diários
                          if (_eventType == 'Diário') ...[
                            const SizedBox(height: 20),
                            const Text(
                              'Foto do Evento (Opcional):',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: () async {
                                // Mostrar diálogo com opções de câmera ou galeria
                                final ImageSource? source =
                                    await showDialog<ImageSource>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text(
                                            'Selecionar Imagem',
                                          ),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ListTile(
                                                leading: const Icon(
                                                  Icons.camera_alt,
                                                ),
                                                title: const Text('Câmera'),
                                                onTap: () => Navigator.pop(
                                                  context,
                                                  ImageSource.camera,
                                                ),
                                              ),
                                              ListTile(
                                                leading: const Icon(
                                                  Icons.photo_library,
                                                ),
                                                title: const Text('Galeria'),
                                                onTap: () => Navigator.pop(
                                                  context,
                                                  ImageSource.gallery,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );

                                if (source != null) {
                                  final ImagePicker picker = ImagePicker();
                                  try {
                                    final XFile? image = await picker.pickImage(
                                      source: source,
                                      maxWidth: 800,
                                      maxHeight: 600,
                                      imageQuality: 80,
                                    );

                                    if (image != null) {
                                      setModalState(() {
                                        // Converter XFile para File no mobile, manter XFile na web
                                        if (kIsWeb) {
                                          _fotoDiario = image;
                                        } else {
                                          _fotoDiario = File(image.path);
                                        }
                                      });
                                    }
                                  } catch (e) {
                                    print('Erro ao selecionar imagem: $e');
                                  }
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                height: 200,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.grey[50],
                                ),
                                child: _fotoDiario != null
                                    ? Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            child: kIsWeb
                                                ? Image.network(
                                                    _fotoDiario!.path,
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                  )
                                                : Image.file(
                                                    _fotoDiario!,
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                  ),
                                          ),
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: GestureDetector(
                                              onTap: () {
                                                setModalState(() {
                                                  _fotoDiario = null;
                                                });
                                              },
                                              child: Container(
                                                decoration: const BoxDecoration(
                                                  color: Colors.red,
                                                  shape: BoxShape.circle,
                                                ),
                                                padding: const EdgeInsets.all(
                                                  4,
                                                ),
                                                child: const Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 8,
                                            right: 8,
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                color: Colors.blue,
                                                shape: BoxShape.circle,
                                              ),
                                              padding: const EdgeInsets.all(8),
                                              child: const Icon(
                                                Icons.zoom_in,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.camera_alt,
                                            size: 48,
                                            color: Colors.grey[400],
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'Clique para adicionar foto',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Botão Salvar (fixo na parte inferior)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveEvent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Salvar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'JANEIRO',
      'FEVEREIRO',
      'MARÇO',
      'ABRIL',
      'MAIO',
      'JUNHO',
      'JULHO',
      'AGOSTO',
      'SETEMBRO',
      'OUTUBRO',
      'NOVEMBRO',
      'DEZEMBRO',
    ];
    return months[month - 1];
  }

  void _showEditEventModal(EventoAgenda evento) {
    // Preencher os controllers com os dados do evento
    _eventBeingEdited = evento;
    _editTitleController.text = evento.titulo;
    _editDescriptionController.text = evento.descricao ?? '';
    _editStartTimeController.text = _formatTimeDisplay(evento.horaInicio);
    _editEndTimeController.text = _formatTimeDisplay(evento.horaFim);
    _editNotifyAll = evento.avisarCondominiosEmail;
    _editNotifyMe = evento.avisarRepresentanteEmail;
    _editSelectedCondominioId = evento.condominioId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
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
                  // Título do modal (fixo)
                  const Text(
                    'Editar Evento',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Conteúdo com scroll
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Título
                          const Text(
                            'Título:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _editTitleController,
                            decoration: InputDecoration(
                              hintText: 'Digite o título do evento',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFF1E3A8A),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Descrição
                          const Text(
                            'Descrição:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _editDescriptionController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText:
                                  'Digite a descrição do evento (opcional)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFF1E3A8A),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Horários
                          Row(
                            children: [
                              // Hora de Início
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Hora de Início:',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: _editStartTimeController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [TimeInputFormatter()],
                                      decoration: InputDecoration(
                                        hintText: 'hh:mm',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFF1E3A8A),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Hora de Fim
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Hora de Fim:',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: _editEndTimeController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [TimeInputFormatter()],
                                      decoration: InputDecoration(
                                        hintText: 'hh:mm',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFF1E3A8A),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Informação de Recorrência (somente leitura)
                          if (evento.eventoRecorrente) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.repeat,
                                    color: Colors.blue.shade600,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Evento Recorrente - ${evento.numeroMesesRecorrencia ?? 1} ${(evento.numeroMesesRecorrencia ?? 1) == 1 ? 'mês' : 'meses'}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 20),

                          // Notificações
                          const Text(
                            'Notificações:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),

                          Row(
                            children: [
                              Checkbox(
                                value: _editNotifyAll,
                                onChanged: (value) {
                                  setModalState(() {
                                    _editNotifyAll = value ?? false;
                                  });
                                },
                                activeColor: const Color(0xFF1E3A8A),
                              ),
                              const Expanded(
                                child: Text(
                                  'Notificar todos os condôminos',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),

                          Row(
                            children: [
                              Checkbox(
                                value: _editNotifyMe,
                                onChanged: (value) {
                                  setModalState(() {
                                    _editNotifyMe = value ?? false;
                                  });
                                },
                                activeColor: const Color(0xFF1E3A8A),
                              ),
                              const Expanded(
                                child: Text(
                                  'Notificar apenas representante',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),

                          // Widget de seleção/remoção de foto para edição
                          const SizedBox(height: 20),
                          const Text(
                            'Foto do Evento (Opcional):',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () async {
                              // Mostrar diálogo com opções de câmera ou galeria
                              final ImageSource? source =
                                  await showDialog<ImageSource>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Selecionar Imagem'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ListTile(
                                              leading: const Icon(
                                                Icons.camera_alt,
                                              ),
                                              title: const Text('Câmera'),
                                              onTap: () => Navigator.pop(
                                                context,
                                                ImageSource.camera,
                                              ),
                                            ),
                                            ListTile(
                                              leading: const Icon(
                                                Icons.photo_library,
                                              ),
                                              title: const Text('Galeria'),
                                              onTap: () => Navigator.pop(
                                                context,
                                                ImageSource.gallery,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );

                              if (source != null) {
                                final ImagePicker picker = ImagePicker();
                                try {
                                  final XFile? image = await picker.pickImage(
                                    source: source,
                                    maxWidth: 800,
                                    maxHeight: 600,
                                    imageQuality: 80,
                                  );

                                  if (image != null) {
                                    setModalState(() {
                                      // Converter XFile para File no mobile, manter XFile na web
                                      if (kIsWeb) {
                                        _editFotoEvento = image;
                                      } else {
                                        _editFotoEvento = File(image.path);
                                      }
                                    });
                                  }
                                } catch (e) {
                                  print('Erro ao selecionar imagem: $e');
                                }
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              height: 200,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey[50],
                              ),
                              child: _editFotoEvento != null
                                  ? Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          child: kIsWeb
                                              ? Image.network(
                                                  _editFotoEvento!.path,
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                )
                                              : Image.file(
                                                  _editFotoEvento!,
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                ),
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: GestureDetector(
                                            onTap: () {
                                              setModalState(() {
                                                _editFotoEvento = null;
                                                _removerFotoEvento = false;
                                              });
                                            },
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                              padding: const EdgeInsets.all(4),
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 8,
                                          right: 8,
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.blue,
                                              shape: BoxShape.circle,
                                            ),
                                            padding: const EdgeInsets.all(8),
                                            child: const Icon(
                                              Icons.zoom_in,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : (!_removerFotoEvento &&
                                            _eventBeingEdited?.fotoUrl != null
                                        ? Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Image.network(
                                                  _eventBeingEdited!.fotoUrl!,
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) {
                                                        return Container(
                                                          color:
                                                              Colors.grey[300],
                                                          child: const Icon(
                                                            Icons
                                                                .image_not_supported,
                                                          ),
                                                        );
                                                      },
                                                ),
                                              ),
                                              Positioned(
                                                top: 8,
                                                right: 8,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    setModalState(() {
                                                      _removerFotoEvento = true;
                                                    });
                                                  },
                                                  child: Container(
                                                    decoration:
                                                        const BoxDecoration(
                                                          color: Colors.red,
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                    padding:
                                                        const EdgeInsets.all(4),
                                                    child: const Icon(
                                                      Icons.close,
                                                      color: Colors.white,
                                                      size: 20,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                bottom: 8,
                                                right: 8,
                                                child: Container(
                                                  decoration:
                                                      const BoxDecoration(
                                                        color: Colors.blue,
                                                        shape: BoxShape.circle,
                                                      ),
                                                  padding: const EdgeInsets.all(
                                                    8,
                                                  ),
                                                  child: const Icon(
                                                    Icons.zoom_in,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        : Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.camera_alt,
                                                size: 48,
                                                color: Colors.grey[400],
                                              ),
                                              const SizedBox(height: 12),
                                              Text(
                                                'Clique para adicionar/trocar foto',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          )),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Botão Salvar (fixo na parte inferior)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 20),
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : () => _updateEvent(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Salvar Alterações',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _saveEvent() async {
    // Validação do título
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '❌ Título é obrigatório! Por favor, informe o título do evento.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Descrição é opcional - não precisa de validação

    // Validação do condomínio
    if (_selectedCondominioId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '🏢 Condomínio é obrigatório! Por favor, selecione um condomínio.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validação dos horários (apenas para eventos de agenda)
    if (_eventType == 'Agenda') {
      // Validação do horário de início
      if (_startTimeController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '🕐 Horário de início é obrigatório! Por favor, informe o horário de início.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Validação do horário de fim
      if (_endTimeController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '🕐 Horário de fim é obrigatório! Por favor, informe o horário de fim.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Validar formato dos horários
      final timeRegex = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$');
      if (!timeRegex.hasMatch(_startTimeController.text)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '⏰ Horário de início inválido! Use o formato HH:MM (ex: 14:30).',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (!timeRegex.hasMatch(_endTimeController.text)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '⏰ Horário de fim inválido! Use o formato HH:MM (ex: 16:30).',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Validar recorrência (apenas para eventos de agenda)
    if (_eventType == 'Agenda' &&
        _isRecurrent &&
        (_recurrentMonths == null || _recurrentMonths! <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '🔄 Número de meses é obrigatório! Para eventos recorrentes, informe quantos meses.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Criar data do evento
      DateTime dataEvento = DateTime(
        currentYear,
        currentMonthIndex + 1,
        selectedDay,
      );

      // Verificar o tipo de evento selecionado
      if (_eventType == 'Diário') {
        // Fazer upload da foto se houver uma selecionada
        String? fotoUrl;
        if (_fotoDiario != null) {
          try {
            print('🔵 Iniciando upload da foto do evento diário...');

            // Gerar nome único para a foto
            final String nomeArquivo =
                'evento_${DateTime.now().millisecondsSinceEpoch}.jpg';

            // Fazer upload para Supabase Storage
            fotoUrl = await EventoDiarioService.uploadFotoEventoDiario(
              condominioId: _selectedCondominioId!,
              eventoId: DateTime.now().millisecondsSinceEpoch.toString(),
              arquivo: _fotoDiario!,
              nomeArquivo: nomeArquivo,
            );

            if (fotoUrl != null) {
              print('✅ Upload da foto realizado com sucesso: $fotoUrl');
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

        // Salvar como evento diário
        final eventoDiarioSalvo = await EventoDiarioService.criarEvento(
          representanteId: widget.representante.id,
          condominioId: _selectedCondominioId!,
          titulo: _titleController.text.trim(),
          descricao: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          dataEvento: dataEvento,
        );

        print('🔵 eventoDiarioSalvo: $eventoDiarioSalvo');
        print('🔵 eventoDiarioSalvo.id: ${eventoDiarioSalvo?.id}');
        print('🔵 fotoUrl: $fotoUrl');

        // Se o upload foi bem sucedido e temos a URL da foto, atualizar o evento com a foto
        if (eventoDiarioSalvo != null && fotoUrl != null) {
          try {
            print(
              '🔵 Atualizando evento diário ${eventoDiarioSalvo.id} com foto_url: $fotoUrl',
            );
            // Atualizar o evento com a URL da foto
            final resultado = await Supabase.instance.client
                .from('eventos_diario_representante')
                .update({'foto_url': fotoUrl})
                .eq('id', eventoDiarioSalvo.id);

            print(
              '✅ Foto adicionada ao evento diário com sucesso. Resultado: $resultado',
            );
          } catch (e) {
            print('⚠️ Erro ao associar foto ao evento diário: $e');
          }
        }

        if (eventoDiarioSalvo != null) {
          // Sucesso - fechar modal e recarregar eventos
          Navigator.pop(context);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Evento diário criado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );

          // Recarregar eventos
          await _loadEvents();

          // Limpar os campos
          _titleController.clear();
          _descriptionController.clear();
          _startTimeController.clear();
          _endTimeController.clear();

          setState(() {
            _eventType = 'Agenda';
            _isRecurrent = false;
            _recurrentMonths = 1;
            _notifyAll = false;
            _notifyMe = false;
            _fotoEvento = null;
            _fotoDiario = null;
          });
        } else {
          throw Exception('Falha ao salvar evento diário');
        }
        return; // Sair da função aqui para eventos diários
      }

      // Salvar evento de agenda (com suporte a recorrência automática)

      // Fazer upload da foto se houver uma selecionada
      String? fotoUrl;
      if (_fotoEvento != null && _eventType == 'Agenda') {
        try {
          print('🔵 Iniciando upload da foto do evento...');

          // Primeiro, criar um evento temporário para obter um ID
          // Na verdade, vamos gerar um UUID único para o evento
          final String nomeArquivo =
              'evento_${DateTime.now().millisecondsSinceEpoch}.jpg';

          // Fazer upload para Supabase Storage
          fotoUrl = await EventoAgendaService.uploadFotoEventoAgenda(
            condominioId: _selectedCondominioId!,
            eventoId: DateTime.now().millisecondsSinceEpoch.toString(),
            arquivo: _fotoEvento!,
            nomeArquivo: nomeArquivo,
          );

          if (fotoUrl != null) {
            print('✅ Upload da foto realizado com sucesso: $fotoUrl');
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

      final eventoSalvo = await EventoAgendaService.criarEvento(
        representanteId: widget.representante.id,
        condominioId: _selectedCondominioId!,
        titulo: _titleController.text.trim(),
        descricao: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        dataEvento: dataEvento,
        horaInicio: _startTimeController.text.trim(),
        horaFim: _endTimeController.text.trim(),
        eventoRecorrente: _isRecurrent,
        numeroMesesRecorrencia: _isRecurrent ? _recurrentMonths : null,
        avisarCondominiosEmail: _notifyAll,
        avisarRepresentanteEmail: _notifyMe,
      );

      print('🔵 eventoSalvo: $eventoSalvo');
      print('🔵 eventoSalvo.id: ${eventoSalvo?.id}');
      print('🔵 fotoUrl: $fotoUrl');

      // Se o upload foi bem sucedido e temos a URL da foto, atualizar o evento com a foto
      if (eventoSalvo != null && fotoUrl != null) {
        try {
          print(
            '🔵 Atualizando evento ${eventoSalvo.id} com foto_url: $fotoUrl',
          );
          // Atualizar o evento com a URL da foto
          final resultado = await Supabase.instance.client
              .from('eventos_agenda_representante')
              .update({'foto_url': fotoUrl})
              .eq('id', eventoSalvo.id);

          print(
            '✅ Foto adicionada ao evento com sucesso. Resultado: $resultado',
          );
        } catch (e) {
          print('⚠️ Erro ao associar foto ao evento: $e');
        }
      }

      // A geração de eventos recorrentes é feita automaticamente dentro de criarEvento()
      // Não é necessário criar eventos em loop aqui

      if (eventoSalvo != null) {
        // Sucesso - fechar modal e recarregar eventos
        Navigator.pop(context);

        // Mensagem de sucesso personalizada
        String mensagem = 'Evento criado com sucesso!';
        if (_isRecurrent && _recurrentMonths != null && _recurrentMonths! > 1) {
          mensagem =
              'Evento criado com sucesso! ${_recurrentMonths} eventos recorrentes foram criados.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensagem), backgroundColor: Colors.green),
        );

        // Recarregar eventos
        await _loadEvents();

        // Limpar os campos
        _titleController.clear();
        _descriptionController.clear();
        _startTimeController.clear();
        _endTimeController.clear();

        setState(() {
          _eventType = 'Agenda';
          _isRecurrent = false;
          _recurrentMonths = 1;
          _notifyAll = false;
          _notifyMe = false;
          _fotoEvento = null;
        });
      } else {
        throw Exception('Falha ao salvar evento');
      }
    } catch (e) {
      print('Erro ao salvar evento: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar evento: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _updateEvent() async {
    // Validação do título
    if (_editTitleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '❌ Título é obrigatório! Por favor, informe o título do evento.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // A data não pode ser alterada, usamos a data original do evento

    // Validação do horário de início
    if (_editStartTimeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '🕐 Horário de início é obrigatório! Por favor, informe o horário de início.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validação do horário de fim
    if (_editEndTimeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '🕐 Horário de fim é obrigatório! Por favor, informe o horário de fim.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validar formato dos horários
    final timeRegex = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$');
    if (!timeRegex.hasMatch(_editStartTimeController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '⏰ Horário de início inválido! Use o formato HH:MM (ex: 14:30).',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!timeRegex.hasMatch(_editEndTimeController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '⏰ Horário de fim inválido! Use o formato HH:MM (ex: 16:30).',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validar recorrência

    setState(() {
      _isSaving = true;
    });

    try {
      if (_eventBeingEdited == null) {
        throw Exception('Evento não encontrado');
      }

      String? novaFotoUrl = _eventBeingEdited!.fotoUrl;

      // Lógica de upload de foto
      if (_editFotoEvento != null) {
        // Nova foto foi selecionada
        novaFotoUrl = await EventoAgendaService.uploadFotoEventoAgenda(
          condominioId: _eventBeingEdited!.condominioId,
          eventoId: _eventBeingEdited!.id!,
          arquivo: _editFotoEvento!,
          nomeArquivo: 'foto_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      } else if (_removerFotoEvento) {
        // Foto foi removida
        novaFotoUrl = null;
      }

      // Criar evento atualizado
      final eventoAtualizado = EventoAgenda(
        id: _eventBeingEdited!.id,
        titulo: _editTitleController.text.trim(),
        descricao: _editDescriptionController.text.trim().isEmpty
            ? null
            : _editDescriptionController.text.trim(),
        dataEvento: _eventBeingEdited!.dataEvento,
        horaInicio: _editStartTimeController.text.trim(),
        horaFim: _editEndTimeController.text.trim(),
        eventoRecorrente: _eventBeingEdited!.eventoRecorrente,
        numeroMesesRecorrencia: _eventBeingEdited!.numeroMesesRecorrencia,
        avisarCondominiosEmail: _editNotifyAll,
        avisarRepresentanteEmail: _editNotifyMe,
        condominioId:
            _editSelectedCondominioId ?? _eventBeingEdited!.condominioId,
        representanteId: _eventBeingEdited!.representanteId,
        criadoEm: _eventBeingEdited!.criadoEm,
        atualizadoEm: DateTime.now(),
        fotoUrl: novaFotoUrl,
      );

      // Atualizar evento
      final eventoSalvo = await EventoAgendaService.atualizarEvento(
        eventoId: _eventBeingEdited!.id!,
        titulo: _editTitleController.text.trim(),
        descricao: _editDescriptionController.text.trim().isEmpty
            ? null
            : _editDescriptionController.text.trim(),
        dataEvento: _eventBeingEdited!.dataEvento,
        horaInicio: _editStartTimeController.text.trim(),
        horaFim: _editEndTimeController.text.trim(),
        eventoRecorrente: _eventBeingEdited!.eventoRecorrente,
        numeroMesesRecorrencia: _eventBeingEdited!.numeroMesesRecorrencia,
        avisarCondominiosEmail: _editNotifyAll,
        avisarRepresentanteEmail: _editNotifyMe,
      );

      // Atualizar a foto se foi alterada
      if (eventoSalvo != null && novaFotoUrl != _eventBeingEdited!.fotoUrl) {
        try {
          print(
            '🔵 Atualizando foto do evento ${_eventBeingEdited!.id} com nova URL: $novaFotoUrl',
          );
          await Supabase.instance.client
              .from('eventos_agenda_representante')
              .update({'foto_url': novaFotoUrl})
              .eq('id', _eventBeingEdited!.id);
          print('✅ Foto do evento atualizada com sucesso');
        } catch (e) {
          print('⚠️ Erro ao atualizar foto do evento: $e');
        }
      }

      if (eventoSalvo != null) {
        // Sucesso - fechar modal e recarregar eventos
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Evento atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        // Recarregar eventos
        await _loadEvents();

        // Limpar os campos de edição
        _editTitleController.clear();
        _editDescriptionController.clear();
        _editStartTimeController.clear();
        _editEndTimeController.clear();

        setState(() {
          _editNotifyAll = false;
          _editNotifyMe = false;
          _eventBeingEdited = null;
          _editFotoEvento = null;
          _removerFotoEvento = false;
        });
      } else {
        throw Exception('Falha ao atualizar evento');
      }
    } catch (e) {
      print('Erro ao atualizar evento: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar evento: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _showDeleteConfirmation(EventoAgenda evento) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 8),
              Text('Confirmar Exclusão'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tem certeza que deseja excluir este evento?'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      evento.titulo,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '📅 ${evento.dataEvento.day.toString().padLeft(2, '0')}/${evento.dataEvento.month.toString().padLeft(2, '0')}/${evento.dataEvento.year}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    Text(
                      '🕐 ${_formatTimeDisplay(evento.horaInicio)} - ${_formatTimeDisplay(evento.horaFim)}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    if (evento.descricao != null &&
                        evento.descricao!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        evento.descricao!,
                        style: TextStyle(color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '⚠️ Esta ação não pode ser desfeita.',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteEvent(evento);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteEvent(EventoAgenda evento) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final sucesso = await EventoAgendaService.deletarEvento(evento.id!);

      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Evento excluído com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        // Recarregar eventos
        await _loadEvents();
      } else {
        throw Exception('Falha ao excluir evento');
      }
    } catch (e) {
      print('Erro ao excluir evento: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erro ao excluir evento: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Método para mostrar foto ampliada do evento
  void _mostrarFotoAmpliadaEvento(String fotoUrl) {
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

  // Método para mostrar foto ampliada do evento diário
  void _mostrarFotoAmpliadaEventoDiario(String fotoUrl) {
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

  Widget _buildCalendarHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: ['DOM', 'SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SÁB']
          .map(
            (day) => Expanded(
              child: Center(
                child: Text(
                  day,
                  style: TextStyle(
                    color: Colors.grey[600],
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

  Widget _buildCalendarGrid() {
    List<Widget> days = [];

    int monthNumber = currentMonthIndex + 1;
    int daysInMonth = _getDaysInMonth(monthNumber, currentYear);
    int firstDayOfWeek = _getFirstDayOfMonth(monthNumber, currentYear);

    // Adicionar células vazias no início para alinhar o primeiro dia
    for (int i = 0; i < firstDayOfWeek; i++) {
      days.add(Container());
    }

    // Adicionar os dias do mês
    for (int day = 1; day <= daysInMonth; day++) {
      days.add(_buildCalendarDay(day, isSelected: day == selectedDay));
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: days,
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

            // Título da página
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Text(
                    'Home/Gestão/Agenda',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.refresh, color: Color(0xFF1E3A8A)),
                      onPressed: _refreshData,
                      tooltip: 'Recarregar dados',
                    ),
                  ),
                ],
              ),
            ),

            // Conteúdo da agenda
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Seletor de mês/ano
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: _previousMonth,
                            icon: const Icon(Icons.chevron_left, size: 28),
                          ),
                          Text(
                            '$currentMonth $currentYear',
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
                      ),
                      const SizedBox(height: 20),

                      // Cabeçalho do calendário
                      _buildCalendarHeader(),
                      const SizedBox(height: 10),

                      // Grid do calendário
                      _buildCalendarGrid(),
                      const SizedBox(height: 30),

                      // Seção de eventos
                      Row(
                        children: [
                          Text(
                            'Eventos - Dia ${selectedDay.toString().padLeft(2, '0')}/${currentMonth.toUpperCase()}/$currentYear',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: _showAddEventModal,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                color: Color(0xFF1E3A8A),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // Lista de eventos do dia selecionado
                      _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF1E3A8A),
                              ),
                            )
                          : Column(children: _buildEventsList()),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildEventsList() {
    List<EventoAgenda> eventsForDay = _getEventsForDay(selectedDay);
    List<EventoDiario> diaryEventsForDay = _getDiaryEventsForDay(selectedDay);

    if (eventsForDay.isEmpty && diaryEventsForDay.isEmpty) {
      return [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Nenhum evento para este dia',
            style: TextStyle(color: Colors.grey, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
      ];
    }

    List<Widget> eventWidgets = [];

    // Adicionar eventos de agenda
    eventWidgets.addAll(
      eventsForDay
          .map(
            (evento) => Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Foto do evento (se existir)
                  if (evento.fotoUrl != null && evento.fotoUrl!.isNotEmpty) ...[
                    GestureDetector(
                      onTap: () {
                        _mostrarFotoAmpliadaEvento(evento.fotoUrl!);
                      },
                      child: Container(
                        width: double.infinity,
                        height: 150,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white30),
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                evento.fotoUrl!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[700],
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      color: Colors.white70,
                                    ),
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.7),
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(6),
                                child: const Icon(
                                  Icons.zoom_in,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          evento.titulo,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${_formatTimeDisplay(evento.horaInicio)} - ${_formatTimeDisplay(evento.horaFim)}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  if (evento.descricao?.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Text(
                      evento.descricao!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                  if (evento.eventoRecorrente) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.repeat,
                          color: Colors.white70,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Recorrente (${evento.numeroMesesRecorrencia ?? 1} meses)',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (evento.avisarCondominiosEmail ||
                      evento.avisarRepresentanteEmail) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.email,
                          color: Colors.white70,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          evento.avisarCondominiosEmail
                              ? 'Notificar todos'
                              : 'Notificar apenas representante',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                  // Botões de ação
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Botão Editar
                      InkWell(
                        onTap: () => _showEditEventModal(evento),
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.white30),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit, color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'Editar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Botão Excluir
                      InkWell(
                        onTap: () => _showDeleteConfirmation(evento),
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.5),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.delete, color: Colors.red, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'Excluir',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );

    // Adicionar eventos diários
    eventWidgets.addAll(
      diaryEventsForDay
          .map(
            (evento) => Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(
                  0xFF059669,
                ), // Verde para diferenciar dos eventos de agenda
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Foto do evento (se existir)
                  if (evento.fotoUrl != null && evento.fotoUrl!.isNotEmpty) ...[
                    GestureDetector(
                      onTap: () {
                        _mostrarFotoAmpliadaEventoDiario(evento.fotoUrl!);
                      },
                      child: Container(
                        width: double.infinity,
                        height: 150,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white30),
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                evento.fotoUrl!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[700],
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      color: Colors.white70,
                                    ),
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.7),
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(6),
                                child: const Icon(
                                  Icons.zoom_in,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          evento.titulo,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Diário',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (evento.descricao?.isNotEmpty == true) ...[
                    const SizedBox(height: 8),
                    Text(
                      evento.descricao!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                  // Botões de ação
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Botão Editar
                      InkWell(
                        onTap: () => _showEditDiaryEventModal(evento),
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.white30),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit, color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'Editar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Botão Excluir
                      InkWell(
                        onTap: () => _showDeleteDiaryEventConfirmation(evento),
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.5),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.delete, color: Colors.red, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'Excluir',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );

    return eventWidgets;
  }

  // Função para formatar horário removendo segundos se existirem
  String _formatTimeDisplay(String? time) {
    if (time == null) return '';

    // Se o horário tem segundos (formato HH:MM:SS), remove os segundos
    if (time.contains(':') && time.split(':').length == 3) {
      final parts = time.split(':');
      return '${parts[0]}:${parts[1]}';
    }

    // Se já está no formato HH:MM, retorna como está
    return time;
  }

  // Método para mostrar modal de edição de evento diário
  void _showEditDiaryEventModal(EventoDiario evento) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return _EditDiaryEventModalContent(
          evento: evento,
          onSave: () {
            _loadEvents();
          },
        );
      },
    );
  }

  // Método para mostrar confirmação de exclusão de evento diário
  void _showDeleteDiaryEventConfirmation(EventoDiario evento) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text(
            'Tem certeza que deseja excluir o evento "${evento.titulo}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await EventoDiarioService.deletarEvento(evento.id);

                  Navigator.of(context).pop();
                  _loadEvents(); // Recarregar eventos

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Evento diário excluído com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao excluir evento: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }
}

// StatefulWidget para edição de evento diário com foto
class _EditDiaryEventModalContent extends StatefulWidget {
  final EventoDiario evento;
  final VoidCallback onSave;

  const _EditDiaryEventModalContent({
    required this.evento,
    required this.onSave,
  });

  @override
  State<_EditDiaryEventModalContent> createState() =>
      _EditDiaryEventModalContentState();
}

class _EditDiaryEventModalContentState
    extends State<_EditDiaryEventModalContent> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  File? fotoSelecionada;
  bool removerFoto = false;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.evento.titulo);
    descriptionController = TextEditingController(
      text: widget.evento.descricao ?? '',
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho
            Text(
              'Editar Evento Diário',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),

            // Campo de título
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 16),

            // Campo de descrição
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            // Label de foto
            const Text(
              'Foto do Evento (Opcional):',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF059669),
              ),
            ),
            const SizedBox(height: 12),

            // Widget de foto
            GestureDetector(
              onTap: isSaving ? null : _selecionarFoto,
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[50],
                ),
                child: _buildPhotoWidget(),
              ),
            ),
            const SizedBox(height: 24),

            // Botões
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: isSaving ? null : _salvarEvento,
                  child: isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Salvar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoWidget() {
    // Foto selecionada
    if (fotoSelecionada != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              fotoSelecionada!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  fotoSelecionada = null;
                  removerFoto = false;
                });
              },
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(4),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      );
    }

    // Foto atual não removida
    if (!removerFoto && widget.evento.fotoUrl != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              widget.evento.fotoUrl!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported),
                );
              },
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  removerFoto = true;
                });
              },
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(4),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      );
    }

    // Nenhuma foto
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            'Clique para adicionar/trocar foto',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Future<void> _selecionarFoto() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80,
      );

      if (image == null) {
        final XFile? galleryImage = await picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 800,
          maxHeight: 600,
          imageQuality: 80,
        );
        if (galleryImage != null) {
          setState(() {
            fotoSelecionada = File(galleryImage.path);
            removerFoto = false;
          });
        }
      } else {
        setState(() {
          fotoSelecionada = File(image.path);
          removerFoto = false;
        });
      }
    } catch (e) {
      print('Erro ao selecionar imagem: $e');
    }
  }

  Future<void> _salvarEvento() async {
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O título é obrigatório'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      String? novaFotoUrl = widget.evento.fotoUrl;

      // Lógica de upload de foto
      if (fotoSelecionada != null) {
        // Nova foto foi selecionada
        novaFotoUrl = await EventoDiarioService.uploadFotoEventoDiario(
          condominioId: widget.evento.condominioId,
          eventoId: widget.evento.id,
          arquivo: fotoSelecionada!,
          nomeArquivo: 'foto_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      } else if (removerFoto) {
        // Foto foi removida
        novaFotoUrl = null;
      }

      await EventoDiarioService.atualizarEvento(
        eventoId: widget.evento.id,
        titulo: titleController.text.trim(),
        descricao: descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
        fotoUrl: novaFotoUrl,
      );

      if (mounted) {
        Navigator.pop(context);
        widget.onSave();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Evento diário atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar evento: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }
}
