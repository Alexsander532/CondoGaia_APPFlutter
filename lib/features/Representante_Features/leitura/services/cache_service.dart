import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const String _unidadesKey = 'cached_unidades_';
  static const String _configKey = 'cached_config_';
  static const String _leiturasKey = 'cached_leituras_';

  static const Duration _unidadesTTL = Duration(hours: 24);
  static const Duration _configTTL = Duration(days: 7);
  static const Duration _leiturasTTL = Duration(minutes: 30);

  SharedPreferences? _prefs;
  Future<SharedPreferences>? _initFuture;

  Future<void> _ensureInitialized() async {
    if (_prefs != null) return;
    _initFuture ??= SharedPreferences.getInstance();
    _prefs = await _initFuture;
  }

  Future<void> init() async {
    await _ensureInitialized();
  }

  Future<T?> getCachedData<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    await _ensureInitialized();
    try {
      final cached = _prefs!.getString(key);
      if (cached == null) return null;

      final data = jsonDecode(cached);
      final timestamp = data['timestamp'] as int;
      final age = DateTime.now().millisecondsSinceEpoch - timestamp;

      if (age > _getTTL(key).inMilliseconds) {
        await _prefs!.remove(key);
        return null;
      }

      return fromJson(data['value']);
    } catch (e) {
      print('Erro ao ler cache: $e');
      return null;
    }
  }

  Future<void> cacheData<T>(
    String key,
    T data,
    Map<String, dynamic> Function(T) toJson,
  ) async {
    await _ensureInitialized();
    try {
      final cacheData = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'value': toJson(data),
      };
      await _prefs!.setString(key, jsonEncode(cacheData));
    } catch (e) {
      print('Erro ao salvar cache: $e');
    }
  }

  Future<void> clearCache(String pattern) async {
    await _ensureInitialized();
    try {
      final keys = _prefs!.getKeys();
      for (final key in keys) {
        if (key.contains(pattern)) {
          await _prefs!.remove(key);
        }
      }
    } catch (e) {
      print('Erro ao limpar cache: $e');
    }
  }

  Duration _getTTL(String key) {
    if (key.startsWith(_unidadesKey)) return _unidadesTTL;
    if (key.startsWith(_configKey)) return _configTTL;
    if (key.startsWith(_leiturasKey)) return _leiturasTTL;
    return const Duration(hours: 1);
  }

  Future<bool> isCacheExpired(String key) async {
    await _ensureInitialized();
    try {
      final cached = _prefs!.getString(key);
      if (cached == null) return true;

      final data = jsonDecode(cached);
      final timestamp = data['timestamp'] as int;
      final age = DateTime.now().millisecondsSinceEpoch - timestamp;

      return age > _getTTL(key).inMilliseconds;
    } catch (e) {
      return true;
    }
  }

  Future<void> clearAllCache() async {
    await _ensureInitialized();
    try {
      await _prefs!.clear();
    } catch (e) {
      print('Erro ao limpar todo o cache: $e');
    }
  }

  // Métodos específicos para cada tipo de dado
  Future<List<T>?> getCachedList<T>(
    String baseKey,
    String id,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final key = '$baseKey$id';
    // getCachedData already ensures initialization
    final data = await getCachedData<Map<String, dynamic>>(key, (json) => json);

    if (data == null) return null;

    final items = data['items'] as List?;
    if (items == null) return null;

    return items
        .map((item) => fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> cacheList<T>(
    String baseKey,
    String id,
    List<T> data,
    Map<String, dynamic> Function(T) toJson,
  ) async {
    final key = '$baseKey$id';
    // cacheData already ensures initialization
    await cacheData(key, {
      'items': data.map((item) => toJson(item)).toList(),
    }, (data) => data);
  }
}
