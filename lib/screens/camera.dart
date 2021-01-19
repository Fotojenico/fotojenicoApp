import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import 'package:fotojenico/globals.dart';
import 'package:fotojenico/navbar.dart';
import 'package:fotojenico/screens/send.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() {
    return _CameraScreenState();
  }
}

/// Returns a suitable camera icon for [direction].
IconData getCameraLensIcon(CameraLensDirection direction) {
  switch (direction) {
    case CameraLensDirection.back:
      return Icons.camera_rear;
    case CameraLensDirection.front:
      return Icons.camera_front;
    case CameraLensDirection.external:
      return Icons.camera;
  }
  throw ArgumentError('Unknown lens direction');
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  CameraController controller;
  String imagePath;
  String videoPath;
  VideoPlayerController videoController;
  VoidCallback videoPlayerListener;
  bool enableAudio = true;
  bool videoPreview = false;
  bool imagePreview = false;
  int selectedCameraId = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (controller != null) {
        onNewCameraSelected(controller.description);
      }
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: sentScreenToggle
          ? SendScreen()
          : Scaffold(
              key: _scaffoldKey,
              body: Stack(
                children: <Widget>[
                  Container(
                    child: Center(
                      child: _cameraPreviewWidget(),
                    ),
                  ),
                  Stack(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.topLeft,
                        child: _cameraSelectorWidget(),
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: _fileSelectorWidget(),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: _thumbnailWidget(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Visibility(
        visible: true,
        child: GestureDetector(
          onTap: () {
            onTakePictureButtonPressed();
          },
          onLongPressStart: (details) {
            onVideoRecordButtonPressed();
          },
          onLongPressEnd: (details) {
            onStopButtonPressed();
          },
          // ignore: missing_required_param
          child: FloatingActionButton(
            //tooltip: floatingActionTooltip,
            backgroundColor: Theme.of(context).backgroundColor,
            foregroundColor: Theme.of(context).primaryColor,
            child: Icon(
              Icons.camera,
              size: 50,
            ),
          ),
        ),
      ),
      bottomNavigationBar: navBar(context, 0),
    );
  }

  Widget _fileSelectorWidget() {
    return IconButton(
      icon: Icon(Icons.file_upload),
      color: Theme.of(context).backgroundColor,
      onPressed: () {
        filePicker();
      },
    );
  }

  void filePicker() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(type: FileType.media, allowMultiple: false);
    if (result != null) {
      File file = File(result.files.single.path);
      print(file);
    }
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      onNewCameraSelected(cameras[selectedCameraId]);
      return Container(child: Text("Loading"),);
    } else {
      if (imageToggle) {
        onTakePictureButtonPressed();
        setState(() {
          imageToggle = false;
        });
      }
      if (videoStartToggle) {
        onVideoRecordButtonPressed();
        setState(() {
          videoStartToggle = false;
        });
      }
      if (videoEndToggle) {
        onStopButtonPressed();
        setState(() {
          videoEndToggle = false;
        });
      }
      final size = MediaQuery.of(context).size;

      // calculate scale for aspect ratio widget
      var scale = 0.9 * controller.value.aspectRatio / size.aspectRatio;

      // check if adjustments are needed...
      if (controller.value.aspectRatio < size.aspectRatio) {
        scale = 1 / scale;
      }

      return Transform.scale(
        scale: scale,
        child: AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: CameraPreview(controller),
        ),
      );
    }
  }

  /// Display the thumbnail of the captured image or video.
  Widget _thumbnailWidget() {
    return videoController == null && imagePath == null
        ? Container()
        : GestureDetector(
            child: SizedBox(
              child: (videoController == null)
                  ? Image.file(File(imagePath))
                  : Container(
                      child: Center(
                        child: AspectRatio(
                            aspectRatio: videoController.value.size != null ? videoController.value.aspectRatio : 1.0,
                            child: VideoPlayer(videoController)),
                      ),
                      decoration: BoxDecoration(border: Border.all(color: Colors.pink)),
                    ),
              width: 128.0,
              height: 128.0,
            ),
            onTap: () {
              setState(() {
                if (videoController != null) {
                  sentVideo = videoPath;
                }
                if (imagePath != null) {
                  sentImage = imagePath;
                }
              });
              Navigator.pushNamed(context, '/send');
            },
          );
  }

  /// Display the control bar with buttons to take pictures and record videos.
  //Widget _captureControlRowWidget() {
  //  return Row(
  //    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //    mainAxisSize: MainAxisSize.max,
  //    children: <Widget>[
  //      IconButton(
  //        icon: const Icon(Icons.camera_alt),
  //        color: Colors.blue,
  //        onPressed: controller != null &&
  //                controller.value.isInitialized &&
  //                !controller.value.isRecordingVideo
  //            ? onTakePictureButtonPressed
  //            : null,
  //      ),
  //      IconButton(
  //        icon: const Icon(Icons.videocam),
  //        color: Colors.blue,
  //        onPressed: controller != null &&
  //                controller.value.isInitialized &&
  //                !controller.value.isRecordingVideo
  //            ? onVideoRecordButtonPressed
  //            : null,
  //      ),
  //      IconButton(
  //        icon: controller != null && controller.value.isRecordingPaused
  //            ? Icon(Icons.play_arrow)
  //            : Icon(Icons.pause),
  //        color: Colors.blue,
  //        onPressed: controller != null &&
  //                controller.value.isInitialized &&
  //                controller.value.isRecordingVideo
  //            ? (controller != null && controller.value.isRecordingPaused
  //                ? onResumeButtonPressed
  //                : onPauseButtonPressed)
  //            : null,
  //      ),
  //      IconButton(
  //        icon: const Icon(Icons.stop),
  //        color: Colors.red,
  //        onPressed: controller != null &&
  //                controller.value.isInitialized &&
  //                controller.value.isRecordingVideo
  //            ? onStopButtonPressed
  //            : null,
  //      )
  //    ],
  //  );
  //}

  /// Display a row of toggle to select the camera (or a message if no camera is available).
  Widget _cameraSelectorWidget() {
    final List<Widget> toggles = <Widget>[];

    if (cameras.isEmpty) {
      return const Text('No camera found');
    } else {
      for (CameraDescription cameraDescription in cameras) {
        toggles.add(
          SizedBox(
            width: 90.0,
            child: RadioListTile<CameraDescription>(
              title: Icon(
                getCameraLensIcon(cameraDescription.lensDirection),
                color: Colors.white.computeLuminance() > 0.5 ? Colors.black : Colors.white,
              ),
              groupValue: controller?.description,
              value: cameraDescription,
              selected: true,
              onChanged: controller != null && controller.value.isRecordingVideo ? null : onNewCameraSelected,
            ),
          ),
        );
      }
    }
    if (cameras.isEmpty) {
      return const Text('No camera found');
    } else {
      return IconButton(
        icon: Icon(
          getCameraLensIcon(cameras[selectedCameraId].lensDirection),
          color: Theme.of(context).backgroundColor,
        ),
        onPressed: () {
          if (selectedCameraId >= cameras.length - 1) {
            setState(() {
              selectedCameraId = 0;
            });
          } else {
            setState(() {
              selectedCameraId++;
            });
          }
          onNewCameraSelected(cameras[selectedCameraId]);
        },
      );
    }
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller?.dispose();
      setState(() {
        controller = null;
      });
    }
    setState(() {
      controller = new CameraController(
        cameraDescription,
        ResolutionPreset.ultraHigh,
      );
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
      print(controller);
    }
    // If the controller is updated then update the UI.
    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        showInSnackBar('Camera error ${controller.value.errorDescription}');
      }
    });

    if (mounted) {
      setState(() {});
    }
  }

  void onTakePictureButtonPressed() {
    takePicture().then((String filePath) {
      if (mounted) {
        setState(() {
          imagePath = filePath;
          videoController?.dispose();
          videoController = null;
        });
      }
    });
  }

  void onVideoRecordButtonPressed() {
    startVideoRecording().then((String filePath) {
      if (mounted) setState(() {});
      if (filePath != null) showInSnackBar('Saving video to $filePath');
    });
  }

  void onStopButtonPressed() {
    stopVideoRecording().then((_) {
      if (mounted) setState(() {});
      showInSnackBar('Video recorded to: $videoPath');
    });
  }

  void onPauseButtonPressed() {
    pauseVideoRecording().then((_) {
      if (mounted) setState(() {});
      showInSnackBar('Video recording paused');
    });
  }

  void onResumeButtonPressed() {
    resumeVideoRecording().then((_) {
      if (mounted) setState(() {});
      showInSnackBar('Video recording resumed');
    });
  }

  Future<String> startVideoRecording() async {
    if (!controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }

    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Movies/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.mp4';

    if (controller.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return null;
    }

    try {
      videoPath = filePath;
      await controller.startVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  Future<void> stopVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller.stopVideoRecording().then((file) => null);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }

    await _startVideoPlayer();
  }

  Future<void> pauseVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller.pauseVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> resumeVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller.resumeVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> _startVideoPlayer() async {
    final VideoPlayerController videoControllerInstance = VideoPlayerController.file(File(videoPath));
    videoPlayerListener = () {
      if (videoController != null && videoController.value.size != null) {
        // Refreshing the state to update video player with the correct ratio.
        if (mounted) setState(() {});
        videoController.removeListener(videoPlayerListener);
      }
    };
    videoControllerInstance.addListener(videoPlayerListener);
    await videoControllerInstance.setLooping(true);
    await videoControllerInstance.initialize();
    await videoController?.dispose();
    if (mounted) {
      setState(() {
        imagePath = null;
        videoController = videoControllerInstance;
      });
    }
    await videoControllerInstance.play();
  }

  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await Directory(dirPath).create(recursive: true);
    String filePath = '$dirPath/${timestamp()}.jpg';

    if (controller.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      await controller.takePicture().then((XFile file) {
        if (mounted) {
          setState(() {
            filePath = file.path;
            videoController?.dispose();
            videoController = null;
          });
          if (file != null) showInSnackBar('Picture saved to ${file.path}');
        }
      });
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }
}
