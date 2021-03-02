import 'package:flutter/material.dart';
import 'package:privacywind/constants/loading.dart';
import 'package:privacywind/constants/permissions_icon_data.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchAppPermissionList extends StatefulWidget {
  final String packageName, appname, iconstring;

  SearchAppPermissionList({this.packageName, this.appname, this.iconstring});

  @override
  _SearchAppPermissionListState createState() =>
      _SearchAppPermissionListState();
}

class _SearchAppPermissionListState extends State<SearchAppPermissionList> {
  List<dynamic> permissionsList = [];
  bool hasPermissions = false;

  @override
  void initState() {
    super.initState();
    getSearchAppPermissions(
        widget.packageName, widget.appname, widget.iconstring);
  }

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
                        backgroundImage: NetworkImage("${widget.iconstring}"),
                        radius: 60.0,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 15.0, bottom: 5.0),
                      child: Text(
                        widget.appname,
                        style: TextStyle(
                          fontSize: 25.0,
                        ),
                      ),
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
              child: !hasPermissions
                  ? Loading()
                  : (permissionsList.length != 0
                      ? ListView.builder(
                          itemCount: permissionsList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                              title: Text(permissionsList[index]),
                              leading: PermissionIconData(context: context)
                                  .getPermissionIcon(permissionsList[index]),
                            );
                          },
                        )
                      : Center(
                          child: Text("This app requires no permission")))),
        ));
  }

  Future<void> getSearchAppPermissions(
      String packageName, String appname, String iconstring) async {
    try {
      var url =
          "https://permission-api.herokuapp.com/api/permission/$packageName";
      var client = http.Client();
      var response = await client.get(url);

      var parsed = json.decode(response.body);
      permissionsList = parsed;
      hasPermissions = true;
    } catch (e) {
      debugPrint(e);
    }
    setState(() {});
  }
}
