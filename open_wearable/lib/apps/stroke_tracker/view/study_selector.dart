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
  final Wearable leftWearable;
  final Wearable rightWearable;
  final SensorConfigurationProvider leftConfigProvider;
  final SensorConfigurationProvider rightConfigProvider;

  const StudySelection({super.key, 
    required this.leftWearable,
    required this.rightWearable,
    required this.leftConfigProvider,
    required this.rightConfigProvider,
  });

  @override
  State<StudySelection> createState() => _StudySelectionState();
}

class _StudySelectionState extends State<StudySelection> {
  final TextEditingController _controller = TextEditingController();

  void _submitParticipantId() {
    String inputString = _controller.text.trim();
    String participantId = inputString.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    if (participantId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bitte eine participant-ID eingeben!')),
      );
      return;
    }

    StudyProtocol protocol = StudyProtocol();
    
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
          leftConfigProvider: widget.leftConfigProvider, 
          rightConfigProvider: widget.rightConfigProvider,),),)
    );
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Submit Your ID'),
        actions: [
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
                'Enter your Participant ID',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 20),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Participant ID',
                  
                  hintText: 'Letters and numbers only',
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
                      'Submit',
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


