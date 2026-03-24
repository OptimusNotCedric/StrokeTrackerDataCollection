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
              onPressed: _exportRecordingsX,
              icon: const Icon(Icons.download),
              label: const Text("Download Logs"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                textStyle: const TextStyle(fontSize: 20),
              ),
            ),
            if (true)
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _deleteLogs,
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
        List<File> files = await ExperimentLogger.getAllLogFiles();
        List<XFile> xFiles = [];
        // Share the file
        for (File file in files) {
          xFiles.add(XFile(file.path));
          print(file.path);
        }
        final params = ShareParams(files: xFiles, text: "Recordings");
        final result = await SharePlus.instance.share(params);
        if (result.status == ShareResultStatus.success) {
          print("Successfully exported");
        }
    } catch (e) {
        print(e);
    }
  }

  Future<void> _deleteLogs() async {
    await ExperimentLogger.deleteAllLogFiles();
  }
  
}
