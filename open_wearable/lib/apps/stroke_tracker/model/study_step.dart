//to distinguishe different screens during the study

enum StudyStepType { instruction, measuring, cameraMeasurement, labeling}

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
  });
}