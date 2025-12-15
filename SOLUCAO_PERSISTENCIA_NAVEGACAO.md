# 🔄 Persistência de Navegação - Solução Web Refresh

## Problema
Quando o usuário atualiza a página (F5/refresh) na web, a aplicação Flutter volta para o **Dashboard** em vez de manter o contexto da tela atual (como Portaria Representante).

## Solução Implementada

### 1. **Novo Serviço: `NavigationPersistenceService`**
Localização: `lib/services/navigation_persistence_service.dart`

Este serviço utiliza **localStorage do navegador** para persistir:
- Nome da rota atual
- Parâmetros da navegação (IDs, nomes, dados)

**Métodos disponíveis:**
- `saveCurrentRoute(String routeName, Map<String, dynamic> params)` - Salva a rota
- `getSavedRoute()` - Recupera a rota salva
- `getSavedParams()` - Recupera os parâmetros
- `clearSavedRoute()` - Limpa a persistência
- `hasSavedRoute()` - Verifica se há rota salva

### 2. **Modificações no `main.dart`**

#### Adicionado:
- Import do `NavigationPersistenceService`
- Import do `PortariaRepresentanteScreen`

#### Novo método `_restorePreviousRoute()`:
```dart
Future<void> _restorePreviousRoute(LoginResult result) async {
  if (!mounted) return;

  final savedRoute = NavigationPersistenceService.getSavedRoute();
  final savedParams = NavigationPersistenceService.getSavedParams();

  if (savedRoute == 'portaria_representante') {
    // Restaurar tela de Portaria com parâmetros salvos
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => PortariaRepresentanteScreen(
          condominioId: savedParams['condominioId'],
          condominioNome: savedParams['condominioNome'],
          condominioCnpj: savedParams['condominioCnpj'],
          representanteId: savedParams['representanteId'],
          temBlocos: savedParams['temBlocos'] ?? false,
        ),
      ),
    );
  } else if (savedRoute == 'representante_home') {
    // Restaurar tela de Home do Representante
    // ...
  }
}
```

#### Modificado método `_checkAuthStatus()`:
Antes de redirecionar pelo tipo de usuário, verifica se há uma rota salva:
```dart
if (NavigationPersistenceService.hasSavedRoute()) {
  await _restorePreviousRoute(result);
} else {
  await _redirectByUserType(result);
}
```

### 3. **PortariaRepresentanteScreen**
Localização: `lib/screens/portaria_representante_screen.dart`

#### Adicionado no `initState()`:
```dart
// ✅ Salvar navegação atual para persistir em caso de refresh na web
NavigationPersistenceService.saveCurrentRoute('portaria_representante', {
  'condominioId': widget.condominioId,
  'condominioNome': widget.condominioNome,
  'condominioCnpj': widget.condominioCnpj,
  'representanteId': widget.representanteId,
  'temBlocos': widget.temBlocos,
});
```

### 4. **RepresentanteHomeScreen**
Localização: `lib/screens/representante_home_screen.dart`

#### Adicionado no método `build()`:
```dart
// ✅ Salvar navegação atual para persistir em caso de refresh na web
NavigationPersistenceService.saveCurrentRoute('representante_home', {
  'condominioId': widget.condominioId,
  'condominioNome': widget.condominioNome,
  'condominioCnpj': widget.condominioCnpj,
});
```

#### Modificado método `_handleLogout()`:
Agora limpa a navegação persistida antes de fazer logout:
```dart
// ✅ Limpar navegação persistida antes de fazer logout
NavigationPersistenceService.clearSavedRoute();
```

### 5. **RepresentanteDashboardScreen**
Localização: `lib/screens/representante_dashboard_screen.dart`

#### Modificado método `_handleLogout()`:
Similar ao RepresentanteHomeScreen, limpa a navegação ao fazer logout.

## Como Funciona

### Fluxo Normal (sem refresh):
1. Usuário navega para Portaria → `initState()` salva a rota
2. Usuário realiza ações normalmente
3. A rota permanece salva no localStorage

### Fluxo Com Refresh (F5 no navegador):
1. Usuário faz refresh na página (F5)
2. Aplicação passa pelo `SplashScreen` novamente
3. `_checkAuthStatus()` verifica login automático
4. Se há rota salva e usuário está logado:
   - `_restorePreviousRoute()` é chamado
   - A tela anterior (Portaria) é restaurada com todos os parâmetros
5. Se não há rota salva:
   - Fluxo normal de redirecionamento por tipo de usuário

### Logout:
1. Usuário clica em "Sair"
2. `_handleLogout()` limpa a rota persistida
3. Usuário é deslogado e redirecionado para LoginScreen

## Suporte Futuro

Para adicionar persistência em outras telas, basta:

1. Adicionar import do serviço:
```dart
import '../services/navigation_persistence_service.dart';
```

2. Salvar a rota no `initState()` ou `build()`:
```dart
NavigationPersistenceService.saveCurrentRoute('nome_rota', {
  'param1': valor1,
  'param2': valor2,
});
```

3. Adicionar a rota ao método `_restorePreviousRoute()` em `main.dart`:
```dart
} else if (savedRoute == 'nome_rota') {
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (context) => MeuScreen(
        param1: savedParams['param1'],
        param2: savedParams['param2'],
      ),
    ),
  );
}
```

## Limitações

- ✅ Funciona apenas na **web** (usa `dart:html`)
- ✅ Dados são persistidos no **localStorage do navegador**
- ✅ Funcionário se deslogar em outra aba, a rota não será restaurada
- ✅ Se o usuário limpar o cache/localStorage, a persistência é perdida

## Teste

Para testar:
1. Navegue até a tela de Portaria
2. Pressione F5 (refresh)
3. Você deve ser mantido na tela de Portaria com todos os dados carregados
4. Verifique o console do navegador (DevTools) para logs de debug
