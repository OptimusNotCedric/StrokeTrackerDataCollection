import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:csv/csv.dart';
import 'package:face_detection_tflite/face_detection_tflite.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

/// Represents a single step event
class StepEvent {
  final int blockNumber;
  final String taskId;
  final DateTime startTime;
  DateTime? endTime;
  final int relativeStartTime;
  int? relativeEndTime;

  StepEvent({
    required this.blockNumber,
    required this.taskId,
    required this.startTime,
    this.endTime,
    required this.relativeStartTime,
    this.relativeEndTime,
  });

  List<String> toCsvRow(String sessionID) {
    return [
      sessionID,
      blockNumber.toString(),
      taskId,
      startTime.toIso8601String(),
      endTime?.toIso8601String() ?? '',
      relativeStartTime.toString(),
      relativeEndTime?.toString() ?? '',
    ];
  }
}

class OtherEvent {
  final int blockNumber;
  final String instruction;
  final String taskId;
  final DateTime timestamp;
  final int relativeTime;
  final String eventType;

  OtherEvent({
    required this.blockNumber,
    required this.instruction,
    required this.taskId,
    required this.timestamp,
    required this.relativeTime,
    required this.eventType,
  });

  List<String> toCsvRow(String SessionID) {
    return [
      SessionID,
      blockNumber.toString(),
      instruction,
      taskId,
      timestamp.toIso8601String(),
      relativeTime.toString(),
      eventType,
    ];
  }
}

class SyncEvent {
  final int deviceTimestamp;
  final DateTime phoneTimestamp;
  final int relativePhoneTime;
  SyncEvent({
    required this.deviceTimestamp,
    required this.phoneTimestamp,
    required this.relativePhoneTime,
  });

  List<String> toCsvRow(String sessionID) {
    return [
      sessionID,
      deviceTimestamp.toString(),
      phoneTimestamp.toIso8601String(),
      relativePhoneTime.toString(),
    ];
  }
}

/// Logger for ExperimentManager
class ExperimentLogger extends ChangeNotifier{
  static const String _stepsCsvHeader =
      'SessionID,Block,Task,DurationS,StartTime,EndTime,RelativeStartMS,RelativeEndMS';
  static const String _otherCsvHeader =
      'SessionID,Block,Task,Time,RelativeTimeMS,EventType,Value';
  static const String _syncCsvHeader =
      "SessionID,DeviceTimestamp,PhoneTimestamp,RelativePhoneTimeMS";

  late File _stepsCsvFile;
  late File _otherCsvFile;
  late File _syncLeftCsvFile;
  late File _syncRightCsvFile;

  late String sessionID;
  late DateTime _sessionStartTime;
  final List<StepEvent> _stepEvents = [];
  final List<OtherEvent> _otherEvents = [];
  final List<SyncEvent> _syncLeftEvents = [];
  final List<SyncEvent> _syncRightEvents = [];
  Completer<void>? _sensorsReady;

  File get csvFile => _stepsCsvFile;
  Future<void> get sensorsReady {
    // If both are already satisfied, just return immediately
    if (_syncLeftEvents.isNotEmpty && _syncRightEvents.isNotEmpty) {
      return Future.value();
    }

    // Create a new pending completer if none exists or the old one is completed
    if (_sensorsReady == null || _sensorsReady!.isCompleted) {
      _sensorsReady = Completer<void>();
    }

    return _sensorsReady!.future;
  }

  Future<void> startLogging(bool sync, String newSessionID) async {
    sessionID = newSessionID;
    final dir = await getApplicationDocumentsDirectory();

    if (!sync) {
      _stepsCsvFile = File('${dir.path}/steps_log.csv');
      _otherCsvFile = File('${dir.path}/other_log.csv');
    }

    _syncLeftCsvFile = File('${dir.path}/sync_left_log.csv');
    _syncRightCsvFile = File('${dir.path}/sync_right_log.csv');

    if (!await _stepsCsvFile.exists()){
      _stepsCsvFile.writeAsString(_stepsCsvHeader);
    }

    if (!await _otherCsvFile.exists()){
      _otherCsvFile.writeAsString(_otherCsvHeader);
    }

    if (!await _syncLeftCsvFile.exists()){
      _syncLeftCsvFile.writeAsString(_syncCsvHeader);
    }

    if (!await _syncRightCsvFile.exists()){
      _syncRightCsvFile.writeAsString(_syncCsvHeader);
    }

    _sensorsReady = null;
    _sessionStartTime = DateTime.now();
  }

