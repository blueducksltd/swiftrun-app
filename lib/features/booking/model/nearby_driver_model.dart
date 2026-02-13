class CloseByDriverModel {
  String? driversId;
  double? latitude;
  double? longitude;
  CloseByDriverModel({
    this.driversId,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'driverID': driversId,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory CloseByDriverModel.fromMap(Map<String, dynamic> map) {
    return CloseByDriverModel(
      driversId: map['driverID'] as String,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
    );
  }
}
