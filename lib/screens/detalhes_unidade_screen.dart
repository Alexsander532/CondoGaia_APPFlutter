import 'package:flutter/material.dart';

class DetalhesUnidadeScreen extends StatefulWidget {
  final String? condominioId;
  final String? condominioNome;
  final String? condominioCnpj;
  final String bloco;
  final String unidade;

  const DetalhesUnidadeScreen({
    super.key,
    this.condominioId,
    this.condominioNome,
    this.condominioCnpj,
    required this.bloco,
    required this.unidade,
  });

  @override
  State<DetalhesUnidadeScreen> createState() => _DetalhesUnidadeScreenState();
}

class _DetalhesUnidadeScreenState extends State<DetalhesUnidadeScreen> {
  // Estados das seções expansíveis
  bool _unidadeExpanded = false;
  bool _proprietarioExpanded = false;
  bool _inquilinoExpanded = false;
  bool _imobiliariaExpanded = false;

  // Controladores dos campos de texto
  final TextEditingController _unidadeController = TextEditingController();
  final TextEditingController _blocoController = TextEditingController();
  final TextEditingController _fracaoIdealController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _vencimentoDiferenteController = TextEditingController();
  final TextEditingController _valorDiferenteController = TextEditingController();
  final TextEditingController _observacaoController = TextEditingController();

  // Controladores para a seção Proprietário
  final TextEditingController _proprietarioNomeController = TextEditingController();
  final TextEditingController _proprietarioCpfCnpjController = TextEditingController();
  final TextEditingController _proprietarioCepController = TextEditingController();
  final TextEditingController _proprietarioEnderecoController = TextEditingController();
  final TextEditingController _proprietarioNumeroController = TextEditingController();
  final TextEditingController _proprietarioBairroController = TextEditingController();
  final TextEditingController _proprietarioCidadeController = TextEditingController();
  final TextEditingController _proprietarioEstadoController = TextEditingController();
  final TextEditingController _proprietarioTelefoneController = TextEditingController();
  final TextEditingController _proprietarioCelularController = TextEditingController();
  final TextEditingController _proprietarioEmailController = TextEditingController();
  final TextEditingController _proprietarioConjugeController = TextEditingController();
  final TextEditingController _proprietarioMultiproprietariosController = TextEditingController();
  final TextEditingController _proprietarioMoradoresController = TextEditingController();

  // Controladores para a seção Inquilino
  final TextEditingController _inquilinoNomeController = TextEditingController();
  final TextEditingController _inquilinoCpfCnpjController = TextEditingController();
  final TextEditingController _inquilinoCepController = TextEditingController();
  final TextEditingController _inquilinoEnderecoController = TextEditingController();
  final TextEditingController _inquilinoNumeroController = TextEditingController();
  final TextEditingController _inquilinoBairroController = TextEditingController();
  final TextEditingController _inquilinoCidadeController = TextEditingController();
  final TextEditingController _inquilinoEstadoController = TextEditingController();
  final TextEditingController _inquilinoTelefoneController = TextEditingController();
  final TextEditingController _inquilinoCelularController = TextEditingController();
  final TextEditingController _inquilinoEmailController = TextEditingController();
  final TextEditingController _inquilinoConjugeController = TextEditingController();
  final TextEditingController _inquilinoMultiproprietariosController = TextEditingController();
  final TextEditingController _inquilinoMoradoresController = TextEditingController();

  // Controladores para a seção Imobiliária
  final TextEditingController _imobiliariaNomeController = TextEditingController();
  final TextEditingController _imobiliariaCnpjController = TextEditingController();
  final TextEditingController _imobiliariaTelefoneController = TextEditingController();
  final TextEditingController _imobiliariaCelularController = TextEditingController();
  final TextEditingController _imobiliariaEmailController = TextEditingController();

  // Estados dos campos
  String? _tipoSelecionado;
  String _isencaoSelecionada = 'nenhum';
  String _acaoJudicialSelecionada = 'nao';
  String _correiosSelecionado = 'nao';
  String _pagadorBoletoSelecionado = 'proprietario';

  // Estados para a seção Proprietário
  String _agruparBoletosSelecionado = 'nao';
  String _matriculaImovelSelecionado = 'nao';

  // Estados para a seção Inquilino
  String _receberBoletoEmailSelecionado = 'nao';
  String _controleLocacaoSelecionado = 'nao';

  // Estados de loading para os botões de salvar
  bool _isLoadingUnidade = false;
  bool _isLoadingProprietario = false;
  bool _isLoadingInquilino = false;
  bool _isLoadingImobiliaria = false;

