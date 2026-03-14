class UserPermissions {
  final bool todos;
  final bool gestaoUsuarios;
  final bool notificacoesMural;
  final bool chat;
  final bool reservas;
  final bool reservasConfig;
  final bool leitura;
  final bool leituraConfig;
  final bool diarioAgenda;
  final bool documentos;
  final bool condominioGestao;
  final bool condominioConf;
  final bool relatorios;
  final bool portaria;
  final bool boleto;
  final bool boletoGerar;
  final bool boletoEnviar;
  final bool boletoReceber;
  final bool boletoExcluir;
  final bool cobrancasAcordos;
  final bool acordoGerar;
  final bool acordoEnviar;
  final bool moradorUnid;
  final bool moradorConf;
  final bool emailGestao;
  final bool despReceita;
  final bool despReceitaCriar;
  final bool despReceitaExcluir;

  const UserPermissions({
    this.todos = false,
    this.gestaoUsuarios = false,
    this.notificacoesMural = false,
    this.chat = false,
    this.reservas = false,
    this.reservasConfig = false,
    this.leitura = false,
    this.leituraConfig = false,
    this.diarioAgenda = false,
    this.documentos = false,
    this.condominioGestao = false,
    this.condominioConf = false,
    this.relatorios = false,
    this.portaria = false,
    this.boleto = false,
    this.boletoGerar = false,
    this.boletoEnviar = false,
    this.boletoReceber = false,
    this.boletoExcluir = false,
    this.cobrancasAcordos = false,
    this.acordoGerar = false,
    this.acordoEnviar = false,
    this.moradorUnid = false,
    this.moradorConf = false,
    this.emailGestao = false,
    this.despReceita = false,
    this.despReceitaCriar = false,
    this.despReceitaExcluir = false,
  });

  factory UserPermissions.fromMap(Map<String, dynamic> map) {
    return UserPermissions(
      todos: map['todos_marcado'] ?? false,
      gestaoUsuarios: map['gestao_usuarios_marcado'] ?? false,
      notificacoesMural: map['notificacoes_mural_marcado'] ?? false,
      chat: map['chat_marcado'] ?? false,
      reservas: map['reservas_marcado'] ?? false,
      reservasConfig: map['reservas_config_marcado'] ?? false,
      leitura: map['leitura_marcado'] ?? false,
      leituraConfig: map['leitura_config_marcado'] ?? false,
      diarioAgenda: map['diario_agenda_marcado'] ?? false,
      documentos: map['documentos_marcado'] ?? false,
      condominioGestao: map['condominio_gestao_marcado'] ?? false,
      condominioConf: map['condominio_conf_marcado'] ?? false,
      relatorios: map['relatorios_marcado'] ?? false,
      portaria: map['portaria_marcado'] ?? false,
      boleto: map['boleto_marcado'] ?? false,
      boletoGerar: map['boleto_gerar_marcado'] ?? false,
      boletoEnviar: map['boleto_enviar_marcado'] ?? false,
      boletoReceber: map['boleto_receber_marcado'] ?? false,
      boletoExcluir: map['boleto_excluir_marcado'] ?? false,
      cobrancasAcordos: map['cobrancas_acordos_marcado'] ?? false,
      acordoGerar: map['acordo_gerar_marcado'] ?? false,
      acordoEnviar: map['acordo_enviar_marcado'] ?? false,
      moradorUnid: map['morador_unid_marcado'] ?? false,
      moradorConf: map['morador_conf_marcado'] ?? false,
      emailGestao: map['email_gestao_marcado'] ?? false,
      despReceita: map['desp_receita_marcado'] ?? false,
      despReceitaCriar: map['desp_receita_criar_marcado'] ?? false,
      despReceitaExcluir: map['desp_receita_excluir_marcado'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'todos_marcado': todos,
      'gestao_usuarios_marcado': gestaoUsuarios,
      'notificacoes_mural_marcado': notificacoesMural,
      'chat_marcado': chat,
      'reservas_marcado': reservas,
      'reservas_config_marcado': reservasConfig,
      'leitura_marcado': leitura,
      'leitura_config_marcado': leituraConfig,
      'diario_agenda_marcado': diarioAgenda,
      'documentos_marcado': documentos,
      'condominio_gestao_marcado': condominioGestao,
      'condominio_conf_marcado': condominioConf,
      'relatorios_marcado': relatorios,
      'portaria_marcado': portaria,
      'boleto_marcado': boleto,
      'boleto_gerar_marcado': boletoGerar,
      'boleto_enviar_marcado': boletoEnviar,
      'boleto_receber_marcado': boletoReceber,
      'boleto_excluir_marcado': boletoExcluir,
      'cobrancas_acordos_marcado': cobrancasAcordos,
      'acordo_gerar_marcado': acordoGerar,
      'acordo_enviar_marcado': acordoEnviar,
      'morador_unid_marcado': moradorUnid,
      'morador_conf_marcado': moradorConf,
      'email_gestao_marcado': emailGestao,
      'desp_receita_marcado': despReceita,
      'desp_receita_criar_marcado': despReceitaCriar,
      'desp_receita_excluir_marcado': despReceitaExcluir,
    };
  }

  factory UserPermissions.allTrue() {
    return UserPermissions(
      todos: true,
      gestaoUsuarios: true,
      notificacoesMural: true,
      chat: true,
      reservas: true,
      reservasConfig: true,
      leitura: true,
      leituraConfig: true,
      diarioAgenda: true,
      documentos: true,
      condominioGestao: true,
      condominioConf: true,
      relatorios: true,
      portaria: true,
      boleto: true,
      boletoGerar: true,
      boletoEnviar: true,
      boletoReceber: true,
      boletoExcluir: true,
      cobrancasAcordos: true,
      acordoGerar: true,
      acordoEnviar: true,
      moradorUnid: true,
      moradorConf: true,
      emailGestao: true,
      despReceita: true,
      despReceitaCriar: true,
      despReceitaExcluir: true,
    );
  }

  UserPermissions copyWith({
    bool? todos,
    bool? gestaoUsuarios,
    bool? notificacoesMural,
    bool? chat,
    bool? reservas,
    bool? reservasConfig,
    bool? leitura,
    bool? leituraConfig,
    bool? diarioAgenda,
    bool? documentos,
    bool? condominioGestao,
    bool? condominioConf,
    bool? relatorios,
    bool? portaria,
    bool? boleto,
    bool? boletoGerar,
    bool? boletoEnviar,
    bool? boletoReceber,
    bool? boletoExcluir,
    bool? cobrancasAcordos,
    bool? acordoGerar,
    bool? acordoEnviar,
    bool? moradorUnid,
    bool? moradorConf,
    bool? emailGestao,
    bool? despReceita,
    bool? despReceitaCriar,
    bool? despReceitaExcluir,
  }) {
    return UserPermissions(
      todos: todos ?? this.todos,
      gestaoUsuarios: gestaoUsuarios ?? this.gestaoUsuarios,
      notificacoesMural: notificacoesMural ?? this.notificacoesMural,
      chat: chat ?? this.chat,
      reservas: reservas ?? this.reservas,
      reservasConfig: reservasConfig ?? this.reservasConfig,
      leitura: leitura ?? this.leitura,
      leituraConfig: leituraConfig ?? this.leituraConfig,
      diarioAgenda: diarioAgenda ?? this.diarioAgenda,
      documentos: documentos ?? this.documentos,
      condominioGestao: condominioGestao ?? this.condominioGestao,
      condominioConf: condominioConf ?? this.condominioConf,
      relatorios: relatorios ?? this.relatorios,
      portaria: portaria ?? this.portaria,
      boleto: boleto ?? this.boleto,
      boletoGerar: boletoGerar ?? this.boletoGerar,
      boletoEnviar: boletoEnviar ?? this.boletoEnviar,
      boletoReceber: boletoReceber ?? this.boletoReceber,
      boletoExcluir: boletoExcluir ?? this.boletoExcluir,
      cobrancasAcordos: cobrancasAcordos ?? this.cobrancasAcordos,
      acordoGerar: acordoGerar ?? this.acordoGerar,
      acordoEnviar: acordoEnviar ?? this.acordoEnviar,
      moradorUnid: moradorUnid ?? this.moradorUnid,
      moradorConf: moradorConf ?? this.moradorConf,
      emailGestao: emailGestao ?? this.emailGestao,
      despReceita: despReceita ?? this.despReceita,
      despReceitaCriar: despReceitaCriar ?? this.despReceitaCriar,
      despReceitaExcluir: despReceitaExcluir ?? this.despReceitaExcluir,
    );
  }

  // Helper Methods para os 5 Setores de Responsabilidade
  bool hasAdminAccess() => condominioGestao || moradorUnid || gestaoUsuarios || todos;
  bool hasCommsAccess() => chat || notificacoesMural || emailGestao || todos;
  bool hasOpAccess() => portaria || reservas || leitura || diarioAgenda || todos;
  bool hasFinAccess() => despReceita || boleto || cobrancasAcordos || relatorios || todos;
  bool hasDocsAccess() => documentos || todos;
}
