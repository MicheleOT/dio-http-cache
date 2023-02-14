import 'package:dio/dio.dart';
import 'package:dio_http_cache/src/dio_cache_manager.dart';

/// try to get maxAge and maxStale from response headers.
/// local settings will always overview the value get from service.
Options buildServiceCacheOptions(
        {Options? options,
        Duration? maxStale,
        String? primaryKey,
        String? subKey,
        bool? forceRefresh}) =>
    buildConfigurableCacheOptions(
        options: options,
        maxStale: maxStale,
        primaryKey: primaryKey,
        subKey: subKey,
        forceRefresh: forceRefresh);

/// build a normal cache options
Options buildCacheOptions(Duration maxAge,
        {Duration? maxStale,
        String? primaryKey,
        String? subKey,
        Options? options,
        bool? forceRefresh}) =>
    buildConfigurableCacheOptions(
        maxAge: maxAge,
        options: options,
        primaryKey: primaryKey,
        subKey: subKey,
        maxStale: maxStale,
        forceRefresh: forceRefresh);

/// if [maxAge] is null, will try to get [maxAge] and [maxStale] from response headers.
/// local settings will always overview the value get from service.
Options buildConfigurableCacheOptions(
    {Options? options,
    Duration? maxAge,
    Duration? maxStale,
    String? primaryKey,
    String? subKey,
    bool? forceRefresh}) {
  if (options == null) {
    options = Options();
    options.extra = {};
  } else if (options.responseType == ResponseType.stream) {
    throw Exception("ResponseType.stream is not supported");
  } else if (options.extra == null) {
    options.extra = {};
  }
  options.extra!.addAll({DIO_CACHE_KEY_TRY_CACHE: true});
  if (maxAge != null) {
    options.extra!.addAll({DIO_CACHE_KEY_MAX_AGE: maxAge});
  }
  if (maxStale != null) {
    options.extra!.addAll({DIO_CACHE_KEY_MAX_STALE: maxStale});
  }
  if (primaryKey != null) {
    options.extra!.addAll({DIO_CACHE_KEY_PRIMARY_KEY: primaryKey});
  }
  if (subKey != null) {
    options.extra!.addAll({DIO_CACHE_KEY_SUB_KEY: subKey});
  }
  if (forceRefresh != null) {
    options.extra!.addAll({DIO_CACHE_KEY_FORCE_REFRESH: forceRefresh});
  }
  return options;
}
