import 'package:flutter/material.dart';

class BotaoEnviar extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool carregando;
  final bool formularioValido;
  final String texto;

  const BotaoEnviar({
    Key? key,
    this.onPressed,
    this.carregando = false,
    this.formularioValido = false,
    this.texto = 'ENVIAR',
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
            borderRadius: BorderRadius.circular(24),
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
            : Text(
                texto,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}

