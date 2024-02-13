import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:video_call_agora/constants.dart';
import 'package:video_call_agora/features/home_screen/home_mixin.dart';
import 'package:video_call_agora/features/home_screen/models/agora_user_model.dart';
import 'package:video_call_agora/services/firestore_service.dart';

import '../authentication/phone_or_google_auth/phone_or_google_auth_screen.dart';
import '../profile_screen/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  static const String path = "/home";

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with HomeMixin {
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
                .where((element) =>
                    element.uid != FirestoreService.currentUser?.uid)
                .toList();

            if (agoraUsers.isEmpty) {
              return const Center(child: Text("No Items Found"));
            }

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
}
