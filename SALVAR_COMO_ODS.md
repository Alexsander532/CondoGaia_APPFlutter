# 📋 COMO CONVERTER PARA OPENDOCUMENT (.ODS)

## 🎯 Por que ODS?

- ✅ Suporta números normalmente (sem conversão para datas)
- ✅ Formato aberto (não é proprietário)
- ✅ Funciona melhor com o parser

---

## 🚀 PASSO-A-PASSO

### **Opção A: LibreOffice Calc (RECOMENDADO)**

1. Abra seu arquivo: `planilha_importacao.xlsx`
2. Clique em: **File → Save As**
3. Em "File type", escolha: **ODF Spreadsheet (.ods)**
4. Salve como: `planilha_importacao.ods`
5. Coloque em: `assets/planilha_importacao.ods`

---

### **Opção B: Google Sheets**

1. Abra o arquivo no Google Drive
2. Clique em: **File → Download → Open Document Format (.ods)**
3. Salve em: `assets/planilha_importacao.ods`

---

### **Opção C: Excel (Microsoft)**

1. Abra o arquivo
2. **File → Save As**
3. Em "Save as type", procure por: **ODF Spreadsheet (.ods)**
4. Salve como: `planilha_importacao.ods`

---

## 📝 ESTRUTURA DO ARQUIVO ODS

Após salvar, seu arquivo terá:

**Linha 1:** Título (será pulado automaticamente)
```
CADASTRO BLOCO E UNIDADES
```

**Linha 2:** Cabeçalhos
```
bloco | unidade | fracao_ideal | proprietario_nome_completo | proprietario_cpf | proprietario_cel | proprietario_email | inquilino_nome_completo | inquilino_cpf | inquilino_cel | inquilino_email | nome_imobiliaria | cnpj_imobiliaria | cel_imobiliaria | email_imobiliaria
```

**Linhas 3+:** Dados
```
A | 101 | 0.05 | Nilza Almeida de Araujo | 017.104.821-09 | (67) 99114-5697 | nilzaa326@gmail.com | | | | | | | |

A | 102 | | Jenifer Pauliana da Silva | 416.529.158-77 | (18) 99755-3588 | jeniffer_silva2k@hotmail.com | | | | | | | |

...
```

---

## ✅ DEPOIS SALVAR

Execute:
```bash
dart run bin/testar_importacao.dart
```

Ou abra o app:
```bash
flutter run
# Vá para: Unidades → Importar Planilha
```

---

## 🎉 VANTAGENS

✅ Sem problema de datas estranhas
✅ Formato padrão aberto
✅ Funciona em qualquer sistema operacional
✅ Compatível com nosso parser

---

Pronto! Salve como ODS e teste! 🚀
