
import 'package:gttp/features/courses/data/models/course_asset_url.dart';

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

    return EventModel(
      id: getString(['id', 'event_id', 'eventId']),
      title: getString(['title', 'name', 'event_name', 'heading']),
      description: getString(['description', 'details', 'summary', 'about']),
      imageUrl: CourseAssetUrl.resolve(getString([
        'image_url', 'image', 'thumbnail_url', 'banner_url', 
        'cover_image', 'cover_image_url', 'thumbnail', 
        'course_image', 'featured_image', 'picture', 'photo'
      ])),
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
