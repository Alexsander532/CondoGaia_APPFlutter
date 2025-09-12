import 'package:flutter/material.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

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
  bool _notifyMe = false;
  
  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    selectedDay = now.day;
    currentMonth = months[now.month - 1];
    currentYear = now.year;
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
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
  ];
  
  int get currentMonthIndex => months.indexOf(currentMonth);
  
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
  }
  
  Widget _buildCalendarDay(int day, {bool isSelected = false}) {
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
        ),
        child: Center(
          child: Text(
            day.toString(),
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
  
  void _showAddEventModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
              Text(
                'Reservar Dia ${selectedDay.toString().padLeft(2, '0')}/${_getMonthName(currentMonthIndex + 1)}/$currentYear',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(height: 20),
              
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
                          setState(() {
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
                          setState(() {
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
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF1E3A8A)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF1E3A8A)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                            decoration: InputDecoration(
                              hintText: ':',
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
                                borderSide: const BorderSide(color: Color(0xFF1E3A8A)),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                            decoration: InputDecoration(
                              hintText: ':',
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
                                borderSide: const BorderSide(color: Color(0xFF1E3A8A)),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                        setState(() {
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
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          onChanged: (value) {
                            _recurrentMonths = int.tryParse(value) ?? 1;
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
                            setState(() {
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
                            setState(() {
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
              const SizedBox(height: 20),
              
              // Anexar fotografias
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.photo_camera_outlined, color: Color(0xFF1E3A8A), size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Anexar foto/arquivo',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF1E3A8A),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              
              // Botão Salvar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
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
      ),
    );
  }
  
  String _getMonthName(int month) {
    const months = [
      'JANEIRO', 'FEVEREIRO', 'MARÇO', 'ABRIL', 'MAIO', 'JUNHO',
      'JULHO', 'AGOSTO', 'SETEMBRO', 'OUTUBRO', 'NOVEMBRO', 'DEZEMBRO'
    ];
    return months[month - 1];
  }

  void _saveEvent() {
    // Por enquanto apenas fecha o modal
    Navigator.pop(context);
    
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
    });
  }
  
  Widget _buildCalendarHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        'DOM', 'SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SÁB'
      ].map((day) => Expanded(
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
      )).toList(),
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
                'Home/Gestão/Agenda',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            // Conteúdo da agenda
            Expanded(
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
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    
                    // Card de evento
                    if (selectedDay == DateTime.now().day && currentMonth == months[DateTime.now().month - 1] && currentYear == DateTime.now().year)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E3A8A),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dedetização',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Evento recorrente',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
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