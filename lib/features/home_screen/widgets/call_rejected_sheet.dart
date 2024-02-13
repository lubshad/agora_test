import 'package:flutter/material.dart';
import 'package:get/utils.dart';
import 'package:lottie/lottie.dart';
import 'package:video_call_agora/gen/assets.gen.dart';

class CallRejectedSheet extends StatelessWidget {
  const CallRejectedSheet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Row(),
        SizedBox(
          height: context.width * .5,
          child: AspectRatio(
              aspectRatio: 1, child: Lottie.asset(Assets.lotties.warning)),
        ),
        const Text("Call Rejected.")
      ],
    );
  }
}
