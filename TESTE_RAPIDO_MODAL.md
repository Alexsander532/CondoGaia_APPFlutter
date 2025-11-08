# 🧪 TESTE RÁPIDO: ABRIR MODAL COM PLANILHA REAL

## 🎯 O que você vai fazer

1. **Abrir o modal** do aplicativo
2. **Selecionar uma planilha real** (a que você passou em imagem)
3. **Ver todos os logs no terminal** enquanto o modal funciona
4. **Clicar em Prosseguir/Importar** para ver o resultado

---

## 🚀 Começar Agora

### **Passo 1: Criar a Planilha Excel**

Crie um arquivo Excel com o nome exato: `planilha_teste.xlsx`

Com os dados baseados na sua imagem:

```
bloco | unidade | fracao_ideal | proprietario_nome_completo | proprietario_cpf | proprietario_cel | proprietario_email | inquilino_nome_completo | inquilino_cpf | inquilino_cel | inquilino_email | nome_imobiliaria | cnpj_imobiliaria | cel_imobiliaria | email_imobiliaria
```

**Copie as linhas abaixo e cole no Excel (em abas separadas):**

**Linha 1 (Cabeçalho):** Use as colunas acima

**Linhas de dados:**

```
A	101	0.05	Nilza Almeida de Araújo	017.104.821-09	(07) 99114-6607	nilza325@gmail.com	Jeniffer Paulina da Silva	418.529.138-77	(18) 90755-3688	jeniffer515000@gmail.com	IMOBILIÁRIA SILVA	25.748.962/0001-00	(11) 9999-9999	contato@silva.com.br
```

(Continue com os dados do CRIAR_PLANILHA_TESTE.sh)

### **Passo 2: Colocar Arquivo no Projeto**

```bash
# Windows CMD
copy planilha_teste.xlsx c:\Users\Alexsander\Desktop\Aplicativos\APPflutter\condogaiaapp\assets\
```

### **Passo 3: Abrir o App com Flutter**

```bash
cd c:\Users\Alexsander\Desktop\Aplicativos\APPflutter\condogaiaapp
flutter run
```

### **Passo 4: Abrir Terminal Lado-a-Lado**

Deixe o terminal aberto onde você rodou `flutter run`. É lá que os logs vão aparecer!

### **Passo 5: No App**

1. Navegue até: **Unidades do Morador** → **Importar Planilha**
2. Clique em **"Selecionar Arquivo"** (passo 1 do modal)
3. Escolha `planilha_teste.xlsx`
4. Clique em **"Prosseguir"** (passo 2 - processamento)

### **Passo 6: Ver os Logs no Terminal**

Enquanto o modal processa, **olhe no terminal** e você verá:

```
═══════════════════════════════════════════════════════════════
🚀 INICIANDO IMPORTAÇÃO DE PLANILHA
═══════════════════════════════════════════════════════════════
📁 Arquivo: planilha_teste.xlsx
⏰ Hora: 2025-11-08 10:30:45.123456

📖 FASE 1: PARSING DO ARQUIVO
───────────────────────────────────────────────────────────────
✓ Arquivo lido com sucesso
✓ Total de linhas encontradas: 8

  📄 Linha 2: Bloco A | Un. 101 | Nilza Almeida de Araújo | CPF: 017***821-09
  📄 Linha 3: Bloco A | Un. 102 | Marlarny Silva | CPF: 102***894-22
  📄 Linha 4: Bloco A | Un. 103 | Daniel Gomes de Araújo | CPF: 009***301-21
  📄 Linha 5: Bloco A | Un. 104 | Marcelo Alexandre Toriaski | CPF: 227***268-50
  📄 Linha 6: Bloco B | Un. 201 | Vitor dos Santos Braga | CPF: 488***798-80
  📄 Linha 7: Bloco B | Un. 202 | William Batista Lopes | CPF: 031***381-01
  📄 Linha 8: Bloco B | Un. 203 | Valdivino Ramundo de Oliveira | CPF: 554***311-87
  📄 Linha 9: Bloco B | Un. 204 | Kátia Anhani Maraga | CPF: 420***516-40

✔️ FASE 2: VALIDAÇÃO DE DADOS
───────────────────────────────────────────────────────────────
  ✅ Linha 2 OK: Nilza Almeida de Araújo → Inquilino: Jeniffer Paulina da Silva
  ✅ Linha 3 OK: Marlarny Silva
  ✅ Linha 4 OK: Daniel Gomes de Araújo
  ✅ Linha 5 OK: Marcelo Alexandre Toriaski
  ✅ Linha 6 OK: Vitor dos Santos Braga
  ✅ Linha 7 OK: William Batista Lopes → Inquilino: Maria Clara Sousa
  ✅ Linha 8 OK: Valdivino Ramundo de Oliveira → Inquilino: Ana Carolina Silva
  ✅ Linha 9 OK: Kátia Anhani Maraga

═══════════════════════════════════════════════════════════════
📊 RESUMO DA VALIDAÇÃO
═══════════════════════════════════════════════════════════════
📈 Total de linhas: 8
✅ Linhas válidas: 8 (100.0%)
❌ Linhas com erro: 0

✓ Nenhum erro encontrado! Dados prontos para mapeamento.
═══════════════════════════════════════════════════════════════

🔄 FASE 3: MAPEAMENTO DE DADOS
───────────────────────────────────────────────────────────────
Agrupando dados de proprietários, inquilinos e imobiliárias...

  👤 Proprietário: Nilza Almeida de Araújo
     • CPF: 017***821-09
     • Unidades: 2
     • Senha: CG2024-a7K9mNx2

  👤 Proprietário: Marlarny Silva
     • CPF: 102***894-22
     • Unidades: 1
     • Senha: CG2024-p2Q5rTv8

... (mais dados aparecem aqui)

═══════════════════════════════════════════════════════════════
📊 RESUMO DA IMPORTAÇÃO
═══════════════════════════════════════════════════════════════
📁 Total de linhas: 8
✅ Linhas válidas: 8
❌ Linhas com erro: 0

👥 PROPRIETÁRIOS (6)
👥 INQUILINOS (3)
🏘️ BLOCOS (2)
🏢 IMOBILIÁRIAS (2)

... (tabelas detalhadas aparecem)

🎉 DADOS PRONTOS PARA IMPORTAÇÃO
═══════════════════════════════════════════════════════════════
✓ Proprietários: 6
✓ Inquilinos: 3
✓ Blocos: 2
✓ Imobiliárias: 2
✓ Total de senhas: 9
═══════════════════════════════════════════════════════════════
```

