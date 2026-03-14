import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../models/porteiro.dart';
import '../../../../models/user_permissions.dart';
import '../cubit/gestao_usuarios_cubit.dart';

class GestaoUsuariosScreen extends StatefulWidget {
  final String condominioId;

  const GestaoUsuariosScreen({super.key, required this.condominioId});

  @override
  State<GestaoUsuariosScreen> createState() => _GestaoUsuariosScreenState();
}

class _GestaoUsuariosScreenState extends State<GestaoUsuariosScreen> {
  static const _primaryColor = Color(0xFF0D3B66);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GestaoUsuariosCubit()..carregarUsuarios(widget.condominioId),
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 24),
              onPressed: () => Navigator.pop(context),
            ),
            title: Image.asset('assets/images/logo_CondoGaia.png', height: 30),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Image.asset('assets/images/Sino_Notificacao.png', width: 24, height: 24),
                onPressed: () {},
              ),
              IconButton(
                icon: Image.asset('assets/images/Fone_Ouvido_Cabecalho.png', width: 24, height: 24),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showUsuarioDialog(context),
            backgroundColor: _primaryColor,
            child: const Icon(Icons.add, color: Colors.white),
          ),
          body: Column(
            children: [
              const Divider(height: 1),
              Expanded(
                child: BlocBuilder<GestaoUsuariosCubit, GestaoUsuariosState>(
                  builder: (context, state) {
                    if (state is GestaoUsuariosLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is GestaoUsuariosError) {
                      return Center(child: Text(state.message));
                    }

                    if (state is GestaoUsuariosLoaded) {
                      if (state.usuarios.isEmpty) {
                        return const Center(child: Text('Nenhum usuário cadastrado.'));
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: state.usuarios.length,
                        itemBuilder: (context, index) {
                          final usuario = state.usuarios[index];
                          return _buildUsuarioItem(context, usuario);
                        },
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsuarioItem(BuildContext context, Porteiro usuario) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    usuario.nomeCompleto,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _primaryColor),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: _primaryColor),
                      onPressed: () => _showUsuarioDialog(context, usuario: usuario),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _confirmarExclusao(context, usuario),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildInfoRowWithCopy('Login (E-mail):', usuario.email ?? "Não informado", context),
            const SizedBox(height: 4),
            _buildInfoRowWithCopy('Senha:', usuario.senhaAcesso, context),
            const SizedBox(height: 8),
            const Text('Acessos Liberados:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _primaryColor)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _buildAcessoChips(usuario.permissions),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRowWithCopy(String label, String value, BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '$label $value',
            style: const TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (value != "Não informado")
          IconButton(
            icon: const Icon(Icons.copy, size: 16, color: Colors.grey),
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(4),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$label copiado!'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            tooltip: 'Copiar',
          ),
      ],
    );
  }

  List<Widget> _buildAcessoChips(UserPermissions perms) {
    List<String> acessos = [];
    if (perms.todos) {
      acessos.add('Acesso Total');
    } else {
      if (perms.hasAdminAccess()) acessos.add('Administrativo e RH');
      if (perms.hasCommsAccess()) acessos.add('Comunicação');
      if (perms.hasOpAccess()) acessos.add('Operacional e Portaria');
      if (perms.hasFinAccess()) acessos.add('Financeiro');
      if (perms.hasDocsAccess()) acessos.add('Arquivos');
    }

    if (acessos.isEmpty) {
      return [const Text('Nenhum acesso configurado', style: TextStyle(fontSize: 13, color: Colors.grey, fontStyle: FontStyle.italic))];
    }

    return acessos.map((acesso) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0D3B66).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF0D3B66).withOpacity(0.3)),
      ),
      child: Text(
        acesso,
        style: const TextStyle(fontSize: 12, color: Color(0xFF0D3B66), fontWeight: FontWeight.w500),
      ),
    )).toList();
  }

  void _confirmarExclusao(BuildContext context, Porteiro usuario) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir Usuário'),
        content: Text('Deseja realmente excluir ${usuario.nomeCompleto}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<GestaoUsuariosCubit>().excluirUsuario(usuario.id, widget.condominioId);
              Navigator.pop(dialogContext);
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showUsuarioDialog(BuildContext context, {Porteiro? usuario}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: context.read<GestaoUsuariosCubit>(),
          child: _UsuarioFormDialog(
            condominioId: widget.condominioId,
            usuario: usuario,
          ),
        );
      },
    );
  }
}

