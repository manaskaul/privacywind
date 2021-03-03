import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:privacywind/app_monitor/app_details.dart';
import 'package:privacywind/app_monitor/app_list.dart';

class AppMonitor extends StatefulWidget {
  @override
  _AppMonitorState createState() => _AppMonitorState();
}

class _AppMonitorState extends State<AppMonitor> {
  bool isServiceRunning = false;
  Map<bool, String> serviceStatus = {
    true: "Service is running",
    false: "Service is not running"
  };

  List<ApplicationWithIcon> watchList = [];

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
                  serviceStatus[isServiceRunning],
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ),
              Container(
                child: Switch(
                  value: isServiceRunning,
                  onChanged: (_) {
                    setState(() {
                      isServiceRunning = !isServiceRunning;
                    });
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
                        // color: Colors.black,
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
            onPressed: () async {
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
            },
          ),
        ),
      ],
    );
  }
}
