import 'dart:io';

import 'package:device_apps/device_apps.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:privacywind/constants/loading.dart';
import 'package:privacywind/wrapper.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final String fontFam = "Lato";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: fontFam,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: fontFam,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const platform =
      const MethodChannel("com.example.test_permissions_app/permissions");

  List<ApplicationWithIcon> allApps = [];
  AndroidDeviceInfo deviceInfo;

  bool hasUserSeenOnBoarding = true;

  @override
  void initState() {
    super.initState();
    checkShowOnboarding();
    // SchedulerBinding.instance.addPostFrameCallback((_) {
    //   checkShowOnboarding();
    // });
  }

  checkShowOnboarding() async {
    var seenOnboarding = await getUserOnboardingInfo();
    if (!seenOnboarding) {
      setState(() {
        hasUserSeenOnBoarding = seenOnboarding;
      });
    } else {
      getDeviceInfo();
      getInstalledApps();
    }
  }

  getUserOnboardingInfo() async {
    var res = await platform.invokeMethod("getUserOnboardingInfo");
    return res;
  }

  setUserOnboardingInfo() async {
    await platform.invokeMethod("setUserOnboardingInfo");
    setState(() {
      hasUserSeenOnBoarding = true;
      checkShowOnboarding();
    });
  }

  getDeviceInfo() async {
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      deviceInfo = await deviceInfoPlugin.androidInfo;
    }
  }

  getInstalledApps() async {
    await DeviceApps.getInstalledApplications(
      includeAppIcons: true,
      includeSystemApps: true,
      onlyAppsWithLaunchIntent: true,
    ).then((value) {
      for (int i = 0; i < value.length; i++) {
        allApps.add(value[i] as ApplicationWithIcon);
      }
    });
    allApps.sort(
        (x, y) => x.appName.toLowerCase().compareTo(y.appName.toLowerCase()));

    new Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Wrapper(
            allApps: allApps,
            deviceInfo: deviceInfo,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (hasUserSeenOnBoarding) {
      return Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: Text(
                "PrivacyWind",
                style: TextStyle(
                  fontSize: 25.0,
                ),
              ),
            ),
            Loading(),
          ],
        ),
      );
    } else {
      return SafeArea(
        child: onboardingScreen(),
      );
    }
  }

  void onIntroEnd(context) {
    setUserOnboardingInfo();
  }

  static const bodyStyle = TextStyle(fontSize: 19.0);
  static const pageDecoration = PageDecoration(
    titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
    bodyTextStyle: bodyStyle,
    descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
    imagePadding: EdgeInsets.zero,
  );

  onboardingScreen() {
    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: "PrivacyWind",
          body:
              "Privacy centered app to monitor and keep track of permissions accessed by third-party android apps.",
          image: Icon(
            Icons.android,
            size: 100.0,
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Permission Manager",
          body: "Keep track of all the permissions used by the installed apps",
          image: Icon(
            Icons.format_list_bulleted_outlined,
            size: 100.0,
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "App Search",
          body:
              "Search apps and check the permissions required by the application before you install it.",
          image: Icon(
            Icons.search_outlined,
            size: 100.0,
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "App Monitor",
          body:
              "Monitor the behaviour of installed apps by keeping track of permissions accessed by the apps.",
          image: Icon(
            Icons.widgets_rounded,
            size: 100.0,
          ),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => onIntroEnd(context),
      onSkip: () => onIntroEnd(context),
      showSkipButton: true,
      skipFlex: 0,
      nextFlex: 0,
      skip: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600)),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        activeSize: Size(20.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }
}
