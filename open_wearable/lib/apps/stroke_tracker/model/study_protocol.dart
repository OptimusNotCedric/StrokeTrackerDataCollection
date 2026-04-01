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
    type: StudyStepType.measuring,
    measuringInstructions: [
      t(
        "Instruct the patient to turn the head from right to left",
        "Den Patienten anweisen, den Kopf von rechts nach links zu drehen"
      ),
      t(
        "Instruct the patient to turn the head from left to right",
        "Den Patienten anweisen, den Kopf von links nach rechts zu drehen"
      ),
    ],
    repetitions: 3,
  ),
  StudyStep(
    type: StudyStepType.instruction,
    heading: t("Tap Earables", "Earables antippen"),
    description: t(
      "During the recording tap one earable with the opposing arm",
      "Während der Aufnahme ein Earable mit dem gegenüberliegenden Arm antippen"
    ),
  ),
  StudyStep(
    type: StudyStepType.measuring,
    measuringInstructions: [
      t(
        "Instruct the patient to tap the right Earable with the left Hand",
        "Den Patienten anweisen, das rechte Earable mit der linken Hand zu berühren"
      ),
    ],
    repetitions: 1,
  ),
  StudyStep(
    type: StudyStepType.measuring,
    measuringInstructions: [
      t(
        "Instruct the patient to tap the left Earable with the right Hand",
        "Den Patienten anweisen, das linke Earable mit der rechten Hand zu berühren"
      ),
    ],
    repetitions: 1,
  ),
    StudyStep(
    type: StudyStepType.measuring,
    measuringInstructions: [
      t(
        "Instruct the patient to tap the right Earable with the left Hand",
        "Den Patienten anweisen, das rechte Earable mit der linken Hand zu berühren"
      ),
    ],
    repetitions: 1,
  ),
  StudyStep(
    type: StudyStepType.measuring,
    measuringInstructions: [
      t(
        "Instruct the patient to tap the left Earable with the right Hand",
        "Den Patienten anweisen, das linke Earable mit der rechten Hand zu berühren"
      ),
    ],
    repetitions: 1,
  ),StudyStep(
    type: StudyStepType.measuring,
    measuringInstructions: [
      t(
        "Instruct the patient to tap the right Earable with the left Hand",
        "Den Patienten anweisen, das rechte Earable mit der linken Hand zu berühren"
      ),
    ],
    repetitions: 1,
  ),
  StudyStep(
    type: StudyStepType.measuring,
    measuringInstructions: [
      t(
        "Instruct the patient to tap the left Earable with the right Hand",
        "Den Patienten anweisen, das linke Earable mit der rechten Hand zu berühren"
      ),
    ],
    repetitions: 1,
  ),
    StudyStep(type: StudyStepType.ending),
    ];
}
