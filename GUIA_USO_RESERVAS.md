# 🎬 PASSO-A-PASSO: Como Usar o Sistema de Reservas

## 📱 Na Tela do App (Flutter)

### Passo 1: Abrir a Tela de Reservas
```
Navegue para a tela de Reservas
(menu ou rota correspondente)
```

### Passo 2: Selecionar Uma Data
```
┌─────────────────────────┐
│  Calendário Interativo  │
│                         │
│  [◄] Novembro 2025 [►]  │
│                         │
│  DOM SEG TER QUA QUI    │
│   2   3   4   5   6     │
│   9  10  11  12  13     │
│  16  17  18  19  20     │
│  23  24  25  26  27     │
│  30                     │
│                         │
│  ✓ Clique em um dia     │
│    (destacado em azul)  │
└─────────────────────────┘
```

### Passo 3: Preencher o Formulário
```
┌────────────────────────────────┐
│ RESERVAR DIA 10/NOV/2025       │
├────────────────────────────────┤
│                                │
│ Local:  [Dropdown ▼]           │
│         Selecione um ambiente: │
│         • Salão de Festas      │
│         • Churrasqueira        │
│         • Quadra de Esportes   │
│                                │
│ Hora Início:  [14:00]  HH:MM   │
│ Hora Fim:     [16:00]  HH:MM   │
│                                │
│ Para:  [◉ Condomínio            │
│        [ ] Bloco/Unid]          │
│                                │
│ Valor Locação: [R$ 250,00]     │
│                                │
│ Lista Presentes (opt):         │
│ [Bolo, refrigerante, sucos  ]  │
│                                │
│           [ RESERVAR ]         │
│                                │
└────────────────────────────────┘
```

### Passo 4: Clicar "RESERVAR"
```
Quando clica no botão:

1️⃣ App valida os dados
   ✅ Ambiente selecionado?
   ✅ Hora início preenchida?
   ✅ Hora fim preenchida?
   ✅ Hora fim > hora início?

2️⃣ Mostra "Salvando..."
   ┌──────────────────┐
   │ ⏳ Salvando...   │
   └──────────────────┘

3️⃣ Envia dados para Supabase
   
4️⃣ Supabase valida
   ✅ Usuario autenticado?
   ✅ Ambiente existe?
   ✅ Não tem conflito de hora?
   
5️⃣ Se OK: Insere registro
   
6️⃣ Se Erro: Mostra mensagem
```

### Passo 5: Resultado - Sucesso ✅
```
┌────────────────────────────────┐
│ ✅ Reserva criada com sucesso! │
└────────────────────────────────┘

Modal fecha automaticamente
Formulário limpa
```

### Passo 6: Resultado - Erro ❌
```
Exemplo: Horário já reservado

┌────────────────────────────────────────┐
│ ❌ Já existe uma reserva neste        │
│    horário para este ambiente         │
└────────────────────────────────────────┘

Modal permanece aberto
Pode tentar outro horário
```

---

## 🗄️ No Supabase (Backend)

### O Que Acontece Quando Você Clica "Reservar"

```
1. Frontend coleta dados do formulário
   │
   ├─ ambienteId: "abc-123"
   ├─ dataReserva: "2025-11-10"
   ├─ horaInicio: "14:00"
   ├─ horaFim: "16:00"
   ├─ para: "Condomínio"
   ├─ local: "Salão de Festas"
   ├─ valorLocacao: 250.00
   └─ observacoes: "Bolo, refrigerante, sucos"
   │
   ▼
2. ReservaService.criarReserva() executa
   │
   ├─ Pega usuarioId do user autenticado
   ├─ Valida se hora_fim > hora_inicio
   ├─ Verifica conflito no banco
   │  └─ SELECT * FROM reservas
   │     WHERE ambiente_id = 'abc-123'
   │     AND data_reserva = '2025-11-10'
   │     AND (hora_inicio < '16:00' AND hora_fim > '14:00')
   │
   └─ Se nenhum conflito, executa INSERT
   │
   ▼
3. Supabase insere na tabela 'reservas'
   │
   ├─ Gera id automático: "xyz-999"
   ├─ Seta created_at: NOW()
   ├─ Seta updated_at: NOW()
   └─ Valida constraints:
      ├─ hora_fim > hora_inicio ✅
      ├─ valor_locacao >= 0 ✅
      ├─ para IN ('Condomínio', 'Bloco/Unid') ✅
      └─ data_reserva >= CURRENT_DATE ✅
   │
   ▼
4. Resposta retorna ao Flutter
   │
   └─ Retorna objeto Reserva com id
   │
   ▼
5. Flutter mostra sucesso ✅
```

---

## 📊 Visualização do Banco Após Criar Reserva

### Antes (Vazio)
```
reservas table está vazia
id | ambiente_id | usuario_id | data_reserva | ... | observacoes
```

### Depois (Após Reservar)
```
reservas table com 1 linha:

id          | ambiente_id | usuario_id | data_reserva | hora_inicio | hora_fim | para        | local           | valor_locacao | observacoes              | created_at
─────────────────────────────────────────────────────────────────────────────────────────────────────────────
xyz-999     | abc-123     | user-123   | 2025-11-10   | 14:00       | 16:00    | Condomínio  | Salão de Festas | 250.00        | Bolo, refrigerante... | 2025-11-07 10:30:45
```

---

## ⚠️ Possíveis Erros e Soluções

