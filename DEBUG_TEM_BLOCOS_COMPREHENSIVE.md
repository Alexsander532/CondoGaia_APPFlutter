# 🔍 Debug Completo: temBlocos not Working

## Resumo da Implementação de Debug

Adicionar logging extensivo em todo o fluxo de `temBlocos` para rastrear onde o valor está sendo perdido ou incorretamente definido.

---

## 📋 Pontos de Logging Implementados

### 1️⃣ **gestao_screen.dart** (Linha ~213)
**Função:** Navegação para Portaria

```dart
// Quando clica em 'Portaria' no menu de gestão
debugPrint('═' * 80);
debugPrint('🔴 [GESTAO] ═══ NAVEGANDO PARA PORTARIA ═══');
debugPrint('═' * 80);
debugPrint('[GESTAO] Clicou em: Portaria');
debugPrint('[GESTAO] widget.condominioId: ${widget.condominioId}');
debugPrint('[GESTAO] widget.condominioNome: ${widget.condominioNome}');
debugPrint('[GESTAO] widget.condominioCnpj: ${widget.condominioCnpj}');
debugPrint('[GESTAO] temBlocos a ser passado: true (HARDCODED!)');
debugPrint('[GESTAO] ⚠️ AVISO: temBlocos está hardcoded como true');
debugPrint('═' * 80);
```

**O que mostra:**
- ✅ Confirmação que entrou na navegação
- ✅ IDs do condomínio
- ❌ **PROBLEMA ENCONTRADO:** temBlocos está hardcoded como `true`!

---

### 2️⃣ **portaria_representante_screen.dart - initState()** (Linha ~165)
**Função:** Inicialização da tela

```dart
debugPrint('═' * 80);
debugPrint('🔵 [PORTARIA] ═══ INIT STATE ═══');
debugPrint('═' * 80);
debugPrint('[PORTARIA] widget.temBlocos (parâmetro recebido): ${widget.temBlocos}');
debugPrint('[PORTARIA] _temBlocos ANTES de _carregarTemBlocos: $_temBlocos');
// ... inicialização ...
debugPrint('[PORTARIA] _temBlocos DEPOIS de _carregarTemBlocos: $_temBlocos');
debugPrint('[PORTARIA] Iniciando carregamento de dados...');
debugPrint('═' * 80);
```

**O que mostra:**
- ✅ Valor recebido no parâmetro
- ✅ Valor antes/depois de processar

---

### 3️⃣ **portaria_representante_screen.dart - _carregarTemBlocos()** (Linha ~1210)
**Função:** Carrega o valor real de temBlocos

```dart
void _carregarTemBlocos() {
  debugPrint('═' * 80);
  debugPrint('🔵 [PORTARIA] ═══ CARREGANDO TEM_BLOCOS ═══');
  debugPrint('═' * 80);
  debugPrint('[PORTARIA] Entrada em _carregarTemBlocos()');
  debugPrint('[PORTARIA] widget.temBlocos recebido: ${widget.temBlocos}');
  debugPrint('[PORTARIA] widget.temBlocos != true: ${widget.temBlocos != true}');
  
  if (widget.temBlocos != true) {
    debugPrint('[PORTARIA] ✓ Entrando na condição: widget.temBlocos != true');
    debugPrint('[PORTARIA] Definindo _temBlocos = ${widget.temBlocos}');
    _temBlocos = widget.temBlocos;
    debugPrint('[PORTARIA] ✓ _temBlocos agora é: $_temBlocos');
    return;
  }
  
  debugPrint('[PORTARIA] ✗ NÃO entrou na condição (widget.temBlocos == true)');
}
```

**O que mostra:**
- ✅ Se entra na condição de carregar
- ✅ Valor final de _temBlocos
- ❌ Se não entra em condição, mantém `true`

---

### 4️⃣ **portaria_representante_screen.dart - _buildUnidadeExpandible()** (Linha ~1785)
**Função:** Formata label para Proprietários/Inquilinos

```dart
debugPrint('[PORTARIA] _buildUnidadeExpandible() - Label formatting:');
debugPrint('[PORTARIA]   - unidade: $unidade');
debugPrint('[PORTARIA]   - _temBlocos: $_temBlocos');
debugPrint('[PORTARIA]   - unidade.contains("/"): ${unidade.contains("/")}');
debugPrint('[PORTARIA]   - temBlocosCheck: $temBlocosCheck');
debugPrint('[PORTARIA]   - label final: $label');
```

**O que mostra:**
- ✅ Valor de _temBlocos no momento de renderização
- ✅ Se a unidade tem "/"
- ✅ Label final mostrado ao usuário
- ❌ Se label está errado, mostra a condição exata

---

### 5️⃣ **portaria_representante_screen.dart - _buildUnidadeAutorizadosExpandible()** (Linha ~2920)
**Função:** Formata label para Autorizados

Mesmo padrão que acima, mas para a seção de Autorizados:

```dart
debugPrint('[PORTARIA] _buildUnidadeAutorizadosExpandible() - Label formatting:');
debugPrint('[PORTARIA]   - unidade: $unidade');
debugPrint('[PORTARIA]   - _temBlocos: $_temBlocos');
debugPrint('[PORTARIA]   - unidade.contains("/"): ${unidade.contains("/")}');
debugPrint('[PORTARIA]   - temBlocosCheck: $temBlocosCheck');
debugPrint('[PORTARIA]   - label final: $label');
```