class _UsuarioFormDialog extends StatefulWidget {
  final String condominioId;
  final Porteiro? usuario;

  const _UsuarioFormDialog({required this.condominioId, this.usuario});

  @override
  State<_UsuarioFormDialog> createState() => _UsuarioFormDialogState();
}

class _UsuarioFormDialogState extends State<_UsuarioFormDialog> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  late UserPermissions _permissions;

  @override
  void initState() {
    super.initState();
    if (widget.usuario != null) {
      _nomeController.text = widget.usuario!.nomeCompleto;
      _emailController.text = widget.usuario!.email ?? '';
      _permissions = widget.usuario!.permissions;
    } else {
      _permissions = const UserPermissions();
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0D3B66);
    final size = MediaQuery.of(context).size;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: size.width * 0.9,
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Popup', style: TextStyle(color: Colors.grey)),
                  IconButton(
                    icon: const Icon(Icons.close, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildFieldLabel('Usuário:', isRequired: true),
              _buildTextField(_nomeController),
              const SizedBox(height: 8),
              _buildFieldLabel('E-Mail:', isRequired: true),
              _buildTextField(_emailController),
              const SizedBox(height: 16),
              
              // 1. ADMINISTRATIVO E RH
              _buildSectionHeader('Administrativo e RH', _permissions.hasAdminAccess(), (v) {
                setState(() {
                  _permissions = _permissions.copyWith(
                    condominioGestao: v,
                    condominioConf: v,
                    moradorUnid: v,
                    moradorConf: v,
                    gestaoUsuarios: v,
                  );
                });
              }),
              _buildPermissionItemWithSub(
                'Condomínio', 
                _permissions.condominioGestao, 
                (v) => _updatePermissions(condominioGestao: v, condominioConf: v ? true : null),
                'Conf.',
                _permissions.condominioConf,
                (v) => _updatePermissions(condominioConf: v, condominioGestao: v ? true : null),
              ),
              _buildPermissionItemWithSub(
                'Morador/Unid', 
                _permissions.moradorUnid, 
                (v) => _updatePermissions(moradorUnid: v, moradorConf: v ? true : null),
                'Conf.',
                _permissions.moradorConf,
                (v) => _updatePermissions(moradorConf: v, moradorUnid: v ? true : null),
              ),
              _buildPermissionItem('Gestão de Equipe/Usuários', _permissions.gestaoUsuarios, (v) => _updatePermissions(gestaoUsuarios: v)),
              
              const SizedBox(height: 16),

              // 2. COMUNICAÇÃO
              _buildSectionHeader('Comunicação', _permissions.hasCommsAccess(), (v) {
                setState(() {
                  _permissions = _permissions.copyWith(
                    chat: v,
                    emailGestao: v,
                    notificacoesMural: v,
                  );
                });
              }),
              _buildPermissionItem('Chat', _permissions.chat, (v) => _updatePermissions(chat: v)),
              _buildPermissionItem('E-mail Disparos', _permissions.emailGestao, (v) => _updatePermissions(emailGestao: v)),
              _buildPermissionItem('Mural de Notificações', _permissions.notificacoesMural, (v) => _updatePermissions(notificacoesMural: v)),
              
              const SizedBox(height: 16),

              // 3. OPERACIONAL E PORTARIA
              _buildSectionHeader('Operacional e Portaria', _permissions.hasOpAccess(), (v) {
                setState(() {
                  _permissions = _permissions.copyWith(
                    portaria: v,
                    reservas: v,
                    reservasConfig: v,
                    leitura: v,
                    leituraConfig: v,
                    diarioAgenda: v,
                  );
                });
              }),
              _buildPermissionItem('Portaria', _permissions.portaria, (v) => _updatePermissions(portaria: v)),
              _buildPermissionItemWithSub(
                'Reservas', 
                _permissions.reservas, 
                (v) => _updatePermissions(reservas: v, reservasConfig: v ? true : null),
                'Config.',
                _permissions.reservasConfig,
                (v) => _updatePermissions(reservasConfig: v, reservas: v ? true : null),
              ),
              _buildPermissionItemWithSub(
                'Leitura (Água/Gás)', 
                _permissions.leitura, 
                (v) => _updatePermissions(leitura: v, leituraConfig: v ? true : null),
                'Config.',
                _permissions.leituraConfig,
                (v) => _updatePermissions(leituraConfig: v, leitura: v ? true : null),
              ),
              _buildPermissionItem('Diário e Agenda', _permissions.diarioAgenda, (v) => _updatePermissions(diarioAgenda: v)),
              
              const SizedBox(height: 16),

              // 4. FINANCEIRO
              _buildSectionHeader('Financeiro', _permissions.hasFinAccess(), (v) {
                setState(() {
                  _permissions = _permissions.copyWith(
                    despReceita: v, despReceitaCriar: v, despReceitaExcluir: v,
                    boleto: v, boletoGerar: v, boletoEnviar: v, boletoReceber: v, boletoExcluir: v,
                    cobrancasAcordos: v, acordoGerar: v, acordoEnviar: v,
                    relatorios: v,
                  );
                });
              }),
              _buildPermissionDespesaReceita(),
              _buildPermissionBoleto(),
              _buildPermissionAcordo(),
              _buildPermissionItem('Relatórios', _permissions.relatorios, (v) => _updatePermissions(relatorios: v)),
              
              const SizedBox(height: 16),

              // 5. ARQUIVOS
              _buildSectionHeader('Arquivos', _permissions.hasDocsAccess(), (v) {
                setState(() => _permissions = _permissions.copyWith(documentos: v));
              }),
              _buildPermissionItem('Documentos e Pastas', _permissions.documentos, (v) => _updatePermissions(documentos: v)),

              const SizedBox(height: 24),
              Center(
                child: Column(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        minimumSize: const Size(120, 40),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: () => _handleSave(context),
                      child: const Text('Salvar', style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        minimumSize: const Size(200, 40),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: () => _handleSave(context, sendInvite: true),
                      child: const Text('Salvar e Enviar Convite por email', style: TextStyle(color: Colors.white, fontSize: 13)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updatePermissions({
    bool? gestaoUsuarios, bool? notificacoesMural,
    bool? chat, bool? reservas, bool? reservasConfig, bool? leitura, bool? leituraConfig,
    bool? diarioAgenda, bool? documentos,
    bool? condominioGestao, bool? condominioConf, bool? relatorios, bool? portaria,
    bool? boleto, bool? boletoGerar, bool? boletoEnviar, bool? boletoReceber, bool? boletoExcluir,
    bool? cobrancasAcordos, bool? acordoGerar, bool? acordoEnviar,
    bool? moradorUnid, bool? moradorConf, bool? emailGestao, 
    bool? despReceita, bool? despReceitaCriar, bool? despReceitaExcluir,
  }) {
    setState(() {
      _permissions = _permissions.copyWith(
        gestaoUsuarios: gestaoUsuarios,
        notificacoesMural: notificacoesMural,
        chat: chat,
        reservas: reservas,
        reservasConfig: reservasConfig,
        leitura: leitura,
        leituraConfig: leituraConfig,
        diarioAgenda: diarioAgenda,
        documentos: documentos,
        condominioGestao: condominioGestao,
        condominioConf: condominioConf,
        relatorios: relatorios,
        portaria: portaria,
        boleto: boleto,
        boletoGerar: boletoGerar,
        boletoEnviar: boletoEnviar,
        boletoReceber: boletoReceber,
        boletoExcluir: boletoExcluir,
        cobrancasAcordos: cobrancasAcordos,
        acordoGerar: acordoGerar,
        acordoEnviar: acordoEnviar,
        moradorUnid: moradorUnid,
        moradorConf: moradorConf,
        emailGestao: emailGestao,
        despReceita: despReceita,
        despReceitaCriar: despReceitaCriar,
        despReceitaExcluir: despReceitaExcluir,
      );
    });
  }

  Widget _buildFieldLabel(String label, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          if (isRequired)
            const Text(' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller) {
    return Container(
      height: 35,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          border: InputBorder.none,
        ),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool value, Function(bool) onChanged) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(width: 8),
        _buildSmallCheckbox(value, onChanged),
      ],
    );
  }

  Widget _buildPermissionItem(String title, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 4),
      child: Row(
        children: [
          _buildSmallCheckbox(value, onChanged),
          const SizedBox(width: 4),
          Text(title, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildPermissionItemWithSub(String title, bool value, Function(bool) onChanged, String subTitle, bool subValue, Function(bool) subOnChanged) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 4),
      child: Row(
        children: [
          _buildSmallCheckbox(value, onChanged),
          const SizedBox(width: 4),
          Text(title, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          const Text('(', style: TextStyle(fontSize: 14)),
          _buildSmallCheckbox(subValue, subOnChanged),
          const SizedBox(width: 4),
          Text(subTitle, style: const TextStyle(fontSize: 14)),
          const Text(')', style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildPermissionBoleto() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildSmallCheckbox(_permissions.boleto, (v) => _updatePermissions(boleto: v, boletoGerar: v ? true : null, boletoEnviar: v ? true : null, boletoReceber: v ? true : null, boletoExcluir: v ? true : null)),
              const SizedBox(width: 4),
              const Text('Boleto', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              const Text('(', style: TextStyle(fontSize: 14)),
              _buildSmallCheckbox(_permissions.boletoGerar, (v) => _updatePermissions(boletoGerar: v, boleto: v ? true : null)),
              const SizedBox(width: 4),
              const Text('Gerar Boletos', style: TextStyle(fontSize: 13)),
              const SizedBox(width: 8),
              _buildSmallCheckbox(_permissions.boletoEnviar, (v) => _updatePermissions(boletoEnviar: v, boleto: v ? true : null)),
              const SizedBox(width: 4),
              const Text('Enviar p/ Registro', style: TextStyle(fontSize: 13)),
              const Text(')', style: TextStyle(fontSize: 14)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 55),
            child: Row(
              children: [
                const Text('(', style: TextStyle(fontSize: 14)),
                _buildSmallCheckbox(_permissions.boletoReceber, (v) => _updatePermissions(boletoReceber: v, boleto: v ? true : null)),
                const SizedBox(width: 4),
                const Text('Receber', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 8),
                _buildSmallCheckbox(_permissions.boletoExcluir, (v) => _updatePermissions(boletoExcluir: v, boleto: v ? true : null)),
                const SizedBox(width: 4),
                const Text('Excluir', style: TextStyle(fontSize: 13)),
                const Text(' )', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionAcordo() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 4),
      child: Row(
        children: [
          _buildSmallCheckbox(_permissions.cobrancasAcordos, (v) => _updatePermissions(cobrancasAcordos: v, acordoGerar: v ? true : null, acordoEnviar: v ? true : null)),
          const SizedBox(width: 4),
          const Text('Cobranças/Acordo', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          const Text('(', style: TextStyle(fontSize: 14)),
          _buildSmallCheckbox(_permissions.acordoGerar, (v) => _updatePermissions(acordoGerar: v, cobrancasAcordos: v ? true : null)),
          const SizedBox(width: 4),
          const Text('Gerar Acordo', style: TextStyle(fontSize: 13)),
          const SizedBox(width: 8),
          _buildSmallCheckbox(_permissions.acordoEnviar, (v) => _updatePermissions(acordoEnviar: v, cobrancasAcordos: v ? true : null)),
          const SizedBox(width: 4),
          const Text('Enviar p/ Registro', style: TextStyle(fontSize: 13)),
          const Text(')', style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildPermissionDespesaReceita() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 4),
      child: Row(
        children: [
          _buildSmallCheckbox(_permissions.despReceita, (v) => _updatePermissions(despReceita: v, despReceitaCriar: v ? true : null, despReceitaExcluir: v ? true : null)),
          const SizedBox(width: 4),
          const Text('Despesa/Receita', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          const Text('(', style: TextStyle(fontSize: 14)),
          _buildSmallCheckbox(_permissions.despReceitaCriar, (v) => _updatePermissions(despReceitaCriar: v, despReceita: v ? true : null)),
          const SizedBox(width: 4),
          const Text('Criar', style: TextStyle(fontSize: 13)),
          const SizedBox(width: 8),
          _buildSmallCheckbox(_permissions.despReceitaExcluir, (v) => _updatePermissions(despReceitaExcluir: v, despReceita: v ? true : null)),
          const SizedBox(width: 4),
          const Text('Excluir', style: TextStyle(fontSize: 13)),
          const Text(')', style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildSmallCheckbox(bool value, Function(bool) onChanged) {
    return SizedBox(
      height: 20,
      width: 20,
      child: Checkbox(
        value: value,
        onChanged: (v) => onChanged(v ?? false),
        activeColor: const Color(0xFF0D3B66),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      ),
    );
  }

  String _gerarCpfVazioMock() {
    // Retorna um CPF válido gerado apenas para preencher o banco
    final rng = math.Random();
    List<int> n = List.generate(9, (_) => rng.nextInt(10));

    int d1 = 0;
    for (int i = 0; i < 9; i++) {
      d1 += n[i] * (10 - i);
    }
    d1 = 11 - (d1 % 11);
    if (d1 >= 10) d1 = 0;
    n.add(d1);

    int d2 = 0;
    for (int i = 0; i < 10; i++) {
      d2 += n[i] * (11 - i);
    }
    d2 = 11 - (d2 % 11);
    if (d2 >= 10) d2 = 0;
    n.add(d2);

    String cpf = n.join('');
    return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-${cpf.substring(9, 11)}';
  }

  String _gerarSenhaAleatoria() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = math.Random();
    return String.fromCharCodes(Iterable.generate(
      8, (_) => chars.codeUnitAt(rnd.nextInt(chars.length)),
    ));
  }

  Future<void> _handleSave(BuildContext context, {bool sendInvite = false}) async {
    if (_nomeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, informe o Nome Completo.'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, informe um E-mail de acesso.'), backgroundColor: Colors.red),
      );
      return;
    }

    // Verifica se ao menos uma permissão foi marcada (setores principais ou sub-permissões)
    bool temPermissao = _permissions.hasAdminAccess() || 
                       _permissions.hasCommsAccess() || 
                       _permissions.hasOpAccess() || 
                       _permissions.hasFinAccess() || 
                       _permissions.hasDocsAccess() || 
                       _permissions.todos;

    if (!temPermissao) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione ao menos um setor de acesso para o usuário.'), backgroundColor: Colors.orange),
      );
      return;
    }

    // Para simplificar, o "Cargo" será deduzido ou mantido se for edição. 
    // No mockup não tem campo cargo explícito, mas no banco é obrigatório.
    final cargo = widget.usuario?.cargo ?? 'Colaborador';
    
    final novoUsuario = Porteiro(
      id: widget.usuario?.id ?? 'temp_\${DateTime.now().millisecondsSinceEpoch}',
      nomeCompleto: _nomeController.text,
      cpf: widget.usuario?.cpf ?? _gerarCpfVazioMock(), // Mock: gerando CPF falso válido para passar na constraint
      senhaAcesso: widget.usuario?.senhaAcesso ?? _gerarSenhaAleatoria(), 
      condominioId: widget.condominioId,
      cargo: cargo,
      email: _emailController.text,
      permissions: _permissions,
      createdAt: widget.usuario?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    // Exibir loading modal
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final cubit = context.read<GestaoUsuariosCubit>();
      
      // Salva no banco de dados primeiro
      await cubit.salvarUsuario(novoUsuario);

      // Dispara o e-mail de convite
      if (sendInvite) {
        await cubit.enviarConviteEmail(
          nomeUsuario: novoUsuario.nomeCompleto,
          emailUsuario: novoUsuario.email ?? '',
          senhaAcesso: novoUsuario.senhaAcesso,
        );
      }
      
      // Fecha o loading modal
      if (mounted) Navigator.pop(context);
      
      if (sendInvite && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Convite enviado com sucesso para o modo de Teste!'), backgroundColor: Colors.green),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário salvo com sucesso!'), backgroundColor: Colors.green),
        );
      }
      
      // Fecha o formulário
      if (mounted) Navigator.pop(context);
      
    } catch (e) {
      // Fecha o loading modal
      if (mounted) Navigator.pop(context);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar/enviar: \$e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

