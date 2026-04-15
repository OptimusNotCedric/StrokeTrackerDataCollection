import 'package:flutter/material.dart';
import 'package:open_earable_flutter/open_earable_flutter.dart';
import 'package:open_wearable/view_models/sensor_configuration_provider.dart';
import 'package:open_wearable/view_models/wearables_provider.dart';
import 'package:provider/provider.dart';

class SelectTwoEarableView extends StatelessWidget {
  final Widget Function(
    OpenEarableV2 right,
    SensorConfigurationProvider rightConfig,
  ) startApp;

  const SelectTwoEarableView({super.key, required this.startApp});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<WearablesProvider>();

    final wearables = prov.wearables.whereType<OpenEarableV2>().toList();
    final allWearables = prov.wearables;
    _logWearables(allWearables);
    return FutureBuilder<_EarablePair>(
      future: _resolveEarables(wearables, allWearables),
      builder: (context, snapshot) {
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text("Error detecting earables")),
          );
        }

        final pair = snapshot.data!;
       
        final right = pair.right;
        

      
        final hasRight = right != null;
     
        final bothConnected = hasRight ;

        
        if (!bothConnected) {
          return Scaffold(
            appBar: AppBar(title: const Text("Select Earables")),
            body: Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.warning, color: Colors.red, size: 40),
                    const SizedBox(height: 10),
                    const Text(
                      "Missing earables",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(_buildMissingText(hasRight)),
                    const SizedBox(height: 20),
                    const Text(
                      "Please connect both left and right earables.",
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // All CONNECTED → START APP
        return startApp(
          right,
          prov.getSensorConfigurationProvider(right),
          
        );
      },
    );
  }

  /// 🔍 Resolve left/right asynchronously
  Future<_EarablePair> _resolveEarables(List<OpenEarableV2> wearables, List<Wearable> allWearables) async {
    
    OpenEarableV2? right;
    
    
    for (var wearable in wearables) {
      right = wearable;
      
    }

    return _EarablePair(right: right);
  }

  

  String _buildMissingText(bool hasRight) {

      return "Right earable is not connected.";
    
  }

  void _logWearables(List<Wearable> wearables) {
    for (var wearable in wearables) {
      print(wearable.name + " " + wearable.deviceId);
      for(Sensor sensor in wearable.requireCapability<SensorManager>().sensors) {
        print("${sensor.sensorName} ${sensor.axisNames.reduce((a,b)=> a+b)}");
      }
    }
  }
}




class _EarablePair {
  final OpenEarableV2? right;
  

  _EarablePair({this.right});
}