# 📋 Relatório de Testes Manuais — Despesa, Receita e Transferência

**Projeto:** CondoGaia App  
**Feature:** Gestão Financeira (Despesas, Receitas e Transferências)  
**Data dos Testes:** 22/03/2026  
**Responsável:** Equipe de Desenvolvimento  
**Status Geral:** ✅ **TODOS OS TESTES PASSARAM COM SUCESSO**

---

## 1. Objetivo dos Testes

Validar que todas as funcionalidades da tela de Despesas, Receitas e Transferências estão operando corretamente para o usuário Representante do condomínio. Os testes cobrem desde o cadastro básico até cenários complexos de filtro, edição, exclusão e cálculos financeiros.

---

## 2. Ambiente de Testes

| Item | Detalhes |
|------|----------|
| **Plataforma** | Web (Chrome) via Flutter Web |
| **Perfil de Usuário** | Representante do Condomínio |
| **Banco de Dados** | Supabase (Produção Sandbox) |
| **Backend** | Laravel (API REST + Webhooks) |
| **Testes Unitários** | 89/89 passando (automatizados) |

---

## 3. Resumo Executivo

| Módulo | Testes Realizados | Aprovados | Reprovados |
|--------|:-----------------:|:---------:|:----------:|
| Despesas (cadastro) | 16 | ✅ 16 | 0 |
| Despesas (listagem e filtros) | 6 | ✅ 6 | 0 |
| Despesas (edição) | 4 | ✅ 4 | 0 |
| Despesas (exclusão) | 5 | ✅ 5 | 0 |
| Despesas (modal de detalhes) | 6 | ✅ 6 | 0 |
| Receitas (cadastro) | 14 | ✅ 14 | 0 |
| Receitas (filtros) | 4 | ✅ 4 | 0 |
| Receitas (edição e exclusão) | 3 | ✅ 3 | 0 |
| Receitas (modal de detalhes) | 3 | ✅ 3 | 0 |
| Transferências (cadastro) | 9 | ✅ 9 | 0 |
| Transferências (filtros) | 2 | ✅ 2 | 0 |
| Transferências (edição e exclusão) | 2 | ✅ 2 | 0 |
| Resumo Financeiro | 6 | ✅ 6 | 0 |
| Navegação por Mês/Ano | 6 | ✅ 6 | 0 |
| Formatadores de Entrada | 19 | ✅ 19 | 0 |
| **TOTAL** | **105** | **✅ 105** | **0** |

---

## 4. Detalhamento dos Testes

### 4.1 Módulo de Despesas

#### 4.1.1 Cadastro de Despesas

| # | Cenário Testado | Resultado |
|:-:|-----------------|:---------:|
| 1 | Acessar a tela pelo menu Gestão → Despesas/Receitas | ✅ Aprovado |
| 2 | Botão "+ Cadastrar" abre formulário | ✅ Aprovado |
| 3 | Dropdown de Conta Bancária lista contas do condomínio | ✅ Aprovado |
| 4 | Dropdown de Categoria lista apenas categorias do tipo DESPESA | ✅ Aprovado |
| 5 | Dropdown de Subcategoria lista apenas subcategorias da categoria selecionada | ✅ Aprovado |
| 6 | Campo de descrição aceita texto livre | ✅ Aprovado |
| 7 | Campo de valor aplica formatação brasileira (R$ 1.500,50) automaticamente | ✅ Aprovado |
| 8 | Campo de data de vencimento aplica formatação DD/MM/AAAA automaticamente | ✅ Aprovado |
| 9 | Marcação "Recorrente" exibe campo "Qtd. de Meses" | ✅ Aprovado |
| 10 | Campo "Qtd. de Meses" aceita número inteiro | ✅ Aprovado |
| 11 | Checkbox "Me Avisar" funciona corretamente | ✅ Aprovado |
| 12 | Campo de Link aceita URL | ✅ Aprovado |
| 13 | Botão "Anexar foto" abre seletor de imagem | ✅ Aprovado |
| 14 | Salvar despesa com todos os campos preenchidos → registro aparece na tabela | ✅ Aprovado |
| 15 | Tentar salvar sem valor → validação impede e exibe erro | ✅ Aprovado |
| 16 | Tentar salvar sem data de vencimento → validação impede e exibe erro | ✅ Aprovado |

