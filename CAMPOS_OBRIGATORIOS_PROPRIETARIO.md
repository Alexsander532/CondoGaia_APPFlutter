# 📋 CAMPOS OBRIGATÓRIOS - SEÇÃO PROPRIETÁRIO

## ✅ Campos Obrigatórios (Requeridos)

| Campo | Tipo | Validação | Status |
|-------|------|-----------|--------|
| **Nome*** | Texto | Não vazio | ✅ Obrigatório |
| **CPF/CNPJ*** | Texto | Não vazio + Formato válido | ✅ Obrigatório |

*O asterisco (*) na UI indica campo obrigatório*

---

## 📝 Campos Opcionais (Preenchimento Livre)

| Campo | Tipo | Padrão | Observação |
|-------|------|--------|-----------|
| CEP | Texto | Vazio | Opcional |
| Endereço | Texto | Vazio | Opcional |
| Número | Texto | Vazio | Opcional |
| Bairro | Texto | Vazio | Opcional |
| Cidade | Texto | Vazio | Opcional |
| Estado | Texto | Vazio | Opcional |
| Telefone | Texto | Vazio | Opcional |
| Celular | Texto | Vazio | Opcional |
| Email | Texto | Vazio | Opcional |
| Cônjuge | Texto | Vazio | Opcional |
| Multipropietários | Texto | Vazio | Opcional |
| Moradores | Texto | Vazio | Opcional |

---

## 🎛️ Campos com Opções (Radio Buttons)

| Campo | Opções | Padrão Atual | Padrão Recomendado |
|-------|--------|--------------|-------------------|
| **Agrupar boletos** | Sim / Não | 'nao' ✅ | 'nao' (Não) |
| **Matrícula do Imóvel** | Fazer Upload / Não | 'nao' ✅ | 'nao' (Não) |

**Status:** ✅ Já estão com padrão correto como "Não" (false)

---

## 🔍 Resumo da Validação no Código

### Função `_salvarProprietario()`
```dart
// Validação atual
if (_proprietario == null || _proprietario!.id.isEmpty) {
  // Mostra erro: "Nenhum proprietário cadastrado"
  return;
}

// Dados coletados (Todos os campos opcionais podem ser null)
final dadosAtualizacao = <String, dynamic>{
  'nome': _proprietarioNomeController.text.trim(),
  'cpf_cnpj': _proprietarioCpfCnpjController.text.trim(),
  'cep': _proprietarioCepController.text.trim().isEmpty ? null : ...,
  // ... outros campos opcionais
};
```

### Modelo `Proprietario`
```dart
// Campos obrigatórios no construtor
required this.nome,
required this.cpfCnpj,

// Campos opcionais (podem ser null)
this.cep,
this.endereco,
this.numero,
// ... etc
```

---

## 🎯 Próximos Passos

### ✅ Já Implementado
- [x] Agrupar boletos padrão como "Não"
- [x] Matrícula do Imóvel padrão como "Não"

### 📌 Para Validar
- [ ] Verificar se UI mostra claramente os campos obrigatórios (asterisco *)
- [ ] Confirmar se validação de CPF está funcionando antes de salvar
- [ ] Testar comportamento ao tentar salvar sem Nome ou CPF

---

## 💾 Dados Salvos no Banco

### Obrigatórios (NOT NULL)
- `nome`
- `cpf_cnpj`

### Opcionais (NULL allowed)
- Todos os outros (cep, endereco, numero, bairro, cidade, estado, telefone, celular, email, conjuge, multiproprietarios, moradores)

---

## 📱 Como os Campos Aparecem na UI

```
SEÇÃO PROPRIETÁRIO
├─ Nome* ...................... [Text Field] ⭐ OBRIGATÓRIO
├─ CPF/CNPJ* .................. [Text Field] ⭐ OBRIGATÓRIO
├─ CEP ........................ [Text Field]
├─ Endereço ................... [Text Field]
├─ Número ..................... [Text Field]
├─ Bairro ..................... [Text Field]
├─ Cidade ..................... [Text Field]
├─ Estado ..................... [Text Field]
├─ Telefone ................... [Text Field]
├─ Celular .................... [Text Field]
├─ Email ...................... [Text Field]
├─ Cônjuge .................... [Text Field]
├─ Multipropietários .......... [Text Field]
├─ Moradores .................. [Text Field]
├─ Agrupar boletos ............ ◉ Não  ○ Sim (Padrão: Não) ✅
├─ Matrícula do Imóvel ........ ◉ Não  ○ Fazer Upload (Padrão: Não) ✅
└─ [SALVAR PROPRIETÁRIO] ....... [Button]
```