  void logOtherEvent(
    int blockNumber,
    String instruction,
    String taskId,
    String eventType,
  ) {
    final now = DateTime.now();
    final relative = now.difference(_sessionStartTime).inMilliseconds;
    final event = OtherEvent(
      blockNumber: blockNumber,
      instruction: instruction,
      taskId: taskId,
      timestamp: now,
      relativeTime: relative,
      eventType: eventType,
    );
    print(event.toCsvRow(sessionID));
    _otherEvents.add(event);
  }

  void logSyncLeftEvent(int deviceTimestamp) {
    final now = DateTime.now();
    final relative = now.difference(_sessionStartTime).inMilliseconds;
    final event = SyncEvent(
      deviceTimestamp: deviceTimestamp,
      phoneTimestamp: now,
      relativePhoneTime: relative,
    );
    print(event.toCsvRow(sessionID));
    _syncLeftEvents.add(event);
    _checkReady();
  }

  void logSyncRightEvent(int deviceTimestamp) {
    final now = DateTime.now();
    final relative = now.difference(_sessionStartTime).inMilliseconds;
    final event = SyncEvent(
      deviceTimestamp: deviceTimestamp,
      phoneTimestamp: now,
      relativePhoneTime: relative,
    );
    print(event.toCsvRow(sessionID));
    _syncRightEvents.add(event);
    _checkReady();
  }

  void logTaskStart(
    int blockNumber,
    String taskId,
  ) {
    final now = DateTime.now();
    final relative = now.difference(_sessionStartTime).inMilliseconds;
    final event = StepEvent(
      blockNumber: blockNumber,
      taskId: taskId,
      startTime: now,
      relativeStartTime: relative,
    );
    print(event.toCsvRow(sessionID));
    _stepEvents.add(event);
  }

  void logTaskEnd() {
    if (_stepEvents.isEmpty) return;
    final now = DateTime.now();
    final relative = now.difference(_sessionStartTime).inMilliseconds;
    final event = _stepEvents.last;
    event.endTime = now;
    event.relativeEndTime = relative;
    print(event.toCsvRow(sessionID));
  }

  void discardLastTask() {
    if (_stepEvents.isNotEmpty) _stepEvents.removeLast();
  }

  Future<void> stopAndWriteLogging(bool sync) async {
    print("Finalizing experiment");

    final converter = ListToCsvConverter();

    final syncLeftRows = <List<String>>[];
    
    for (final e in _syncLeftEvents) {
      syncLeftRows.add(e.toCsvRow(sessionID));
    }

    final syncRightRows = <List<String>>[];
    
    for (final e in _syncRightEvents) {
      syncRightRows.add(e.toCsvRow(sessionID));
    }

    final syncLeftCsvData = converter.convert(syncLeftRows);
    final syncRightCsvData = converter.convert(syncRightRows);

    await Future.wait([
      _syncLeftCsvFile.writeAsString("\n$syncLeftCsvData", mode: FileMode.append),
      _syncRightCsvFile.writeAsString("\n$syncRightCsvData", mode: FileMode.append),
    ]);

    if (!sync) {
      final stepsRows = <List<String>>[];
      for (final e in _stepEvents) {
        stepsRows.add(e.toCsvRow(sessionID));
      }
      final otherRows = <List<String>>[];
      for (final e in _otherEvents) {
        otherRows.add(e.toCsvRow(sessionID));
      }

      final stepsCsvData = converter.convert(stepsRows);
      final otherCsvData = converter.convert(otherRows);

      await Future.wait([
        _stepsCsvFile.writeAsString("\n$stepsCsvData", mode: FileMode.append),
        _otherCsvFile.writeAsString("\n$otherCsvData", mode: FileMode.append),
      ]);
    }

    _stepEvents.clear();
    _otherEvents.clear();
    _syncLeftEvents.clear();
    _syncRightEvents.clear();

    _sensorsReady = null;
  }

