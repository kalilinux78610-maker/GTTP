import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class MaterialViewerScreen extends StatefulWidget {
  final String url;
  final String title;

  const MaterialViewerScreen({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<MaterialViewerScreen> createState() => _MaterialViewerScreenState();
}

class _MaterialViewerScreenState extends State<MaterialViewerScreen> {
  bool _isLoading = true;
  String? _localPath;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _downloadFile();
  }

  bool get _isPdf => widget.url.toLowerCase().contains('.pdf');

  Future<void> _downloadFile() async {
    try {
      final dir = await getTemporaryDirectory();
      final extension = _isPdf ? '.pdf' : '.png'; // Default to png if not pdf
      final fileName = 'material_${DateTime.now().millisecondsSinceEpoch}$extension';
      final savePath = '${dir.path}/$fileName';

      await Dio().download(widget.url, savePath);

      if (mounted) {
        setState(() {
          _localPath = savePath;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _share() {
    if (_localPath != null) {
      SharePlus.instance.share(ShareParams(
        files: [XFile(_localPath!)],
        subject: widget.title,
      ));
    } else {
      SharePlus.instance.share(ShareParams(
        uri: Uri.parse(widget.url),
        subject: widget.title,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        actions: [
          if (!_isLoading && _errorMessage.isEmpty)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _share,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Error loading material: $_errorMessage',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final uri = Uri.tryParse(widget.url);
                  if (uri != null) {
                    launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                child: const Text('Open Externally'),
              ),
            ],
          ),
        ),
      );
    }

    if (_isPdf && _localPath != null) {
      return PDFView(
        filePath: _localPath,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageFling: true,
        pageSnap: true,
        defaultPage: 0,
        fitPolicy: FitPolicy.BOTH,
      );
    } else {
      // Image Viewer
      return InteractiveViewer(
        minScale: 1.0,
        maxScale: 4.0,
        child: Center(
          child: _localPath != null
              ? Image.file(File(_localPath!))
              : CachedNetworkImage(imageUrl: widget.url),
        ),
      );
    }
  }
}
