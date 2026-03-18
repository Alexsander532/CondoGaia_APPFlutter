# Relatório Completo — Funcionamento do Boleto no Sistema CondoGaia

**Data:** 16/03/2026  
**Versão:** 1.0  
**Autor:** Sistema de Documentação  

---

## 1. Visão Geral do Sistema de Boletos

O sistema de boletos do CondoGaia é uma solução integrada para gestão de cobranças condominiais, conectando o aplicativo Flutter ao backend Laravel e à API do ASAAS para emissão e registro de boletos bancários.

### Arquitetura do Sistema

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         FLUXO DO BOLETO                                 │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│   ┌──────────────┐    ┌──────────────┐    ┌──────────────┐             │
│   │   Flutter    │───▶│   Laravel    │───▶│    ASAAS     │             │
│   │   (Front)    │    │   (Backend)  │    │   (Gateway)  │             │
│   └──────────────┘    └──────────────┘    └──────────────┘             │
│          │                   │                   │                     │
│          ▼                   ▼                   ▼                     │
│   ┌──────────────┐    ┌──────────────┐    ┌──────────────┐             │
│   │   Supabase   │◀───│   Supabase   │◀───│  Webhooks    │             │
│   │   (Storage)  │    │   (Sync)     │    │  (Status)    │             │
│   └──────────────┘    └──────────────┘    └──────────────┘             │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### Componentes Principais

| Componente | Arquivo | Função |
|------------|---------|--------|
| **BoletoService (Flutter)** | `boleto_service.dart` | Comunicação com backend e Supabase |
| **BoletoCubit** | `boleto_cubit.dart` | Gerenciamento de estado |
| **BoletoModel** | `boleto_model.dart` | Estrutura de dados |
| **BoletoService (PHP)** | `BoletoService.php` | Integração ASAAS |
| **CobrancaService** | `CobrancaService.php` | Operações de cobrança |

---

## 2. Tipos de Boleto e Suas Características

### 2.1 Boleto Mensal

**Definição:** Cobrança periódica gerada em lote para todos os moradores do condomínio.

**Composição do Valor:**
```
Valor Total = Cota Condominial
            + Fundo de Reserva
            + Multa por Infração
            + Taxa de Controle
            + Rateio de Água
            - Descontos
```

**Campos no Model:**
```dart
// @boleto_model.dart:25-30
final double cotaCondominial;
final double fundoReserva;
final double multaInfracao;
final double controle;
final double rateioAgua;
final double desconto;
```

### 2.2 Boleto Avulso

**Definição:** Cobrança individual para despesas extraordinárias (ex: aluguel de salão, consumo de gás, multas específicas).

**Características:**
- Gerado individualmente por unidade
- Pode ser recorrente ou pontual
- Integração com plano de contas

### 2.3 Boleto de Acordo

**Definição:** Resultado do agrupamento de múltiplos boletos em uma única cobrança.

**Como Funciona:**
1. Seleciona-se 2 ou mais boletos
2. Os valores são somados
3. O primeiro boleto assume o valor total
4. Os demais são marcados como "Cancelado por Acordo"

---

## 3. Status do Boleto - Ciclo de Vida

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    CICLO DE VIDA DO BOLETO                              │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│   ┌─────────┐    ┌───────────┐    ┌─────────┐    ┌─────────┐           │
│   │  Ativo  │───▶│ Registrado│───▶│  Pago   │    │Cancelado│           │
│   │         │    │  (ASAAS)  │    │         │    │  Acordo │           │
│   └─────────┘    └───────────┘    └─────────┘    └─────────┘           │
│        │              │                                               │
│        │              │                                               │
│        ▼              ▼                                               │
│   ┌─────────┐    ┌─────────┐                                         │
│   │ Vencido │    │  PDF    │                                         │
│   │(filtro) │    │disponível│                                        │
│   └─────────┘    └─────────┘                                         │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### Tabela de Status

