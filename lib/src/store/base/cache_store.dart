import 'package:dio_http_cache/src/core/obj.dart';

abstract class CacheStore {
  /// Retrieve an object from cache
  Future<CacheObj?> getCacheObj(String key, {String? subKey});

  /// Set an object in cache
  /// Return true if object was successfully created/updated
  Future<bool> setCacheObj(CacheObj obj);

  /// Delete an object from cache
  /// Return true if object was successfully deleted
  Future<bool> delete(String key, {String? subKey});

  /// Clear expire objects in cache
  /// Return true if cache was successfully cleared from expired objects
  Future<bool> clearExpired();

  /// Remove everything present in cache
  /// Return true if cache was successfully cleared
  Future<bool> clearAll();
}
