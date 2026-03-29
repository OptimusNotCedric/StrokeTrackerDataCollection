import 'package:flutter/material.dart';
import 'package:open_wearable/apps/stroke_tracker/controller/logger.dart';

import 'package:flutter/material.dart';

class LikertChoice extends StatefulWidget{
  final Function(int) onScoreChanged;
  final int initialScore;
  LikertChoice({super.key, required this.onScoreChanged, required this.initialScore});

  @override
  State<LikertChoice> createState() {
    return _LikertChoiceState();
  }
}

class _LikertChoiceState extends State<LikertChoice> {

  int score = 0;

  @override
  void initState() {
    super.initState();
    score = widget.initialScore;
  }

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<int>(
      segments: <ButtonSegment<int>>[
        ButtonSegment<int>(
          value: 1,
          label: Text("Likely absent"),
        ),
        ButtonSegment<int>(
          value: 2,
          label: Text("Somewhat likely absent"),
        ),
        ButtonSegment<int>(
          value: 3,
          label: Text("Indeterminate"),
        ),
        ButtonSegment<int>(
          value: 4,
          label: Text("Somewhat likely present"),
        ),
        ButtonSegment<int>(
          value: 5,
          label: Text("Likely present"),
        ),
      ],
      selected: <int>{score},
      onSelectionChanged: (Set<int> newSelection) {
        setState(() {
          score = newSelection.first;
        });
        widget.onScoreChanged(newSelection.first);
      },
      showSelectedIcon: false,
    );
  }
}

enum Side {
  left,
  right,
}

class TaskScreen extends StatefulWidget{
  final int currentRepetition;
  final int maxRepetition;
  final int currentStepNumber;
  final String currentStepTask;
  final ExperimentLogger logger;

  const TaskScreen({
    super.key,
    required this.maxRepetition,
    required this.currentRepetition,
    required this.logger,
    required this.currentStepNumber,
    required this.currentStepTask,
  });

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  late Widget _likertWidget;
  int score = 0;
  Side? selectedSide;
  bool wrongSelection = false;

  @override
  void initState() {
    super.initState();
    _likertWidget = _buildLikertScale();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
    child: Scaffold(
      appBar: AppBar(
        title: const Text("Repetition Task"),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Repetition ${widget.currentRepetition} of ${widget.maxRepetition}",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "Please rate the pathology severity on a scale from 1 (no impairment) to 5 (severe impairment).",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 30),
            _likertWidget,
            if (score >= 4) _buildSideSelector(),
            if (!canGoNext())
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  "Please complete all required selections",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: canGoNext() ? pressExitButton : null,
              child: Text(
                widget.currentRepetition < widget.maxRepetition
                    ? "Start/Repeat Task"
                    : "Done",
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildLikertScale(){

    return LikertChoice(onScoreChanged: onScoreChanged, initialScore: 0);
  }

  void onScoreChanged(int newScore) {
    setState(() {
      score = newScore;
    });
  }

  

  bool canGoNext() {
    return score > 0 ? (score >= 4 ? (selectedSide != null? true :false) : true) : false;
  }

  Widget _buildSideSelector() {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text(
          "Which side is the impairment (From perspective of the patient)?",
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 10),

        SegmentedButton<Side>(
          segments: const <ButtonSegment<Side>>[
            ButtonSegment(
              value: Side.left,
              label: Text("Left"),
              icon: Icon(Icons.arrow_left),
            ),
            ButtonSegment(
              value: Side.right,
              label: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text("Right"),
                SizedBox(width: 4),
                Icon(Icons.arrow_right),
              ],
            ),
            ),
          ],
          selected: selectedSide != null ? {selectedSide!} : <Side>{},
          multiSelectionEnabled: false,
          emptySelectionAllowed: true, 
          onSelectionChanged: (Set<Side> newSelection) {
            setState(() {
              selectedSide = newSelection.isNotEmpty ? newSelection.first : null;
            });
          },
        ),
      ],
    );
  }

  void pressExitButton(){
    widget.logger.logOtherEvent(widget.currentRepetition, "Evaluation", widget.currentStepTask, score.toString());
    if(selectedSide != null && score >= 4) {
      widget.logger.logOtherEvent(widget.currentRepetition, "Side of impairment", widget.currentStepTask, selectedSide.toString().split(".").last);
    }
    Navigator.of(context).pop();
  }

}