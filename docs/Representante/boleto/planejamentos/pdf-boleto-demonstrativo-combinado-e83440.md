# PDF de Boleto com Demonstrativo Financeiro Combinado

Implementação de PDF personalizado com 2 páginas: boleto ASAAS + demonstrativo financeiro detalhado do condomínio.

---

## Visão Geral

O sistema atual gera boletos via ASAAS que retornam um PDF padrão (`bankSlipUrl`). Este plano implementa a mesclagem desse PDF com um demonstrativo financeiro personalizado, criando um documento único com:

- **Página 1**: Boleto bancário padrão do ASAAS
- **Página 2**: Demonstrativo financeiro completo do condomínio

---

## Estrutura do PDF Final

### Página 1 - Boleto ASAAS (existente)
- Código de barras / linha digitável
- Dados do sacado
- Valor e vencimento
- Instruções bancárias padrão

### Página 2 - Demonstrativo Financeiro (novo)

```
┌─────────────────────────────────────────────────┐
│  [LOGO]     CONDOMÍNIO RESIDENCIAL XPTO         │
│             CNPJ: 00.000.000/0001-00            │
│  ─────────────────────────────────────────────  │
│  DEMONSTRATIVO FINANCEIRO                       │
│  Referência: 04/2026  |  Unidade: A/101        │
│  Vencimento: 10/04/2026                         │
│  ─────────────────────────────────────────────  │
│  SACADO: João da Silva                          │
│  ─────────────────────────────────────────────  │
│  COMPOSIÇÃO DO VALOR:                           │
│  ├─ Cota Condominial............. R$  450,00   │
│  ├─ Fundo de Reserva............. R$   45,00   │
│  ├─ Taxa de Controle............. R$   15,00   │
│  ├─ Rateio de Água............... R$  120,00   │
│  │   Leitura anterior: 100 m³                    │
│  │   Leitura atual: 120 m³                       │
│  │   Consumo: 20 m³                              │
│  ├─ Manutenção Elevador.......... R$   30,00   │
│  ├─ Multa por Infração........... R$   50,00   │
│  ├─ Desconto..................... R$  -20,00   │
│  ─────────────────────────────────────────────  │
│  VALOR TOTAL..................... R$  690,00   │
│  ─────────────────────────────────────────────  │
│  DADOS BANCÁRIOS (opcional):                    │
│  Banco: 001 - Banco do Brasil                   │
│  Agência: 1234-5                                │
│  Conta: 12345-6                                 │
│  PIX: cnpj@condominio.com.br                    │
│  ─────────────────────────────────────────────  │
│  Administrado por: CondoGaia                    │
└─────────────────────────────────────────────────┘
```

---

## Dados Necessários

### Já disponíveis no Supabase (tabela `boletos`)
| Campo | Descrição |
|-------|-----------|
| `cota_condominial` | Valor fixo mensal |
| `fundo_reserva` | Percentual sobre cota |
| `controle` | Taxa administrativa |
| `rateio_agua` | Valor do rateio |
| `multa_infracao` | Multas aplicadas |
| `desconto` | Descontos concedidos |
| `valor_total` | Soma de todos |

### Dados a buscar do condomínio (tabela `condominios`)
| Campo | Uso |
|-------|-----|
| `nome_condominio` | Cabeçalho |
| `cnpj` | Cabeçalho |
| `logo_url` | Logo (se existir) |
| `banco`, `agencia`, `conta` | Dados bancários |
| `pix` | Chave PIX |

### Dados de despesas variáveis (tabela `despesas`)
| Campo | Uso |
|-------|-----|
| `descricao` | Nome da despesa |
| `valor` | Valor rateado |
| `categoria` | Tipo de despesa |

### Dados de leitura de água (tabela `leituras_agua`)
| Campo | Uso |
|-------|-----|
| `leitura_anterior` | Consumo anterior |
| `leitura_atual` | Consumo atual |
| `consumo_m3` | Diferença |

---

## Arquitetura Técnica

### Backend (Laravel/PHP)

