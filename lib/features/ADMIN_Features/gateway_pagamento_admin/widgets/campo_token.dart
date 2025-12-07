import 'package:flutter/material.dart';

class CampoToken extends StatefulWidget {
  final TextEditingController controller;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;

  const CampoToken({
    Key? key,
    required this.controller,
    this.onChanged,
    this.validator,
  }) : super(key: key);

  @override
  State<CampoToken> createState() => _CampoTokenState();
}

class _CampoTokenState extends State<CampoToken> {
  bool _mostrarToken = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Token : ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          onChanged: widget.onChanged,
          validator: widget.validator,
          obscureText: !_mostrarToken,
          maxLines: 1,
          decoration: InputDecoration(
            hintText: 'Insira o token do gateway',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            suffixIcon: IconButton(
              icon: Icon(
                _mostrarToken ? Icons.visibility : Icons.visibility_off,
                size: 20,
              ),
              onPressed: () {
                setState(() => _mostrarToken = !_mostrarToken);
              },
            ),
          ),
        ),
        if (widget.controller.text.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                widget.controller.text.length >= 10 ? Icons.check_circle : Icons.info,
                size: 16,
                color: widget.controller.text.length >= 10 ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 4),
              Text(
                '${widget.controller.text.length} caracteres',
                style: TextStyle(
                  fontSize: 12,
                  color: widget.controller.text.length >= 10 ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
