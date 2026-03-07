import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/unidade.dart';
import '../models/proprietario.dart';
import '../models/inquilino.dart';
import '../models/imobiliaria.dart';
import 'qr_code_generation_service.dart';
import '../utils/password_generator.dart';

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
      // 0. Buscar se o condomínio tem blocos
      bool temBlocos = true;
      try {
        final condominioData = await _supabase
            .from('condominios')
            .select('tem_blocos')
            .eq('id', condominioId)
            .maybeSingle();

        if (condominioData != null) {
          temBlocos = condominioData['tem_blocos'] ?? true;
        }
      } catch (e) {
        print('Erro ao buscar tem_blocos do condomínio: $e');
        // Usar padrão true se der erro
      }

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
        'temBlocos': temBlocos,
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
      await _supabase.from('unidades').update(dados).eq('id', unidadeId);
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
      final response = await _supabase
          .from('proprietarios')
          .update(dados)
          .eq('id', proprietarioId)
          .select()
          .single();

      // ✅ Regenerar QR Code com os novos dados
      final proprietarioAtualizado = Proprietario.fromJson(response);
      _gerarQRCodeProprietarioAsync(
        proprietarioAtualizado,
        proprietarioAtualizado.cpfCnpj,
      );
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
    String? matriculaImovelUrl,
  }) async {
    try {
      // ✅ MULTI-UNIT: Verificar se já existe proprietário com este CPF
      String senhaGerada;
      String? emailHerdado;
      String? fotoHerdada;

      final existente = await _supabase
          .from('proprietarios')
          .select('email, senha_acesso, foto_perfil')
          .eq('cpf_cnpj', cpfCnpj)
          .limit(1)
          .maybeSingle();

      if (existente != null) {
        // ♻️ HERDAR credenciais existentes
        senhaGerada =
            existente['senha_acesso'] ??
            PasswordGenerator.generatePasswordFromName(nome);
        emailHerdado = existente['email'];
        fotoHerdada = existente['foto_perfil'];
        print(
          '♻️ CPF existente! Herdando credenciais de: ${existente['email']}',
        );
        print('✅ Usando senha existente para manter acesso unificado');
      } else {
        // 🔐 Gerar nova senha automática baseada no nome
        senhaGerada = PasswordGenerator.generatePasswordFromName(nome);
        print('✅ Senha gerada para proprietário "$nome": $senhaGerada');
        print('📝 GUARDE ESTA SENHA! Email: $email | Senha: $senhaGerada');
      }

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
            'email': emailHerdado ?? email, // ✅ Usar email herdado se existir
            'conjuge': conjuge,
            'multiproprietarios': multiproprietarios,
            'moradores': moradores,
            'senha_acesso': senhaGerada,
            'foto_perfil': fotoHerdada, // ✅ Herdar foto se existir
            'matricula_imovel_url': matriculaImovelUrl,
          })
          .select()
          .single();

      final proprietario = Proprietario.fromJson(response);

      // ✅ NOVO: Gerar QR code em background
      _gerarQRCodeProprietarioAsync(proprietario, cpfCnpj);

      return proprietario;
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
      final response = await _supabase
          .from('inquilinos')
          .update(dados)
          .eq('id', inquilinoId)
          .select()
          .single();

      // ✅ Regenerar QR Code com os novos dados
      final inquilinoAtualizado = Inquilino.fromJson(response);
      _gerarQRCodeInquilinoAsync(
        inquilinoAtualizado,
        inquilinoAtualizado.cpfCnpj,
      );
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
    String? controleLocacaoUrl,
  }) async {
    try {
      // 🔐 Gerar senha automática baseada no nome
      final senhaGerada = PasswordGenerator.generatePasswordFromName(nome);
      print('✅ Senha gerada para inquilino "$nome": $senhaGerada');

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
            'controle_locacao_url': controleLocacaoUrl,
            'senha_acesso': senhaGerada, // ✅ Adicionar senha gerada
          })
          .select()
          .single();

      final inquilino = Inquilino.fromJson(response);

      // ✅ NOVO: Gerar QR code em background
      _gerarQRCodeInquilinoAsync(inquilino, cpfCnpj);

      return inquilino;
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
      final response = await _supabase
          .from('imobiliarias')
          .update(dados)
          .eq('id', imobiliariaId)
          .select()
          .single();

      // ✅ Regenerar QR Code com os novos dados
      final imobiliariaAtualizada = Imobiliaria.fromJson(response);
      _gerarQRCodeImobiliariaAsync(
        imobiliariaAtualizada,
        imobiliariaAtualizada.cnpj,
      );
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

      final imobiliaria = Imobiliaria.fromJson(response);

      // ✅ NOVO: Gerar QR code em background
      _gerarQRCodeImobiliariaAsync(imobiliaria, cnpj);

      return imobiliaria;
    } catch (e) {
      throw Exception('Erro ao criar imobiliária: $e');
    }
  }

  /// Busca todas as imobiliárias do condomínio
  Future<List<Imobiliaria>> buscarImobiliariasCondominio(
    String condominioId,
  ) async {
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

  // ========== MÉTODOS AUXILIARES PARA GERAÇÃO DE QR CODES ==========

  /// Gera QR code para o proprietário em background
  void _gerarQRCodeProprietarioAsync(
    Proprietario proprietario,
    String cpfCnpj,
  ) {
    Future.delayed(const Duration(milliseconds: 500), () async {
      try {
        print(
          '🔄 [Proprietário] Iniciando geração de QR Code para: ${proprietario.nome}',
        );

        final qrCodeUrl =
            await QrCodeGenerationService.gerarESalvarQRCodeGenerico(
              tipo: 'proprietario',
              id: proprietario.id,
              nome: proprietario.nome,
              tabelaNome: 'proprietarios',
              dados: {
                'id': proprietario.id,
                'nome': proprietario.nome,
                'cpf': _sanitizarCPF(cpfCnpj),
                'email': proprietario.email ?? '',
                'telefone': proprietario.celular ?? proprietario.telefone ?? '',
                'condominio_id': proprietario.condominioId,
                'data_criacao': DateTime.now().toIso8601String(),
              },
            );

        if (qrCodeUrl != null) {
          print('✅ [Proprietário] QR Code gerado e salvo: $qrCodeUrl');
        } else {
          print('❌ [Proprietário] Falha ao gerar QR Code');
        }
      } catch (e) {
        print('❌ [Proprietário] Erro ao gerar QR Code: $e');
      }
    });
  }

  /// Gera QR code para o inquilino em background
  void _gerarQRCodeInquilinoAsync(Inquilino inquilino, String cpfCnpj) {
    Future.delayed(const Duration(milliseconds: 500), () async {
      try {
        print(
          '🔄 [Inquilino] Iniciando geração de QR Code para: ${inquilino.nome}',
        );

        final qrCodeUrl =
            await QrCodeGenerationService.gerarESalvarQRCodeGenerico(
              tipo: 'inquilino',
              id: inquilino.id,
              nome: inquilino.nome,
              tabelaNome: 'inquilinos',
              dados: {
                'id': inquilino.id,
                'nome': inquilino.nome,
                'cpf': _sanitizarCPF(cpfCnpj),
                'email': inquilino.email ?? '',
                'telefone': inquilino.celular ?? inquilino.telefone ?? '',
                'condominio_id': inquilino.condominioId,
                'data_criacao': DateTime.now().toIso8601String(),
              },
            );

        if (qrCodeUrl != null) {
          print('✅ [Inquilino] QR Code gerado e salvo: $qrCodeUrl');
        } else {
          print('❌ [Inquilino] Falha ao gerar QR Code');
        }
      } catch (e) {
        print('❌ [Inquilino] Erro ao gerar QR Code: $e');
      }
    });
  }

  /// Gera QR code para a imobiliária em background
  void _gerarQRCodeImobiliariaAsync(Imobiliaria imobiliaria, String cnpj) {
    Future.delayed(const Duration(milliseconds: 500), () async {
      try {
        print(
          '🔄 [Imobiliária] Iniciando geração de QR Code para: ${imobiliaria.nome}',
        );

        final qrCodeUrl =
            await QrCodeGenerationService.gerarESalvarQRCodeGenerico(
              tipo: 'imobiliaria',
              id: imobiliaria.id,
              nome: imobiliaria.nome,
              tabelaNome: 'imobiliarias',
              dados: {
                'id': imobiliaria.id,
                'nome': imobiliaria.nome,
                'cnpj': _sanitizarCNPJ(cnpj),
                'email': imobiliaria.email ?? '',
                'telefone': imobiliaria.celular ?? imobiliaria.telefone ?? '',
                'condominio_id': imobiliaria.condominioId,
                'data_criacao': DateTime.now().toIso8601String(),
              },
            );

        if (qrCodeUrl != null) {
          print('✅ [Imobiliária] QR Code gerado e salvo: $qrCodeUrl');
        } else {
          print('❌ [Imobiliária] Falha ao gerar QR Code');
        }
      } catch (e) {
        print('❌ [Imobiliária] Erro ao gerar QR Code: $e');
      }
    });
  }

  /// Sanitiza o CPF para exibição (apenas últimos 4 dígitos)
  String _sanitizarCPF(String cpf) {
    final cpfLimpo = cpf.replaceAll(RegExp(r'[^\d]'), '');
    if (cpfLimpo.length < 4) return cpfLimpo;
    return cpfLimpo.substring(cpfLimpo.length - 4);
  }

  /// Sanitiza o CNPJ para exibição (apenas últimos 4 dígitos)
  String _sanitizarCNPJ(String cnpj) {
    final cnpjLimpo = cnpj.replaceAll(RegExp(r'[^\d]'), '');
    if (cnpjLimpo.length < 4) return cnpjLimpo;
    return cnpjLimpo.substring(cnpjLimpo.length - 4);
  }

  /// Deleta um proprietário e todos os seus dados
  Future<void> deletarProprietario({required String proprietarioId}) async {
    try {
      print('🗑️ Deletando proprietário com ID: $proprietarioId');

      await _supabase.from('proprietarios').delete().eq('id', proprietarioId);

      print('✅ Proprietário deletado com sucesso!');
    } catch (e) {
      print('❌ Erro ao deletar proprietário: $e');
      throw Exception('Erro ao deletar proprietário: $e');
    }
  }

  /// Deleta um inquilino e todos os seus dados
  Future<void> deletarInquilino({required String inquilinoId}) async {
    try {
      print('🗑️ Deletando inquilino com ID: $inquilinoId');

      await _supabase.from('inquilinos').delete().eq('id', inquilinoId);

      print('✅ Inquilino deletado com sucesso!');
    } catch (e) {
      print('❌ Erro ao deletar inquilino: $e');
      throw Exception('Erro ao deletar inquilino: $e');
    }
  }

  /// Deleta uma imobiliária e todos os seus dados
  Future<void> deletarImobiliaria({required String imobiliariaId}) async {
    try {
      print('🗑️ Deletando imobiliária com ID: $imobiliariaId');

      await _supabase.from('imobiliarias').delete().eq('id', imobiliariaId);

      print('✅ Imobiliária deletada com sucesso!');
    } catch (e) {
      print('❌ Erro ao deletar imobiliária: $e');
      throw Exception('Erro ao deletar imobiliária: $e');
    }
  }

  /// Deleta um representante e todos os seus dados
  Future<void> deletarRepresentante({required String representanteId}) async {
    try {
      print('🗑️ Deletando representante com ID: $representanteId');

      await _supabase.from('representantes').delete().eq('id', representanteId);

      print('✅ Representante deletado com sucesso!');
    } catch (e) {
      print('❌ Erro ao deletar representante: $e');
      throw Exception('Erro ao deletar representante: $e');
    }
  }

  /// Deleta uma unidade e todos os seus dados vinculados
  Future<void> deletarUnidade({required String unidadeId}) async {
    try {
      print('🗑️ Deletando unidade com ID: $unidadeId');

      await _supabase.from('unidades').delete().eq('id', unidadeId);

      print('✅ Unidade deletada com sucesso!');
    } catch (e) {
      print('❌ Erro ao deletar unidade: $e');
      throw Exception('Erro ao deletar unidade: $e');
    }
  }
}
