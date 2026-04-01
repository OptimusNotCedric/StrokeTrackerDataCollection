import 'package:face_detection_tflite/face_detection_tflite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:open_earable_flutter/open_earable_flutter.dart';
import 'package:open_wearable/apps/stroke_tracker/controller/logger.dart';
import 'package:open_wearable/apps/stroke_tracker/controller/manager.dart';
import 'package:open_wearable/apps/stroke_tracker/model/config.dart';
import 'package:open_wearable/apps/stroke_tracker/model/study_protocol.dart';
import 'package:open_wearable/apps/stroke_tracker/model/study_step.dart';
import 'package:open_wearable/apps/stroke_tracker/view/end_page.dart';
import 'package:open_wearable/apps/stroke_tracker/view/instruction_screen.dart';
import 'package:open_wearable/apps/stroke_tracker/view/measuring_page.dart';
import 'package:open_wearable/apps/stroke_tracker/view/repetition_screen.dart';
import 'package:open_wearable/apps/stroke_tracker/view/smile_check_screen.dart';
import 'package:open_wearable/apps/stroke_tracker/view/study_selector.dart';

import 'package:open_wearable/view_models/sensor_configuration_provider.dart';





class StudyRunner extends StatefulWidget {
  final StudyProtocol protocol;
  final ExperimentLogger logger;
  final OpenEarableV2 leftWearable;
  final OpenEarableV2 rightWearable;
  final SensorConfigurationProvider leftConfigProvider;
  final SensorConfigurationProvider rightConfigProvider;

  const StudyRunner({
    super.key,
    required this.protocol,
    required this.logger,
    required this.leftWearable,
    required this.rightWearable,
    required this.leftConfigProvider,
    required this.rightConfigProvider,
  });

  @override
  State<StudyRunner> createState() => _StudyRunnerState();
}

class _StudyRunnerState extends State<StudyRunner> {
  late final List<StudyStep> _steps;
  int _currentIndex = 0;
  
  int _repetitionCounter = 1;
  late final FaceDetectorIsolate _faceDetectorIsolate;
  /// Zählt echte Mess-Schritte (1,2,3...)

  late final ExperimentManager _manager;
  late final ExperimentLogger _logger;
  late final ExperimentConfig _expConfig;

  late final Future<void> _loadingFuture;

  @override
  void initState() {
    super.initState();
    _loadConfigureFaceDetector();
    _steps = widget.protocol.getSteps();
    _logger = ExperimentLogger();
    _loadingFuture = _loadConfigAndInitManager();
  }

  //takes 100-500ms
  Future<void> _loadConfigureFaceDetector() async {
    try {
      _faceDetectorIsolate = await FaceDetectorIsolate.spawn(
        model: FaceDetectionModel.backCamera,
        performanceConfig: PerformanceConfig.auto(),
        meshPoolSize: 1,
      );
      
    } catch (_) {}
    setState(() {});
  }
  

  Future<void> _loadConfigAndInitManager() async {
    final sensorConfigs = [
      SensorConfig(sensor: "imu", sampleRate: 50),
      SensorConfig(sensor: "pressure", sampleRate: 50),
      SensorConfig(sensor: "microphone", sampleRate: 48000),
      //SensorConfig(sensor: "ppg", sampleRate: 50),
      SensorConfig(sensor: "bone_conduction", sampleRate: 1600),
      //SensorConfig(sensor: "temperature", sampleRate: 8),
    ];

    _expConfig = ExperimentConfig(globalSensorConfigs: sensorConfigs); 

    _manager = ExperimentManager(
      logger: _logger,
      expConfig: _expConfig,
      leftWearable: widget.leftWearable,
      leftSensorCfgProvider: widget.leftConfigProvider,
      rightWearable: widget.rightWearable,
      rightSensorCfgProvider: widget.rightConfigProvider,
    );
  }



  Future<void> _startMeasuring() async {
    //await _manager.deactivateSensors(); // <-- wichtig
    final step = _steps[_currentIndex];
    // final date = DateTime.now().toIso8601String().replaceAll(':', '-');
    final recordingId = 
        "${widget.protocol.sessionId.replaceAll(':', '-')}_rep_${_repetitionCounter}_Step_${_currentIndex}_";

    await _logger.startLogging(false, widget.protocol.sessionId);
    _logger.logTaskStart(_currentIndex, step.heading);

    print("startSensorLogFilePrefix");
    await _manager.setSensorLogFilePrefix(recordingId);
    print("startConfigureSensors");
    await _manager.configureSensors();
    print("Sensoren gestartet");
  }

