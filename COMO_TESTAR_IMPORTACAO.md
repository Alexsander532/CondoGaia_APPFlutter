# 📋 Guia: Como Testar a Importação no Terminal

## 🎯 Objetivo

Você vai:
1. ✅ Abrir o modal da UI
2. ✅ Selecionar uma planilha Excel
3. ✅ Ver todos os detalhes no **terminal** enquanto o modal funciona

---

## 🚀 Passo-a-Passo

### **Passo 1: Preparar a Planilha Excel**

Crie um arquivo Excel com as seguintes colunas (exatamente assim):

```
bloco | unidade | fracao_ideal | proprietario_nome_completo | proprietario_cpf | proprietario_cel | proprietario_email | inquilino_nome_completo | inquilino_cpf | inquilino_cel | inquilino_email | nome_imobiliaria | cnpj_imobiliaria | cel_imobiliaria | email_imobiliaria
```

**Exemplo de dados:**

```
A | 101 | 0.05 | Nilza Almeida de Araújo | 017.104.821-09 | (07) 99114-6607 | nilza325@gmail.com | Jeniffer Paulina da Silva | 418.529.138-77 | (18) 90755-3688 | jeniffer515000@gmail.com | IMOBILIÁRIA SILVA | 25.748.962/0001-00 | (11) 9999-9999 | contato@silva.com.br

A | 102 | 0.05 | Marlarny Silva | 102.597.894-22 | (07) 99111-0207 | marlonnys@gmail.com | | | | | IMOBILIÁRIA SILVA | 25.748.962/0001-00 | (11) 9999-9999 | contato@silva.com.br
```

---

### **Passo 2: Integrar o Logger na Importação**

#### **Opção A: Testar via Script CLI** (Mais Rápido)

```bash
# 1. Salve a planilha em:
assets/planilha_importacao.xlsx

# 2. Execute o script de teste:
dart run bin/testar_importacao.dart
```

**Saída esperada:**

```
═══════════════════════════════════════════════════════════════
🚀 INICIANDO IMPORTAÇÃO DE PLANILHA
═══════════════════════════════════════════════════════════════
📁 Arquivo: planilha_importacao.xlsx
⏰ Hora: 2025-11-08 10:30:45.123456
═══════════════════════════════════════════════════════════════

📖 FASE 1: PARSING DO ARQUIVO
───────────────────────────────────────────────────────────────
✓ Arquivo lido com sucesso
✓ Total de linhas encontradas: 10

  📄 Linha 2: Bloco A | Un. 101 | Nilza Almeida de Araújo | CPF: 017***821-09
  📄 Linha 3: Bloco A | Un. 102 | Marlarny Silva | CPF: 102***894-22
  ...

✔️ FASE 2: VALIDAÇÃO DE DADOS
───────────────────────────────────────────────────────────────
  ✅ Linha 2 OK: Nilza Almeida de Araújo → Inquilino: Jeniffer Paulina da Silva
  ✅ Linha 3 OK: Marlarny Silva
  ❌ Linha 5 ERROS:
     • Email "joao@" inválido - Formato correto: usuario@dominio.com
     • CPF "123" inválido - CPF deve conter 11 dígitos (ex: 123.456.789-01)

═══════════════════════════════════════════════════════════════
📊 RESUMO DA VALIDAÇÃO
═══════════════════════════════════════════════════════════════
📈 Total de linhas: 10
✅ Linhas válidas: 8 (80.0%)
❌ Linhas com erro: 2

✓ Nenhum erro encontrado! Dados prontos para mapeamento.
═══════════════════════════════════════════════════════════════

🔄 FASE 3: MAPEAMENTO DE DADOS
───────────────────────────────────────────────────────────────
Agrupando dados de proprietários, inquilinos e imobiliárias...

  👤 Proprietário: Nilza Almeida de Araújo
     • CPF: 017***821-09
     • Unidades: 1
     • Senha: CG2024-a7K9mNx2

  👤 Proprietário: Marlarny Silva
     • CPF: 102***894-22
     • Unidades: 1
     • Senha: CG2024-p2Q5rTv8

  🏠 Inquilino: Jeniffer Paulina da Silva
     • CPF: 418***138-77
     • Unidade: A101
     • Senha: CG2024-bC3dEfG9

═══════════════════════════════════════════════════════════════
📊 RESUMO DA IMPORTAÇÃO
═══════════════════════════════════════════════════════════════
📁 Total de linhas: 10
✅ Linhas válidas: 8
❌ Linhas com erro: 2
═══════════════════════════════════════════════════════════════

👥 PROPRIETÁRIOS (8)
═══════════════════════════════════════════════════════════════

1. Nilza Almeida de Araújo
   CPF: 017***821-09
   Email: nilza325@gmail.com
   Telefone: (07) 99114-6607
   Unidades: A101, A103
   🔑 Senha: CG2024-a7K9mNx2

2. Marlarny Silva
   CPF: 102***894-22
   Email: marlonnys@gmail.com
   Telefone: (07) 99111-0207
   Unidades: A102
   🔑 Senha: CG2024-p2Q5rTv8

═══════════════════════════════════════════════════════════════

🏠 INQUILINOS (1)
═══════════════════════════════════════════════════════════════

1. Jeniffer Paulina da Silva
   CPF: 418***138-77
   Email: jeniffer515000@gmail.com
   Telefone: (18) 90755-3688
   Unidade: A101
   🔑 Senha: CG2024-bC3dEfG9

═══════════════════════════════════════════════════════════════

🏘️ BLOCOS (1)
═══════════════════════════════════════════════════════════════
1. A
═══════════════════════════════════════════════════════════════

🏢 IMOBILIÁRIAS (2)
═══════════════════════════════════════════════════════════════

1. IMOBILIÁRIA SILVA
   CNPJ: 25***0001-00
   Email: contato@silva.com.br
   Telefone: (11) 9999-9999

═══════════════════════════════════════════════════════════════
🎉 DADOS PRONTOS PARA IMPORTAÇÃO
═══════════════════════════════════════════════════════════════
✓ Proprietários: 8
✓ Inquilinos: 1
✓ Blocos: 1
✓ Imobiliárias: 2
✓ Total de senhas: 9
═══════════════════════════════════════════════════════════════

✅ TESTE CONCLUÍDO COM SUCESSO!
```

