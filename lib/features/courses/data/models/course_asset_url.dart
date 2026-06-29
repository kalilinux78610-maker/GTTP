import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gttp/core/network/api_json_parser.dart';

/// Resolves relative GTTP storage paths and absolute URLs from API JSON.
class CourseAssetUrl {
  CourseAssetUrl._();

  /// Site origin for storage assets (no `/api` suffix).
  static String get assetOrigin => _assetOrigin();

  static String? resolve(dynamic value) {
    if (value == null) return null;

    final raw = _normalizeRaw(value);
    if (raw == null || raw.isEmpty) return null;

    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return _sanitizeAbsoluteUrl(raw);
    }

    final origin = _assetOrigin();
    var path = raw.startsWith('/') ? raw.substring(1) : raw;

    // API sometimes returns `public/storage/...` or `api/storage/...`.
    if (path.startsWith('public/')) {
      path = path.substring('public/'.length);
    }
    if (path.startsWith('api/storage/')) {
      path = path.substring('api/'.length);
    }

    final storageAwarePath = path.startsWith('storage/')
        ? path
        : 'storage/$path';

    final base = origin.endsWith('/') ? origin.substring(0, origin.length - 1) : origin;
    final segment =
        storageAwarePath.startsWith('/') ? storageAwarePath.substring(1) : storageAwarePath;
    return '$base/$segment';
  }

  static String? _normalizeRaw(dynamic value) {
    if (value is List && value.isNotEmpty) {
      return _normalizeRaw(value.first);
    }

    var text = ApiJsonParser.asString(value);
    if (text.isEmpty) return null;
    
    // Fix JSON escaped slashes like "\/"
    text = text.replaceAll(r'\', '');

    // Handle JSON-ish array strings: ["https://..."] or [url1, url2]
    if (text.startsWith('[') && text.endsWith(']')) {
      final inner = text
          .substring(1, text.length - 1)
          .replaceAll('"', '')
          .replaceAll("'", '')
          .trim();
      if (inner.contains(',')) {
        text = inner.split(',').first.trim();
      } else {
        text = inner;
      }
    }

    return text.trim();
  }

  static String _sanitizeAbsoluteUrl(String url) {
    var cleaned = url.replaceAll(r'\', '').trim();
    // Fix accidental double storage segment in full URLs.
    cleaned = cleaned.replaceAll('/storage/storage/', '/storage/');
    final uri = Uri.tryParse(cleaned);
    if (uri == null) return cleaned;
    return uri.toString();
  }

  static String _assetOrigin() {
    final raw = dotenv.env['API_BASE_URL']?.trim();
    if (raw == null || raw.isEmpty) {
      return 'https://gttp.efsouls.com';
    }
    final withoutApi = raw.replaceAll(RegExp(r'/api/?$'), '');
    final uri = Uri.tryParse(withoutApi);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      return 'https://gttp.efsouls.com';
    }
    return uri.origin;
  }
}
