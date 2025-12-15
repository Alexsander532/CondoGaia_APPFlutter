import 'package:flutter/foundation.dart';
import 'dart:html' as html;
import 'dart:convert';

/// Serviço para persistir o estado de navegação na web
/// Permite que a aplicação mantenha o contexto quando a página é recarregada
class NavigationPersistenceService {
  static const String _storageKeyRoute = 'app_current_route';
  static const String _storageKeyParams = 'app_route_params';

  /// Salva a rota atual e seus parâmetros
  static void saveCurrentRoute(String routeName, Map<String, dynamic> params) {
    if (kIsWeb) {
      try {
        html.window.localStorage[_storageKeyRoute] = routeName;
        html.window.localStorage[_storageKeyParams] = jsonEncode(params);
        debugPrint('[NavigationPersistence] 💾 Rota salva: $routeName com parâmetros: $params');
      } catch (e) {
        debugPrint('[NavigationPersistence] ❌ Erro ao salvar rota: $e');
      }
    }
  }

  /// Recupera a rota salva
  static String? getSavedRoute() {
    if (kIsWeb) {
      try {
        final route = html.window.localStorage[_storageKeyRoute];
        if (route != null && route.isNotEmpty) {
          debugPrint('[NavigationPersistence] 📂 Rota recuperada: $route');
          return route;
        }
      } catch (e) {
        debugPrint('[NavigationPersistence] ❌ Erro ao recuperar rota: $e');
      }
    }
    return null;
  }

  /// Recupera os parâmetros salvos da rota
  static Map<String, dynamic> getSavedParams() {
    if (kIsWeb) {
      try {
        final paramsJson = html.window.localStorage[_storageKeyParams];
        if (paramsJson != null && paramsJson.isNotEmpty) {
          final params = jsonDecode(paramsJson) as Map<String, dynamic>;
          debugPrint('[NavigationPersistence] 📦 Parâmetros recuperados: $params');
          return params;
        }
      } catch (e) {
        debugPrint('[NavigationPersistence] ❌ Erro ao recuperar parâmetros: $e');
      }
    }
    return {};
  }

  /// Limpa a rota salva
  static void clearSavedRoute() {
    if (kIsWeb) {
      try {
        html.window.localStorage.remove(_storageKeyRoute);
        html.window.localStorage.remove(_storageKeyParams);
        debugPrint('[NavigationPersistence] 🗑️ Rota limpa do localStorage');
      } catch (e) {
        debugPrint('[NavigationPersistence] ❌ Erro ao limpar rota: $e');
      }
    }
  }

  /// Verifica se há uma rota salva
  static bool hasSavedRoute() {
    if (kIsWeb) {
      try {
        return html.window.localStorage.containsKey(_storageKeyRoute);
      } catch (e) {
        return false;
      }
    }
    return false;
  }
}
