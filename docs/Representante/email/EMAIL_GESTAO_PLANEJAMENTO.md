# Feature de Gestão de Email - Planejamento de Implementação Final

> **Última atualização:** Março 2026
> **Status:** Backend 95% pronto | Flutter 100% pronto

---

## Visão Geral do Status Real

A feature de **Gestão de Email** está **QUASE PRONTA para produção**. Ao contrário do que parecia inicialmente, o backend Laravel já está implementado e funcional. O que falta é basicamente **testar e validar a integração ponta-a-ponta**.

---

## 1. O Que JÁ ESTÁ Implementado

### 1.1 Frontend Flutter ✅ 100%

| Componente | Status | Arquivo |
|------------|--------|---------|
| UI da tela de email | ✅ | `email_gestao_screen.dart` |
| Gerenciamento de estado | ✅ | `email_gestao_cubit.dart` + `email_gestao_state.dart` |
| Modelos de dados | ✅ | `RecipientModel`, `EmailModeloModel`, `EmailAttachmentModel` |
| Service Flutter | ✅ | `email_gestao_service.dart` |
| Integração Supabase | ✅ | Busca de destinatários e modelos |
| LaravelApiService | ✅ | Cliente HTTP para Laravel |
| Seleção de destinatários | ✅ | Filtros e checkboxes |
| Modelos salvos (CRUD) | ✅ | Tabela `email_modelos` no Supabase |
| Anexos de imagem | ✅ | Cross-platform (Uint8List + Base64) |

### 1.2 Backend Laravel ✅ 95%

| Componente | Status | Arquivo |
|------------|--------|---------|
| **Rotas API** | ✅ | `routes/api.php` - 3 endpoints de gestão |
| **Controller** | ✅ | `app/Resend/Gestao/GestaoEmailController.php` |
| **Service** | ✅ | `app/Resend/Gestao/GestaoEmailService.php` |
| **HTTP Client** | ✅ | `app/Shared/ResendHttpClient.php` |
| **Template HTML** | ✅ | `resources/views/emails/gestao_circular.blade.php` |
| **Configuração** | ✅ | `config/resend.php` |
| **API Key** | ✅ | Configurada no `.env` |
| **Validação** | ✅ | Validação de payload nos controllers |
| **Tratamento de erros** | ✅ | Try/catch com mensagens de erro |
| **Script de testes** | ✅ | `tests/Resend/01_email_gestao.php` |

### 1.3 Módulos de Email Relacionados (também implementados)

| Módulo | Controller | Service | Status |
|--------|------------|---------|--------|
| **Boleto** | `BoletoEmailController` | `BoletoEmailService` | ✅ |
| **Cobrança** | `CobrancaEmailController` | `CobrancaEmailService` | ✅ |
| **Notificação** | `NotificacaoEmailController` | `NotificacaoEmailService` | ✅ |

---

## 2. Arquitetura Atual

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           FLUTTER APP                                    │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │ EmailGestaoScreen                                                │    │
│  │   → EmailGestaoCubit.sendEmail()                                 │    │
│  │     → EmailGestaoService.sendEmail()                             │    │
│  │       → LaravelApiService.post('/resend/gestao/em-massa')        │    │
│  └─────────────────────────────────────────────────────────────────┘    │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │ HTTP POST (Bearer Token)
                                     ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                          LARAVEL BACKEND                                 │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │ POST /api/resend/gestao/em-massa                                 │    │
│  │   → GestaoEmailController.emMassa()                              │    │
│  │     → GestaoEmailService.enviarEmMassa()                         │    │
│  │       → View::make('emails.gestao_circular') → HTML              │    │
│  │       → ResendHttpClient.sendBatch()                             │    │
│  └─────────────────────────────────────────────────────────────────┘    │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │ HTTP POST (API Key Resend)
                                     ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                            RESEND API                                    │
│  POST /emails/batch → Envio individualizado para cada destinatário      │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 3. O Que REALMENTE Falta

### 3.1 Validação e Testes - Prioridade ALTA

#### Passo 1: Verificar se o backend está rodando

```bash
cd Backend
php artisan serve
```

#### Passo 2: Verificar se as rotas estão registradas

```bash
php artisan route:list --path=resend/gestao
```

**Esperado:** Ver 3 rotas POST listadas:
- `POST /api/resend/gestao/circular`
- `POST /api/resend/gestao/aviso`
- `POST /api/resend/gestao/em-massa`

#### Passo 3: Executar script de testes

```bash
cd Backend
TOKEN=$(php artisan tinker --execute="echo User::first()->createToken('test')->plainTextToken")
TOKEN=$TOKEN php tests/Resend/01_email_gestao.php
```

#### Passo 4: Verificar no Resend Dashboard

