import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:privacywind/app_monitor/allow_accessibility_dialog.dart';
import 'package:privacywind/app_monitor/app_details.dart';
import 'package:privacywind/app_monitor/app_list.dart';

class AppMonitor extends StatefulWidget {
  @override
  _AppMonitorState createState() => _AppMonitorState();
}

class _AppMonitorState extends State<AppMonitor> with WidgetsBindingObserver {
  static const platform =
      const MethodChannel("com.example.test_permissions_app/permissions");

  bool serviceStatusSwitch = false;
  Map<bool, String> serviceStatus = {
    true: "Service is running",
    false: "Service is not running"
  };

  List<ApplicationWithIcon> watchList = [];

  @override
  void initState() {
    super.initState();
    checkAccessibilityEnabled();
    setSharedPref();
    clearOldLogs();
    shareLogs();
  }

  shareLogs() async {
    await platform.invokeMethod("shareAllLogs");
  }

  checkAccessibilityEnabled() async {
    dynamic accessibilityEnabled =
        await platform.invokeMethod("checkAccessibilityEnabled");
    dynamic showDialog =
        await platform.invokeMethod("getAccessibilityInfoDialogSeen");
    setState(() {
      serviceStatusSwitch = accessibilityEnabled;
    });
    if (!accessibilityEnabled && showDialog) {
      showAccessibilityDialogBox();
      initializeWatchList();
    } else {
      showLocationStatus();
    }
  }

  showAccessibilityDialogBox() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AccessibilityDialogBox();
      },
    );
  }

  showLocationStatus() async {
    var locationStatus = await Permission.location.status;
    if (!locationStatus.isGranted) {
      Permission.location.request();
    }
  }

  clearOldLogs() {
    platform.invokeMethod("clearOldLogs");
  }

  initializeWatchList() async {
    debugPrint("initlizeList");
    var res = await platform.invokeMethod("getAppWatchList");
    if (res.isNotEmpty) {
      watchList.clear();
      for (String packageName in res) {
        await DeviceApps.getApp(packageName).then((value) {
          ApplicationWithIcon app = value as ApplicationWithIcon;
          watchList.add(app);
        });
      }
    } else {
      List<ApplicationWithIcon> allApps = [];
      List<String> allAppString = [];
      await DeviceApps.getInstalledApplications(
        includeAppIcons: true,
        includeSystemApps: true,
        onlyAppsWithLaunchIntent: true,
      ).then((value) {
        for (int i = 0; i < value.length; i++) {
          allApps.add(value[i] as ApplicationWithIcon);
          allAppString.add(allApps[i].packageName);
        }
      });
      allApps.sort(
          (x, y) => x.appName.toLowerCase().compareTo(y.appName.toLowerCase()));
      watchList.addAll(allApps);
      await platform.invokeMethod("addAppListToWatchList", allAppString);
    }
    if (mounted) {
      setState(() {});
    }
  }

  addAppToWatchList(String packageName) async {
    await platform.invokeMethod("addAppToWatchList", packageName);
  }

  getWatchList() async {
    debugPrint("get watch List");
    var res = await platform.invokeMethod("getAppWatchList");
    if (res.isNotEmpty) {
      debugPrint("res => ${res.toString()}");
      watchList.clear();
      for (String packageName in res) {
        await DeviceApps.getApp(packageName).then((value) {
          ApplicationWithIcon app = value as ApplicationWithIcon;
          watchList.add(app);
        });
      }
      watchList.sort((x, y) => x.appName.toLowerCase().compareTo(y.appName.toLowerCase()));
    }
    if (mounted) {
      setState(() {});
    }
  }

  removeAppFromWatchList(String packageName) async {
    var res =
        await platform.invokeMethod("removeAppFromWatchList", packageName);
    debugPrint(res);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addObserver(this);
    getWatchList();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkAccessibilityEnabled();
      setSharedPref();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Text(
                  serviceStatus[serviceStatusSwitch],
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ),
              Container(
                child: Switch(
                  value: serviceStatusSwitch,
                  onChanged: (_) async {
                    switchServiceOnOff();
                  },
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 15.0),
          child: Text(
            "Watchlist",
            style: TextStyle(fontSize: 15.0),
          ),
          alignment: Alignment.topLeft,
        ),
        Expanded(
          child: watchList.isEmpty
              ? Center(child: Text("There are no apps in the watch list"))
              : ListView.builder(
                  itemCount: watchList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(watchList[index].appName),
                      leading: CircleAvatar(
                        backgroundImage: MemoryImage(watchList[index].icon),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios_sharp,
                        size: 15.0,
                      ),
                      onTap: () async {
                        var appToRemove = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AppDetails(
                              selectedApp: watchList[index],
                            ),
                          ),
                        );
                        if (appToRemove != null) {
                          await removeAppFromWatchList(
                              appToRemove.packageName.toString());
                          setState(() {
                            watchList.remove(appToRemove);
                          });
                        }
                      },
                    );
                  },
                ),
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 15.0),
          height: MediaQuery.of(context).size.height * 0.10,
          width: MediaQuery.of(context).size.width * 0.85,
          child: RaisedButton(
            child: Text(
              "Add App",
              style: TextStyle(
                fontSize: 20.0,
                color: getTextColor(),
              ),
            ),
            onPressed: serviceStatusSwitch
                ? () async {
                    var appToAdd = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AppMonitorAppList(
                          watchListApps: watchList,
                        ),
                      ),
                    );
                    if (appToAdd != null) {
                      await addAppToWatchList(appToAdd.packageName.toString());
                      setState(() {
                        watchList.add(appToAdd);
                        watchList.sort((x, y) => x.appName.toLowerCase().compareTo(y.appName.toLowerCase()));
                      });
                    }
                  }
                : null,
          ),
        ),
      ],
    );
  }

  getTextColor() {
    return serviceStatusSwitch
        ? Colors.white
        : MediaQuery.of(context).platformBrightness == Brightness.light
            ? Colors.grey[700]
            : Colors.grey[400];
  }

  switchServiceOnOff() async {
    await platform.invokeMethod("openAccessibilitySettings");
  }

  setSharedPref() {
    platform.invokeMethod("setSharedPref");
  }
}