| Status | Descrição | Ações Disponíveis |
|--------|-----------|-------------------|
| `Ativo` | Boleto criado, aguardando pagamento | Ver, Copiar código, Enviar email, Registrar |
| `Registrado` | Registrado no ASAAS com linha digitável | Ver PDF, Copiar código, Compartilhar |
| `Pago` | Pagamento confirmado | Ver comprovante, Ver detalhes |
| `Cancelado` | Boleto cancelado | Nenhuma |
| `Cancelado por Acordo` | Agrupado em outro boleto | Nenhuma |

### Campo `boleto_registrado`

| Valor | Significado |
|-------|-------------|
| `SIM` | Registrado com sucesso no ASAAS |
| `NAO` | Ainda não enviado para registro |
| `PENDENTE` | Aguardando processamento |
| `ERRO` | Falha no registro |

---

## 4. CASOS REAIS DE USO

### ═══════════════════════════════════════════════════════════════════
### CASO 1: Geração de Cobrança Mensal (Fluxo Completo)
### ═══════════════════════════════════════════════════════════════════

**Cenário:** O síndico João precisa gerar os boletos de março/2026 para todos os 48 moradores do Condomínio Gaia Prime.

#### Passo a Passo no Sistema:

**1. Acesso à Funcionalidade**
```
Home Representante → Gestão de Boletos → Botão "Gerar Cobrança Mensal"
```

**2. Preenchimento dos Valores**
```
┌────────────────────────────────────────────────────────────┐
│           GERAR COBRANÇA MENSAL - Março/2026               │
├────────────────────────────────────────────────────────────┤
│ Data de Vencimento: 10/03/2026                            │
│                                                            │
│ Cota Condominial:    R$ 450,00                             │
│ Fundo de Reserva:    R$  45,00  (10% da cota)              │
│ Multa por Infração:  R$   0,00                             │
│ Taxa de Controle:    R$  15,00                             │
│ Rateio de Água:      R$ 120,00  (média por unidade)        │
│ Desconto:            R$   0,00                             │
│ ─────────────────────────────────────────────────────────  │
│ VALOR TOTAL/UNID:    R$ 630,00                             │
│                                                            │
│ ☑ Enviar para Registro (ASAAS)                            │
│ ☑ Enviar por E-mail                                       │
│                                                            │
│ [Selecionar Unidades] (48 unidades selecionadas)           │
│                                                            │
│           [CANCELAR]  [GERAR COBRANÇA]                     │
└────────────────────────────────────────────────────────────┘
```

**3. Processamento no Backend**

O Flutter envia para o Laravel:
```dart
// @boleto_service.dart:277-288
final response = await LaravelApiService().post('/asaas/boletos/gerar-mensal', {
  'condominioId': condominioId,
  'dataVencimento': '2026-03-10',
  'cotaCondominial': 450.00,
  'fundoReserva': 45.00,
  'multaInfracao': 0.00,
  'controle': 15.00,
  'rateioAgua': 120.00,
  'desconto': 0.00,
  'enviarParaRegistro': true,
  'moradores': moradoresParaApi, // Lista com 48 moradores
});
```

**4. Execução no Laravel + ASAAS**

```php
// @BoletoService.php:147-236
public function gerarCobrancaMensal(array $data): array
{
    // Para cada morador:
    foreach ($moradores as $morador) {
        // 1. Criar/buscar cliente no ASAAS
        $cliente = $this->clientService->criarOuBuscar([
            'name' => 'Maria Silva',
            'cpfCnpj' => '123.456.789-00',
            'email' => 'maria@email.com',
        ]);
        
        // 2. Criar cobrança BOLETO
        $cobranca = $this->cobrancaService->criar([
            'customer' => $cliente['id'],
            'billingType' => 'BOLETO',
            'value' => 630.00,
            'dueDate' => '2026-03-10',
            'description' => 'Condomínio - A/101. Cota: R$ 450,00 | Fundo: R$ 45,00...',
        ]);
        
        // 3. Obter linha digitável
        $linha = $this->obterLinhaDigitavel($cobranca['id']);
        
        // 4. Salvar no Supabase
        $boletosParaSupabase[] = [
            'condominio_id' => 'uuid-cond...',
            'bloco_unidade' => 'A/101',
            'sacado' => 'uuid-morador',
            'referencia' => '03/2026',
            'data_vencimento' => '2026-03-10',
            'valor' => 630.00,
            'status' => 'Ativo',
            'tipo' => 'Mensal',
            'asaas_payment_id' => 'pay_123abc',
            'identification_field' => '001234567890...',
            'bar_code' => '001234567890123456789012345678...',
            'boleto_registrado' => 'SIM',
        ];
    }
    
    // Batch insert no Supabase
    $this->supabase->api()->post('/boletos', $boletosParaSupabase);
}
```

