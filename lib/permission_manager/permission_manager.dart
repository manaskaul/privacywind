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
    return Container(
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
    );
  }
}