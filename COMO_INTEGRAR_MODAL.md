/// COMO INTEGRAR O IMPORTACAO_MODAL NA UNIDADE_MORADOR_SCREEN
/// 
/// Este arquivo explica passo a passo como adicionar o modal de importação
/// ao botão de "Importar Planilha" que já existe na tela.

/*

// ============================================================================
// PASSO 1: Adicionar import no início do arquivo
// ============================================================================

import 'package:condogaiaapp/widgets/importacao_modal_widget.dart';

// ============================================================================
// PASSO 2: Atualizar o método _importarPlanilha() na classe
// ============================================================================

Future<void> _importarPlanilha() async {
  try {
    // Buscar CPFs e emails existentes do Supabase
    final cpfsExistentes = await _buscarCpfsExistentes();
    final emailsExistentes = await _buscarEmailsExistentes();

    // Mostrar modal de importação
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => ImportacaoModalWidget(
          condominioId: widget.condominioId, // ID do condomínio
          condominioNome: widget.condominioNome, // Nome do condomínio
          cpfsExistentes: cpfsExistentes,
          emailsExistentes: emailsExistentes,
          onImportarConfirmado: _processarDadosImportados,
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ Erro: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

// ============================================================================
// PASSO 3: Implementar o callback de processamento dos dados
// ============================================================================

Future<void> _processarDadosImportados(Map<String, dynamic> dados) async {
  try {
    final proprietarios = dados['proprietarios'] as List;
    final inquilinos = dados['inquilinos'] as List;
    final blocos = dados['blocos'] as List;
    final imobiliarias = dados['imobiliarias'] as List;
    final senhasProprietarios = dados['senhasProprietarios'] as Map<String, String>;
    final senhasInquilinos = dados['senhasInquilinos'] as Map<String, String>;

    print('📊 Dados recebidos:');
    print('  - Proprietários: ${proprietarios.length}');
    print('  - Inquilinos: ${inquilinos.length}');
    print('  - Blocos: ${blocos.length}');
    print('  - Imobiliárias: ${imobiliarias.length}');

    // PRÓXIMA TAREFA: Inserir estes dados no Supabase
    // await _inserirDadosNoSupabase(
    //   proprietarios,
    //   inquilinos,
    //   blocos,
    //   imobiliarias,
    //   senhasProprietarios,
    //   senhasInquilinos,
    // );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Dados prontos para inserção no banco de dados'),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ Erro ao processar dados: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

// ============================================================================
// PASSO 4: Implementar métodos auxiliares para buscar dados do BD
// ============================================================================

Future<Set<String>> _buscarCpfsExistentes() async {
  try {
    final response = await supabase
        .from('proprietarios')
        .select('cpf')
        .eq('condominio_id', widget.condominioId);

    final cpfs = (response as List)
        .map((item) => (item['cpf'] as String).replaceAll(RegExp(r'[^\d]'), ''))
        .toSet();

    print('📋 CPFs existentes encontrados: ${cpfs.length}');
    return cpfs;
  } catch (e) {
    print('❌ Erro ao buscar CPFs: $e');
    return {};
  }
}

Future<Set<String>> _buscarEmailsExistentes() async {
  try {
    // Buscar emails de proprietários
    final propResponse = await supabase
        .from('proprietarios')
        .select('email')
        .eq('condominio_id', widget.condominioId);

    final propEmails = (propResponse as List)
        .map((item) => (item['email'] as String).toLowerCase())
        .toSet();

    // Buscar emails de inquilinos
    final inquilResponse = await supabase
        .from('inquilinos')
        .select('email')
        .eq('condominio_id', widget.condominioId);

    final inquilEmails = (inquilResponse as List)
        .map((item) => (item['email'] as String).toLowerCase())
        .toSet();

    final todos = {...propEmails, ...inquilEmails};
    print('📧 Emails existentes encontrados: ${todos.length}');
    return todos;
  } catch (e) {
    print('❌ Erro ao buscar emails: $e');
    return {};
  }
}

// ============================================================================
// PASSO 5: Estrutura completa do arquivo atualizado
// ============================================================================

// No topo do arquivo unidade_morador_screen.dart, adicione:

import 'package:flutter/material.dart';
import 'package:condogaiaapp/widgets/importacao_modal_widget.dart';
// ... outros imports

class UnidadeMoradorScreen extends StatefulWidget {
  final String condominioId;
  final String condominioNome;

  const UnidadeMoradorScreen({
    Key? key,
    required this.condominioId,
    required this.condominioNome,
  }) : super(key: key);

  @override
  State<UnidadeMoradorScreen> createState() => _UnidadeMoradorScreenState();
}

class _UnidadeMoradorScreenState extends State<UnidadeMoradorScreen> {
  // ... estado anterior

  // Adicione este novo método
  Future<void> _importarPlanilha() async {
    // ... implementação acima
  }

  // Adicione este método
  Future<void> _processarDadosImportados(Map<String, dynamic> dados) async {
    // ... implementação acima
  }

  // Adicione estes métodos
  Future<Set<String>> _buscarCpfsExistentes() async {
    // ... implementação acima
  }

  Future<Set<String>> _buscarEmailsExistentes() async {
    // ... implementação acima
  }

  // Build widget já existente
  @override
  Widget build(BuildContext context) {
    // ... código existente com o botão de importar que chama _importarPlanilha()
  }
}

// ============================================================================
// FLUXO VISUAL NO MODAL
// ============================================================================

/*
PASSO 1: SELEÇÃO DE ARQUIVO
┌─────────────────────────────────────────┐
│ [📁] Selecionar Arquivo                 │
│ Clique para escolher arquivo .xlsx      │
└─────────────────────────────────────────┘
           ↓
     [Selecionar Arquivo]

PASSO 2: PROCESSAMENTO (Automático)
┌─────────────────────────────────────────┐
│ ⏳ Validando dados...                  │
│ Detectando duplicatas...               │
│ Mapeando entidades...                  │
└─────────────────────────────────────────┘

PASSO 3: PREVIEW
┌─────────────────────────────────────────┐
│ Total de linhas: 25                     │
│ ✅ Válidas: 22                          │
│ ❌ Com erro: 3                          │
│                                         │
│ ERROS:                                  │
│ • Linha 5: CPF inválido                │
│ • Linha 8: Email duplicado             │
│ • Linha 12: CPF duplicado              │
│                                         │
│ [← Voltar]              [✓ Prosseguir] │
└─────────────────────────────────────────┘

PASSO 4: CONFIRMAÇÃO
┌─────────────────────────────────────────┐
│ Confirmar Importação                    │
│                                         │
│ Condomínio: Cond. Ecoville             │
│ Linhas a importar: 22                  │
│ Linhas ignoradas: 3                    │
│                                         │
│ Deseja prosseguir com a importação?    │
│                                         │
│ [← Voltar]     [☁️ Importar]  [Cancel] │
└─────────────────────────────────────────┘

PASSO 5: RESULTADO
┌─────────────────────────────────────────┐
│ ✅ Importação Preparada!               │
│                                         │
│ 👤 Proprietários: 15                    │
│ 🏠 Inquilinos: 18                       │
│ 🏘️ Blocos: 3                           │
│ 🏢 Imobiliárias: 5                     │
│                                         │
│ ℹ️ Senhas serão exibidas após inserção  │
│ ✓ Dados prontos para Supabase          │
│                                         │
│                    [✓ Concluir]        │
└─────────────────────────────────────────┘
*/

// ============================================================================
// EXEMPLO: Chamar do botão "Importar Planilha"
// ============================================================================

// Seu botão atual provavelmente é algo assim:

ElevatedButton.icon(
  onPressed: _importarPlanilha,  // ← Chama o novo método
  icon: const Icon(Icons.upload_file, size: 18),
  label: const Text('Importar Planilha'),
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF50C878),
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    elevation: 2,
  ),
)

// Não precisa mudar nada, pois _importarPlanilha() agora abre o modal!

// ============================================================================
// TESTES SUGERIDOS
// ============================================================================

// 1. Testar seleção de arquivo válido
// 2. Testar cancelamento no passo 1
// 3. Testar arquivo com erros
// 4. Testar preview de múltiplos erros
// 5. Testar confirmação e conclusão
// 6. Testar com dados já existentes no BD

*/
