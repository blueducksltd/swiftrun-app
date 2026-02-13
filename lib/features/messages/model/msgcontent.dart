import 'package:cloud_firestore/cloud_firestore.dart';

class Msgcontent {
  String? senderID;
  String? content;
  String? receiverID;
  Timestamp? addtime;

  Msgcontent({
    this.senderID,
    this.content,
    this.receiverID,
    this.addtime,
  });

  factory Msgcontent.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Msgcontent(
      senderID: data?['senderID'],
      content: data?['content'],
      receiverID: data?['receiverID'],
      addtime: data?['addtime'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (senderID != null) "senderID": senderID,
      if (content != null) "content": content,
      if (receiverID != null) "receiverID": receiverID,
      if (addtime != null) "addtime": addtime,
    };
  }
}
