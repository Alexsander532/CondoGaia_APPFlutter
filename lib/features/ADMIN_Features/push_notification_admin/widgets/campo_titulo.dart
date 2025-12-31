import 'package:flutter/material.dart';

class CampoTitulo extends StatefulWidget {
  final TextEditingController controller;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;

  const CampoTitulo({
    Key? key,
    required this.controller,
    this.onChanged,
    this.validator,
  }) : super(key: key);

  @override
  State<CampoTitulo> createState() => _CampoTituloState();
}

class _CampoTituloState extends State<CampoTitulo> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label com asterisco obrigatório
        RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: 'Título',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const TextSpan(
                text: ' *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          onChanged: widget.onChanged,
          validator: widget.validator,
          maxLength: 100,
          decoration: InputDecoration(
            hintText: 'Digite o título da notificação',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            counterText: '',
            suffixIcon: widget.controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      widget.controller.clear();
                      widget.onChanged?.call('');
                    },
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