---

## 🔍 Como Ler o Output de Debug

### Ordem de Execução (em ordem de aparição no log):

1. **[GESTAO]** - Você clicou em Portaria
   - Mostra que `temBlocos: true` está sendo passado

2. **[PORTARIA] INIT STATE** - Portaria iniciou
   - Mostra `widget.temBlocos = true` (porque foi passado)

3. **[PORTARIA] CARREGANDO TEM_BLOCOS** - Função que tenta corrigir
   - Se `widget.temBlocos == true`, não muda `_temBlocos`
   - Problema: fica com `true` eternamente

4. **[PORTARIA] _buildUnidadeExpandible()** - Para cada unidade
   - Mostra o label final que é exibido
   - Se mostra "Bloco", significa `_temBlocos = true`
   - Se mostra sem "Bloco", significa `_temBlocos = false`

---

## ⚠️ Problema Identificado

### O Culpado: **gestao_screen.dart (linha ~213)**

```dart
temBlocos: true, // ← HARDCODED! Sempre passa true
```

### Por Que É Um Problema:

1. **Banco de Dados:** `tem_blocos = FALSE` ✅
2. **Unidade Morador:** Mostra corretamente "Sem Blocos" ✅
3. **Navegação para Portaria:** Passa `true` (hardcoded) ❌
4. **Portaria:** Recebe `true`, ignora banco de dados ❌
5. **Display:** Mostra "Unidade Bloco A - 101" ❌

---

## ✅ Solução

### Opção A: Fetch em gestao_screen.dart (Recomendado)

Antes de navegar, buscar `tem_blocos` do banco de dados:

```dart
// Em gestao_screen.dart, antes do Navigator.push

// Buscar o valor real do banco de dados
final condominio = await CondominioInitService.obterCondominioById(widget.condominioId);
final temBlocos = condominio?.temBlocos ?? false;

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => PortariaRepresentanteScreen(
      condominioId: widget.condominioId,
      condominioNome: widget.condominioNome,
      condominioCnpj: widget.condominioCnpj,
      temBlocos: temBlocos, // ← Valor real do banco
    ),
  ),
);
```

### Opção B: Fetch em portaria_representante_screen.dart

Deixar que Portaria busque o valor do banco usando `condominioId`.

---

## 📊 Leitura do Debug Output

### Cenário Esperado Correto (temBlocos = false):

```
[GESTAO] temBlocos a ser passado: true (HARDCODED!)
[PORTARIA] widget.temBlocos (parâmetro recebido): true
[PORTARIA] _temBlocos ANTES: true
[PORTARIA] _temBlocos DEPOIS: false  ← Se conseguisse carregar do banco
[PORTARIA] _buildUnidadeExpandible() - label final: Unidade 101  ← Correto!
```

### Cenário Atual (Problema):

```
[GESTAO] temBlocos a ser passado: true (HARDCODED!)
[PORTARIA] widget.temBlocos (parâmetro recebido): true
[PORTARIA] _temBlocos ANTES: true
[PORTARIA] _temBlocos DEPOIS: true  ← Não consegue carregar, fica true
[PORTARIA] _buildUnidadeExpandible() - label final: Unidade Bloco A - 101  ← ERRADO!
```

---

## 🎯 Próximos Passos

1. **Executar App com Debug On**
   - Rodar em modo debug
   - Abrir Logcat/Console do Flutter

2. **Navegar para Portaria**
   - Ir até Gestão → Portaria
   - Observar logs

3. **Buscar Strings de Debug**
   - Procurar por: `[GESTAO]`, `[PORTARIA]`
   - Ler sequência de logs

4. **Identificar Exato Problema**
   - Logs mostrarão exatamente onde valor está errado

5. **Implementar Solução**
   - Após identificar, usar Opção A ou B acima

---

## 📝 Resumo dos Logs

| Ponto | Variável | Função |
|-------|----------|--------|
| gestao_screen | temBlocos | Mostrar valor hardcoded |
| portaria initState | widget.temBlocos | Mostrar parâmetro recebido |
| _carregarTemBlocos | _temBlocos | Mostrar valor processado |
| _buildUnidadeExpandible | _temBlocos | Mostrar no momento da renderização |
| _buildUnidadeAutorizadosExpandible | _temBlocos | Mostrar no momento da renderização |

---

## 🎬 Como Executar o Debug

```bash
# 1. Abrir o app em modo debug
flutter run -v

# 2. Abrir Logcat (Android Studio ou via terminal)
adb logcat | grep "PORTARIA\|GESTAO"

# 3. Navegar para Portaria e observar logs
```

---

## 📌 Checklist

- [x] Logging em gestao_screen.dart (navegação)
- [x] Logging em portaria initState
- [x] Logging em _carregarTemBlocos()
- [x] Logging em _buildUnidadeExpandible() (Prop/Inq)
- [x] Logging em _buildUnidadeAutorizadosExpandible() (Autorizados)
- [ ] Executar app e coletar logs
- [ ] Analisar logs e identificar problema
- [ ] Implementar solução (Opção A ou B)
- [ ] Testar com novo valor
- [ ] Verificar que labels aparecem corretos
