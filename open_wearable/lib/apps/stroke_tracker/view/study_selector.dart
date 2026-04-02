import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:open_earable_flutter/open_earable_flutter.dart';
import 'package:open_wearable/apps/stroke_tracker/controller/logger.dart';
import 'package:open_wearable/apps/stroke_tracker/model/study_protocol.dart';
import 'package:open_wearable/apps/stroke_tracker/view/demographics_survey.dart';
import 'package:open_wearable/apps/stroke_tracker/view/download_page.dart';
import 'package:open_wearable/view_models/sensor_configuration_provider.dart';
import 'package:provider/provider.dart';



class StudySelection extends StatefulWidget {
  // Hinzufügen der benötigten Parameter
  final OpenEarableV2 leftWearable;
  final OpenEarableV2 rightWearable;
  final Wearable ring;
  final SensorConfigurationProvider leftConfigProvider;
  final SensorConfigurationProvider rightConfigProvider;
  final SensorConfigurationProvider ringConfigProvider;

  const StudySelection({super.key, 
    required this.leftWearable,
    required this.rightWearable,
    required this.leftConfigProvider,
    required this.rightConfigProvider,
    required this.ring,
    required this.ringConfigProvider,
  });

  @override
  State<StudySelection> createState() => _StudySelectionState();
}

class _StudySelectionState extends State<StudySelection> {
  final TextEditingController _controller = TextEditingController();
  bool isEnglish = false;

  void _submitParticipantId() {
    String inputString = _controller.text.trim();
    String participantId = inputString.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    StudyProtocol protocol = StudyProtocol();
    protocol.isEnglish = isEnglish;
    
    protocol.addParticipantId(participantId);
    protocol.addSessionId("${DateTime.now().toIso8601String()}");

     Navigator.push(
      context, platformPageRoute(
        context: context,
        builder: (_) => ChangeNotifierProvider(
        create: (_) => ExperimentLogger(), child :DemographicsSurvey(
          protocol: protocol, 
          leftWearable: widget.leftWearable, 
          rightWearable: widget.rightWearable, 
          ring: widget.ring,
          leftConfigProvider: widget.leftConfigProvider, 
          rightConfigProvider: widget.rightConfigProvider,
          ringConfigProvider: widget.rightConfigProvider,
          )
          ,),)
    );
  }

  
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Submit Your ID'),
        actions: [
          Row(
              children: [
                Text(isEnglish ? 'EN' : 'DE'),
                Switch(
                  value: isEnglish,
                  onChanged: (value) {
                    setState(() {
                      isEnglish = value;
                    });
                  },
                ),
              ],
            ),
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DownloadScreen(),
                ),
                );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isEnglish 
                  ? 'Enter your Participant ID' 
                  : 'Teilnehmer-ID eingeben',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 20),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: isEnglish ? 'Participant ID' : 'Teilnehmer-ID',
                  
                  hintText: isEnglish ? 'Letters and numbers only' 
                      : 'Nur Buchstaben und Zahlen',
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitParticipantId,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      isEnglish ? 'Submit' : 'Absenden',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
    
}


