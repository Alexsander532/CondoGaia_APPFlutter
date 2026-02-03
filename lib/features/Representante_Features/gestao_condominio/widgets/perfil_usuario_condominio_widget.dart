import 'package:flutter/material.dart';
import '../../../../models/condominio.dart';

class PerfilUsuarioCondominioWidget extends StatefulWidget {
  final Condominio? condominio;

  const PerfilUsuarioCondominioWidget({super.key, this.condominio});

  @override
  State<PerfilUsuarioCondominioWidget> createState() =>
      _PerfilUsuarioCondominioWidgetState();
}

class _PerfilUsuarioCondominioWidgetState
    extends State<PerfilUsuarioCondominioWidget> {
  // Mock Data
  final List<String> _perfis = [
    'Síndico(a)',
    'Administradora',
    'Cobrança',
    'Zelador',
    'Portaria',
  ];

  void _openEditDialog({String? perfil}) {
    showDialog(
      context: context,
      builder: (context) => PerfilUsuarioDialog(initialPerfil: perfil),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Add Button
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: () => _openEditDialog(),
              icon: const Icon(
                Icons.add_circle_outline,
                color: Color(0xFF0D3B66),
                size: 32,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),

        // List
        ..._perfis.map((perfil) => _buildPerfilRow(perfil)).toList(),
      ],
    );
  }

  Widget _buildPerfilRow(String perfil) {
    final bool isSindico = perfil == 'Síndico(a)';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF0D3B66), width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            perfil,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          if (!isSindico)
            Row(
              children: [
                InkWell(
                  onTap: () => _openEditDialog(perfil: perfil),
                  child: const Icon(
                    Icons.edit,
                    color: Color(0xFF0D3B66),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                InkWell(
                  onTap: () {
                    // TODO: Implement delete
                  },
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class PerfilUsuarioDialog extends StatefulWidget {
  final String? initialPerfil;

  const PerfilUsuarioDialog({super.key, this.initialPerfil});

  @override
  State<PerfilUsuarioDialog> createState() => _PerfilUsuarioDialogState();
}

class _PerfilUsuarioDialogState extends State<PerfilUsuarioDialog> {
  final _usuarioController = TextEditingController();
  final _emailController = TextEditingController();

  // Permission States
  bool _modulos = false;
  bool _chat = false;
  bool _reservas = false;
  bool _reservasConfig = false;
  bool _leitura = false;
  bool _leituraConfig = false;
  bool _diarioAgenda = false;
  bool _documentos = false;

  bool _gestao = false;
  bool _condominio = false;
  bool _condominioConf = false;
  bool _relatorios = false;
  bool _portaria = false;
  bool _boleto = false;
  bool _boletoGerar = false;
  bool _boletoEnviar = false;
  bool _boletoReceber = false;
  bool _boletoExcluir = false;
  bool _acordo = false;
  bool _acordoGerar = false;
  bool _acordoEnviar = false;
  bool _moradorUnid = false;
  bool _moradorUnidConf = false;
  bool _email = false;
  bool _despReceita = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialPerfil != null) {
      _usuarioController.text = widget.initialPerfil!;
    }
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Container(
      height: 35,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade500),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 4.0),
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(bottom: 14),
              ),
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckbox(
    String label,
    bool value,
    ValueChanged<bool?> onChanged, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF0D3B66),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with Close
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Popup',
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 28),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Inputs
              _buildTextField('Usuário:', _usuarioController),
              const SizedBox(height: 8),
              _buildTextField('E-Mail:', _emailController),
              const SizedBox(height: 12),

              // Modulos Section
              _buildCheckbox(
                'Módulos:',
                _modulos,
                (v) => setState(() => _modulos = v!),
                isBold: true,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCheckbox(
                      'Chat',
                      _chat,
                      (v) => setState(() => _chat = v!),
                    ),
                    Row(
                      children: [
                        _buildCheckbox(
                          'Reservas',
                          _reservas,
                          (v) => setState(() => _reservas = v!),
                        ),
                        const SizedBox(width: 8),
                        _buildCheckbox(
                          'Configurações',
                          _reservasConfig,
                          (v) => setState(() => _reservasConfig = v!),
                        ),
                        const Text(')'),
                      ],
                    ),
                    Row(
                      children: [
                        _buildCheckbox(
                          'Leitura',
                          _leitura,
                          (v) => setState(() => _leitura = v!),
                        ),
                        const SizedBox(width: 8),
                        _buildCheckbox(
                          'Configurações',
                          _leituraConfig,
                          (v) => setState(() => _leituraConfig = v!),
                        ),
                        const Text(')'),
                      ],
                    ),
                    _buildCheckbox(
                      'Diario/agenda',
                      _diarioAgenda,
                      (v) => setState(() => _diarioAgenda = v!),
                    ),
                    _buildCheckbox(
                      'Documentos',
                      _documentos,
                      (v) => setState(() => _documentos = v!),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Gestao Section
              _buildCheckbox(
                'Gestão:',
                _gestao,
                (v) => setState(() => _gestao = v!),
                isBold: true,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildCheckbox(
                          'Condomínio',
                          _condominio,
                          (v) => setState(() => _condominio = v!),
                        ),
                        const SizedBox(width: 8),
                        _buildCheckbox(
                          'Conf.',
                          _condominioConf,
                          (v) => setState(() => _condominioConf = v!),
                        ),
                        const Text(')'),
                      ],
                    ),
                    _buildCheckbox(
                      'Relatórios',
                      _relatorios,
                      (v) => setState(() => _relatorios = v!),
                    ),
                    _buildCheckbox(
                      'Portaria',
                      _portaria,
                      (v) => setState(() => _portaria = v!),
                    ),

                    // Boleto
                    Row(
                      children: [
                        _buildCheckbox(
                          'Boleto',
                          _boleto,
                          (v) => setState(() => _boleto = v!),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            children: [
                              _buildCheckbox(
                                'Gerar Boletos',
                                _boletoGerar,
                                (v) => setState(() => _boletoGerar = v!),
                              ),
                              _buildCheckbox(
                                'Enviar p/ Registro',
                                _boletoEnviar,
                                (v) => setState(() => _boletoEnviar = v!),
                              ),
                              _buildCheckbox(
                                'Receber',
                                _boletoReceber,
                                (v) => setState(() => _boletoReceber = v!),
                              ),
                              _buildCheckbox(
                                'Excluir',
                                _boletoExcluir,
                                (v) => setState(() => _boletoExcluir = v!),
                              ),
                            ],
                          ),
                        ),
                        const Text(')'),
                      ],
                    ),

                    // Acordo
                    Row(
                      children: [
                        _buildCheckbox(
                          'Acordo',
                          _acordo,
                          (v) => setState(() => _acordo = v!),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            children: [
                              _buildCheckbox(
                                'Gerar Boletos',
                                _acordoGerar,
                                (v) => setState(() => _acordoGerar = v!),
                              ),
                              _buildCheckbox(
                                'Enviar p/ Registro',
                                _acordoEnviar,
                                (v) => setState(() => _acordoEnviar = v!),
                              ),
                            ],
                          ),
                        ),
                        const Text(')'),
                      ],
                    ),

                    Row(
                      children: [
                        _buildCheckbox(
                          'Morador/Unid',
                          _moradorUnid,
                          (v) => setState(() => _moradorUnid = v!),
                        ),
                        const SizedBox(width: 8),
                        _buildCheckbox(
                          'Conf.',
                          _moradorUnidConf,
                          (v) => setState(() => _moradorUnidConf = v!),
                        ),
                        const Text(')'),
                      ],
                    ),
                    _buildCheckbox(
                      'E-mail',
                      _email,
                      (v) => setState(() => _email = v!),
                    ),
                    _buildCheckbox(
                      'Desp/Receita',
                      _despReceita,
                      (v) => setState(() => _despReceita = v!),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D3B66),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                    ),
                    child: const Text(
                      'Salvar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Implement save and invite
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D3B66),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                    ),
                    child: const Text(
                      'Salvar e Enviar Convite por email',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
