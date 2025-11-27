# 🎯 Root Cause Analysis: temBlocos Hardcoded em gestao_screen.dart

## 🔴 Problema Identificado

**Arquivo:** `lib/screens/gestao_screen.dart`  
**Linha:** ~213  
**Causa:** `temBlocos: true` está **hardcoded** ao navegar para Portaria

```dart
// ANTES (Problema):
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => PortariaRepresentanteScreen(
      condominioId: widget.condominioId,
      condominioNome: widget.condominioNome,
      condominioCnpj: widget.condominioCnpj,
      temBlocos: true,  // ← SEMPRE true, ignora banco de dados!
    ),
  ),
);
```

---

## ❌ Por Que Isso É Um Problema

### Fluxo Atual (Quebrado):

```
Usuário em Unidade Morador
    ↓
Marca: "Sem Blocos" (temBlocos = false)
    ↓
Salva no banco: tem_blocos = FALSE ✅
    ↓
Vai para Gestão
    ↓
Clica em "Portaria"
    ↓
gestao_screen.dart passa: temBlocos: true (hardcoded)
    ↓
PortariaRepresentanteScreen recebe: widget.temBlocos = true ❌
    ↓
Ignora banco de dados, usa true
    ↓
Exibe: "Unidade Bloco A - 101" (ERRADO!)
```

### Esperado (Correto):

```
Banco: tem_blocos = FALSE
    ↓
Portaria deve receber: temBlocos = false
    ↓
Exibe: "Unidade 101" (CORRETO!)
```

---

## ✅ Solução: Buscar Valor Real do Banco

### Passo 1: Analisar gestao_screen.dart

O arquivo tem `condominioId` disponível na classe:

```dart
class GestaoScreen extends StatefulWidget {
  final String? condominioId;  // ← DISPONÍVEL!
  final String? condominioNome;
  final String? condominioCnpj;

  const GestaoScreen({
    super.key,
    this.condominioId,
    this.condominioNome,
    this.condominioCnpj,
  });
```

### Passo 2: Buscar temBlocos do Banco

No momento da navegação, buscar o valor real:

```dart
// Buscar o condomínio para obter temBlocos
final service = CondominioInitService();
final condominio = await service.obterCondominioById(widget.condominioId ?? '');
final temBlocos = condominio?.temBlocos ?? false;

debugPrint('[GESTAO] Condomínio encontrado: ${condominio?.nome}');
debugPrint('[GESTAO] temBlocos do banco: $temBlocos');
```

