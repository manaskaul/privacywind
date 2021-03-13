import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // TODO : Show custom dialog to turn on accessibility for the app
  /*
    show custom dialog box
    if user agrees then open accessibility settings
    if not then close the application
  */

  @override
  void initState() {
    super.initState();
    checkAccessibilityEnabled();
    checkServiceEnabled();
  }

  checkAccessibilityEnabled() async {
    dynamic val = await platform.invokeMethod("checkAccessibilityEnabled");
    if (!val) {
      showAccessibilityDialogBox();
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
  
  checkServiceEnabled() async {
    dynamic val = await platform.invokeMethod("isServiceRunning");
      setState(() {
        serviceStatusSwitch = val;
      });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkAccessibilityEnabled();
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
                    if (serviceStatusSwitch) {
                      stopService();
                    } else {
                      startService();
                    }
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
                        setState(() {
                          appToRemove != null
                              ? watchList.remove(watchList[index])
                              : debugPrint("Go Back");
                        });
                      },
                    );
                  },
                ),
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 15.0),
          height: MediaQuery.of(context).size.height * 0.10,
          width: MediaQuery.of(context).size.width * 0.85,
          child: ElevatedButton(
            child: Text(
              "Add App",
              style: TextStyle(fontSize: 20.0),
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
                    setState(() {
                      appToAdd != null
                          ? watchList.add(appToAdd)
                          : debugPrint("No apps selected");
                    });
                  }
                : null,
          ),
        ),
      ],
    );
  }

  startService() async {
    dynamic val = await platform.invokeMethod("startMonitorService");
    debugPrint("got START val $val");
    setState(() {
      serviceStatusSwitch = val;
    });
  }

  stopService() async {
    dynamic val = await platform.invokeMethod("stopMonitorService");
    debugPrint("got STOP val $val");
    setState(() {
      serviceStatusSwitch = val;
    });
  }
}
