# 🧪 GUIA DE TESTE - QR Code Implementation

## Objetivo
Validar que a implementação de QR Code está funcionando corretamente em dispositivo real ou emulador.

---

## 📋 Pré-requisitos

- ✅ Flutter instalado e configurado
- ✅ Emulador Android ou dispositivo físico
- ✅ Aplicativo compilado com sucesso
- ✅ Permissões do Android concedidas

---

## 🚀 Passo 1: Compilar e Executar

### Via Terminal

```bash
# Limpar build anterior
flutter clean

# Obter dependências
flutter pub get

# Analisar erros
flutter analyze

# Executar
flutter run
```

### Via Android Studio

1. Abrir projeto em Android Studio
2. Menu: `Run` → `Run 'main.dart'`
3. Selecionar emulador ou dispositivo
4. Aguardar compilação

---

## 🎯 Passo 2: Navegar para Tela de Autorizados

### Cenário 1: Autorizados de Inquilino

1. Abrir app
2. Menu principal → **Portaria** ou **Inquilino**
3. Selecionar/Criar uma **Unidade/Imóvel**
4. Aba: **Autorizados** ou **Inquilino**
5. Visualizar lista de autorizados (ou criar um novo)

### Cenário 2: Autorizados de Representante

1. Abrir app
2. Menu principal → **Portaria** ou **Representante**
3. Selecionar **Representante**
4. Aba: **Autorizados**
5. Visualizar lista de autorizados

---

## 👀 Passo 3: Validar Visualização do QR Code

### Verificar Renderização

```
✅ QR Code visível no card?
   - Tamanho: 180x180 pixels
   - Posição: Abaixo das informações do autorizado
   - Cor: Preto e branco padrão
   
✅ Rótulo visível?
   - Texto: "QR Code de: [Nome do Autorizado]"
   - Tamanho: Pequeno (12pt)
   - Cor: Cinza claro
   
✅ Botões visíveis?
   - "Copiar QR" (azul)
   - "Compartilhar" (verde)
   - Ambos clicáveis
```

### Validar Renderização

- [ ] QR Code aparece no card
- [ ] QR Code tem tamanho apropriado
- [ ] QR Code tem contraste (preto/branco)
- [ ] Rótulo aparece abaixo do QR
- [ ] Dois botões estão visíveis
- [ ] Botões têm cores diferentes (azul vs verde)

---

## 🧪 Passo 4: Testar Cópia de QR Code

### Teste 1: Clicar em "Copiar QR"

1. Encontrar um autorizado com QR Code
2. Clicar no botão **"Copiar QR"**

**Esperado:**
- Botão fica desabilitado (cinza)
- Spinner circular aparece no ícone
- Texto muda para "Copiando..."
- ~1-2 segundos processando
- SnackBar verde aparece: **"QR Code pronto para copiar!"**
- Botão volta a estar habilitado

### Teste 2: Validar Cópia

1. Após copia bem-sucedida, abrir outro app (WhatsApp, Email, etc.)
2. Tentar colar (Ctrl+V ou long press)
3. Verificar se QR foi copiado

**Esperado:**
- QR Code disponível para colar em outros apps
- Tamanho da imagem: ~180x180 pixels

### Checklist

- [ ] Botão responde ao clique
- [ ] Estados de loading aparecem
- [ ] SnackBar de sucesso aparece
- [ ] Nenhum erro no console
- [ ] QR Code pode ser colado em outro app

---

## 📤 Passo 5: Testar Compartilhamento

### Teste 1: Clicar em "Compartilhar"

1. Encontrar um autorizado com QR Code
2. Clicar no botão **"Compartilhar"**

**Esperado:**
- Botão fica desabilitado (cinza)
- Spinner circular aparece no ícone
- Texto muda para "Compartilhando..."
- ~1-2 segundos processando
- Diálogo nativo do sistema abre
- Lista de apps de compartilhamento

