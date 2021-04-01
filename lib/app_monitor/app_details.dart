import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:privacywind/app_monitor/log_record_tile.dart';
import 'package:privacywind/app_monitor/record_model.dart';
import 'package:privacywind/constants/loading.dart';

class AppDetails extends StatefulWidget {
  final ApplicationWithIcon selectedApp;

  AppDetails({this.selectedApp});

  @override
  _AppDetailsState createState() => _AppDetailsState();
}

class _AppDetailsState extends State<AppDetails> with WidgetsBindingObserver {
  bool isServiceRunning = false;
  static const platform =
      const MethodChannel("com.example.test_permissions_app/permissions");

  bool isLoadingLogs = false;
  List<Record> allLogs = List();

  @override
  void initState() {
    super.initState();
    checkIsServiceRunning();
    getAllLogs();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      getAllLogs();
    }
  }

  checkIsServiceRunning() async {
    var res = await platform.invokeMethod("isServiceRunning");
    setState(() {
      isServiceRunning = res;
    });
  }

  getAllLogs() async {
    allLogs.clear();
    dynamic res = await platform.invokeMethod(
        "getAllLogsForApp", widget.selectedApp.appName);
    res.forEach((key, val) {
      allLogs.add(Record(
        appName: val["appName"],
        permissionUsed: val["permissionUsed"],
        permissionAllowed: val["permissionAllowed"] == "1",
        startTime: val["startTime"],
        endTime: val["endTime"],
      ));
    });
    setState(() {
      isLoadingLogs = false;
    });
  }

  clearAllLogs() async {
    await platform.invokeMethod("clearLogsForApp", widget.selectedApp.appName);
    setState(() {
      allLogs.clear();
    });
  }

  void handleClick(String value) {
    switch (value) {
      case 'Clear Logs':
        clearAllLogs();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("App Monitor"),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: handleClick,
            itemBuilder: (BuildContext context) {
              return {'Clear Logs'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, value) => [
          SliverToBoxAdapter(
            child: Container(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(15.0),
                    child: CircleAvatar(
                      backgroundImage: MemoryImage((widget.selectedApp).icon),
                      radius: 60.0,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 15.0, bottom: 5.0),
                    child: Text(
                      widget.selectedApp.appName,
                      style: TextStyle(
                        fontSize: 25.0,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(bottom: 15.0),
                    child: Text("Version: ${widget.selectedApp.versionName}"),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Divider(thickness: 2.0),
                  ),
                ],
              ),
            ),
          ),
        ],
        body: Column(
          children: [
            Expanded(
              child: isLoadingLogs
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Loading all logs..."),
                        Loading(),
                      ],
                    )
                  : allLogs.isEmpty
                      ? Center(child: Text("There are no Logs."))
                      : ListView.builder(
                          itemCount: allLogs.length,
                          itemBuilder: (context, index) {
                            return Container(
                              padding: const EdgeInsets.all(5.0),
                              child: Container(
                                color: allLogs[index].permissionAllowed
                                    ? Colors.transparent
                                    : Colors.red,
                                padding: const EdgeInsets.all(5.0),
                                child: LogRecordTile(
                                  permissionType: allLogs[index].permissionUsed,
                                  isPermissionAllowed:
                                      allLogs[index].permissionAllowed,
                                  startTime: allLogs[index].startTime,
                                  endTime: allLogs[index].endTime,
                                ),
                              ),
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
                  "Remove App",
                  style: TextStyle(fontSize: 20.0),
                ),
                onPressed: isServiceRunning
                    ? () => Navigator.pop(context, widget.selectedApp)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