**5. Resultado Final**

```
┌─────────────────────────────────────────────────────────────┐
│                 RESULTADO DA GERAÇÃO                        │
├─────────────────────────────────────────────────────────────┤
│ ✅ 48 boletos gerados com sucesso                           │
│ ✅ 48 boletos registrados no ASAAS                          │
│ ✅ 46 emails enviados (2 moradores sem email)               │
│                                                             │
│ Detalhes:                                                   │
│ • Maria Silva (A/101) - pay_abc123 - R$ 630,00             │
│ • João Santos (A/102) - pay_def456 - R$ 630,00             │
│ • Ana Oliveira (B/201) - pay_ghi789 - R$ 630,00            │
│ • ... (45 outros)                                           │
│                                                             │
│ ❌ 0 erros                                                  │
└─────────────────────────────────────────────────────────────┘
```

**6. Dados Armazenados no Supabase**

| Campo | Valor Exemplo |
|-------|---------------|
| `id` | `uuid-boleto-123` |
| `condominio_id` | `uuid-cond-gaia` |
| `bloco_unidade` | `A/101` |
| `sacado` | `uuid-maria-silva` |
| `referencia` | `03/2026` |
| `data_vencimento` | `2026-03-10` |
| `valor` | `630.00` |
| `valor_total` | `630.00` |
| `status` | `Ativo` |
| `tipo` | `Mensal` |
| `asaas_payment_id` | `pay_abc123xyz` |
| `identification_field` | `001900000901234567890...` |
| `bar_code` | `00190000090123456789012345678901234` |
| `boleto_registrado` | `SIM` |
| `bank_slip_url` | `https://asaas.com/bankSlip/...` |

---

### ═══════════════════════════════════════════════════════════════════
### CASO 2: Morador Visualizando Seu Boleto (App Proprietário/Inquilino)
### ═══════════════════════════════════════════════════════════════════

**Cenário:** Maria Silva, proprietária da unidade A/101, abre o app para ver seu boleto de março.

#### Fluxo no App:

**1. Navegação**
```
Home Proprietário → Boletos → BoletoPropScreen
```

**2. Carregamento dos Dados**

O app consulta o Supabase filtrando pelo `moradorId`:
```dart
// @boleto_service.dart:14-130
Future<List<Boleto>> listarBoletos(String condominioId, {...}) async {
  var query = _supabase
      .from('boletos')
      .select('*, contas_bancarias(banco)')
      .eq('condominio_id', condominioId);
  
  // Filtro por status
  if (situacao == 'A vencer') {
    query = query
        .eq('status', 'Ativo')
        .gte('data_vencimento', DateTime.now().toIso8601String());
  }
  
  final response = await query.order('data_vencimento', ascending: false);
}
```

**3. Exibição do Boleto**

