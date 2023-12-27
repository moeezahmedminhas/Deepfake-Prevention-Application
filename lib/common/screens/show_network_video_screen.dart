import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:deepfake_prevention_app/common/widgets/loader.dart';

class NetworkVideoPlayerScreen extends ConsumerStatefulWidget {
  final String videoUrl;

  const NetworkVideoPlayerScreen({super.key, required this.videoUrl});

  @override
  ConsumerState<NetworkVideoPlayerScreen> createState() =>
      _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<NetworkVideoPlayerScreen> {
  late VideoPlayerController _controller;
  late ValueNotifier<double> _sliderValueNotifier;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
    _sliderValueNotifier = ValueNotifier<double>(0.0);
    _controller.addListener(() {
      final bool isVideoEnded =
          _controller.value.position >= _controller.value.duration;

      if (_controller.value.isInitialized && !isVideoEnded) {
        _sliderValueNotifier.value =
            _controller.value.position.inSeconds.toDouble();
      } else if (isVideoEnded) {
        _resetSliderAndVideo();
      }
    });
  }

  void _resetSliderAndVideo() {
    setState(() {
      _sliderValueNotifier.value = 0.0;
      _controller.seekTo(Duration.zero);

      _controller.pause();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _sliderValueNotifier.dispose();
    super.dispose();
  }

  void _forwardVideo() {
    _controller
        .seekTo(_controller.value.position + const Duration(seconds: 10));
  }

  void _rewindVideo() {
    final currentPosition = _controller.value.position;
    if (currentPosition.inSeconds > 10) {
      _controller.seekTo(currentPosition - const Duration(seconds: 10));
    } else {
      _controller.seekTo(Duration.zero);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video')),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _controller.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  : const Loader(),
              ValueListenableBuilder<double>(
                valueListenable: _sliderValueNotifier,
                builder: (context, value, child) {
                  return Slider(
                    value: value,
                    min: 0.0,
                    max: _controller.value.duration.inSeconds.toDouble(),
                    onChanged: (newValue) {
                      _controller.seekTo(Duration(seconds: newValue.toInt()));
                    },
                  );
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.fast_rewind),
                    onPressed: _rewindVideo,
                  ),
                  IconButton(
                    icon: Icon(_controller.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow),
                    onPressed: () {
                      setState(() {
                        if (_controller.value.isPlaying) {
                          _controller.pause();
                        } else {
                          _controller.play();
                        }
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.fast_forward),
                    onPressed: _forwardVideo,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
