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
          label: Text("Somewhat likely presen"),
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
            _likertWidget,
            if (score >= 4) _buildSideSelector(),
            ElevatedButton(
              onPressed: pressExitButton,
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
              label: Text("Right"),
              icon: Icon(Icons.arrow_right),
            ),
          ],
          selected: selectedSide != null ? {selectedSide!} : <Side>{},
          onSelectionChanged: (Set<Side> newSelection) {
            setState(() {
              selectedSide = newSelection.first;
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