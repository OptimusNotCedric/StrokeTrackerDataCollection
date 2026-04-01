import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:open_earable_flutter/open_earable_flutter.dart';
import 'package:open_wearable/apps/stroke_tracker/controller/logger.dart';
import 'package:open_wearable/apps/stroke_tracker/model/study_protocol.dart';
import 'package:open_wearable/view_models/sensor_configuration_provider.dart';
import 'package:provider/provider.dart';
import 'study_runner.dart';

typedef SurveyResults = Map<String, dynamic>;

/// ---------------------------------------------------------------------------
/// DATA MODEL
/// ---------------------------------------------------------------------------
enum Gender {
  male,
  female,
}

/// ---------------------------------------------------------------------------
/// MAIN SCREEN
/// ---------------------------------------------------------------------------
class DemographicsSurvey extends StatefulWidget {
  final StudyProtocol protocol;
  final Wearable leftWearable;
  final Wearable rightWearable;
  final SensorConfigurationProvider leftConfigProvider;
  final SensorConfigurationProvider rightConfigProvider;
  

  const DemographicsSurvey({
    super.key,
    required this.protocol,
    required this.leftWearable,
    required this.rightWearable,
    required this.leftConfigProvider,
    required this.rightConfigProvider,
  });

  @override
  State<DemographicsSurvey> createState() => _DemographicsSurveyState();
}

class _DemographicsSurveyState extends State<DemographicsSurvey> {
  TextEditingController ageInputController = TextEditingController();
  TextEditingController predispotionsController = TextEditingController();
  late final ExperimentLogger _logger;
  int age = -1;
  Gender? genderChoice;
  late final String Function(String en,String de) t;

  @override
  void initState() {
    super.initState();
    _logger = Provider.of<ExperimentLogger>(context, listen: false);
    t = widget.protocol.t;
  }

  @override
  Widget build(BuildContext context){
    
    return PopScope(
      canPop: true,
      child: PlatformScaffold(
      appBar: PlatformAppBar(title: PlatformText(t("Fill out the Survey", "Fragebogen ausfüllen")),),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: Column(
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t("How old are you?", "Wie alt sind Sie?"),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 8),
                  Text(
                    t("Please enter your age in years", "Bitte geben Sie Ihr Alter in Jahren ein"),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: ageInputController,
                    keyboardType: TextInputType.number,
                    onChanged: (value) => setState(() {
                      age = int.tryParse(value) ?? 0;
                    }),
                    decoration: InputDecoration(
                      labelText: t("Age", "Alter"),
                      suffixText: t("years", "Jahre"),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: RadioGroup<Gender>(
              groupValue: genderChoice,
              onChanged: (Gender? value) {
                setState(() {
                  genderChoice = value;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t("What is your biological gender?", "Was ist Ihr biologisches Geschlecht?"),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 12),
                    RadioListTile<Gender>(
                      title: Text(t("Male", "Männlich")),
                      value: Gender.male,
                    ),
                    RadioListTile<Gender>(
                      title: Text(t("Female", "Weiblich")),
                      value: Gender.female,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t(
                      "Do you have any predispositions that could impede this study?",
                      "Haben Sie Vorerkrankungen, die diese Studie beeinträchtigen könnten?"
                    ),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: predispotionsController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(padding: EdgeInsetsGeometry.fromLTRB(5, 10, 5, 10),
          child: ElevatedButton(onPressed: _isFilledOut()?_continueButtonPressed:null, child: Text(t("Continue", "Weiter"))),)
        ],
        
      ),
      )
    ));
  }

  void _continueButtonPressed(){
      if(_isFilledOut()){
        _finishSurvey();
      }
  }

  bool _isFilledOut(){
    return age > 0 && (genderChoice != null);
  }



  Future<void> _finishSurvey() async {
    final results = <String, dynamic>{};

    results["age"] = age;
    results["gender"] = genderChoice.toString().split(".")[1];
    results["predispositions"] = predispotionsController.text;

    await _logger.startLogging(false, widget.protocol.sessionId);

    for (var entry in results.entries) {
      _logger.logOtherEvent(
        0,
        "SurveyResults",
        entry.key,
        entry.value.toString(),
      );
    }

    await _logger.stopAndWriteLogging(false);

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        platformPageRoute(
          context: context,
          builder: (_) => StudyRunner(
            protocol: widget.protocol,
            logger: _logger,
            leftWearable: widget.leftWearable,
            rightWearable: widget.rightWearable,
            leftConfigProvider: widget.leftConfigProvider,
            rightConfigProvider: widget.rightConfigProvider,
          ),
        ),
      );
    }
  }
}