  // Métodos de salvamento para cada seção
  Future<void> _salvarUnidade() async {
    setState(() {
      _isLoadingUnidade = true;
    });

    try {
      // Aqui você implementará a lógica de salvamento da unidade
      // Por exemplo: await _unidadeService.salvar(dados);
      
      // Simulando delay de API
      await Future.delayed(const Duration(seconds: 1));
      
      // Mostrar feedback de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dados da unidade salvos com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Mostrar feedback de erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar dados da unidade: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoadingUnidade = false;
      });
    }
  }

  Future<void> _salvarProprietario() async {
    setState(() {
      _isLoadingProprietario = true;
    });

    try {
      // Aqui você implementará a lógica de salvamento do proprietário
      // Por exemplo: await _proprietarioService.salvar(dados);
      
      // Simulando delay de API
      await Future.delayed(const Duration(seconds: 1));
      
      // Mostrar feedback de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dados do proprietário salvos com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Mostrar feedback de erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar dados do proprietário: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoadingProprietario = false;
      });
    }
  }

  Future<void> _salvarInquilino() async {
    setState(() {
      _isLoadingInquilino = true;
    });

    try {
      // Aqui você implementará a lógica de salvamento do inquilino
      // Por exemplo: await _inquilinoService.salvar(dados);
      
      // Simulando delay de API
      await Future.delayed(const Duration(seconds: 1));
      
      // Mostrar feedback de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dados do inquilino salvos com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Mostrar feedback de erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar dados do inquilino: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoadingInquilino = false;
      });
    }
  }

  Future<void> _salvarImobiliaria() async {
    setState(() {
      _isLoadingImobiliaria = true;
    });

    try {
      // Aqui você implementará a lógica de salvamento da imobiliária
      // Por exemplo: await _imobiliariaService.salvar(dados);
      
      // Simulando delay de API
      await Future.delayed(const Duration(seconds: 1));
      
      // Mostrar feedback de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dados da imobiliária salvos com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Mostrar feedback de erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar dados da imobiliária: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoadingImobiliaria = false;
      });
    }
  }

  // Método para editar unidade
  Future<void> _editarUnidade() async {
    final TextEditingController nomeController = TextEditingController(text: widget.unidade);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Unidade'),
          content: TextField(
            controller: nomeController,
            decoration: const InputDecoration(
              labelText: 'Número da Unidade',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nomeController.text.isNotEmpty && nomeController.text != widget.unidade) {
                  Navigator.of(context).pop();
                  
                  // Mostrar feedback de sucesso
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Unidade editada com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  
                  // Voltar para a tela anterior
                  Navigator.of(context).pop(true);
                } else {
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90E2),
              ),
              child: const Text('Salvar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Método para excluir unidade
  Future<void> _excluirUnidade() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Excluir Unidade'),
          content: Text('Tem certeza que deseja excluir a unidade ${widget.bloco}/${widget.unidade}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                
                // Mostrar feedback de sucesso
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Unidade excluída com sucesso!'),
                    backgroundColor: Colors.green,
                  ),
                );
                
                // Voltar para a tela anterior
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Excluir', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Widget reutilizável para o botão de salvar
  Widget _buildSaveButton({
    required String text,
    required VoidCallback onPressed,
    required bool isLoading,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E3A59),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    Widget? content,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2E3A59),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: const Color(0xFF666666),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.edit,
                    color: Color(0xFF666666),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded && content != null)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: content,
            ),
        ],
      ),
    );
  }

  Widget _buildUnidadeContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 1,
          color: const Color(0xFFE0E0E0),
          margin: const EdgeInsets.only(bottom: 16),
        ),
        
        // Primeira linha - Unidade e Bloco
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Unidade*:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 45,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: TextField(
                       controller: _unidadeController,
                       decoration: const InputDecoration(
                         hintText: '101',
                         hintStyle: TextStyle(
                           color: Color(0xFF999999),
                           fontSize: 14,
                         ),
                         border: InputBorder.none,
                         contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                       ),
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
                  const Text(
                    'Bloco:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 45,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: TextField(
                       controller: _blocoController,
                       decoration: const InputDecoration(
                         hintText: 'B',
                         hintStyle: TextStyle(
                           color: Color(0xFF999999),
                           fontSize: 14,
                         ),
                         border: InputBorder.none,
                         contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                       ),
                     ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Segunda linha - Fração Ideal e Área
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fração Ideal:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 45,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: TextField(
                       controller: _fracaoIdealController,
                       decoration: const InputDecoration(
                         hintText: '0,014',
                         hintStyle: TextStyle(
                           color: Color(0xFF999999),
                           fontSize: 14,
                         ),
                         border: InputBorder.none,
                         contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                       ),
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
                  const Text(
                    'Área (m²):',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 45,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: TextField(
                      controller: _areaController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Terceira linha - Vencto dia diferente e Pagar valor diferente
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Vencto dia diferente:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 45,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: TextField(
                      controller: _vencimentoDiferenteController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
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
                  const Text(
                    'Pagar valor diferente:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 45,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: TextField(
                      controller: _valorDiferenteController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Dropdown Tipo
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tipo:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 45,
              width: 120,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                value: _tipoSelecionado,
                hint: const Text(
                  'A',
                  style: TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 14,
                  ),
                ),
                items: ['A', 'B', 'C', 'D'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _tipoSelecionado = newValue;
                  });
                },
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Seção Isenção
        const Text(
          'Isenção',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2E3A59),
          ),
        ),
        const SizedBox(height: 12),
        
        // Checkboxes Isenção
        Row(
          children: [
            Row(
              children: [
                Checkbox(
                  value: _isencaoSelecionada == 'nenhum',
                  onChanged: (bool? value) {
                    setState(() {
                      _isencaoSelecionada = 'nenhum';
                    });
                  },
                  activeColor: const Color(0xFF4A90E2),
                ),
                const Text(
                  'Nenhum',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            Row(
              children: [
                Checkbox(
                  value: _isencaoSelecionada == 'total',
                  onChanged: (bool? value) {
                    setState(() {
                      _isencaoSelecionada = 'total';
                    });
                  },
                  activeColor: const Color(0xFF4A90E2),
                ),
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            Row(
              children: [
                Checkbox(
                  value: _isencaoSelecionada == 'cota',
                  onChanged: (bool? value) {
                    setState(() {
                      _isencaoSelecionada = 'cota';
                    });
                  },
                  activeColor: const Color(0xFF4A90E2),
                ),
                const Text(
                  'Cota',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
          ],
        ),
        
        Row(
          children: [
            Row(
              children: [
                Checkbox(
                  value: _isencaoSelecionada == 'fundo_reserva',
                  onChanged: (bool? value) {
                    setState(() {
                      _isencaoSelecionada = 'fundo_reserva';
                    });
                  },
                  activeColor: const Color(0xFF4A90E2),
                ),
                const Text(
                  'Fundo Reserva',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Seção Ação Judicial
        const Text(
          'Ação Judicial',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2E3A59),
          ),
        ),
        const SizedBox(height: 12),
        
        // Radio buttons Ação Judicial
        Row(
          children: [
            Row(
              children: [
                Radio<String>(
                  value: 'sim',
                  groupValue: _acaoJudicialSelecionada,
                  onChanged: (String? value) {
                    setState(() {
                      _acaoJudicialSelecionada = value!;
                    });
                  },
                  activeColor: const Color(0xFF4A90E2),
                ),
                const Text(
                  'Sim',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            Row(
              children: [
                Radio<String>(
                  value: 'nao',
                  groupValue: _acaoJudicialSelecionada,
                  onChanged: (String? value) {
                    setState(() {
                      _acaoJudicialSelecionada = value!;
                    });
                  },
                  activeColor: const Color(0xFF4A90E2),
                ),
                const Text(
                  'Não',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Seção Correios
        const Text(
          'Correios',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2E3A59),
          ),
        ),
        const SizedBox(height: 12),
        
        // Radio buttons Correios
        Row(
          children: [
            Row(
              children: [
                Radio<String>(
                  value: 'sim',
                  groupValue: _correiosSelecionado,
                  onChanged: (String? value) {
                    setState(() {
                      _correiosSelecionado = value!;
                    });
                  },
                  activeColor: const Color(0xFF4A90E2),
                ),
                const Text(
                  'Sim',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            Row(
              children: [
                Radio<String>(
                  value: 'nao',
                  groupValue: _correiosSelecionado,
                  onChanged: (String? value) {
                    setState(() {
                      _correiosSelecionado = value!;
                    });
                  },
                  activeColor: const Color(0xFF4A90E2),
                ),
                const Text(
                  'Não',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Seção Nome Pagador do Boleto
        const Text(
          'Nome Pagador do Boleto',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2E3A59),
          ),
        ),
        const SizedBox(height: 12),
        
        // Radio buttons Nome Pagador do Boleto
        Row(
          children: [
            Row(
              children: [
                Radio<String>(
                  value: 'proprietario',
                  groupValue: _pagadorBoletoSelecionado,
                  onChanged: (String? value) {
                    setState(() {
                      _pagadorBoletoSelecionado = value!;
                    });
                  },
                  activeColor: const Color(0xFF4A90E2),
                ),
                const Text(
                  'Proprietário',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            Row(
              children: [
                Radio<String>(
                  value: 'inquilino',
                  groupValue: _pagadorBoletoSelecionado,
                  onChanged: (String? value) {
                    setState(() {
                      _pagadorBoletoSelecionado = value!;
                    });
                  },
                  activeColor: const Color(0xFF4A90E2),
                ),
                const Text(
                  'Inquilino',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Campo Observação
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Observação:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: TextField(
                controller: _observacaoController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ),
          ],
        ),
        
        // Botão de salvar para a seção Unidade
        _buildSaveButton(
          text: 'SALVAR UNIDADE',
          onPressed: _salvarUnidade,
          isLoading: _isLoadingUnidade,
        ),
      ],
    );
  }

  Widget _buildProprietarioContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        
        // Seção Anexar foto
        Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.camera_alt_outlined,
                color: Color(0xFF999999),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Anexar foto',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Campo Nome
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nome*:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: TextField(
                controller: _proprietarioNomeController,
                decoration: const InputDecoration(
                  hintText: 'José Marcos da Silva',
                  hintStyle: TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Campo CPF/CNPJ
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CPF/CNPJ*:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: TextField(
                controller: _proprietarioCpfCnpjController,
                decoration: const InputDecoration(
                  hintText: '066.556.902-06',
                  hintStyle: TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Campo CEP
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CEP:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: TextField(
                controller: _proprietarioCepController,
                decoration: const InputDecoration(
                  hintText: '11123-456',
                  hintStyle: TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Campos Endereço e Número
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Endereço:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: TextField(
                      controller: _proprietarioEnderecoController,
                      decoration: const InputDecoration(
                        hintText: 'Rua Almirante Carlos Guedert',
                        hintStyle: TextStyle(
                          color: Color(0xFF999999),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Número:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: TextField(
                      controller: _proprietarioNumeroController,
                      decoration: const InputDecoration(
                        hintText: '',
                        hintStyle: TextStyle(
                          color: Color(0xFF999999),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Campos Bairro
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bairro:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: TextField(
                controller: _proprietarioBairroController,
                decoration: const InputDecoration(
                  hintText: '',
                  hintStyle: TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Campos Cidade e Estado
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cidade:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: TextField(
                      controller: _proprietarioCidadeController,
                      decoration: const InputDecoration(
                        hintText: '',
                        hintStyle: TextStyle(
                          color: Color(0xFF999999),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Estado:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: TextField(
                      controller: _proprietarioEstadoController,
                      decoration: const InputDecoration(
                        hintText: '',
                        hintStyle: TextStyle(
                          color: Color(0xFF999999),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Campo Telefone
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Telefone:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: TextField(
                controller: _proprietarioTelefoneController,
                decoration: const InputDecoration(
                  hintText: '51 3246-5866',
                  hintStyle: TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Campo Celular
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Celular:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: TextField(
                controller: _proprietarioCelularController,
                decoration: const InputDecoration(
                  hintText: '51 9996-33541',
                  hintStyle: TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Campo Email
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Email:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: TextField(
                controller: _proprietarioEmailController,
                decoration: const InputDecoration(
                  hintText: 'josesilva@gmail.com',
                  hintStyle: TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            ),
          ],
        ),
         
         const SizedBox(height: 24),
         
         // Seção Cônjuge
         Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             const Text(
               'Cônjuge:',
               style: TextStyle(
                 fontSize: 14,
                 fontWeight: FontWeight.w500,
                 color: Color(0xFF333333),
               ),
             ),
             const SizedBox(height: 8),
             Container(
               decoration: BoxDecoration(
                 border: Border.all(color: const Color(0xFFE0E0E0)),
                 borderRadius: BorderRadius.circular(8),
                 color: Colors.white,
               ),
               child: TextField(
                 controller: _proprietarioConjugeController,
                 decoration: const InputDecoration(
                   hintText: '',
                   hintStyle: TextStyle(
                     color: Color(0xFF999999),
                     fontSize: 14,
                   ),
                   border: InputBorder.none,
                   contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                 ),
               ),
             ),
           ],
         ),
         
         const SizedBox(height: 16),
         
         // Seção Multiproprietários
         Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             const Text(
               'Multiproprietários:',
               style: TextStyle(
                 fontSize: 14,
                 fontWeight: FontWeight.w500,
                 color: Color(0xFF333333),
               ),
             ),
             const SizedBox(height: 8),
             Container(
               decoration: BoxDecoration(
                 border: Border.all(color: const Color(0xFFE0E0E0)),
                 borderRadius: BorderRadius.circular(8),
                 color: Colors.white,
               ),
               child: TextField(
                 controller: _proprietarioMultiproprietariosController,
                 decoration: const InputDecoration(
                   hintText: '',
                   hintStyle: TextStyle(
                     color: Color(0xFF999999),
                     fontSize: 14,
                   ),
                   border: InputBorder.none,
                   contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                 ),
               ),
             ),
           ],
         ),
         
         const SizedBox(height: 16),
         
         // Seção Moradores
         Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             const Text(
               'Moradores:',
               style: TextStyle(
                 fontSize: 14,
                 fontWeight: FontWeight.w500,
                 color: Color(0xFF333333),
               ),
             ),
             const SizedBox(height: 8),
             Container(
               decoration: BoxDecoration(
                 border: Border.all(color: const Color(0xFFE0E0E0)),
                 borderRadius: BorderRadius.circular(8),
                 color: Colors.white,
               ),
               child: TextField(
                 controller: _proprietarioMoradoresController,
                 decoration: const InputDecoration(
                   hintText: '',
                   hintStyle: TextStyle(
                     color: Color(0xFF999999),
                     fontSize: 14,
                   ),
                   border: InputBorder.none,
                   contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                 ),
               ),
             ),
           ],
         ),
         
         const SizedBox(height: 24),
         
         // Seção Agrupar boletos
         Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             const Text(
               'Agrupar boletos:',
               style: TextStyle(
                 fontSize: 14,
                 fontWeight: FontWeight.w500,
                 color: Color(0xFF333333),
               ),
             ),
             const SizedBox(height: 8),
             Row(
               children: [
                 Row(
                   children: [
                     Radio<String>(
                       value: 'Sim',
                       groupValue: _agruparBoletosSelecionado,
                       onChanged: (String? value) {
                         setState(() {
                           _agruparBoletosSelecionado = value!;
                         });
                       },
                       activeColor: const Color(0xFF2196F3),
                     ),
                     const Text(
                       'Sim',
                       style: TextStyle(
                         fontSize: 14,
                         color: Color(0xFF333333),
                       ),
                     ),
                   ],
                 ),
                 const SizedBox(width: 24),
                 Row(
                   children: [
                     Radio<String>(
                       value: 'Não',
                       groupValue: _agruparBoletosSelecionado,
                       onChanged: (String? value) {
                         setState(() {
                           _agruparBoletosSelecionado = value!;
                         });
                       },
                       activeColor: const Color(0xFF2196F3),
                     ),
                     const Text(
                       'Não',
                       style: TextStyle(
                         fontSize: 14,
                         color: Color(0xFF333333),
                       ),
                     ),
                   ],
                 ),
               ],
             ),
           ],
         ),
         
         const SizedBox(height: 16),
         
         // Seção Matrícula do Imóvel
         Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             const Text(
               'Matrícula do Imóvel:',
               style: TextStyle(
                 fontSize: 14,
                 fontWeight: FontWeight.w500,
                 color: Color(0xFF333333),
               ),
             ),
             const SizedBox(height: 8),
             Row(
               children: [
                 Row(
                   children: [
                     Radio<String>(
                       value: 'Fazer Upload',
                       groupValue: _matriculaImovelSelecionado,
                       onChanged: (String? value) {
                         setState(() {
                           _matriculaImovelSelecionado = value!;
                         });
                       },
                       activeColor: const Color(0xFF2196F3),
                     ),
                     const Text(
                       'Fazer Upload',
                       style: TextStyle(
                         fontSize: 14,
                         color: Color(0xFF333333),
                       ),
                     ),
                   ],
                 ),
                 const SizedBox(width: 24),
                 Row(
                   children: [
                     Radio<String>(
                       value: 'Não',
                       groupValue: _matriculaImovelSelecionado,
                       onChanged: (String? value) {
                         setState(() {
                           _matriculaImovelSelecionado = value!;
                         });
                       },
                       activeColor: const Color(0xFF2196F3),
                     ),
                     const Text(
                       'Não',
                       style: TextStyle(
                         fontSize: 14,
                         color: Color(0xFF333333),
                       ),
                     ),
                   ],
                 ),
               ],
             ),
           ],
         ),
         
         const SizedBox(height: 24),
         
         // Seção Veículos
         Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             const Text(
               'Veículos:',
               style: TextStyle(
                 fontSize: 16,
                 fontWeight: FontWeight.w500,
                 color: Color(0xFF333333),
               ),
             ),
             const SizedBox(height: 12),
             
             // Cabeçalho da tabela
             Container(
               decoration: BoxDecoration(
                 color: const Color(0xFFF5F5F5),
                 borderRadius: BorderRadius.circular(8),
                 border: Border.all(color: const Color(0xFFE0E0E0)),
               ),
               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
               child: const Row(
                 children: [
                   Expanded(
                     flex: 2,
                     child: Text(
                       'Placa:',
                       style: TextStyle(
                         fontSize: 14,
                         fontWeight: FontWeight.w500,
                         color: Color(0xFF333333),
                       ),
                     ),
                   ),
                   Expanded(
                     flex: 2,
                     child: Text(
                       'Marca:',
                       style: TextStyle(
                         fontSize: 14,
                         fontWeight: FontWeight.w500,
                         color: Color(0xFF333333),
                       ),
                     ),
                   ),
                   Expanded(
                     flex: 2,
                     child: Text(
                       'Modelo:',
                       style: TextStyle(
                         fontSize: 14,
                         fontWeight: FontWeight.w500,
                         color: Color(0xFF333333),
                       ),
                     ),
                   ),
                   Expanded(
                     flex: 2,
                     child: Text(
                       'Cor:',
                       style: TextStyle(
                         fontSize: 14,
                         fontWeight: FontWeight.w500,
                         color: Color(0xFF333333),
                       ),
                     ),
                   ),
                 ],
               ),
             ),
             
             // Primeira linha da tabela
             Container(
               decoration: BoxDecoration(
                 border: Border.all(color: const Color(0xFFE0E0E0)),
                 borderRadius: BorderRadius.circular(8),
               ),
               margin: const EdgeInsets.only(top: 8),
               padding: const EdgeInsets.all(8),
               child: Row(
                 children: [
                   Expanded(
                     flex: 2,
                     child: Container(
                       decoration: BoxDecoration(
                         border: Border.all(color: const Color(0xFFE0E0E0)),
                         borderRadius: BorderRadius.circular(4),
                         color: Colors.white,
                       ),
                       child: const TextField(
                         decoration: InputDecoration(
                           hintText: 'Placa',
                           hintStyle: TextStyle(
                             color: Color(0xFF999999),
                             fontSize: 12,
                           ),
                           border: InputBorder.none,
                           contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                         ),
                       ),
                     ),
                   ),
                   const SizedBox(width: 8),
                   Expanded(
                     flex: 2,
                     child: Container(
                       decoration: BoxDecoration(
                         border: Border.all(color: const Color(0xFFE0E0E0)),
                         borderRadius: BorderRadius.circular(4),
                         color: Colors.white,
                       ),
                       child: const TextField(
                         decoration: InputDecoration(
                           hintText: 'Marca',
                           hintStyle: TextStyle(
                             color: Color(0xFF999999),
                             fontSize: 12,
                           ),
                           border: InputBorder.none,
                           contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                         ),
                       ),
                     ),
                   ),
                   const SizedBox(width: 8),
                   Expanded(
                     flex: 2,
                     child: Container(
                       decoration: BoxDecoration(
                         border: Border.all(color: const Color(0xFFE0E0E0)),
                         borderRadius: BorderRadius.circular(4),
                         color: Colors.white,
                       ),
                       child: const TextField(
                         decoration: InputDecoration(
                           hintText: 'Modelo',
                           hintStyle: TextStyle(
                             color: Color(0xFF999999),
                             fontSize: 12,
                           ),
                           border: InputBorder.none,
                           contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                         ),
                       ),
                     ),
                   ),
                   const SizedBox(width: 8),
                   Expanded(
                     flex: 2,
                     child: Container(
                       decoration: BoxDecoration(
                         border: Border.all(color: const Color(0xFFE0E0E0)),
                         borderRadius: BorderRadius.circular(4),
                         color: Colors.white,
                       ),
                       child: const TextField(
                         decoration: InputDecoration(
                           hintText: 'Cor',
                           hintStyle: TextStyle(
                             color: Color(0xFF999999),
                             fontSize: 12,
                           ),
                           border: InputBorder.none,
                           contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                         ),
                       ),
                     ),
                   ),
                 ],
               ),
             ),
             
             // Segunda linha da tabela
             Container(
               decoration: BoxDecoration(
                 border: Border.all(color: const Color(0xFFE0E0E0)),
                 borderRadius: BorderRadius.circular(8),
               ),
               margin: const EdgeInsets.only(top: 8),
               padding: const EdgeInsets.all(8),
               child: Row(
                 children: [
                   Expanded(
                     flex: 2,
                     child: Container(
                       decoration: BoxDecoration(
                         border: Border.all(color: const Color(0xFFE0E0E0)),
                         borderRadius: BorderRadius.circular(4),
                         color: Colors.white,
                       ),
                       child: const TextField(
                         decoration: InputDecoration(
                           hintText: 'Placa',
                           hintStyle: TextStyle(
                             color: Color(0xFF999999),
                             fontSize: 12,
                           ),
                           border: InputBorder.none,
                           contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                         ),
                       ),
                     ),
                   ),
                   const SizedBox(width: 8),
                   Expanded(
                     flex: 2,
                     child: Container(
                       decoration: BoxDecoration(
                         border: Border.all(color: const Color(0xFFE0E0E0)),
                         borderRadius: BorderRadius.circular(4),
                         color: Colors.white,
                       ),
                       child: const TextField(
                         decoration: InputDecoration(
                           hintText: 'Marca',
                           hintStyle: TextStyle(
                             color: Color(0xFF999999),
                             fontSize: 12,
                           ),
                           border: InputBorder.none,
                           contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                         ),
                       ),
                     ),
                   ),
                   const SizedBox(width: 8),
                   Expanded(
                     flex: 2,
                     child: Container(
                       decoration: BoxDecoration(
                         border: Border.all(color: const Color(0xFFE0E0E0)),
                         borderRadius: BorderRadius.circular(4),
                         color: Colors.white,
                       ),
                       child: const TextField(
                         decoration: InputDecoration(
                           hintText: 'Modelo',
                           hintStyle: TextStyle(
                             color: Color(0xFF999999),
                             fontSize: 12,
                           ),
                           border: InputBorder.none,
                           contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                         ),
                       ),
                     ),
                   ),
                   const SizedBox(width: 8),
                   Expanded(
                     flex: 2,
                     child: Container(
                       decoration: BoxDecoration(
                         border: Border.all(color: const Color(0xFFE0E0E0)),
                         borderRadius: BorderRadius.circular(4),
                         color: Colors.white,
                       ),
                       child: const TextField(
                         decoration: InputDecoration(
                           hintText: 'Cor',
                           hintStyle: TextStyle(
                             color: Color(0xFF999999),
                             fontSize: 12,
                           ),
                           border: InputBorder.none,
                           contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                         ),
                       ),
                     ),
                   ),
                 ],
               ),
             ),
             
             // Terceira linha da tabela
             Container(
               decoration: BoxDecoration(
                 border: Border.all(color: const Color(0xFFE0E0E0)),
                 borderRadius: BorderRadius.circular(8),
               ),
               margin: const EdgeInsets.only(top: 8),
               padding: const EdgeInsets.all(8),
               child: Row(
                 children: [
                   Expanded(
                     flex: 2,
                     child: Container(
                       decoration: BoxDecoration(
                         border: Border.all(color: const Color(0xFFE0E0E0)),
                         borderRadius: BorderRadius.circular(4),
                         color: Colors.white,
                       ),
                       child: const TextField(
                         decoration: InputDecoration(
                           hintText: 'Placa',
                           hintStyle: TextStyle(
                             color: Color(0xFF999999),
                             fontSize: 12,
                           ),
                           border: InputBorder.none,
                           contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                         ),
                       ),
                     ),
                   ),
                   const SizedBox(width: 8),
                   Expanded(
                     flex: 2,
                     child: Container(
                       decoration: BoxDecoration(
                         border: Border.all(color: const Color(0xFFE0E0E0)),
                         borderRadius: BorderRadius.circular(4),
                         color: Colors.white,
                       ),
                       child: const TextField(
                         decoration: InputDecoration(
                           hintText: 'Marca',
                           hintStyle: TextStyle(
                             color: Color(0xFF999999),
                             fontSize: 12,
                           ),
                           border: InputBorder.none,
                           contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                         ),
                       ),
                     ),
                   ),
                   const SizedBox(width: 8),
                   Expanded(
                     flex: 2,
                     child: Container(
                       decoration: BoxDecoration(
                         border: Border.all(color: const Color(0xFFE0E0E0)),
                         borderRadius: BorderRadius.circular(4),
                         color: Colors.white,
                       ),
                       child: const TextField(
                         decoration: InputDecoration(
                           hintText: 'Modelo',
                           hintStyle: TextStyle(
                             color: Color(0xFF999999),
                             fontSize: 12,
                           ),
                           border: InputBorder.none,
                           contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                         ),
                       ),
                     ),
                   ),
                   const SizedBox(width: 8),
                   Expanded(
                     flex: 2,
                     child: Container(
                       decoration: BoxDecoration(
                         border: Border.all(color: const Color(0xFFE0E0E0)),
                         borderRadius: BorderRadius.circular(4),
                         color: Colors.white,
                       ),
                       child: const TextField(
                         decoration: InputDecoration(
                           hintText: 'Cor',
                           hintStyle: TextStyle(
                             color: Color(0xFF999999),
                             fontSize: 12,
                           ),
                           border: InputBorder.none,
                           contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                         ),
                       ),
                     ),
                   ),
                 ],
               ),
             ),
           ],
       ),
       
       const SizedBox(height: 24),
       
       // Botão de salvar para a seção Proprietário
       _buildSaveButton(
         text: 'SALVAR PROPRIETÁRIO',
         onPressed: _salvarProprietario,
         isLoading: _isLoadingProprietario,
       ),
     ],
   );
 }

  Widget _buildInquilinoContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Seção para anexar foto
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt_outlined,
                  size: 32,
                  color: Color(0xFF666666),
                ),
                SizedBox(height: 8),
                Text(
                  'Anexar foto',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Campo Cônjuge
          const Text(
            'Cônjuge:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _inquilinoConjugeController,
            decoration: InputDecoration(
              hintText: 'Digite o nome do cônjuge',
              hintStyle: const TextStyle(color: Color(0xFF999999)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF2E3A59)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            ),
          ),
          const SizedBox(height: 16),

          // Campo Multiproprietários
          const Text(
            'Multiproprietários:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _inquilinoMultiproprietariosController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Digite os nomes dos multiproprietários',
              hintStyle: const TextStyle(color: Color(0xFF999999)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF2E3A59)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            ),
          ),
          const SizedBox(height: 16),

          // Campo Moradores
          const Text(
            'Moradores:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _inquilinoMoradoresController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Digite os nomes dos moradores',
              hintStyle: const TextStyle(color: Color(0xFF999999)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF2E3A59)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            ),
          ),
          const SizedBox(height: 24),

          // Seção Receber boletos por email
          const Text(
            'Receber boletos por email:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Radio<String>(
                value: 'sim',
                groupValue: _receberBoletoEmailSelecionado,
                onChanged: (String? value) {
                  setState(() {
                    _receberBoletoEmailSelecionado = value!;
                  });
                },
                activeColor: const Color(0xFF2E3A59),
              ),
              const Text(
                'Sim',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(width: 24),
              Radio<String>(
                value: 'nao',
                groupValue: _receberBoletoEmailSelecionado,
                onChanged: (String? value) {
                  setState(() {
                    _receberBoletoEmailSelecionado = value!;
                  });
                },
                activeColor: const Color(0xFF2E3A59),
              ),
              const Text(
                'Não',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Seção Controle de Locação
          const Text(
            'Controle de Locação:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Radio<String>(
                value: 'fazer_upload',
                groupValue: _controleLocacaoSelecionado,
                onChanged: (String? value) {
                  setState(() {
                    _controleLocacaoSelecionado = value!;
                  });
                },
                activeColor: const Color(0xFF2E3A59),
              ),
              const Text(
                'Fazer Upload',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(width: 24),
              Radio<String>(
                value: 'nao',
                groupValue: _controleLocacaoSelecionado,
                onChanged: (String? value) {
                  setState(() {
                    _controleLocacaoSelecionado = value!;
                  });
                },
                activeColor: const Color(0xFF2E3A59),
              ),
              const Text(
                'Não',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Seção Veículos
          const Text(
            'Veículos:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 16),
          
          // Tabela de Veículos
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE0E0E0)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // Cabeçalho da tabela
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Placa',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Marca',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Modelo',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Cor',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Linhas da tabela
                ...List.generate(3, (index) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: const Color(0xFFE0E0E0),
                        width: index == 0 ? 1 : 0,
                      ),
                      bottom: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Placa',
                            hintStyle: const TextStyle(color: Color(0xFF999999), fontSize: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: const BorderSide(color: Color(0xFF2E3A59)),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            isDense: true,
                          ),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Marca',
                            hintStyle: const TextStyle(color: Color(0xFF999999), fontSize: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: const BorderSide(color: Color(0xFF2E3A59)),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            isDense: true,
                          ),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Modelo',
                            hintStyle: const TextStyle(color: Color(0xFF999999), fontSize: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: const BorderSide(color: Color(0xFF2E3A59)),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            isDense: true,
                          ),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Cor',
                            hintStyle: const TextStyle(color: Color(0xFF999999), fontSize: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: const BorderSide(color: Color(0xFF2E3A59)),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            isDense: true,
                          ),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Campo Nome
          const Text(
            'Nome*',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _inquilinoNomeController,
            decoration: InputDecoration(
              hintText: 'Digite o nome completo',
              hintStyle: const TextStyle(color: Color(0xFF999999)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF2E3A59)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            ),
          ),
          const SizedBox(height: 16),

          // Campo CPF/CNPJ
          const Text(
            'CPF/CNPJ*',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _inquilinoCpfCnpjController,
            decoration: InputDecoration(
              hintText: 'Digite o CPF ou CNPJ',
              hintStyle: const TextStyle(color: Color(0xFF999999)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF2E3A59)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            ),
          ),
          const SizedBox(height: 16),

          // Campo CEP
          const Text(
            'CEP*',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inquilinoCepController,
                  decoration: InputDecoration(
                    hintText: 'Digite o CEP',
                    hintStyle: const TextStyle(color: Color(0xFF999999)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF2E3A59)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E3A59),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Buscar no\nCadastro',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Campo Endereço
          const Text(
            'Endereço*',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _inquilinoEnderecoController,
            decoration: InputDecoration(
              hintText: 'Digite o endereço',
              hintStyle: const TextStyle(color: Color(0xFF999999)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF2E3A59)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            ),
          ),
          const SizedBox(height: 16),

          // Linha com Número e Bairro
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Número:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _inquilinoNumeroController,
                      decoration: InputDecoration(
                        hintText: 'Nº',
                        hintStyle: const TextStyle(color: Color(0xFF999999)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF2E3A59)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bairro:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _inquilinoBairroController,
                      decoration: InputDecoration(
                        hintText: 'Digite o bairro',
                        hintStyle: const TextStyle(color: Color(0xFF999999)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF2E3A59)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Linha com Cidade e Estado
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cidade:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _inquilinoCidadeController,
                      decoration: InputDecoration(
                        hintText: 'Digite a cidade',
                        hintStyle: const TextStyle(color: Color(0xFF999999)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF2E3A59)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Estado:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _inquilinoEstadoController,
                      decoration: InputDecoration(
                        hintText: 'UF',
                        hintStyle: const TextStyle(color: Color(0xFF999999)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF2E3A59)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Campo Telefone
          const Text(
            'Telefone:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _inquilinoTelefoneController,
            decoration: InputDecoration(
              hintText: 'Digite o telefone',
              hintStyle: const TextStyle(color: Color(0xFF999999)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF2E3A59)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            ),
          ),
          const SizedBox(height: 16),

          // Campo Celular
          const Text(
            'Celular:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _inquilinoCelularController,
            decoration: InputDecoration(
              hintText: 'Digite o celular',
              hintStyle: const TextStyle(color: Color(0xFF999999)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF2E3A59)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            ),
          ),
          const SizedBox(height: 16),

          // Campo Email
          const Text(
            'Email:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _inquilinoEmailController,
            decoration: InputDecoration(
              hintText: 'Digite o email',
              hintStyle: const TextStyle(color: Color(0xFF999999)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF2E3A59)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            ),
          ),
          const SizedBox(height: 24),
          
          // Botão de salvar para a seção Inquilino
          _buildSaveButton(
            text: 'SALVAR INQUILINO',
            onPressed: _salvarInquilino,
            isLoading: _isLoadingInquilino,
          ),
        ],
      ),
    );
  }

  Widget _buildImobiliariaContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 1,
          color: const Color(0xFFE0E0E0),
          margin: const EdgeInsets.only(bottom: 16),
        ),
        
        // Seção para anexar foto
        Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.camera_alt_outlined,
                color: Color(0xFF999999),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Anexar foto',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Campo Nome
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nome*:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: TextField(
                controller: _imobiliariaNomeController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  hintText: 'Digite o nome da imobiliária',
                  hintStyle: TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Campo CNPJ
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CNPJ*:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: TextField(
                controller: _imobiliariaCnpjController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  hintText: 'Digite o CNPJ',
                  hintStyle: TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Campo Telefone
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Telefone*:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: TextField(
                controller: _imobiliariaTelefoneController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  hintText: 'Digite o telefone',
                  hintStyle: TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Campo Celular
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Celular*:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: TextField(
                controller: _imobiliariaCelularController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  hintText: 'Digite o celular',
                  hintStyle: TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Campo Email
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Email*:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: TextField(
                controller: _imobiliariaEmailController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  hintText: 'Digite o email',
                  hintStyle: TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
        
        // Botão de salvar para a seção Imobiliária
        _buildSaveButton(
          text: 'SALVAR IMOBILIÁRIA',
          onPressed: _salvarImobiliaria,
          isLoading: _isLoadingImobiliaria,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Cabeçalho superior padronizado
            Container(
              color: Colors.white,
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
                      // Menu de ações da unidade
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert,
                          color: Color(0xFF333333),
                          size: 24,
                        ),
                        onSelected: (value) {
                          switch (value) {
                            case 'editar':
                              _editarUnidade();
                              break;
                            case 'excluir':
                              _excluirUnidade();
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'editar',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 18, color: Color(0xFF4A90E2)),
                                SizedBox(width: 8),
                                Text('Editar Unidade'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'excluir',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Excluir Unidade', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
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
              color: const Color(0xFFE0E0E0),
            ),
            
            // Breadcrumb
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Center(
                child: Text(
                  'Home/Gestão/Unid/${widget.bloco}/${widget.unidade}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),

            // Conteúdo principal
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    
                    // Seção principal com número da unidade
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A90E2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '${widget.bloco}/${widget.unidade}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Seções expansíveis
                    _buildExpandableSection(
                      title: 'Unidade',
                      isExpanded: _unidadeExpanded,
                      onTap: () {
                        setState(() {
                          _unidadeExpanded = !_unidadeExpanded;
                        });
                      },
                      content: _buildUnidadeContent(),
                    ),

                    _buildExpandableSection(
                      title: 'Proprietário',
                      isExpanded: _proprietarioExpanded,
                      onTap: () {
                        setState(() {
                          _proprietarioExpanded = !_proprietarioExpanded;
                        });
                      },
                      content: _buildProprietarioContent(),
                    ),

                    _buildExpandableSection(
                      title: 'Inquilino',
                      isExpanded: _inquilinoExpanded,
                      onTap: () {
                        setState(() {
                          _inquilinoExpanded = !_inquilinoExpanded;
                        });
                      },
                      content: _buildInquilinoContent(),
                    ),

                    _buildExpandableSection(
                      title: 'Imobiliária',
                      isExpanded: _imobiliariaExpanded,
                      onTap: () {
                        setState(() {
                          _imobiliariaExpanded = !_imobiliariaExpanded;
                        });
                      },
                      content: _buildImobiliariaContent(),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Controladores da seção Unidade
    _unidadeController.dispose();
    _blocoController.dispose();
    _fracaoIdealController.dispose();
    _areaController.dispose();
    _vencimentoDiferenteController.dispose();
    _valorDiferenteController.dispose();
    _observacaoController.dispose();
    
    // Controladores da seção Proprietário
    _proprietarioNomeController.dispose();
    _proprietarioCpfCnpjController.dispose();
    _proprietarioCepController.dispose();
    _proprietarioEnderecoController.dispose();
    _proprietarioNumeroController.dispose();
    _proprietarioBairroController.dispose();
    _proprietarioCidadeController.dispose();
    _proprietarioEstadoController.dispose();
    _proprietarioTelefoneController.dispose();
    _proprietarioCelularController.dispose();
    _proprietarioEmailController.dispose();
    _proprietarioConjugeController.dispose();
    _proprietarioMultiproprietariosController.dispose();
    _proprietarioMoradoresController.dispose();
    
    // Controladores da seção Inquilino
    _inquilinoNomeController.dispose();
    _inquilinoCpfCnpjController.dispose();
    _inquilinoCepController.dispose();
    _inquilinoEnderecoController.dispose();
    _inquilinoNumeroController.dispose();
    _inquilinoBairroController.dispose();
    _inquilinoCidadeController.dispose();
    _inquilinoEstadoController.dispose();
    _inquilinoTelefoneController.dispose();
    _inquilinoCelularController.dispose();
    _inquilinoEmailController.dispose();
    _inquilinoConjugeController.dispose();
    _inquilinoMultiproprietariosController.dispose();
    _inquilinoMoradoresController.dispose();

    // Controladores da Imobiliária
    _imobiliariaNomeController.dispose();
    _imobiliariaCnpjController.dispose();
    _imobiliariaTelefoneController.dispose();
    _imobiliariaCelularController.dispose();
    _imobiliariaEmailController.dispose();
    
    super.dispose();
  }
}