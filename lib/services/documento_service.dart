import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/documento.dart';
import '../models/balancete.dart';
import 'supabase_service.dart';

class DocumentoService {
  /// Criar uma nova pasta
  static Future<Documento> criarPasta({
    required String nome,
    String? descricao,
    required bool privado,
    required String condominioId,
    required String representanteId,
  }) async {
    final response = await SupabaseService.criarPastaDocumento(
      nome: nome,
      descricao: descricao,
      privado: privado,
      condominioId: condominioId,
      representanteId: representanteId,
    );
    
    if (response != null) {
      return Documento.fromJson(response);
    }
    
    throw Exception('Erro ao criar pasta');
  }
  
  /// Buscar todas as pastas de um condomínio
  static Future<List<Documento>> getPastas(String condominioId) async {
    print('📂 DocumentoService.getPastas() chamado com condominioId: $condominioId');
    final response = await SupabaseService.getPastasDocumentos(condominioId);
    print('📂 Resposta do SupabaseService: ${response.length} itens');
    final pastas = response.map((json) => Documento.fromJson(json)).toList();
    print('📂 Pastas parseadas: ${pastas.length}');
    return pastas;
  }

  /// Buscar todas as pastas (públicas + privadas) - para REPRESENTANTE
  static Future<List<Documento>> getPastasRepresentante(String condominioId) async {
    print('📂 DocumentoService.getPastasRepresentante() chamado com condominioId: $condominioId');
    final response = await SupabaseService.getPastasDocumentosRepresentante(condominioId);
    print('📂 Resposta do SupabaseService: ${response.length} itens');
    final pastas = response.map((json) => Documento.fromJson(json)).toList();
    print('📂 Pastas parseadas: ${pastas.length}');
    return pastas;
  }
  
  /// Atualizar uma pasta
  static Future<Documento> atualizarPasta(
    String pastaId,
    {String? nome, String? descricao, bool? privado}
  ) async {
    final dados = <String, dynamic>{};
    if (nome != null) dados['nome'] = nome;
    if (descricao != null) dados['descricao'] = descricao;
    if (privado != null) dados['privado'] = privado;
    
    final response = await SupabaseService.atualizarPastaDocumento(pastaId, dados);
    
    if (response != null) {
      return Documento.fromJson(response);
    }
    
    throw Exception('Erro ao atualizar pasta');
  }
  
  /// Deletar uma pasta
  static Future<void> deletarPasta(String pastaId) async {
    await SupabaseService.deletarPastaDocumento(pastaId);
  }
  
  /// Adicionar arquivo com upload
  static Future<Documento> adicionarArquivoComUpload({
    required String nome,
    required File arquivo,
    String? descricao,
    required bool privado,
    required String pastaId,
    required String condominioId,
    required String representanteId,
  }) async {
    final url = await SupabaseService.uploadArquivoDocumento(
      arquivo,
      nome,
      condominioId,
    );
    
    if (url == null) {
      throw Exception('Erro ao fazer upload do arquivo');
    }
    
    final response = await SupabaseService.adicionarArquivoDocumento(
      nome: nome,
      descricao: descricao,
      url: url,
      privado: privado,
      pastaId: pastaId,
      condominioId: condominioId,
      representanteId: representanteId,
    );
    
    if (response != null) {
      return Documento.fromJson(response);
    }
    
    throw Exception('Erro ao adicionar arquivo');
  }

  /// Adicionar arquivo com upload usando bytes diretamente (compatível com web)
  static Future<Documento> adicionarArquivoComUploadBytes({
    required String nome,
    required Uint8List bytes,
    String? descricao,
    required bool privado,
    required String pastaId,
    required String condominioId,
    required String representanteId,
  }) async {
    final url = await SupabaseService.uploadArquivoDocumentoBytes(
      bytes,
      nome,
      condominioId,
    );
    
    if (url == null) {
      throw Exception('Erro ao fazer upload do arquivo');
    }
    
    final response = await SupabaseService.adicionarArquivoDocumento(
      nome: nome,
      descricao: descricao,
      url: url,
      privado: privado,
      pastaId: pastaId,
      condominioId: condominioId,
      representanteId: representanteId,
    );
    
    if (response != null) {
      return Documento.fromJson(response);
    }
    
    throw Exception('Erro ao adicionar arquivo');
  }
  
