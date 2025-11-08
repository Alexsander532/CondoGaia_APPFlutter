#!/bin/bash
# Script para criar um arquivo Excel de teste

# Esta é uma instrução para criar a planilha manualmente em LibreOffice Calc ou Excel

cat << 'EOF'
╔══════════════════════════════════════════════════════════════════╗
║         CRIAR ARQUIVO EXCEL PARA TESTE DE IMPORTAÇÃO             ║
╚══════════════════════════════════════════════════════════════════╝

📋 COLUNAS (exatamente nesta ordem):
═══════════════════════════════════════════════════════════════════

1. bloco
2. unidade  
3. fracao_ideal
4. proprietario_nome_completo
5. proprietario_cpf
6. proprietario_cel
7. proprietario_email
8. inquilino_nome_completo
9. inquilino_cpf
10. inquilino_cel
11. inquilino_email
12. nome_imobiliaria
13. cnpj_imobiliaria
14. cel_imobiliaria
15. email_imobiliaria

═══════════════════════════════════════════════════════════════════

📝 DADOS DE EXEMPLO (copie e cole na planilha):

Linha 1: CABEÇALHO (títulos das colunas acima)

Linha 2:
A	101	0.05	Nilza Almeida de Araújo	017.104.821-09	(07) 99114-6607	nilza325@gmail.com	Jeniffer Paulina da Silva	418.529.138-77	(18) 90755-3688	jeniffer515000@gmail.com	IMOBILIÁRIA SILVA	25.748.962/0001-00	(11) 9999-9999	contato@silva.com.br

Linha 3:
A	102	0.05	Marlarny Silva	102.597.894-22	(07) 99111-0207	marlonnys@gmail.com						IMOBILIÁRIA SILVA	25.748.962/0001-00	(11) 9999-9999	contato@silva.com.br

Linha 4:
A	103	0.10	Daniel Gomes de Araújo	009.908.301-21	(07) 98942-0057	danielassociados@gmail.com				IMOBILIÁRIA SILVA	25.748.962/0001-00	(11) 9999-9999	contato@silva.com.br

Linha 5:
A	104	0.15	Marcelo Alexandre Toriaski	227.030.268-50	(07) 98004-5538	marcelandsepp@gmail.com				IMOBILIÁRIA SILVA	25.748.962/0001-00	(11) 9999-9999	contato@silva.com.br

Linha 6:
B	201	0.08	Vitor dos Santos Braga	488.020.798-80	(07) 98168-6121	vitor081@gmail.com				IMOBILIÁRIA BRASIL	15.987.654/0001-23	(11) 8888-8888	contato@brasil.com.br

Linha 7:
B	202	0.12	William Batista Lopes	031.403.381-01	(07) 98833-0775	williambatista@gmail.com	Maria Clara Sousa	555.111.222-33	(11) 92222-1111	maria.sousa@gmail.com	IMOBILIÁRIA BRASIL	15.987.654/0001-23	(11) 8888-8888	contato@brasil.com.br

Linha 8:
B	203	0.10	Valdivino Ramundo de Oliveira	554.073.311-87	(07) 98123-0485	alnejaclinoliveira@gmail.com	Ana Carolina Silva	666.222.333-44	(11) 93333-2222	ana.carol@gmail.com	IMOBILIÁRIA BRASIL	15.987.654/0001-23	(11) 8888-8888	contato@brasil.com.br

Linha 9:
B	204	0.05	Kátia Anhani Maraga	420.808.516-40	(18) 98120-5528	katia.anhani@gmail.com				IMOBILIÁRIA BRASIL	15.987.654/0001-23	(11) 8888-8888	contato@brasil.com.br

═══════════════════════════════════════════════════════════════════

🎯 PASSOS PARA CRIAR O ARQUIVO:

1. Abra LibreOffice Calc ou Excel
2. Crie uma nova planilha
3. Cole o cabeçalho na linha 1
4. Cole os dados das linhas 2-9
5. Salve como: assets/planilha_importacao.xlsx
6. Execute: dart run bin/testar_importacao.dart

═══════════════════════════════════════════════════════════════════

✅ RESULTADO ESPERADO:

- 8 linhas (das quais 7-8 devem ser válidas)
- 5-6 proprietários
- 2-3 inquilinos
- 2 blocos (A e B)
- 2 imobiliárias
- 7-9 senhas geradas

═══════════════════════════════════════════════════════════════════
EOF
