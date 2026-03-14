import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../models/porteiro.dart';
import '../../../../services/supabase_service.dart';
import '../../../../services/laravel_api_service.dart';

abstract class GestaoUsuariosState {}

class GestaoUsuariosInitial extends GestaoUsuariosState {}

class GestaoUsuariosLoading extends GestaoUsuariosState {}

class GestaoUsuariosLoaded extends GestaoUsuariosState {
  final List<Porteiro> usuarios;
  GestaoUsuariosLoaded(this.usuarios);
}

class GestaoUsuariosError extends GestaoUsuariosState {
  final String message;
  GestaoUsuariosError(this.message);
}

class GestaoUsuariosCubit extends Cubit<GestaoUsuariosState> {
  GestaoUsuariosCubit() : super(GestaoUsuariosInitial());

  Future<void> carregarUsuarios(String condominioId) async {
    emit(GestaoUsuariosLoading());
    try {
      final response = await SupabaseService.client
          .from('porteiros')
          .select()
          .eq('condominio_id', condominioId)
          .order('nome_completo');
      
      final List<Porteiro> usuarios = (response as List)
          .map((data) => Porteiro.fromJson(data))
          .toList();
      
      emit(GestaoUsuariosLoaded(usuarios));
    } catch (e) {
      emit(GestaoUsuariosError('Erro ao carregar usuários: $e'));
    }
  }

  Future<void> salvarUsuario(Porteiro usuario) async {
    try {
      final data = usuario.toJson();
      if (usuario.id.isNotEmpty && !usuario.id.startsWith('temp_')) {
        await SupabaseService.client
            .from('porteiros')
            .update(data)
            .eq('id', usuario.id);
      } else {
        // Remover ID temporário para o Supabase gerar um novo UUID
        data.remove('id');
        await SupabaseService.client.from('porteiros').insert(data);
      }
      carregarUsuarios(usuario.condominioId);
    } catch (e) {
      emit(GestaoUsuariosError('Erro ao salvar usuário: $e'));
    }
  }

  Future<void> excluirUsuario(String id, String condominioId) async {
    try {
      await SupabaseService.client.from('porteiros').delete().eq('id', id);
      carregarUsuarios(condominioId);
    } catch (e) {
      emit(GestaoUsuariosError('Erro ao excluir usuário: $e'));
    }
  }

  Future<void> enviarConviteEmail({
    required String nomeUsuario,
    required String emailUsuario,
    required String senhaAcesso,
  }) async {
    try {
      // E-mail em modo de teste cai no alexsanderaugusto142019@gmail.com
      final emailTeste = 'alexsanderaugusto142019@gmail.com';

      final subject = 'Bem-vindo(a) ao CondoGaia - Suas Credenciais de Acesso';
      final body = '''
      Olá, $nomeUsuario!

      Bem-vindo(a) ao CondoGaia. O seu perfil de usuário foi criado com sucesso.

      Aqui estão os seus dados de acesso:
      E-mail/Login: $emailUsuario
      Senha provisória: $senhaAcesso

      Recomendamos que você altere sua senha após o primeiro login.

      Atenciosamente,
      Equipe CondoGaia
      ''';

      final payload = {
        'subject': subject,
        'body': body,
        'condominioNome': 'CondoGaia',
        'recipients': [
          {
            'email': emailTeste, // Enviando pro email de teste
            'name': nomeUsuario,
            'type': 'P',
          }
        ],
      };

      final apiService = LaravelApiService();
      final response = await apiService.post('/resend/gestao/aviso', payload);

      if (response.statusCode != 200) {
        throw Exception('Falha na API: \${response.statusCode} - \${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao enviar e-mail de convite: $e');
    }
  }
}
