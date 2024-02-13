import 'dart:convert';


import 'package:video_call_agora/features/home_screen/models/agora_user_model.dart';

import 'call_request_model.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class CallRequestDetailsModel {
  final String? docId;
  final AgoraUserModel from;
  final AgoraUserModel to;
  final CallStatus status;
  CallRequestDetailsModel({
     this.docId,
    required this.from,
    required this.to,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'docId': docId,
      'from': from.toMap(),
      'to': to.toMap(),
      'status': status.name,
    };
  }

  factory CallRequestDetailsModel.fromMap(Map<String, dynamic> map) {
    return CallRequestDetailsModel(
      docId: map['docId'] != null ? map['docId'] as String : null,
      from: AgoraUserModel.fromMap(map['from'] as Map<String,dynamic>),
      to: AgoraUserModel.fromMap(map['to'] as Map<String,dynamic>),
      status: CallStatus.fromString(map['status'] ),
    );
  }

  String toJson() => json.encode(toMap());

  factory CallRequestDetailsModel.fromJson(String source) =>
      CallRequestDetailsModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