  /// Adicionar arquivo com link externo
  static Future<Documento> adicionarArquivoComLink({
    required String nome,
    required String linkExterno,
    String? descricao,
    required bool privado,
    required String pastaId,
    required String condominioId,
    required String representanteId,
  }) async {
    final response = await SupabaseService.adicionarArquivoDocumento(
      nome: nome,
      descricao: descricao,
      linkExterno: linkExterno,
      privado: privado,
      pastaId: pastaId,
      condominioId: condominioId,
      representanteId: representanteId,
    );
    
    if (response != null) {
      return Documento.fromJson(response);
    }
    
    throw Exception('Erro ao adicionar arquivo com link');
  }
  
  /// Buscar arquivos de uma pasta
  static Future<List<Documento>> getArquivosDaPasta(String pastaId) async {
    print('📄 DocumentoService.getArquivosDaPasta() chamado com pastaId: $pastaId');
    final response = await SupabaseService.getArquivosPasta(pastaId);
    print('📄 Resposta do SupabaseService: ${response.length} itens');
    final documentos = response.map((json) => Documento.fromJson(json)).toList();
    print('📄 Documentos parseados: ${documentos.length}');
    return documentos;
  }
  
  /// Atualizar um arquivo/documento
  static Future<Documento> atualizarDocumento(
    String arquivoId,
    {String? nome, String? descricao}
  ) async {
    final dados = <String, dynamic>{};
    if (nome != null) dados['nome'] = nome;
    if (descricao != null) dados['descricao'] = descricao;
    
    final response = await SupabaseService.atualizarArquivoDocumento(arquivoId, dados);
    
    if (response != null) {
      return Documento.fromJson(response);
    }
    
    throw Exception('Erro ao atualizar documento');
  }

  /// Deletar um arquivo
  static Future<void> deletarArquivo(String arquivoId) async {
    await SupabaseService.deletarArquivoDocumento(arquivoId);
  }
  
  /// Buscar balancetes de um condomínio
  static Future<List<Balancete>> getBalancetes(String condominioId) async {
    final response = await SupabaseService.getBalancetes(condominioId);
    return response.map((json) => Balancete.fromJson(json)).toList();
  }
  
  /// Buscar balancetes por período específico
  static Future<List<Balancete>> getBalancetesPorPeriodo(
    String condominioId,
    int mes,
    int ano,
  ) async {
    final response = await SupabaseService.getBalancetesPorPeriodo(
      condominioId,
      mes.toString(),
      ano.toString(),
    );
    return response.map((json) => Balancete.fromJson(json)).toList();
  }
  
  /// Adicionar balancete com link
  static Future<Balancete> adicionarBalancete({
    required String nomeArquivo,
    String? linkExterno,
    required String mes,
    required String ano,
    required bool privado,
    required String condominioId,
    required String representanteId,
  }) async {
    final response = await SupabaseService.adicionarBalancete(
      nomeArquivo: nomeArquivo,
      linkExterno: linkExterno,
      mes: mes,
      ano: ano,
      privado: privado,
      condominioId: condominioId,
      representanteId: representanteId,
    );
    
    if (response != null) {
      return Balancete.fromJson(response);
    }
    
    throw Exception('Erro ao adicionar balancete');
  }

