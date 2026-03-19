import 'package:flutter/material.dart';
import 'package:open_earable_flutter/open_earable_flutter.dart';
import 'package:open_wearable/apps/stroke_tracker/view/study_runner.dart';
import 'package:open_wearable/apps/stroke_tracker/view/study_selector.dart';
import 'package:open_wearable/apps/widgets/select_two_earable_view.dart';
import 'package:open_wearable/view_models/sensor_configuration_provider.dart';
import 'package:provider/provider.dart';

class StrokeTrackerView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SelectTwoEarableView(
      startApp: (leftWearable, leftConfigProv, rightWearable, rightConfigProv) {
        // Diese Ansicht startet, nachdem die Kopfhörer ausgewählt wurden.
        return StudySelection(
          leftWearable: leftWearable,
          leftConfigProvider: leftConfigProv,
          rightWearable: rightWearable,
          rightConfigProvider: rightConfigProv,
        );
      },);
}

}