import 'package:device_apps/device_apps.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'permission_list.dart';

class PermissionManager extends StatelessWidget {
  final List<ApplicationWithIcon> allApps;
  final AndroidDeviceInfo deviceInfo;

  PermissionManager({Key key, this.allApps, this.deviceInfo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Privacy Manager"),
      ),
      drawer: new Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(deviceInfo.model),
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
              },
            ),
            ListTile(
              title: Text("App Search"),
              // TODO : OPEN APP SEARCH PAGE
              onTap: () async {
                debugPrint("OPEN APP SEARCH PAGE");
              },
            ),
            ListTile(
              title: Text("App Monitor"),
              onTap: () {
                // TODO : OPEN APP MONITOR PAGE
                debugPrint("OPEN APP MONITOR PAGE");
              },
            ),
          ],
        ),
      ),
      body: Container(
        child: ListView.builder(
          itemCount: allApps.length,
          itemBuilder: (BuildContext context, int index) {
            ApplicationWithIcon app = allApps[index];
            return Column(
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 0.0),
                  child: new ListTile(
                    title: Text(app.appName),
                    // subtitle: Text(app.versionName),
                    leading: CircleAvatar(
                      backgroundImage: MemoryImage(app.icon),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios_sharp,
                      size: 15.0,
                      // color: Colors.black,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PermissionList(),
                          settings: RouteSettings(
                            arguments: allApps[index].packageName,
                          ),
                        ),
                      );
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
    );
  }
}
