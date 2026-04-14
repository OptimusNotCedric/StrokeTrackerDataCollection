import 'package:open_wearable/apps/stroke_tracker/model/study_step.dart';

class StudyProtocol {
  late String participantId;
  late String sessionId;
  bool isEnglish = false;

  void addParticipantId(String id){
    participantId  = id;
  }

  void addSessionId(String id) {
    sessionId = id;
  }

  String t(String en, String de) => isEnglish ? en : de;

  List<StudyStep> getSteps() => [
  StudyStep(
    type: StudyStepType.instruction,
    heading: t("Smiling", "Lächeln"),
    description: t(
      "During the recording let the patient smile",
      "Während der Aufnahme soll der Patient lächeln"
    ),
  ),
  StudyStep(
    type: StudyStepType.cameraMeasurement,
    repetitions: 3,
  ),
  StudyStep(
    type: StudyStepType.instruction,
    heading: t("Turn Head", "Kopf drehen"),
    description: t(
      "During the recording turn your head",
      "Während der Aufnahme den Kopf drehen"
    ),
  ),
  StudyStep(
    type: StudyStepType.measuringHead,
    measuringInstructions: [
      t(
        "Instruct the patient to start with the head in a neutral position, then turn it to the right, back to neutral, and then to the left, and back to neutral.",
        "Den Patienten anweisen, den Kopf zunächst in die neutrale Position zu bringen, dann nach rechts zu drehen, zurück zur Neutralstellung und anschließend nach links und zurück zur Neutralstellung"
      ),
      t(
        "Instruct the patient to start with the head in a neutral position, then turn it to the left, back to neutral, and then to the right, and back to neutral.",
        "Den Patienten anweisen, den Kopf zunächst in die neutrale Position zu bringen, dann nach links zu drehen, zurück zur Neutralstellung und anschließend nach rechts und zurück zur Neutralstellung."
      ),
    ],
    repetitions: 3,
  ),
  StudyStep(
    type: StudyStepType.instruction,
    heading: t("Tap Earables", "Earables antippen"),
    description: t(
      "During the recording tap twice one earable with the opposing arm twice",
      "Während der Aufnahme ein Earable mit dem gegenüberliegenden Arm zweimal antippen"
    ),
  ),
  StudyStep(
    type: StudyStepType.measuringTap,
    measuringInstructions: [
      t(
        "Instruct the patient to tap the right Earable with the left Hand twice",
        "Den Patienten anweisen, das rechte Earable mit der linken Hand zweimal anzutippen"
      ),
    ],
    playSound: true,
    soundside: Side.right,
    repetitions: 1,
  ),
  StudyStep(
    type: StudyStepType.measuringTap,
    measuringInstructions: [
      t(
        "Instruct the patient to tap the left Earable with the right Hand twice",
        "Den Patienten anweisen, das linke Earable mit der rechten Hand zweimal anzutippen"
      ),
    ],
    playSound: true,
    soundside: Side.left,
    repetitions: 1,
  ),
    StudyStep(
    type: StudyStepType.measuringTap,
    measuringInstructions: [
      t(
        "Instruct the patient to tap the right Earable with the left Hand twice",
        "Den Patienten anweisen, das rechte Earable mit der linken Hand zweimal anzutippen"
      ),
    ],
    playSound: true,
    soundside: Side.right,
    repetitions: 1,
  ),
  StudyStep(
    type: StudyStepType.measuringTap,
    measuringInstructions: [
      t(
        "Instruct the patient to tap the left Earable with the right Hand twice",
        "Den Patienten anweisen, das linke Earable mit der rechten Hand zweimal anzutippen"
      ),
    ],
    playSound: true,
    soundside: Side.left,
    repetitions: 1,
  ),StudyStep(
    type: StudyStepType.measuringTap,
    measuringInstructions: [
      t(
        "Instruct the patient to tap the right Earable with the left Hand",
        "Den Patienten anweisen, das rechte Earable mit der linken Hand zweimal anzutippen"
      ),
    ],
    playSound: true,
    soundside: Side.right,
    repetitions: 1,
  ),
  StudyStep(
    type: StudyStepType.measuringTap,
    measuringInstructions: [
      t(
        "Instruct the patient to tap the left Earable with the right Hand twice",
        "Den Patienten anweisen, das linke Earable mit der rechten Hand zweimal anzutippen"
      ),
    ],
    playSound: true,
    soundside: Side.left,
    repetitions: 1,
  ),
  
    StudyStep(type: StudyStepType.ending),
    ];
}
