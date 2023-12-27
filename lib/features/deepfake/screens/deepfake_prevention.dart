import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../../common/utils/colors.dart';
import '../../../common/utils/utils.dart';
import 'processed_image_screen.dart';

class DeepfakePreventionScreen extends StatefulWidget {
  const DeepfakePreventionScreen({super.key});
  static const routeName = 'image-processing';
  @override
  DeepfakePreventionScreenState createState() =>
      DeepfakePreventionScreenState();
}

class DeepfakePreventionScreenState extends State<DeepfakePreventionScreen> {
  File? _selectedImage;
  String? _processedImageId;
  String? _errorMessage;
  bool _processingImage = false;
  http.Client _client = http.Client();
  final watermarkController = TextEditingController();
  final _key = GlobalKey<FormState>();
  // String _selectedUrl = 'http://localhost:8000/process_image/';

  String _selectedUrl =
      'https://moeezminhas-deepfakeapp.hf.space/process_image/';

  Future<void> _pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _sendImageToApi() async {
    if (_selectedImage == null) return;
    setState(() {
      _processingImage = true;
    });
    if (_selectedUrl != urlImages[0]) {
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
          .add(await http.MultipartFile.fromPath('file', _selectedImage!.path));
      var response = await _client.send(request);
      var responseBody = await http.Response.fromStream(response);
      var decodedJson = jsonDecode(responseBody.body);
      _processedImageId = null;
      if (response.statusCode == 200) {
        if (_selectedUrl == urlImages[2]) {
          var watermarkMessage = decodedJson['watermark'];
          setState(() {
            _processingImage = false;
            _errorMessage = null;
            _processedImageId = watermarkMessage; // Display watermark message
          });
        } else {
          var watermarkMessage = decodedJson['watermark'];
          var imageId = decodedJson['image_id'];
          setState(() {
            _processingImage = false;
            _errorMessage = null;
            _processedImageId = null; // Clear the processed image URL
          });
          _processedImageId = imageId;
          // Make a GET request to download the processed image
          if (_processedImageId != null) {
            if (context.mounted) {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ProcessedImageScreen(
                  imageId: _processedImageId!,
                  watermarkMsg: watermarkMessage,
                ),
              ));
            }
          }
        }
      } else if (response.statusCode == 400) {
        setState(() {
          _processingImage = false;
          _errorMessage = decodedJson['error'];
        });
      } else {
        setState(() {
          _processingImage = false;
          _errorMessage =
              'Error processing image as it is not encoded yet. Status Code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _processingImage = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _cancelRequest() {
    _client.close();
    setState(() {
      _errorMessage = "";
      _processingImage = false;
    });
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Form(
      key: _key,
      child: Center(
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
                  _selectedImage == null && _processedImageId == null
                      ? Icon(
                          Icons.image,
                          size: size.height * 0.3,
                          color: primaryColor,
                        )
                      : ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                          child: Image.file(
                            _selectedImage!,
                            width: double.infinity,
                            height: size.height * 0.25,
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                  SizedBox(
                    height: size.height * 0.01,
                  ),

                  if (!_processingImage && _processingImage == false) ...[
                    Container(
                      margin: EdgeInsets.all(size.width * 0.03),
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _pickImage,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: secondaryColor),
                        child: Text(_selectedImage != null
                            ? "Pick Another Image"
                            : "Pick Image"),
                      ),
                    ),
                  ],
                  if (_processingImage == false) ...[
                    DropdownButton<String>(
                      borderRadius: BorderRadius.circular(10),
                      elevation: 30,
                      underline: const SizedBox(),
                      value: _selectedUrl,
                      onChanged: (val) {
                        setState(() {
                          _selectedUrl = val!;
                          _processedImageId = null;
                        });
                      },
                      items: urlImages.map((url) {
                        String displayText;
                        if (url == urlImages[0]) {
                          displayText = 'Encode Image';
                        } else if (url == urlImages[1]) {
                          displayText = 'Decode Image';
                        } else {
                          displayText = 'Detect Deepfake';
                        }
                        return DropdownMenuItem<String>(
                          value: url,
                          child: Text(displayText),
                        );
                      }).toList(),
                    ),
                    _selectedUrl != urlImages[0]
                        ? Padding(
                            padding: EdgeInsets.all(size.width * 0.045),
                            child: TextFormField(
                              controller: watermarkController,
                              decoration: fieldStyle.copyWith(
                                  hintText: "Enter Watermark"),
                              validator: (value) {
                                if (value == null || value == "") {
                                  return "enter valid decoding key";
                                }
                                return null;
                              },
                            ),
                          )
                        : const SizedBox(),
                  ],
                  SizedBox(height: size.height * 0.01),
                  // Dropdown menu for selecting the URL

                  if (_selectedImage != null && !_processingImage) ...[
                    Container(
                      margin: EdgeInsets.all(size.width * 0.03),
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _errorMessage = null;
                          });
                          if (_key.currentState!.validate() &&
                              _selectedUrl != urlImages[0]) {
                            _sendImageToApi();
                          } else if (_selectedUrl == urlImages[0]) {
                            _sendImageToApi();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("please enter waterwark")));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: secondaryColor),
                        child: const Text("Process Image"),
                      ),
                    ),
                  ],

                  if (_processingImage) ...[
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
                  if (_selectedImage != null && !_processingImage) ...[
                    _selectedUrl == urlImages[2]
                        ? _processedImageId == null
                            ? const SizedBox()
                            : Padding(
                                padding: EdgeInsets.only(
                                    bottom: size.height * 0.036),
                                child: Text(
                                  _processedImageId!,
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
                  // ElevatedButton(
                  //   onPressed: () {
                  //     // downloadImage(context,
                  //     //     "https://res.cloudinary.com/dxxdandwe/image/upload/v1702876185/lslcf0fwksbsrtpj6a9n.png");

                  //     Navigator.of(context)
                  //         .push(MaterialPageRoute(builder: (context) {
                  //       return const VideoPreventionScreen();
                  //     }));
                  //   },
                  //   style: ElevatedButton.styleFrom(
                  //       backgroundColor: primaryColor,
                  //       foregroundColor: secondaryColor),
                  //   child: const Text("Beta Feature"),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
