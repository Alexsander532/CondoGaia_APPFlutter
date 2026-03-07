import 'package:flutter/material.dart';

class BotaoSalvarConfiguracao extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool carregando;
  final bool formularioValido;

  const BotaoSalvarConfiguracao({
    Key? key,
    this.onPressed,
    this.carregando = false,
    this.formularioValido = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool habilitado = formularioValido && !carregando;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: habilitado ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: habilitado ? Colors.blue[900] : Colors.grey[400],
          disabledBackgroundColor: Colors.grey[400],
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: carregando
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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

