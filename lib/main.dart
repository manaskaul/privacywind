import 'dart:io';

import 'package:device_apps/device_apps.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:privacywind/constants/loading.dart';
import 'package:privacywind/wrapper.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  String fontFam = "Lato";

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
  List<ApplicationWithIcon> allApps = [];
  AndroidDeviceInfo deviceInfo;

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      getDeviceInfo();
      getInstalledApps();
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
  }
}
