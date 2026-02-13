class DriverModel {
  String? driversId;
  String? firstName;
  String? lastName;
  String? phoneNumber;
  String? picturePath;
  String? userToken;
  double? averageRating;
  int? totalRatings;

  DriverModel({
    this.driversId,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.picturePath,
    this.userToken,
    this.averageRating,
    this.totalRatings,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      driversId: json['driversId'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      phoneNumber: json['phoneNumber'],
      picturePath: json['profilePic'],
      userToken: json['userToken'],
      averageRating: json['averageRating']?.toDouble(),
      totalRatings: json['totalRatings'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'driversId': driversId,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'profilePic': picturePath,
      'userToken': userToken,
      'averageRating': averageRating,
      'totalRatings': totalRatings,
    };
  }
}
