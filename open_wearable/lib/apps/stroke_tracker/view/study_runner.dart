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
import 'package:open_wearable/apps/stroke_tracker/view/repetition_screen.dart';
import 'package:open_wearable/apps/stroke_tracker/view/smile_check_screen.dart';
import 'package:open_wearable/apps/stroke_tracker/view/study_selector.dart';

import 'package:open_wearable/view_models/sensor_configuration_provider.dart';





class StudyRunner extends StatefulWidget {
  final StudyProtocol protocol;
  final ExperimentLogger logger;
  final Wearable leftWearable;
  final Wearable rightWearable;
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

  /// Zählt echte Mess-Schritte (1,2,3...)

  late final ExperimentManager _manager;
  late final ExperimentLogger _logger;
  late final ExperimentConfig _expConfig;

  late final Future<void> _loadingFuture;

  @override
  void initState() {
    super.initState();
    _steps = widget.protocol.getSteps();
    _logger = ExperimentLogger();
    _loadingFuture = _loadConfigAndInitManager();
  }

  Future<void> _loadConfigAndInitManager() async {
    final sensorConfigs = [
      SensorConfig(sensor: "imu", sampleRate: 50),
      SensorConfig(sensor: "pressure", sampleRate: 50),
      SensorConfig(sensor: "microphone", sampleRate: 48000),
      SensorConfig(sensor: "ppg", sampleRate: 50),
      SensorConfig(sensor: "bone_conduction", sampleRate: 1600),
      SensorConfig(sensor: "temperature", sampleRate: 8),
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
    final date = DateTime.now().toIso8601String().replaceAll(':', '-');
    final filename = "$_repetitionCounter";

    final recordingId =
        "${widget.protocol.sessionId}_step${filename}_${step.heading.replaceAll(" ", "")}_$date";


    await _logger.startLogging(recordingId, false);
    _logger.logTaskStart(_currentIndex, step.heading);

    await _manager.setSensorLogFilePrefix(recordingId);
    await _manager.configureSensors();
    await _logger.sensorsReady;

    print("Sensoren gestartet");
  }

  Future<void> _stopAndConfirm() async {
    await _manager.deactivateSensors();
  }

  Future<void> _saveAndAdvance() async {
    _stopAndConfirm();
    _logger.logTaskEnd();
    await _logger.stopAndWriteLogging(false);

    print("-----------------------------------------------------------$_currentIndex---------------------------------------------");
    final currentStep = _steps[_currentIndex];
    final maxRepetitions = currentStep.repetitions;
    
    await Navigator.push(context, 
    MaterialPageRoute(
    builder: (context) => TaskScreen(
      maxRepetition: maxRepetitions, 
      currentRepetition: _repetitionCounter, 
      logger: _logger, 
      currentStepNumber: _currentIndex,
      currentStepTask: _steps[_currentIndex].heading,),
    ),);
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

  Future<void> _leaveStudy(bool needToSave) async {
    print("leave_Study");
    await _manager.deactivateSensors();

    if (needToSave) {
      try {
        _logger.logTaskEnd();
        await _logger.stopAndWriteLogging(false);
      } catch (_) {}
    }

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
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => SummaryScreen()));
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
            onLeaveStudy: () => _leaveStudy(false),
          );
        }

        if (step.type == StudyStepType.cameraMeasurement) {
          return MeasuringScreen(currentRepetition: _repetitionCounter, repetitions: _repetitionCounter, onNext: _saveAndAdvance, startMeasuring: _startMeasuring, stopMeasuring: _stopAndConfirm, logger: _logger, recordingId: widget.protocol.sessionId);
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
}