```
┌─────────────────────────────────────────────────────────────┐
│ 📄 BOLETO - Março/2026                                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ Unidade: A/101                                              │
│ Vencimento: 10/03/2026                                      │
│ Status: ⚪ A Vencer                                         │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐│
│ │ VALOR: R$ 630,00                                        ││
│ └─────────────────────────────────────────────────────────┘│
│                                                             │
│ ▼ Ver Composição                                            │
│   ├─ Cota Condominial... R$ 450,00                         │
│   ├─ Fundo de Reserva... R$  45,00                         │
│   ├─ Taxa de Controle... R$  15,00                         │
│   └─ Rateio de Água..... R$ 120,00                         │
│                                                             │
│ ▼ Demonstrativo Financeiro                                  │
│   (Resumo das despesas do condomínio)                       │
│                                                             │
│ ─────────────────────────────────────────────────────────  │
│                                                             │
│ [📋 COPIAR CÓDIGO]  [👁 VER BOLETO PDF]  [📤 COMPARTILHAR] │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**4. Ações Disponíveis**

| Ação | Implementação | Código |
|------|---------------|--------|
| **Copiar Código** | Copia `identification_field` para clipboard | `Clipboard.setData(...)` |
| **Ver PDF** | Abre `bank_slip_url` no navegador | `url_launcher.launch(...)` |
| **Compartilhar** | Envia PDF via apps do celular | `share_plus.share(...)` |

**5. Código de Barras Copiado**

```
Linha Digitável: 00190000090123456789012345678901234567890123
Código de Barras: 00190000090123456789012345678901234
```

---

### ═══════════════════════════════════════════════════════════════════
### CASO 3: Recebimento Manual de Boleto (Baixa)
### ═══════════════════════════════════════════════════════════════════

**Cenário:** O morador João Santos pagou seu boleto em dinheiro na portaria. O síndico precisa dar baixa no sistema.

#### Passo a Passo:

**1. Localizar o Boleto**
```
Gestão de Boletos → Filtrar por "A/102" ou "João Santos"
```

**2. Abrir Dialog de Recebimento**
```
Clicar no boleto → Botão "Receber" → ReceberBoletoDialog
```

**3. Preencher Dados do Recebimento**

```
┌─────────────────────────────────────────────────────────────┐
│              RECEBER BOLETO                                 │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ Unidade: A/102                                              │
│ Valor Original: R$ 630,00                                   │
│ Vencimento: 10/03/2026                                      │
│ Data Atual: 15/03/2026 (5 dias de atraso)                   │
│                                                             │
│ ─────────────────────────────────────────────────────────  │
│                                                             │
│ Data do Pagamento: [15/03/2026] 📅                         │
│                                                             │
│ Conta Bancária: [▼ Banco Itaú]                             │
│                                                             │
│ Juros (R$):     [   5,25  ]  (0,025% ao dia)               │
│ Multa (R$):     [  18,90  ]  (3% após vencimento)          │
│ Outros Acresc.: [    0,00 ]                                 │
│                                                             │
│ ─────────────────────────────────────────────────────────  │
│ VALOR TOTAL:    R$ 654,15                                   │
│ ─────────────────────────────────────────────────────────  │
│                                                             │
│ Observações:                                                │
│ [Pagamento realizado em dinheiro na portaria         ]     │
│                                                             │
│           [CANCELAR]  [CONFIRMAR RECEBIMENTO]               │
└─────────────────────────────────────────────────────────────┘
```

**4. Processamento no Backend**

```dart
// @boleto_service.dart:136-165
Future<void> receberBoleto({
  required String boletoId,
  required String contaBancariaId,
  required String dataPagamento,
  required double juros,
  required double multa,
  required double outrosAcrescimos,
  required double valorTotal,
  String? obs,
}) async {
  await _supabase
      .from('boletos')
      .update({
        'status': 'Pago',
        'conta_bancaria_id': contaBancariaId,
        'data_pagamento': dataPagamento,
        'juros': juros,
        'multa': multa,
        'outros_acrescimos': outrosAcrescimos,
        'valor_total': valorTotal,
        'obs': obs,
        'pgto': 'SIM',
      })
      .eq('id', boletoId);
}
```

**5. Estado Atualizado no Supabase**

| Campo | Antes | Depois |
|-------|-------|--------|
| `status` | `Ativo` | `Pago` |
| `data_pagamento` | `null` | `2026-03-15` |
| `juros` | `0` | `5.25` |
| `multa` | `0` | `18.90` |
| `valor_total` | `630.00` | `654.15` |
| `pgto` | `null` | `SIM` |
| `conta_bancaria_id` | `null` | `uuid-conta-itaú` |

---

### ═══════════════════════════════════════════════════════════════════
### CASO 4: Agrupamento de Boletos (Acordo de Pagamento)
### ═══════════════════════════════════════════════════════════════════

**Cenário:** Ana Oliveira tem 3 boletos vencidos e quer negociar. O síndico propõe um acordo agrupando tudo em um único boleto.

#### Boletos Vencidos:
```
┌─────────────────────────────────────────────────────────────┐
│ BOLETOS VENCIDOS - Ana Oliveira (B/201)                     │
├─────────────────────────────────────────────────────────────┤
│ ☑ Boleto Jan/2026 - R$ 630,00 - Vencido há 45 dias         │
│ ☑ Boleto Fev/2026 - R$ 630,00 - Vencido há 15 dias         │
│ ☑ Boleto Mar/2026 - R$ 630,00 - Vencido há 5 dias          │
│                                                             │
│ TOTAL SELECIONADO: R$ 1.890,00                             │
│                                                             │
│           [AGRUPAR SELECIONADOS]                            │
└─────────────────────────────────────────────────────────────┘
```

#### Processo de Agrupamento:

```dart
// @boleto_service.dart:439-478
Future<void> agruparBoletos(List<String> boletoIds) async {
  // 1. Buscar os boletos selecionados
  final boletos = await _supabase
      .from('boletos')
      .select()
      .inFilter('id', boletoIds);

  // 2. Somar os valores
  double valorTotal = 0;
  for (final b in boletos) {
    valorTotal += (b['valor'] ?? 0).toDouble();
  }
  // valorTotal = 630 + 630 + 630 = 1890.00

  // 3. Atualizar o primeiro boleto com valor agrupado
  await _supabase
      .from('boletos')
      .update({
        'valor': valorTotal,
        'valor_total': valorTotal,
        'tipo': 'Acordo',
        'classe': 'ACORDO(3)',
      })
      .eq('id', boletos.first['id']);

  // 4. Cancelar os demais
  await _supabase
      .from('boletos')
      .update({'status': 'Cancelado por Acordo'})
      .inFilter('id', boletoIds.skip(1).toList());
}
```

#### Resultado:

| Boleto | Status | Valor |
|--------|--------|-------|
| Jan/2026 | `Ativo` (agrupado) | R$ 1.890,00 |
| Fev/2026 | `Cancelado por Acordo` | R$ 0,00 |
| Mar/2026 | `Cancelado por Acordo` | R$ 0,00 |

---

### ═══════════════════════════════════════════════════════════════════
### CASO 5: Envio de Boleto por E-mail
### ═══════════════════════════════════════════════════════════════════

**Cenário:** O síndico quer reenviar o boleto de março para todos os moradores que ainda não pagaram.

#### Processo:

**1. Seleção de Boletos**
```
Gestão de Boletos → Filtrar "A Vencer" → Selecionar todos → "Enviar por E-mail"
```

**2. Lógica de Envio**

```dart
// @boleto_service.dart:305-390
Future<void> enviarBoletosPorEmail({
  required String condominioId,
  List<String>? boletoIds,
}) async {
  // 1. Buscar boletos
  var boletos = await _supabase
      .from('boletos')
      .select('id, unidade_id, sacado, valor, data_vencimento')
      .inFilter('id', boletoIds);

  // 2. Determinar email de envio
  // Verifica se o pagador é inquilino ou proprietário
  for (var b in boletos) {
    String unidId = b['unidade_id'];
    String pagador = pagadorMap[unidId] ?? 'proprietario';

    if (pagador == 'inquilino') {
      email = emailsInquilinos[unidId] ?? emailsProprietarios[unidId];
    } else {
      email = emailsProprietarios[unidId] ?? emailsInquilinos[unidId];
    }
  }

  // 3. Enviar em lote
  final BoletoEmailService emailService = BoletoEmailService();
  await emailService.enviarLote(finalBoletosParaEmail);
}
```

**3. Email Enviado**

```
┌─────────────────────────────────────────────────────────────┐
│ Para: maria.silva@email.com                                 │
│ Assunto: Boleto Condomínio Gaia Prime - Março/2026          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ Prezada Maria Silva,                                        │
│                                                             │
│ Segue em anexo o boleto referente ao mês 03/2026.           │
│                                                             │
│ Valor: R$ 630,00                                            │
│ Vencimento: 10/03/2026                                      │
│ Unidade: A/101                                              │
│                                                             │
│ Código de Barras:                                           │
│ 00190000090123456789012345678901234567890123               │
│                                                             │
│ [Botão: Copiar Código de Barras]                            │
│                                                             │
│ Link do PDF: https://asaas.com/bankSlip/pay_abc123         │
│                                                             │
│ Atenciosamente,                                             │
│ Condomínio Gaia Prime                                       │
└─────────────────────────────────────────────────────────────┘
```

---

### ═══════════════════════════════════════════════════════════════════
### CASO 6: Boleto Avulso (Despesa Extraordinária)
### ═══════════════════════════════════════════════════════════════════

**Cenário:** O morador do A/103 alugou o salão de festas por R$ 500,00. O síndico precisa gerar uma cobrança avulsa.

#### Passo a Passo:

**1. Acesso**
```
Gestão de Boletos → Botão (+) → Cobrança Avulsa
```

**2. Formulário**

```
┌─────────────────────────────────────────────────────────────┐
│           COBRANÇA AVULSA / DESPESA EXTRA                   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ [CADASTRAR]  [PESQUISAR]  ← Abas                            │
│                                                             │
│ Conta Contábil: [▼ Aluguel Salão]                          │
│                                                             │
│ Pesquisar unidade: [A/103] 🔍                              │
│                                                             │
│ Mês/Ano: [03/2026]                                          │
│                                                             │
│ Descrição:                                                  │
│ [Aluguel do salão de festas para festa de aniversário]     │
│                                                             │
│ Cobrar: [▼ Boleto Avulso]                                  │
│         (Opções: "Junto a Taxa Cond." ou "Boleto Avulso")  │
│                                                             │
│ Dia de Vencimento: [20]                                     │
│                                                             │
│ Valor por Unid. R$: [500,00]                               │
│                                                             │
│ ☐ Recorrente                                               │
│                                                             │
│ Anexo: [📎 Anexar comprovante]                             │
│                                                             │
│ ☑ Enviar para Registro (ASAAS)                             │
│ ☑ Disparar por E-mail                                      │
│                                                             │
│           [CANCELAR]  [GERAR BOLETO]                        │
└─────────────────────────────────────────────────────────────┘
```

**3. Resultado**

| Campo | Valor |
|-------|-------|
| `tipo` | `Avulso` |
| `valor` | `500.00` |
| `classe` | `Aluguel Salão` |
| `data_vencimento` | `2026-03-20` |
| `status` | `Ativo` |

---

### ═══════════════════════════════════════════════════════════════════
### CASO 7: Registro Individual de Boleto no ASAAS
### ═══════════════════════════════════════════════════════════════════

**Cenário:** Um boleto foi gerado sem registro automático e agora precisa ser registrado.

#### Processo:

```dart
// @boleto_service.dart:396-413
Future<Map<String, dynamic>> registrarBoletoNoAsaas(String boletoId) async {
  final api = LaravelApiService();
  final response = await api.post('/asaas/boletos/registrar-individual', {
    'boletoId': boletoId,
  });
}
```

#### Backend PHP:

```php
// @BoletoService.php:35-139
public function registrarBoletoNoAsaas(string $boletoId): array
{
    // 1. Buscar boleto no Supabase
    $boleto = $this->supabase->api()->get("/boletos?id=eq.{$boletoId}");

    // 2. Buscar morador (sacado)
    $morador = $this->supabase->api()->get("/moradores?id=eq.{$sacadoId}");

    // 3. Criar cliente no ASAAS se não existir
    if (!$morador['asaas_customer_id']) {
        $cliente = $this->clientService->criarOuBuscar([
            'name' => $morador['nome'],
            'cpfCnpj' => $morador['cpf_cnpj'],
            'email' => $morador['email'],
        ]);
    }

    // 4. Criar cobrança BOLETO no ASAAS
    $cobranca = $this->cobrancaService->criar([
        'customer' => $asaasCustomerId,
        'billingType' => 'BOLETO',
        'value' => $boleto['valor_total'],
        'dueDate' => $boleto['data_vencimento'],
        'description' => "Boleto Ref: {$boleto['referencia']}",
    ]);

    // 5. Obter linha digitável
    $linha = $this->obterLinhaDigitavel($cobranca['id']);

    // 6. Atualizar boleto no Supabase
    $this->supabase->api()->patch("/boletos?id=eq.{$boletoId}", [
        'asaas_payment_id' => $cobranca['id'],
        'bank_slip_url' => $cobranca['bankSlipUrl'],
        'identification_field' => $linha['identificationField'],
        'bar_code' => $linha['barCode'],
        'boleto_registrado' => 'SIM',
        'status' => 'Registrado',
    ]);
}
```

---

## 5. Integração com ASAAS

### Configuração de Juros e Multa

```php
// @CobrancaService.php:38-46
'fine' => [
    'value' => 2.0,      // 2% de multa
    'type' => 'PERCENTAGE',
],
'interest' => [
    'value' => 1.0,      // 1% ao mês
    'type' => 'PERCENTAGE',
],
```

### Obtenção da Linha Digitável

O ASAAS processa o código de barras de forma assíncrona, então o sistema faz múltiplas tentativas:

```php
// @BoletoService.php:242-255
public function obterLinhaDigitavel(string $paymentId, int $tentativas = 3, int $esperaSegundos = 2): array
{
    for ($i = 0; $i < $tentativas; $i++) {
        if ($i > 0) {
            sleep($esperaSegundos);  // Aguarda processamento
        }
        $resultado = $this->http->get("/payments/{$paymentId}/identificationField");
        if (!empty($resultado['identificationField'])) {
            return $resultado;
        }
    }
    return $resultado ?? [];
}
```

---

## 6. Filtros e Pesquisas Disponíveis

### Filtros na Tela de Gestão de Boletos

| Filtro | Campo | Valores |
|--------|-------|---------|
| **Tipo de Emissão** | `tipo` | `Todos`, `Mensal`, `Avulso`, `Acordo` |
| **Situação** | `status` | `Todos`, `A vencer`, `Pago`, `Vencido`, `Cancelado acordo` |
| **Período** | `data_vencimento` | Intervalo de datas |
| **Nosso Número** | `nosso_numero` | Busca exata |
| **Pesquisa Livre** | `bloco_unidade` ou `sacadoNome` | Busca parcial |

### Query Implementada

```dart
// @boleto_service.dart:24-81
var query = _supabase
    .from('boletos')
    .select('*, contas_bancarias(banco)')
    .eq('condominio_id', condominioId);