Acessar [resend.com/emails](https://resend.com/emails) e confirmar que os emails foram enviados.

---

### 3.2 Validação do Domínio - Prioridade ALTA

O domínio `condogaia.com.br` precisa estar **verificado no Resend** para enviar emails reais.

**Como verificar:**
1. Acessar [resend.com/domains](https://resend.com/domains)
2. Adicionar o domínio `condogaia.com.br`
3. Configurar os registros DNS indicados (SPF, DKIM, DMARC)
4. Aguardar verificação (pode levar até 48h)

**Para testes:** Usar `delivered@resend.dev` (email de teste oficial do Resend)

---

### 3.3 Conectar Flutter ao Backend - Prioridade MÉDIA

O Flutter já tem o `LaravelApiService` implementado, mas precisa garantir que:

1. **URL do backend está correta** no `.env` do Flutter:
   ```
   LARAVEL_API_URL=http://localhost:8000/api
   ```

2. **Token Sanctum está sendo enviado** corretamente nas requisições

3. **Payload está no formato esperado** pelo backend

---

### 3.4 Melhorias para Produção - Prioridade BAIXA

| Melhoria | Descrição | Benefício |
|----------|-----------|-----------|
| **Logs de email** | Tabela `email_logs` no banco | Auditoria e rastreabilidade |
| **Queue** | Processamento assíncrono | Não bloqueia a UI |
| **Rate Limiting** | Controle de envio diário | Evita bloqueio do Resend |
| **Métricas** | Tracking de abertura | Dashboard de eficácia |

---

## 4. Checklist para Colocar em Produção

### Fase 1: Validação Local (2-4 horas)

- [ ] Iniciar servidor Laravel (`php artisan serve`)
- [ ] Verificar rotas (`php artisan route:list --path=resend`)
- [ ] Executar script de testes (`php tests/Resend/01_email_gestao.php`)
- [ ] Verificar emails no Resend Dashboard
- [ ] Testar envio com anexo
- [ ] Testar múltiplos destinatários

### Fase 2: Validação do Domínio (1-2 dias)

- [ ] Verificar domínio no Resend
- [ ] Configurar DNS (SPF, DKIM, DMARC)
- [ ] Aguardar propagação DNS
- [ ] Testar envio para emails reais

### Fase 3: Integração Flutter (2-4 horas)

- [ ] Configurar URL do backend no Flutter
- [ ] Testar fluxo completo: App → Backend → Resend
- [ ] Validar tratamento de erros no Flutter
- [ ] Testar anexos

### Fase 4: Deploy (4-8 horas)

- [ ] Deploy do backend em servidor público
- [ ] Configurar HTTPS
- [ ] Atualizar URL no Flutter
- [ ] Testar em ambiente de produção

---

## 5. Configuração Necessária

### 5.1 Variáveis de Ambiente (Backend)

```env
# Já configurado no Backend/.env
RESEND_API_KEY=re_xxxxxxxxxxxx
RESEND_FROM_EMAIL=noreply@condogaia.com.br
RESEND_FROM_NAME=CondoGaia
```

### 5.2 Variáveis de Ambiente (Flutter)

```env
# Arquivo .env no Flutter
LARAVEL_API_URL=http://localhost:8000/api
```

---

## 6. Riscos e Soluções

| Risco | Probabilidade | Solução |
|-------|---------------|---------|
| Domínio não verificado | Alta | Configurar DNS corretamente |
| Emails em SPAM | Média | Configurar SPF/DKIM/DMARC |
| Rate limit excedido | Baixa | Implementar Queue + Rate Limiting |
| Falha de autenticação | Média | Verificar token Sanctum |

---

## 7. Arquivos Importantes

### Backend (já existem)

| Arquivo | Função |
|---------|--------|
| `app/Resend/Gestao/GestaoEmailController.php` | Recebe requisições HTTP |
| `app/Resend/Gestao/GestaoEmailService.php` | Lógica de envio |
| `app/Shared/ResendHttpClient.php` | Cliente HTTP para Resend |
| `resources/views/emails/gestao_circular.blade.php` | Template HTML do email |
| `config/resend.php` | Configurações do Resend |
| `routes/api.php` | Rotas da API |
| `tests/Resend/01_email_gestao.php` | Script de testes |

### Flutter (já existem)

| Arquivo | Função |
|---------|--------|
| `lib/features/Representante_Features/email_gestao/screens/email_gestao_screen.dart` | UI |
| `lib/features/Representante_Features/email_gestao/cubit/email_gestao_cubit.dart` | Estado |
| `lib/features/Representante_Features/email_gestao/services/email_gestao_service.dart` | Service |
| `lib/services/laravel_api_service.dart` | Cliente HTTP |

---

## 8. Conclusão

**A feature está 95% pronta!** O backend Laravel já está completamente implementado com:

- ✅ Rotas, Controllers e Services
- ✅ Template HTML profissional
- ✅ Integração com Resend API
- ✅ Suporte a anexos
- ✅ Validação e tratamento de erros

**O que falta:**
1. **Testar localmente** (2-4h)
2. **Verificar domínio no Resend** (1-2 dias para DNS propagar)
3. **Validar integração Flutter → Backend** (2-4h)
4. **Deploy em produção** (4-8h)

**Tempo total estimado para colocar em produção:** 1-2 dias (considerando propagação DNS)
