import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:privacywind/constants/loading.dart';
import 'package:privacywind/constants/permissions_icon_data.dart';

class SearchAppPermissionList extends StatefulWidget {
  final String appIconURL;
  final String appName;
  final String packageName;


  SearchAppPermissionList({this.appIconURL, this.appName, this.packageName});

  @override
  _SearchAppPermissionListState createState() =>
      _SearchAppPermissionListState();
}

class _SearchAppPermissionListState extends State<SearchAppPermissionList> {
  static const platform =
      const MethodChannel("com.example.test_permissions_app/permissions");

  List<dynamic> permissionsList = [];

  @override
  void initState() {
    super.initState();
    getSearchAppPermissions(widget.packageName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("App Search"),
        centerTitle: true,
      ),
      body: permissionsList.isEmpty
          ? Loading()
          : NestedScrollView(
              headerSliverBuilder: (context, value) => [
                SliverToBoxAdapter(
                  child: Container(
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(15.0),
                          child: CircleAvatar(
                            // TODO : use app icon here
                            backgroundColor: Colors.blue,
                            radius: 60.0,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 15.0, bottom: 5.0),
                          child: Text(
                            widget.appName,
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
                child: ListView.builder(
                  itemCount: permissionsList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(permissionsList[index]),
                      leading: PermissionIconData(context: context)
                          .getPermissionIcon(permissionsList[index]),
                    );
                  },
                ),
              ),
            ),
    );
  }

  Future<void> getSearchAppPermissions(String packageName) async {
    try {
      permissionsList =
          await platform.invokeMethod("getSearchAppPermissions", packageName);
    } catch (e) {
      debugPrint(e);
    }
    setState(() {});
  }
}