```
Backend/app/
├── Asaas/Boleto/
│   ├── BoletoService.php          (existente - modificar)
│   └── BoletoController.php       (existente - modificar)
├── Pdf/
│   ├── PdfService.php             (novo - geração de PDF)
│   ├── PdfDemonstrativoService.php (novo - demonstrativo)
│   └── templates/
│       └── demonstrativo_financeiro.html (template)
└── Http/Controllers/
    └── BoletoPdfController.php    (novo - endpoint)
```

### Dependências PHP (composer.json)

```json
{
    "require": {
        "dompdf/dompdf": "^2.0",
        "fpdf/fpdi": "^2.0"
    }
}
```

- **dompdf**: Gerar PDF do demonstrativo a partir de HTML
- **fpdi**: Mesclar PDFs (ASAAS + demonstrativo)

---

## Fluxo de Processamento

```
┌──────────────────────────────────────────────────────────────┐
│                    REQUISIÇÃO DO APP                          │
│              GET /api/asaas/boletos/{id}/pdf-completo        │
└──────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────┐
│  1. BUSCAR DADOS DO BOLETO                                   │
│     - Boleto no Supabase (tabela boletos)                    │
│     - Condomínio (tabela condominios)                        │
│     - Despesas do mês (tabela despesas)                      │
│     - Leitura de água (tabela leituras_agua)                 │
└──────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────┐
│  2. BAIXAR PDF DO ASAAS                                      │
│     - GET bankSlipUrl                                        │
│     - Salvar temporariamente                                  │
└──────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────┐
│  3. GERAR PDF DO DEMONSTRATIVO                               │
│     - Renderizar template HTML com dados                     │
│     - Converter para PDF via dompdf                          │
└──────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────┐
│  4. MESCLAR PDFs                                             │
│     - Adicionar página do ASAAS                              │
│     - Adicionar página do demonstrativo                      │
│     - Gerar PDF final único                                   │
└──────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────┐
│  5. RETORNAR PDF                                             │
│     - Stream para download                                   │
│     - Ou retornar URL temporária                             │
└──────────────────────────────────────────────────────────────┘
```

---

## Endpoints da API

### Novo Endpoint

```
GET /api/asaas/boletos/{boletoId}/pdf-completo
```

**Resposta:**
- Content-Type: `application/pdf`
- Body: PDF binário

**Headers:**
```
Content-Disposition: attachment; filename="boleto_condominio_04_2026_A101.pdf"
```

### Endpoint Existente (mantido)

```
GET /api/asaas/boletos/{paymentId}/pdf
```
Retorna apenas URL do PDF ASAAS (para casos especiais).

---

## Implementação em Etapas

### Etapa 1: Preparação do Ambiente
**Tempo estimado:** 30 min

- [ ] Instalar `dompdf/dompdf` via composer
- [ ] Instalar `fpdf/fpdi` via composer
- [ ] Criar diretório `app/Pdf/`
- [ ] Criar diretório `app/Pdf/templates/`

### Etapa 2: Serviço de Geração de PDF
**Tempo estimado:** 2h

- [ ] Criar `PdfService.php` (classe base)
- [ ] Criar `PdfDemonstrativoService.php` (específico)
- [ ] Criar template HTML `demonstrativo_financeiro.html`
- [ ] Implementar método `gerarDemonstrativo()`

### Etapa 3: Serviço de Mesclagem de PDFs
**Tempo estimado:** 1h30

- [ ] Criar método `mesclarPdfs()` em `PdfService.php`
- [ ] Implementar download do PDF ASAAS
- [ ] Implementar mesclagem via FPDI

### Etapa 4: Integração com BoletoService
**Tempo estimado:** 1h

- [ ] Adicionar método `obterPdfCompleto()` em `BoletoService.php`
- [ ] Buscar dados do condomínio
- [ ] Buscar despesas variáveis do mês
- [ ] Buscar leitura de água (se aplicável)

### Etapa 5: Controller e Rota
**Tempo estimado:** 30 min

- [ ] Criar endpoint `GET /api/asaas/boletos/{id}/pdf-completo`
- [ ] Adicionar rota em `routes/api.php`
- [ ] Implementar retorno do PDF

### Etapa 6: Integração no Flutter
**Tempo estimado:** 1h

