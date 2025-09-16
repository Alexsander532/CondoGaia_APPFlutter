import 'package:flutter/material.dart';

class AgendaInquilinoScreen extends StatefulWidget {
  final String? condominioId;
  final String? inquilinoId;
  
  const AgendaInquilinoScreen({
    super.key,
    this.condominioId,
    this.inquilinoId,
  });

  @override
  State<AgendaInquilinoScreen> createState() => _AgendaInquilinoScreenState();
}

class _AgendaInquilinoScreenState extends State<AgendaInquilinoScreen> {
  late int selectedDay;
  late String currentMonth;
  late int currentYear;
  
  // IDs para operações
  String get condominioId => widget.condominioId ?? 'demo-condominio-id';
  String get inquilinoId => widget.inquilinoId ?? 'demo-inquilino-id';
  
  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    selectedDay = now.day;
    currentMonth = months[now.month - 1];
    currentYear = now.year;
  }
  
  final List<String> months = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
  ];
  
  // Dados mockados de eventos criados pelo representante
  final Map<String, List<Map<String, dynamic>>> eventosPorData = {
    '06/05/2022': [
      {
        'titulo': 'Dedetização',
        'tipo': 'Agenda',
        'horario': '18h30 até 22h',
        'descricao': 'Dedetização do condomínio - Evento recorrente',
        'criadoPor': 'Administradora',
      }
    ],
    '15/05/2022': [
      {
        'titulo': 'Reunião com a Administradora',
        'tipo': 'Diário',
        'horario': 'Todo o dia',
        'descricao': 'Hoje foi reunião com a equipe da Administradora do Condomínio.',
        'criadoPor': 'Representante',
      }
    ],
    '20/05/2022': [
      {
        'titulo': 'Manutenção Elevador',
        'tipo': 'Agenda',
        'horario': '08h00 até 17h00',
        'descricao': 'Manutenção preventiva do elevador social',
        'criadoPor': 'Administradora',
      }
    ],
  };
  
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
  
  Widget _buildCalendarDay(int day, {bool isSelected = false, bool hasEvent = false}) {
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
            // Indicador de evento
            if (hasEvent)
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
  
  String _getMonthName(int month) {
    const monthNames = [
      '', 'JANEIRO', 'FEVEREIRO', 'MARÇO', 'ABRIL', 'MAIO', 'JUNHO',
      'JULHO', 'AGOSTO', 'SETEMBRO', 'OUTUBRO', 'NOVEMBRO', 'DEZEMBRO'
    ];
    return monthNames[month];
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
      String dateKey = '${day.toString().padLeft(2, '0')}/${_getMonthName(monthNumber).substring(0, 3)}/$currentYear';
      String dateKeyFull = '${day.toString().padLeft(2, '0')}/${monthNumber.toString().padLeft(2, '0')}/$currentYear';
      bool hasEvent = eventosPorData.containsKey(dateKeyFull);
      
      days.add(_buildCalendarDay(
        day, 
        isSelected: day == selectedDay,
        hasEvent: hasEvent,
      ));
    }
    
    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: days,
    );
  }
  
  List<Map<String, dynamic>> _getEventosForSelectedDay() {
    String dateKey = '${selectedDay.toString().padLeft(2, '0')}/${(currentMonthIndex + 1).toString().padLeft(2, '0')}/$currentYear';
    return eventosPorData[dateKey] ?? [];
  }
  
  Widget _buildEventCard(Map<String, dynamic> evento) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A8A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  evento['titulo'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  evento['tipo'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (evento['horario'] != null)
            Text(
              evento['horario'],
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          const SizedBox(height: 4),
          Text(
            evento['descricao'],
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Criado por: ${evento['criadoPor']}',
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> eventosDodia = _getEventosForSelectedDay();
    
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
                    
                    // Seção de eventos (sem botão de adicionar)
                    Text(
                      'Eventos - Dia ${selectedDay.toString().padLeft(2, '0')}/${currentMonth.toUpperCase()}/$currentYear',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 15),
                    
                    // Lista de eventos
                    Expanded(
                      child: eventosDodia.isEmpty
                          ? const Center(
                              child: Text(
                                'Nenhum evento neste dia',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: eventosDodia.length,
                              itemBuilder: (context, index) {
                                return _buildEventCard(eventosDodia[index]);
                              },
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