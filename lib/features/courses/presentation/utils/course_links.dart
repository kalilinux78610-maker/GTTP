import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openCourseUrl(BuildContext context, String? url, {String? errorMessage}) async {
  if (url == null || url.isEmpty) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage ?? 'Link not available.')),
      );
    }
    return;
  }

  final uri = Uri.tryParse(url);
  if (uri == null) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid link from server.')),
      );
    }
    return;
  }

  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!launched && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open link.')),
    );
  }
}
