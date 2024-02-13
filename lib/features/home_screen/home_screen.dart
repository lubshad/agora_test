import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:get/utils.dart';
import 'package:video_call_agora/constants.dart';
import 'package:video_call_agora/core/logger.dart';
import 'package:video_call_agora/features/home_screen/models/agora_user_model.dart';
import 'package:video_call_agora/features/home_screen/models/call_request_model.dart';
import 'package:video_call_agora/features/video_call_screen/video_call_screen.dart';
import 'package:video_call_agora/main.dart';
import 'package:video_call_agora/services/firestore_service.dart';

import '../authentication/phone_or_google_auth/phone_or_google_auth_screen.dart';
import '../profile_screen/profile_screen.dart';
import 'widgets/call_initiated_sheet.dart';
import 'widgets/call_rejected_sheet.dart';

class HomeScreen extends StatefulWidget {
  static const String path = "/home";

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? listenStream;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.userChanges().listen((user) {
      if (user == null) {
        Navigator.pushReplacementNamed(context, PhoneOrGoogleSignin.path);
      } else {}
    });
    FirestoreService.updateUserDetails();
    listenForCallRequests();
  }

  @override
  void dispose() {
    super.dispose();
    listenStream?.cancel();
    listenStream = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contacts"),
      ),
      drawer: const ProfileScreen(),
      body: StreamBuilder(
        stream: FirestoreService.userStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          } else {
            List<AgoraUserModel> agoraUsers = snapshot.data!.docs
                .map((e) => AgoraUserModel.fromMap(e.data()))
                .toList();

            return ListView(
                padding: const EdgeInsets.all(
                  paddingLarge,
                ),
                children: agoraUsers
                    .map((e) => ListTile(
                          onTap: () => FirestoreService.initiateCallRequest(e),
                          trailing: const Icon(Icons.call),
                          leading: CircleAvatar(
                            backgroundImage: CachedNetworkImageProvider(
                              e.imageUrl,
                            ),
                          ),
                          title: Text(e.name),
                          subtitle: Text(e.email),
                        ))
                    .toList());
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: navigateToVideoCallingScreen,
          label: const Text("Start Video Call")),
    );
  }

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
    showModalBottomSheet(
      context: context,
      builder: (context) => const CallRejectedSheet(),
    );
  }

  void showCallInitiatedSheet(CallRequestModel newRequest) async {
    final result = await showModalBottomSheet<CallStatus>(
      enableDrag: false,
      isDismissible: false,
      context: context,
      builder: (context) => CallInitiatedSheet(requestModel: newRequest),
    );
    if (result == null) return;
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
