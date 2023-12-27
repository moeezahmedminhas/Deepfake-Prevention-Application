import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../../common/utils/colors.dart';

class AudioMessageWidget extends StatefulWidget {
  final String audioUrl;

  const AudioMessageWidget({super.key, required this.audioUrl});

  @override
  AudioMessageWidgetState createState() => AudioMessageWidgetState();
}

class AudioMessageWidgetState extends State<AudioMessageWidget> {
  late AudioPlayer audioPlayer;
  bool isPlaying = false;
  double currentPosition = 0.0;
  Duration duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();

    audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        isPlaying = false;
        currentPosition = 0.0;
      });
    });

    audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });
    audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() {
        // Ensure currentPosition does not exceed the duration
        currentPosition = newPosition.inMilliseconds
            .toDouble()
            .clamp(0.0, duration.inMilliseconds.toDouble());
      });
    });
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  void _playPauseAudio() async {
    if (isPlaying) {
      await audioPlayer.pause();
    } else {
      await audioPlayer.play(UrlSource(widget.audioUrl));
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  void _seek(double value) {
    final position = Duration(milliseconds: value.round());
    audioPlayer.seek(position);
  }

  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size;
    return Column(
      children: [
        Slider(
          value: currentPosition,
          activeColor: accentColor,
          inactiveColor: primaryTextColor,
          max: duration.inMilliseconds.toDouble(),
          onChanged: (value) {
            setState(() {
              currentPosition = value;
            });
            _seek(value);
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: _playPauseAudio,
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: primaryTextColor,
              ),
            ),
            Text(
              "${formatDuration(Duration(milliseconds: currentPosition.round()))} / ${formatDuration(duration)}",
              style: const TextStyle(color: primaryTextColor),
            ),
          ],
        ),
      ],
    );
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}