---

#### **Opção B: Testar via Modal UI + Logs**

Se preferir usar o modal:

1. **Abra o aplicativo:**
   ```bash
   flutter run
   ```

2. **Navegue até a tela de unidades do morador**

3. **Clique em "Importar Planilha"**

4. **Selecione o arquivo Excel**

5. **Veja os logs no terminal enquanto o modal funciona!**

O logger mostra tudo em tempo real no console do Flutter.

---

## 📊 O QUE VOCÊ VÊ NO TERMINAL

### **Estrutura de Logs**

```
═══════════════════════════════════════════════════════════════
🚀 INICIANDO IMPORTAÇÃO DE PLANILHA
═══════════════════════════════════════════════════════════════

📖 FASE 1: PARSING DO ARQUIVO
   (Mostra todas as linhas sendo lidas)

✔️ FASE 2: VALIDAÇÃO DE DADOS
   (Mostra cada linha válida e detalhes de cada erro)

📊 RESUMO DA VALIDAÇÃO
   (Total, válidas, com erro, percentuais)

🔄 FASE 3: MAPEAMENTO DE DADOS
   (Agrupamento de proprietários, inquilinos, blocos)

📊 RESUMO DA IMPORTAÇÃO
   (Contagem final de cada entidade)

👥 PROPRIETÁRIOS
   (Tabela com CPF, Email, Telefone, Unidades, Senhas)

🏠 INQUILINOS
   (Tabela com CPF, Email, Telefone, Unidade, Senhas)

🏘️ BLOCOS
   (Lista de blocos)

🏢 IMOBILIÁRIAS
   (Tabela com CNPJ, Email, Telefone)

🎉 DADOS PRONTOS PARA IMPORTAÇÃO
   (Resumo final de tudo que será criado)
```

---

## 🔧 CONFIGURAR MODAL PARA USAR LOGGER

Abra `lib/widgets/importacao_modal_widget.dart` e procure onde chama `parsarEValidarArquivo`:

```dart
// Antes:
final rows = await ImportacaoService.parsarEValidarArquivo(
  _arquivoBytes!,
  cpfsExistentesNoBanco: widget.cpfsExistentes,
  emailsExistenteNoBanco: widget.emailsExistentes,
);

// Depois (com logs):
final rows = await ImportacaoService.parsarEValidarArquivo(
  _arquivoBytes!,
  cpfsExistentesNoBanco: widget.cpfsExistentes,
  emailsExistenteNoBanco: widget.emailsExistentes,
  enableLogging: true,  // 👈 Adicionar isto!
);
```

Agora quando você abrir o modal, os logs aparecerão no terminal em tempo real!

---

## ✨ RESUMO

| Teste | Comando | Onde Ver Logs |
|-------|---------|---------------|
| **CLI Rápido** | `dart run bin/testar_importacao.dart` | Terminal |
| **Modal UI** | `flutter run` → Importar | Terminal + Console do Flutter |

Ambos mostram **exatamente os mesmos logs** no terminal, então você vê tudo o que está sendo processado! 🎯
