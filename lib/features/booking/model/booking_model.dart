// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:swiftrun/core/model/address_model.dart';

class BookingModel {
  final String? courierType;
  final AddressModel? pickupAddress;
  final AddressModel? dropOffAddress;
  final List<String>? items;
  final String? quantity;
  final String? recipientName;
  final String? recipientNumber;
  final String? imageUrl;
  BookingModel({
    this.courierType,
    this.pickupAddress,
    this.dropOffAddress,
    this.items,
    this.quantity,
    this.recipientName,
    this.recipientNumber,
    this.imageUrl,
  });

  BookingModel copyWith({
    String? courierType,
    AddressModel? pickupAddress,
    AddressModel? dropOffAddress,
    List<String>? items,
    String? quantity,
    String? recipientName,
    String? recipientNumber,
    String? imageUrl,
  }) {
    return BookingModel(
      courierType: courierType ?? this.courierType,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropOffAddress: dropOffAddress ?? this.dropOffAddress,
      items: items ?? this.items,
      quantity: quantity ?? this.quantity,
      recipientName: recipientName ?? this.recipientName,
      recipientNumber: recipientNumber ?? this.recipientNumber,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'courierType': courierType,
      'pickupAddress': pickupAddress?.toMap(),
      'dropOffAddress': dropOffAddress?.toMap(),
      'items': items,
      'quantity': quantity,
      'recipientName': recipientName,
      'recipientNumber': recipientNumber,
      'imageUrl': imageUrl,
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      courierType:
          map['courierType'] != null ? map['courierType'] as String : null,
      pickupAddress: map['pickupAddress'] != null
          ? AddressModel.fromMap(map['pickupAddress'] as Map<String, dynamic>)
          : null,
      dropOffAddress: map['dropOffAddress'] != null
          ? AddressModel.fromMap(map['dropOffAddress'] as Map<String, dynamic>)
          : null,
      items: map['items'] != null
          ? List<String>.from((map['items'] as List<String>))
          : null,
      quantity: map['quantity'] != null ? map['quantity'] as String : null,
      recipientName:
          map['recipientName'] != null ? map['recipientName'] as String : null,
      recipientNumber: map['recipientNumber'] != null
          ? map['recipientNumber'] as String
          : null,
      imageUrl: map['imageUrl'] != null ? map['imageUrl'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory BookingModel.fromJson(String source) =>
      BookingModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
