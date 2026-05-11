import 'package:flutter_dotenv/flutter_dotenv.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String? eventDate;
  final String? eventTime;
  final String? location;
  final String status; // upcoming, ongoing, past

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.eventDate,
    this.eventTime,
    this.location,
    this.status = 'upcoming',
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    String? tryString(dynamic value) {
      if (value == null) return null;
      return value.toString().trim();
    }

    String getString(List<String> keys) {
      for (final key in keys) {
        final value = _getValueByPath(json, key);
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString().trim();
        }
      }
      return '';
    }

    String? processImageUrl(dynamic value) {
      if (value == null) return null;

      String? url;
      if (value is List && value.isNotEmpty) {
        url = value.first?.toString().trim();
      } else if (value is String) {
        String stringValue = value.trim();
        if (stringValue.startsWith('[') && stringValue.endsWith(']')) {
          stringValue = stringValue.replaceAll('[', '').replaceAll(']', '').replaceAll('"', '').replaceAll('\\', '').trim();
          final parts = stringValue.split(',');
          if (parts.isNotEmpty && parts.first.isNotEmpty) {
            url = parts.first.trim();
          }
        } else {
          url = stringValue;
        }
      } else {
        url = value.toString().trim();
      }

      if (url == null || url.isEmpty) return null;
      if (url.startsWith('http://') || url.startsWith('https://')) return url;
      final baseUrl = dotenv.env['API_BASE_URL']?.replaceAll('/api', '') ?? 'https://gttp.efsouls.com';
      final normalizedPath = url.startsWith('/')
          ? url.substring(1)
          : url;
      final storageAwarePath = normalizedPath.startsWith('storage/')
          ? normalizedPath
          : 'storage/$normalizedPath';
      return '$baseUrl/$storageAwarePath';
    }

    return EventModel(
      id: getString(['id', 'event_id', 'eventId']),
      title: getString(['title', 'name', 'event_name', 'heading']),
      description: getString(['description', 'details', 'summary', 'about']),
      imageUrl: processImageUrl(json['image_url'] ?? json['image'] ?? json['thumbnail_url'] ?? json['banner_url']),
      eventDate: tryString(json['event_date'] ?? json['date'] ?? json['start_date']),
      eventTime: tryString(json['event_time'] ?? json['time'] ?? json['start_time']),
      location: tryString(json['location'] ?? json['venue'] ?? json['address']),
      status: getString(['status', 'state']).toLowerCase().isNotEmpty 
          ? getString(['status', 'state']).toLowerCase() 
          : 'upcoming',
    );
  }

  static dynamic _getValueByPath(Map<String, dynamic> json, String path) {
    if (!path.contains('.')) return json[path];
    
    dynamic current = json;
    for (final part in path.split('.')) {
      if (current is Map<String, dynamic> && current.containsKey(part)) {
        current = current[part];
      } else {
        return null;
      }
    }
    return current;
  }
}
