import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video_call_agora/widgets/app_logo.dart';
import '../../../widgets/loading_button.dart';
import '../phone_or_google_auth/phone_or_google_auth_screen.dart';
import '../../../exporter.dart';

class LandingPage extends StatefulWidget {
  static const String path = "/landing-page";

  const LandingPage({
    super.key,
  });

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  late AnimationController controller;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // const Align(
            //   alignment: Alignment.centerLeft,
            //   child: SizedBox(
            //       width: 100,
            //       child: AspectRatio(aspectRatio: 3, child: AppLogo())),
            // ),
            const Spacer(),
            const SizedBox(
                    width: 200,
                    child: AspectRatio(aspectRatio: 1, child: AppLogo()))
                .animate()
                .scaleXY(curve: Curves.fastOutSlowIn, begin: .8, end: 1),
            gapLarge,
            Text(
              'Crystal-clear video calls\nanytime, anywhere.',
              style: context.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            Text(
              "Create  an account or login",
              style: context.labelLarge,
              textAlign: TextAlign.center,
            ),
            gapLarge,
            LoadingButton(
              onPressed: () {
                Navigator.pushNamed(context, PhoneOrGoogleSignin.path);
              },
              text: ('Get Started'),
              buttonLoading: false,
            ),
          ],
        ),
      ),
    ));
  }
}
