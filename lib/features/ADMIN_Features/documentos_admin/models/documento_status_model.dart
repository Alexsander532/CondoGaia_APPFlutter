enum StatusDocumento { aprovado, pendente, erro }

class DocumentoStatusModel {
  final String id;
  final String nome;
  final String rgCnhCnpj;
  final String cidade;
  final String uf; // Estado
  final StatusDocumento status;
  final String? errorMessage;
  final DateTime dataEnvio;

  const DocumentoStatusModel({
    required this.id,
    required this.nome,
    required this.rgCnhCnpj,
    required this.cidade,
    required this.uf,
    required this.status,
    required this.dataEnvio,
    this.errorMessage,
  });
}
