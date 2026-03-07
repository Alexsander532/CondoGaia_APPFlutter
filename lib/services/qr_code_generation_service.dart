import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'supabase_service.dart';

/// Serviço para gerar e salvar QR codes de visitantes no Supabase Storage
class QrCodeGenerationService {
  static const String _bucketName = 'qr_codes';
  static const String _tableName = 'autorizados_visitantes_portaria_representante';

  /// Gera QR code e salva no bucket qr_codes
  /// Retorna a URL pública do arquivo salvo
  static Future<String?> gerarESalvarQRCode({
    required String visitanteId,
    required String visitanteNome,
    required String visitanteCpf,
    required String unidade,
    String? celular,
    String? diasPermitidos,
  }) async {
    try {
      print('🔄 [QR Code] Iniciando geração para: $visitanteNome');

      // 1️⃣ Montar dados do QR Code
      final dadosQR = {
        'id': visitanteId,
        'nome': visitanteNome,
        'cpf': _sanitizarCPF(visitanteCpf),
        'unidade': unidade,
        'tipo': 'visitante_representante',
        'celular': celular ?? '',
        'dias_permitidos': diasPermitidos ?? 'Sem restrição',
        'data_geracao': DateTime.now().toIso8601String(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      final jsonString = jsonEncode(dadosQR);
      print('📋 [QR Code] Dados: $jsonString');

      // 2️⃣ Gerar imagem PNG do QR Code
      print('🖼️ [QR Code] Gerando imagem...');
      final pngBytes = await _gerarImagemQRCode(jsonString);

      if (pngBytes == null) {
        print('❌ [QR Code] Falha ao gerar imagem PNG');
        return null;
      }

      // 3️⃣ Preparar nome do arquivo
      final nomeArquivo = _gerarNomeArquivo(visitanteNome);
      print('📁 [QR Code] Nome do arquivo: $nomeArquivo');

      // 4️⃣ Upload para Supabase Storage
      print('☁️ [QR Code] Uploadando para bucket "$_bucketName"...');
      final urlPublica = await _uploadParaStorage(nomeArquivo, pngBytes);

      if (urlPublica == null) {
        print('❌ [QR Code] Falha ao fazer upload');
        return null;
      }

      print('✅ [QR Code] Geração concluída: $urlPublica');
      return urlPublica;
    } catch (e) {
      print('❌ [QR Code] ERRO: $e');
      return null;
    }
  }

  /// Gera a imagem PNG do QR Code
  static Future<Uint8List?> _gerarImagemQRCode(String dados) async {
    try {
      final qrCodeImage = await QrPainter(
        data: dados,
        version: QrVersions.auto,
        emptyColor: const Color.fromARGB(255, 255, 255, 255),
        color: const Color.fromARGB(255, 0, 0, 0),
      ).toImageData(500); // 500 pixels - aumentado para melhor qualidade

      return qrCodeImage?.buffer.asUint8List();
    } catch (e) {
      print('❌ [QR Painter] Erro ao gerar imagem: $e');
      return null;
    }
  }

  /// Faz upload da imagem para Supabase Storage
  static Future<String?> _uploadParaStorage(
    String nomeArquivo,
    Uint8List bytes,
  ) async {
    try {
      final supabase = SupabaseService.client;

      // Fazer upload do arquivo
      final path = await supabase.storage.from(_bucketName).uploadBinary(
            nomeArquivo,
            bytes,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      print('📤 [Storage] Upload concluído: $path');

      // Limpar o path removendo duplicações de bucket
      String caminhoLimpo = path;
      // Se o path começar com o nome do bucket, remover a duplicação
      if (caminhoLimpo.startsWith('$_bucketName/')) {
        caminhoLimpo = caminhoLimpo.substring('$_bucketName/'.length);
        print('🧹 [Storage] Path limpo: $caminhoLimpo');
      }

      // Obter URL pública - construir manualmente para evitar duplicação
      final supabaseUrl = 'https://tukpgefrddfchmvtiujp.supabase.co';
      final urlPublica = '$supabaseUrl/storage/v1/object/public/$_bucketName/$caminhoLimpo';
      print('🔗 [Storage] URL pública: $urlPublica');

      return urlPublica;
    } catch (e) {
      print('❌ [Storage] Erro ao fazer upload: $e');
      return null;
    }
  }

  /// Atualiza o campo qr_code_url na tabela
  static Future<bool> salvarURLnaBancoDados(
    String visitanteId,
    String qrCodeUrl,
  ) async {
    try {
      print('💾 [BD] Salvando URL para visitante: $visitanteId');

      // Limpar URL antes de salvar - remover duplicações
      String urlLimpa = qrCodeUrl;
      // Remover duplicações de /qr_codes/qr_codes/
      while (urlLimpa.contains('/qr_codes/qr_codes/')) {
        urlLimpa = urlLimpa.replaceAll('/qr_codes/qr_codes/', '/qr_codes/');
      }

      if (urlLimpa != qrCodeUrl) {
        print('🧹 [BD] URL original: $qrCodeUrl');
        print('🧹 [BD] URL limpa: $urlLimpa');
      }

      final supabase = SupabaseService.client;

      await supabase
          .from(_tableName)
          .update({'qr_code_url': urlLimpa})
          .eq('id', visitanteId);

      print('✅ [BD] URL salva com sucesso');
      return true;
    } catch (e) {
      print('❌ [BD] Erro ao salvar URL: $e');
      return false;
    }
  }

  /// Gera nome único para o arquivo
  static String _gerarNomeArquivo(String visitanteNome) {
    final nomeSanitizado = visitanteNome
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_]'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');

    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final uuid = const Uuid().v4().substring(0, 8);

    return 'qr_${nomeSanitizado}_${timestamp}_$uuid.png';
  }

  /// Sanitiza o CPF para exibição no QR (apenas últimos 4 dígitos)
  static String _sanitizarCPF(String cpf) {
    // Remove caracteres especiais
    final cpfLimpo = cpf.replaceAll(RegExp(r'[^\d]'), '');
    
    // Se tiver menos de 4 dígitos, retorna como está
    if (cpfLimpo.length < 4) {
      return cpfLimpo;
    }
    
    // Retorna últimos 4 dígitos
    return cpfLimpo.substring(cpfLimpo.length - 4);
  }

  /// Busca QR code da tabela
  static Future<String?> obterURLQRCode(String visitanteId) async {
    try {
      final supabase = SupabaseService.client;

      final resultado = await supabase
          .from(_tableName)
          .select('qr_code_url')
          .eq('id', visitanteId)
          .single();

      return resultado['qr_code_url'] as String?;
    } catch (e) {
      print('❌ [BD] Erro ao buscar URL do QR Code: $e');
      return null;
    }
  }

  /// Corrige URLs duplicadas no banco de dados
  /// Remove a duplicação /qr_codes/qr_codes/ convertendo para /qr_codes/
  static Future<void> corrigirURLsDuplicadas() async {
    try {
      print('🔧 [QR Code] Iniciando correção de URLs duplicadas...');

      final supabase = SupabaseService.client;

      // Buscar todos os visitantes com URL duplicada
      final resultado = await supabase
          .from(_tableName)
          .select('id, qr_code_url')
          .filter('qr_code_url', 'is', 'not.null');

      int corrigidas = 0;

      for (final visitante in resultado) {
        final urlAtual = visitante['qr_code_url'] as String?;

        if (urlAtual != null) {
          // Verificar se tem duplicação e corrigir
          String urlCorrigida = urlAtual;
          
          // Remover duplicações do padrão /qr_codes/qr_codes/
          while (urlCorrigida.contains('/qr_codes/qr_codes/')) {
            urlCorrigida = urlCorrigida.replaceAll('/qr_codes/qr_codes/', '/qr_codes/');
          }
          
          // Se a URL foi modificada, atualizar no banco
          if (urlCorrigida != urlAtual) {
            print('🔄 Corrigindo: $urlAtual');
            print('   Para: $urlCorrigida');

            // Atualizar no banco
            await supabase
                .from(_tableName)
                .update({'qr_code_url': urlCorrigida})
                .eq('id', visitante['id']);

            corrigidas++;
          }
        }
      }

      print('✅ [QR Code] $corrigidas URLs corrigidas');
    } catch (e) {
      print('❌ [QR Code] Erro ao corrigir URLs: $e');
    }
  }

  /// Regenera QR code para um visitante existente
  static Future<String?> regenerarQRCode({
    required String visitanteId,
    required String visitanteNome,
    required String visitanteCpf,
    required String unidade,
    String? celular,
    String? diasPermitidos,
  }) async {
    try {
      print('🔄 [QR Code] Regenerando para: $visitanteNome');

      // Gerar novo QR code
      final novaUrl = await gerarESalvarQRCode(
        visitanteId: visitanteId,
        visitanteNome: visitanteNome,
        visitanteCpf: visitanteCpf,
        unidade: unidade,
        celular: celular,
        diasPermitidos: diasPermitidos,
      );

      if (novaUrl != null) {
        // Salvar URL no banco
        await salvarURLnaBancoDados(visitanteId, novaUrl);
        return novaUrl;
      }

      return null;
    } catch (e) {
      print('❌ [QR Code] Erro ao regenerar: $e');
      return null;
    }
  }

  /// ✨ NOVO MÉTODO GENÉRICO
  /// Gera QR code para qualquer tipo de entidade (unidade, proprietário, inquilino, imobiliária)
  /// 
  /// Parâmetros:
  /// - [tipo]: 'unidade', 'proprietario', 'inquilino', 'imobiliaria'
  /// - [id]: ID da entidade
  /// - [nome]: Nome/número da entidade
  /// - [tabelaNome]: Nome da tabela no banco (onde salvar a URL)
  /// - [dados]: Map com dados adicionais para codificar no QR code
  static Future<String?> gerarESalvarQRCodeGenerico({
    required String tipo,
    required String id,
    required String nome,
    required String tabelaNome,
    required Map<String, dynamic> dados,
  }) async {
    try {
      print('🔄 [QR Code] Iniciando geração genérica para tipo: $tipo, nome: $nome');

      // 1️⃣ Montar dados do QR Code
      final dadosQR = {
        'tipo': tipo,
        ...dados, // Incluir dados adicionais
        'data_geracao': DateTime.now().toIso8601String(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      final jsonString = jsonEncode(dadosQR);
      print('📋 [QR Code] Dados: $jsonString');

      // 2️⃣ Gerar imagem PNG do QR Code
      print('🖼️ [QR Code] Gerando imagem...');
      final pngBytes = await _gerarImagemQRCode(jsonString);

      if (pngBytes == null) {
        print('❌ [QR Code] Falha ao gerar imagem PNG');
        return null;
      }

      // 3️⃣ Preparar nome do arquivo
      final nomeArquivo = _gerarNomeArquivoGenerico(tipo, nome);
      print('📁 [QR Code] Nome do arquivo: $nomeArquivo');

      // 4️⃣ Upload para Supabase Storage
      print('☁️ [QR Code] Uploadando para bucket "$_bucketName"...');
      final urlPublica = await _uploadParaStorage(nomeArquivo, pngBytes);

      if (urlPublica == null) {
        print('❌ [QR Code] Falha ao fazer upload');
        return null;
      }

      // 5️⃣ Salvar URL no banco de dados
      print('💾 [QR Code] Salvando URL na tabela "$tabelaNome"...');
      final sucesso = await _salvarURLnaBancoDadosGenerico(
        tabelaNome,
        id,
        urlPublica,
      );

      if (sucesso) {
        print('✅ [QR Code] Geração concluída para $tipo: $urlPublica');
        return urlPublica;
      } else {
        print('❌ [QR Code] Falha ao salvar URL no banco');
        return null;
      }
    } catch (e) {
      print('❌ [QR Code] ERRO: $e');
      return null;
    }
  }

  /// Gera nome único para o arquivo (versão genérica)
  static String _gerarNomeArquivoGenerico(String tipo, String identificador) {
    final identificadorSanitizado = identificador
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_]'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');

    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final uuid = const Uuid().v4().substring(0, 8);

    return 'qr_${tipo}_${identificadorSanitizado}_${timestamp}_$uuid.png';
  }

  /// Salva URL no banco de dados (versão genérica para qualquer tabela)
  static Future<bool> _salvarURLnaBancoDadosGenerico(
    String tabelaNome,
    String id,
    String qrCodeUrl,
  ) async {
    try {
      print('💾 [BD] Salvando URL para $tabelaNome ID: $id');

      // Limpar URL antes de salvar - remover duplicações
      String urlLimpa = qrCodeUrl;
      while (urlLimpa.contains('/qr_codes/qr_codes/')) {
        urlLimpa = urlLimpa.replaceAll('/qr_codes/qr_codes/', '/qr_codes/');
      }

      if (urlLimpa != qrCodeUrl) {
        print('🧹 [BD] URL corrigida de duplicação');
      }

      final supabase = SupabaseService.client;

      await supabase
          .from(tabelaNome)
          .update({'qr_code_url': urlLimpa})
          .eq('id', id);

      print('✅ [BD] URL salva com sucesso em $tabelaNome');
      return true;
    } catch (e) {
      print('❌ [BD] Erro ao salvar URL: $e');
      return false;
    }
  }
}
