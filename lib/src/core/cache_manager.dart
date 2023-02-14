import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio_http_cache/src/core/cache_config.dart';
import 'package:dio_http_cache/src/core/obj.dart';
import 'package:dio_http_cache/src/store/base/cache_store.dart';
import 'package:dio_http_cache/src/store/disk_cache_store.dart';
import 'package:dio_http_cache/src/store/memory_cache_store.dart';

class CacheManager {
  CacheConfig _config;
  CacheStore? _diskCacheStore;
  CacheStore? _memoryCacheStore;
  late Utf8Encoder _utf8encoder;

  CacheManager(this._config) {
    _utf8encoder = const Utf8Encoder();
    if (!_config.skipDiskCache)
      _diskCacheStore = _config.diskStore ??
          DiskCacheStore(_config.databasePath, _config.databaseName,
              _config.encrypt, _config.decrypt);
    if (!_config.skipMemoryCache)
      _memoryCacheStore = MemoryCacheStore(_config.maxMemoryCacheCount);
  }

  Future<CacheObj?> _pullFromCache(String key, {String? subKey}) async {
    key = _convertMd5(key);
    if (subKey != null) {
      subKey = _convertMd5(subKey);
    }
    var obj = await _memoryCacheStore?.getCacheObj(key, subKey: subKey);
    if (obj == null) {
      obj = await _diskCacheStore?.getCacheObj(key, subKey: subKey);
      if (obj != null) {
        await _memoryCacheStore?.setCacheObj(obj);
      }
    }
    if (obj != null) {
      var now = DateTime.now().millisecondsSinceEpoch;
      if (obj.maxStaleDate != null && obj.maxStaleDate! > 0) {
        //if maxStaleDate exist, Remove it if maxStaleDate expired.
        if (obj.maxStaleDate! < now) {
          await delete(key, subKey: subKey);
          return null;
        }
      } else {
        //if maxStaleDate NOT exist, Remove it if maxAgeDate expired.
        if (obj.maxAgeDate! < now) {
          await delete(key, subKey: subKey);
          return null;
        }
      }
    }
    return obj;
  }

  Future<CacheObj?> pullFromCacheBeforeMaxAge(String key,
      {String? subKey}) async {
    var obj = await _pullFromCache(key, subKey: subKey);
    if (obj != null &&
        obj.maxAgeDate != null &&
        obj.maxAgeDate! < DateTime.now().millisecondsSinceEpoch) {
      return null;
    }
    return obj;
  }

  Future<CacheObj?> pullFromCacheBeforeMaxStale(String key,
      {String? subKey}) async {
    return await _pullFromCache(key, subKey: subKey);
  }

  Future<bool> pushToCache(CacheObj obj) {
    obj.key = _convertMd5(obj.key);
    if (null != obj.subKey) obj.subKey = _convertMd5(obj.subKey!);

    if (null == obj.maxAgeDate || obj.maxAgeDate! <= 0) {
      obj.maxAge = _config.defaultMaxAge;
    }
    if (null == obj.maxAgeDate || obj.maxAgeDate! <= 0) {
      return Future.value(false);
    }
    if ((null == obj.maxStaleDate || obj.maxStaleDate! <= 0) &&
        null != _config.defaultMaxStale) {
      obj.maxStale = _config.defaultMaxStale;
    }

    return _getCacheFutureResult(_memoryCacheStore, _diskCacheStore,
        _memoryCacheStore?.setCacheObj(obj), _diskCacheStore?.setCacheObj(obj));
  }

  Future<bool> delete(String key, {String? subKey}) {
    key = _convertMd5(key);
    if (null != subKey) subKey = _convertMd5(subKey);

    return _getCacheFutureResult(
        _memoryCacheStore,
        _diskCacheStore,
        _memoryCacheStore?.delete(key, subKey: subKey),
        _diskCacheStore?.delete(key, subKey: subKey));
  }

  Future<bool> clearExpired() {
    return _getCacheFutureResult(_memoryCacheStore, _diskCacheStore,
        _memoryCacheStore?.clearExpired(), _diskCacheStore?.clearExpired());
  }

  Future<bool> clearAll() {
    return _getCacheFutureResult(_memoryCacheStore, _diskCacheStore,
        _memoryCacheStore?.clearAll(), _diskCacheStore?.clearAll());
  }

  String _convertMd5(String str) {
    return md5
        .convert(_utf8encoder.convert(str))
        .bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
  }

  Future<bool> _getCacheFutureResult(
      CacheStore? memoryCacheStore,
      CacheStore? diskCacheStore,
      Future<bool>? memoryCacheFuture,
      Future<bool>? diskCacheFuture) async {
    var isCachedInMemory =
        (memoryCacheStore == null) ? true : await memoryCacheFuture!;
    var isCachedInDisk =
        (diskCacheStore == null) ? true : await diskCacheFuture!;
    return isCachedInMemory && isCachedInDisk;
  }
}
