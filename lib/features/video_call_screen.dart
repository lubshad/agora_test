import 'package:agora_uikit/agora_uikit.dart';
import 'package:flutter/material.dart';

class VideoCallScreen extends StatefulWidget {
  static const String path = "/video-call-screen";

  const VideoCallScreen({Key? key}) : super(key: key);

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final AgoraClient client = AgoraClient(
    agoraConnectionData: AgoraConnectionData(
      appId: "d3a126be4f8940f38282b9fa2f2e0860",
      channelName: "test",
      tempToken:
          "007eJxTYGCsMd32+jZXhZFrbmwzRzNP/a9l2ccvWl2LXXYpyc/X75gCQ4pxoqGRWVKqSZqFpYlBmrGFkYVRkmVaolGaUaqBhZlBMN/p1IZARgaJjhomRgYIBPFZGEpSi0sYGAD7Wh4S",
    ),
    enabledPermission: [
      Permission.camera,
      Permission.microphone,
    ],
  );

  void initAgora() async {
    await client.initialize();
  }

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AgoraVideoViewer(client: client),
          AgoraVideoButtons(client: client),
        ],
      ),
    );
  }
}
