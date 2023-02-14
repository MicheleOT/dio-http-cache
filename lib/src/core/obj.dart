import 'package:json_annotation/json_annotation.dart';

part 'obj.g.dart';

/// This class represents a serializable cache object.
/// It will be used by hive [ICacheStore] implementations to fetch or update an
/// object in itself
@JsonSerializable()
class CacheObj {
  /// First part of key used when adding the element inside an [ICacheStore] implementation
  String key;

  /// Second part of key used when adding the element inside an [ICacheStore] implementation
  String? subKey;

  /// Int representing the date the object was created + [Duration] that
  /// represents when the object will expire.
  /// This value will be used to evaluate if the object is valid in [DioCacheManager._onRequest]
  /// If [maxAge] has not been called this will be null.
  @JsonKey(name: "max_age_date")
  int? maxAgeDate;

  /// Int representing the date the object was created + [Duration] that
  /// represents when the object will expire.
  /// This value will be used in case of a REST call encountered an error to
  /// evaluate if this object is still valid and usable as a fall-back value.
  /// If [maxStale] has not been called this will be null.
  @JsonKey(name: "max_stale_date")
  int? maxStaleDate;

  /// Byte array with the content received by API
  List<int>? content;

  /// Int representing the Status Code received by API. See [HttpStatus].
  int? statusCode;

  /// Byte array with the headers received by API
  List<int>? headers;

  CacheObj._(
      this.key, this.subKey, this.content, this.statusCode, this.headers);

  factory CacheObj(String key, List<int> content,
      {String? subKey = "",
      Duration? maxAge,
      Duration? maxStale,
      int? statusCode = 200,
      List<int>? headers}) {
    return CacheObj._(key, subKey, content, statusCode, headers)
      ..maxAge = maxAge
      ..maxStale = maxStale;
  }

  /// Set this object's [maxAgeDate]. If [duration] is null
  /// [maxAgeDate] will be null
  set maxAge(Duration? duration) {
    if (duration != null) {
      this.maxAgeDate = _convertDuration(duration);
    }
  }

  /// Set this object's [maxStaleDate]. If [duration] is null
  /// [maxStaleDate] will be null
  set maxStale(Duration? duration) {
    if (duration != null) {
      this.maxStaleDate = _convertDuration(duration);
    }
  }

  _convertDuration(Duration duration) =>
      DateTime.now().add(duration).millisecondsSinceEpoch;

  factory CacheObj.fromJson(Map<String, dynamic> json) =>
      _$CacheObjFromJson(json);

  toJson() => _$CacheObjToJson(this);
}
