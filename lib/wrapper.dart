import 'package:device_apps/device_apps.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:privacywind/app_monitor/app_monitor.dart';
import 'package:privacywind/app_search/app_search.dart';
import 'package:privacywind/permission_manager/permission_manager.dart';

class Wrapper extends StatefulWidget {
  final List<ApplicationWithIcon> allApps;
  final AndroidDeviceInfo deviceInfo;

  Wrapper({Key key, this.allApps, this.deviceInfo}) : super(key: key);

  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  String page = "Permission Manager";

  @override
  Widget build(BuildContext context) {
    List<ApplicationWithIcon> allApps = widget.allApps;
    AndroidDeviceInfo deviceInfo = widget.deviceInfo;

    Map<String, Widget> pages = {
      "Permission Manager": PermissionManager(
        allApps: allApps,
        deviceInfo: deviceInfo,
      ),
      "App Search": AppSearch(),
      "App Monitor": AppMonitor(),
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(page),
        centerTitle: true,
      ),
      drawer: new Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName:
                  Text("${deviceInfo.manufacturer} ${deviceInfo.device}"),
              accountEmail: Text("Android ${deviceInfo.version.release}"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: Icon(
                  Icons.phone_iphone,
                  size: 75.0,
                  color: Colors.white,
                ),
              ),
            ),
            ListTile(
              title: Text("Permission Manager"),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  page = "Permission Manager";
                });
              },
            ),
            ListTile(
              title: Text("App Search"),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  page = "App Search";
                });
              },
            ),
            ListTile(
              title: Text("App Monitor"),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  page = "App Monitor";
                });
              },
            ),
          ],
        ),
      ),
      body: pages[page],
    );
  }
}
