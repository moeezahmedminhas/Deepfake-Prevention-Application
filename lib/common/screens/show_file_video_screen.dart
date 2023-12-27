import 'dart:io';
import 'package:deepfake_prevention_app/common/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../enums/message_enum.dart';
import '../../features/chat/controller/chat_controller.dart';

class VideoPlayerScreen extends ConsumerStatefulWidget {
  final File videoFile;
  final String recieverUserId;

  const VideoPlayerScreen(
      {super.key, required this.videoFile, required this.recieverUserId});

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  void sendFileMessage(File file, MessageEnum messageEnum) {
    ref
        .read(chatControllerProvider)
        .sendFileMessage(context, file, widget.recieverUserId, messageEnum);

    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.videoFile)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
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
      appBar: AppBar(
        title: const Text('Video'),
        actions: [
          GestureDetector(
            onTap: () {
              sendFileMessage(widget.videoFile, MessageEnum.video);
            },
            child: const Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Done"),
                ],
              ),
            ),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : const Loader(),
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
    );
  }
}
