import 'package:open_wearable/apps/stroke_tracker/model/study_step.dart';

class StudyProtocol {
  late String participantId;
  late String sessionId;
  bool isEnglish = false;

  void addParticipantId(String id) {
    participantId = id;
  }

  void addSessionId(String id) {
    sessionId = "${participantId}_$id".replaceAll(':', '-');
  }



  String t(String en, String de) => isEnglish ? en : de;

  int stepsTotal () {
    int total = 0;
    for (StudyStep step in getSteps()) {
      if (step.type != StudyStepType.instruction){
        total = total + step.repetitions;
      }
    }
    return total;
  }
  List<StudyStep> getSteps() => [
  StudyStep(
    type: StudyStepType.instruction,
    heading: t("Smiling", "Lächeln"),
  ),
  StudyStep(
    type: StudyStepType.cameraMeasurement,
    repetitions: 15,
    description:  t(
   "1. Position the camera so that the participant's face is centered within the green frame.\n"
    "2. Start the recording.\n"
    "3. Read aloud: \"Please look into the camera and smile, showing your teeth.\"\n"
    "4. After the participant has smiled for at least 3 seconds, read aloud: \"You may stop smiling now.\"\n"
    "5. Stop the recording.",
   "1. Positionieren Sie die Kamera so, dass das Gesicht des Probanden im grünen Rahmen liegt.\n"
   "2. Starten Sie die Aufnahme\n"
   "3. Lesen Sie vor: \"Schauen Sie in die Kamera und lächeln Sie mit sichtbaren Zähnen\"\n"
   "4. Nachdem der Proband mindestens 3 Sekunden gelächelt hat. Lesen Sie vor: \"Hören Sie bitte auf zu lächeln\"\n"
   "5. Stoppen Sie die Aufnahme."
),
  ),
  StudyStep(
    type: StudyStepType.instruction,
    heading: t("Turn Head", "Kopf drehen"),
    
  ),
  StudyStep(
    type: StudyStepType.measuringHead,
    measuringInstructions: [
      t(
        "1. Instruct the participant to bring their head to a neutral position and look straight ahead.\n"
      "2. Start the recording.\n"
      "3. Read aloud: \"Turn your head to the right and return to the center. Then turn your head to the left and return to the center.\"\n"
      "4. Ensure that the participant completes the full movement.\n"
      "5. Stop the recording.",
        "Lesen Sie vor: \"Bringen Sie Ihren Kopf in eine aufrechte Position und schauen Sie nach vorne.\"\n"
        "1. Starten Sie die Aufnahme.\n"
        "2. Lesen Sie vor: \"Drehen Sie Ihren Kopf nach rechts und zurück zur Mitte. Drehen Sie danach Ihren Kopf nach links und zurück zur Mitte.\"\n"
        "3. Vergewissern Sie sich, dass der Proband die Bewegung vollständig ausgeführt hat.\n"
        "4. Stoppen Sie die Aufnahme."
      ),
      t(
        "1. Instruct the participant to bring their head to a neutral position and look straight ahead.\n"
      "2. Start the recording.\n"
      "3. Read aloud: \"Turn your head to the left and return to the center. Then turn your head to the right and return to the center.\"\n"
      "4. Ensure that the participant completes the full movement.\n"
      "5. Stop the recording.",
        "Lesen Sie vor: \"Bringen Sie Ihren Kopf in eine aufrechte Position und schauen Sie nach vorne.\"\n"
        "1. Starten Sie die Aufnahme.\n"
        "2. Lesen Sie vor: \"Drehen Sie Ihren Kopf nach links und zurück zur Mitte. Drehen Sie danach Ihren Kopf nach rechts und zurück zur Mitte.\"\n"
        "3. Vergewissern Sie sich, dass der Proband die Bewegung vollständig ausgeführt hat.\n"
        "4. Stoppen Sie die Aufnahme."
      ),
    ],
    repetitions: 15,
  ),
  StudyStep(
    type: StudyStepType.instruction,
    heading: t("Tap Earables", "Earables antippen"),
  ),
  StudyStep(
    type: StudyStepType.measuringTap,
    measuringInstructions: [
      t(
        "1. Read aloud: \"Place your hands in front of you and keep your head still during the following task. You will hear a sound in one of the earbuds. Please use the opposite hand to double-tap that earbud.\"\n"
      "2. Start the recording.\n"
      "3. Wait until the participant has double-tapped the right Earable with their left hand.\n"
      "4. Stop the recording.",
        "Lesen Sie vor:\"Legen Sie ihre Hände vor Ihnen hin und bewegen Sie ihren Kopf in der folgenden Aufgabe nicht. Sie werden einen Ton auf einer Seite der Hörer hören, bitte tippen Sie mit Ihrer gegnüberliegendenden Hand zweimal kurz hintereinander auf diesen Hörer.\"\n"
        "1. Starten Sie die Aufnahme.\n"
        "2. Warten Sie, bis der Proband die Bewegung mit der linken Hand zum rechten Hörer ausgeführt hat.\n"
        "3. Stoppen Sie die Aufnahme."
      ),
      t(
        "1. Read aloud: \"Place your hands in front of you and keep your head still during the following task. You will hear a sound in one of the earbuds. Please use the opposite hand to double-tap that earbud.\"\n"
      "2. Start the recording.\n"
      "3. Wait until the participant has double-tapped the left Earable with their right hand.\n"
      "4. Stop the recording.",
        "Lesen Sie vor:\"Legen Sie ihre Hände vor Ihnen hin und bewegen Sie ihren Kopf in der folgenden Aufgabe nicht. Sie werden einen Ton auf einer Seite der Hörer hören, bitte tippen Sie mit Ihrer gegnüberliegendenden Hand zweimal kurz hintereinander auf diesen Hörer.\"\n"
        "1. Starten Sie die Aufnahme.\n"
        "2. Warten Sie, bis der Proband die Bewegung mit der rechten Hand zum linken Hörer ausgeführt hat.\n"
        "3. Stoppen Sie die Aufnahme."
      ),
    ],
    playSound: true,
    soundside: Side.right,
    repetitions: 30,
  ),
    StudyStep(type: StudyStepType.ending),
    ];
}
