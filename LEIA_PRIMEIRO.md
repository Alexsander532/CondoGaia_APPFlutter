# ⚡ TESTE RÁPIDO - 3 PASSOS

## Passo 1: Criar Arquivo Excel

Crie `planilha_teste.xlsx` com estas colunas:
```
bloco | unidade | fracao_ideal | proprietario_nome_completo | proprietario_cpf | proprietario_cel | proprietario_email | inquilino_nome_completo | inquilino_cpf | inquilino_cel | inquilino_email | nome_imobiliaria | cnpj_imobiliaria | cel_imobiliaria | email_imobiliaria
```

**Cole uma linha de dados:**
```
A | 101 | 0.05 | João Silva | 123.456.789-00 | (11) 98765-4321 | joao@email.com | | | | | | | |
```

Salve em: `assets/planilha_teste.xlsx`

---

## Passo 2: Rodar Teste

```bash
dart run bin/testar_importacao.dart
```

---

## Passo 3: Ver Resultado

Você verá no terminal:

```
═══════════════════════════════════════════════════════════════
🚀 INICIANDO IMPORTAÇÃO DE PLANILHA
═══════════════════════════════════════════════════════════════
...
```

---

## Ou Testar com Modal

```bash
flutter run
```

Vá para: **Unidades → Importar Planilha**

Os mesmos logs aparecem no terminal! 🎉
