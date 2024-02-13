import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/utils.dart';

import '../../services/firestore_service.dart';
import '../video_call_screen/video_call_screen.dart';
import 'home_screen.dart';
import 'models/call_request_model.dart';
import 'widgets/call_initiated_sheet.dart';
import 'widgets/call_rejected_sheet.dart';

mixin HomeMixin<T extends StatefulWidget> on State<T> {
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? listenStream;

  void navigateToVideoCallingScreen() {
    Navigator.pushNamed(context, VideoCallScreen.path);
  }

  bool initiated = false;

  void listenForCallRequests() {
    final String currentUserId = FirestoreService.currentUser!.uid;

    // only listening for the latest request
    listenStream = FirestoreService.callRequestRef
        // .orderBy('timeStamp', descending: true)
        // .limit(1)
        .snapshots()
        .listen((event) {
      if (!initiated) {
        initiated = true;
        return;
      }
      final newRequest = event.docChanges
          .map((e) => e.doc)
          .map((e) {
            Map<String, dynamic> data = e.data()!;
            data.addAll({"docId": e.id});
            return CallRequestModel.fromMap(data);
          })
          .toList()
          .firstWhereOrNull(
            (element) =>
                element.from == currentUserId || element.to == currentUserId,
          );
      if (newRequest == null) return;
      actionBasedOnStatus(newRequest);
    });
  }

  void showCallRejectedSheet(CallRequestModel newRequest) {
    if (rejectedByUser) return;
    showModalBottomSheet(
      context: context,
      builder: (context) => const CallRejectedSheet(),
    );
    rejectedByUser = false;
  }

  bool rejectedByUser = false;

  void showCallInitiatedSheet(CallRequestModel newRequest) async {
    final result = await showModalBottomSheet<CallStatus>(
      enableDrag: false,
      isDismissible: false,
      context: context,
      builder: (context) => CallInitiatedSheet(requestModel: newRequest),
    );
    if (result == null) return;
    if (result == CallStatus.rejected) {
      rejectedByUser = true;
    }
    FirestoreService.updateRequestStatus(newRequest.copyWith(status: result));
  }

  void actionBasedOnStatus(CallRequestModel newRequest) {
    Navigator.popUntil(
        context, (route) => route.settings.name == HomeScreen.path);
    switch (newRequest.status) {
      case CallStatus.initiated:
        showCallInitiatedSheet(newRequest);
        break;
      case CallStatus.accepted:
        navigateToVideoCallingScreen();
        break;
      case CallStatus.rejected:
        showCallRejectedSheet(newRequest);
        break;
    }
  }
}
