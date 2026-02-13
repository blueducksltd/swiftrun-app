// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';

class FaqModel {
  int? id;
  String? subject;
  String? content;
  bool? isExpanded;
  Timestamp? dateCreated;
  FaqModel({
    this.id,
    this.subject,
    this.content,
    this.isExpanded = false,
    this.dateCreated,
  });

  factory FaqModel.fromJson(Map<String, dynamic> json) {
    return FaqModel(
      id: json['id'] ?? 0,
      subject: json['title'] ?? '',
      isExpanded: json['isExpanded'],
      content: json['body'] ?? '',
      dateCreated: (json['dateCreated'] is Timestamp)
          ? json['dateCreated']
          : Timestamp.fromDate(
              DateTime.parse(
                json['dateCreated'],
              ),
            ),
    );
  }
}
