import 'dart:async';
import 'package:flutter/material.dart';
import 'package:open_wearable/apps/stroke_tracker/controller/logger.dart';


class MeasuringScreen extends StatefulWidget {
  final int repetitions;
  final int currentRepetition;
  final VoidCallback onNext;  
  final VoidCallback startMeasuring;
  final VoidCallback stopMeasuring;
  final ExperimentLogger logger;
  final String recordingId;
  final String taskName;
  final String instruction;

  const MeasuringScreen({
    super.key,
    required this.repetitions,
    required this.onNext,
    required this.startMeasuring,
    required this.stopMeasuring,
    required this.currentRepetition,
    required this.logger,
    required this.recordingId,
    required this.taskName,
    required this.instruction,
  });

  @override
  State<MeasuringScreen> createState() => _MeasuringScreenState();
}

class _MeasuringScreenState extends State<MeasuringScreen> {
  bool recording = false;

  int countdown = 10;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _startRecording() async {
    setState(() {
      recording = true;
    });
    _startTimer();
    
    widget.startMeasuring();
    try {

      widget.logger.logOtherEvent(
        widget.repetitions,
        "Start Record of ${widget.taskName}",
        widget.taskName,
        "Recording_Start",
      );

      debugPrint("MEasurement gestartet.");
    } catch (e) {
      debugPrint("Fehler beim Starten der Measurement: $e");
    }
  }

  Future<void> _stopRecording() async {
    if (!recording) {
      return;
    }
    
    setState(() {
      recording = false;
    });
    _timer?.cancel();
    

    try {
      widget.logger.logOtherEvent(
        widget.repetitions,
        "Stop Record of ${widget.taskName}",
        widget.taskName,
        "Recording_Stop",
      );
    } catch (e) {
      debugPrint("Fehler beim Stoppen der Videoaufnahme: $e");
    }
    finishTask();
  }

  void finishTask(){
    widget.onNext();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    countdown = 10;

    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (countdown == 0) {
        timer.cancel();
        _stopRecording();
      } else {
        setState(() {
          countdown--;
        });
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // 🔹 Instruction Panel
              AnimatedOpacity(
                duration: Duration(milliseconds: 300),
                opacity: recording ? 0.5 : 1.0,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    elevation: 3,
                    color: Colors.grey.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            "Examiner Instruction",
                            style: TextStyle(
                              color: Colors.deepOrange,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            widget.instruction,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 16),
                          Divider(color: Colors.grey.shade300),
                          SizedBox(height: 12),
                          Text(
                            "Patient",
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Look at the camera and follow the instruction",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 🔹 CENTER: Countdown
              if (recording)
                Expanded(
                  child: Center(
                    child: Text(
                      "$countdown",
                      style: TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: Center(
                    child: Text(
                      "Press start to begin",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),

              // 🔹 Bottom Controls
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    // Status text
                    Text(
                      recording ? "Recording..." : "Ready",
                      style: TextStyle(
                        color: recording ? Colors.red : Colors.grey.shade700,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 12),

                    // Button
                    GestureDetector(
                      onTap: recording ? _stopRecording : _startRecording,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        width: recording ? 90 : 80,
                        height: recording ? 90 : 80,
                        decoration: BoxDecoration(
                          color: recording ? Colors.red : Colors.green,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            )
                          ],
                        ),
                        child: Icon(
                          recording ? Icons.stop : Icons.play_arrow,
                          size: 42,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    SizedBox(height: 16),

                    // Repetition indicator
                    Text(
                      "Repetition ${widget.currentRepetition} / ${widget.repetitions}",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ));
  }
}