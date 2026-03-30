import 'package:open_wearable/apps/stroke_tracker/model/study_step.dart';

class StudyProtocol {
  late String participantId;
  late String sessionId;

  void addParticipantId(String id){
    participantId  = id;
  }

  void addSessionId(String id) {
    sessionId = id;
  }

  List<StudyStep> getSteps() => 
     [
    StudyStep(
      type: StudyStepType.instruction,
      heading: "Smiling",
      description: "During the recording smile"
      ),
    StudyStep(
      type: StudyStepType.cameraMeasurement,
      repetitions: 3,
    ),
    StudyStep(
      type: StudyStepType.instruction,
      heading: "Turn Head",
      description: "During the recording turn your head"
      ),
    StudyStep(
      type: StudyStepType.measuring,
      measuringInstructions: ["Instruct the patient to turn the head from right to left", "Instruct the patient to turn the head from left to right"],
      repetitions: 3,
    ),
    StudyStep(
      type: StudyStepType.instruction,
      heading: "Tap Earables",
      description: "During the recording Tap both earables",
      ),
    StudyStep(
      type: StudyStepType.measuring,
      measuringInstructions: ["Instruct the patient to tap the right Earable with the left Hand"],
      repetitions: 1,
    ),
    StudyStep(
      type: StudyStepType.measuring,
      measuringInstructions: ["Instruct the patient to tap the left Earable with the right Hand"],
      repetitions: 1,
    ),
    StudyStep(
      type: StudyStepType.measuring,
      measuringInstructions: ["Instruct the patient to tap the right Earable with the left Hand"],
      repetitions: 1,
    ),StudyStep(
      type: StudyStepType.measuring,
      measuringInstructions: ["Instruct the patient to tap the left Earable with the right Hand"],
      repetitions: 1,
    ),StudyStep(
      type: StudyStepType.measuring,
      measuringInstructions: ["Instruct the patient to tap the right Earable with the left Hand"],
      repetitions: 1,
    ),StudyStep(
      type: StudyStepType.measuring,
      measuringInstructions: ["Instruct the patient to tap the left Earable with the right Hand"],
      repetitions: 1,
    ),
    StudyStep(type: StudyStepType.ending),
    ];
}
