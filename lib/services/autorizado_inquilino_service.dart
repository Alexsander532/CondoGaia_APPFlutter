import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/autorizado_inquilino.dart';
import 'supabase_service.dart';

class AutorizadoInquilinoService {
  static SupabaseClient get _client => SupabaseService.client;

  /// Busca todos os autorizados de uma unidade específica
  static Future<List<AutorizadoInquilino>> getAutorizadosByUnidade(
    String unidadeId,
  ) async {
    try {
      final response = await _client
          .from('autorizados_inquilinos')
          .select()
          .eq('unidade_id', unidadeId)
          .eq('ativo', true)
          .order('created_at', ascending: false);

      return response
          .map<AutorizadoInquilino>(
            (json) => AutorizadoInquilino.fromJson(json),
          )
          .toList();
    } catch (e) {
      print('Erro ao buscar autorizados da unidade: $e');
      rethrow;
    }
  }

  /// Busca todos os autorizados de um inquilino específico
  static Future<List<AutorizadoInquilino>> getAutorizadosByInquilino(
    String inquilinoId,
  ) async {
    try {
      final response = await _client
          .from('autorizados_inquilinos')
          .select()
          .eq('inquilino_id', inquilinoId)
          .eq('ativo', true)
          .order('created_at', ascending: false);

      return response
          .map<AutorizadoInquilino>(
            (json) => AutorizadoInquilino.fromJson(json),
          )
          .toList();
    } catch (e) {
      print('Erro ao buscar autorizados do inquilino: $e');
      rethrow;
    }
  }

  /// Busca todos os autorizados de um proprietário específico
  static Future<List<AutorizadoInquilino>> getAutorizadosByProprietario(
    String proprietarioId,
  ) async {
    try {
      final response = await _client
          .from('autorizados_inquilinos')
          .select()
          .eq('proprietario_id', proprietarioId)
          .eq('ativo', true)
          .order('created_at', ascending: false);

      return response
          .map<AutorizadoInquilino>(
            (json) => AutorizadoInquilino.fromJson(json),
          )
          .toList();
    } catch (e) {
      print('Erro ao buscar autorizados do proprietário: $e');
      rethrow;
    }
  }

