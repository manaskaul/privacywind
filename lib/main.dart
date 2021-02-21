import 'dart:io';

import 'package:device_apps/device_apps.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:privacywind/constants/loading.dart';
import 'package:privacywind/permission_manager/permission_manager.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
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
      // debugPrint("${deviceInfo.model} \n ${deviceInfo.version.release}");
    }
  }

  getInstalledApps() async {
    await DeviceApps.getInstalledApplications(
      includeAppIcons: true,
      includeSystemApps: false,
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
          builder: (context) => PermissionManager(
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
