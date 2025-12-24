import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../models/ambiente.dart';
import '../utils/formatters.dart';
import 'supabase_service.dart';

class AmbienteService {
  /// Buscar todos os ambientes ativos
  /// Nota: Como a tabela não tem condominio_id nem ativo, buscaremos todos os ambientes
  static Future<List<Ambiente>> getAmbientes() async {
    try {
      final response = await SupabaseService.client
          .from('ambientes')
          .select()
          .order('titulo');
      
      return response.map((json) => Ambiente.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar ambientes: $e');
    }
  }

  /// Buscar um ambiente específico por ID
  static Future<Ambiente?> getAmbiente(String ambienteId) async {
    try {
      final response = await SupabaseService.client
          .from('ambientes')
          .select()
          .eq('id', ambienteId)
          .single();
      
      return Ambiente.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Criar um novo ambiente
  static Future<Ambiente> criarAmbiente({
    required String titulo,
    String? descricao,
    required double valor,
    String? limiteHorario,
    String? limiteTempoDuracao,
    String? diasBloqueados,
    bool inadimplentePodemReservar = false,
    String? createdBy,
    String? fotoUrl,
    String? locacaoUrl,
  }) async {
    try {
      final ambiente = Ambiente(
        titulo: titulo,
        descricao: descricao,
        valor: valor,
        limiteHorario: limiteHorario,
        limiteTempoDuracao: limiteTempoDuracao,
        diasBloqueados: diasBloqueados,
        inadimplentePodemReservar: inadimplentePodemReservar,
        createdBy: createdBy,
        fotoUrl: fotoUrl,
        locacaoUrl: locacaoUrl,
      );

      final response = await SupabaseService.client
          .from('ambientes')
          .insert(ambiente.toJson())
          .select()
          .single();
      
      return Ambiente.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao criar ambiente: $e');
    }
  }

  /// Atualizar um ambiente existente
  static Future<Ambiente> atualizarAmbiente(
    String ambienteId, {
    String? titulo,
    String? descricao,
    double? valor,
    String? limiteHorario,
    String? limiteTempoDuracao,
    String? diasBloqueados,
    bool? inadimplentePodemReservar,
    String? updatedBy,
    String? fotoUrl,
    String? locacaoUrl,
    bool? removerLocacao, // Flag para indicar que deve remover o termo
  }) async {
    try {
      final dados = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      if (titulo != null) dados['titulo'] = titulo;
      if (descricao != null) dados['descricao'] = descricao;
      if (valor != null) dados['valor'] = valor;
      if (limiteHorario != null) dados['limite_horario'] = limiteHorario;
      if (limiteTempoDuracao != null) dados['limite_tempo_duracao'] = limiteTempoDuracao;
      if (diasBloqueados != null) dados['dias_bloqueados'] = diasBloqueados;
      if (inadimplentePodemReservar != null) dados['inadiplente_podem_assinar'] = inadimplentePodemReservar;
      if (updatedBy != null) dados['updated_by'] = updatedBy;
      if (fotoUrl != null) dados['foto_url'] = fotoUrl;
      
      // Se removerLocacao é true, define como null explicitamente
      // Caso contrário, só atualiza se locacaoUrl não for null
      if (removerLocacao == true) {
        dados['locacao_url'] = null;
      } else if (locacaoUrl != null) {
        dados['locacao_url'] = locacaoUrl;
      }

      final response = await SupabaseService.client
          .from('ambientes')
          .update(dados)
          .eq('id', ambienteId)
          .select()
          .single();
      
      return Ambiente.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao atualizar ambiente: $e');
    }
  }

  /// Deletar um ambiente permanentemente
  /// Nota: Como não há campo 'ativo', implementamos delete real
  static Future<bool> deletarAmbiente(String ambienteId) async {
    try {
      await SupabaseService.client
          .from('ambientes')
          .delete()
          .eq('id', ambienteId);
      
      return true;
    } catch (e) {
      throw Exception('Erro ao deletar ambiente: $e');
    }
  }

  /// Método mantido para compatibilidade (agora faz delete real)
  static Future<bool> desativarAmbiente(String ambienteId, {String? atualizadoPor}) async {
    return await deletarAmbiente(ambienteId);
  }

  /// Verificar se um ambiente pode ser reservado
  static Future<bool> podeReservar(String ambienteId, {bool? inadimplente}) async {
    try {
      final ambiente = await getAmbiente(ambienteId);
      if (ambiente == null) return false;
      
      // Se o usuário é inadimplente, verificar se inadimplentes podem reservar
      if (inadimplente == true && !ambiente.inadimplentePodemReservar) {
        return false;
      }
      
      return true; // Ambiente existe, pode reservar
    } catch (e) {
      return false;
    }
  }

  /// Verificar se um dia da semana está bloqueado para um ambiente
  static Future<bool> isDiaBloqueado(String ambienteId, dynamic dia) async {
    try {
      final ambiente = await getAmbiente(ambienteId);
      if (ambiente == null) return true;
      
      return ambiente.diasBloqueados?.contains(dia) ?? true;
    } catch (e) {
      return true;
    }
  }

  /// Buscar ambientes disponíveis para reserva
  static Future<List<Ambiente>> getAmbientesDisponiveis({bool? inadimplente}) async {
    try {
      final ambientes = await getAmbientes();
      
      if (inadimplente == true) {
        // Filtrar apenas ambientes que permitem inadimplentes
        return ambientes.where((ambiente) => ambiente.inadimplentePodemReservar).toList();
      }
      
      return ambientes;
    } catch (e) {
      throw Exception('Erro ao buscar ambientes disponíveis: $e');
    }
  }

  /// Buscar ambientes por título (busca parcial)
  static Future<List<Ambiente>> buscarAmbientesPorTitulo(String termo) async {
    try {
      final response = await SupabaseService.client
          .from('ambientes')
          .select()
          .ilike('titulo', '%$termo%')
          .order('titulo');
      
      return response.map((json) => Ambiente.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar ambientes por título: $e');
    }
  }

  /// Buscar ambientes por faixa de valor
  static Future<List<Ambiente>> buscarAmbientesPorValor({
    double? valorMinimo,
    double? valorMaximo,
  }) async {
    try {
      var query = SupabaseService.client.from('ambientes').select();
      
      if (valorMinimo != null) {
        query = query.gte('valor', valorMinimo);
      }
      
      if (valorMaximo != null) {
        query = query.lte('valor', valorMaximo);
      }
      
      final response = await query.order('valor');
      
      return response.map((json) => Ambiente.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar ambientes por valor: $e');
    }
  }

  /// Upload de foto para ambiente
  /// Aceita File (mobile) ou XFile (web)
  static Future<String?> uploadFotoAmbiente(dynamic arquivo) async {
    try {
      if (arquivo == null) return null;

      // Obter bytes da imagem (funciona tanto para File quanto XFile)
      late final Uint8List bytes;
      late final String nomeArquivo;

      if (arquivo is File) {
        bytes = Uint8List.fromList(await arquivo.readAsBytes());
        nomeArquivo = arquivo.path.split('/').last;
      } else if (arquivo is XFile) {
        bytes = Uint8List.fromList(await arquivo.readAsBytes());
        nomeArquivo = arquivo.name;
      } else {
        throw Exception('Tipo de arquivo não suportado');
      }

      // Gerar nome único para o arquivo
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final nomeUnico = 'ambiente_${timestamp}_$nomeArquivo';

      // Fazer upload para o bucket
      await SupabaseService.client.storage
          .from('imagens_ambientes_representante')
          .uploadBinary(nomeUnico, bytes);

      // Obter URL pública
      final urlPublica = SupabaseService.client.storage
          .from('imagens_ambientes_representante')
          .getPublicUrl(nomeUnico);

      return urlPublica;
    } catch (e) {
      print('Erro ao fazer upload de foto do ambiente: $e');
      return null;
    }
  }

  /// Deletar foto do ambiente
  static Future<bool> deletarFotoAmbiente(String fotoUrl) async {
    try {
      if (fotoUrl.isEmpty) return false;

      // Extrair o nome do arquivo da URL
      final uri = Uri.parse(fotoUrl);
      final pathSegments = uri.pathSegments;
      if (pathSegments.length < 2) return false;

      final nomeArquivo = pathSegments.last;

      // Deletar do storage
      await SupabaseService.client.storage
          .from('imagens_ambientes_representante')
          .remove([nomeArquivo]);

      return true;
    } catch (e) {
      print('Erro ao deletar foto do ambiente: $e');
      return false;
    }
  }

  /// Upload de PDF do termo de locação para ambiente
  /// Aceita File (mobile), XFile (image_picker) ou PlatformFile (file_picker)
  static Future<String?> uploadLocacaoPdfAmbiente(dynamic arquivo, {required String nomeArquivo}) async {
    try {
      if (arquivo == null) return null;

      // Obter bytes do PDF (funciona para File, XFile e PlatformFile)
      late final Uint8List bytes;

      if (arquivo is File) {
        bytes = Uint8List.fromList(await arquivo.readAsBytes());
      } else if (arquivo is XFile) {
        bytes = Uint8List.fromList(await arquivo.readAsBytes());
      } else if (arquivo is PlatformFile) {
        // PlatformFile tem o campo 'bytes' direto
        if (arquivo.bytes != null) {
          bytes = arquivo.bytes!;
        } else if (arquivo.path != null) {
          // Se não tiver bytes, ler do arquivo no disco (mobile)
          bytes = Uint8List.fromList(await File(arquivo.path!).readAsBytes());
        } else {
          throw Exception('PlatformFile sem bytes ou path');
        }
      } else {
        throw Exception('Tipo de arquivo não suportado: ${arquivo.runtimeType}');
      }

      // Sanitizar nome do arquivo para remover caracteres especiais
      final nomeArquivoSanitizado = Formatters.sanitizeFileName(nomeArquivo);

      // Gerar nome único para o arquivo
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final nomeUnico = 'locacao_${timestamp}_$nomeArquivoSanitizado';

      // Fazer upload para o bucket Termo_Locacao_Ambiente
      await SupabaseService.client.storage
          .from('Termo_Locacao_Ambiente')
          .uploadBinary(nomeUnico, bytes);

      // Obter URL pública
      final urlPublica = SupabaseService.client.storage
          .from('Termo_Locacao_Ambiente')
          .getPublicUrl(nomeUnico);

      return urlPublica;
    } catch (e) {
      print('Erro ao fazer upload do PDF de locação: $e');
      rethrow; // Relançar a exceção para o caller
    }
  }

  /// Deletar PDF do termo de locação do ambiente
  static Future<bool> deletarLocacaoPdfAmbiente(String locacaoUrl) async {
    try {
      if (locacaoUrl.isEmpty) return false;

      // Extrair o nome do arquivo da URL
      final uri = Uri.parse(locacaoUrl);
      final pathSegments = uri.pathSegments;
      if (pathSegments.length < 2) return false;

      final nomeArquivo = pathSegments.last;

      // Deletar do storage
      await SupabaseService.client.storage
          .from('Termo_Locacao_Ambiente')
          .remove([nomeArquivo]);

      return true;
    } catch (e) {
      print('Erro ao deletar PDF de locação: $e');
      return false;
    }
  }
}