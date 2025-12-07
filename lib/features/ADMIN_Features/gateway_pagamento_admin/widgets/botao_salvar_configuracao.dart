import 'package:flutter/material.dart';

class BotaoSalvarConfiguracao extends StatelessWidget {
  final VoidCallback onPressed;
  final bool carregando;
  final bool desabilitado;

  const BotaoSalvarConfiguracao({
    Key? key,
    required this.onPressed,
    required this.carregando,
    this.desabilitado = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: desabilitado || carregando ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[900],
          disabledBackgroundColor: Colors.grey[300],
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: carregando
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    desabilitado ? Colors.grey : Colors.white,
                  ),
                ),
              )
            : const Text(
                'Salvar Configuração',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
      ),
    );
  }
}