  /// Download de arquivo para o dispositivo (imagens e PDFs)
  static Future<String?> downloadArquivo(String url, String nomeArquivo) async {
    try {
      // Verificar se é um arquivo suportado (imagem ou PDF)
      if (!_isImageFile(nomeArquivo) && !_isPDF(nomeArquivo)) {
        throw Exception('Download permitido apenas para imagens (JPG, JPEG, PNG, GIF, BMP, WEBP) e PDFs');
      }

      // Para Android 13+, usar downloads sem permissão (via pasta app ou cache)
      if (Platform.isAndroid) {
        try {
          // Tentar Download público primeiro (sem permissão em Android 13+)
          final downloadsDir = Directory('/storage/emulated/0/Download');
          
          if (await downloadsDir.exists()) {
            String fileName = nomeArquivo;
            String filePath = '${downloadsDir.path}/$fileName';
            int counter = 1;
            
            while (await File(filePath).exists()) {
              final extension = fileName.split('.').last;
              final nameWithoutExtension = fileName.replaceAll('.$extension', '');
              fileName = '${nameWithoutExtension}_$counter.$extension';
              filePath = '${downloadsDir.path}/$fileName';
              counter++;
            }

            // Fazer download usando Dio
            final dio = Dio();
            await dio.download(url, filePath);
            print('✅ Download concluído: $filePath');
            return filePath;
          }
        } catch (e) {
          print('⚠️ Erro ao salvar em Downloads público: $e');
          // Continua para fallback
        }
        
        // Fallback: usar pasta de aplicação (não precisa permissão)
        final appDir = await getApplicationDocumentsDirectory();
        final downloadSubDir = Directory('${appDir.path}/Downloads');
        if (!await downloadSubDir.exists()) {
          await downloadSubDir.create(recursive: true);
        }

        String fileName = nomeArquivo;
        String filePath = '${downloadSubDir.path}/$fileName';
        int counter = 1;
        
        while (await File(filePath).exists()) {
          final extension = fileName.split('.').last;
          final nameWithoutExtension = fileName.replaceAll('.$extension', '');
          fileName = '${nameWithoutExtension}_$counter.$extension';
          filePath = '${downloadSubDir.path}/$fileName';
          counter++;
        }

        final dio = Dio();
        await dio.download(url, filePath);
        print('✅ Download concluído (pasta app): $filePath');
        return filePath;
      }

      // iOS: sempre usar documents
      if (Platform.isIOS) {
        final downloadsDir = await getApplicationDocumentsDirectory();
        final downloadSubDir = Directory('${downloadsDir.path}/Downloads');
        if (!await downloadSubDir.exists()) {
          await downloadSubDir.create(recursive: true);
        }

        String fileName = nomeArquivo;
        String filePath = '${downloadSubDir.path}/$fileName';
        int counter = 1;
        
        while (await File(filePath).exists()) {
          final extension = fileName.split('.').last;
          final nameWithoutExtension = fileName.replaceAll('.$extension', '');
          fileName = '${nameWithoutExtension}_$counter.$extension';
          filePath = '${downloadSubDir.path}/$fileName';
          counter++;
        }

        final dio = Dio();
        await dio.download(url, filePath);
        print('✅ Download concluído: $filePath');
        return filePath;
      }

      // Outras plataformas
      final downloadsDir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
      
      String fileName = nomeArquivo;
      String filePath = '${downloadsDir.path}/$fileName';
      int counter = 1;
      
      while (await File(filePath).exists()) {
        final extension = fileName.split('.').last;
        final nameWithoutExtension = fileName.replaceAll('.$extension', '');
        fileName = '${nameWithoutExtension}_$counter.$extension';
        filePath = '${downloadsDir.path}/$fileName';
        counter++;
      }

      final dio = Dio();
      await dio.download(url, filePath);
      print('✅ Download concluído: $filePath');
      return filePath;
    } catch (e) {
      print('❌ Erro ao fazer download do arquivo: $e');
      rethrow;
    }
  }

