import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/unidade_service.dart';
import '../models/condominio.dart';

class ConfiguracaoCondominioScreen extends StatefulWidget {
  final Condominio condominio;

  const ConfiguracaoCondominioScreen({
    Key? key,
    required this.condominio,
  }) : super(key: key);

  @override
  State<ConfiguracaoCondominioScreen> createState() => _ConfiguracaoCondominioScreenState();
}

class _ConfiguracaoCondominioScreenState extends State<ConfiguracaoCondominioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _unidadeService = UnidadeService();
  
  // Controladores dos campos
  final _totalBlocosController = TextEditingController(text: '4');
  final _unidadesPorBlocoController = TextEditingController(text: '6');
  
  bool _usarLetras = true;
  bool _isLoading = false;
  bool _jaConfigurado = false;

  @override
  void initState() {
    super.initState();
    _verificarConfiguracao();
  }

  @override
  void dispose() {
    _totalBlocosController.dispose();
    _unidadesPorBlocoController.dispose();
    super.dispose();
  }

  Future<void> _verificarConfiguracao() async {
    try {
      final jaConfigurado = await _unidadeService.condominioJaConfigurado(widget.condominio.id);
      setState(() {
        _jaConfigurado = jaConfigurado;
      });
    } catch (e) {
      // Se der erro, assume que não foi configurado
      setState(() {
        _jaConfigurado = false;
      });
    }
  }

  Future<void> _configurarCondominio() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final totalBlocos = int.parse(_totalBlocosController.text);
      final unidadesPorBloco = int.parse(_unidadesPorBlocoController.text);

      final resultado = await _unidadeService.configurarCondominioCompleto(
        condominioId: widget.condominio.id,
        totalBlocos: totalBlocos,
        unidadesPorBloco: unidadesPorBloco,
        usarLetras: _usarLetras,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Condomínio configurado com sucesso!\n'
              'Criados ${resultado['blocos_criados']} blocos e ${resultado['unidades_criadas']} unidades.',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );

        // Volta para a tela anterior
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao configurar condomínio: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuração do Condomínio'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: _jaConfigurado ? _buildJaConfigurado() : _buildFormularioConfiguracao(),
    );
  }

  Widget _buildJaConfigurado() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              size: 80,
              color: Colors.green,
            ),
            const SizedBox(height: 24),
            Text(
              'Condomínio já configurado!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Este condomínio já possui blocos e unidades configurados. '
              'Você pode gerenciá-los na tela de unidades.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormularioConfiguracao() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Configuração Inicial',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Configure os blocos e unidades do condomínio ${widget.condominio.nomeCondominio}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Formulário
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Parâmetros de Configuração',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Total de blocos
                    TextFormField(
                      controller: _totalBlocosController,
                      decoration: const InputDecoration(
                        labelText: 'Total de Blocos',
                        hintText: 'Ex: 4',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.apartment),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe o total de blocos';
                        }
                        final numero = int.tryParse(value);
                        if (numero == null || numero < 1 || numero > 50) {
                          return 'Informe um número entre 1 e 50';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Unidades por bloco
                    TextFormField(
                      controller: _unidadesPorBlocoController,
                      decoration: const InputDecoration(
                        labelText: 'Unidades por Bloco',
                        hintText: 'Ex: 6',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.home),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe o número de unidades por bloco';
                        }
                        final numero = int.tryParse(value);
                        if (numero == null || numero < 1 || numero > 100) {
                          return 'Informe um número entre 1 e 100';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Usar letras para blocos
                    SwitchListTile(
                      title: const Text('Usar letras para nomear blocos'),
                      subtitle: Text(
                        _usarLetras 
                          ? 'Blocos serão nomeados: A, B, C, D...'
                          : 'Blocos serão nomeados: 1, 2, 3, 4...',
                      ),
                      value: _usarLetras,
                      onChanged: (value) {
                        setState(() {
                          _usarLetras = value;
                        });
                      },
                      activeColor: const Color(0xFF2E7D32),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Preview
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Preview da Configuração',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildPreview(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Botão de configurar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _configurarCondominio,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Configurando...'),
                        ],
                      )
                    : const Text(
                        'Configurar Condomínio',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    final totalBlocos = int.tryParse(_totalBlocosController.text) ?? 0;
    final unidadesPorBloco = int.tryParse(_unidadesPorBlocoController.text) ?? 0;
    final totalUnidades = totalBlocos * unidadesPorBloco;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.apartment, color: Color(0xFF2E7D32)),
            const SizedBox(width: 8),
            Text('$totalBlocos blocos serão criados'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.home, color: Color(0xFF2E7D32)),
            const SizedBox(width: 8),
            Text('$totalUnidades unidades serão criadas'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.label, color: Color(0xFF2E7D32)),
            const SizedBox(width: 8),
            Text(
              _usarLetras 
                ? 'Blocos: A, B, C...' 
                : 'Blocos: 1, 2, 3...',
            ),
          ],
        ),
        if (totalBlocos > 0 && unidadesPorBloco > 0) ...[
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            'Exemplo de estrutura:',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(
            totalBlocos > 3 ? 3 : totalBlocos,
            (index) {
              final nomeBloco = _usarLetras 
                ? String.fromCharCode(65 + index) // A, B, C...
                : (index + 1).toString(); // 1, 2, 3...
              
              return Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 4),
                child: Text(
                  'Bloco $nomeBloco: Unidades 101 a ${100 + unidadesPorBloco}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            },
          ),
          if (totalBlocos > 3)
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                '... e mais ${totalBlocos - 3} blocos',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ],
    );
  }
}