### Passo 3: Passar Valor Real ao Navegar

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => PortariaRepresentanteScreen(
      condominioId: widget.condominioId,
      condominioNome: widget.condominioNome,
      condominioCnpj: widget.condominioCnpj,
      temBlocos: temBlocos,  // ← Valor real do banco!
    ),
  ),
);
```

---

## 📝 Implementação Completa

### Localizar o Código

Arquivo: `lib/screens/gestao_screen.dart`  
Procure por:

```dart
} else if (item['title'] == 'Portaria') {
```

### Substituir Por:

```dart
} else if (item['title'] == 'Portaria') {
  // Buscar temBlocos real do banco de dados
  debugPrint('═' * 80);
  debugPrint('🔴 [GESTAO] ═══ NAVEGANDO PARA PORTARIA ═══');
  debugPrint('═' * 80);
  debugPrint('[GESTAO] widget.condominioId: ${widget.condominioId}');
  
  // Buscar o condomínio para obter temBlocos
  final service = CondominioInitService();
  final condominio = await service.obterCondominioById(widget.condominioId ?? '');
  final temBlocos = condominio?.temBlocos ?? false;
  
  debugPrint('[GESTAO] Condomínio encontrado: ${condominio?.nome}');
  debugPrint('[GESTAO] temBlocos do banco: $temBlocos');
  debugPrint('[GESTAO] Navegando para Portaria com temBlocos=$temBlocos');
  debugPrint('═' * 80);
  
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PortariaRepresentanteScreen(
        condominioId: widget.condominioId,
        condominioNome: widget.condominioNome,
        condominioCnpj: widget.condominioCnpj,
        temBlocos: temBlocos,  // ← Valor real do banco!
      ),
    ),
  );
}
```

---

## ⚠️ Atenção: Callback Assíncrono

O método `obterCondominioById` é **assíncrono**, então precisamos de um callback:

```dart
} else if (item['title'] == 'Portaria') {
  _irParaPortaria();  // Chamar função assíncrona
}
```

E criar a função assíncrona em `_GestaoScreenState`:

```dart
Future<void> _irParaPortaria() async {
  debugPrint('═' * 80);
  debugPrint('🔴 [GESTAO] ═══ NAVEGANDO PARA PORTARIA ═══');
  debugPrint('═' * 80);
  debugPrint('[GESTAO] widget.condominioId: ${widget.condominioId}');
  
  try {
    // Buscar o condomínio para obter temBlocos
    final service = CondominioInitService();
    final condominio = await service.obterCondominioById(widget.condominioId ?? '');
    final temBlocos = condominio?.temBlocos ?? false;
    
    debugPrint('[GESTAO] Condomínio encontrado: ${condominio?.nome}');
    debugPrint('[GESTAO] temBlocos do banco: $temBlocos');
    debugPrint('[GESTAO] Navegando para Portaria com temBlocos=$temBlocos');
    debugPrint('═' * 80);
    
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PortariaRepresentanteScreen(
            condominioId: widget.condominioId,
            condominioNome: widget.condominioNome,
            condominioCnpj: widget.condominioCnpj,
            temBlocos: temBlocos,  // ← Valor real do banco!
          ),
        ),
      );
    }
  } catch (e) {
    debugPrint('[GESTAO] ❌ Erro ao buscar condomínio: $e');
    // Fallback: usar valor padrão
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PortariaRepresentanteScreen(
            condominioId: widget.condominioId,
            condominioNome: widget.condominioNome,
            condominioCnpj: widget.condominioCnpj,
            temBlocos: false,  // Fallback padrão
          ),
        ),
      );
    }
  }
}
```

---

## 📊 Verificar Imports

Certifique-se que gestao_screen.dart importa:

```dart
import 'package:condogaiaapp/services/condominio_init_service.dart';
import 'portaria_representante_screen.dart';
```

Se não tiver, adicionar ao topo do arquivo:

```dart
import 'package:condogaiaapp/services/condominio_init_service.dart';
```

---

## 🧪 Teste da Solução

### Passo 1: Executar com debug
```bash
flutter run -v
```

### Passo 2: Abrir Logcat
```bash
adb logcat | grep "GESTAO\|PORTARIA"
```

### Passo 3: Navegar para Portaria
- Ir a Gestão → Portaria

### Passo 4: Observar Logs

**Esperado:**
```
[GESTAO] temBlocos do banco: false
[GESTAO] Navegando para Portaria com temBlocos=false
[PORTARIA] widget.temBlocos (parâmetro recebido): false
[PORTARIA] _buildUnidadeExpandible() - label final: Unidade 101
```

**Resultado:**
- Se mostrar "Unidade 101" → ✅ CORRETO!
- Se mostrar "Unidade Bloco A - 101" → ❌ AINDA ERRADO

---

## 📌 Checklist

- [ ] Localizar linha ~213 em gestao_screen.dart
- [ ] Ler método de navegação para Portaria
- [ ] Adicionar import de CondominioInitService
- [ ] Criar função `_irParaPortaria()`
- [ ] Implementar busca de temBlocos do banco
- [ ] Testar navegação
- [ ] Verificar logs
- [ ] Confirmar que labels aparecem corretos
- [ ] Remover função antiga (se houver)

---

## 🎯 Resultado Esperado

Depois desta mudança:

1. **Ao navegar para Portaria:**
   - Valor real de `tem_blocos` é buscado do banco
   - Passado corretamente ao PortariaRepresentanteScreen

2. **Portaria exibe corretamente:**
   - Se `tem_blocos = false` → "Unidade 101"
   - Se `tem_blocos = true` → "Unidade Bloco A - 101"

3. **Sincronização automática:**
   - Mudar em Unidade Morador → Atualiza automaticamente em Portaria
   - Sem necessidade de reiniciar app

---

## 🚀 Alternativa: Se Usar Outro Service

Se o serviço de condomínio for diferente, adaptar conforme:

```dart
// Exemplo genérico:
final condominio = await _carregarCondominio(widget.condominioId);
final temBlocos = condominio['tem_blocos'] ?? false;
```

Conferir qual service está sendo usado no projeto.
