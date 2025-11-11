import 'dart:convert';
import 'package:flutter/material.dart';

/// Widget reutilizável para exibir foto de perfil de Proprietário ou Inquilino
/// 
/// Suporta:
/// - URLs do Supabase Storage
/// - Base64 encoding (compatibilidade com dados antigos)
/// - Ícone padrão se nenhuma foto for fornecida
/// - Loading spinner enquanto carrega a URL
/// - Fallback em caso de erro
class FotoPerfilAvatar extends StatelessWidget {
  final String? fotoUrl;
  final String nome;
  final double radius;
  final Color backgroundColor;
  final IconData? iconDefault;
  final Color iconColor;

  const FotoPerfilAvatar({
    super.key,
    required this.fotoUrl,
    required this.nome,
    this.radius = 25,
    this.backgroundColor = Colors.grey,
    this.iconDefault = Icons.person,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    // Se não há foto, mostrar ícone padrão
    if (fotoUrl == null || fotoUrl!.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        child: Icon(
          iconDefault,
          size: radius,
          color: iconColor,
        ),
      );
    }

    // Verificar se é URL (começa com http) ou Base64
    if (fotoUrl!.startsWith('http')) {
      // É URL do Storage - usar Image.network
      return ClipOval(
        child: Image.network(
          fotoUrl!,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return CircleAvatar(
              radius: radius,
              backgroundColor: backgroundColor,
              child: Icon(
                iconDefault,
                size: radius,
                color: iconColor,
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return CircleAvatar(
              radius: radius,
              backgroundColor: Colors.grey[300],
              child: SizedBox(
                width: radius * 0.8,
                height: radius * 0.8,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                ),
              ),
            );
          },
        ),
      );
    } else {
      // É Base64 - decodificar e usar Image.memory
      try {
        String base64String = fotoUrl!;
        if (base64String.startsWith('data:image')) {
          base64String = base64String.split(',')[1];
        }

        return ClipOval(
          child: Image.memory(
            base64Decode(base64String),
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return CircleAvatar(
                radius: radius,
                backgroundColor: backgroundColor,
                child: Icon(
                  iconDefault,
                  size: radius,
                  color: iconColor,
                ),
              );
            },
          ),
        );
      } catch (e) {
        // Erro ao decodificar
        return CircleAvatar(
          radius: radius,
          backgroundColor: backgroundColor,
          child: Icon(
            iconDefault,
            size: radius,
            color: iconColor,
          ),
        );
      }
    }
  }
}

/// Widget para ListTile com foto de perfil
/// 
/// Combina FotoPerfilAvatar com Text em um ListTile
class PessoaListTile extends StatelessWidget {
  final String? fotoUrl;
  final String nome;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  const PessoaListTile({
    super.key,
    required this.fotoUrl,
    required this.nome,
    this.subtitle,
    this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: FotoPerfilAvatar(
        fotoUrl: fotoUrl,
        nome: nome,
        radius: 20,
        backgroundColor: backgroundColor ?? Colors.grey,
      ),
      title: Text(nome),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      onTap: onTap,
    );
  }
}

/// Widget para Card com foto de perfil grande
/// 
/// Exibe a foto em tamanho maior dentro de um Card
class PessoaCardComFoto extends StatelessWidget {
  final String? fotoUrl;
  final String nome;
  final String? cpfCnpj;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  const PessoaCardComFoto({
    super.key,
    required this.fotoUrl,
    required this.nome,
    this.cpfCnpj,
    this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: FotoPerfilAvatar(
                fotoUrl: fotoUrl,
                nome: nome,
                radius: 40,
                backgroundColor: backgroundColor ?? Colors.grey,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                nome,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (cpfCnpj != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  cpfCnpj!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
