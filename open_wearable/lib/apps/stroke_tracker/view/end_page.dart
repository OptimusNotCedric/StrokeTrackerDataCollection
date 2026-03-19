import 'package:flutter/material.dart';
import 'package:open_wearable/apps/stroke_tracker/controller/logger.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class SummaryScreen extends StatelessWidget {

  const SummaryScreen({super.key});

  Future<void> _downloadLog(BuildContext context) async {
    try {

      final files = await ExperimentLogger.getAllLogFiles();

      for (File file in files) {
      if (await file.exists()) {
          // For example, you could copy the file to Downloads or share it
          // Here we just show a message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Log file ready at ${file.path}')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Log file not found!')),
          );
        }}
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
      
    }
  }

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
              onPressed: () => _downloadLog(context),
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
}