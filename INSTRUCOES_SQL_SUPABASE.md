# 🗄️ Como Executar o SQL no Supabase

## Passo 1: Acessar o Supabase
1. Vá para https://supabase.com
2. Faça login na sua conta
3. Selecione o projeto **CondoGaia**

## Passo 2: Acessar o SQL Editor
1. No menu lateral, clique em **SQL Editor**
2. Clique em **+ New Query**

## Passo 3: Copiar e Executar o SQL
1. Abra o arquivo `SQL_ADD_TEM_BLOCOS.sql` da pasta do projeto
2. Copie **apenas** o comando SQL principal (primeiro comando ALTER TABLE):

```sql
ALTER TABLE condominios
ADD COLUMN tem_blocos boolean DEFAULT false NOT NULL;
```

3. Cole no editor do Supabase
4. Clique no botão **▶️ Run** (ou `Ctrl + Enter`)

## Passo 4: Confirmar que Funcionou
Você deve ver uma mensagem como:
```
✓ Success: ALTER TABLE
```

Se aparecer algum erro do tipo:
- `column "tem_blocos" of relation "condominios" already exists` → A coluna já existe (ok, pode prosseguir)
- Outro erro → Avise para corrigir

## Passo 5: Verificar a Coluna (Opcional)
Se quiser confirmar visualmente:
1. No menu, vá em **Table Editor**
2. Selecione a tabela **condominios**
3. Procure pela coluna `tem_blocos` no final da lista

---

## ✅ Pronto!
Depois de executar, me avisa que continuamos para o próximo passo (Atualizar o modelo Condominio).
