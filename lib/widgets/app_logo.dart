
import 'package:flutter/material.dart';
import 'package:video_call_agora/exporter.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
            padding: const EdgeInsets.all(paddingLarge),
            width: 140,
            height: 140,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              "Agora",
              style: context.headlineLarge.copyWith(
                color: Colors.white,
              ),
            ));
  }
}
