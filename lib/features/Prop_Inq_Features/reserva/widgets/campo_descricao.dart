import 'package:flutter/material.dart';

class CampoDescricao extends StatefulWidget {
  final TextEditingController controller;
  final Function(String)? onChanged;
  final FormFieldValidator<String>? validator;

  const CampoDescricao({
    Key? key,
    required this.controller,
    this.onChanged,
    this.validator,
  }) : super(key: key);

  @override
  State<CampoDescricao> createState() => _CampoDescricaoState();
}

class _CampoDescricaoState extends State<CampoDescricao> {
  late final FocusNode _focusNode;

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
        RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: 'Descrição',
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
          maxLines: 3,
          minLines: 2,
          maxLength: 250,
          decoration: InputDecoration(
            hintText: 'Descreva o motivo da reserva',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            counterText: '',
          ),
        ),
      ],
    );
  }
}
