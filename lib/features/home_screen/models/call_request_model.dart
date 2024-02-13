import 'dart:convert';

import 'package:get/utils.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class CallRequestModel {
  final String? docId;
  final String from;
  final String to;
  final CallStatus status;
  final DateTime timeStamp;
  CallRequestModel({
    this.docId,
    required this.from,
    required this.to,
    required this.status,
    required this.timeStamp,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'docId': docId,
      'from': from,
      'to': to,
      'status': status.name,
      'timeStamp': timeStamp.toUtc().toIso8601String(),
    };
  }

  factory CallRequestModel.fromMap(Map<String, dynamic> map) {
    return CallRequestModel(
      docId: map['docId'] != null ? map['docId'] as String : null,
      from: map['from'] as String,
      to: map['to'] as String,
      status: CallStatus.fromString(map['status']),
      timeStamp: DateTime.parse(map['timeStamp']).toLocal(),
    );
  }

  String toJson() => json.encode(toMap());

  factory CallRequestModel.fromJson(String source) =>
      CallRequestModel.fromMap(json.decode(source) as Map<String, dynamic>);

  CallRequestModel copyWith({
    String? docId,
    String? from,
    String? to,
    CallStatus? status,
    DateTime? timeStamp,
  }) {
    return CallRequestModel(
      docId: docId ?? this.docId,
      from: from ?? this.from,
      to: to ?? this.to,
      status: status ?? this.status,
      timeStamp: timeStamp ?? this.timeStamp,
    );
  }
}

enum CallStatus {
  initiated,
  accepted,
  rejected;

  static CallStatus fromString(value) {
    return CallStatus.values
            .firstWhereOrNull((element) => element.name == value) ??
        CallStatus.initiated;
  }
}
