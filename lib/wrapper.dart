import 'package:device_apps/device_apps.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  static const platform =
      const MethodChannel("com.example.test_permissions_app/permissions");

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

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

    shareAllLogs() async {
      var res = await platform.invokeMethod("shareAllLogs");
      String val;
      if (res) {
        val = "Logs successfully shared.";
      } else {
        val = "Error in sharing logs.";
      }

      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(val),
          action: SnackBarAction(
            label: "Okay",
            onPressed: () {},
          ),
        ),
      );
    }

    clearAllLogs() async {
      await platform.invokeMethod("clearAllLogs");

      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text("All logs have been cleared."),
          action: SnackBarAction(
            label: "Okay",
            onPressed: () {},
          ),
        ),
      );
    }

    void handleClick(String value) {
      switch (value) {
        case "Share all Logs":
          shareAllLogs();
          break;
        case "Clear all Logs":
          clearAllLogs();
          break;
      }
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(page),
        actions: page == "App Monitor"
            ? [
                PopupMenuButton<String>(
                  onSelected: handleClick,
                  itemBuilder: (BuildContext context) {
                    return {
                      "Share all Logs",
                      "Clear all Logs",
                    }.map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                      );
                    }).toList();
                  },
                ),
              ]
            : null,
      ),
      drawer: new Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                "${deviceInfo.manufacturer} ${deviceInfo.device}",
                style: TextStyle(color: Colors.white),
              ),
              accountEmail: Text(
                "Android ${deviceInfo.version.release}",
                style: TextStyle(color: Colors.white),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.lightBlue[700],
                child: Icon(
                  Icons.phone_iphone,
                  size: 75.0,
                  color: Colors.white,
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.lightBlue[700],
              ),
            ),
            Container(
              color: page == "Permission Manager"
                  ? getDrawerItemColor()
                  : Theme.of(context).canvasColor,
              child: ListTile(
                title: Text(
                  "Permission Manager",
                  style: TextStyle(fontSize: 16.0),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    page = "Permission Manager";
                  });
                },
              ),
            ),
            Container(
              color: page == "App Search"
                  ? getDrawerItemColor()
                  : Theme.of(context).canvasColor,
              child: ListTile(
                title: Text(
                  "App Search",
                  style: TextStyle(fontSize: 16.0),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    page = "App Search";
                  });
                },
              ),
            ),
            Container(
              color: page == "App Monitor"
                  ? getDrawerItemColor()
                  : Theme.of(context).canvasColor,
              child: ListTile(
                title: Text(
                  "App Monitor",
                  style: TextStyle(fontSize: 16.0),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    page = "App Monitor";
                  });
                },
              ),
            ),
          ],
        ),
      ),
      body: pages[page],
    );
  }

  getDrawerItemColor() {
    if (MediaQuery.of(context).platformBrightness == Brightness.light) {
      return Colors.grey[300];
    } else {
      return Colors.grey[700];
    }
  }
}