### Teste 2: Compartilhar via WhatsApp

1. No diálogo de compartilhamento
2. Selecionar **"WhatsApp"**
3. Selecionar contato ou grupo
4. Enviar

**Esperado:**
- Diálogo de seleção de contato abre
- Mensagem com QR Code é enviada
- Contato recebe imagem PNG com QR Code
- SnackBar verde: **"QR Code pronto para compartilhar!"**

### Teste 3: Compartilhar via Email

1. No diálogo de compartilhamento
2. Selecionar **"Gmail"** ou **"Email"**
3. Completar composição
4. Enviar

**Esperado:**
- Composição de email abre
- QR Code está em anexo
- Email pode ser enviado normalmente
- Destinatário recebe imagem PNG

### Teste 4: Compartilhar via Sistema de Arquivos

1. No diálogo de compartilhamento
2. Selecionar **"Salvar em Arquivos"** ou **"Drive"**
3. Selecionar destino
4. Salvar

**Esperado:**
- Arquivo PNG criado
- Nome: `qr_code_[nome_autorizado].png`
- Arquivo contém QR Code correto

### Checklist

- [ ] Diálogo de compartilhamento abre
- [ ] Estados de loading aparecem
- [ ] SnackBar de sucesso aparece
- [ ] Nenhum erro no console
- [ ] Compartilhamento via WhatsApp funciona
- [ ] Compartilhamento via Email funciona
- [ ] Compartilhamento via Arquivos funciona

---

## 🔍 Passo 6: Validar Dados do QR Code

### Teste: Escanear QR Code

1. Usar app de QR Code scanner (Google Lens, câmera padrão, etc.)
2. Apontar para QR Code do app
3. Escanear

**Esperado:**
- JSON com dados do autorizado
- Conteúdo:
  ```json
  {
    "id": "uuid-autorizado",
    "nome": "Nome Autorizado",
    "cpf_cnpj": "CPF/CNPJ",
    "telefone": "telefone",
    "tipo": "inquilino|representante",
    "unidade": "101",
    "data_autorizacao": "data ISO 8601",
    "timestamp": "timestamp ISO 8601",
    "veiculo": "placa ou null",
    "horario": "horário de acesso"
  }
  ```

### Checklist

- [ ] QR Code escaneia corretamente
- [ ] JSON aparece legível
- [ ] Todos os campos estão presentes
- [ ] Dados correspondem ao autorizado exibido

---

## ⚠️ Passo 7: Testar Erros e Edge Cases

### Teste 1: Autorizado com Dados Inválidos

1. Se houver autorizado com dados muito grandes (> 2953 caracteres)
2. Visualizar card

**Esperado:**
- Mensagem de erro: **"❌ Dados inválidos para gerar QR Code"**
- Container vermelho
- Botões desabilitados

### Teste 2: Clicar Botões Múltiplas Vezes

1. Clicar "Copiar QR" e rapidamente clicar novamente
2. Verificar que não há múltiplas operações

**Esperado:**
- Botão desabilitado durante operação
- Apenas uma operação por vez
- Sem erros ou crashes

### Teste 3: Sair e Voltar à Tela

1. Abrir tela de autorizados
2. Ver QR Code
3. Sair (voltar)
4. Voltar à tela

**Esperado:**
- QR Code regenerado
- Sem errors
- Sem memory leaks

### Checklist

- [ ] Dados inválidos exibem erro
- [ ] Botões impedem múltiplos cliques
- [ ] Sem erros ao sair/voltar
- [ ] Sem crashes durante operações

---

## 📊 Passo 8: Validar Logs

### Verificar Console do Flutter

1. Abrir VS Code ou Android Studio
2. Aba: **Debug Console**
3. Procurar por logs de QR Code

**Logs Esperados:**

