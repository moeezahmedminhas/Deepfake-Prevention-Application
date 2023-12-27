import 'dart:async';
import 'dart:io';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../common/enums/message_enum.dart';
import '../../../common/utils/colors.dart';
import '../../../common/utils/utils.dart';
import '../../../common/screens/show_file_video_screen.dart';
import '../controller/chat_controller.dart';

class BottomChatField extends ConsumerStatefulWidget {
  final String receiverUserId;

  const BottomChatField({super.key, required this.receiverUserId});

  @override
  ConsumerState<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends ConsumerState<BottomChatField> {
  bool voiceButton = true;
  bool isShowEmojiContainer = false;
  FocusNode focusNode = FocusNode();
  FlutterSoundRecorder? _soundRecorder;
  bool isRecorderInit = false;
  bool isRecording = false;
  Timer? _timer;
  Duration _recordingDuration = Duration.zero;
  final _messageController = TextEditingController();

  void startRecording() async {
    var tempDir = await getTemporaryDirectory();
    var path = '${tempDir.path}/flutter_sound.aac';
    if (!isRecorderInit) return;

    await _soundRecorder!.startRecorder(toFile: path);
    _startTimer();

    setState(() {
      isRecording = true;
    });
  }

  void stopRecording() async {
    if (!isRecorderInit) return;

    await _soundRecorder!.stopRecorder();
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }

    var tempDir = await getTemporaryDirectory();
    var path = '${tempDir.path}/flutter_sound.aac';
    sendFileMessage(File(path), MessageEnum.audio);

    setState(() {
      isRecording = false;
      _recordingDuration = Duration.zero;
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingDuration = Duration(seconds: timer.tick);
      });
    });
  }

  void openAudio() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Mic permission not allowed!');
    }
    await _soundRecorder!.openRecorder();
    isRecorderInit = true;
  }

  void sendTextMessage() async {
    if (!voiceButton) {
      String trimmedText = _messageController.text.trim();

      if (trimmedText.isNotEmpty) {
        ref.read(chatControllerProvider).sendTextMessage(
              context,
              trimmedText,
              widget.receiverUserId,
            );
        setState(() {
          _messageController.text = '';
          voiceButton = true;
        });
      }
    } else {
      if (isRecording) {
        stopRecording();
      } else {
        startRecording();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _soundRecorder = FlutterSoundRecorder();
    openAudio();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        hideEmojiContainer();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _messageController.dispose();
    _soundRecorder!.closeRecorder();
    isRecorderInit = false;
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
  }

  void sendFileMessage(File file, MessageEnum messageEnum) {
    ref
        .read(chatControllerProvider)
        .sendFileMessage(context, file, widget.receiverUserId, messageEnum);
  }

  void selectImage() async {
    File? image = await pickImageFromGallery(context);
    if (image == null) return;
    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Scaffold(
              appBar: AppBar(
                foregroundColor: primaryTextColor,
                elevation: 0,
                title: Text(
                  "Image",
                  style: textStyle.copyWith(color: primaryTextColor),
                ),
                backgroundColor: primaryColor,
                actions: [
                  IconButton(
                    onPressed: () {
                      // Send the file message and close the BottomSheet
                      sendFileMessage(image, MessageEnum.image);
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.done),
                  ),
                ],
              ),
              body: Center(
                child: Image.file(image),
              ),
            );
          },
        );
      },
    );
  }

  void selectVideo() async {
    File? video = await pickVideoFromGallery(context);
    if (video == null) return;
    if (!context.mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(
          videoFile: video,
          recieverUserId: widget.receiverUserId,
        ),
      ),
    );
  }

  void hideEmojiContainer() {
    setState(() {
      isShowEmojiContainer = false;
    });
  }

  void showEmojiContainer() {
    setState(() {
      isShowEmojiContainer = true;
    });
  }

  void showKeyboard() => focusNode.requestFocus();
  void hideKeyboard() => focusNode.unfocus();

  void toggleEmojiKeyboardContainer() {
    if (focusNode.hasFocus) {
      hideEmojiContainer();
    } else {
      showKeyboard();
    }
    if (isShowEmojiContainer) {
      hideEmojiContainer();
    } else {
      hideKeyboard();
      showEmojiContainer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(
              bottom: isLandscape ? size.height * 0.005 : size.height * 0.01),
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          // height: size.height * 0.07,
          // width: double.infinity,
          child: Row(
            children: [
              SizedBox(
                width: size.width * 0.01,
              ),
              IconButton(
                onPressed: () {
                  toggleEmojiKeyboardContainer();
                },
                icon: Icon(
                  size: size.width * 0.07,
                  Icons.emoji_emotions,
                  color: primaryColor,
                ),
              ),
              Expanded(
                child: TextFormField(
                  minLines: 1,
                  maxLines: 4,
                  focusNode: focusNode,
                  controller: _messageController,
                  onChanged: (val) {
                    if (val.isEmpty) {
                      setState(() {
                        voiceButton = true;
                      });
                    } else {
                      setState(() {
                        voiceButton = false;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    enabled: !isRecording,
                    filled: true,
                    fillColor: secondaryColor,
                    suffixIcon: !isRecording
                        ? IconButton(
                            onPressed: () {
                              selectImage();
                            },
                            icon: const Icon(
                              Icons.camera_alt,
                              color: Colors.grey,
                            ),
                          )
                        : const SizedBox(),
                    hintText: !isRecording
                        ? 'Type a message!'
                        : formatDuration(_recordingDuration),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: const BorderSide(
                        width: 0,
                        style: BorderStyle.none,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(10),
                  ),
                ),
              ),
              !isRecording
                  ? IconButton(
                      onPressed: () {
                        selectVideo();
                      },
                      icon: const Icon(
                        Icons.attach_file,
                        color: primaryColor,
                      ),
                    )
                  : const SizedBox(),
              Padding(
                padding: EdgeInsets.all(size.width * 0.02),
                child: CircleAvatar(
                  backgroundColor: primaryColor,
                  radius: 25,
                  child: GestureDetector(
                    onTap: sendTextMessage,
                    child: Icon(
                      voiceButton
                          ? isRecording
                              ? Icons.close
                              : Icons.mic
                          : Icons.send,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        isShowEmojiContainer
            ? SizedBox(
                height: isLandscape
                    ? size.height * 0.2
                    : size.height * 0.35, // Adjust emoji container height
                child: EmojiPicker(
                  onEmojiSelected: ((category, emoji) {
                    setState(() {
                      _messageController.text =
                          _messageController.text + emoji.emoji;
                    });

                    if (!voiceButton) {
                      setState(() {
                        voiceButton = true;
                      });
                    }
                    if (voiceButton &&
                        _messageController.text.trim().isNotEmpty) {
                      setState(() {
                        voiceButton = false;
                      });
                    }
                  }),
                ),
              )
            : const SizedBox(),
      ],
    );
  }
}
