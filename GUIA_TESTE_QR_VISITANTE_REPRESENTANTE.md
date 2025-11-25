## ✅ GUIA DE TESTES - QR CODE VISITANTE REPRESENTANTE

### 📋 Checklist de Implementação Concluída

#### ✅ FASE 1: Serviço de Geração
- [x] `QrCodeGenerationService` criado em `lib/services/qr_code_generation_service.dart`
- [x] Função `gerarESalvarQRCode()` implementada
- [x] Upload para bucket `qr_codes` configurado
- [x] Função `salvarURLnaBancoDados()` implementada
- [x] Função `obterURLQRCode()` implementada
- [x] Função `regenerarQRCode()` implementada

#### ✅ FASE 2: Integração na Criação
- [x] `VisitantePortariaService.insertVisitante()` modificado
- [x] Geração automática de QR code após inserção
- [x] Salvamento assíncrono (não bloqueia fluxo)
- [x] Método `_gerarQRCodeAsync()` adicionado

#### ✅ FASE 3: Widget de Exibição
- [x] `QrCodeDisplayWidget` criado em `lib/widgets/qr_code_display_widget.dart`
- [x] Exibe imagem QR code da URL salva
- [x] Botão de compartilhar implementado
- [x] Loading indicator durante compartilhamento
- [x] Dialog para visualizar QR ampliado
- [x] Tratamento de erros (fallback)

#### ✅ FASE 4: Atualização do Card
- [x] `_buildAutorizadoCard()` atualizado
- [x] Integração com `QrCodeDisplayWidget`
- [x] Remoção de geração dinâmica

---

### 🧪 PASSO A PASSO DO TESTE

#### **TESTE 1: Criar Novo Visitante Representante**

1. Abra o App CondoGaia
2. Navegue para: **Portaria → Representante**
3. Selecione uma unidade
4. Preencha o formulário de novo visitante:
   - Nome: "João Silva Teste"
   - CPF: "123.456.789-00"
   - Celular: "(85) 98765-4321"
   - Dias/Horários: "Segunda a Sexta 08:00-18:00"
5. Clique em **Salvar/Registrar**

**✓ Resultado esperado:**
- Visitante é criado com sucesso
- Mensagem "Visitante cadastrado!" aparece

---

#### **TESTE 2: Verificar Geração de QR Code**

1. Após criar o visitante, aguarde **2-3 segundos** (processamento assíncrono)
2. Abra a aba **"Autorizados por Unidade"**
3. Expanda a unidade do visitante criado

**✓ Resultado esperado:**
- Card do visitante aparece com:
  - ✅ Nome: "João Silva Teste"
  - ✅ CPF: "123***"
  - ✅ Informações adicionais (criado por, acesso, etc)
  - ✅ Widget QR Code com imagem visível

---

#### **TESTE 3: Validar Imagem QR Code**

1. No card do visitante, localize a seção "QR Code"
2. Verifique se a imagem QR code está renderizando

**Verificações:**
- [ ] Imagem QR code está visível (200x200px)
- [ ] Imagem não tem erros de carregamento
- [ ] Está com status "QR Code gerado com sucesso" (verde)
- [ ] Clique na imagem para ampliar (deve abrir dialog)

---

#### **TESTE 4: Testar Compartilhamento via Botão**

1. No card do visitante, clique em **"Compartilhar QR Code"**

**Verificações:**
- [ ] Botão fica com loader durante compartilhamento
- [ ] Abre menu de compartilhamento nativo (Android/iOS)
- [ ] Pode selecionar app (WhatsApp, Email, SMS, etc)
- [ ] Mensagem de sucesso aparece: "QR Code compartilhado com sucesso!"
- [ ] Imagem do QR code é enviada corretamente

---

#### **TESTE 5: Dialog Ampliado**

1. Clique **na imagem QR code** para ampliar
2. Um dialog deve abrir mostrando:
   - Título: "QR Code - João Silva Teste"
   - Botão para fechar (X)
   - Imagem maior (300x300px)
   - Botão "Compartilhar QR Code"

**Verificações:**
- [ ] Dialog abre corretamente
- [ ] Botão fechar funciona
- [ ] Compartilhar dentro do dialog funciona
- [ ] Imagem ampliada está clara

---

#### **TESTE 6: Validar Banco de Dados**

1. Abra Supabase Console
2. Vá para: **SQL Editor**
3. Execute:

```sql
SELECT id, nome, cpf, qr_code_url 
FROM autorizados_visitantes_portaria_representante 
WHERE nome = 'João Silva Teste'
ORDER BY created_at DESC;
```

**✓ Resultado esperado:**
- [ ] Visitante aparece na tabela
- [ ] Campo `qr_code_url` contém URL válida
- [ ] URL segue formato: `https://[project].supabase.co/storage/v1/object/public/qr_codes/qr_*.png`

---

#### **TESTE 7: Validar Arquivo no Storage**

1. No Supabase, vá para: **Storage → qr_codes**

**✓ Resultado esperado:**
- [ ] Arquivo PNG do QR code está salvo
- [ ] Nome segue padrão: `qr_joao_silva_teste_[timestamp]_[uuid].png`
- [ ] Arquivo tem ~5-10KB
- [ ] Arquivo é acessível (URL pública)

---

#### **TESTE 8: Atualizar Visitante (Reutilizar QR)**

1. Edite o visitante criado (mudar alguns dados)
2. Clique em Salvar

**✓ Resultado esperado:**
- [ ] QR code continua o mesmo (reutilização)
- [ ] URL em `qr_code_url` não muda
- [ ] Card exibe o mesmo QR code

---

#### **TESTE 9: Visitante sem QR Code (Fallback)**

1. Crie visitante diretamente no banco (SQL) sem `qr_code_url`
2. Abra o app e vá para "Autorizados por Unidade"

**✓ Resultado esperado:**
- [ ] Card exibe "Gerando QR Code..."
- [ ] Spinner de loading aparece
- [ ] Após ~5s, QR code é gerado e aparece

---

#### **TESTE 10: Múltiplos Visitantes**

1. Crie 3-4 visitantes diferentes
2. Cada um deve ter QR code único

**✓ Resultado esperado:**
- [ ] Cada card mostra QR code diferente
- [ ] Todos compartilham corretamente
- [ ] Nenhum conflito de arquivo

---

### ⚠️ Checklist de Erros Comuns

- [ ] Erro: "Bucket qr_codes não encontrado"
  - **Solução**: Criar bucket no Supabase Storage
  
- [ ] Erro: "QR code não está disponível"
  - **Solução**: Aguardar processamento assíncrono ou verificar logs
  
- [ ] Imagem com erro (404)
  - **Solução**: Verificar se arquivo foi realmente salvo no Storage
  
- [ ] Compartilhamento não funciona
  - **Solução**: Verificar se `qr_code_helper.dart` tem função `compartilharQRURL()`

---

### 📊 Logs Esperados no Console

```
🔄 [QR Code] Iniciando geração para: João Silva Teste
📋 [QR Code] Dados: {"id":"...", "nome":"João Silva Teste", ...}
🖼️ [QR Code] Gerando imagem...
☁️ [QR Code] Uploadando para bucket "qr_codes"...
📤 [Storage] Upload concluído: qr_joao_silva_teste_1732583400_a7f3.png
🔗 [Storage] URL pública: https://...
💾 [BD] Salvando URL para visitante: ...
✅ [BD] URL salva com sucesso
✅ [QR Code] Geração concluída: https://...
```

---

### 🚀 Próximas Fases (Após Validação)

- **FASE 7**: Migração para visitantes existentes sem QR code
- **FASE 8**: Adicionar QR code para visitantes no tab "Visitantes Cadastrados"

---

### 💡 Dicas de Debug

1. **Verificar logs do console:**
   ```bash
   flutter logs
   ```

2. **Testar geração de QR manualmente:**
   - Abrir `QrCodeGenerationService`
   - Chamar `gerarESalvarQRCode()` com dados de teste

3. **Verificar URL da imagem:**
   - Copiar URL do QR code do banco
   - Abrir em navegador (deve mostrar QR como imagem PNG)

4. **Simular erro de rede:**
   - Usar DevTools do Supabase para simular timeout
   - Verificar se fallback funciona

---

### 📝 Notas Importantes

- QR Code é gerado **uma única vez** após criação
- Se regenerar, sobrescreve arquivo anterior
- URL é salva em `qr_code_url` para rápido acesso
- Compartilhamento usa a URL salva (sem gerar de novo)
- Compatível com WhatsApp, Email, SMS, etc

---

**Status**: Pronto para Testes ✅
**Data**: 25 de Novembro, 2025
**Versão**: v1.0