  /// Busca todos os autorizados de um condomínio agrupados por unidade para representantes
  static Future<Map<String, List<Map<String, dynamic>>>>
  getAutorizadosAgrupadosPorUnidade(String condominioId) async {
    try {
      print(
        '🔍 DEBUG SERVICE: Buscando autorizados para condomínio: $condominioId',
      );

      final response = await _client
          .from('autorizados_inquilinos')
          .select('''
            id,
            nome,
            cpf,
            parentesco,
            horario_inicio,
            horario_fim,
            dias_semana_permitidos,
            veiculo_marca,
            veiculo_modelo,
            veiculo_placa,
            foto_url,
            unidades!inner(
              id,
              numero,
              bloco,
              condominio_id
            ),
            inquilinos(
              id,
              nome
            ),
            proprietarios(
              id,
              nome
            )
          ''')
          .eq('unidades.condominio_id', condominioId)
          .eq('ativo', true)
          .order('created_at', ascending: false);

      print(
        '🔍 DEBUG SERVICE: Response recebido: ${response.length} registros',
      );
      print('🔍 DEBUG SERVICE: Primeiro item (verificando foto_url): ${response.isNotEmpty ? response.first : 'vazio'}');

      Map<String, List<Map<String, dynamic>>> autorizadosPorUnidade = {};

      for (var item in response) {
        final unidade = item['unidades'];
        final inquilino = item['inquilinos'];
        final proprietario = item['proprietarios'];

        // Criar chave da unidade (Bloco/Número ou apenas Número)
        String chaveUnidade;
        if (unidade['bloco'] != null &&
            unidade['bloco'].toString().isNotEmpty) {
          chaveUnidade = 'Bloco ${unidade['bloco']} - ${unidade['numero']}';
        } else {
          chaveUnidade = unidade['numero'].toString();
        }

        // Determinar o nome do criador (inquilino ou proprietário)
        String nomeCriador = 'N/A';
        if (inquilino != null && inquilino['nome'] != null) {
          nomeCriador = inquilino['nome'];
        } else if (proprietario != null && proprietario['nome'] != null) {
          nomeCriador = proprietario['nome'];
        }

        // Formatar dias da semana
        String diasFormatados = 'Todos os dias';
        if (item['dias_semana_permitidos'] != null) {
          List<int> dias = List<int>.from(item['dias_semana_permitidos']);
          List<String> nomesDias = [];
          for (int dia in dias) {
            switch (dia) {
              case 1:
                nomesDias.add('Dom');
                break;
              case 2:
                nomesDias.add('Seg');
                break;
              case 3:
                nomesDias.add('Ter');
                break;
              case 4:
                nomesDias.add('Qua');
                break;
              case 5:
                nomesDias.add('Qui');
                break;
              case 6:
                nomesDias.add('Sex');
                break;
              case 7:
                nomesDias.add('Sáb');
                break;
            }
          }
          if (nomesDias.isNotEmpty) {
            diasFormatados = nomesDias.join(', ');
          }
        }

        // Formatar horários
        String horariosFormatados = '24h';
        if (item['horario_inicio'] != null && item['horario_fim'] != null) {
          horariosFormatados =
              '${item['horario_inicio']} - ${item['horario_fim']}';
        }

        // Obter os 3 primeiros dígitos do CPF
        String cpfTresPrimeiros = '';
        if (item['cpf'] != null && item['cpf'].toString().length >= 3) {
          cpfTresPrimeiros = item['cpf'].toString().substring(0, 3);
        }

        Map<String, dynamic> autorizadoFormatado = {
          'id': item['id'],
          'nome': item['nome'] ?? 'N/A',
          'cpfTresPrimeiros': cpfTresPrimeiros,
          'nomeCriador': nomeCriador,
          'diasHorarios': '$diasFormatados • $horariosFormatados',
          'parentesco': item['parentesco'] ?? '',
          'criado_por': nomeCriador, // Adicionando campo criado_por
          'dias_permitidos':
              diasFormatados, // Adicionando campo dias_permitidos
          'veiculo': item['veiculo_placa'] != null
              ? '${item['veiculo_marca'] ?? ''} ${item['veiculo_modelo'] ?? ''} - ${item['veiculo_placa']}'
                    .trim()
              : null,
          'foto_url': item['foto_url'], // Adicionando foto do autorizado
        };

        // Debug: Verificar se foto_url foi corretamente adicionada
        if (item['foto_url'] != null && (item['foto_url'] as String).isNotEmpty) {
          print('✅ Foto do autorizado ${item['nome']}: ${item['foto_url']}');
        }

        print(
          '🔍 DEBUG SERVICE: Autorizado ${item['nome']} - foto_url: ${item['foto_url']}',
        );

        if (!autorizadosPorUnidade.containsKey(chaveUnidade)) {
          autorizadosPorUnidade[chaveUnidade] = [];
        }
        autorizadosPorUnidade[chaveUnidade]!.add(autorizadoFormatado);
      }

      print(
        '🔍 DEBUG SERVICE: Resultado final: ${autorizadosPorUnidade.length} unidades agrupadas',
      );
      print(
        '🔍 DEBUG SERVICE: Chaves das unidades: ${autorizadosPorUnidade.keys.toList()}',
      );

      return autorizadosPorUnidade;
    } catch (e) {
      print('❌ ERRO SERVICE ao buscar autorizados agrupados por unidade: $e');
      rethrow;
    }
  }

  /// Busca um autorizado específico pelo ID
  static Future<AutorizadoInquilino?> getAutorizadoById(String id) async {
    try {
      final response = await _client
          .from('autorizados_inquilinos')
          .select()
          .eq('id', id)
          .single();

      return AutorizadoInquilino.fromJson(response);
    } catch (e) {
      print('Erro ao buscar autorizado por ID: $e');
      return null;
    }
  }

  /// Insere um novo autorizado
  static Future<AutorizadoInquilino?> insertAutorizado(
    Map<String, dynamic> autorizadoData,
  ) async {
    try {
      // Validações básicas
      if (!_validarDadosObrigatorios(autorizadoData)) {
        throw Exception('Dados obrigatórios não fornecidos');
      }

      if (!_validarCPF(autorizadoData['cpf'])) {
        throw Exception('CPF inválido');
      }

      if (!_validarVinculo(autorizadoData)) {
        throw Exception(
          'Autorizado deve estar vinculado a um inquilino OU proprietário',
        );
      }

      // Validar se já existe autorizado com mesmo CPF na unidade
      final cpfExistente = await _verificarCPFExistente(
        autorizadoData['cpf'],
        autorizadoData['unidade_id'],
      );

      if (cpfExistente) {
        throw Exception('Já existe um autorizado com este CPF nesta unidade');
      }

      final response = await _client
          .from('autorizados_inquilinos')
          .insert(autorizadoData)
          .select()
          .single();

      return AutorizadoInquilino.fromJson(response);
    } catch (e) {
      print('Erro ao inserir autorizado: $e');
      rethrow;
    }
  }

