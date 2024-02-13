import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:video_call_agora/features/video_call_screen.dart';

import '../authentication/phone_or_google_auth/phone_or_google_auth_screen.dart';
import '../profile_screen/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  static const String path = "/home";

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.userChanges().listen((user) {
      if (user == null) {
        Navigator.pushReplacementNamed(context, PhoneOrGoogleSignin.path);
      } else {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: const ProfileScreen(),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: navigateToVideoCallingScreen,
          label: const Text("Start Video Call")),
    );
  }

  void navigateToVideoCallingScreen() {
    Navigator.pushNamed(context, VideoCallScreen.path);
  }
}
