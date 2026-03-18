# Implementação de Contas Contábeis em Boletos Avulsos

## Resumo da Implementação

Foram implementadas as categorias de contas contábeis para geração de cobranças avulsas, conforme solicitado na imagem de referência.

## 1. Frontend (Flutter)

### Novo Widget: GerarCobrancaAvulsaDialog
**Localização:** `lib/features/Representante_Features/boleto/widgets/gerar_cobranca_avulsa_dialog.dart`

**Características:**
- Dropdown com todas as categorias de contas contábeis
- Checkbox "Constar no Relatório" para categorias específicas
- Seleção de unidades específicas ou todas
- Campos para valor, descrição e data de vencimento
- Opções de envio para registro e e-mail

**Categorias Implementadas:**
- Todos
- Taxa Condominal
- Multa por Infração (Constar no relatório)
- Advertência (Constar no relatório)
- Controle/ Tags
- Manutenção/ Serviços
- Salão de Festa/ Churrasqueira
- Água
- Gás
- Sinistro

### Atualizações no BoletoCubit
**Localização:** `lib/features/Representante_Features/boleto/cubit/boleto_cubit.dart`

**Novo Método:**
```dart
Future<void> gerarCobrancaAvulsa({
  required String contaContabil,
  required String contaNome,
  required String dataVencimento,
  required double valor,
  required String descricao,
  required bool constarRelatorio,
  required bool enviarParaRegistro,
  required bool enviarPorEmail,
  List<String>? unidadeIds,
})
```

### Atualizações no BoletoService
**Localização:** `lib/features/Representante_Features/boleto/services/boleto_service.dart`

**Novo Método:**
```dart
Future<void> gerarCobrancaAvulsa({...})
```

### Atualizações no Modelo Boleto
**Localização:** `lib/features/Representante_Features/boleto/models/boleto_model.dart`

**Novo Campo:**
```dart
final String? constarRelatorio; // SIM, NAO
```

### Atualização na Tela Principal
**Localização:** `lib/features/Representante_Features/boleto/screens/boleto_screen.dart`

**Novos Botões Flutuantes:**
- Botão "Mensal" (azul) - para cobranças mensais
- Botão "Avulsa" (laranja) - para cobranças avulsas

## 2. Backend (Laravel)

### Novo Service: BoletoAvulsoService
**Localização:** `Backend/app/Asaas/Boleto/BoletoAvulsoService.php`

**Funcionalidades:**
- Geração de cobranças avulsas em lote
- Integração com ASAAS para registro
- Suporte ao campo "constar_relatorio"
- Descrição detalhada com categoria e unidade

### Atualizações no BoletoController
**Localização:** `Backend/app/Asaas/Boleto/BoletoController.php`

**Novo Endpoint:**
```php
POST /api/asaas/boletos/gerar-avulso
```

**Validações:**
- contaContabil (required)
- contaNome (required)
- valor (required, min: 0.01)
- descricao (nullable)
- constarRelatorio (required, boolean)
- moradores (required, array)

### Nova Rota
**Localização:** `Backend/routes/api.php`

**Adicionada:**
```php
Route::post('/gerar-avulso', [BoletoController::class, 'gerarAvulso']);
```

## 3. Fluxo de Utilização

### Para o Síndico:
1. Acessar tela de Boletos
2. Clicar no botão flutuante "Avulsa" (laranja)
3. Preencher formulário:
   - Selecionar categoria contábil
   - Definir data de vencimento
   - Informar valor
   - Descrever cobrança (opcional)
   - Marcar "Constar no Relatório" (se aplicável)
   - Selecionar unidades (opcional)
   - Marcar opções de envio
4. Clicar em "GERAR BOLETO AVULSO"

### Resultado:
- Boletos criados com tipo "Avulso"
- Campo "classe" preenchido com ID da categoria
- Campo "constar_relatorio" configurado conforme categoria
- Boletos registrados no ASAAS (se marcado)
- Boletos enviados por e-mail (se marcado)

## 4. Estrutura no Banco de Dados

### Campos Atualizados na tabela `boletos`:
```sql
ALTER TABLE boletos 
ADD COLUMN constar_relatorio VARCHAR(3) DEFAULT 'NAO' CHECK (constar_relatorio IN ('SIM', 'NAO'));
```

### Valores no campo `classe`:
- `taxa_condominal`
- `multa_infracao`
- `advertencia`
- `controle_tags`
- `manutencao_servicos`
- `salao_festa`
- `agua`
- `gas`
- `sinistro`

## 5. Benefícios da Implementação

1. **Organização:** Categorias bem definidas para melhor controle
2. **Relatórios:** Opção de incluir ou não nos relatórios financeiros
3. **Flexibilidade:** Permite gerar cobranças para unidades específicas
4. **Integração:** Totalmente integrado com ASAAS
5. **UX:** Interface intuitiva com botões distintos para cada tipo

## 6. Próximos Passos (Opcional)

1. **Relatórios por Categoria:** Implementar filtros e relatórios baseados nas categorias
2. **Configuração de Categorias:** Permitir adicionar/editar categorias personalizadas
3. **Templates:** Criar templates para categorias mais usadas
4. **Histórico:** Visualizar histórico de cobranças por categoria

## 7. Testes Sugeridos

1. **Teste de Geração:** Gerar boletos avulsos para cada categoria
2. **Teste de Relatório:** Verificar se boletos marcados aparecem nos relatórios
3. **Teste de Seleção:** Gerar para unidades específicas
4. **Teste de Integração:** Verificar registro no ASAAS
5. **Teste de E-mails:** Confirmar envio dos boletos por e-mail

---

**Status:** ✅ Implementação Concluída
**Pronto para:** Testes e Deploy
