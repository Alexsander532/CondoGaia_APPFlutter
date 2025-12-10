
import 'package:flutter/material.dart';
import '../models/evento_diario.dart';
import '../models/evento_agenda.dart';
import '../services/evento_diario_service.dart';
import '../services/evento_agenda_service.dart';

class AgendaInquilinoScreen extends StatefulWidget {
  final String condominioId;
  const AgendaInquilinoScreen({Key? key, required this.condominioId}) : super(key: key);

  @override
  State<AgendaInquilinoScreen> createState() => _AgendaInquilinoScreenState();
}

class _AgendaInquilinoScreenState extends State<AgendaInquilinoScreen> {
  late final DateTime _today;
  late DateTime _selectedDate;
  late int _currentMonthIndex;
  late int _currentYear;
  final List<String> _months = const [
    'Janeiro', 'Fevereiro', 'Março', 'Abril',
    'Maio', 'Junho', 'Julho', 'Agosto',
    'Setembro', 'Outubro', 'Novembro', 'Dezembro'
  ];

  List<EventoDiario> _eventos = [];
  List<EventoAgenda> _eventosAgenda = [];
  Set<int> _diasComEventos = {};

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _selectedDate = _today;
    _currentMonthIndex = _selectedDate.month - 1;
    _currentYear = _selectedDate.year;
    print('🔵 AgendaInquilinoScreen - condominioId: ${widget.condominioId}');
    _carregarAmbientes();
    _carregarReservas();
  }

  Future<void> _carregarAmbientes() async {
    // Não carrega ambientes mais, apenas eventos do diário
  }

  Future<void> _carregarReservas() async {
    try {
      if (widget.condominioId.isEmpty) {
        print('❌ condominioId está vazio!');
        return;
      }
      print('🔵 Carregando eventos para condominio: ${widget.condominioId}');
      
      // Carrega eventos de diário
      final eventos = await EventoDiarioService.buscarEventosPorCondominio(widget.condominioId);
      print('📅 Eventos de diário: ${eventos.length}');
      
      // Carrega eventos de agenda
      final eventosAgenda = await EventoAgendaService.buscarEventosPorCondominio(widget.condominioId);
      print('📅 Eventos de agenda: ${eventosAgenda.length}');
      
      // Combina os eventos de ambos os tipos
      final todosDias = <int>{};
      
      for (var evento in eventos) {
        print('📅 Evento diário encontrado: ${evento.titulo} em ${evento.dataEvento}');
        if (evento.dataEvento.month == _currentMonthIndex + 1 &&
            evento.dataEvento.year == _currentYear) {
          todosDias.add(evento.dataEvento.day);
        }
      }
      
      for (var evento in eventosAgenda) {
        print('📅 Evento agenda encontrado: ${evento.titulo} em ${evento.dataEvento}');
        if (evento.dataEvento.month == _currentMonthIndex + 1 &&
            evento.dataEvento.year == _currentYear) {
          todosDias.add(evento.dataEvento.day);
        }
      }
      
      setState(() {
        _eventos = eventos;
        _eventosAgenda = eventosAgenda;
        _diasComEventos = todosDias;
      });
      print('✅ Total de eventos diários: ${eventos.length}');
      print('✅ Total de eventos agenda: ${eventosAgenda.length}');
      print('✅ Dias com eventos: $todosDias');
    } catch (e) {
      print('❌ Erro ao carregar eventos: $e');
    }
  }

  bool _hasReservationOn(DateTime date) {
    return _diasComEventos.contains(date.day) &&
           date.month == _currentMonthIndex + 1 &&
           date.year == _currentYear;
  }

  String _formatarHora(String hora) {
    try {
      if (hora.length >= 5) {
        return hora.substring(0, 5);
      }
      return hora;
    } catch (e) {
      return hora;
    }
  }

  void _previousMonth() {
    setState(() {
      _currentMonthIndex--;
      if (_currentMonthIndex < 0) {
        _currentMonthIndex = 11;
        _currentYear--;
      }
      final daysInCurrentMonth = DateTime(_currentYear, _currentMonthIndex + 2, 0).day;
      final selectedDay = _selectedDate.day > daysInCurrentMonth ? daysInCurrentMonth : _selectedDate.day;
      _selectedDate = DateTime(_currentYear, _currentMonthIndex + 1, selectedDay);
      _carregarReservas();
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonthIndex++;
      if (_currentMonthIndex > 11) {
        _currentMonthIndex = 0;
        _currentYear++;
      }
      final daysInNewMonth = DateTime(_currentYear, _currentMonthIndex + 2, 0).day;
      final selectedDay = _selectedDate.day > daysInNewMonth ? daysInNewMonth : _selectedDate.day;
      _selectedDate = DateTime(_currentYear, _currentMonthIndex + 1, selectedDay);
      _carregarReservas();
    });
  }

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

  Widget _buildCalendarHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: const [
        'DOM', 'SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SÁB'
      ].map((day) => Expanded(
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
      )).toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_currentYear, _currentMonthIndex + 1, 1);
    final lastDayOfMonth = DateTime(_currentYear, _currentMonthIndex + 2, 0);
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday % 7;

    final days = <Widget>[];

    for (int i = 0; i < firstWeekday; i++) {
      days.add(const SizedBox());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_currentYear, _currentMonthIndex + 1, day);
      final isSelected = _selectedDate.day == day &&
          _selectedDate.month == _currentMonthIndex + 1 &&
          _selectedDate.year == _currentYear;
      final isToday = _today.day == day &&
          _today.month == _currentMonthIndex + 1 &&
          _today.year == _currentYear;
      final hasReservation = _hasReservationOn(date);

      days.add(_buildCalendarDay(
        day: day,
        isSelected: isSelected,
        isToday: isToday,
        hasReservation: hasReservation,
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

  Widget _buildReservationCard() {
    // Filtra eventos de diário do dia selecionado
    final eventosDoDia = _eventos.where((evento) {
      return evento.dataEvento.day == _selectedDate.day &&
             evento.dataEvento.month == _selectedDate.month &&
             evento.dataEvento.year == _selectedDate.year;
    }).toList();

    // Filtra eventos de agenda do dia selecionado
    final eventosAgendaDoDia = _eventosAgenda.where((evento) {
      return evento.dataEvento.day == _selectedDate.day &&
             evento.dataEvento.month == _selectedDate.month &&
             evento.dataEvento.year == _selectedDate.year;
    }).toList();

    // Se não houver eventos de nenhum tipo
    if (eventosDoDia.isEmpty && eventosAgendaDoDia.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.event_note, size: 48, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'Nenhum evento para este dia',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // Eventos de diário
        ...eventosDoDia.map((evento) {
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
                // Foto do evento (se houver)
                if (evento.fotoUrl != null && evento.fotoUrl!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: GestureDetector(
                      onTap: () => _abrirImagemAmpliada(context, evento.fotoUrl!),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Stack(
                          children: [
                            Image.network(
                              evento.fotoUrl!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 200,
                                  width: double.infinity,
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Icon(Icons.image_not_supported, color: Colors.grey),
                                  ),
                                );
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  height: 200,
                                  width: double.infinity,
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              },
                            ),
                            // Overlay com ícone de ampliação
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.zoom_in,
                                    color: Colors.white.withOpacity(0),
                                    size: 48,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Primeira linha: Título
                Text(
                  evento.titulo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                const SizedBox(height: 8.0),

                // Descrição (se houver)
                if (evento.descricao != null && evento.descricao!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      evento.descricao!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13.0,
                      ),
                    ),
                  ),

                // Badge de tipo
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'DIÁRIO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),

        // Eventos de agenda
        ...eventosAgendaDoDia.map((evento) {
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
                // Foto do evento (se houver)
                if (evento.fotoUrl != null && evento.fotoUrl!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: GestureDetector(
                      onTap: () => _abrirImagemAmpliada(context, evento.fotoUrl!),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Stack(
                          children: [
                            Image.network(
                              evento.fotoUrl!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 200,
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Icon(Icons.image_not_supported, color: Colors.grey),
                                  ),
                                );
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  height: 200,
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              },
                            ),
                            // Overlay com ícone de ampliação
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.zoom_in,
                                    color: Colors.white.withOpacity(0),
                                    size: 48,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Primeira linha: Título e Horário
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        evento.titulo,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                    Text(
                      '${_formatarHora(evento.horaInicio)}${evento.horaFim != null ? ' - ${_formatarHora(evento.horaFim!)}' : ''}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4.0),

                // Descrição
                if (evento.descricao != null && evento.descricao!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      evento.descricao!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13.0,
                      ),
                    ),
                  ),

                const SizedBox(height: 4.0),

                // Informações adicionais
                if (evento.eventoRecorrente)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Recorrente: cada ${evento.numeroMesesRecorrencia ?? 1} mês(es)',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12.0,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),

                // Badge de tipo
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'AGENDA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  void _abrirImagemAmpliada(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black87,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            // Imagem ampliada
            Center(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[800],
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
            ),
            // Botão de fechar
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
              ),
            ),
          ],
        ),
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
                  'Home/Diário-Agenda',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              
              // Conteúdo da agenda
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMonthSelector(),
                    const SizedBox(height: 24.0),
                    _buildCalendarHeader(),
                    const SizedBox(height: 8.0),
                    _buildCalendarGrid(),
                    const SizedBox(height: 24.0),
                    _buildReservationCard(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}