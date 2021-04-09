import 'package:flutter/material.dart';
import 'package:privacywind/app_search/AppModel.dart';
import 'package:privacywind/app_search/search_category/app_compare.dart';
import 'package:privacywind/app_search/search_category/app_detail_model.dart';
import 'package:privacywind/app_search/search_category/app_details.dart';
import 'package:privacywind/constants/app_search_constants.dart';
import 'package:privacywind/constants/loading.dart';

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

  getSearchResult(String categoryName) async {
    await AppSearchConstants.getAppListFromSearchResult(categoryName)
        .then((value) {
      setState(() {
        searchResult = value;
        isLoading = false;
      });
    });
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
            : searchResult != null
                ? ListView.builder(
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
                                List<String> compareListAppNames = [];
                                for (AppDetail appDet in compareList) {
                                  compareListAppNames.add(appDet.appName.toString());
                                }
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
                                      compareList: compareListAppNames,
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
                  )
                : Center(
                    child: Text("There was an error getting the app list"),
                  ),
      ),
      floatingActionButton: InkWell(
        child: FloatingActionButton.extended(
          backgroundColor: getFloatingActionButtonColor(),
          label: Text(
            "Compare Apps : ${compareList.length}",
            style: TextStyle(
              color: getTextColor(),
            ),
          ),
          onPressed:
              compareList.length >= AppSearchConstants.MIN_COMPARE_APPS &&
                      compareList.length <= AppSearchConstants.MAX_COMPARE_APPS
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

  getTextColor() {
    if (compareList.length >= AppSearchConstants.MIN_COMPARE_APPS &&
        compareList.length <= AppSearchConstants.MAX_COMPARE_APPS) {
      return Colors.white;
    } else {
      if (MediaQuery.of(context).platformBrightness == Brightness.light) {
        return Colors.white;
      } else {
        return Colors.black;
      }
    }
  }

  getFloatingActionButtonColor() {
    if (compareList.length >= AppSearchConstants.MIN_COMPARE_APPS &&
        compareList.length <= AppSearchConstants.MAX_COMPARE_APPS) {
      return Colors.lightBlue[700];
    } else {
      if (MediaQuery.of(context).platformBrightness == Brightness.light) {
        return Colors.grey[700];
      } else {
        return Colors.grey[300];
      }
    }
  }
}
