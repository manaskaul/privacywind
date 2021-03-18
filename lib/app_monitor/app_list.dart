import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:privacywind/constants/loading.dart';

class AppMonitorAppList extends StatefulWidget {
  final List<ApplicationWithIcon> watchListApps;

  AppMonitorAppList({this.watchListApps});

  @override
  _AppMonitorAppListState createState() => _AppMonitorAppListState();
}

class _AppMonitorAppListState extends State<AppMonitorAppList> {
  List<ApplicationWithIcon> allApps = [];

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      getInstalledApps();
    });
  }

  Future<void> getInstalledApps() async {
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
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("App Monitor"),
      ),
      body: Container(
        child: Center(
          child: allApps.length == 0
              ? Loading()
              : ListView.builder(
                  itemCount: allApps.length,
                  itemBuilder: (BuildContext context, int index) {
                    ApplicationWithIcon app = allApps[index];
                    return Column(
                      children: [
                        Container(
                          padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 0.0),
                          child: new ListTile(
                            title: Text(app.appName),
                            leading: CircleAvatar(
                              backgroundImage: MemoryImage(app.icon),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios_sharp,
                              size: 15.0,
                              // color: Colors.black,
                            ),
                            onTap: () {
                              var containsApp = widget.watchListApps.where(
                                  (element) =>
                                      element.packageName ==
                                      allApps[index].packageName);
                              if (containsApp.isNotEmpty) {
                                Scaffold.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        "This app is already in the watch list !"),
                                    action: SnackBarAction(
                                      label: "Okay",
                                      onPressed: () {},
                                    ),
                                  ),
                                );
                              } else {
                                Navigator.pop(context, allApps[index]);
                              }
                            },
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: Divider(thickness: 1.0),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ),
    );
  }
}
