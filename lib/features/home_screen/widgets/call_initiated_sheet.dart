import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:get/utils.dart';
import 'package:video_call_agora/constants.dart';
import 'package:video_call_agora/features/home_screen/models/call_request_details_model.dart';
import 'package:video_call_agora/features/home_screen/widgets/call_action_button.dart';
import 'package:video_call_agora/services/firestore_service.dart';
import 'package:video_call_agora/theme/theme.dart';
import 'package:video_call_agora/widgets/error_widget_with_retry.dart';
import 'package:video_call_agora/widgets/network_resource.dart';

import '../models/agora_user_model.dart';
import '../models/call_request_model.dart';

class CallInitiatedSheet extends StatefulWidget {
  const CallInitiatedSheet({
    super.key,
    required this.requestModel,
  });

  final CallRequestModel requestModel;

  @override
  State<CallInitiatedSheet> createState() => _CallInitiatedSheetState();
}

class _CallInitiatedSheetState extends State<CallInitiatedSheet> {
  Future<CallRequestDetailsModel>? future;

  @override
  void initState() {
    super.initState();
    getData();
    startRingtone();
  }

  @override
  void dispose() {
    super.dispose();
    FlutterRingtonePlayer.stop();
  }

  AgoraUserModel getUser(CallRequestDetailsModel callRequestDetailsModel) {
    if (isOutgoing) {
      return callRequestDetailsModel.to;
    } else {
      return callRequestDetailsModel.from;
    }
  }

  void getData() {
    setState(() {
      future = FirestoreService.fetchCallRequestDetails(widget.requestModel);
    });
  }

  bool get isOutgoing {
    return FirestoreService.currentUser?.uid == widget.requestModel.from;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Container(
        padding: const EdgeInsets.all(paddingLarge),
        child: NetworkResource(
          future,
          error: (exception) =>
              ErrorWidgetWithRetry(exception: exception, retry: getData),
          success: (details) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Row(),
                Text(
                  "Calling..",
                  style: context.titleLarge,
                ),
                Builder(builder: (context) {
                  return Column(
                    children: [
                      CircleAvatar(
                        radius: context.width * .1,
                        backgroundImage: CachedNetworkImageProvider(
                            getUser(details).imageUrl),
                      ),
                      gapLarge,
                      Text(
                        getUser(details).name,
                        style: context.titleLarge,
                      ),
                    ],
                  );
                }),
                Builder(builder: (context) {
                  if (isOutgoing) {
                    return CallActionButton(
                        onTap: () =>
                            Navigator.pop(context, CallStatus.rejected),
                        text: "Cancel",
                        icon: Icons.call_end,
                        color: Colors.red);
                  }
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CallActionButton(
                          onTap: () =>
                              Navigator.pop(context, CallStatus.accepted),
                          text: "Accept",
                          icon: Icons.call,
                          color: Colors.green),
                      CallActionButton(
                        onTap: () =>
                            Navigator.pop(context, CallStatus.rejected),
                        text: "Reject",
                        icon: Icons.call_end,
                        color: Colors.red,
                      ),
                    ],
                  );
                })
              ],
            );
          },
        ),
      ),
    );
  }

  void startRingtone() {
    if (isOutgoing) return;
    FlutterRingtonePlayer.playRingtone();
  }
}
