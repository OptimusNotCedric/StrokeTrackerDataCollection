import 'package:flutter/material.dart';
import 'package:open_wearable/apps/stroke_tracker/controller/logger.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';

class SummaryScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Study Summary")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Study Completed!",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              "Your recordings and logs are ready. You can download or share them below.",
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 50),
            ElevatedButton.icon(
              onPressed: _exportRecordings,
              icon: const Icon(Icons.download),
              label: const Text("Download Logs"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                textStyle: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text("Exit"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportRecordings() async {

    try {
      print("recordings");
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      print("SelectedRecordings");
      if (selectedDirectory == null) {
        // User canceled the picker
        return;
      }

      await ExperimentLogger.copyToOther(selectedDirectory);
      
    } catch (e) {
      
      print(e);
    } 
  }

  Future<void> _exportRecordingsX() async {
  try {
    print("recordings");

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/log.csv');

    // Example: write something (replace with your logger)
    await file.writeAsString('example log data');

    print("file ready: ${file.path}");

    // Share the file
    await Share.shareXFiles([XFile(file.path)]);

  } catch (e) {
    print(e);
  }
}
}