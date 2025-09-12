import 'package:flutter/material.dart';
import 'configurar_ambientes_screen.dart';

class ReservasScreen extends StatefulWidget {
  const ReservasScreen({super.key});

  @override
  State<ReservasScreen> createState() => _ReservasScreenState();
}

class _ReservasScreenState extends State<ReservasScreen> {
  // Variáveis para controle do calendário
  late DateTime _currentDate;
  late int _currentMonth;
  late int _currentYear;
  List<int> _selectedDays = [];
  String _selectedDay = '';
  
  // Controladores para os campos do formulário
  final TextEditingController _valorController = TextEditingController(text: 'R\$ 100,00');
  final TextEditingController _horaInicioController = TextEditingController();
  final TextEditingController _horaFimController = TextEditingController();
  
  // Variáveis para controle do formulário
  String _selectedLocal = 'Salão de Festas';
  bool _isCondominio = true;
  bool _isBlocoUnid = false;
  bool _termoLocacao = false;
  
  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    _currentMonth = _currentDate.month;
    _currentYear = _currentDate.year;
    // Atualizar para a data atual
    _selectedDay = '${_currentDate.day.toString().padLeft(2, '0')}/${_getMonthName(_currentDate.month).toUpperCase()}/${_currentDate.year}';
  }
  
  @override
  void dispose() {
    _valorController.dispose();
    _horaInicioController.dispose();
    _horaFimController.dispose();
    super.dispose();
  }

  // Função para obter o nome do mês
  String _getMonthName(int month) {
    const monthNames = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril',
      'Maio', 'Junho', 'Julho', 'Agosto',
      'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    return monthNames[month - 1];
  }

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

  // Função para navegar para o mês anterior
  void _previousMonth() {
    setState(() {
      if (_currentMonth == 1) {
        _currentMonth = 12;
        _currentYear--;
      } else {
        _currentMonth--;
      }
    });
  }

  // Função para navegar para o próximo mês
  void _nextMonth() {
    setState(() {
      if (_currentMonth == 12) {
        _currentMonth = 1;
        _currentYear++;
      } else {
        _currentMonth++;
      }
    });
  }

  // Função para construir o cabeçalho do calendário
  Widget _buildCalendarHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _previousMonth,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          Text(
            '${_getMonthName(_currentMonth)} $_currentYear',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _nextMonth,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  // Função para construir o grid do calendário
  Widget _buildCalendarGrid() {
    const daysOfWeek = ['DOM', 'SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SAB'];
    final daysInMonth = _getDaysInMonth(_currentMonth, _currentYear);
    final firstDayOfWeek = _getFirstDayOfWeekFromMonth(_currentMonth, _currentYear);

    // Construir cabeçalho dos dias da semana
    final List<Widget> dayHeaders = daysOfWeek.map((day) {
      return Container(
        alignment: Alignment.center,
        child: Text(
          day,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }).toList();

    // Construir células do calendário
    final List<Widget> calendarCells = [];

    // Adicionar células vazias para os dias antes do primeiro dia do mês
    for (int i = 0; i < firstDayOfWeek; i++) {
      calendarCells.add(Container());
    }

    // Adicionar células para os dias do mês
    for (int day = 1; day <= daysInMonth; day++) {
      final isSelected = day == _currentDate.day && _currentMonth == _currentDate.month && _currentYear == _currentDate.year;
      final hasEvent = day == _currentDate.day && _currentMonth == _currentDate.month && _currentYear == _currentDate.year; // Apenas o dia atual tem evento
      
      calendarCells.add(
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? const Color(0xFF003E7E) : Colors.transparent,
          ),
          alignment: Alignment.center,
          child: Text(
            day.toString(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected 
                  ? Colors.white 
                  : hasEvent 
                      ? const Color(0xFF003E7E) 
                      : Colors.black,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        // Cabeçalho dos dias da semana
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 7,
          children: dayHeaders,
        ),
        // Grid do calendário
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 7,
          children: calendarCells,
        ),
      ],
    );
  }

  // Função para verificar se há reservas para hoje
  bool _hasReservationsForToday() {
    // Por padrão, não há reservas - mostra apenas o botão de adicionar
    // Você pode modificar esta lógica para verificar reservas reais do banco de dados
    return false;
  }

  // Função para construir a seção "Adicionar novo evento"
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
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 24.0,
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          GestureDetector(
            onTap: _showReservationModal,
            child: const Text(
              'Adicionar novo evento',
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
                'Reservar Dia $_selectedDay',
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
                  child: _buildReservationForm(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Função para construir o card de reserva existente
  Widget _buildReservationCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(36.0),
      decoration: BoxDecoration(
        color: const Color(0xFF003E7E),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Salão de Festas - 18h30 às 22h',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
          const SizedBox(height: 14.0),
          const Text(
            'Reservado por José da Silva Amarante 102/B',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.0,
            ),
          ),
        ],
      ),
    );
  }

  // Função para construir o formulário de reserva
  Widget _buildReservationForm() {
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
          Row(
            children: [
              Radio(
                value: true,
                groupValue: _isCondominio,
                onChanged: (value) {
                  setState(() {
                    _isCondominio = true;
                    _isBlocoUnid = false;
                  });
                },
                activeColor: const Color(0xFF003E7E),
              ),
              const Text('Condomínio'),
              const SizedBox(width: 16.0),
              Radio(
                value: true,
                groupValue: _isBlocoUnid,
                onChanged: (value) {
                  setState(() {
                    _isCondominio = false;
                    _isBlocoUnid = true;
                  });
                },
                activeColor: const Color(0xFF003E7E),
              ),
              const Text('Bloco/Unid.'),
            ],
          ),
          const SizedBox(height: 16.0),
          // Campo Local
          const Text(
            'Local:',
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedLocal,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedLocal = newValue;
                    });
                  }
                },
                items: <String>['Salão de Festas', 'Churrasqueira', 'Quadra']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          // Valor da locação
          const Text(
            'Valor da locação:',
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8.0),
          TextField(
            controller: _valorController,
            readOnly: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
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
                    const Text(
                      'Hora de Início',
                      style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8.0),
                    TextField(
                      controller: _horaInicioController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                        hintText: '-',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hora de Fim',
                      style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8.0),
                    TextField(
                      controller: _horaFimController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                        hintText: '-',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          // Lista de presentes
          const Text(
            'Lista de Presentes',
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8.0),
          Container(
            height: 80.0,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              children: const [
                Text('1'),
                Text('2'),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          // Botão de upload
          Row(
            children: [
              const Icon(Icons.visibility, color: Color(0xFF003E7E)),
              const SizedBox(width: 8.0),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Fazer Upload da Lista',
                  style: TextStyle(color: Color(0xFF003E7E)),
                ),
              ),
            ],
          ),
          // Termo de locação
          Row(
            children: [
              Checkbox(
                value: _termoLocacao,
                onChanged: (value) {
                  setState(() {
                    _termoLocacao = value ?? false;
                  });
                },
                activeColor: const Color(0xFF003E7E),
              ),
              const Text('Termo de Locação'),
            ],
          ),
          const SizedBox(height: 16.0),
          // Botão de reservar
          Center(
            child: ElevatedButton(
                onPressed: () {
                  // Fechar o modal após reservar
                  Navigator.of(context).pop();
                  // Aqui você pode adicionar a lógica para salvar a reserva
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003E7E),
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
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
            
            // Caminho de navegação
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ConfigurarAmbientesScreen(),
                      ),
                    );
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
            _buildCalendarHeader(),
            _buildCalendarGrid(),
            
            // Reservas do dia selecionado
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Reservados - Dia $_selectedDay',
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
            
            // Verificar se há reservas para o dia atual
            _hasReservationsForToday() ? _buildReservationCard() : _buildAddEventSection(),
            ],
          ),
        ),
      ),
    );
  }
}