### **Passo 7: No Modal**

Enquanto você vê os logs no terminal:

1. O modal mostra: ⏳ **Passo 2: Processando**
2. Então você vê: ✅ **Passo 3: Preview** com todos os dados válidos
3. Clique em **Prosseguir** para confirmar
4. Clique em **Importar** para simular inserção

---

## 📊 O QUE VOCÊ VÊ

### **No Terminal:**
- ✅ Parsing completo
- ✅ Validação linha por linha
- ✅ Erros detalhados (se houver)
- ✅ Resumo de validação
- ✅ Mapeamento de dados
- ✅ Tabelas de proprietários, inquilinos, blocos, imobiliárias
- ✅ Senhas geradas

### **No Modal UI:**
- ✅ Indicador de progresso
- ✅ Preview com resumo
- ✅ Listagem de erros (se houver)
- ✅ Botões para avançar/voltar
- ✅ Resultado final com confirmação

---

## 🔧 SE QUISER VER MAIS LOGS

Para aumentar o nível de detalhes, edite `lib/widgets/importacao_modal_widget.dart`:

Procure por:
```dart
final rows = await ImportacaoService.parsarEValidarArquivo(
```

E adicione `enableLogging: true`:
```dart
final rows = await ImportacaoService.parsarEValidarArquivo(
  _arquivoBytes!,
  cpfsExistentesNoBanco: widget.cpfsExistentes,
  emailsExistenteNoBanco: widget.emailsExistentes,
  enableLogging: true,  // 👈 Adicionar
);
```

---

## ✨ RESUMO DO FLUXO

```
┌─────────────────────┐
│  Abrir App Flutter  │
└──────────┬──────────┘
           ↓
┌─────────────────────────────────────────────┐
│  Unidades → Importar Planilha (abre modal) │
└──────────┬──────────────────────────────────┘
           ↓
┌─────────────────────────────────────────────┐
│  Passo 1: Selecionar arquivo               │
│  [Selecionar arquivo Excel]               │
└──────────┬──────────────────────────────────┘
           ↓
      TERMINAL MOSTRA:
      📖 FASE 1: PARSING...
      ✔️ FASE 2: VALIDAÇÃO...
      🔄 FASE 3: MAPEAMENTO...
           ↓
┌─────────────────────────────────────────────┐
│  Passo 2: Processamento (automático)        │
│  ⏳ Carregando...                            │
└──────────┬──────────────────────────────────┘
           ↓
┌─────────────────────────────────────────────┐
│  Passo 3: Preview                           │
│  ✅ 8 linhas válidas                        │
│  ❌ 0 linhas com erro                       │
│  [Prosseguir]                              │
└──────────┬──────────────────────────────────┘
           ↓
┌─────────────────────────────────────────────┐
│  Passo 4: Confirmação                       │
│  Pronto para importar 6 proprietários,     │
│  3 inquilinos, 2 blocos, 2 imobiliárias   │
│  [Importar]                                │
└──────────┬──────────────────────────────────┘
           ↓
┌─────────────────────────────────────────────┐
│  Passo 5: Resultado                         │
│  ✅ Importação preparada!                   │
│  👥 Proprietários: 6                        │
│  🏠 Inquilinos: 3                           │
│  🏘️ Blocos: 2                                │
│  🏢 Imobiliárias: 2                         │
│  [Concluir]                                │
└─────────────────────────────────────────────┘
```

---

## 🎯 CHECKLIST

- [ ] Criar arquivo Excel: `planilha_teste.xlsx`
- [ ] Salvar em: `assets/`
- [ ] Executar: `flutter run`
- [ ] Abrir modal: "Importar Planilha"
- [ ] Selecionar arquivo
- [ ] Ver logs no terminal
- [ ] Clicar "Prosseguir"
- [ ] Ver preview no modal
- [ ] Clicar "Importar"
- [ ] Ver resultado final
- [ ] ✅ Tudo funcionando!

---

## 💡 DICAS

- Se não ver os logs, cheque se o terminal está aberto
- Se o modal travar, olhe para erros no terminal
- Se não conseguir selecionar arquivo, verifique permissões
- Os logs aparecem **em tempo real** enquanto processa

**Estou pronto! 🚀**
