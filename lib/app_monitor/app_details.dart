import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:privacywind/app_monitor/log_record_tile.dart';
import 'package:privacywind/app_monitor/record_model.dart';
import 'package:privacywind/constants/loading.dart';
import 'package:privacywind/constants/permissions_icon_data.dart';

class AppDetails extends StatefulWidget {
  final ApplicationWithIcon selectedApp;

  AppDetails({this.selectedApp});

  @override
  _AppDetailsState createState() => _AppDetailsState();
}

class _AppDetailsState extends State<AppDetails> {
  bool isServiceRunning = false;
  static const platform =
      const MethodChannel("com.example.test_permissions_app/permissions");

  bool isLoadingLogs = false;

  // List<Record> allLogs = List();
  List<Record> allLogs = [
    Record(
      appName: "Instagram",
      permissionUsed: "Camera",
      permissionAllowed: true,
      startTime: "07:55 PM 31/03/2021",
      endTime: "07:55 PM 31/03/2021",
    ),
    Record(
      appName: "Instagram",
      permissionUsed: "Microphone",
      permissionAllowed: true,
      startTime: "09:19 PM 31/03/2021",
      endTime: "09:20 PM 31/03/2021",
    ),
    Record(
      appName: "Instagram",
      permissionUsed: "Microphone",
      permissionAllowed: true,
      startTime: "09:22 PM 31-03-2021",
      endTime: "09:22 PM 31-03-2021",
    )
  ];

  @override
  void initState() {
    super.initState();
    checkIsServiceRunning();
    // getAllLogs();
  }

  checkIsServiceRunning() async {
    var res = await platform.invokeMethod("isServiceRunning");
    setState(() {
      isServiceRunning = res;
    });
  }

/*
  getAllLogs() async {
    List<dynamic> res =
        await platform.invokeMethod("getAllLogs", widget.selectedApp.appName);
    for (int i = 0; i < res.length; i++) {
      allLogs.add(Record(
        appName: res[i]["appName"],
        permissionUsed: res[i]["permissionUsed"],
        permissionAllowed: res[i]["permissionAllowed"] == 1,
        startTime: res[i]["startTime"],
        endTime: res[i]["endTime"],
      ));
    }
    setState(() {
      isLoadingLogs = false;
    });
  }
*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("App Monitor"),
        centerTitle: true,
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
                      ? Center(
                          child: Text("There are no Logs."),
                        )
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
