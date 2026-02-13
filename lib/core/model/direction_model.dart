import 'dart:convert';

class DirectionModel {
  final String? distanceInKM;

  // final int? distanceInMeter;
  final int? distanceInMeter;
  final String? durationInHour;
  final dynamic duration;
  final String? polylinePoints;
  DirectionModel({
    this.distanceInKM,
    this.distanceInMeter,
    this.durationInHour,
    this.duration,
    this.polylinePoints,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'distanceInKM': distanceInKM,
      'distanceInMeter': distanceInMeter,
      'durationInHour': durationInHour,
      'duration': duration,
      'polylinePoints': polylinePoints,
    };
  }

  factory DirectionModel.fromMap(Map<String, dynamic> map) {
    return DirectionModel(
      distanceInKM: map['distanceInKM'] as String,
      distanceInMeter: (map['distanceInMeter'] as num).toInt(),
      durationInHour: map['durationInHour'] as String,
      duration: map['duration'],
      polylinePoints: map['polylinePoints'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory DirectionModel.fromJson(String source) =>
      DirectionModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
