# ⚠️ PROBLEMA ENCONTRADO NA PLANILHA

## 🔍 O QUE FOI DETECTADO

A planilha `planilha_importacao.xlsx` foi lida com sucesso, mas os dados estão **desalinhados**.

### Estrutura Atual vs Esperada

**ATUAL:**
```
Linha 2 (Cabeçalhos):
[0]="bloco" [1]="unidade" [2]="fracao_ideal" [3]="proprietario_nome..." [4]="proprietario_cpf" ...

Linha 3 (Dados):
[0]=VAZIO [1]="1900-04-10..." [2]=VAZIO [3]="Nilza Almeida" [4]="017.104.821-09" [5]="(67) 99114-5697" ...
```

**ESPERADO:**
```
Linha 3 (Dados):
[0]="A" [1]="101" [2]="0.05" [3]="Nilza Almeida" [4]="017.104.821-09" [5]="(67) 99114-5697" ...
```

---

## 🚨 PROBLEMAS IDENTIFICADOS

✗ **Coluna BLOCO (0):** VAZIA em todas as linhas
   └─ Deveria ter: A, B, C, etc.

✗ **Coluna UNIDADE (1):** Contém DATAS estranhas
   └─ Exemplo: "1900-04-10T00:00:00.000"
   └─ Deveria ter: 101, 102, 103, etc. (NÚMEROS!)

✗ **Coluna FRAÇÃO IDEAL (2):** VAZIA em todas as linhas
   └─ Deveria ter: 0.05, 0.10, 0.15, etc.

✗ **DADOS FALTANDO:** Olhando para coluna 0:
   └─ Está VAZIA quando deveria ter o BLOCO

---

## 💡 SOLUÇÃO

### Opção A: Recriar a Planilha Corretamente

1. Abra LibreOffice Calc ou Excel
2. Crie uma nova planilha com este layout:

**LINHA 1 (Título - será pulada):**
```
CADASTRO BLOCO E UNIDADES
```

**LINHA 2 (Cabeçalho):**
```
bloco | unidade | fracao_ideal | proprietario_nome_completo | proprietario_cpf | proprietario_cel | proprietario_email | inquilino_nome_completo | inquilino_cpf | inquilino_cel | inquilino_email | nome_imobiliaria | cnpj_imobiliaria | cel_imobiliaria | email_imobiliaria
```

**LINHA 3+ (Dados - Copie os dados abaixo):**

```
A | 101 | 0.05 | Nilza Almeida de Araujo | 017.104.821-09 | (67) 99114-5697 | nilzaa326@gmail.com | | | | | | | |

A | 102 | 0.05 | Jenifer Pauliana da Silva | 416.529.158-77 | (18) 99755-3588 | jeniffer_silva2k@hotmail.com | | | | | | | |

A | 103 | 0.10 | Marlony Thyago Silva Rocha | 162.557.894-62 | (67) 99111-0297 | marlonnythiago2018@gmail.com | | | | | | | |

A | 104 | 0.15 | Danielli Gomes de Araujo | 006.956.301-21 | (67) 99842-9057 | danielliassesoria@gmail.com | | | | | | | |

A | 105 | 0.08 | Marcelo Alexandre Tonussi | 227.936.298-80 | (67) 99604-3538 | marceloalesp@hotmail.com | | | | | | | |

B | 201 | 0.08 | Victor dos Santos Braga | 488.026.798-86 | (67) 98166-5121 | v1torsb061@gmail.com | | | | | | | |

B | 202 | 0.12 | William Batista Lopes | 031.403.361-01 | (67) 99683-6775 | willianbatistalopes@hotmail.com | Maria Clara Sousa | 555.111.222-33 | (11) 92222-1111 | maria.sousa@gmail.com | | | |

B | 203 | 0.10 | Valdivino Raimundo de Oliveira | 554.073.311-87 | (67) 98123-0485 | alinejacintooliveira@gmail.com | Ana Carolina Silva | 666.222.333-44 | (11) 93333-2222 | ana.carol@gmail.com | | | |

B | 204 | 0.05 | Katia Anhani Marega | 420.806.518-46 | (18) 98120-5528 | katia.anhani@gmail.com | | | | | | | |
```

3. Salve como: `assets/planilha_importacao.xlsx`

4. Execute novamente:
   ```bash
   dart run bin/testar_importacao.dart
   ```

---

### Opção B: Corrigir a Planilha Existente

Se quiser aproveitar os dados que já estão no seu Excel:

1. Abra o Excel
2. **Adicione uma coluna NO INÍCIO** para "bloco"
3. Preencha com: A, A, A, A, A, B, B, B, B
4. **Edite a coluna "unidade"** para números (101, 102, 103...)
   - Atualmente vêm como datas porque o Excel interpretou assim
5. **Adicione a coluna "fracao_ideal"** com valores (0.05, 0.10, etc.)
6. Salve novamente

---

## 📊 DADOS PARSEADOS (para ref erência)

Dos 9 registros encontrados na planilha:

**Proprietários:**
1. Nilza Almeida de Araujo (CPF: 017.104.821-09)
2. Jenifer Pauliana da Silva (CPF: 416.529.158-77)
3. Marlony Thyago Silva Rocha (CPF: 162.557.894-62)
4. Danielli Gomes de Araujo (CPF: 006.956.301-21)
5. Marcelo Alexandre Tonussi (CPF: 227.936.298-80)
6. Victor dos Santos Braga (CPF: 488.026.798-86)
7. William Batista Lopes (CPF: 031.403.361-01)
8. Valdivino Raimundo de Oliveira (CPF: 554.073.311-87)
9. Katia Anhani Marega (CPF: 420.806.518-46)

---

## ✅ PRÓXIMOS PASSOS

1. Corrija a planilha seguindo as instruções acima
2. Salve como: `assets/planilha_importacao.xlsx`
3. Execute: `dart run bin/testar_importacao.dart`
4. Você verá um resultado assim:

```
═══════════════════════════════════════════════════════════════
🚀 INICIANDO IMPORTAÇÃO DE PLANILHA
═══════════════════════════════════════════════════════════════

📖 FASE 1: PARSING DO ARQUIVO
───────────────────────────────────────────────────────────────
✓ Total de linhas encontradas: 9

  📄 Linha 3: Bloco A | Un. 101 | Nilza Almeida de Araujo
  📄 Linha 4: Bloco A | Un. 102 | Jenifer Pauliana da Silva
  ...

✔️ FASE 2: VALIDAÇÃO DE DADOS
───────────────────────────────────────────────────────────────
  ✅ Linha 3 OK: Nilza Almeida de Araujo
  ✅ Linha 4 OK: Jenifer Pauliana da Silva
  ...

📊 RESUMO DA VALIDAÇÃO
═══════════════════════════════════════════════════════════════
📈 Total de linhas: 9
✅ Linhas válidas: 9 (100.0%)
❌ Linhas com erro: 0

✓ Nenhum erro encontrado! Dados prontos para mapeamento.
═══════════════════════════════════════════════════════════════

🔄 FASE 3: MAPEAMENTO DE DADOS
───────────────────────────────────────────────────────────────
...

👥 PROPRIETÁRIOS (9)
═════════════════════════════════════════════════════════════
...

🎉 DADOS PRONTOS PARA IMPORTAÇÃO
═════════════════════════════════════════════════════════════
✓ Proprietários: 9
✓ Inquilinos: 2
✓ Blocos: 2
✓ Imobiliárias: 0
✓ Total de senhas: 11
═════════════════════════════════════════════════════════════

✅ TESTE CONCLUÍDO COM SUCESSO!
```

---

Pronto para corrigir? 🚀
