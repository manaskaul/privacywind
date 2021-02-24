import 'package:flutter/material.dart';
import 'package:privacywind/constants/permissions_icon_data.dart';

class SearchAppPermissionList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("App Search"),
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
                      backgroundColor: Colors.blue,
                      radius: 60.0,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 15.0, bottom: 5.0),
                    child: Text(
                      "App Name",
                      style: TextStyle(
                        fontSize: 25.0,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(bottom: 15.0),
                    child: Text("15.6 MB"),
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
        body: Container(
          child: ListView.builder(
            itemCount: 1,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                children: [
                  ListTile(
                    title: Text("Camera"),
                    leading: PermissionIconData(context: context).getPermissionIcon("Camera"),
                  ),
                  ListTile(
                    title: Text("Contacts"),
                    leading: PermissionIconData(context: context).getPermissionIcon("Contacts"),
                  ),
                  ListTile(
                    title: Text("Location"),
                    leading: PermissionIconData(context: context).getPermissionIcon("Location"),
                  ),
                  ListTile(
                    title: Text("Microphone"),
                    leading: PermissionIconData(context: context).getPermissionIcon("Microphone"),
                  ),
                  ListTile(
                    title: Text("SMS"),
                    leading: PermissionIconData(context: context).getPermissionIcon("SMS"),
                  ),
                  ListTile(
                    title: Text("Phone"),
                    leading: PermissionIconData(context: context).getPermissionIcon("Phone"),
                  ),
                  ListTile(
                    title: Text("Storage"),
                    leading: PermissionIconData(context: context).getPermissionIcon("Storage"),
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