  /// Download de arquivo usando Supabase Storage (imagens e PDFs)
  static Future<String?> downloadArquivoSupabase(String url, String nomeArquivo) async {
    try {
      // Verificar se é um arquivo suportado (imagem ou PDF)
      if (!_isImageFile(nomeArquivo) && !_isPDF(nomeArquivo)) {
        throw Exception('Download permitido apenas para imagens (JPG, JPEG, PNG, GIF, BMP, WEBP) e PDFs');
      }

      // Fazer download dos bytes do arquivo
      final bytes = await SupabaseService.downloadArquivo(url);
      if (bytes == null) {
        throw Exception('Erro ao baixar arquivo do Supabase');
      }

      // Obter diretório de downloads baseado na plataforma
      Directory? downloadsDir;
      
      if (Platform.isAndroid) {
        // Para Android, usar a pasta Downloads pública do dispositivo
        downloadsDir = Directory('/storage/emulated/0/Download');
        
        // Se não existir, tentar criar
        if (!await downloadsDir.exists()) {
          try {
            await downloadsDir.create(recursive: true);
          } catch (e) {
            // Se falhar, usar fallback para pasta interna
            final appDir = await getApplicationDocumentsDirectory();
            final downloadSubDir = Directory('${appDir.path}/Downloads');
            if (!await downloadSubDir.exists()) {
              await downloadSubDir.create(recursive: true);
            }
            downloadsDir = downloadSubDir;
            print('⚠️ Não conseguiu acessar /Download público, usando: ${downloadsDir.path}');
          }
        }
        
      } else if (Platform.isIOS) {
        downloadsDir = await getApplicationDocumentsDirectory();
        
        // Criar subdiretório "Downloads" para organização
        final downloadSubDir = Directory('${downloadsDir.path}/Downloads');
        if (!await downloadSubDir.exists()) {
          await downloadSubDir.create(recursive: true);
        }
        downloadsDir = downloadSubDir;
        
      } else {
        // Para outras plataformas (Web, Desktop)
        downloadsDir = await getDownloadsDirectory();
        if (downloadsDir == null) {
          downloadsDir = await getApplicationDocumentsDirectory();
        }
      }

      // Criar nome único para o arquivo se já existir
      String fileName = nomeArquivo;
      String filePath = '${downloadsDir.path}/$fileName';
      int counter = 1;
      
      while (await File(filePath).exists()) {
        final extension = fileName.split('.').last;
        final nameWithoutExtension = fileName.replaceAll('.$extension', '');
        fileName = '${nameWithoutExtension}_$counter.$extension';
        filePath = '${downloadsDir.path}/$fileName';
        counter++;
      }

      // Salvar arquivo no dispositivo
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      return filePath;
    } catch (e) {
      print('Erro ao fazer download do arquivo: $e');
      rethrow;
    }
  }

  /// Copiar arquivo local para pasta de Downloads
  static Future<String?> copiarArquivoLocal(String caminhoLocal, String nomeArquivo) async {
    try {
      // Remover 'file://' se existir
      String caminhoReal = caminhoLocal.replaceAll('file://', '');
      
      final arquivoOriginal = File(caminhoReal);
      
      // Verificar se o arquivo existe
      if (!await arquivoOriginal.exists()) {
        throw Exception('Arquivo local não encontrado: $caminhoReal');
      }

      // Solicitar permissão de escrita
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          throw Exception('Permissão de armazenamento negada');
        }
      }

      // Obter diretório de downloads
      Directory? downloadsDir;
      
      if (Platform.isAndroid) {
        // Para Android, usar a pasta Downloads pública do dispositivo
        downloadsDir = Directory('/storage/emulated/0/Download');
        
        // Se não existir, tentar criar
        if (!await downloadsDir.exists()) {
          try {
            await downloadsDir.create(recursive: true);
          } catch (e) {
            // Se falhar, usar fallback para pasta interna
            final appDir = await getApplicationDocumentsDirectory();
            final downloadSubDir = Directory('${appDir.path}/Downloads');
            if (!await downloadSubDir.exists()) {
              await downloadSubDir.create(recursive: true);
            }
            downloadsDir = downloadSubDir;
            print('⚠️ Não conseguiu acessar /Download público, usando: ${downloadsDir.path}');
          }
        }
        
      } else if (Platform.isIOS) {
        downloadsDir = await getApplicationDocumentsDirectory();
        
        final downloadSubDir = Directory('${downloadsDir.path}/Downloads');
        if (!await downloadSubDir.exists()) {
          await downloadSubDir.create(recursive: true);
        }
        downloadsDir = downloadSubDir;
        
      } else {
        downloadsDir = await getDownloadsDirectory();
        if (downloadsDir == null) {
          downloadsDir = await getApplicationDocumentsDirectory();
        }
      }

      print('📋 Copiando arquivo local de: $caminhoReal');

      // Criar nome único para o arquivo se já existir
      String fileName = nomeArquivo;
      String filePath = '${downloadsDir.path}/$fileName';
      int counter = 1;
      
      while (await File(filePath).exists()) {
        final extension = fileName.split('.').last;
        final nameWithoutExtension = fileName.replaceAll('.$extension', '');
        fileName = '${nameWithoutExtension}_$counter.$extension';
        filePath = '${downloadsDir.path}/$fileName';
        counter++;
      }

