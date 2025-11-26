import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'dart:io';
import '../services/unidade_detalhes_service.dart';
import '../services/supabase_service.dart';
import '../models/unidade.dart';
import '../models/proprietario.dart';
import '../models/inquilino.dart';
import '../models/imobiliaria.dart';
import '../utils/formatters.dart';
import '../widgets/qr_code_display_widget.dart';

class DetalhesUnidadeScreen extends StatefulWidget {
  final String? condominioId;
  final String? condominioNome;
  final String? condominioCnpj;
  final String bloco;
  final String unidade;
  final String modo; // 'criar' ou 'editar' (padrão)

  const DetalhesUnidadeScreen({
    super.key,
    this.condominioId,
    this.condominioNome,
    this.condominioCnpj,
    required this.bloco,
    required this.unidade,
    this.modo = 'editar',
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

  // Serviço
  final UnidadeDetalhesService _service = UnidadeDetalhesService();

  // Dados carregados
  Unidade? _unidade;
  Proprietario? _proprietario;
  Inquilino? _inquilino;
  Imobiliaria? _imobiliaria;
  bool _isLoadingDados = true;
  String? _errorMessage;

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

  // Estados para Imobiliária - Foto
  final ImagePicker _imagePicker = ImagePicker();
  Uint8List? _fotoImobiliariaBytes;
  bool _isUploadingFotoImobiliaria = false;

  // Estados para Proprietário - Foto (Upload)
  bool _isUploadingProprietarioFoto = false;

  // Estados para Inquilino - Foto (Upload)
  bool _isUploadingInquilinoFoto = false;

  // Estados de loading para os botões de salvar
  bool _isLoadingUnidade = false;
  bool _isLoadingProprietario = false;
  bool _isLoadingInquilino = false;
  bool _isLoadingImobiliaria = false;

  @override
  void initState() {
    super.initState();
    
    // Se é modo criação, inicializar com valores padrão
    // Se é modo edição, carrega dados do banco
    if (widget.modo == 'criar') {
      _inicializarParaCriacao();
    } else {
      _carregarDados();
    }
  }

  /// Inicializa a tela para criação de nova unidade
  void _inicializarParaCriacao() {
    setState(() {
      _unidadeController.text = widget.unidade;
      _blocoController.text = widget.bloco;
      _isLoadingDados = false;
      _errorMessage = null;
    });
    
    // Aguardar um pouco para o QR code ser salvo no banco (300ms da criação + buffer)
    // Depois recarregar os dados para pegar o QR code
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _carregarDados();
      }
    });
  }

  Future<void> _carregarDados() async {
    if (widget.condominioId == null) {
      setState(() {
        _errorMessage = 'ID do condomínio não informado';
        _isLoadingDados = false;
      });
      return;
    }

    try {
      setState(() {
        _isLoadingDados = true;
        _errorMessage = null;
      });

      final dados = await _service.buscarDetalhesUnidade(
        condominioId: widget.condominioId!,
        numero: widget.unidade,
        bloco: widget.bloco,
      );

      if (mounted) {
        setState(() {
          _unidade = dados['unidade'];
          _proprietario = dados['proprietario'];
          _inquilino = dados['inquilino'];
          _imobiliaria = dados['imobiliaria'];
          _isLoadingDados = false;

          // Preencher campos de unidade
          _unidadeController.text = _unidade?.numero ?? '';
          _blocoController.text = _unidade?.bloco ?? '';
          _fracaoIdealController.text = _unidade?.fracaoIdeal?.toString() ?? '';
          _areaController.text = _unidade?.areaM2?.toString() ?? '';
          _vencimentoDiferenteController.text = _unidade?.vencimentoDiaDiferente?.toString() ?? '';
          _valorDiferenteController.text = _unidade?.pagarValorDiferente?.toString() ?? '';
          _tipoSelecionado = _unidade?.tipoUnidade ?? 'A';
          _observacaoController.text = _unidade?.observacoes ?? '';

          // Preencher estado das isenções
          _isencaoSelecionada = _unidade?.isencaoTotal == true
              ? 'total'
              : _unidade?.isencaoCota == true
                  ? 'cota'
                  : _unidade?.isencaoFundoReserva == true
                      ? 'fundo_reserva'
                      : 'nenhum';

          // Preencher outros estados de unidade
          _acaoJudicialSelecionada = (_unidade?.acaoJudicial ?? false) ? 'sim' : 'nao';
          _correiosSelecionado = (_unidade?.correios ?? false) ? 'sim' : 'nao';
          _pagadorBoletoSelecionado = _unidade?.nomePagadorBoleto ?? 'proprietario';

          // Preencher campos de proprietário
          if (_proprietario != null) {
            _proprietarioNomeController.text = _proprietario?.nome ?? '';
            _proprietarioCpfCnpjController.text = _proprietario?.cpfCnpj ?? '';
            _proprietarioCepController.text = _proprietario?.cep ?? '';
            _proprietarioEnderecoController.text = _proprietario?.endereco ?? '';
            _proprietarioNumeroController.text = _proprietario?.numero ?? '';
            _proprietarioBairroController.text = _proprietario?.bairro ?? '';
            _proprietarioCidadeController.text = _proprietario?.cidade ?? '';
            _proprietarioEstadoController.text = _proprietario?.estado ?? '';
            _proprietarioTelefoneController.text = _proprietario?.telefone ?? '';
            _proprietarioCelularController.text = _proprietario?.celular ?? '';
            _proprietarioEmailController.text = _proprietario?.email ?? '';
            _proprietarioConjugeController.text = _proprietario?.conjuge ?? '';
            _proprietarioMultiproprietariosController.text = _proprietario?.multiproprietarios ?? '';
            _proprietarioMoradoresController.text = _proprietario?.moradores ?? '';
            // Carregar estados dos radio buttons do banco
            _agruparBoletosSelecionado = (_proprietario?.agruparBoletos ?? false) ? 'Sim' : 'Não';
            _matriculaImovelSelecionado = (_proprietario?.matriculaImovel ?? false) ? 'Fazer Upload' : 'Não';
          }

          // Preencher campos de inquilino
          if (_inquilino != null) {
            _inquilinoNomeController.text = _inquilino?.nome ?? '';
            _inquilinoCpfCnpjController.text = _inquilino?.cpfCnpj ?? '';
            _inquilinoCepController.text = _inquilino?.cep ?? '';
            _inquilinoEnderecoController.text = _inquilino?.endereco ?? '';
            _inquilinoNumeroController.text = _inquilino?.numero ?? '';
            _inquilinoBairroController.text = _inquilino?.bairro ?? '';
            _inquilinoCidadeController.text = _inquilino?.cidade ?? '';
            _inquilinoEstadoController.text = _inquilino?.estado ?? '';
            _inquilinoTelefoneController.text = _inquilino?.telefone ?? '';
            _inquilinoCelularController.text = _inquilino?.celular ?? '';
            _inquilinoEmailController.text = _inquilino?.email ?? '';
            _inquilinoConjugeController.text = _inquilino?.conjuge ?? '';
            _inquilinoMultiproprietariosController.text = _inquilino?.multiproprietarios ?? '';
            _inquilinoMoradoresController.text = _inquilino?.moradores ?? '';
            _receberBoletoEmailSelecionado = (_inquilino?.receberBoletoEmail ?? true) ? 'sim' : 'nao';
            _controleLocacaoSelecionado = (_inquilino?.controleLocacao ?? true) ? 'sim' : 'nao';
          }

          // Preencher campos de imobiliária
          if (_imobiliaria != null) {
            _imobiliariaNomeController.text = _imobiliaria?.nome ?? '';
            _imobiliariaCnpjController.text = _imobiliaria?.cnpj ?? '';
            _imobiliariaTelefoneController.text = _imobiliaria?.telefone ?? '';
            _imobiliariaCelularController.text = _imobiliaria?.celular ?? '';
            _imobiliariaEmailController.text = _imobiliaria?.email ?? '';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erro ao carregar dados: $e';
          _isLoadingDados = false;
        });
      }
    }
  }

  // Métodos de salvamento para cada seção
  Future<void> _salvarUnidade() async {
    // Validação: deve haver uma unidade carregada com ID
    if (_unidade == null || _unidade!.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro: Unidade não foi carregada corretamente.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoadingUnidade = true;
    });

    try {
      // Coletar os dados do formulário
      final dadosAtualizacao = <String, dynamic>{
        'numero': _unidadeController.text.trim(),
        'bloco': _blocoController.text.trim(),
        'fracao_ideal': _fracaoIdealController.text.isNotEmpty 
            ? double.tryParse(_fracaoIdealController.text.replaceAll(',', '.'))
            : null,
        'area_m2': _areaController.text.isNotEmpty
            ? double.tryParse(_areaController.text.replaceAll(',', '.'))
            : null,
        'vencto_dia_diferente': _vencimentoDiferenteController.text.isNotEmpty
            ? int.tryParse(_vencimentoDiferenteController.text)
            : null,
        'pagar_valor_diferente': _valorDiferenteController.text.isNotEmpty
            ? double.tryParse(_valorDiferenteController.text.replaceAll('R\$ ', '').replaceAll(',', '.'))
            : null,
        'tipo_unidade': _tipoSelecionado ?? 'A',
        'isencao_nenhum': _isencaoSelecionada == 'nenhum',
        'isencao_total': _isencaoSelecionada == 'total',
        'isencao_cota': _isencaoSelecionada == 'cota',
        'isencao_fundo_reserva': _isencaoSelecionada == 'fundo_reserva',
        'acao_judicial': _acaoJudicialSelecionada == 'sim',
        'correios': _correiosSelecionado == 'sim',
        'nome_pagador_boleto': _pagadorBoletoSelecionado,
        'observacoes': _observacaoController.text.trim().isEmpty 
            ? null 
            : _observacaoController.text.trim(),
      };

      // Chamar o serviço para atualizar
      await _service.atualizarUnidade(
        unidadeId: _unidade!.id,
        dados: dadosAtualizacao,
      );

      // Atualizar os dados em memória (para refletir na interface)
      setState(() {
        _unidade = _unidade!.copyWith(
          numero: dadosAtualizacao['numero'] as String,
          bloco: dadosAtualizacao['bloco'] as String?,
          fracaoIdeal: dadosAtualizacao['fracao_ideal'] as double?,
          areaM2: dadosAtualizacao['area_m2'] as double?,
          vencimentoDiaDiferente: dadosAtualizacao['vencto_dia_diferente'] as int?,
          pagarValorDiferente: dadosAtualizacao['pagar_valor_diferente'] as double?,
          tipoUnidade: dadosAtualizacao['tipo_unidade'] as String,
          isencaoNenhum: dadosAtualizacao['isencao_nenhum'] as bool,
          isencaoTotal: dadosAtualizacao['isencao_total'] as bool,
          isencaoCota: dadosAtualizacao['isencao_cota'] as bool,
          isencaoFundoReserva: dadosAtualizacao['isencao_fundo_reserva'] as bool,
          acaoJudicial: dadosAtualizacao['acao_judicial'] as bool,
          correios: dadosAtualizacao['correios'] as bool,
          nomePagadorBoleto: dadosAtualizacao['nome_pagador_boleto'] as String,
          observacoes: dadosAtualizacao['observacoes'] as String?,
        );
      });

      // Mostrar feedback de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dados da unidade salvos com sucesso!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Mostrar feedback de erro detalhado
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar dados da unidade: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      print('Erro ao salvar unidade: $e');
    } finally {
      setState(() {
        _isLoadingUnidade = false;
      });
    }
  }

  Future<void> _salvarProprietario() async {
    // Validar campos obrigatórios
    final nome = _proprietarioNomeController.text.trim();
    final cpfCnpj = _proprietarioCpfCnpjController.text.trim();
    final email = _proprietarioEmailController.text.trim();

    if (nome.isEmpty || cpfCnpj.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nome*, CPF/CNPJ* e Email* são obrigatórios!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoadingProprietario = true;
    });

    try {
      // Se não tem proprietário, criar um novo
      if (_proprietario == null || _proprietario!.id.isEmpty) {
        print('📝 Criando novo proprietário...');
        
        final novoPropietario = await _service.criarProprietario(
          condominioId: widget.condominioId ?? '',
          unidadeId: _unidade?.id ?? '',
          nome: nome,
          cpfCnpj: cpfCnpj,
          cep: _proprietarioCepController.text.trim().isEmpty ? null : _proprietarioCepController.text.trim(),
          endereco: _proprietarioEnderecoController.text.trim().isEmpty ? null : _proprietarioEnderecoController.text.trim(),
          numero: _proprietarioNumeroController.text.trim().isEmpty ? null : _proprietarioNumeroController.text.trim(),
          bairro: _proprietarioBairroController.text.trim().isEmpty ? null : _proprietarioBairroController.text.trim(),
          cidade: _proprietarioCidadeController.text.trim().isEmpty ? null : _proprietarioCidadeController.text.trim(),
          estado: _proprietarioEstadoController.text.trim().isEmpty ? null : _proprietarioEstadoController.text.trim(),
          telefone: _proprietarioTelefoneController.text.trim().isEmpty ? null : _proprietarioTelefoneController.text.trim(),
          celular: _proprietarioCelularController.text.trim().isEmpty ? null : _proprietarioCelularController.text.trim(),
          email: _proprietarioEmailController.text.trim().isEmpty ? null : _proprietarioEmailController.text.trim(),
          conjuge: _proprietarioConjugeController.text.trim().isEmpty ? null : _proprietarioConjugeController.text.trim(),
          multiproprietarios: _proprietarioMultiproprietariosController.text.trim().isEmpty ? null : _proprietarioMultiproprietariosController.text.trim(),
          moradores: _proprietarioMoradoresController.text.trim().isEmpty ? null : _proprietarioMoradoresController.text.trim(),
        );

        // Atualizar estado com o novo proprietário
        setState(() {
          _proprietario = novoPropietario;
        });

        // Mostrar sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Proprietário criado com sucesso!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        // 🔄 Recarregar dados para mostrar QR code atualizado
        await Future.delayed(const Duration(milliseconds: 500));
        await _carregarDados();
      } else {
        // Se já tem proprietário, atualizar dados
        print('♻️ Atualizando proprietário existente...');
        
        final dadosAtualizacao = <String, dynamic>{
          'nome': nome,
          'cpf_cnpj': cpfCnpj,
          'cep': _proprietarioCepController.text.trim().isEmpty ? null : _proprietarioCepController.text.trim(),
          'endereco': _proprietarioEnderecoController.text.trim().isEmpty ? null : _proprietarioEnderecoController.text.trim(),
          'numero': _proprietarioNumeroController.text.trim().isEmpty ? null : _proprietarioNumeroController.text.trim(),
          'bairro': _proprietarioBairroController.text.trim().isEmpty ? null : _proprietarioBairroController.text.trim(),
          'cidade': _proprietarioCidadeController.text.trim().isEmpty ? null : _proprietarioCidadeController.text.trim(),
          'estado': _proprietarioEstadoController.text.trim().isEmpty ? null : _proprietarioEstadoController.text.trim(),
          'telefone': _proprietarioTelefoneController.text.trim().isEmpty ? null : _proprietarioTelefoneController.text.trim(),
          'celular': _proprietarioCelularController.text.trim().isEmpty ? null : _proprietarioCelularController.text.trim(),
          'email': _proprietarioEmailController.text.trim().isEmpty ? null : _proprietarioEmailController.text.trim(),
          'conjuge': _proprietarioConjugeController.text.trim().isEmpty ? null : _proprietarioConjugeController.text.trim(),
          'multiproprietarios': _proprietarioMultiproprietariosController.text.trim().isEmpty ? null : _proprietarioMultiproprietariosController.text.trim(),
          'moradores': _proprietarioMoradoresController.text.trim().isEmpty ? null : _proprietarioMoradoresController.text.trim(),
          'agrupar_boletos': _agruparBoletosSelecionado == 'Sim',
          'matricula_imovel': _matriculaImovelSelecionado == 'Fazer Upload',
        };

        await _service.atualizarProprietario(
          proprietarioId: _proprietario!.id,
          dados: dadosAtualizacao,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Dados do proprietário atualizados com sucesso!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        // 🔄 Recarregar dados para mostrar QR code atualizado
        await Future.delayed(const Duration(milliseconds: 500));
        await _carregarDados();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erro ao salvar proprietário: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      print('Erro ao salvar proprietário: $e');
    } finally {
      setState(() {
        _isLoadingProprietario = false;
      });
    }
  }

  Future<void> _salvarInquilino() async {
    // Validar campos obrigatórios
    final nome = _inquilinoNomeController.text.trim();
    final cpfCnpj = _inquilinoCpfCnpjController.text.trim();
    final email = _inquilinoEmailController.text.trim();

    if (nome.isEmpty || cpfCnpj.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nome*, CPF/CNPJ* e Email* são obrigatórios!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoadingInquilino = true;
    });

    try {
      // Se não tem inquilino, criar um novo
      if (_inquilino == null || _inquilino!.id.isEmpty) {
        print('📝 Criando novo inquilino...');
        
        final novoInquilino = await _service.criarInquilino(
          condominioId: widget.condominioId ?? '',
          unidadeId: _unidade?.id ?? '',
          nome: nome,
          cpfCnpj: cpfCnpj,
          cep: _inquilinoCepController.text.trim().isEmpty ? null : _inquilinoCepController.text.trim(),
          endereco: _inquilinoEnderecoController.text.trim().isEmpty ? null : _inquilinoEnderecoController.text.trim(),
          numero: _inquilinoNumeroController.text.trim().isEmpty ? null : _inquilinoNumeroController.text.trim(),
          bairro: _inquilinoBairroController.text.trim().isEmpty ? null : _inquilinoBairroController.text.trim(),
          cidade: _inquilinoCidadeController.text.trim().isEmpty ? null : _inquilinoCidadeController.text.trim(),
          estado: _inquilinoEstadoController.text.trim().isEmpty ? null : _inquilinoEstadoController.text.trim(),
          telefone: _inquilinoTelefoneController.text.trim().isEmpty ? null : _inquilinoTelefoneController.text.trim(),
          celular: _inquilinoCelularController.text.trim().isEmpty ? null : _inquilinoCelularController.text.trim(),
          email: _inquilinoEmailController.text.trim().isEmpty ? null : _inquilinoEmailController.text.trim(),
          conjuge: _inquilinoConjugeController.text.trim().isEmpty ? null : _inquilinoConjugeController.text.trim(),
          multiproprietarios: _inquilinoMultiproprietariosController.text.trim().isEmpty ? null : _inquilinoMultiproprietariosController.text.trim(),
          moradores: _inquilinoMoradoresController.text.trim().isEmpty ? null : _inquilinoMoradoresController.text.trim(),
        );

        // Atualizar estado com o novo inquilino
        setState(() {
          _inquilino = novoInquilino;
        });

        // Mostrar sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Inquilino criado com sucesso!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        // 🔄 Recarregar dados para mostrar QR code atualizado
        await Future.delayed(const Duration(milliseconds: 500));
        await _carregarDados();
      } else {
        // Se já tem inquilino, atualizar dados
        print('♻️ Atualizando inquilino existente...');
        
        final dadosAtualizacao = <String, dynamic>{
          'nome': nome,
          'cpf_cnpj': cpfCnpj,
          'cep': _inquilinoCepController.text.trim().isEmpty ? null : _inquilinoCepController.text.trim(),
          'endereco': _inquilinoEnderecoController.text.trim().isEmpty ? null : _inquilinoEnderecoController.text.trim(),
          'numero': _inquilinoNumeroController.text.trim().isEmpty ? null : _inquilinoNumeroController.text.trim(),
          'bairro': _inquilinoBairroController.text.trim().isEmpty ? null : _inquilinoBairroController.text.trim(),
          'cidade': _inquilinoCidadeController.text.trim().isEmpty ? null : _inquilinoCidadeController.text.trim(),
          'estado': _inquilinoEstadoController.text.trim().isEmpty ? null : _inquilinoEstadoController.text.trim(),
          'telefone': _inquilinoTelefoneController.text.trim().isEmpty ? null : _inquilinoTelefoneController.text.trim(),
          'celular': _inquilinoCelularController.text.trim().isEmpty ? null : _inquilinoCelularController.text.trim(),
          'email': _inquilinoEmailController.text.trim().isEmpty ? null : _inquilinoEmailController.text.trim(),
          'conjuge': _inquilinoConjugeController.text.trim().isEmpty ? null : _inquilinoConjugeController.text.trim(),
          'multiproprietarios': _inquilinoMultiproprietariosController.text.trim().isEmpty ? null : _inquilinoMultiproprietariosController.text.trim(),
          'moradores': _inquilinoMoradoresController.text.trim().isEmpty ? null : _inquilinoMoradoresController.text.trim(),
          'receber_boleto_email': _receberBoletoEmailSelecionado == 'sim',
          'controle_locacao': _controleLocacaoSelecionado == 'sim',
        };

        await _service.atualizarInquilino(
          inquilinoId: _inquilino!.id,
          dados: dadosAtualizacao,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Dados do inquilino atualizados com sucesso!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        // 🔄 Recarregar dados para mostrar QR code atualizado
        await Future.delayed(const Duration(milliseconds: 500));
        await _carregarDados();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erro ao salvar inquilino: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      print('Erro ao salvar inquilino: $e');
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
      String imobiliariaId;
      
      // Se não tem imobiliária cadastrada, criar uma nova
      if (_imobiliaria == null || _imobiliaria!.id.isEmpty) {
        // Validar dados obrigatórios
        if (_imobiliariaNomeController.text.trim().isEmpty || 
            _imobiliariaCnpjController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Preencha Nome e CNPJ para criar a imobiliária.'),
              backgroundColor: Colors.orange,
            ),
          );
          setState(() {
            _isLoadingImobiliaria = false;
          });
          return;
        }

        // Validar formato do CNPJ
        if (!Formatters.isValidCNPJ(_imobiliariaCnpjController.text.trim())) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('CNPJ inválido. Verifique se o número está correto.'),
              backgroundColor: Colors.orange,
            ),
          );
          setState(() {
            _isLoadingImobiliaria = false;
          });
          return;
        }

        // Criar imobiliária
        final novaImobiliaria = await _service.criarImobiliaria(
          condominioId: widget.condominioId ?? '',
          unidadeId: widget.unidade,
          nome: _imobiliariaNomeController.text.trim(),
          cnpj: _imobiliariaCnpjController.text.trim(),
          telefone: _imobiliariaTelefoneController.text.trim().isEmpty ? null : _imobiliariaTelefoneController.text.trim(),
          celular: _imobiliariaCelularController.text.trim().isEmpty ? null : _imobiliariaCelularController.text.trim(),
          email: _imobiliariaEmailController.text.trim().isEmpty ? null : _imobiliariaEmailController.text.trim(),
        );

        imobiliariaId = novaImobiliaria.id;
        
        // Atualizar state com a nova imobiliária
        setState(() {
          _imobiliaria = novaImobiliaria;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Imobiliária criada com sucesso!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        // 🔄 Recarregar dados para mostrar QR code atualizado
        await Future.delayed(const Duration(milliseconds: 500));
        await _carregarDados();
      } else {
        imobiliariaId = _imobiliaria!.id;
      }

      // Se tem foto selecionada (em bytes), fazer upload
      String? fotoUrl = _imobiliaria?.fotoUrl;
      
      if (_fotoImobiliariaBytes != null) {
        // Fazer upload da foto para o Supabase Storage
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'imobiliaria_${imobiliariaId}_$timestamp.jpg';
        
        fotoUrl = await SupabaseService.uploadArquivoDocumentoBytes(
          _fotoImobiliariaBytes!,
          fileName,
          widget.condominioId ?? '',
        );

        if (fotoUrl == null) {
          throw Exception('Falha ao fazer upload da foto');
        }
      }

      // Coletar os dados do formulário
      final dadosAtualizacao = <String, dynamic>{
        'nome': _imobiliariaNomeController.text.trim(),
        'cnpj': _imobiliariaCnpjController.text.trim(),
        'telefone': _imobiliariaTelefoneController.text.trim().isEmpty ? null : _imobiliariaTelefoneController.text.trim(),
        'celular': _imobiliariaCelularController.text.trim().isEmpty ? null : _imobiliariaCelularController.text.trim(),
        'email': _imobiliariaEmailController.text.trim().isEmpty ? null : _imobiliariaEmailController.text.trim(),
        'foto_url': fotoUrl,
      };

      // Chamar o serviço para atualizar
      await _service.atualizarImobiliaria(
        imobiliariaId: imobiliariaId,
        dados: dadosAtualizacao,
      );

      // Limpar bytes após salvar
      setState(() {
        _fotoImobiliariaBytes = null;
      });

      // Mostrar feedback de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dados da imobiliária salvos com sucesso!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      // 🔄 Recarregar dados para mostrar QR code atualizado
      await Future.delayed(const Duration(milliseconds: 500));
      await _carregarDados();
    } catch (e) {
      // Mostrar feedback de erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar dados da imobiliária: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      print('Erro ao salvar imobiliária: $e');
    } finally {
      setState(() {
        _isLoadingImobiliaria = false;
      });
    }
  }

  // ============================================================================
  // FUNÇÕES PARA GERENCIAR FOTO DA IMOBILIÁRIA
  // ============================================================================

  /// Abre dialog para selecionar câmera ou galeria
  void _showImageSourceDialogImobiliaria() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeria'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageImobiliaria(ImageSource.gallery);
                },
              ),
              // Mostrar câmera apenas em plataformas móveis
              if (!kIsWeb)
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Câmera'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageImobiliaria(ImageSource.camera);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  /// Seleciona uma imagem de câmera ou galeria
  Future<void> _pickImageImobiliaria(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        
        setState(() {
          _fotoImobiliariaBytes = bytes;
        });

        // Mostrar feedback que foto foi selecionada
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto selecionada. Clique em "SALVAR IMOBILIÁRIA" para confirmar.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar imagem: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Exibe a foto em modo ampliado com zoom
  void _showFotoImobiliariaZoom() {
    if (_imobiliaria?.fotoUrl == null || _imobiliaria!.fotoUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhuma foto disponível'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: InteractiveViewer(
          child: Image.network(
            _imobiliaria!.fotoUrl!,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.black87,
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              );
            },
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
          ),
        ),
      ),
    );
  }

  void _showFotoProprietarioZoom() {
    if (_proprietario?.fotoPerfil == null || _proprietario!.fotoPerfil!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhuma foto disponível'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: InteractiveViewer(
          child: Image.network(
            _proprietario!.fotoPerfil!,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.black87,
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              );
            },
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
          ),
        ),
      ),
    );
  }

  void _showFotoInquilinoZoom() {
    if (_inquilino?.fotoPerfil == null || _inquilino!.fotoPerfil!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhuma foto disponível'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: InteractiveViewer(
          child: Image.network(
            _inquilino!.fotoPerfil!,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.black87,
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              );
            },
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
          ),
        ),
      ),
    );
  }

  // Funções para upload de foto do Proprietário
  void _showImageSourceDialogProprietario() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeria'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadProprietarioFoto(ImageSource.gallery);
                },
              ),
              // Mostrar câmera apenas em plataformas móveis
              if (!kIsWeb)
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Câmera'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndUploadProprietarioFoto(ImageSource.camera);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAndUploadProprietarioFoto(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        _isUploadingProprietarioFoto = true;
      });

      try {
        // Para Web: usar Uint8List diretamente
        // Para Mobile: converter XFile para File
        late Map<String, dynamic>? uploadedProprietario;

        if (kIsWeb) {
          // Web: usar bytes diretamente
          final bytes = await image.readAsBytes();
          uploadedProprietario =
              await _uploadProprietarioFotoWeb(_proprietario!.id, bytes, image.name);
        } else {
          // Mobile: converter para File
          final imageFile = File(image.path);
          uploadedProprietario = await SupabaseService.uploadProprietarioFotoPerfil(
            _proprietario!.id,
            imageFile,
          );
        }

        if (uploadedProprietario != null) {
          setState(() {
            _proprietario = _proprietario?.copyWith(
              fotoPerfil: uploadedProprietario?['foto_perfil'] as String?,
            );
            _isUploadingProprietarioFoto = false;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Foto do proprietário atualizada com sucesso!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      } catch (e) {
        setState(() {
          _isUploadingProprietarioFoto = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao atualizar foto: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isUploadingProprietarioFoto = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar imagem: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Upload para Web (usando Uint8List)
  Future<Map<String, dynamic>?> _uploadProprietarioFotoWeb(
    String proprietarioId,
    Uint8List bytes,
    String fileName,
  ) async {
    try {
      // Detectar extensão
      final fileExtension = fileName.split('.').last.toLowerCase();
      final validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
      final extension = validExtensions.contains(fileExtension) ? fileExtension : 'jpg';

      // Gerar nome único
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storagePath = 'proprietarios/$proprietarioId/$timestamp.$extension';

      // Upload
      await SupabaseService.client.storage
          .from('fotos_perfil')
          .uploadBinary(storagePath, bytes);

      // Obter URL pública
      final imageUrl =
          SupabaseService.client.storage.from('fotos_perfil').getPublicUrl(storagePath);

      // Atualizar banco
      final response = await SupabaseService.client
          .from('proprietarios')
          .update({'foto_perfil': imageUrl})
          .eq('id', proprietarioId)
          .select()
          .single();

      return response;
    } catch (e) {
      print('Erro ao fazer upload da foto de perfil do proprietário (Web): $e');
      rethrow;
    }
  }

  // Funções para upload de foto do Inquilino
  void _showImageSourceDialogInquilino() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeria'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadInquilinoFoto(ImageSource.gallery);
                },
              ),
              // Mostrar câmera apenas em plataformas móveis
              if (!kIsWeb)
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Câmera'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndUploadInquilinoFoto(ImageSource.camera);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAndUploadInquilinoFoto(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        _isUploadingInquilinoFoto = true;
      });

      try {
        // Para Web: usar Uint8List diretamente
        // Para Mobile: converter XFile para File
        late Map<String, dynamic>? uploadedInquilino;

        if (kIsWeb) {
          // Web: usar bytes diretamente
          final bytes = await image.readAsBytes();
          uploadedInquilino =
              await _uploadInquilinoFotoWeb(_inquilino!.id, bytes, image.name);
        } else {
          // Mobile: converter para File
          final imageFile = File(image.path);
          uploadedInquilino = await SupabaseService.uploadInquilinoFotoPerfil(
            _inquilino!.id,
            imageFile,
          );
        }

        if (uploadedInquilino != null) {
          setState(() {
            _inquilino = _inquilino?.copyWith(
              fotoPerfil: uploadedInquilino?['foto_perfil'] as String?,
            );
            _isUploadingInquilinoFoto = false;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Foto do inquilino atualizada com sucesso!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      } catch (e) {
        setState(() {
          _isUploadingInquilinoFoto = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao atualizar foto: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isUploadingInquilinoFoto = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar imagem: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Upload para Web (usando Uint8List)
  Future<Map<String, dynamic>?> _uploadInquilinoFotoWeb(
    String inquilinoId,
    Uint8List bytes,
    String fileName,
  ) async {
    try {
      // Detectar extensão
      final fileExtension = fileName.split('.').last.toLowerCase();
      final validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
      final extension = validExtensions.contains(fileExtension) ? fileExtension : 'jpg';

      // Gerar nome único
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storagePath = 'inquilinos/$inquilinoId/$timestamp.$extension';

      // Upload
      await SupabaseService.client.storage
          .from('fotos_perfil')
          .uploadBinary(storagePath, bytes);

      // Obter URL pública
      final imageUrl =
          SupabaseService.client.storage.from('fotos_perfil').getPublicUrl(storagePath);

      // Atualizar banco
      final response = await SupabaseService.client
          .from('inquilinos')
          .update({'foto_perfil': imageUrl})
          .eq('id', inquilinoId)
          .select()
          .single();

      return response;
    } catch (e) {
      print('Erro ao fazer upload da foto de perfil do inquilino (Web): $e');
      rethrow;
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
        
        const SizedBox(height: 24),
        
        // QR Code da Unidade (se existir ou está carregando)
        if (_unidade != null)
          if (_unidade!.qrCodeUrl != null && _unidade!.qrCodeUrl!.isNotEmpty)
            QrCodeDisplayWidget(
              qrCodeUrl: _unidade!.qrCodeUrl,
              visitanteNome: 'Unidade',
              visitanteCpf: _unidade!.id,
              unidade: '${_unidade!.bloco}-${_unidade!.numero}',
            )
          else
            // Mostrar loading enquanto o QR code é gerado
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue[300]!,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue[600]!,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Gerando QR Code...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Aguarde enquanto o código é gerado e salvo no banco',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[600],
                    ),
                  ),
                ],
              ),
            ),
        
        const SizedBox(height: 24),
        
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
        
        // Seção Anexar foto - Foto do Proprietário
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Foto + Botão Editar
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Se houver foto, exibir em círculo
                  if (_proprietario?.fotoPerfil != null && _proprietario!.fotoPerfil!.isNotEmpty)
                    GestureDetector(
                      onTap: _showFotoProprietarioZoom,
                      child: ClipOval(
                        child: Image.network(
                          _proprietario!.fotoPerfil!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // Se falhar ao carregar, mostrar ícone padrão
                            return Container(
                              width: 100,
                              height: 100,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE0E0E0),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt_outlined,
                                color: Color(0xFF666666),
                                size: 32,
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  else
                    // Se não houver foto, mostrar ícone padrão
                    Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFE0E0E0)),
                          top: BorderSide(color: Color(0xFFE0E0E0)),
                          left: BorderSide(color: Color(0xFFE0E0E0)),
                          right: BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        color: Color(0xFF666666),
                        size: 32,
                      ),
                    ),
                  const SizedBox(width: 16),
                  // Botão Editar Foto
                  Column(
                    children: [
                      FloatingActionButton(
                        onPressed: _isUploadingProprietarioFoto ? null : _showImageSourceDialogProprietario,
                        mini: true,
                        backgroundColor: _isUploadingProprietarioFoto ? Colors.grey : const Color(0xFF2E3A59),
                        child: _isUploadingProprietarioFoto
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.edit, size: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isUploadingProprietarioFoto ? 'Enviando...' : 'Editar',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Foto do Proprietário',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Campo Nome
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Nome',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF333333),
                    ),
                  ),
                  TextSpan(
                    text: '*:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ),
                  ),
                ],
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
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'CPF/CNPJ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF333333),
                    ),
                  ),
                  TextSpan(
                    text: '*:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ),
                  ),
                ],
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
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Email',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF333333),
                    ),
                  ),
                  TextSpan(
                    text: '*:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ),
                  ),
                ],
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
       
       // QR Code do Proprietário (se existir ou está carregando)
       if (_proprietario != null)
         if (_proprietario!.qrCodeUrl != null && _proprietario!.qrCodeUrl!.isNotEmpty)
           Container(
             width: double.infinity,
             padding: const EdgeInsets.all(16),
             decoration: BoxDecoration(
               border: Border.all(color: const Color(0xFFE0E0E0)),
               borderRadius: BorderRadius.circular(8),
               color: const Color(0xFFFAFAFA),
             ),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.center,
               children: [
                 const Text(
                   'QR Code do Proprietário',
                   style: TextStyle(
                     fontSize: 14,
                     fontWeight: FontWeight.w600,
                     color: Color(0xFF333333),
                   ),
                 ),
                 const SizedBox(height: 12),
                 QrCodeDisplayWidget(
                   qrCodeUrl: _proprietario!.qrCodeUrl,
                   visitanteNome: _proprietario!.nome,
                   visitanteCpf: _proprietario!.cpfCnpj,
                   unidade: '${widget.bloco}-${widget.unidade}',
                 ),
               ],
             ),
           )
         else
           // Mostrar loading enquanto o QR code é gerado
           Container(
             width: double.infinity,
             padding: const EdgeInsets.all(16),
             decoration: BoxDecoration(
               border: Border.all(color: Colors.blue[300]!),
               borderRadius: BorderRadius.circular(8),
               color: Colors.blue[50],
             ),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.center,
               children: [
                 const Text(
                   'QR Code do Proprietário',
                   style: TextStyle(
                     fontSize: 14,
                     fontWeight: FontWeight.w600,
                     color: Color(0xFF333333),
                   ),
                 ),
                 const SizedBox(height: 12),
                 Row(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     SizedBox(
                       width: 18,
                       height: 18,
                       child: CircularProgressIndicator(
                         strokeWidth: 2,
                         valueColor: AlwaysStoppedAnimation<Color>(
                           Colors.blue[600]!,
                         ),
                       ),
                     ),
                     const SizedBox(width: 10),
                     Text(
                       'Gerando QR Code...',
                       style: TextStyle(
                         fontSize: 13,
                         color: Colors.blue[700],
                         fontWeight: FontWeight.w500,
                       ),
                     ),
                   ],
                 ),
               ],
             ),
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
          // Seção para anexar foto - Foto do Inquilino
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Foto + Botão Editar
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Se houver foto, exibir em círculo
                    if (_inquilino?.fotoPerfil != null && _inquilino!.fotoPerfil!.isNotEmpty)
                      GestureDetector(
                        onTap: _showFotoInquilinoZoom,
                        child: ClipOval(
                          child: Image.network(
                            _inquilino!.fotoPerfil!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // Se falhar ao carregar, mostrar ícone padrão
                              return Container(
                                width: 100,
                                height: 100,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE0E0E0),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt_outlined,
                                  color: Color(0xFF666666),
                                  size: 32,
                                ),
                              );
                            },
                          ),
                        ),
                      )
                    else
                      // Se não houver foto, mostrar ícone padrão
                      Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border(
                            bottom: BorderSide(color: Color(0xFFE0E0E0)),
                            top: BorderSide(color: Color(0xFFE0E0E0)),
                            left: BorderSide(color: Color(0xFFE0E0E0)),
                            right: BorderSide(color: Color(0xFFE0E0E0)),
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt_outlined,
                          color: Color(0xFF666666),
                          size: 32,
                        ),
                      ),
                    const SizedBox(width: 16),
                    // Botão Editar Foto
                    Column(
                      children: [
                        FloatingActionButton(
                          onPressed: _isUploadingInquilinoFoto ? null : _showImageSourceDialogInquilino,
                          mini: true,
                          backgroundColor: _isUploadingInquilinoFoto ? Colors.grey : const Color(0xFF2E3A59),
                          child: _isUploadingInquilinoFoto
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Icon(Icons.edit, size: 18),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isUploadingInquilinoFoto ? 'Enviando...' : 'Editar',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Foto do Inquilino',
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
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'Nome',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF333333),
                  ),
                ),
                TextSpan(
                  text: '*',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
                ),
              ],
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
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'CPF/CNPJ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF333333),
                  ),
                ),
                TextSpan(
                  text: '*',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
                ),
              ],
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
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'CEP',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF333333),
                  ),
                ),
                TextSpan(
                  text: '*',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
                ),
              ],
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
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'Email',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF333333),
                  ),
                ),
                TextSpan(
                  text: '*:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
                ),
              ],
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
          
          // QR Code do Inquilino (se existir ou está carregando)
          if (_inquilino != null)
            if (_inquilino!.qrCodeUrl != null && _inquilino!.qrCodeUrl!.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFFFAFAFA),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'QR Code do Inquilino',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 12),
                    QrCodeDisplayWidget(
                      qrCodeUrl: _inquilino!.qrCodeUrl,
                      visitanteNome: _inquilino!.nome,
                      visitanteCpf: _inquilino!.cpfCnpj,
                      unidade: '${widget.bloco}-${widget.unidade}',
                    ),
                  ],
                ),
              )
            else
              // Mostrar loading enquanto o QR code é gerado
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue[300]!),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.blue[50],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'QR Code do Inquilino',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blue[600]!,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Gerando QR Code...',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
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
        
        // Seção para anexar/visualizar foto em círculo
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (_imobiliaria?.fotoUrl != null && _imobiliaria!.fotoUrl!.isNotEmpty)
                // Se já tem foto salva no banco, mostrar a foto circular com opção de zoom
                GestureDetector(
                  onTap: _showFotoImobiliariaZoom,
                  child: ClipOval(
                    child: Image.network(
                      _imobiliaria!.fotoUrl!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 100,
                          height: 100,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE0E0E0),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt_outlined,
                            color: Color(0xFF999999),
                            size: 40,
                          ),
                        );
                      },
                    ),
                  ),
                )
              else if (_fotoImobiliariaBytes != null)
                // Se tem foto selecionada mas não salva, mostrar a preview circular
                GestureDetector(
                  onTap: _showImageSourceDialogImobiliaria,
                  child: ClipOval(
                    child: Image.memory(
                      _fotoImobiliariaBytes!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                // Se não tem foto, mostrar botão circular para adicionar
                GestureDetector(
                  onTap: _showImageSourceDialogImobiliaria,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE0E0E0),
                      shape: BoxShape.circle,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isUploadingFotoImobiliaria 
                              ? Icons.hourglass_empty 
                              : Icons.camera_alt_outlined,
                          color: const Color(0xFF999999),
                          size: 40,
                        ),
                        if (!_isUploadingFotoImobiliaria)
                          const Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Text(
                              'Anexar foto',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF666666),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
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
                inputFormatters: [Formatters.cnpjFormatter],
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  hintText: '00.000.000/0000-00',
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
        
        const SizedBox(height: 24),
        
        // QR Code da Imobiliária (se existir ou está carregando)
        if (_imobiliaria != null)
          if (_imobiliaria!.qrCodeUrl != null && _imobiliaria!.qrCodeUrl!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFFFAFAFA),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'QR Code da Imobiliária',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 12),
                  QrCodeDisplayWidget(
                    qrCodeUrl: _imobiliaria!.qrCodeUrl,
                    visitanteNome: _imobiliaria!.nome,
                    visitanteCpf: _imobiliaria!.cnpj,
                    unidade: '${widget.bloco}-${widget.unidade}',
                  ),
                ],
              ),
            )
          else
            // Mostrar loading enquanto o QR code é gerado
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue[300]!),
                borderRadius: BorderRadius.circular(8),
                color: Colors.blue[50],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'QR Code da Imobiliária',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue[600]!,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Gerando QR Code...',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        
        const SizedBox(height: 24),
        
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

            // ⚠️ Aviso para modo criação
            if (widget.modo == 'criar')
              Container(
                color: Colors.orange.shade50,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Modo Criação: Nova Unidade',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Você deve salvar a unidade antes de preencher proprietário/inquilino.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Conteúdo principal
            Expanded(
              child: _isLoadingDados
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A90E2)),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Carregando dados...',
                            style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
                          ),
                        ],
                      ),
                    )
                  : _errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, size: 64, color: Colors.red),
                              const SizedBox(height: 16),
                              Text(
                                _errorMessage!,
                                style: const TextStyle(fontSize: 16, color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _carregarDados,
                                child: const Text('Tentar Novamente'),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
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