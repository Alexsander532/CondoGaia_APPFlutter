import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/unidade.dart';
import '../models/proprietario.dart';
import '../models/inquilino.dart';
import '../models/imobiliaria.dart';

/// Serviço para buscar detalhes completos de uma unidade
/// Carrega: Unidade + Proprietário + Inquilino + Imobiliária
class UnidadeDetalhesService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Busca todos os dados de uma unidade específica
  Future<Map<String, dynamic>> buscarDetalhesUnidade({
    required String condominioId,
    required String numero,
    required String bloco,
  }) async {
    try {
      // 1. Buscar a unidade
      final unidadeData = await _supabase
          .from('unidades')
          .select()
          .eq('condominio_id', condominioId)
          .eq('numero', numero)
          .eq('bloco', bloco)
          .maybeSingle();

      if (unidadeData == null) {
        throw Exception('Unidade não encontrada');
      }

      final unidade = Unidade.fromJson(unidadeData);

      // 2. Buscar o proprietário (se existir)
      Proprietario? proprietario;
      try {
        final proprietarioData = await _supabase
            .from('proprietarios')
            .select()
            .eq('unidade_id', unidade.id)
            .maybeSingle();

        if (proprietarioData != null) {
          proprietario = Proprietario.fromJson(proprietarioData);
        }
      } catch (e) {
        print('Erro ao buscar proprietário: $e');
        // Continuar mesmo se não encontrar proprietário
      }

      // 3. Buscar o inquilino (se existir)
      Inquilino? inquilino;
      try {
        final inquilinoData = await _supabase
            .from('inquilinos')
            .select()
            .eq('unidade_id', unidade.id)
            .maybeSingle();

        if (inquilinoData != null) {
          inquilino = Inquilino.fromJson(inquilinoData);
        }
      } catch (e) {
        print('Erro ao buscar inquilino: $e');
        // Continuar mesmo se não encontrar inquilino
      }

      // 4. Buscar a imobiliária (associada à unidade específica)
      Imobiliaria? imobiliaria;
      try {
        // Buscar imobiliária ESPECÍFICA da unidade (não do condomínio todo)
        final imobiliariaData = await _supabase
            .from('imobiliarias')
            .select()
            .eq('unidade_id', unidade.id)
            .maybeSingle();

        if (imobiliariaData != null) {
          imobiliaria = Imobiliaria.fromJson(imobiliariaData);
        }
      } catch (e) {
        print('Erro ao buscar imobiliária: $e');
        // Continuar mesmo se não encontrar imobiliária
      }

      return {
        'unidade': unidade,
        'proprietario': proprietario,
        'inquilino': inquilino,
        'imobiliaria': imobiliaria,
      };
    } catch (e) {
      throw Exception('Erro ao buscar detalhes da unidade: $e');
    }
  }

  /// Atualiza dados da unidade
  Future<void> atualizarUnidade({
    required String unidadeId,
    required Map<String, dynamic> dados,
  }) async {
    try {
      await _supabase
          .from('unidades')
          .update(dados)
          .eq('id', unidadeId);
    } catch (e) {
      throw Exception('Erro ao atualizar unidade: $e');
    }
  }

  /// Atualiza dados do proprietário
  Future<void> atualizarProprietario({
    required String proprietarioId,
    required Map<String, dynamic> dados,
  }) async {
    try {
      await _supabase
          .from('proprietarios')
          .update(dados)
          .eq('id', proprietarioId);
    } catch (e) {
      throw Exception('Erro ao atualizar proprietário: $e');
    }
  }

  /// Cria um novo proprietário
  Future<Proprietario> criarProprietario({
    required String condominioId,
    required String unidadeId,
    required String nome,
    required String cpfCnpj,
    String? cep,
    String? endereco,
    String? numero,
    String? complemento,
    String? bairro,
    String? cidade,
    String? estado,
    String? telefone,
    String? celular,
    String? email,
    String? conjuge,
    String? multiproprietarios,
    String? moradores,
  }) async {
    try {
      final response = await _supabase
          .from('proprietarios')
          .insert({
            'condominio_id': condominioId,
            'unidade_id': unidadeId,
            'nome': nome,
            'cpf_cnpj': cpfCnpj,
            'cep': cep,
            'endereco': endereco,
            'numero': numero,
            'complemento': complemento,
            'bairro': bairro,
            'cidade': cidade,
            'estado': estado,
            'telefone': telefone,
            'celular': celular,
            'email': email,
            'conjuge': conjuge,
            'multiproprietarios': multiproprietarios,
            'moradores': moradores,
          })
          .select()
          .single();

      return Proprietario.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao criar proprietário: $e');
    }
  }

  /// Atualiza dados do inquilino
  Future<void> atualizarInquilino({
    required String inquilinoId,
    required Map<String, dynamic> dados,
  }) async {
    try {
      await _supabase
          .from('inquilinos')
          .update(dados)
          .eq('id', inquilinoId);
    } catch (e) {
      throw Exception('Erro ao atualizar inquilino: $e');
    }
  }

  /// Cria um novo inquilino
  Future<Inquilino> criarInquilino({
    required String condominioId,
    required String unidadeId,
    required String nome,
    required String cpfCnpj,
    String? cep,
    String? endereco,
    String? numero,
    String? bairro,
    String? cidade,
    String? estado,
    String? telefone,
    String? celular,
    String? email,
    String? conjuge,
    String? multiproprietarios,
    String? moradores,
    bool receberBoletoEmail = true,
    bool controleLocacao = true,
  }) async {
    try {
      final response = await _supabase
          .from('inquilinos')
          .insert({
            'condominio_id': condominioId,
            'unidade_id': unidadeId,
            'nome': nome,
            'cpf_cnpj': cpfCnpj,
            'cep': cep,
            'endereco': endereco,
            'numero': numero,
            'bairro': bairro,
            'cidade': cidade,
            'estado': estado,
            'telefone': telefone,
            'celular': celular,
            'email': email,
            'conjuge': conjuge,
            'multiproprietarios': multiproprietarios,
            'moradores': moradores,
            'receber_boleto_email': receberBoletoEmail,
            'controle_locacao': controleLocacao,
          })
          .select()
          .single();

      return Inquilino.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao criar inquilino: $e');
    }
  }

  /// Atualiza dados da imobiliária
  Future<void> atualizarImobiliaria({
    required String imobiliariaId,
    required Map<String, dynamic> dados,
  }) async {
    try {
      await _supabase
          .from('imobiliarias')
          .update(dados)
          .eq('id', imobiliariaId);
    } catch (e) {
      throw Exception('Erro ao atualizar imobiliária: $e');
    }
  }

  /// Cria uma nova imobiliária associada a uma unidade específica
  Future<Imobiliaria> criarImobiliaria({
    required String condominioId,
    required String unidadeId,
    required String nome,
    required String cnpj,
    String? telefone,
    String? celular,
    String? email,
    String? fotoUrl,
  }) async {
    try {
      final response = await _supabase
          .from('imobiliarias')
          .insert({
            'condominio_id': condominioId,
            'unidade_id': unidadeId,
            'nome': nome,
            'cnpj': cnpj,
            'telefone': telefone,
            'celular': celular,
            'email': email,
            'foto_url': fotoUrl,
            'ativo': true,
          })
          .select()
          .single();

      return Imobiliaria.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao criar imobiliária: $e');
    }
  }

  /// Busca todas as imobiliárias do condomínio
  Future<List<Imobiliaria>> buscarImobiliariasCondominio(String condominioId) async {
    try {
      final response = await _supabase
          .from('imobiliarias')
          .select()
          .eq('condominio_id', condominioId)
          .eq('ativo', true);

      return (response as List)
          .map((item) => Imobiliaria.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar imobiliárias: $e');
    }
  }
}
