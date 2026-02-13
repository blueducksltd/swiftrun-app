import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class AddressModel {
  String? name;
  String? description;
  String? placeID;
  double? latitude;
  double? longitude;
  AddressModel({
    this.name,
    this.description,
    this.placeID,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'description': description,
      'placeID': placeID,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      name: map['name'] != null ? map['name'] as String : null,
      description:
          map['description'] != null ? map['description'] as String : null,
      placeID: map['placeID'] != null ? map['placeID'] as String : null,
      latitude: map['latitude'] != null ? map['latitude'] as double : null,
      longitude: map['longitude'] != null ? map['longitude'] as double : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory AddressModel.fromJson(String source) =>
      AddressModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
