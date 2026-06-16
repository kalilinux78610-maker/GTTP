import 'dart:convert';
import 'package:gttp/features/courses/data/models/course_asset_url.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final List<String>? images; // Added to support multiple gallery images
  final String? eventDate;
  final String? eventTime;
  final String? location;
  final String status; // upcoming, ongoing, past

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.images,
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

    List<String>? parsedImages;
    final rawImages = json['image'] ?? json['event_images'] ?? json['eventImages'] ?? json['images'] ?? json['gallery'] ?? json['photos'];
    
    dynamic processImages = rawImages;
    if (rawImages is String && rawImages.trim().startsWith('[') && rawImages.trim().endsWith(']')) {
      try {
        processImages = jsonDecode(rawImages);
      } catch (_) {}
    }

    if (processImages is List) {
      parsedImages = processImages
          .map((e) => CourseAssetUrl.resolve(e.toString()))
          .whereType<String>()
          .toList();
    } else if (processImages is String && processImages.isNotEmpty) {
      // Sometimes it's a single string
      final resolved = CourseAssetUrl.resolve(processImages);
      if (resolved != null) {
        parsedImages = [resolved];
      }
    }

    // Determine imageUrl: if 'image' is a string, use it. If it's a list, use the first element.
    String? firstImage;
    if (parsedImages != null && parsedImages.isNotEmpty) {
      firstImage = parsedImages.first;
    }

    return EventModel(
      id: getString(['id', 'event_id', 'eventId']),
      title: getString(['title', 'name', 'event_name', 'heading']),
      description: getString(['description', 'details', 'summary', 'about']),
      imageUrl: firstImage ?? CourseAssetUrl.resolve(getString([
        'image_url', 'thumbnail_url', 'banner_url', 
        'cover_image', 'cover_image_url', 'thumbnail', 
        'course_image', 'featured_image', 'picture', 'photo'
      ])),
      images: parsedImages,
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'images': images,
      'eventDate': eventDate,
      'eventTime': eventTime,
      'location': location,
      'status': status,
    };
  }
}
