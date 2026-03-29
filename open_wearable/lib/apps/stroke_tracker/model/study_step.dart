//to distinguishe different screens during the study

import 'dart:math';

enum StudyStepType { instruction, measuring, cameraMeasurement, ending}

class StudyStep {
  final StudyStepType type;
  final String heading;
  final String pathToImage;
  final String description;
  final int repetitions;
  final List<String> measuringInstructions;
  final bool debugMode;
  final bool secondaryDescription;
  final String secondaryDescriptionString;
  late final List<int> instructionOrder;

  StudyStep({
    required this.type,
    this.heading = "",
    this.pathToImage = "",
    this.description = "",
    this.repetitions = 1,
    this.measuringInstructions = const [""],
    this.debugMode = false,
    this.secondaryDescription = false,
    this.secondaryDescriptionString = "",
    
  }){
    final random = Random(DateTime.now().second); // seed = timestamp

  instructionOrder = List.generate(repetitions, (_) {
    return 0 + random.nextInt(measuringInstructions.length);
  });
  }


}