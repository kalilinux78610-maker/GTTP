import 'dart:async';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
class CourseModuleVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final VoidCallback onVideoCompleted;

  const CourseModuleVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.onVideoCompleted,
  });

  @override
  State<CourseModuleVideoPlayer> createState() => _CourseModuleVideoPlayerState();
}

class _CourseModuleVideoPlayerState extends State<CourseModuleVideoPlayer> {
  YoutubePlayerController? _youtubeController;
  StreamSubscription? _youtubeStateSubscription;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;  
  bool _isYouTube = false;
  bool _hasTriggeredCompletion = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    if (videoId != null) {
      _isYouTube = true;
      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
        ),
      );
      
      _youtubeController!.addListener(() {
        if (_hasTriggeredCompletion || _youtubeController == null) return;
        
        final position = _youtubeController!.value.position;
        final duration = _youtubeController!.metadata.duration;
        
        if (duration.inSeconds > 0) {
          final percentage = position.inSeconds / duration.inSeconds;
          if (percentage >= 0.90) { // Trigger at 90%
            _hasTriggeredCompletion = true;
            widget.onVideoCompleted();
          }
        }
      });
      
      setState(() {
        _isInitialized = true;
      });
    } else {
      _isYouTube = false;
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
        ..initialize().then((_) {
          _chewieController = ChewieController(
            videoPlayerController: _videoPlayerController!,
            autoPlay: false,
            looping: false,
            aspectRatio: _videoPlayerController!.value.aspectRatio,
          );
          _videoPlayerController!.addListener(_videoListener);
          setState(() {
            _isInitialized = true;
          });
        });
    }
  }

  void _videoListener() {
    if (_hasTriggeredCompletion || _videoPlayerController == null) return;
    
    final position = _videoPlayerController!.value.position;
    final duration = _videoPlayerController!.value.duration;
    
    if (duration.inSeconds > 0) {
      final percentage = position.inSeconds / duration.inSeconds;
      if (percentage >= 0.90) { // Trigger at 90%
        _hasTriggeredCompletion = true;
        widget.onVideoCompleted();
      }
    }
  }

  @override
  void dispose() {
    _youtubeStateSubscription?.cancel();
    _youtubeController?.dispose();
    _videoPlayerController?.removeListener(_videoListener);
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: _isYouTube
          ? YoutubePlayer(
              controller: _youtubeController!,
            )
          : AspectRatio(
              aspectRatio: _videoPlayerController!.value.aspectRatio,
              child: Chewie(controller: _chewieController!),
            ),
    );
  }
}
