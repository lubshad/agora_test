// ignore_for_file: use_build_context_synchronously

import 'package:agora_uikit/agora_uikit.dart';
import 'package:flutter/material.dart';
import 'package:video_call_agora/services/firestore_service.dart';
import 'package:video_call_agora/widgets/confirmation_dialog.dart';
import 'package:video_call_agora/widgets/error_widget_with_retry.dart';
import 'package:video_call_agora/widgets/network_resource.dart';

class VideoCallScreen extends StatefulWidget {
  static const String path = "/video-call-screen";

  const VideoCallScreen({Key? key}) : super(key: key);

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  late AgoraClient client;

  Future<AgoraClient>? future;

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  void dispose() {
    super.dispose();
    client.release();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        showConfirmationSheet();
      },
      child: Scaffold(
        body: NetworkResource(
          future,
          error: (exception) =>
              ErrorWidgetWithRetry(exception: exception, retry: getData),
          success: (client) => Stack(
            children: [
              AgoraVideoViewer(
                client: client,
              ),
              AgoraVideoButtons(
                client: client,
                enabledButtons: const [
                  BuiltInButtons.toggleMic,
                  BuiltInButtons.toggleCamera,
                  BuiltInButtons.callEnd,
                  BuiltInButtons.switchCamera,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showConfirmationSheet() async {
    final result = await showDialog(
        context: context,
        builder: (context) => const ConfirmationDialog(
            title: "Are you sure",
            description: "You are about to disconect from the call"));
    if (result != true) return;
    client.release();
    Navigator.pop(context);
  }

  void getData() async {
    setState(() {
      future = FirestoreService.getAgoraClient().then((value) async {
        client = value;
        await client.initialize();
        return client;
      });
    });
  }
}