**Observação:** Após o salvamento, o sistema exibe uma mensagem de confirmação (SnackBar verde) informando que a despesa foi cadastrada com sucesso.

#### 4.1.2 Listagem e Filtros de Despesas

| # | Cenário Testado | Resultado |
|:-:|-----------------|:---------:|
| 1 | Tabela lista despesas do mês/ano selecionado corretamente | ✅ Aprovado |
| 2 | Filtro por Conta Bancária funciona | ✅ Aprovado |
| 3 | Filtro por Categoria funciona | ✅ Aprovado |
| 4 | Filtro por Subcategoria funciona (depende da categoria) | ✅ Aprovado |
| 5 | Filtro por Palavra-chave busca na descrição | ✅ Aprovado |
| 6 | Limpar filtros retorna a lista completa do mês | ✅ Aprovado |

#### 4.1.3 Edição de Despesas

| # | Cenário Testado | Resultado |
|:-:|-----------------|:---------:|
| 1 | Selecionar despesa via checkbox na tabela | ✅ Aprovado |
| 2 | Botão "Editar" no rodapé preenche o formulário com dados existentes | ✅ Aprovado |
| 3 | Alterar o valor e salvar → tabela atualiza | ✅ Aprovado |
| 4 | SnackBar de confirmação aparece após edição | ✅ Aprovado |

#### 4.1.4 Exclusão de Despesas

| # | Cenário Testado | Resultado |
|:-:|-----------------|:---------:|
| 1 | Marcar 1 despesa e clicar "Excluir" → diálogo de confirmação | ✅ Aprovado |
| 2 | Confirmar exclusão → registro removido da tabela | ✅ Aprovado |
| 3 | Marcar múltiplas despesas e excluir em lote | ✅ Aprovado |
| 4 | "Selecionar Todos" no cabeçalho marca todas as despesas | ✅ Aprovado |
| 5 | Clicar novamente em "Selecionar Todos" desmarca todas | ✅ Aprovado |

#### 4.1.5 Modal de Detalhes da Despesa

| # | Cenário Testado | Resultado |
|:-:|-----------------|:---------:|
| 1 | Tocar em uma despesa na tabela abre modal de detalhes | ✅ Aprovado |
| 2 | Modal exibe todas as informações (conta, categoria, subcategoria, valor, data, descrição) | ✅ Aprovado |
| 3 | Despesa com foto: imagem carrega e é exibida | ✅ Aprovado |
| 4 | Despesa com link: botão "Abrir" redireciona ao navegador | ✅ Aprovado |
| 5 | Despesa com link: botão "Copiar" copia para área de transferência | ✅ Aprovado |
| 6 | Indicador de tipo exibe "MANUAL" ou "AUTOMÁTICO" corretamente | ✅ Aprovado |

---

### 4.2 Módulo de Receitas

#### 4.2.1 Cadastro de Receitas

| # | Cenário Testado | Resultado |
|:-:|-----------------|:---------:|
| 1 | Aba "Receitas" ativa corretamente | ✅ Aprovado |
| 2 | Botão "+ Cadastrar" abre formulário de receita | ✅ Aprovado |
| 3 | Dropdown de Conta Bancária funciona | ✅ Aprovado |
| 4 | Dropdown de Categoria lista apenas categorias do tipo RECEITA | ✅ Aprovado |
| 5 | Dropdown de Subcategoria lista subcategorias da categoria | ✅ Aprovado |
| 6 | Dropdown de Conta Contábil lista opções: Controle, Fundo Reserva, Obras | ✅ Aprovado |
| 7 | Campo Descrição aceita texto livre | ✅ Aprovado |
| 8 | Campo Valor aplica formatação brasileira | ✅ Aprovado |
| 9 | Campo Data do Crédito aplica formatação DD/MM/AAAA | ✅ Aprovado |
| 10 | Marcação "Recorrente" exibe campo "Qtd. de Meses" | ✅ Aprovado |
| 11 | Dropdown de Tipo lista opções Manual e Automático | ✅ Aprovado |
| 12 | Salvar receita com todos os campos → registro aparece na tabela | ✅ Aprovado |
| 13 | Tentar salvar sem valor → validação impede | ✅ Aprovado |
| 14 | Tentar salvar sem data de crédito → validação impede | ✅ Aprovado |

#### 4.2.2 Filtros de Receitas