```
[QR] Gerando imagem QR com tamanho: 200
[QR] Imagem QR gerada com sucesso: 45678 bytes
[Widget] Iniciando cópia do QR Code...
[QR] Iniciando cópia para clipboard...
[QR] QR Code pronto para ser copiado (45678 bytes)
```

ou

```
[Widget] Iniciando compartilhamento do QR Code...
[QR] Iniciando compartilhamento do QR Code...
[QR] QR Code compartilhado com sucesso
```

### Checklist

- [ ] Logs aparecem no console
- [ ] Não há erros ou exceções
- [ ] Sequência de logs é lógica
- [ ] Não há logs de stack trace

---

## 🎯 Passo 9: Teste de Integração Completo

### Fluxo 1: Inquilino → Criar Unidade → Adicionar Autorizado → Ver QR

```
1. Abrir Portaria → Inquilino
2. Criar nova unidade ou selecionar existente
3. Ir para aba "Autorizados"
4. Criar novo autorizado (ou visualizar existente)
5. Descer e ver QR Code
6. Clicar "Copiar QR"
7. Verificar sucesso
8. Clicar "Compartilhar"
9. Escolher WhatsApp
10. Enviar para contato
11. Validar que imagem foi recebida
```

**Resultado Esperado:** ✅ Todas as etapas funcionam sem erros

### Fluxo 2: Representante → Ver Autorizados → Compartilhar QR

```
1. Abrir Portaria → Representante
2. Selecionar representante
3. Aba "Autorizados"
4. Visualizar lista
5. Encontrar autorizado com QR
6. Clicar "Compartilhar"
7. Compartilhar via Email
8. Validar que email foi criado com QR
```

**Resultado Esperado:** ✅ Todas as etapas funcionam sem erros

### Checklist

- [ ] Fluxo 1 completo funciona
- [ ] Fluxo 2 completo funciona
- [ ] Sem crashes durante execução
- [ ] Sem erros no console
- [ ] QR codes compartilhados são válidos

---

## 📋 Resumo do Teste

### Áreas Testadas

| Área | Status | Notas |
|------|--------|-------|
| Visualização de QR | ✅/❌ | |
| Cópia para Clipboard | ✅/❌ | |
| Compartilhamento (WhatsApp) | ✅/❌ | |
| Compartilhamento (Email) | ✅/❌ | |
| Validação de QR | ✅/❌ | |
| Tratamento de Erros | ✅/❌ | |
| Logs | ✅/❌ | |
| Integração Completa | ✅/❌ | |

### Resultado Final

**Status Geral:** ✅ **TESTES PASSARAM** / ❌ **TESTES FALHARAM**

**Observações:**
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

## 🐛 Troubleshooting

### Problema: QR Code não aparece

**Soluções:**
1. Verificar se autorizado tem dados válidos
2. Verificar console para mensagens de erro
3. Limpar build: `flutter clean`
4. Fazer rebuild

### Problema: Botões não funcionam

**Soluções:**
1. Verificar se `share_plus` está instalado: `flutter pub get`
2. Verificar permissões no AndroidManifest.xml
3. Reiniciar emulador/dispositivo
4. Testar com dispositivo diferente

### Problema: Compartilhamento não funciona

**Soluções:**
1. Verificar se app de compartilhamento está instalado (WhatsApp, Gmail)
2. Verificar permissões
3. Verificar logs de erro
4. Testar com app diferente

### Problema: Erros no Console

**Soluções:**
1. Procurar por `[QR]` ou `[Widget]` nos logs
2. Ler mensagem de erro completa
3. Verificar linha de código correspondente
4. Contactar desenvolvedor com screenshot do erro

---

## ✅ Conclusão do Teste

Após completar todos os passos acima:

1. **Documentar resultados** em resumo acima
2. **Notar qualquer problema** encontrado
3. **Reportar bugs** com screenshot e logs
4. **Validar que QR Code funciona** como esperado

**Se todos os testes passarem:** ✅ Implementação pronta para produção

---

*Guia de teste criado em 24/11/2025*