  Future<void> _stopAndConfirm() async {
    await _manager.deactivateSensors();
  }

  Future<void> _saveAndAdvance() async {
    _stopAndConfirm();
    _logger.logTaskEnd();
    await _logger.stopAndWriteLogging(false);
    final currentStep = _steps[_currentIndex];
    final maxRepetitions = currentStep.repetitions;
    await Navigator.push(context, 
    MaterialPageRoute(
    builder: (context) => TaskScreen(
      maxRepetition: maxRepetitions, 
      currentRepetition: _repetitionCounter, 
      logger: _logger,
      onLeaveStudy: _leaveStudy,
      currentStepNumber: _currentIndex,
      currentStepTask: _steps[_currentIndex].heading,
      translate: widget.protocol.t,
      ),
      
    ),
    );
    setState(() {

      if (_repetitionCounter < maxRepetitions) {
        // weitere Wiederholung des gleichen Schritts
        print("repeat step");
        _repetitionCounter++;
      } else {
        _repetitionCounter = 1;
        
        _nextStep();
      }
    });
  }

  Future<void> _leaveStudy() async {
    print("leave_Study");
    await _manager.deactivateSensors();

      try {
        _logger.logTaskEnd();
        await _logger.stopAndWriteLogging(false);
      } catch (_) {}
    

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        platformPageRoute(
          context: context,
          builder: (_) => StudySelection(
            leftWearable: widget.leftWearable,
            rightWearable: widget.rightWearable,
            leftConfigProvider: widget.leftConfigProvider,
            rightConfigProvider: widget.rightConfigProvider,
          ),
        ),
        (route) => route.isFirst,
      );
    }
  }

  void _nextStep() {
    print("go to next Step");
    if (_currentIndex < _steps.length - 1) {
      setState(() => _currentIndex++);
    } else {
      _leaveStudy();
    }
  }


  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadingFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return PlatformScaffold(
            body: Center(child: PlatformCircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return PlatformScaffold(
            appBar: PlatformAppBar(title: Text("Fehler")),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("${snapshot.error}"),
              ),
            ),
          );
        }

        final step = _steps[_currentIndex];

        if (step.type == StudyStepType.instruction) {
          return InstructionScreen(
            heading: step.heading,
            description: step.description,
            onNext: _nextStep,
            onLeaveStudy: _leaveStudy,
            t: widget.protocol.t,
          );
        }

        if (step.type == StudyStepType.cameraMeasurement) {
          return CameraMeasuringScreen(
            currentRepetition: _repetitionCounter, 
            repetitions: step.repetitions, 
            onNext: _saveAndAdvance, 
            startMeasuring: _startMeasuring, 
            stopMeasuring: _stopAndConfirm, 
            logger: _logger,
            faceDetector: _faceDetectorIsolate,
            recordingId: widget.protocol.sessionId,
            t: widget.protocol.t,
            );
        }

        if (step.type == StudyStepType.ending) {
          return SummaryScreen(onLeaveStudy: _leaveStudy,);
        }

        if (step.type == StudyStepType.measuring) {
          return MeasuringScreen(
            repetitions: step.repetitions, 
            onNext: _saveAndAdvance, 
            startMeasuring: _startMeasuring, 
            stopMeasuring: _stopAndConfirm, 
            currentRepetition: _repetitionCounter, 
            logger: _logger, 
            recordingId: widget.protocol.sessionId, 
            taskName: step.heading, 
            instruction: step.measuringInstructions[step.instructionOrder[_repetitionCounter-1]],
            t: widget.protocol.t,
            );
        }
        return PlatformScaffold(
            appBar: PlatformAppBar(title: Text("Fehler")),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("${snapshot.error}"),
              ),
            ),
          );
        
      },
    );
  }

  @override
  void dispose() {
    _faceDetectorIsolate.dispose();
    super.dispose();
  }
}