| # | Cenário Testado | Resultado |
|:-:|-----------------|:---------:|
| 1 | Filtro por Conta Bancária funciona | ✅ Aprovado |
| 2 | Filtro por Conta Contábil (Controle / Fundo Reserva / Obras) funciona | ✅ Aprovado |
| 3 | Filtro por Tipo (Todos / Manual / Automático) funciona | ✅ Aprovado |
| 4 | Filtro por Palavra-chave busca na descrição | ✅ Aprovado |

#### 4.2.3 Edição e Exclusão de Receitas

| # | Cenário Testado | Resultado |
|:-:|-----------------|:---------:|
| 1 | Editar receita existente → tabela atualiza | ✅ Aprovado |
| 2 | Excluir receita individual → registro removido | ✅ Aprovado |
| 3 | Excluir múltiplas receitas → registros removidos | ✅ Aprovado |

#### 4.2.4 Modal de Detalhes da Receita

| # | Cenário Testado | Resultado |
|:-:|-----------------|:---------:|
| 1 | Tocar em uma receita na tabela abre modal de detalhes | ✅ Aprovado |
| 2 | Badge de tipo exibe "MANUAL" ou "AUTOMÁTICO" | ✅ Aprovado |
| 3 | Conta Contábil exibida corretamente no modal | ✅ Aprovado |

---

### 4.3 Módulo de Transferências

#### 4.3.1 Cadastro de Transferências

| # | Cenário Testado | Resultado |
|:-:|-----------------|:---------:|
| 1 | Aba "Transferência" ativa corretamente | ✅ Aprovado |
| 2 | Botão "+ Cadastrar" abre formulário | ✅ Aprovado |
| 3 | Dropdown de Conta Débito (origem) funciona | ✅ Aprovado |
| 4 | Dropdown de Conta Crédito (destino) funciona | ✅ Aprovado |
| 5 | Campo Descrição aceita texto livre | ✅ Aprovado |
| 6 | Campo Valor aplica formatação brasileira | ✅ Aprovado |
| 7 | Campo Data aplica formatação DD/MM/AAAA | ✅ Aprovado |
| 8 | Salvar transferência → registro aparece na tabela | ✅ Aprovado |
| 9 | Tentar salvar com mesma conta débito e crédito → validação impede | ✅ Aprovado |

#### 4.3.2 Filtros de Transferências

| # | Cenário Testado | Resultado |
|:-:|-----------------|:---------:|
| 1 | Filtro por Conta Débito funciona | ✅ Aprovado |
| 2 | Filtro por Conta Crédito funciona | ✅ Aprovado |

#### 4.3.3 Edição e Exclusão de Transferências

| # | Cenário Testado | Resultado |
|:-:|-----------------|:---------:|
| 1 | Editar transferência existente → tabela atualiza | ✅ Aprovado |
| 2 | Excluir transferência → registro removido | ✅ Aprovado |

---

### 4.4 Resumo Financeiro

| # | Cenário Testado | Resultado |
|:-:|-----------------|:---------:|
| 1 | Rodapé fixo exibe: Saldo Anterior, Total Crédito, Total Débito, Saldo Atual | ✅ Aprovado |
| 2 | Cadastrar despesa de R$ 500 → Total Débito aumenta R$ 500 e Saldo Atual diminui R$ 500 | ✅ Aprovado |
| 3 | Cadastrar receita de R$ 800 → Total Crédito aumenta R$ 800 e Saldo Atual aumenta R$ 800 | ✅ Aprovado |
| 4 | Excluir despesa e receita → valores retornam ao estado anterior | ✅ Aprovado |
| 5 | Fórmula correta: Saldo Atual = Saldo Anterior + Total Crédito − Total Débito | ✅ Aprovado |
| 6 | Saldo negativo é exibido em vermelho | ✅ Aprovado |

---

### 4.5 Navegação por Mês/Ano

| # | Cenário Testado | Resultado |
|:-:|-----------------|:---------:|
| 1 | Seletor de mês/ano exibe mês e ano atuais ao abrir a tela | ✅ Aprovado |
| 2 | Seta esquerda navega para o mês anterior | ✅ Aprovado |
| 3 | Dados (despesas, receitas, transferências e saldo anterior) recarregam ao mudar mês | ✅ Aprovado |
| 4 | Seta direita navega para o mês seguinte | ✅ Aprovado |
| 5 | Navegar para mês sem dados → tabelas vazias | ✅ Aprovado |
| 6 | Virada de ano (Dezembro → Novembro) funciona corretamente | ✅ Aprovado |