  /// Atualiza um autorizado existente
  static Future<AutorizadoInquilino?> updateAutorizado(
    String id,
    Map<String, dynamic> autorizadoData,
  ) async {
    try {
      // Validações básicas
      if (autorizadoData.containsKey('cpf') &&
          !_validarCPF(autorizadoData['cpf'])) {
        throw Exception('CPF inválido');
      }

      // Adicionar timestamp de atualização
      autorizadoData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .from('autorizados_inquilinos')
          .update(autorizadoData)
          .eq('id', id)
          .select()
          .single();

      return AutorizadoInquilino.fromJson(response);
    } catch (e) {
      print('Erro ao atualizar autorizado: $e');
      rethrow;
    }
  }

  /// Remove um autorizado (soft delete - marca como inativo)
  static Future<bool> deleteAutorizado(String id) async {
    try {
      await _client
          .from('autorizados_inquilinos')
          .update({
            'ativo': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);

      return true;
    } catch (e) {
      print('Erro ao remover autorizado: $e');
      return false;
    }
  }

  /// Remove um autorizado permanentemente (hard delete)
  static Future<bool> deleteAutorizadoPermanente(String id) async {
    try {
      await _client.from('autorizados_inquilinos').delete().eq('id', id);

      return true;
    } catch (e) {
      print('Erro ao remover autorizado permanentemente: $e');
      return false;
    }
  }

  /// Busca autorizados por nome (busca parcial)
  static Future<List<AutorizadoInquilino>> searchAutorizadosByNome(
    String unidadeId,
    String nome,
  ) async {
    try {
      final response = await _client
          .from('autorizados_inquilinos')
          .select()
          .eq('unidade_id', unidadeId)
          .eq('ativo', true)
          .ilike('nome', '%$nome%')
          .order('nome', ascending: true);

      return response
          .map<AutorizadoInquilino>(
            (json) => AutorizadoInquilino.fromJson(json),
          )
          .toList();
    } catch (e) {
      print('Erro ao buscar autorizados por nome: $e');
      rethrow;
    }
  }

  /// Busca autorizados por CPF
  static Future<List<AutorizadoInquilino>> searchAutorizadosByCPF(
    String unidadeId,
    String cpf,
  ) async {
    try {
      final response = await _client
          .from('autorizados_inquilinos')
          .select()
          .eq('unidade_id', unidadeId)
          .eq('ativo', true)
          .eq('cpf', cpf);

      return response
          .map<AutorizadoInquilino>(
            (json) => AutorizadoInquilino.fromJson(json),
          )
          .toList();
    } catch (e) {
      print('Erro ao buscar autorizados por CPF: $e');
      rethrow;
    }
  }

  /// Reativa um autorizado inativo
  static Future<AutorizadoInquilino?> reativarAutorizado(String id) async {
    try {
      final response = await _client
          .from('autorizados_inquilinos')
          .update({
            'ativo': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();

      return AutorizadoInquilino.fromJson(response);
    } catch (e) {
      print('Erro ao reativar autorizado: $e');
      rethrow;
    }
  }

  /// Faz upload da foto do autorizado para Supabase Storage
  /// Retorna a URL pública da foto ou null se falhar
  static Future<String?> uploadFotoAutorizado({
    required String condominioId,
    required String unidadeId,
    required dynamic arquivo,
    required String nomeArquivo,
  }) async {
    try {
      print('📸 Iniciando upload de foto para autorizado...');
      print('   - Condomínio: $condominioId');
      print('   - Unidade: $unidadeId');
      print('   - Arquivo: $nomeArquivo');

      late Uint8List bytes;
      
      // Tentar obter bytes de forma compatível com web e mobile
      if (arquivo is File) {
        // Mobile/Desktop
        bytes = Uint8List.fromList(await arquivo.readAsBytes());
      } else {
        // Web ou XFile (universal)
        try {
          final bytesLista = await arquivo.readAsBytes();
          bytes = Uint8List.fromList(bytesLista);
        } catch (e) {
          throw Exception('Não foi possível ler o arquivo: $e');
        }
      }

      // Caminho no storage: condominio_id/unidade_id/nomeArquivo
      final caminhoStorage = '$condominioId/$unidadeId/$nomeArquivo';

      // Fazer upload para o bucket 'visitante_adicionado_pelo_inquilino' usando uploadBinary
      await _client.storage
          .from('visitante_adicionado_pelo_inquilino')
          .uploadBinary(
            caminhoStorage,
            bytes,
          );

      print('✅ Upload realizado com sucesso: $caminhoStorage');

      // Gerar URL pública
      final urlPublica = _client.storage
          .from('visitante_adicionado_pelo_inquilino')
          .getPublicUrl(caminhoStorage);

      print('🔗 URL Pública: $urlPublica');
      return urlPublica;
    } catch (e) {
      print('❌ Erro ao fazer upload de foto: $e');
      rethrow;
    }
  }

  // MÉTODOS PRIVADOS DE VALIDAÇÃO

  /// Valida se os dados obrigatórios foram fornecidos
  static bool _validarDadosObrigatorios(Map<String, dynamic> data) {
    return data.containsKey('unidade_id') &&
        data.containsKey('nome') &&
        data.containsKey('cpf') &&
        data['unidade_id'] != null &&
        data['nome'] != null &&
        data['cpf'] != null &&
        data['nome'].toString().trim().isNotEmpty &&
        data['cpf'].toString().trim().isNotEmpty;
  }

  /// Valida se o autorizado está vinculado a um inquilino OU proprietário
  static bool _validarVinculo(Map<String, dynamic> data) {
    final temInquilino =
        data.containsKey('inquilino_id') && data['inquilino_id'] != null;
    final temProprietario =
        data.containsKey('proprietario_id') && data['proprietario_id'] != null;

    // Deve ter um OU outro, mas não ambos
    return (temInquilino && !temProprietario) ||
        (!temInquilino && temProprietario);
  }

  /// Valida formato básico do CPF
  static bool _validarCPF(String cpf) {
    if (cpf.isEmpty) return false;

    // Remove caracteres não numéricos
    final cpfLimpo = cpf.replaceAll(RegExp(r'[^0-9]'), '');

    // Verifica se tem 11 dígitos
    if (cpfLimpo.length != 11) return false;

    // Verifica se não são todos os dígitos iguais
    if (RegExp(r'^(\d)\1{10}$').hasMatch(cpfLimpo)) return false;

    return true;
  }

  /// Verifica se já existe um autorizado com o mesmo CPF na unidade
  static Future<bool> _verificarCPFExistente(
    String cpf,
    String unidadeId,
  ) async {
    try {
      final response = await _client
          .from('autorizados_inquilinos')
          .select('id')
          .eq('unidade_id', unidadeId)
          .eq('cpf', cpf)
          .eq('ativo', true);

      return response.isNotEmpty;
    } catch (e) {
      print('Erro ao verificar CPF existente: $e');
      return false;
    }
  }

  /// Valida formato da placa do veículo (formato brasileiro)
  static bool validarPlaca(String? placa) {
    if (placa == null || placa.isEmpty) return true; // Placa é opcional

    final placaLimpa = placa
        .replaceAll(RegExp(r'[^A-Za-z0-9]'), '')
        .toUpperCase();

    // Formato antigo: ABC1234
    final formatoAntigo = RegExp(r'^[A-Z]{3}[0-9]{4}$');

    // Formato Mercosul: ABC1D23
    final formatoMercosul = RegExp(r'^[A-Z]{3}[0-9][A-Z][0-9]{2}$');

    return formatoAntigo.hasMatch(placaLimpa) ||
        formatoMercosul.hasMatch(placaLimpa);
  }

  /// Valida formato do horário (HH:MM)
  static bool validarHorario(String? horario) {
    if (horario == null || horario.isEmpty) return true; // Horário é opcional

    final regex = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$');
    return regex.hasMatch(horario);
  }

  /// Valida se os dias da semana estão no intervalo correto (0-6)
  static bool validarDiasSemana(List<int>? dias) {
    if (dias == null || dias.isEmpty) return true; // Dias são opcionais

    return dias.every((dia) => dia >= 0 && dia <= 6);
  }
}