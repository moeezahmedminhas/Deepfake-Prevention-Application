import 'package:cached_network_image/cached_network_image.dart';
import 'package:deepfake_prevention_app/common/screens/show_network_image_screen.dart';
import 'package:flutter/material.dart';

import '../../../common/enums/message_enum.dart';
import '../../../common/screens/show_network_video_screen.dart';
import 'audio_player_widget.dart';
import 'video_player_item.dart';

class DisplayTextImage extends StatelessWidget {
  final String message;
  final MessageEnum type;
  final Color color;
  const DisplayTextImage(
      {super.key,
      required this.message,
      required this.type,
      required this.color});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return type == MessageEnum.text
        ? SelectableText.rich(
            TextSpan(
              children: [
                TextSpan(
                    text: message,
                    style:
                        TextStyle(color: color, fontSize: size.height * 0.016)),
              ],
            ),
          )
        : type == MessageEnum.audio
            ? AudioMessageWidget(audioUrl: message)
            : type == MessageEnum.video
                ? GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => NetworkVideoPlayerScreen(
                            videoUrl: message,
                          ),
                        ),
                      );
                    },
                    child: VideoPlayerItem(videoUrl: message))
                : SizedBox(
                    height: size.height * 0.2,
                    width: size.width * 0.8,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ShowNetworkImage(
                                imageUrl: message,
                              ),
                            ),
                          );
                        },
                        child: CachedNetworkImage(
                          imageUrl: message,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      ),
                    ),
                  );
  }
}
