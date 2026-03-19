import 'package:flutter/material.dart';
import 'package:open_wearable/apps/stroke_tracker/model/study_step.dart';


class InstructionScreen extends StatelessWidget {
  final String heading;
  final String description;
  
  final VoidCallback onNext;
  final VoidCallback onLeaveStudy;

  const InstructionScreen({
    super.key,
    required this.heading,
    required this.description,
    required this.onNext,
    required this.onLeaveStudy,
  });

  @override
  Widget build(BuildContext context) {
    // Wir verwenden einen GlobalKey, um den Scaffold manuell zu öffnen.
    // Normalerweise würde man einen AppBar verwenden, aber da InstructionScreen
    // keinen hat, ist dies die gängige Methode für eine freistehende Drawer-Öffnung.
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            // 1. Die Haupt-Column füllt jetzt den ganzen Bildschirm
            child: Column(
              children: [
                // 2. Dieser 'Expanded'-Bereich nimmt allen freien Platz ein
                Expanded(
                  child: Center(
                    // 3. Der Inhalt wird *innerhalb* des freien Platzes zentriert
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          heading,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 24), // Etwas mehr Abstand

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Task:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Text(
                                description,
                                // textAlign: TextAlign.center, // Entfernt
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                      ],
                    ),
                  ),
                ),

                // 4. Die Buttons sind jetzt außerhalb von 'Expanded' und damit am Boden
                // 5. 'SizedBox' sorgt für die volle Breite
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onNext,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Continue",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),

                const SizedBox(height: 12), // Abstand

                // 5. 'SizedBox' sorgt für die volle Breite
              ],
            ),
          ),
          Positioned(
            // <--- Positioned ist direkt im children-Array des Stacks
            top: 16 + MediaQuery.of(context).padding.top,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.menu, size: 30),
              onPressed: () {
                _scaffoldKey.currentState?.openEndDrawer();
              },
            ),
          ),
        ],
      ),
    );
  }
}