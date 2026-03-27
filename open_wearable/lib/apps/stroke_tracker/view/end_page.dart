import 'package:flutter/material.dart';
import 'package:open_wearable/apps/stroke_tracker/controller/logger.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {

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
              "Your recordings and logs are ready. Export them below.",
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 50),

            // ================= LOGS =================
            ElevatedButton.icon(
              onPressed: () => _showExportDialog(type: "logs"),
              icon: const Icon(Icons.description),
              label: const Text("Export Logs"),
            ),

            const SizedBox(height: 20),

            // ================= FACEMESH =================
            ElevatedButton.icon(
              onPressed: () => _showExportDialog(type: "facemesh"),
              icon: const Icon(Icons.face),
              label: const Text("Export FaceMesh Data"),
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: _deleteLogs,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
              ),
              child: const Text("Exit"),
            ),
          ],
        ),
      ),
    );
  }

  // ================= DIALOG =================
  Future<void> _showExportDialog({required String type}) async {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Export Data"),
          content: const Text("Choose what you want to export"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _exportSingle(type);
              },
              child: const Text("Current File"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _exportAll(type);
              },
              child: const Text("All Files"),
            ),
          ],
        );
      },
    );
  }

  // ================= SINGLE EXPORT =================
  Future<void> _exportSingle(String type) async {
    List<File> files;

    if (type == "logs") {
      files = await ExperimentLogger.getAllLogFiles();
    } else {
      files = await ExperimentLogger.getAllFaceData();
    }

    if (files.isEmpty) return;

    final file = files.last;

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
      ),
    );
  }

  // ================= ALL EXPORT =================
  Future<void> _exportAll(String type) async {
    List<File> files;

    if (type == "logs") {
      files = await ExperimentLogger.getAllLogFiles();
    } else {
      files = await ExperimentLogger.getAllFaceData();
    }

    final xFiles = files.map((f) => XFile(f.path)).toList();

    await SharePlus.instance.share(
      ShareParams(
        files: xFiles,
      ),
    );
  }

  // ================= DELETE =================
  Future<void> _deleteLogs() async {
    await ExperimentLogger.deleteAllLogFiles();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All logs deleted")),
      );
    }
  }
}