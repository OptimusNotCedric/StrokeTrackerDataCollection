import 'dart:math';

import 'package:flutter/material.dart';

class TaskScreen extends StatelessWidget {
  final int currentRepetition;
  final int maxRepetition;

  const TaskScreen({
    super.key,
    required this.currentRepetition,
    required this.maxRepetition,
    });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Repetition Task")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Repetition $currentRepetition of $maxRepetition",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () { Navigator.of(context).pop();},
              child: Text(
                currentRepetition <= maxRepetition
                    ? "Start/Repeat Task"
                    : "Done",
              ),
            ),
          ],
        ),
      ),
    );
  }
}