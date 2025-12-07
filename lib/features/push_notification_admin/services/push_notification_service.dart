import '../models/localizacao_model.dart';
import '../models/morador_model.dart';

class PushNotificationService {
  /// Lista de estados brasileiros - dados mockados
  static final List<EstadoModel> _estados = [
    EstadoModel(sigla: 'AC', nome: 'Acre'),
    EstadoModel(sigla: 'AL', nome: 'Alagoas'),
    EstadoModel(sigla: 'AP', nome: 'Amapá'),
    EstadoModel(sigla: 'AM', nome: 'Amazonas'),
    EstadoModel(sigla: 'BA', nome: 'Bahia'),
    EstadoModel(sigla: 'CE', nome: 'Ceará'),
    EstadoModel(sigla: 'DF', nome: 'Distrito Federal'),
    EstadoModel(sigla: 'ES', nome: 'Espírito Santo'),
    EstadoModel(sigla: 'GO', nome: 'Goiás'),
    EstadoModel(sigla: 'MA', nome: 'Maranhão'),
    EstadoModel(sigla: 'MT', nome: 'Mato Grosso'),
    EstadoModel(sigla: 'MS', nome: 'Mato Grosso do Sul'),
    EstadoModel(sigla: 'MG', nome: 'Minas Gerais'),
    EstadoModel(sigla: 'PA', nome: 'Pará'),
    EstadoModel(sigla: 'PB', nome: 'Paraíba'),
    EstadoModel(sigla: 'PR', nome: 'Paraná'),
    EstadoModel(sigla: 'PE', nome: 'Pernambuco'),
    EstadoModel(sigla: 'PI', nome: 'Piauí'),
    EstadoModel(sigla: 'RJ', nome: 'Rio de Janeiro'),
    EstadoModel(sigla: 'RN', nome: 'Rio Grande do Norte'),
    EstadoModel(sigla: 'RS', nome: 'Rio Grande do Sul'),
    EstadoModel(sigla: 'RO', nome: 'Rondônia'),
    EstadoModel(sigla: 'RR', nome: 'Roraima'),
    EstadoModel(sigla: 'SC', nome: 'Santa Catarina'),
    EstadoModel(sigla: 'SP', nome: 'São Paulo'),
    EstadoModel(sigla: 'SE', nome: 'Sergipe'),
    EstadoModel(sigla: 'TO', nome: 'Tocantins'),
  ];

  /// Mapa de cidades por estado - dados mockados
  static final Map<String, List<CidadeModel>> _cidadesPorEstado = {
    'SP': [
      CidadeModel(id: 1, nome: 'São Paulo', estadoSigla: 'SP'),
      CidadeModel(id: 2, nome: 'Campinas', estadoSigla: 'SP'),
      CidadeModel(id: 3, nome: 'Santos', estadoSigla: 'SP'),
      CidadeModel(id: 4, nome: 'Ribeirão Preto', estadoSigla: 'SP'),
      CidadeModel(id: 5, nome: 'Sorocaba', estadoSigla: 'SP'),
    ],
    'RJ': [
      CidadeModel(id: 6, nome: 'Rio de Janeiro', estadoSigla: 'RJ'),
      CidadeModel(id: 7, nome: 'Niterói', estadoSigla: 'RJ'),
      CidadeModel(id: 8, nome: 'Duque de Caxias', estadoSigla: 'RJ'),
      CidadeModel(id: 9, nome: 'São Gonçalo', estadoSigla: 'RJ'),
      CidadeModel(id: 10, nome: 'Itaboraí', estadoSigla: 'RJ'),
    ],
    'MG': [
      CidadeModel(id: 11, nome: 'Belo Horizonte', estadoSigla: 'MG'),
      CidadeModel(id: 12, nome: 'Uberlândia', estadoSigla: 'MG'),
      CidadeModel(id: 13, nome: 'Contagem', estadoSigla: 'MG'),
      CidadeModel(id: 14, nome: 'Juiz de Fora', estadoSigla: 'MG'),
      CidadeModel(id: 15, nome: 'Montes Claros', estadoSigla: 'MG'),
    ],
    'BA': [
      CidadeModel(id: 16, nome: 'Salvador', estadoSigla: 'BA'),
      CidadeModel(id: 17, nome: 'Feira de Santana', estadoSigla: 'BA'),
      CidadeModel(id: 18, nome: 'Vitória da Conquista', estadoSigla: 'BA'),
      CidadeModel(id: 19, nome: 'Camaçari', estadoSigla: 'BA'),
      CidadeModel(id: 20, nome: 'Jequié', estadoSigla: 'BA'),
    ],
  };

