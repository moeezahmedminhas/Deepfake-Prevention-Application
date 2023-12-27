import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../../../common/utils/colors.dart';
import '../../../common/utils/utils.dart';
import 'processed_image_screen.dart';

class VideoPreventionScreen extends StatefulWidget {
  const VideoPreventionScreen({super.key});
  static const routeName = 'image-processing';

  @override
  VideoPreventionScreenState createState() => VideoPreventionScreenState();
}

class VideoPreventionScreenState extends State<VideoPreventionScreen> {
  File? _selectedMedia;
  String? _processedMediaId;
  String? _errorMessage;
  bool _processingMedia = false;
  http.Client _client = http.Client();
  final watermarkController = TextEditingController();
  final _key = GlobalKey<FormState>();
  String _selectedUrl = 'http://localhost:8000/process_media/';
  VideoPlayerController? _videoController;

  Future<void> _pickMedia() async {
    final pickedMedia =
        await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickedMedia != null) {
      setState(() {
        _selectedMedia = File(pickedMedia.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize the video player controller
    if (_selectedMedia != null) {
      _videoController = VideoPlayerController.file(_selectedMedia!)
        ..initialize().then((_) {
          setState(() {}); // when your controller is initialized.
        });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _client.close();

    _videoController?.dispose(); // Dispose the controller
  }

  Future<void> _sendMediaToApi() async {
    if (_selectedMedia == null) return;
    setState(() {
      _processingMedia = true;
    });
    if (_selectedUrl != urlVideos[0]) {
      if (!_key.currentState!.validate()) {
        return;
      }
    }
    try {
      _client = http.Client();
      var request = http.MultipartRequest('POST', Uri.parse(_selectedUrl));

      if (watermarkController.text.isNotEmpty) {
        request.headers['watermark'] = watermarkController.text;
      }

      request.files
          .add(await http.MultipartFile.fromPath('file', _selectedMedia!.path));
      var response = await _client.send(request);
      var responseBody = await http.Response.fromStream(response);
      var decodedJson = jsonDecode(responseBody.body);
      _processedMediaId = null;
      if (response.statusCode == 200) {
        if (_selectedUrl == urlVideos[2]) {
          var watermarkMessage = decodedJson['watermark'];
          setState(() {
            _processingMedia = false;
            _errorMessage = null;
            _processedMediaId = watermarkMessage; // Display watermark message
          });
        } else {
          var watermarkMessage = decodedJson['watermark'];
          var imageId = decodedJson['image_id'];
          setState(() {
            _processingMedia = false;
            _errorMessage = null;
            _processedMediaId = null; // Clear the processed image URL
          });
          _processedMediaId = imageId;
          // Make a GET request to download the processed image
          if (_processedMediaId != null) {
            if (context.mounted) {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ProcessedImageScreen(
                  imageId: _processedMediaId!,
                  watermarkMsg: watermarkMessage,
                ),
              ));
            }
          }
        }
      } else if (response.statusCode == 400) {
        setState(() {
          _processingMedia = false;
          _errorMessage = decodedJson['error'];
        });
      } else {
        setState(() {
          _processingMedia = false;
          _errorMessage =
              'Error processing Media as it is not encoded yet. Status Code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _processingMedia = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _cancelRequest() {
    _client.close();
    setState(() {
      _processingMedia = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Prevention'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(size.width * 0.03),
            child: Container(
              decoration: BoxDecoration(
                  // border: Border.all(color: Colors.black26, width: 3),
                  borderRadius: BorderRadius.circular(15)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _selectedMedia == null && _processedMediaId == null
                      ? Icon(
                          Icons.image,
                          size: size.height * 0.3,
                          color: primaryColor,
                        )
                      : _videoPlayerWidget(size),
                  SizedBox(
                    height: size.height * 0.01,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_processingMedia == false) ...[
                        DropdownButton<String>(
                          borderRadius: BorderRadius.circular(10),
                          elevation: 30,
                          underline: const SizedBox(),
                          value: _selectedUrl,
                          onChanged: (val) {
                            setState(() {
                              _selectedUrl = val!;
                              _processedMediaId = null;
                            });
                          },
                          items: urlVideos.map((url) {
                            String displayText;
                            if (url == urlVideos[0]) {
                              displayText = 'Encode Watermarks';
                            } else if (url == urlVideos[1]) {
                              displayText = 'Decode Watermarks';
                            } else {
                              displayText = 'Detect Deepfake';
                            }
                            return DropdownMenuItem<String>(
                              value: url,
                              child: Text(displayText),
                            );
                          }).toList(),
                        ),
                        if (!_processingMedia) ...[
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: _pickMedia,
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: secondaryColor),
                                child: Text(_selectedMedia != null
                                    ? "Pick Another File"
                                    : "Pick Media"),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ],
                  ),
                  SizedBox(height: size.height * 0.01),
                  // Dropdown menu for selecting the URL
                  _selectedUrl != urlVideos[0]
                      ? Padding(
                          padding: EdgeInsets.all(size.width * 0.045),
                          child: Form(
                            key: _key,
                            child: TextFormField(
                              controller: watermarkController,
                              decoration: fieldStyle.copyWith(
                                  hintText: "Enter Watermark"),
                              validator: (value) {
                                if (value == null) {
                                  return "enter valid decoding key";
                                }
                                return null;
                              },
                            ),
                          ),
                        )
                      : const SizedBox(),

                  if (_selectedMedia != null && !_processingMedia) ...[
                    Container(
                      margin: EdgeInsets.all(size.width * 0.03),
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _sendMediaToApi,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: secondaryColor),
                        child: const Text("Process Image"),
                      ),
                    ),
                  ],

                  if (_processingMedia) ...[
                    SizedBox(height: size.height * 0.03),
                    Text(
                      "It can take 5 minutes to embed watermarks",
                      style: textStyle.copyWith(
                          fontSize: size.height * 0.02,
                          color: const Color.fromARGB(255, 110, 109, 109)),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: size.height * 0.03),
                    const CircularProgressIndicator(
                      color: primaryColor,
                    ),
                    SizedBox(height: size.height * 0.03),
                    ElevatedButton(
                      onPressed: _cancelRequest,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: secondaryColor),
                      child: const Text("Cancel"),
                    ),
                  ],
                  SizedBox(height: size.height * 0.04),
                  if (_selectedMedia != null && !_processingMedia) ...[
                    _selectedUrl == urlImages[2]
                        ? _processedMediaId == null
                            ? const SizedBox()
                            : Padding(
                                padding: EdgeInsets.only(
                                    bottom: size.height * 0.036),
                                child: Text(
                                  _processedMediaId!,
                                  style: textStyle,
                                ),
                              )
                        : const SizedBox(),
                    SizedBox(height: size.height * 0.036),
                  ],
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Error: $_errorMessage',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _videoPlayerWidget(Size size) {
    return _videoController != null && _videoController!.value.isInitialized
        ? AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: VideoPlayer(_videoController!),
          )
        : SizedBox(
            height: size.height * 0.25,
            child: const Center(child: CircularProgressIndicator()),
          );
  }

  String determineMediaType(String path) {
    // Logic to determine if the selected media is a video or an image
    // For simplicity, this example checks file extension
    return path.endsWith('.mp4') ? 'video' : 'image';
  }
}