---

### 4.6 Formatadores de Entrada

#### Formatador de Moeda (R$)

| # | Entrada Digitada | Resultado Esperado | Resultado |
|:-:|:----------------:|:------------------:|:---------:|
| 1 | `5` | `5` | ✅ |
| 2 | `99` | `99` | ✅ |
| 3 | `1234` | `1.234` | ✅ |
| 4 | `1234567` | `1.234.567` | ✅ |
| 5 | `100,50` | `100,50` | ✅ |
| 6 | `1234,56` | `1.234,56` | ✅ |
| 7 | `100,50,` | `100,50` (rejeita segunda vírgula) | ✅ |
| 8 | `007` | `7` (remove zeros à esquerda) | ✅ |
| 9 | `0,50` | `0,50` (mantém zero único antes da vírgula) | ✅ |
| 10 | `12a3b4` | `1.234` (remove caracteres não numéricos) | ✅ |

#### Formatador de Data (DD/MM/AAAA)

| # | Entrada Digitada | Resultado Esperado | Resultado |
|:-:|:----------------:|:------------------:|:---------:|
| 1 | `1` | `1` | ✅ |
| 2 | `15` | `15` | ✅ |
| 3 | `150` | `15/0` | ✅ |
| 4 | `1503` | `15/03` | ✅ |
| 5 | `15032` | `15/03/2` | ✅ |
| 6 | `15032026` | `15/03/2026` | ✅ |
| 7 | Mais de 10 caracteres | Bloqueado (máximo DD/MM/AAAA) | ✅ |
| 8 | Letras misturadas | Removidas automaticamente | ✅ |
| 9 | Cursor posicionado corretamente após formatação | Sim | ✅ |

---

## 5. Feedback Visual (SnackBars)

Todos os SnackBars foram testados e estão funcionando:

| Ação | Mensagem Exibida | Cor |
|------|------------------|-----|
| Despesa cadastrada | "Despesa cadastrada com sucesso!" | 🟢 Verde |
| Despesa editada | "Despesa atualizada com sucesso!" | 🟢 Verde |
| Despesa(s) excluída(s) | "Despesa(s) excluída(s) com sucesso!" | 🟢 Verde |
| Receita cadastrada | "Receita cadastrada com sucesso!" | 🟢 Verde |
| Receita editada | "Receita atualizada com sucesso!" | 🟢 Verde |
| Receita(s) excluída(s) | "Receita(s) excluída(s) com sucesso!" | 🟢 Verde |
| Transferência cadastrada | "Transferência cadastrada com sucesso!" | 🟢 Verde |
| Transferência editada | "Transferência atualizada com sucesso!" | 🟢 Verde |
| Transferência(s) excluída(s) | "Transferência(s) excluída(s) com sucesso!" | 🟢 Verde |
| Erro no salvamento | Mensagem do erro | 🔴 Vermelho |

---

## 6. Testes Automatizados (Unitários)

Além dos testes manuais, a feature possui **89 testes unitários automatizados**, todos passando:

| Grupo de Testes | Qtd. | Status |
|-----------------|:----:|:------:|
| Modelos de Dados (Despesa, Receita, Transferência, Categoria) | 25 | ✅ 25/25 |
| Estado do Cubit (valores padrão, copyWith, getters computados, Equatable) | 24 | ✅ 24/24 |
| Lógica de Negócio do Cubit (carregar, pesquisar, salvar, excluir, seleção, edição, navegação) | 17 | ✅ 17/17 |
| Formatadores de Entrada (Moeda e Data) | 23 | ✅ 23/23 |
| **Total** | **89** | **✅ 89/89** |

---

## 7. Conclusão

✅ **A funcionalidade de Despesas, Receitas e Transferências está totalmente funcional e pronta para uso em produção.**

Todos os **105 cenários de testes manuais** e **89 testes unitários automatizados** foram executados com sucesso, sem nenhuma falha identificada. O sistema atende a todos os requisitos de cadastro, listagem, filtro, edição, exclusão, cálculos financeiros e feedback visual para o usuário.

---

*Relatório gerado em 22/03/2026 — Equipe de Desenvolvimento CondoGaia*
