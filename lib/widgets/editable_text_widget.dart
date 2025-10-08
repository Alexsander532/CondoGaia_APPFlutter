import 'package:flutter/material.dart';

/// Widget para edição inline de texto com confirmação
class EditableTextWidget extends StatefulWidget {
  final String initialText;
  final Function(String) onSave;
  final String? hintText;
  final TextStyle? textStyle;
  final bool enabled;

  const EditableTextWidget({
    Key? key,
    required this.initialText,
    required this.onSave,
    this.hintText,
    this.textStyle,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<EditableTextWidget> createState() => _EditableTextWidgetState();
}

class _EditableTextWidgetState extends State<EditableTextWidget> {
  late TextEditingController _controller;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startEditing() {
    if (!widget.enabled) return;
    setState(() {
      _isEditing = true;
      _controller.text = widget.initialText;
    });
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _controller.text = widget.initialText;
    });
  }

  Future<void> _saveChanges() async {
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O nome não pode estar vazio'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_controller.text.trim() == widget.initialText) {
      _cancelEditing();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onSave(_controller.text.trim());
      setState(() {
        _isEditing = false;
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nome atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditing) {
      return Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: true,
              style: widget.textStyle,
              decoration: InputDecoration(
                hintText: widget.hintText,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              onSubmitted: (_) => _saveChanges(),
            ),
          ),
          const SizedBox(width: 8),
          if (_isLoading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              onPressed: _saveChanges,
              tooltip: 'Salvar',
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: _cancelEditing,
              tooltip: 'Cancelar',
            ),
          ],
        ],
      );
    }

    return GestureDetector(
      onTap: _startEditing,
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.initialText,
              style: widget.textStyle,
            ),
          ),
          if (widget.enabled) ...[
            const SizedBox(width: 8),
            Icon(
              Icons.edit,
              size: 16,
              color: Colors.grey[600],
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget para botões de ação (editar/excluir)
class ActionButtonsWidget extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isLoading;

  const ActionButtonsWidget({
    Key? key,
    this.onEdit,
    this.onDelete,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onEdit != null)
          IconButton(
            icon: const Icon(Icons.edit, size: 18),
            onPressed: onEdit,
            tooltip: 'Editar',
            color: Colors.blue[600],
          ),
        if (onDelete != null)
          IconButton(
            icon: const Icon(Icons.delete, size: 18),
            onPressed: onDelete,
            tooltip: 'Excluir',
            color: Colors.red[600],
          ),
      ],
    );
  }
}