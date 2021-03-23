import 'package:flutter/material.dart';
import 'package:privacywind/app_search/AppModel.dart';
import 'package:privacywind/constants/loading.dart';

import '../search_app_permissions_list.dart';

class AppList extends StatefulWidget {
  String categoryName;

  AppList({this.categoryName});

  @override
  _AppListState createState() => _AppListState();
}

class _AppListState extends State<AppList> {
  bool isLoading = true;
  List<AppModel> searchResult = [];

  @override
  void initState() {
    super.initState();
    getSearchResult(widget.categoryName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("App Search"),
      ),
      body: Center(
        child: isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: Text(
                      "Looking for results...",
                      style: TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                  Loading(),
                ],
              )
            : ListView.builder(
          itemCount: searchResult.length,
          itemBuilder: (context, index) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  child: new ListTile(
                    title: Text(searchResult[index].title),
                    subtitle: Text(searchResult[index].developer),
                    leading: CircleAvatar(
                      backgroundImage:
                      NetworkImage("${searchResult[index].icon}"),
                      backgroundColor: Colors.transparent,
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios_sharp,
                      size: 15.0,
                      // color: Colors.black,
                    ),
                    onTap: () {
                      debugPrint("${searchResult[index].appId}");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SearchAppPermissionList(
                                packageName: searchResult[index].appId,
                                appName: searchResult[index].title,
                                iconString: searchResult[index].icon,
                                playURL: searchResult[index].url,
                                appSummary: searchResult[index].summary,
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

  Future<void> getSearchResult(String categoryName) async {
    try {
      // TODO : fetch top app in the category



      // use => setState(() {});
      // after the search result fetch is complete
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
