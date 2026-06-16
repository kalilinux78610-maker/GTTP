import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:gttp/features/courses/data/models/course_asset_url.dart';

/// Course list / hero cover image with resolved storage URLs and web-friendly loading.
class CourseCoverImage extends StatelessWidget {
  final String? imageUrl;
  final double? height;
  final double? width;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Color placeholderColor;

  const CourseCoverImage({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.placeholderColor = const Color(0xFF398FDE),
  });

  @override
  Widget build(BuildContext context) {
    final resolved = CourseAssetUrl.resolve(imageUrl);

    Widget child;
    if (resolved == null || resolved.isEmpty) {
      child = placeholder ?? _defaultPlaceholder();
    } else {
      child = CachedNetworkImage(
        imageUrl: resolved,
        height: height,
        width: width,
        fit: fit,
        fadeInDuration: const Duration(milliseconds: 250),
        placeholder: (_, _) => placeholder ?? _loadingBox(),
        errorWidget: (context, url, error) {
          debugPrint('Image load error for $url: $error');
          return placeholder ?? _defaultPlaceholder();
        },
      );
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: child);
    }
    return child;
  }

  Widget _loadingBox() {
    return Container(
      height: height,
      width: width ?? double.infinity,
      color: placeholderColor.withValues(alpha: 0.15),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _defaultPlaceholder() {
    return Container(
      height: height,
      width: width ?? double.infinity,
      color: placeholderColor,
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, size: 48, color: Colors.white54),
    );
  }
}