      // Copiar arquivo
      await arquivoOriginal.copy(filePath);

      print('✅ Arquivo copiado para: $filePath');
      return filePath;
    } catch (e) {
      print('❌ Erro ao copiar arquivo local: $e');
      rethrow;
    }
  }

  /// Adicionar balancete com upload de arquivo
  static Future<Balancete> adicionarBalanceteComUpload({
    required dynamic arquivo,
    required String nomeArquivo,
    required String mes,
    required String ano,
    required bool privado,
    required String condominioId,
    required String representanteId,
  }) async {
    // Primeiro fazer upload do arquivo
    final url = await SupabaseService.uploadBalancete(
      arquivo,
      nomeArquivo,
      condominioId,
      mes,
      ano,
    );
    
    if (url == null) {
      throw Exception('Erro ao fazer upload do arquivo');
    }
    
    // Depois adicionar o balancete com a URL
    final response = await SupabaseService.adicionarBalancete(
      nomeArquivo: nomeArquivo,
      url: url,
      mes: mes,
      ano: ano,
      privado: privado,
      condominioId: condominioId,
      representanteId: representanteId,
    );
    
    if (response != null) {
      return Balancete.fromJson(response);
    }
    
    throw Exception('Erro ao adicionar balancete');
  }

  /// Adicionar balancete com upload de bytes (compatível com web)
  static Future<Balancete> adicionarBalanceteComUploadBytes({
    required Uint8List bytes,
    required String nomeArquivo,
    required String mes,
    required String ano,
    required bool privado,
    required String condominioId,
    required String representanteId,
  }) async {
    // Primeiro fazer upload dos bytes
    final url = await SupabaseService.uploadBalanceteBytes(
      bytes,
      nomeArquivo,
      condominioId,
      mes,
      ano,
    );
    
    if (url == null) {
      throw Exception('Erro ao fazer upload do arquivo');
    }
    
    // Depois adicionar o balancete com a URL
    final response = await SupabaseService.adicionarBalancete(
      nomeArquivo: nomeArquivo,
      url: url,
      mes: mes,
      ano: ano,
      privado: privado,
      condominioId: condominioId,
      representanteId: representanteId,
    );
    
    if (response != null) {
      return Balancete.fromJson(response);
    }
    
    throw Exception('Erro ao adicionar balancete');
  }
  
  /// Atualizar balancete
  static Future<Balancete> atualizarBalancete(
    String balanceteId, {
    String? nomeArquivo,
  }) async {
    final dados = <String, dynamic>{};
    
    if (nomeArquivo != null) {
      dados['nome_arquivo'] = nomeArquivo;
    }
    
    final response = await SupabaseService.atualizarBalancete(balanceteId, dados);
    
    if (response != null) {
      return Balancete.fromJson(response);
    }
    
    throw Exception('Erro ao atualizar balancete');
  }

  /// Deletar balancete
  static Future<void> deletarBalancete(String balanceteId) async {
    await SupabaseService.deletarBalancete(balanceteId);
  }
  
  /// Obter lista de meses
  static List<String> getMeses() {
    return [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
  }
  
  /// Obter lista de anos (últimos 5 anos + próximos 2)
  static List<String> getAnos() {
    final anoAtual = DateTime.now().year;
    final anos = <String>[];
    
    for (int i = anoAtual - 5; i <= anoAtual + 2; i++) {
      anos.add(i.toString());
    }
    
    return anos.reversed.toList();
  }

  /// Método auxiliar para verificar se o arquivo é uma imagem
  static bool _isImageFile(String nomeArquivo) {
    final extensoesImagem = [
      '.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp',
      '.JPG', '.JPEG', '.PNG', '.GIF', '.BMP', '.WEBP'
    ];
    
    return extensoesImagem.any((ext) => nomeArquivo.toLowerCase().endsWith(ext.toLowerCase()));
  }

  /// Método auxiliar para verificar se o arquivo é um PDF
  static bool _isPDF(String nomeArquivo) {
    return nomeArquivo.toLowerCase().endsWith('.pdf');
  }
}