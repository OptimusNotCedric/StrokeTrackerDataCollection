import 'dart:io';
import 'package:flutter/services.dart';
import 'package:open_wearable/apps/stroke_tracker/model/study_step.dart';
import 'package:yaml/yaml.dart';

/// Represents a sensor configuration
class SensorConfig {
  final String sensor;
  final double sampleRate;

  SensorConfig({
    required this.sensor,
    required this.sampleRate,
  });

}

/// Represents an experiment configuration
class ExperimentConfig {
 
  final List<SensorConfig> globalSensorConfigs;

  ExperimentConfig({
    required this.globalSensorConfigs,
  });

  /// Default sensor ID mapping for OpenEarable v2
  static const Map<String, String> sensorIdMap = {
    'imu': "9-Axis IMU",/*
    'ppg': "Pulse Oximeter",
    'temperature': "Skin Temperature Sensor",
    'bone_conduction': "Bone Conduction Accelerometer",*/
    'pressure': "Ear Canal Pressure Sensor",
    'microphone': "Microphones",
  };

  /// Get the sensor ID for a given sensor name
  String? getSensorId(String sensorName) {
    final normalizedName = sensorName.toLowerCase();
    return sensorIdMap[normalizedName];
  }

}