### Erro 1: "Usuário não autenticado"
```
❌ Causa: Tentou criar reserva sem fazer login
✅ Solução: Faça login primeiro no app
```

### Erro 2: "Já existe uma reserva neste horário"
```
❌ Causa: Ambiente já está reservado para esta hora/data
✅ Solução: Escolha outro horário ou outro dia
   
Exemplo:
   Salão está reservado: 14:00-16:00
   Você tentou: 14:00-17:00 (conflita)
   Solução: Escolher 16:00-18:00 (após o fim)
```

### Erro 3: "Hora de fim deve ser posterior à hora de início"
```
❌ Causa: hora_fim <= hora_inicio
❌ Exemplo: Inicio=14:00, Fim=14:00 ou Fim=13:00
✅ Solução: Preencher hora_fim maior que hora_inicio
```

### Erro 4: "Selecione um ambiente"
```
❌ Causa: Não selecionou nenhum local
✅ Solução: Clique no dropdown e escolha um
```

### Erro 5: "Preencha a hora de início"
```
❌ Causa: Campo hora_inicio está vazio
✅ Solução: Digite no formato HH:MM (ex: 14:00)
```

---

## 🔍 Como Verificar se Funcionou

### Opção 1: Supabase Console (Melhor)

```
1. Acesse https://supabase.com
2. Faça login na sua conta
3. Abra o projeto "CondoGaia"
4. Clique em "Database" no menu esquerdo
5. Clique em "reservas" na lista de tabelas
6. Veja a nova linha criada
7. Verificar se todos os campos estão corretos
```

### Opção 2: No App (Visual)

```
1. Após clicar "Reservar"
2. Se aparecer mensagem verde "Reserva criada com sucesso!"
3. Significa que foi salvo ✅
```

---

## 🚀 Fluxo Completo Visual

```
┌──────────────────────┐
│   Tela de Reservas   │
└──────┬───────────────┘
       │
       │ Seleciona data
       ▼
┌──────────────────────┐
│   Formulário Aberto  │
│                      │
│  • Ambiente          │
│  • Hora início       │
│  • Hora fim          │
│  • Valor             │
│  • Observações       │
└──────┬───────────────┘
       │
       │ Clica "Reservar"
       ▼
┌──────────────────────┐
│   Validação Local    │
│  (Frontend)          │
│  ✅ Campos OK?       │
└──────┬───────────────┘
       │
       │ Sim, envia para backend
       ▼
┌──────────────────────┐
│  ReservaService      │
│  (Backend)           │
│                      │
│  ✅ Usuário auth?    │
│  ✅ Conflito?        │
│  ✅ Valido?          │
└──────┬───────────────┘
       │
       │ Tudo OK, insere no DB
       ▼
┌──────────────────────┐
│   Supabase Insert    │
│  INSERT INTO         │
│  reservas (...       │
│  VALUES (...         │
└──────┬───────────────┘
       │
       │ Retorna sucesso
       ▼
┌──────────────────────┐
│   Flutter Atualiza   │
│  • Fecha modal       │
│  • Limpa formulário  │
│  • Mostra sucesso    │
└──────────────────────┘
```

---

## 📝 Checklist: Está Funcionando?

- [ ] Consegue abrir a tela de Reservas
- [ ] Calendário está funcionando (pode clicar em datas)
- [ ] Dropdown de ambientes lista seus locais cadastrados
- [ ] Consegue preencher hora início e hora fim (HH:MM)
- [ ] Consegue selecionar "Para" (Condomínio/Bloco)
- [ ] Consegue preencher Lista de Presentes (opcional)
- [ ] Clica "Reservar"
- [ ] Vê loading "Salvando..."
- [ ] Vê mensagem "Reserva criada com sucesso!" (verde)
- [ ] Modal fecha automaticamente
- [ ] Formulário fica vazio
- [ ] No Supabase, pode ver a reserva salva

Se TODOS os ✓ estão marcados = **SUCESSO!** 🎉

---

## 🎯 Próximas Funcionalidades (Opcional)

```
1. Listar minhas reservas
   └─ Mostrar todas as reservas do usuário

2. Editar reserva
   └─ Abrir formulário com dados preenchidos
   └─ Mudar dados
   └─ Clicar "Atualizar"

3. Deletar reserva
   └─ Botão delete em cada reserva
   └─ Pedir confirmação
   └─ Remover do banco

4. Notificações
   └─ Enviar email quando reserva é criada
   └─ Enviar SMS de lembrete

5. PDF da reserva
   └─ Gerar documento
   └─ Enviar por email
```

---

## 💡 Dicas

1. **Teste com data futura**: Use uma data que ainda não passou
2. **Teste com horários vazios**: Deixe em branco e clique "Reservar" (deve dar erro)
3. **Teste conflito**: Crie uma reserva 14:00-16:00, depois tente 14:30-17:00 (deve conflitar)
4. **Teste sem ambiente**: Deixe "Local" vazio e clique "Reservar" (deve dar erro)
5. **Abra Supabase**: Enquanto está no app, abra o Supabase em outra aba para ver a reserva sendo criada em tempo real!

---

## ✅ Conclusão

**Tudo está pronto para usar!** 🚀

Siga os passos acima e sua reserva será criada e salva no Supabase automaticamente.

Se tiver dúvidas ou erros, verifique o arquivo `RESUMO_IMPLEMENTACAO_RESERVAS.md` para mais detalhes técnicos.

**Bom uso!** 🎉
