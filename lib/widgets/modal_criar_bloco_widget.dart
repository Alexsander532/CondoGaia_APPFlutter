import 'package:flutter/material.dart';
import '../models/bloco.dart';
import '../services/unidade_service.dart';

class ModalCriarBlocoWidget extends StatefulWidget {
  final String condominioId;

  const ModalCriarBlocoWidget({
    super.key,
    required this.condominioId,
  });

  @override
  State<ModalCriarBlocoWidget> createState() => _ModalCriarBlocoWidgetState();
}

class _ModalCriarBlocoWidgetState extends State<ModalCriarBlocoWidget> {
  final TextEditingController _nomeController = TextEditingController();
  final UnidadeService _unidadeService = UnidadeService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _criarBloco() async {
    final nome = _nomeController.text.trim();

    // Validação
    if (nome.isEmpty) {
      setState(() {
        _errorMessage = 'Nome do bloco é obrigatório';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Obter o próximo número de ordem para este condomínio
      final proximaOrdem = await _unidadeService.obterProximaOrdemBloco(widget.condominioId);
      
      // Criar bloco no serviço
      final novoBloco = Bloco.novo(
        condominioId: widget.condominioId,
        nome: nome,
        codigo: nome.toUpperCase(),
        ordem: proximaOrdem,
      );

      final blocoRetorno = await _unidadeService.criarBloco(novoBloco);

      if (mounted) {
        // Retornar o bloco criado
        Navigator.of(context).pop(blocoRetorno);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao criar bloco: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Título
            const Text(
              'Criar Novo Bloco',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Campo de Nome
            TextField(
              controller: _nomeController,
              enabled: !_isLoading,
              decoration: InputDecoration(
                labelText: 'Nome do Bloco',
                hintText: 'Ex: A, B, C, Bloco Principal...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.domain),
                errorText: _errorMessage,
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _criarBloco(),
            ),
            const SizedBox(height: 20),

            // Mensagem de Erro (se houver)
            if (_errorMessage != null && _errorMessage!.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 12,
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // Botões
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            Navigator.of(context).pop();
                          },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('CANCELAR'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _criarBloco,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.blue.shade600,
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.blue.shade100,
                              ),
                            ),
                          )
                        : const Text(
                            'CRIAR',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
