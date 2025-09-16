import 'dart:io';
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
    final response = await SupabaseService.getPastasDocumentos(condominioId);
    return response.map((json) => Documento.fromJson(json)).toList();
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
    final response = await SupabaseService.getArquivosPasta(pastaId);
    return response.map((json) => Documento.fromJson(json)).toList();
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
  
  /// Deletar um balancete
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
}