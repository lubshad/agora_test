import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:video_call_agora/features/authentication/phone_or_google_auth/google_oauth_mixin.dart';

import '../../core/app_config.dart';
import '../../exporter.dart';
import '../../main.dart';
import '../../services/shared_preferences_services.dart';
import '../../widgets/loading_button.dart';
import '../authentication/phone_or_google_auth/phone_or_google_auth_screen.dart';
import '../web_view/web_view_screen.dart';
import 'profile_details_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<ProfileDetailsModel>? future;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    // future = DataRepository.i.fetchProfileDetails();
    packageInfo = await PackageInfo.fromPlatform();
    setState(() {});
  }

  User? get user => FirebaseAuth.instance.currentUser;

  PackageInfo? packageInfo;
  @override
  Widget build(BuildContext context) {
    return Drawer(
      // width: double.infinity,
      child: Center(
          child: Padding(
        padding: const EdgeInsets.all(paddingLarge),
        child: Column(
          children: [
            DrawerHeader(
                child: ListTile(
              leading: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(
                  user?.photoURL ?? "",
                ),
              ),
              title: Text(user?.displayName ?? ""),
              subtitle: Text(user?.email ?? ""),
            )),
            const Spacer(),
            LoadingButton(
                buttonLoading: false,
                text: "LOGOUT",
                onPressed: () => signOut(context)),
            if (packageInfo != null)
              Padding(
                  padding: const EdgeInsets.only(
                    bottom: paddingXL,
                    top: paddingXL,
                  ),
                  child: Text("Version : ${packageInfo!.version}"))
          ],
        ),
      )),
    );
  }
}

void showRefundPolicy() {
  Navigator.pushNamed(
      navigatorKey.currentContext!,
      Uri(path: WebViewScreen.path, queryParameters: {
        "title": "Refund Policy",
        "url": appConfig.baseUrl + appConfig.refundPolicy
      }).toString());
}

void showTermsAndConditions() {
  Navigator.pushNamed(
      navigatorKey.currentContext!,
      Uri(path: WebViewScreen.path, queryParameters: {
        "title": "Terms & Conditions",
        "url": appConfig.baseUrl + appConfig.termsAndConditions
      }).toString());
}

void showPrivacyPolicy() {
  Navigator.pushNamed(
      navigatorKey.currentContext!,
      Uri(path: WebViewScreen.path, queryParameters: {
        "title": "Privacy Policy",
        "url": appConfig.baseUrl + appConfig.privacyPolicy
      }).toString());
}

void signOut(context) {
  SharedPreferencesService.i.setValue(value: "");
  FirebaseAuth.instance.signOut();
  GoogleOauthMixin.signOut();
  Navigator.pushNamedAndRemoveUntil(
      context, PhoneOrGoogleSignin.path, (route) => false);
}
