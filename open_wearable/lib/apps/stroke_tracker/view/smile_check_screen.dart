import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:open_wearable/apps/stroke_tracker/controller/logger.dart';

import 'package:path_provider/path_provider.dart';


class MeasuringScreen extends StatefulWidget {
  
  final VoidCallback onNext;
  final VoidCallback startMeasuring;
  final VoidCallback stopMeasuring;

  final ExperimentLogger logger;
  final String recordingId;

  const MeasuringScreen({
    super.key,
    required this.onNext,
    required this.startMeasuring,
    required this.stopMeasuring,

    required this.logger,
    required this.recordingId,
  });

  @override
  State<MeasuringScreen> createState() => _MeasuringScreenState();
}

class _MeasuringScreenState extends State<MeasuringScreen> {
  late int _remaining;
  int _currentCount = 0;
  Timer? _timer;
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;

  bool recording = false;

  @override
  void initState() {
    super.initState();
    _currentCount = 0;
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
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
      recording =true;
    });

    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      debugPrint("Kamera nicht bereit für Aufnahme.");
      return;
    }

    try {
      await _cameraController!.startVideoRecording();

      widget.logger.logOtherEvent(
        _currentCount,
        "Record the Smiling of the patient",
        "Smiling Task",
        "Video_Record_Start",
      );

      debugPrint("Videoaufnahme gestartet.");
    } catch (e) {
      debugPrint("Fehler beim Starten der Videoaufnahme: $e");
    }
  }

  Future<void> _stopVideoRecording() async {
    setState(() {
      recording = false;
    });
    if (_cameraController == null ||
        !_cameraController!.value.isRecordingVideo) {
      return;
    }

    try {
      final XFile videoFile = await _cameraController!.stopVideoRecording();

      widget.logger.logOtherEvent(
        _currentCount,
        "Smiling task",
        "Smiling task",
        "Video_Record_Stop",
      );

      final directory = await getApplicationDocumentsDirectory();
      final String savePath =
          '${directory.path}/${widget.recordingId}_video.mp4';

      await videoFile.saveTo(savePath);
      debugPrint("Videoaufnahme gestoppt und gespeichert unter: $savePath");
    } catch (e) {
      debugPrint("Fehler beim Stoppen der Videoaufnahme: $e");
    }
  }

  @override
  void dispose() {
    _stopVideoRecording();
    _timer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String timerText;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
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
            ]
      ));
  }
}