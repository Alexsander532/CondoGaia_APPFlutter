import '../models/user_permissions.dart';
import '../models/porteiro.dart';
import '../services/auth_service.dart';

/// Serviço centralizado para verificação de permissões do usuário logado
class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  UserPermissions _currentPermissions = UserPermissions();
  UserType? _currentUserType;
  
  /// Permissões atuais do usuário logado
  UserPermissions get permissions => _currentPermissions;

  /// Inicializa o serviço com base no usuário logado
  void initialize(dynamic user, UserType type) {
    _currentUserType = type;

    if (type == UserType.administrator || type == UserType.representante) {
      // Admins e Representantes têm acesso total automático
      _currentPermissions = UserPermissions.allTrue();
    } else if (type == UserType.porteiro && user is Porteiro) {
      // Porteiros (Sub-usuários) usam suas permissões granulares
      _currentPermissions = user.permissions;
    } else {
      // Proprietários e Inquilinos têm acesso restrito padrão (gerenciado por outras telas)
      // Mas para o sistema de "Módulos", começam com tudo falso.
      _currentPermissions = UserPermissions();
    }
  }

  /// Atalhos de verificação rápida
  bool canAccessModules() => _currentPermissions.hasOpAccess() || _currentPermissions.hasCommsAccess();
  bool canAccessGestao() => _currentPermissions.hasFinAccess() || _currentPermissions.hasAdminAccess() || _currentPermissions.hasDocsAccess();
  bool canAccessChat() => _currentPermissions.chat || _currentPermissions.todos;
  bool canAccessReservas() => _currentPermissions.reservas || _currentPermissions.todos;
  bool canAccessLeitura() => _currentPermissions.leitura || _currentPermissions.todos;
  bool canAccessBoleto() => _currentPermissions.boleto || _currentPermissions.todos;
  bool canAccessPortaria() => _currentPermissions.portaria || _currentPermissions.todos;
  bool canAccessDiario() => _currentPermissions.diarioAgenda || _currentPermissions.todos;
  bool canAccessRelatorios() => _currentPermissions.relatorios || _currentPermissions.todos;
  
  /// Permissão para gerenciar outros usuários
  bool canAccessGestaoUsuarios() {
    return _currentUserType == UserType.representante ||
        _currentUserType == UserType.administrator;
  }
  
  /// Verificação avançada para ações financeiras
  bool canGenerateBoleto() => (_currentPermissions.boleto && _currentPermissions.boletoGerar) || _currentPermissions.todos;
  bool canDeleteBoleto() => (_currentPermissions.boleto && _currentPermissions.boletoExcluir) || _currentPermissions.todos;
  
  /// Verifica se o usuário logado é o Representante Principal
  bool get isRepresentante => _currentUserType == UserType.representante;
  
  /// Verifica se o usuário logado é um Sub-usuário (Porteiro/Juridico/Financeiro)
  bool get isSubUser => _currentUserType == UserType.porteiro;
}