- [ ] Modificar `verBoleto()` no cubit
- [ ] Chamar novo endpoint `/pdf-completo`
- [ ] Abrir PDF no visualizador do sistema

### Etapa 7: Testes
**Tempo estimado:** 1h

- [ ] Testar geração do demonstrativo
- [ ] Testar mesclagem de PDFs
- [ ] Testar download no app
- [ ] Validar layout em diferentes tamanhos de papel

---

## Template HTML do Demonstrativo

Estrutura base do template (`demonstrativo_financeiro.html`):

```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <style>
        body { font-family: Arial, sans-serif; font-size: 11pt; }
        .header { text-align: center; border-bottom: 2px solid #333; padding-bottom: 10px; }
        .logo { max-width: 80px; max-height: 60px; }
        .section { margin: 15px 0; }
        .item { display: flex; justify-content: space-between; padding: 5px 0; border-bottom: 1px dotted #ccc; }
        .total { font-weight: bold; font-size: 14pt; border-top: 2px solid #333; margin-top: 10px; padding-top: 10px; }
        .footer { margin-top: 20px; font-size: 9pt; color: #666; text-align: center; }
    </style>
</head>
<body>
    <div class="header">
        <!-- Logo e dados do condomínio -->
    </div>
    
    <div class="section">
        <h3>DEMONSTRATIVO FINANCEIRO</h3>
        <!-- Referência, unidade, vencimento -->
    </div>
    
    <div class="section">
        <h4>COMPOSIÇÃO DO VALOR</h4>
        <!-- Lista de valores -->
    </div>
    
    <div class="total">
        <!-- Valor total -->
    </div>
    
    <div class="footer">
        <!-- Dados bancários e rodapé -->
    </div>
</body>
</html>
```

---

## Tratamento de Casos Especiais

### Boleto sem PDF ASAAS
- Retornar apenas demonstrativo financeiro
- Mensagem: "Boleto em processamento. Demonstrativo disponível."

### Condomínio sem logo
- Exibir apenas nome e CNPJ
- Layout adaptado sem espaço para imagem

### Sem despesas variáveis
- Mostrar apenas valores fixos
- Ocultar seção de despesas extras

### Sem leitura de água
- Mostrar apenas valor do rateio
- Ocultar detalhes de consumo

---

## Cache e Performance

### Estratégia de Cache
```php
// Cache do PDF gerado por 24 horas
$cacheKey = "pdf_completo_{$boletoId}";
$cacheTTL = 60 * 60 * 24; // 24 horas
```

### Otimizações
- PDF gerado sob demanda e cacheado
- Revalidação quando status do boleto muda
- Limpeza de cache ao pagar/cancelar boleto

---

## Segurança

### Validações
- Boleto pertence ao usuário logado
- Condomínio existe e está ativo
- Rate limiting no endpoint (evitar abuso)

### Headers de Segurança
```
X-Content-Type-Options: nosniff
Content-Security-Policy: default-src 'none'
```

---

## Checklist de Implementação

### Backend
- [ ] Instalar dependências PHP
- [ ] Criar estrutura de diretórios
- [ ] Implementar PdfService
- [ ] Implementar PdfDemonstrativoService
- [ ] Criar template HTML
- [ ] Modificar BoletoService
- [ ] Criar endpoint

### Flutter
- [ ] Modificar cubit para chamar novo endpoint
- [ ] Implementar visualização de PDF
- [ ] Tratar erros

### Testes
- [ ] Teste unitário PdfService
- [ ] Teste de integração do endpoint
- [ ] Teste visual do PDF
- [ ] Teste no app Flutter

---

## Estimativa Total

| Etapa | Tempo |
|-------|-------|
| Preparação | 30 min |
| Geração PDF | 2h |
| Mesclagem | 1h30 |
| Integração | 1h |
| Controller | 30 min |
| Flutter | 1h |
| Testes | 1h |
| **Total** | **~7h30** |

---

## Próximos Passos

1. Confirmar estrutura de dados no Supabase (tabelas existentes)
2. Validar campos disponíveis em `condominios`
3. Verificar se tabela `leituras_agua` existe
4. Iniciar implementação da Etapa 1
