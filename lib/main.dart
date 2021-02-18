import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ApplicationWithIcon> allApps = [];

  @override
  void initState() {
    super.initState();
    getInstalledApps();
  }

  getInstalledApps() async {
    await DeviceApps.getInstalledApplications(
      includeAppIcons: true,
      includeSystemApps: false,
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
        centerTitle: true,
        title: Text("Android Privacy"),
      ),
      body: Container(
        alignment: Alignment.center,
        child: allApps != null
            ? ListView.builder(
          itemCount: allApps.length,
          itemBuilder: (BuildContext context, int index) {
            ApplicationWithIcon app = allApps[index];
            return new ListTile(
              title: Text(app.appName),
              subtitle: Text(app.versionName),
              leading: CircleAvatar(
                backgroundImage: MemoryImage(app.icon),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios_sharp,
                // color: Colors.black,
              ),
              onTap: () {},
            );
          },
        )
            : Container(),
      ),
    );
  }
}