if (situacao == 'A vencer') {
  query = query
      .eq('status', 'Ativo')
      .gte('data_vencimento', DateTime.now().toIso8601String());
}

if (dataInicio != null) {
  query = query.gte('data_vencimento', dataInicio);
}

if (nossoNumero != null) {
  query = query.eq('nosso_numero', nossoNumero);
}
```

---

## 7. Resumo das Operações Disponíveis

### Para o Representante (Síndico)

| Operação | Método | Arquivo |
|----------|--------|---------|
| Listar Boletos | `listarBoletos()` | `boleto_service.dart:14` |
| Gerar Cobrança Mensal | `gerarCobrancaMensal()` | `boleto_service.dart:193` |
| Receber Boleto | `receberBoleto()` | `boleto_service.dart:136` |
| Excluir Boleto | `excluirBoleto()` | `boleto_service.dart:171` |
| Agrupar Boletos | `agruparBoletos()` | `boleto_service.dart:439` |
| Enviar por Email | `enviarBoletosPorEmail()` | `boleto_service.dart:305` |
| Registrar no ASAAS | `registrarBoletoNoAsaas()` | `boleto_service.dart:396` |
| Listar Contas Bancárias | `listarContasBancarias()` | `boleto_service.dart:484` |
| Listar Unidades | `listarUnidades()` | `boleto_service.dart:505` |

### Para o Morador (Proprietário/Inquilino)

| Operação | Descrição |
|----------|-----------|
| Ver Boleto PDF | Abre link do ASAAS no navegador |
| Copiar Código de Barras | Copia linha digitável para clipboard |
| Compartilhar Boleto | Envia PDF via apps do celular |
| Ver Composição | Exibe detalhamento do valor |
| Ver Demonstrativo | Mostra despesas do condomínio |

---

## 8. Diagrama de Fluxo Completo

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                    FLUXO COMPLETO DO SISTEMA DE BOLETOS                         │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  ┌─────────────┐                                                                │
│  │  SÍNDICO    │                                                                │
│  └──────┬──────┘                                                                │
│         │                                                                       │
│         ▼                                                                       │
│  ┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐          │
│  │ GERAR COBRANÇA  │────▶│   BACKEND       │────▶│     ASAAS       │          │
│  │    MENSAL       │     │   (Laravel)     │     │   (Gateway)     │          │
│  └─────────────────┘     └────────┬────────┘     └────────┬────────┘          │
│                                   │                       │                    │
│                                   ▼                       ▼                    │
│                          ┌─────────────────┐     ┌─────────────────┐        │
│                          │   SUPABASE      │◀────│  payment_id    │        │
│                          │   (Database)    │     │  bankSlipUrl    │        │
│                          └────────┬────────┘     │  barCode        │        │
│                                   │              │  identification │        │
│                                   │              └─────────────────┘        │
│         ┌─────────────────────────┼─────────────────────────┐              │
│         │                         │                         │              │
│         ▼                         ▼                         ▼              │
│  ┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐       │
│  │   MORADOR       │     │   SÍNDICO       │     │   SÍNDICO       │       │
│  │   Visualiza     │     │   Recebe        │     │   Agrupa        │       │
│  │   (Prop/Inq)    │     │   (Baixa)       │     │   (Acordo)      │       │
│  └─────────────────┘     └─────────────────┘     └─────────────────┘       │
│         │                         │                         │              │
│         ▼                         ▼                         ▼              │
│  ┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐       │
│  │ Ver PDF         │     │ status = Pago   │     │ tipo = Acordo   │       │
│  │ Copiar Código   │     │ data_pagamento  │     │ Cancela outros │       │
│  │ Compartilhar    │     │ valor_total++   │     │ valor soma     │       │
│  └─────────────────┘     └─────────────────┘     └─────────────────┘       │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## 9. Considerações Técnicas Importantes

### 9.1 Tratamento de Erros

O sistema implementa tratamento de erros em todas as camadas:

```dart
// Exemplo no Cubit
try {
  await _service.gerarCobrancaMensal(...);
  emit(state.copyWith(successMessage: 'Cobrança mensal gerada com sucesso!'));
} catch (e) {
  emit(state.copyWith(errorMessage: e.toString()));
}
```

### 9.2 Validações no Backend

```php
// @BoletoController.php:24-31
$request->validate([
    'condominioId' => 'required|string',
    'dataVencimento' => 'required|date_format:Y-m-d',
    'cotaCondominial' => 'required|numeric|min:0',
    'moradores' => 'required|array|min:1',
    'moradores.*.name' => 'required|string',
    'moradores.*.cpfCnpj' => 'required|string',
]);
```

### 9.3 Determinação do Pagador

O sistema verifica automaticamente quem deve receber o boleto:

```dart
// @boleto_service.dart:248-252
final isPagadorInquilino = unidade['nome_pagador_boleto'] == 'inquilino';

final moradorData = (isPagadorInquilino ? inqMap[unidadeId] : propMap[unidadeId])
    ?? propMap[unidadeId]    // Fallback para proprietário
    ?? inqMap[unidadeId];    // Fallback para inquilino
```

---

## 10. Conclusão

O sistema de boletos do CondoGaia oferece uma solução completa para gestão de cobranças condominiais, com:

- **Integração ASAAS** para emissão e registro de boletos bancários
- **Geração em lote** para cobranças mensais
- **Cobranças avulsas** para despesas extraordinárias
- **Acordos de pagamento** via agrupamento de boletos
- **Baixa manual** com cálculo de juros e multas
- **Envio automático por e-mail**
- **Visualização pelo morador** com PDF, código de barras e demonstrativo

O fluxo está estruturado para atender tanto as necessidades do síndico (gestão) quanto do morador (visualização e pagamento), garantindo transparência e controle sobre todas as operações financeiras do condomínio.
