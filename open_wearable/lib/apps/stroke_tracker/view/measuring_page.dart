import 'dart:async';
import 'package:flutter/material.dart';
import 'package:open_wearable/apps/stroke_tracker/controller/logger.dart';


class MeasuringScreen extends StatefulWidget {
  final int repetitions;
  final int currentRepetition;
  final Future<void> Function() onNext;  
  final Future<void> Function() startMeasuring;
  final Future<void> Function() stopMeasuring;
  final String Function(String en,String de) t;
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
    required this.t,
  });

  @override
  State<MeasuringScreen> createState() => _MeasuringScreenState();
}

class _MeasuringScreenState extends State<MeasuringScreen> {
  bool recording = false;
  late final String Function(String en,String de) t;
  int countdown = 10;
  Timer? _timer;
  bool isStarting = false;
  @override
  void initState() {
    super.initState();
    t = widget.t;
  }

  Future<void> _startRecording() async {
    
    if (isStarting) return;

  setState(() {
    isStarting = true;
  });
    
    await widget.startMeasuring();
    try {

      widget.logger.logOtherEvent(
        widget.repetitions,
        "Start Record of ${widget.taskName}",
        widget.instruction,
        "Recording_Start",
      );
      setState(() {
      recording = true;
      isStarting = false;
    });
      _startTimer();
      debugPrint("MEasurement gestartet.");
    } catch (e) {
      debugPrint("Fehler beim Starten der Measurement: $e");
    }
  }

    Future<bool?> _showSaveDialog() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(t("Save Measurement?", "Messung speichern?")),
          content: Text(
              t(
              "Do you want to save this measurement or repeat it?",
              "Möchten Sie diese Messung speichern oder wiederholen?"
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(t("Remeasure", "Wiederholen")),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);

              },
              child: Text(t("Save", "Speichern")),
            ),
          ],
        );
      },
    );
  }
  
  Future<void> _stopRecording() async {
    if (!recording) {
      return;
    }
    
    widget.stopMeasuring();
    setState(() {
      recording = false;
    });
    _timer?.cancel();
    

    try {
      widget.logger.logOtherEvent(
        widget.repetitions,
        "Stop Record of ${widget.taskName}",
        widget.instruction,
        "Recording_Stop",
      );
    } catch (e) {
      debugPrint("Fehler beim Stoppen der Videoaufnahme: $e");
    }
    final shouldSave = await _showSaveDialog();

    if (shouldSave == true) {
      
      await widget.onNext();
    } else {
      // discard data and reset
      setState(() {
        countdown = 10;
      });

      debugPrint("Measurement discarded. Ready to remeasure.");}
  }

  @override
  void dispose() {
    widget.stopMeasuring();
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
                            t("Examiner Instruction", "Anweisung für Untersucher"),
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
                            t(
                              "Look at the camera and follow the instruction",
                              "Schauen Sie in die Kamera und folgen Sie der Anweisung"
                            ),
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
                      t("Press start to begin", "Zum Starten drücken"),
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
                      recording ? t("Recording...", "Aufnahme läuft...") : t("Ready", "Bereit"),
                      style: TextStyle(
                        color: recording ? Colors.red : Colors.grey.shade700,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 12),

                    // Button
                    GestureDetector(
                      onTap: isStarting? null : (recording ? _stopRecording : _startRecording),
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
                      t(
                        "Repetition ${widget.currentRepetition} / ${widget.repetitions}",
                        "Wiederholung ${widget.currentRepetition} / ${widget.repetitions}"
                      ),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (isStarting)
                Container(
                  color: Colors.black.withOpacity(0.4),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 20),
                        Text(
                          t("Starting sensors...", "Sensoren werden gestartet..."),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),),
            ],
          ),
        ),
      ));
  }
}