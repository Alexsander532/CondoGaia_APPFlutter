import '../models/localizacao_model.dart';
import '../models/morador_model.dart';
import '../models/condominio_model.dart';
import '../../../../services/supabase_service.dart';

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

  /// Lista de condomínios - dados mockados (fallback)
  static final List<CondominioModel> _condominios = [
    CondominioModel(
      id: '1',
      nome: 'Cond. Arara',
      localizacao: 'Três Lagoas/MS',
    ),
    CondominioModel(
      id: '2',
      nome: 'Cond. Mansão',
      localizacao: 'São Paulo/SP',
    ),
    CondominioModel(
      id: '3',
      nome: 'Cond. Jardim',
      localizacao: 'Campinas/SP',
    ),
    CondominioModel(
      id: '4',
      nome: 'Cond. Vila Real',
      localizacao: 'Rio de Janeiro/RJ',
    ),
    CondominioModel(
      id: '5',
      nome: 'Cond. Morada do Sol',
      localizacao: 'Belo Horizonte/MG',
    ),
    CondominioModel(
      id: '6',
      nome: 'Cond. Praia Mar',
      localizacao: 'Salvador/BA',
    ),
    CondominioModel(
      id: '7',
      nome: 'Cond. Estação',
      localizacao: 'Porto Alegre/RS',
    ),
    CondominioModel(
      id: '8',
      nome: 'Cond. Luar',
      localizacao: 'Curitiba/PR',
    ),
    CondominioModel(
      id: '9',
      nome: 'Cond. Oasis',
      localizacao: 'Niterói/RJ',
    ),
    CondominioModel(
      id: '10',
      nome: 'Cond. Park',
      localizacao: 'Sorocaba/SP',
    ),
  ];



  /// Obtém a lista completa de estados
  Future<List<EstadoModel>> obterEstados() async {
    try {
      // Usa o SupabaseService para buscar apenas UFs que têm condomínios
      final ufs = await SupabaseService.getUfsFromCondominios();
      
      // Mapeia as siglas para EstadoModel
      return ufs.map((sigla) {
        // Encontra o nome completo do estado na lista _estados
        final estado = _estados.firstWhere(
          (e) => e.sigla == sigla,
          orElse: () => EstadoModel(sigla: sigla, nome: sigla),
        );
        return estado;
      }).toList();
    } catch (e) {
      print('Erro ao obter estados: $e');
      // Fallback para dados mockados se houver erro
      return _estados;
    }
  }

  /// Obtém as cidades de um estado específico
  Future<List<CidadeModel>> obterCidadesPorEstado(String estadoSigla) async {
    try {
      // Usa o SupabaseService para buscar cidades do estado que têm condomínios
      final cidades = await SupabaseService.getCidadesFromCondominios(uf: estadoSigla);
      
      // Converte para CidadeModel
      return cidades.asMap().entries.map((entry) {
        return CidadeModel(
          id: entry.key + 1,
          nome: entry.value,
          estadoSigla: estadoSigla,
        );
      }).toList();
    } catch (e) {
      print('Erro ao obter cidades: $e');
      // Fallback para dados mockados se houver erro
      return _cidadesPorEstado[estadoSigla] ?? [];
    }
  }

  /// Obtém a lista completa de condomínios do Supabase
  Future<List<CondominioModel>> obterCondominios() async {
    try {
      // Busca todos os condomínios do Supabase
      final condominios = await SupabaseService.getCondominios();
      
      // Converte para CondominioModel
      return condominios.map((cond) {
        final cidade = cond['cidade'] as String? ?? '';
        final estado = cond['estado'] as String? ?? '';
        final localizacao = estado.isNotEmpty ? '$cidade/$estado' : cidade;
        
        return CondominioModel(
          id: cond['id'] as String,
          nome: cond['nome_condominio'] as String? ?? 'Sem nome',
          localizacao: localizacao,
        );
      }).toList();
    } catch (e) {
      print('Erro ao obter condomínios do Supabase: $e');
      return [];
    }
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
