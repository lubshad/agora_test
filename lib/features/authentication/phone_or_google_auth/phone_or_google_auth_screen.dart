// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pinput/pinput.dart';
import 'package:video_call_agora/features/authentication/phone_or_google_auth/google_oauth_mixin.dart';
import 'package:video_call_agora/widgets/app_logo.dart';
import '../../../exporter.dart';
import '../../../widgets/loading_button.dart';
import '../../profile_screen/profile_screen.dart';
import 'firebase_phone_auth_mixin.dart';

class PhoneOrGoogleSignin extends StatefulWidget {
  static const String path = "/phone-verification";

  const PhoneOrGoogleSignin({super.key});

  @override
  State<PhoneOrGoogleSignin> createState() => _PhoneOrGoogleSigninState();
}

class _PhoneOrGoogleSigninState extends State<PhoneOrGoogleSignin>
    with FirebasePhoneAuthMixin, GoogleOauthMixin {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        if (pageController.page == 1) {
          pageController.previousPage(
              duration: animationDuration, curve: Curves.fastOutSlowIn);
        } else if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          SystemNavigator.pop(animated: true);
        }
      },
      child: Scaffold(
          appBar: AppBar(),
          body: SafeArea(
            child: Builder(builder: (context) {
              return PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: pageController,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(paddingXL),
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Spacer(),
                            const AppLogo(),
                            // Row(
                            //   children: [
                            //     CountryCodePicker(
                            //       onChanged: onCountryChanged,
                            //       initialSelection: selectedCountry.name,
                            //     ),
                            //     Expanded(
                            //       child: TextFormField(
                            //         inputFormatters: [
                            //           FilteringTextInputFormatter.digitsOnly,
                            //           LengthLimitingTextInputFormatter(10),
                            //         ],
                            //         keyboardType: TextInputType.number,
                            //         autofillHints: const [
                            //           AutofillHints.telephoneNumber
                            //         ],
                            //         validator: validatePhone,
                            //         controller: phoneController,
                            //         decoration: InputDecoration(
                            //           contentPadding: EdgeInsets.zero,
                            //           hintText: "Enter Phone Number",
                            //           errorText: phoneErrorText,
                            //         ),
                            //       ),
                            //     ),
                            //   ],
                            // ),
                            const Spacer(),
                            RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(children: [
                                  WidgetSpan(
                                    child: Text(
                                      "By continuing, you agree  to our ",
                                      style: context.labelLarge,
                                    ),
                                  ),
                                  const WidgetSpan(
                                    child: InkWell(
                                      onTap: showTermsAndConditions,
                                      child: Text(
                                        "Terms of Uses",
                                      ),
                                    ),
                                  ),
                                  const WidgetSpan(
                                    child: Text(
                                      " & ",
                                    ),
                                  ),
                                  const WidgetSpan(
                                    child: InkWell(
                                      onTap: showPrivacyPolicy,
                                      child: Text(
                                        "Privacy Policy",
                                      ),
                                    ),
                                  ),
                                ])),
                            // gapLarge,
                            // LoadingButton(
                            //   buttonLoading: buttonLoading,
                            //   onPressed: sendOtp,
                            //   text: 'Next',
                            // ),
                            gapLarge,
                            IgnorePointer(
                              ignoring: buttonLoading,
                              child: ElevatedButton(
                                onPressed: signInWithGoogle,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      Assets.svgs.icons8Google,
                                      height: paddingXL,
                                    ),
                                    gapLarge,
                                    const Text("Sign In With Google")
                                  ],
                                ),
                              ),
                            ),
                            // LoadingButton(
                            //   buttonLoading: buttonLoading,
                            //   onPressed: signInWithGoogle,
                            //   text: 'Google Sign In',
                            // ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(paddingXL),
                      child: Form(
                        key: pinformKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Spacer(),
                            Pinput(
                              autofocus: true,
                              forceErrorState: otpErrorText != null,
                              errorText: otpErrorText,
                              controller: pincodeController,
                              length: otpLenth,
                              validator: pinValidation,
                            ),
                            if (isTimeOut)
                              IconButton(
                                icon: SvgPicture.asset(Assets.svgs.retry),
                                onPressed: resendOtp,
                              ),
                            const Spacer(),
                            RichText(
                              text: TextSpan(children: [
                                WidgetSpan(
                                    child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Change ",
                                      style: context.labelLarge,
                                    ),
                                    TextButton(
                                        style: shrinkedButton,
                                        onPressed: () =>
                                            pageController.animateToPage(0,
                                                duration: animationDuration,
                                                curve: Curves.fastOutSlowIn),
                                        child: Text(phoneNumber)),
                                  ],
                                )),
                                WidgetSpan(
                                    child: AnimatedBuilder(
                                        animation: stopwatchValue,
                                        builder: (context, child) {
                                          return Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              TextButton(
                                                  onPressed: isTimeOut
                                                      ? resendOtp
                                                      : null,
                                                  style: shrinkedButton,
                                                  child: const Text(
                                                      "Resend OTP ")),
                                              if (!isTimeOut)
                                                Text(
                                                    "in $timeRemaining seconds",
                                                    style: context.labelLarge),
                                            ],
                                          );
                                        })),
                              ]),
                            ),
                            gapXL,
                            LoadingButton(
                                buttonLoading: buttonLoading,
                                text: "Validate",
                                onPressed: validateOtp)
                          ],
                        ),
                      ),
                    ),
                  ]);
            }),
          )),
    );
  }
}
