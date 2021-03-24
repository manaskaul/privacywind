import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:privacywind/app_search/AppModel.dart';
import 'package:privacywind/app_search/search_category/app_compare.dart';
import 'package:privacywind/app_search/search_category/app_detail_model.dart';
import 'package:privacywind/app_search/search_category/app_details.dart';
import 'package:privacywind/constants/loading.dart';

import '../search_app_details.dart';
import 'package:http/http.dart' as http;

class AppList extends StatefulWidget {
  final String categoryName;

  AppList({this.categoryName});

  @override
  _AppListState createState() => _AppListState();
}

class _AppListState extends State<AppList> {
  bool isLoading = true;
  List<AppModel> searchResult = [];
  List<AppDetail> compareList = [];

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
                          onTap: () async {
                            debugPrint("${searchResult[index].appId}");
                            var res = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AppDetails(
                                  packageName: searchResult[index].appId,
                                  appName: searchResult[index].title,
                                  iconString: searchResult[index].icon,
                                  playURL: searchResult[index].url,
                                  appSummary: searchResult[index].summary,
                                  compareListSize: compareList.length,
                                ),
                              ),
                            );
                            if (res != null) {
                              setState(() {
                                compareList.add(res);
                              });
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
      floatingActionButton: InkWell(
        child: FloatingActionButton.extended(
          backgroundColor: getFloatingActionButtonColor(),
          label: Text("Compare Apps : ${compareList.length}"),
          onPressed: compareList.length == 2
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AppCompare(
                        compareApps: compareList,
                      ),
                    ),
                  );
                }
              : null,
        ),
        onLongPress: () {
          setState(() {
            compareList.clear();
          });
        },
      ),
    );
  }

  Future<void> getSearchResult(String categoryName) async {
    try {
      // TODO : fetch top app in the category

      try {
        debugPrint(categoryName);
        var url =
            "https://permission-api.herokuapp.com/api/search/$categoryName";
        var client = http.Client();
        var response = await client.get(url);

        Iterable l = json.decode(response.body);
        List<AppModel> parsed =
            List<AppModel>.from(l.map((model) => AppModel.fromJson(model)));

        searchResult = parsed;
        debugPrint(searchResult.toString());
        setState(() {
          isLoading = false;
        });
      } catch (e) {
        debugPrint(e.toString());
      }

      // use => setState(() {});
      // after the search result fetch is complete
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  getFloatingActionButtonColor() {
    if (compareList.length == 2) {
      // return Theme.of(context).appBarTheme.color;
      return Theme.of(context).appBarTheme.color;
    } else {
      if (MediaQuery.of(context).platformBrightness == Brightness.light) {
        return Colors.grey[700];
      } else {
        return Colors.grey[300];
      }
    }
  }
}