  /// Get all log files in the documents directory
  static Future<List<File>> getAllLogFiles() async {
    final directory = await getApplicationDocumentsDirectory();
    final files = <File>[];

    try {
      await for (final entity in directory.list()) {
        if (entity is File && entity.path.endsWith('log.csv')) {
          files.add(entity);
        }
      }
    } catch (e) {
      print('Error listing log files: $e');
    }

    // Sort by modification date, newest first
    files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    return files;
  }

  /// Delete a log file
  static Future<void> deleteLogFile(File file) async {
    if (await file.exists()) {
      await file.delete();
    }
 }

  void _checkReady() {
    if (_syncLeftEvents.isNotEmpty &&
        _syncRightEvents.isNotEmpty &&
        _sensorsReady != null &&
        !_sensorsReady!.isCompleted) {
      _sensorsReady!.complete();
    }
  }

  Future<void> clearAppDocumentsDirectory() async {
    final dir = await getApplicationDocumentsDirectory();

    if (await dir.exists()) {
      final files = dir.listSync();

      for (final file in files) {
        try {
          if (file is File) {
            await file.delete();
          } else if (file is Directory) {
            await file.delete(recursive: true);
          }
        } catch (e) {
          print("Error deleting $file: $e");
        }
      }
    }
    print("ApplicationDocumentsDirectory cleared");
  }


  static Future<void> deleteAllLogFiles() async {
    final dir = await getApplicationDocumentsDirectory();

    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }

    await dir.create();
  }

  static Future<void> copyToOther(String dirPath) async {
    List<File> sourceFiles = await getAllLogFiles();
    for (File file in sourceFiles) {
      String targetPath = "$dirPath/${file.path.split("/").last}";
    final targetFile = File(targetPath);

    // Make sure the directory exists
    await Directory(dirPath).create(recursive: true);

    // Delete target if it exists (overwrite safely)
    await targetFile.writeAsString(await file.readAsString());
    }
  }

  static String boundingBoxToString(BoundingBox box) {
    return [
      [box.topLeft.x, box.topLeft.y].join(';'),
      [box.topRight.x, box.topRight.y].join(';'),
      [box.bottomLeft.x, box.bottomLeft.y].join(';'),
      [box.bottomRight.x, box.bottomRight.y].join(';'),
    ].join(',');
  }

  static String faceMeshToString(FaceMesh mesh) {
    final values = <String>[];

    List<Point> points = mesh.points;
    List<String> point = [];

    for (var p in points) {
      point.add(p.x.toString());
      point.add(p.y.toString());
      point.add(p.z.toString());
      values.add("(${point.join(';')})");
      point = [];
    }

  return values.join(',');
  }

  static Future<void> logFaceData(
  List<(DateTime, Face)> faces,
  String sessionId,
  int repetition,
  ) async {
    final csvRows = <String>[];

    for (final (time, face) in faces) {
      if (face.mesh != null) {
        final row =
            '$sessionId,'
            '$repetition,'
            '${time.toIso8601String()},'
            '${boundingBoxToString(face.boundingBox)},'
            '${faceMeshToString(face.mesh!)}';

        csvRows.add(row);
      }
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${sessionId}_faces.csv');
    if (!await file.exists()) {
      List<String> header = [];
      header.add("SessionId");
      header.add("RepetitionNumber");
      header.add("TimeStamp");
      header.add("box.left,box.top,box.right,box.bottom");
      
      for (int i = 0; i < faces.length; i++) {
        header.add("Point $i x;y;z");
      }
      file.writeAsString(header.join(","));
    }
    // append correctly
    final sink = file.openWrite(mode: FileMode.append);

    for (final row in csvRows) {
      sink.writeln(row);
    }

    await sink.flush();
    await sink.close();
  }

  static Future<List<File>> getAllFaceData() async {
    final directory = await getApplicationDocumentsDirectory();
    final files = <File>[];

    try {
      await for (final entity in directory.list()) {
        if (entity is File && entity.path.endsWith('faces.csv')) {
          files.add(entity);
        }
      }
    } catch (e) {
      print('Error listing log files: $e');
    }

    // Sort by modification date, newest first
    files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    return files;
  }
}
