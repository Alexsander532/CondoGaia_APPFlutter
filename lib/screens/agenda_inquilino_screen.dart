
import 'package:flutter/material.dart';
import '../models/ambiente.dart';
import '../models/reserva.dart';
import '../services/ambiente_service.dart';
import '../services/reserva_service.dart';

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

  List<Ambiente> _ambientes = [];
  List<Reserva> _reservas = [];
  Set<int> _diasComReservas = {};

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _selectedDate = _today;
    _currentMonthIndex = _selectedDate.month - 1;
    _currentYear = _selectedDate.year;
    _carregarAmbientes();
    _carregarReservas();
  }

  Future<void> _carregarAmbientes() async {
    try {
      final ambientes = await AmbienteService.getAmbientes();
      setState(() {
        _ambientes = ambientes;
      });
    } catch (e) {
      setState(() {
      });
    }
  }

  Future<void> _carregarReservas() async {
    try {
      final reservas = await ReservaService.getReservasPorCondominio(widget.condominioId);
      final diasComReservas = <int>{};
      for (var reserva in reservas) {
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

  bool _hasReservationOn(DateTime date) {
    return _diasComReservas.contains(date.day) &&
           date.month == _currentMonthIndex + 1 &&
           date.year == _currentYear;
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
        onTap: () {
          setState(() {
            _selectedDate = date;
          });
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
          color: isSelected ? const Color(0xFF003E7E) : Colors.white,
          border: isToday ? Border.all(color: const Color(0xFF003E7E), width: 2) : null,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected ? [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 4)] : [],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              day.toString(),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
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
    final reservasDoDia = _reservas.where((reserva) {
      return reserva.dataReserva.day == _selectedDate.day &&
             reserva.dataReserva.month == _selectedDate.month &&
             reserva.dataReserva.year == _selectedDate.year;
    }).toList();

    if (reservasDoDia.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.event_note, size: 48, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'Nenhuma reserva para este dia',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reservasDoDia.length,
      itemBuilder: (context, index) {
        final reserva = reservasDoDia[index];
        final ambiente = _ambientes.firstWhere(
          (a) => a.id == reserva.ambienteId,
          orElse: () => Ambiente(
            id: '',
            titulo: 'Ambiente desconhecido',
            valor: 0,
          ),
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

              // Descrição
              Text(
                reserva.para,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13.0,
                ),
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

              const SizedBox(height: 8.0),

              // Observações (se houver)
              if (reserva.listaPresentes != null && reserva.listaPresentes!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    reserva.listaPresentes!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12.0,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
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
        ),
      ),
    );
  }
}