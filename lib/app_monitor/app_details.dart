import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';

class AppDetails extends StatefulWidget {
  final ApplicationWithIcon selectedApp;

  AppDetails({this.selectedApp});

  @override
  _AppDetailsState createState() => _AppDetailsState();
}

class _AppDetailsState extends State<AppDetails> {
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
                    child: Text(widget.selectedApp.versionName),
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
              child: Center(
                child: Text("ALL LOGS"),
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
                onPressed: () {
                  Navigator.pop(context, widget.selectedApp);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
