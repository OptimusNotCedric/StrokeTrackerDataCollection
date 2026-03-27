import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:open_wearable/apps/stroke_tracker/controller/logger.dart';
import 'package:face_detection_tflite/face_detection_tflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import 'package:share_plus/share_plus.dart';

class MeasuringScreen extends StatefulWidget {
  final int repetitions;
  final int currentRepetition;
  final VoidCallback onNext;  
  final VoidCallback startMeasuring;
  final VoidCallback stopMeasuring;
  final FaceDetectorIsolate faceDetector;
  final ExperimentLogger logger;
  final String recordingId;

  const MeasuringScreen({
    super.key,
    required this.repetitions,
    required this.onNext,
    required this.startMeasuring,
    required this.stopMeasuring,
    required this.currentRepetition,
    required this.faceDetector,
    required this.logger,
    required this.recordingId,
  });

  @override
  State<MeasuringScreen> createState() => _MeasuringScreenState();
}

class _MeasuringScreenState extends State<MeasuringScreen> {
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;
  bool debugimagesaved = false;
  bool recording = false;
  List<(DateTime, Face)> faceBuffer = [];

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final backCamera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      _initializeControllerFuture = _cameraController!.initialize();

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Kamera konnte nicht initialisiert werden: $e");
    }
  }

  Future<void> _startVideoRecording() async {
    setState(() {
      recording = true;
    });
    DateTime lastLoggedTime = DateTime.now().subtract(Duration(seconds: 1));
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      debugPrint("Kamera nicht bereit für Aufnahme.");
      return;
    }
    widget.startMeasuring();
    bool isProcessing = false;
    try {
      await _cameraController!.startImageStream(
        (CameraImage image) async{
          final now = DateTime.now();
          if (now.difference(lastLoggedTime).inMilliseconds <= 500) {
            return;
          }
          lastLoggedTime = now;
          final cv.Mat? mat = await _convertCameraImageToMat(image);
          if (mat != null ) {
            List<Face> faces = await widget.faceDetector.detectFacesFromMat(mat, mode: FaceDetectionMode.standard);
            if (faces.isNotEmpty) {
              Face face = faces.first;
              faceBuffer.add((now, face));
              /*
              if (!debugimagesaved) {
              _saveDebugMeshImage(mat.clone(), faces.first);
              debugimagesaved = true;
              }
              */
            }
            
            mat.dispose();
            
          } else {
            print("no Image for face recognition");
          }
          

        });
      
      
      widget.logger.logOtherEvent(
        widget.repetitions,
        "Start Record of smilingpatient",
        "Smiling Task",
        "Video_Record_Start",
      );

      debugPrint("Videoaufnahme gestartet.");
    } catch (e) {
      debugPrint("Fehler beim Starten der Videoaufnahme: $e");
    }
  }

  Future<void> _saveDebugMeshImage(cv.Mat mat, Face face) async {
    try {
      final box = face.boundingBox;

      // Draw bounding box

      FaceMesh? landmarks = face.mesh;
      if (landmarks == null) return;

      for (int i = 0; i < landmarks.length; i++) {
        final p = landmarks[i];

        final x = p.x.toInt();
        final y = p.y.toInt();

        // Draw point
        cv.circle(
          mat,
          cv.Point(x, y),
          2,
          cv.Scalar(0, 0, 255), // red
        );

        // Draw index number
        cv.putText(
          mat,
          '$i',
          cv.Point(x + 2, y + 2),
          cv.FONT_HERSHEY_SIMPLEX,
          0.3,
          cv.Scalar(255, 0, 0), // blue text
        );
      }

      // Save image
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/mesh_debug_${DateTime.now().millisecondsSinceEpoch}.png';
      
      cv.imwrite(path, mat);
      
      // Share the file
      
      final params = ShareParams(files: [XFile(path)], text: "debugImage");
      await SharePlus.instance.share(params);
      print("Saved debug image: $path");
    } catch (e) {
      print("Error saving debug image: $e");
    }
  }

  Future<void> _stopVideoRecording() async {
    if (!recording) {
      return;
    }
    setState(() {
      recording = false;
    });

    
    if (_cameraController == null) {
      return;
    }

    try {
      await _cameraController!.stopImageStream();

      widget.logger.logOtherEvent(
        widget.repetitions,
        "Stop Record of smiling patient",
        "Smiling task",
        "Video_Record_Stop",
      );
    } catch (e) {
      debugPrint("Fehler beim Stoppen der Videoaufnahme: $e");
    }
    await flushBuffer();
    finishTask();
  }

  void finishTask(){
    widget.onNext();
  }

  @override
  void dispose() {
    if (_cameraController?.value.isStreamingImages ?? false) {
      _cameraController!.stopImageStream();
    }
  
    _cameraController?.dispose();
    super.dispose();
  }

  /// Converts CameraImage to cv.Mat (BGR) for OpenCV processing.
  ///
  /// Handles multiple pixel formats:
  /// - iOS NV12 (2 planes): YUV420 with interleaved UV
  /// - Android I420 (3 planes): YUV420 with separate U/V planes
  /// - Desktop BGRA/RGBA (1 plane): camera_desktop provides packed 4-channel
  ///   (macOS = BGRA byte order, Linux = RGBA byte order)
  Future<cv.Mat?> _convertCameraImageToMat(CameraImage image) async {
    try {
      final int width = image.width;
      final int height = image.height;

      // Desktop: camera_desktop provides single-plane 4-channel packed format
      if (image.planes.length == 1 &&
          (image.planes[0].bytesPerPixel ?? 1) >= 4) {
        final bytes = image.planes[0].bytes;
        final stride = image.planes[0].bytesPerRow;

        // Create a 4-channel Mat directly from camera bytes (handles stride)
        final matCols = stride ~/ 4;
        final bgraOrRgba =
            cv.Mat.fromList(height, matCols, cv.MatType.CV_8UC4, bytes);

        // Crop out stride padding if present
        final cropped = matCols != width
            ? bgraOrRgba.region(cv.Rect(0, 0, width, height))
            : bgraOrRgba;

        // Native SIMD-accelerated color conversion
        final colorCode = cv.COLOR_RGBA2BGR;
        cv.Mat mat = cv.cvtColor(cropped, colorCode);

        if (!identical(cropped, bgraOrRgba)) cropped.dispose();
        bgraOrRgba.dispose();

        final rotationFlag =
            _rotationFlagForFrame(width: width, height: height);
        if (rotationFlag != null) {
          final rotated = cv.rotate(mat, rotationFlag);
          mat.dispose();
          return rotated;
        }
        return mat;
      }

      // Mobile: YUV420 format
      final int yRowStride = image.planes[0].bytesPerRow;
      final int yPixelStride = image.planes[0].bytesPerPixel ?? 1;

      // Allocate BGR buffer for OpenCV (3 bytes per pixel)
      final bgrBytes = Uint8List(width * height * 3);

      void writePixel(int x, int y, int yp, int up, int vp) {
        int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
        int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
            .round()
            .clamp(0, 255);
        int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
        final int bgrIdx = (y * width + x) * 3;
        bgrBytes[bgrIdx] = b;
        bgrBytes[bgrIdx + 1] = g;
        bgrBytes[bgrIdx + 2] = r;
      }

      if (image.planes.length == 2) {
        // iOS NV12 format
        final int uvRowStride = image.planes[1].bytesPerRow;
        final int uvPixelStride = image.planes[1].bytesPerPixel ?? 2;

        for (int y = 0; y < height; y++) {
          for (int x = 0; x < width; x++) {
            final int uvIndex =
                uvPixelStride * (x ~/ 2) + uvRowStride * (y ~/ 2);
            final int index = y * yRowStride + x * yPixelStride;
            writePixel(
                x,
                y,
                image.planes[0].bytes[index],
                image.planes[1].bytes[uvIndex],
                image.planes[1].bytes[uvIndex + 1]);
          }
        }
      } else if (image.planes.length >= 3) {
        // Android I420 format
        final int uvRowStride = image.planes[1].bytesPerRow;
        final int uvPixelStride = image.planes[1].bytesPerPixel ?? 1;

        for (int y = 0; y < height; y++) {
          for (int x = 0; x < width; x++) {
            final int uvIndex =
                uvPixelStride * (x ~/ 2) + uvRowStride * (y ~/ 2);
            final int index = y * yRowStride + x * yPixelStride;
            writePixel(x, y, image.planes[0].bytes[index],
                image.planes[1].bytes[uvIndex], image.planes[2].bytes[uvIndex]);
          }
        }
      } else {
        return null;
      }

      // Create cv.Mat from BGR bytes
      cv.Mat mat = cv.Mat.fromList(height, width, cv.MatType.CV_8UC3, bgrBytes);

      // Rotate image for portrait mode so face detector sees upright faces.
      final rotationFlag = _rotationFlagForFrame(width: width, height: height);
      if (rotationFlag != null) {
        final rotated = cv.rotate(mat, rotationFlag);
        mat.dispose();
        return rotated;
      }

      return mat;
    } catch (e) {
      return null;
    }
  }

  Future<void> flushBuffer() async {
    print("Flushing Buffer");
    print("${faceBuffer.length}");
    await ExperimentLogger.logFaceData(faceBuffer, widget.recordingId, widget.currentRepetition);
  }

  int? _rotationFlagForFrame({
    required int width,
    required int height,
  }) {
    final DeviceOrientation orientation = _effectiveDeviceOrientation(context);
    final bool isPortrait = orientation == DeviceOrientation.portraitUp ||
        orientation == DeviceOrientation.portraitDown;

    if (!isPortrait) return null;

    // If the incoming buffer is already portrait, don't rotate it.
    if (height >= width) return null;

    final int? sensor = _cameraController!.description.sensorOrientation;
    if (sensor == 90) {
      return cv.ROTATE_90_COUNTERCLOCKWISE;
    }
    if (sensor == 270) {
      return cv.ROTATE_90_CLOCKWISE;
    }

    return null;
  }
  
  DeviceOrientation _effectiveDeviceOrientation(BuildContext context) {
    final controller = _cameraController;
    if (controller != null) {
      return controller.value.deviceOrientation;
    }

    return MediaQuery.of(context).orientation == Orientation.portrait
        ? DeviceOrientation.portraitUp
        : DeviceOrientation.landscapeLeft;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
            children: [
              // Kamera
              Expanded(
                flex: 1,
                child: Container(
                  width: double.infinity,
                  color: Colors.black,
                  child: FutureBuilder<void>(
                    future: _initializeControllerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done &&
                          _cameraController != null &&
                          _cameraController!.value.isInitialized) {
                        return ClipRect(
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width:
                                  _cameraController!.value.previewSize!.height,
                              height:
                                  _cameraController!.value.previewSize!.width,
                              child: CameraPreview(_cameraController!),
                            ),
                          ),
                        );
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      }
                    },
                  ),
                ),
              ),
              Positioned(
                top: null,
                bottom: null,
                right: 16,
                height: MediaQuery.of(context).size.height,
                child: Center(
                  
                  child: SizedBox(
                  width: 80,
                  height: 60,
                  child: PlatformElevatedButton(onPressed:recording? _stopVideoRecording: _startVideoRecording, child: recording? Icon(Icons.pause, size: 36,): Icon(Icons.play_arrow, size: 36,),)
                ),),),
                        
            ]
      ));
  }
}