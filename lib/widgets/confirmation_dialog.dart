import 'package:flutter/material.dart';

/// Diálogo de confirmação para exclusões
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final String cancelText;
  final Color? confirmColor;
  final VoidCallback? onConfirm;

  const ConfirmationDialog({
    Key? key,
    required this.title,
    required this.content,
    this.confirmText = 'Confirmar',
    this.cancelText = 'Cancelar',
    this.confirmColor,
    this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            onConfirm?.call();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor ?? Colors.red,
            foregroundColor: Colors.white,
          ),
          child: Text(confirmText),
        ),
      ],
    );
  }

  /// Mostra o diálogo e retorna true se confirmado
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
    Color? confirmColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmColor: confirmColor,
      ),
    );
    return result ?? false;
  }

  /// Diálogo específico para exclusão de bloco
  static Future<bool> showDeleteBlocoDialog({
    required BuildContext context,
    required String nomeBloco,
    required int quantidadeUnidades,
  }) async {
    return show(
      context: context,
      title: 'Excluir Bloco',
      content: 'Tem certeza que deseja excluir o bloco "$nomeBloco"?\n\n'
          'Esta ação irá excluir também todas as $quantidadeUnidades unidades '
          'deste bloco e não pode ser desfeita.',
      confirmText: 'Excluir',
      confirmColor: Colors.red,
    );
  }

  /// Diálogo específico para exclusão de unidade
  static Future<bool> showDeleteUnidadeDialog({
    required BuildContext context,
    required String nomeUnidade,
    required String nomeBloco,
  }) async {
    return show(
      context: context,
      title: 'Excluir Unidade',
      content: 'Tem certeza que deseja excluir a unidade "$nomeUnidade" '
          'do bloco "$nomeBloco"?\n\n'
          'Esta ação não pode ser desfeita.',
      confirmText: 'Excluir',
      confirmColor: Colors.red,
    );
  }

  /// Diálogo para quando todas as unidades foram excluídas
  static Future<bool> showReconfigurationDialog({
    required BuildContext context,
  }) async {
    return show(
      context: context,
      title: 'Reconfiguração Necessária',
      content: 'Todas as unidades foram excluídas do condomínio.\n\n'
          'Deseja fazer uma nova configuração do condomínio?',
      confirmText: 'Reconfigurar',
      cancelText: 'Manter Vazio',
      confirmColor: Colors.blue,
    );
  }
}