  /// Lista de moradores - dados mockados
  static final List<MoradorModel> _moradores = [
    MoradorModel(id: '1', nome: 'João Silva', unidade: '101', bloco: 'A'),
    MoradorModel(id: '2', nome: 'Maria Santos', unidade: '102', bloco: 'A'),
    MoradorModel(id: '3', nome: 'Pedro Oliveira', unidade: '201', bloco: 'B'),
    MoradorModel(id: '4', nome: 'Ana Costa', unidade: '202', bloco: 'B'),
    MoradorModel(id: '5', nome: 'Carlos Ferreira', unidade: '301', bloco: 'C'),
    MoradorModel(id: '6', nome: 'Lucia Rocha', unidade: '302', bloco: 'C'),
    MoradorModel(id: '7', nome: 'Felipe Gomes', unidade: '103', bloco: 'A'),
    MoradorModel(id: '8', nome: 'Patricia Lima', unidade: '203', bloco: 'B'),
    MoradorModel(id: '9', nome: 'Roberto Alves', unidade: '303', bloco: 'C'),
    MoradorModel(id: '10', nome: 'Beatriz Martins', unidade: '104', bloco: 'A'),
  ];



  /// Obtém a lista completa de estados
  Future<List<EstadoModel>> obterEstados() async {
    // Simulando uma chamada à API com delay
    await Future.delayed(const Duration(milliseconds: 300));
    return _estados;
  }

  /// Obtém as cidades de um estado específico
  Future<List<CidadeModel>> obterCidadesPorEstado(String estadoSigla) async {
    // Simulando uma chamada à API com delay
    await Future.delayed(const Duration(milliseconds: 300));
    return _cidadesPorEstado[estadoSigla] ?? [];
  }

  /// Obtém a lista de moradores
  Future<List<MoradorModel>> obterMoradores({String? filtro}) async {
    // Simulando uma chamada à API com delay
    await Future.delayed(const Duration(milliseconds: 400));
    
    if (filtro == null || filtro.isEmpty) {
      return _moradores;
    }
    
    final filtroLower = filtro.toLowerCase();
    return _moradores
        .where((morador) =>
            morador.nome.toLowerCase().contains(filtroLower) ||
            morador.unidade.contains(filtro) ||
            morador.bloco.toLowerCase().contains(filtroLower))
        .toList();
  }

  /// Valida os dados de uma notificação
  /// Retorna uma lista de mensagens de erro (vazia se válido)
  List<String> validarNotificacao({
    required String titulo,
    required String mensagem,
    required bool sindicosInclusos,
    required List moradoresSelecionados, // Mantido vazio para compatibilidade
    required EstadoModel? estadoSelecionado,
    required CidadeModel? cidadeSelecionada,
  }) {
    final erros = <String>[];

    if (titulo.trim().isEmpty) {
      erros.add('O título é obrigatório');
    } else if (titulo.length < 3) {
      erros.add('O título deve ter no mínimo 3 caracteres');
    } else if (titulo.length > 100) {
      erros.add('O título não pode exceder 100 caracteres');
    }

    if (mensagem.trim().isEmpty) {
      erros.add('A mensagem é obrigatória');
    } else if (mensagem.length < 10) {
      erros.add('A mensagem deve ter no mínimo 10 caracteres');
    } else if (mensagem.length > 500) {
      erros.add('A mensagem não pode exceder 500 caracteres');
    }

    if (estadoSelecionado == null) {
      erros.add('Selecione um estado');
    }

    if (cidadeSelecionada == null) {
      erros.add('Selecione uma cidade');
    }

    return erros;
  }

  /// Simula o envio de uma notificação
  /// Retorna um Future que resolve após alguns segundos
  Future<bool> enviarNotificacao({
    required String titulo,
    required String mensagem,
    required bool sindicosInclusos,
    required List moradoresSelecionados, // Mantido vazio para compatibilidade
    required EstadoModel? estadoSelecionado,
    required CidadeModel? cidadeSelecionada,
  }) async {
    // Validar antes de enviar
    final erros = validarNotificacao(
      titulo: titulo,
      mensagem: mensagem,
      sindicosInclusos: sindicosInclusos,
      moradoresSelecionados: moradoresSelecionados,
      estadoSelecionado: estadoSelecionado,
      cidadeSelecionada: cidadeSelecionada,
    );

    if (erros.isNotEmpty) {
      throw Exception(erros.join('\n'));
    }

    // Simulando uma chamada à API com delay
    await Future.delayed(const Duration(seconds: 2));

    // Por enquanto, sempre retorna true (sucesso)
    return true;
  }
}
