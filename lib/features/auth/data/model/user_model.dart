import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? userID;
  String? phoneNumber;
  String? email;
  String? firstName;
  String? lastName;
  String? userType;
  String? profilePix;
  Timestamp? dateCreated;
  String? userToken;
  String? countryCode;
  String? countryName;

  UserModel({
    this.userID,
    this.phoneNumber,
    this.email,
    this.firstName,
    this.lastName,
    this.userType,
    this.profilePix,
    this.dateCreated,
    this.userToken,
    this.countryCode,
    this.countryName,
  });

  Map<String, dynamic> toJson() {
    return {
      'userID': userID,
      'phoneNumber': phoneNumber,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'userType': userType,
      'profilePix': profilePix,
      'dateCreated': dateCreated!.toDate().toIso8601String(),
      'userToken': userToken,
      'countryCode': countryCode,
      'countryName': countryName,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel(
      userID: map['userID'],
      phoneNumber: map['phoneNumber'],
      email: map['email'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      userType: map['userType'],
      profilePix: map['profilePix'],
      dateCreated: (map['dateCreated'] is Timestamp)
          ? map["dateCreated"]
          : Timestamp.fromDate(
              DateTime.parse(
                map['dateCreated'],
              ),
            ),
      userToken: map['userToken'],
      countryCode: map['countryCode'],
      countryName: map['countryName'],
    );
  }

  // @override
  // String toString() {
  //   return 'UserModel(uid: $uid, phoneNumber: $phoneNumber, email: $email, firstName: $firstName, lastName: $lastName, userType: $userType, dateCreated: $dateCreated,)';
  // }
}
