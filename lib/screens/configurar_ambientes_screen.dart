import 'package:flutter/material.dart';

class ConfigurarAmbientesScreen extends StatefulWidget {
  const ConfigurarAmbientesScreen({super.key});

  @override
  State<ConfigurarAmbientesScreen> createState() => _ConfigurarAmbientesScreenState();
}

class _ConfigurarAmbientesScreenState extends State<ConfigurarAmbientesScreen> {
  // Lista de ambientes - vazia por padrão para mostrar o estado inicial
  List<Map<String, String>> ambientes = [
    {'nome': 'Salao de Festa', 'tipo': 'ambiente'},
    {'nome': 'Churrasqueira 1', 'tipo': 'ambiente'},
  ];

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
            
            // Caminho de navegação
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: const Text(
                'Home/Gestão/Reservas/Conf.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            // Título da seção
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: const Text(
                'Ambientes Existentes',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF1E3A8A),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            // Conteúdo principal
            Expanded(
              child: ambientes.isEmpty ? _buildEmptyState() : _buildAmbientesList(),
            ),
          ],
        ),
      ),
    );
  }
  
  // Estado vazio - quando não há ambientes cadastrados
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            'Nenhum',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 40),
          
          // Espaço flexível para centralizar o botão
          const Spacer(),
          
          // Botão Adicionar Novo Ambiente
          GestureDetector(
            onTap: () {
              _showAddAmbienteModal();
            },
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF1E3A8A),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Color(0xFF1E3A8A),
                    size: 30,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Adicionar',
                  style: TextStyle(
                    color: Color(0xFF1E3A8A),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Text(
                  'Novo Ambiente',
                  style: TextStyle(
                    color: Color(0xFF1E3A8A),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          const Spacer(),
        ],
      ),
    );
  }
  
  // Lista de ambientes - quando há ambientes cadastrados
  Widget _buildAmbientesList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          // Lista de ambientes
          Expanded(
            child: ListView.builder(
              itemCount: ambientes.length,
              itemBuilder: (context, index) {
                final ambiente = ambientes[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          ambiente['nome']!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _showEditAmbienteModal(index);
                        },
                        child: const Icon(
                          Icons.edit,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Botão Adicionar Novo Ambiente (quando já há ambientes)
          GestureDetector(
            onTap: () {
              _showAddAmbienteModal();
            },
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF1E3A8A),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Color(0xFF1E3A8A),
                    size: 30,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Adicionar',
                  style: TextStyle(
                    color: Color(0xFF1E3A8A),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Text(
                  'Novo Ambiente',
                  style: TextStyle(
                    color: Color(0xFF1E3A8A),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Modal para adicionar novo ambiente
  void _showAddAmbienteModal() {
    final TextEditingController tituloController = TextEditingController();
    final TextEditingController descricaoController = TextEditingController();
    final TextEditingController valorController = TextEditingController();
    final TextEditingController limiteHorarioController = TextEditingController();
    final TextEditingController limiteDuracaoController = TextEditingController();
    final TextEditingController diasBloqueadosController = TextEditingController();
    
    bool inadimplentesPodemReservar = true;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
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
              const Text(
                'Criar Novo Ambiente',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(height: 20),
              
              // Conteúdo scrollável
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Campo Título
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
                        controller: tituloController,
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
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Campo Descrição
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
                         controller: descricaoController,
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
                           contentPadding: const EdgeInsets.symmetric(
                             horizontal: 12,
                             vertical: 12,
                           ),
                         ),
                       ),
                      const SizedBox(height: 16),
                      
                      // Campo Valor
                       const Text(
                         'Valor:',
                         style: TextStyle(
                           fontSize: 16,
                           fontWeight: FontWeight.w500,
                           color: Colors.black87,
                         ),
                       ),
                       const SizedBox(height: 8),
                       TextField(
                         controller: valorController,
                         keyboardType: TextInputType.number,
                         onChanged: (value) {
                           // Remove todos os caracteres não numéricos
                           String numericValue = value.replaceAll(RegExp(r'[^0-9]'), '');
                           
                           if (numericValue.isNotEmpty) {
                             // Converte para double e divide por 100 para ter centavos
                             double doubleValue = double.parse(numericValue) / 100;
                             
                             // Formata como moeda brasileira
                             String formattedValue = 'R\$ ${doubleValue.toStringAsFixed(2).replaceAll('.', ',')}';
                             
                             // Atualiza o controller sem causar loop infinito
                             if (valorController.text != formattedValue) {
                               valorController.value = TextEditingValue(
                                 text: formattedValue,
                                 selection: TextSelection.collapsed(offset: formattedValue.length),
                               );
                             }
                           } else {
                             valorController.clear();
                           }
                         },
                         decoration: InputDecoration(
                           hintText: 'R\$ 0,00',
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
                           contentPadding: const EdgeInsets.symmetric(
                             horizontal: 12,
                             vertical: 12,
                           ),
                         ),
                       ),
                      const SizedBox(height: 20),
                      
                      // Seção Especificações
                      const Text(
                        'Especificações',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Campo Limite de Horário
                      const Text(
                        'Limite de Horário:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: limiteHorarioController,
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
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Campo Limite de Tempo de Duração
                      const Text(
                        'Limite de Tempo de Duração:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: limiteDuracaoController,
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
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Campo Dias Bloqueados
                      const Text(
                        'Dias Bloqueados:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: diasBloqueadosController,
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
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Pergunta sobre inadimplentes
                      const Text(
                        'Inadimplentes podem reservar?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Radio<bool>(
                            value: true,
                            groupValue: inadimplentesPodemReservar,
                            onChanged: (value) {
                              setState(() {
                                inadimplentesPodemReservar = value!;
                              });
                            },
                            activeColor: const Color(0xFF1E3A8A),
                          ),
                          const Text(
                            'Sim',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Radio<bool>(
                            value: false,
                            groupValue: inadimplentesPodemReservar,
                            onChanged: (value) {
                              setState(() {
                                inadimplentesPodemReservar = value!;
                              });
                            },
                            activeColor: const Color(0xFF1E3A8A),
                          ),
                          const Text(
                            'Não',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Botões de anexar
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              // TODO: Implementar anexar termo
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Anexar termo em desenvolvimento')),
                              );
                            },
                            child: Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF1E3A8A),
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    size: 12,
                                    color: Color(0xFF1E3A8A),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Anexar termo',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF1E3A8A),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              // TODO: Implementar anexar imagem
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Anexar imagem em desenvolvimento')),
                              );
                            },
                            child: Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF1E3A8A),
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    size: 12,
                                    color: Color(0xFF1E3A8A),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Anexar Imagem',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF1E3A8A),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
              
              // Botão Criar Ambiente
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (tituloController.text.isNotEmpty) {
                      setState(() {
                        ambientes.add({
                          'nome': tituloController.text,
                          'tipo': 'ambiente',
                        });
                      });
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Criar Ambiente',
                    style: TextStyle(
                      fontSize: 16,
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
  
  // Modal para editar ambiente existente
  void _showEditAmbienteModal(int index) {
    final TextEditingController tituloController = TextEditingController(
      text: ambientes[index]['nome'],
    );
    final TextEditingController descricaoController = TextEditingController();
    final TextEditingController valorController = TextEditingController();
    final TextEditingController limiteHorarioController = TextEditingController();
    final TextEditingController limiteDuracaoController = TextEditingController();
    final TextEditingController diasBloqueadosController = TextEditingController();
    
    bool inadimplentesPodemReservar = false;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.95,
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
                // Cabeçalho com título e ícone de deletar
                Row(
                  children: [
                    const Text(
                      'Editar Ambiente',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        // Remover ambiente
                        setState(() {
                          ambientes.removeAt(index);
                        });
                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Conteúdo scrollável
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Campo Título
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
                          controller: tituloController,
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
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Campo Descrição
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
                          controller: descricaoController,
                          maxLines: 3,
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
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Campo Valor
                        const Text(
                          'Valor:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: valorController,
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            // Remove todos os caracteres não numéricos
                            String numericValue = value.replaceAll(RegExp(r'[^0-9]'), '');
                            
                            if (numericValue.isEmpty) {
                              valorController.text = '';
                              valorController.selection = TextSelection.fromPosition(
                                TextPosition(offset: valorController.text.length),
                              );
                              return;
                            }
                            
                            // Converte para double e formata como moeda
                            double valueAsDouble = double.parse(numericValue) / 100;
                            String formattedValue = valueAsDouble.toStringAsFixed(2).replaceAll('.', ',');
                            
                            valorController.text = formattedValue;
                            valorController.selection = TextSelection.fromPosition(
                              TextPosition(offset: valorController.text.length),
                            );
                          },
                          decoration: InputDecoration(
                            prefixText: 'R\$ ',
                            hintText: '0,00',
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
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Seção Especificações
                        const Text(
                          'Especificações',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Campo Limite de Hora
                        const Text(
                          'Limite de Hora:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: limiteHorarioController,
                          onChanged: (value) {
                            // Remove todos os caracteres não numéricos
                            String numericValue = value.replaceAll(RegExp(r'[^0-9]'), '');
                            
                            if (numericValue.isEmpty) {
                              limiteHorarioController.text = '';
                              limiteHorarioController.selection = TextSelection.fromPosition(
                                TextPosition(offset: limiteHorarioController.text.length),
                              );
                              return;
                            }
                            
                            // Formata como xxhyymin
                            String formatted = '';
                            if (numericValue.length >= 1) {
                              if (numericValue.length <= 2) {
                                formatted = numericValue + 'h';
                              } else if (numericValue.length <= 4) {
                                String hours = numericValue.substring(0, 2);
                                String minutes = numericValue.substring(2);
                                formatted = hours + 'h' + minutes + 'min';
                              } else {
                                String hours = numericValue.substring(0, 2);
                                String minutes = numericValue.substring(2, 4);
                                formatted = hours + 'h' + minutes + 'min';
                              }
                            }
                            
                            limiteHorarioController.text = formatted;
                            limiteHorarioController.selection = TextSelection.fromPosition(
                              TextPosition(offset: limiteHorarioController.text.length),
                            );
                          },
                          decoration: InputDecoration(
                            hintText: '',
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
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Campo Limite de Tempo de Duração
                        const Text(
                          'Limite de Tempo de Duração:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: limiteDuracaoController,
                          onChanged: (value) {
                            // Remove todos os caracteres não numéricos
                            String numericValue = value.replaceAll(RegExp(r'[^0-9]'), '');
                            
                            if (numericValue.isEmpty) {
                              limiteDuracaoController.text = '';
                              limiteDuracaoController.selection = TextSelection.fromPosition(
                                TextPosition(offset: limiteDuracaoController.text.length),
                              );
                              return;
                            }
                            
                            // Formata como xh
                            String formatted = numericValue + 'h';
                            
                            limiteDuracaoController.text = formatted;
                            limiteDuracaoController.selection = TextSelection.fromPosition(
                              TextPosition(offset: limiteDuracaoController.text.length),
                            );
                          },
                          decoration: InputDecoration(
                            hintText: '',
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
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Campo Dias Bloqueados
                        const Text(
                          'Dias Bloqueados:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: diasBloqueadosController,
                          onChanged: (value) {
                            // Implementa máscara dd/mm/yyyy com múltiplas datas separadas por ;
                            String formatted = '';
                            String numericValue = value.replaceAll(RegExp(r'[^0-9;]'), '');
                            
                            List<String> dates = numericValue.split(';');
                            List<String> formattedDates = [];
                            
                            for (String date in dates) {
                              if (date.isNotEmpty) {
                                String formattedDate = '';
                                String cleanDate = date.replaceAll(RegExp(r'[^0-9]'), '');
                                
                                if (cleanDate.length >= 1) {
                                  if (cleanDate.length <= 2) {
                                    formattedDate = cleanDate;
                                  } else if (cleanDate.length <= 4) {
                                    formattedDate = cleanDate.substring(0, 2) + '/' + cleanDate.substring(2);
                                  } else {
                                    formattedDate = cleanDate.substring(0, 2) + '/' + 
                                                  cleanDate.substring(2, 4) + '/' + 
                                                  cleanDate.substring(4, cleanDate.length > 8 ? 8 : cleanDate.length);
                                  }
                                }
                                
                                if (formattedDate.isNotEmpty) {
                                  formattedDates.add(formattedDate);
                                }
                              }
                            }
                            
                            formatted = formattedDates.join(';');
                            
                            diasBloqueadosController.text = formatted;
                            diasBloqueadosController.selection = TextSelection.fromPosition(
                              TextPosition(offset: diasBloqueadosController.text.length),
                            );
                          },
                          decoration: InputDecoration(
                            hintText: '',
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
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Seção Inadimplentes podem reservar?
                        const Text(
                          'Inadimplentes podem reservar?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Row(
                              children: [
                                Radio<bool>(
                                  value: true,
                                  groupValue: inadimplentesPodemReservar,
                                  onChanged: (value) {
                                    setModalState(() {
                                      inadimplentesPodemReservar = value!;
                                    });
                                  },
                                  activeColor: const Color(0xFF1E3A8A),
                                ),
                                const Text(
                                  'Sim',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 32),
                            Row(
                              children: [
                                Radio<bool>(
                                  value: false,
                                  groupValue: inadimplentesPodemReservar,
                                  onChanged: (value) {
                                    setModalState(() {
                                      inadimplentesPodemReservar = value!;
                                    });
                                  },
                                  activeColor: const Color(0xFF1E3A8A),
                                ),
                                const Text(
                                  'Não',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Botões Anexar
                        Row(
                          children: [
                            // Botão Anexar termo
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  // TODO: Implementar anexar termo
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFF1E3A8A)),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.attach_file,
                                        color: Color(0xFF1E3A8A),
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Anexar termo',
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
                            ),
                            const SizedBox(width: 12),
                            // Botão Anexar Imagem
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  // TODO: Implementar anexar imagem
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFF1E3A8A)),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image,
                                        color: Color(0xFF1E3A8A),
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Anexar Imagem',
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
                            ),
                          ],
                        ),
                        
                        // Textos dos arquivos anexados (exemplo)
                        const SizedBox(height: 12),
                        const Text(
                          'termo_salaofestas.pdf',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'imagemsalao.jpg',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
                
                // Botão Salvar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (tituloController.text.isNotEmpty) {
                        setState(() {
                          ambientes[index]['nome'] = tituloController.text;
                          // Aqui você pode salvar os outros dados também
                        });
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'SALVAR',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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
}