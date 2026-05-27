import 'package:gttp/core/network/api_exception.dart';

/// Helpers for parsing GTTP API JSON envelopes (`success`, `data`, lists).
class ApiJsonParser {
  static Map<String, dynamic>? asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  static List<Map<String, dynamic>> extractList(Map<String, dynamic> response) {
    const priorityKeys = [
      'data',
      'items',
      'results',
      'records',
      'notices',
      'courses',
      'modules',
      'list',
      'rows',
    ];

    for (final key in priorityKeys) {
      final val = response[key];
      if (val is List) {
        return val
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
      if (val is Map) {
        final inner = val['data'];
        if (inner is List) {
          return inner
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        }
      }
    }

    for (final val in response.values) {
      if (val is List && val.isNotEmpty) {
        return val
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
    }

    return const [];
  }

  static Map<String, dynamic>? extractObject(Map<String, dynamic> response) {
    final data = response['data'];
    final map = asMap(data);
    if (map != null) return map;
    if (response.containsKey('id')) return response;
    return null;
  }

  static String asString(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  /// Throws when the API returns an error envelope (e.g. `{ "error": "...", "message": "..." }`).
  static void throwIfErrorResponse(Map<String, dynamic> response) {
    if (response['success'] == false) {
      throw ApiException(_errorMessage(response));
    }

    final error = asString(response['error']);
    final hasDataList = extractList(response).isNotEmpty;
    final hasDataObject = extractObject(response) != null;

    if (error.isNotEmpty && !hasDataList && !hasDataObject) {
      throw ApiException(_errorMessage(response));
    }
  }

  static String _errorMessage(Map<String, dynamic> response) {
    final message = asString(response['message']);
    final error = asString(response['error']);
    if (message.isNotEmpty) return message;
    if (error.isNotEmpty) return error;
    return 'Request failed.';
  }

  static bool asBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      final v = value.toLowerCase();
      return v == 'true' || v == '1' || v == 'yes';
    }
    return false;
  }

  static int asInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
