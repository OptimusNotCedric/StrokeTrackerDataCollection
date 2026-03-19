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

  List<StudyStep> getSteps() => [
    StudyStep(
      type: StudyStepType.instruction,
      heading: "Smiling",
      description: "During the recording smile"
      ),
    StudyStep(
      type: StudyStepType.cameraMeasurement,
      repetitions: 5,
    )
    

  ];
}
