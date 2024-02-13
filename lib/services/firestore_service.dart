import 'package:agora_uikit/agora_uikit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:video_call_agora/core/app_config.dart';
import 'package:video_call_agora/features/home_screen/models/agora_user_model.dart';
import 'package:video_call_agora/features/home_screen/models/call_request_details_model.dart';
import 'package:video_call_agora/features/home_screen/models/call_request_model.dart';
import 'package:video_call_agora/services/fcm_service.dart';

class FirestoreService {
  static final currentUser = FirebaseAuth.instance.currentUser;
  static final db = FirebaseFirestore.instance;
  static final agoraUsersRef = db.collection(appConfig.userCollection);
  static final callRequestRef = db.collection(appConfig.callRequestCollection);
  static final clientDetailsRef = db.collection(appConfig.clientDetails);

  static Stream<QuerySnapshot<Map<String, dynamic>>> userStream =
      agoraUsersRef.snapshots();

  static updateUserDetails() async {
    final fcmToken = await FCMService.token ?? "";
    AgoraUserModel userModel = AgoraUserModel(
        uid: currentUser!.uid,
        name: currentUser!.displayName ?? "",
        email: currentUser!.email ?? "",
        fcmToken: fcmToken,
        imageUrl: currentUser!.photoURL ?? "");
    agoraUsersRef
        .doc(currentUser!.uid)
        .set(userModel.toMap(), SetOptions(merge: true));
  }

  static initiateCallRequest(AgoraUserModel e) {
    callRequestRef.add(CallRequestModel(
            timeStamp: DateTime.now(),
            from: currentUser!.uid,
            to: e.uid,
            status: CallStatus.initiated)
        .toMap());
  }

  static Future<CallRequestDetailsModel> fetchCallRequestDetails(
      CallRequestModel callRequestModel) async {
    final fromUser = await agoraUsersRef
        .doc(callRequestModel.from)
        .get()
        .then((value) => AgoraUserModel.fromMap(value.data()!));
    final toUser = await agoraUsersRef
        .doc(callRequestModel.to)
        .get()
        .then((value) => AgoraUserModel.fromMap(value.data()!));
    return CallRequestDetailsModel(
        from: fromUser, to: toUser, status: callRequestModel.status);
  }

  static void updateRequestStatus(CallRequestModel request) {
    callRequestRef
        .doc(request.docId)
        .set(request.toMap(), SetOptions(merge: true));
  }

  static Future<AgoraClient> getAgoraClient() async {
    return await clientDetailsRef
        .doc(appConfig.clientDetails)
        .get()
        .then((value) {
      Map<String, dynamic> data = value.data()!;
      String appId = data["appId"];
      String channelName = data["channel"];
      String tempToken = data["tempToken"];
      return AgoraClient(
        agoraConnectionData: AgoraConnectionData(
          appId: appId,
          channelName: channelName,
          tempToken: tempToken,
        ),
        enabledPermission: [
          Permission.camera,
          Permission.microphone,
        ],
      );
    });
  }
}
