import 'package:flutter/material.dart';

import 'package:privacywind/app_search/search_app_details.dart';
import 'package:privacywind/app_search/search_category/app_categories.dart';
import 'package:privacywind/constants/app_search_constants.dart';
import 'package:privacywind/constants/loading.dart';
import 'AppModel.dart';

class AppSearch extends StatefulWidget {
  @override
  _AppSearchState createState() => _AppSearchState();
}

class _AppSearchState extends State<AppSearch> {
  bool gotAppList = false;
  bool isLoading = false;
  List<AppModel> searchResult = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: NestedScrollView(
        physics: ScrollPhysics(),
        headerSliverBuilder: (context, value) => [
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 0.0),
              child: TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  prefixIcon: Icon(Icons.search_rounded),
                  labelText: "Search App",
                  contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
                ),
                onFieldSubmitted: (val) async {
                  if (val != "") {
                    setState(() {
                      isLoading = true;
                    });
                    await AppSearchConstants.getAppListFromSearchResult(val)
                        .then((value) {
                      searchResult = value;
                    });
                    if (searchResult == null || searchResult.isEmpty) {
                      setState(() {
                        isLoading = false;
                        Scaffold.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Error in searching !"),
                            action: SnackBarAction(
                              label: "Okay",
                              onPressed: () {},
                            ),
                          ),
                        );
                      });
                    } else {
                      setState(() {
                        gotAppList = true;
                        isLoading = false;
                      });
                    }
                  } else {
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Search Field is Empty !"),
                        action: SnackBarAction(
                          label: "Okay",
                          onPressed: () {},
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ],
        body: Column(
          // mainAxisSize: MainAxisSize.min,
          children: [
            AppCategories(),
            isLoading
                ? Expanded(
                    child: Column(
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
                    ),
                  )
                : gotAppList
                    ? searchResult == null
                        ? Expanded(
                            child: Center(
                              child: Container(
                                child: Text(
                                  "There was an error getting the app list",
                                ),
                              ),
                            ),
                          )
                        : Expanded(
                            child: ListView.builder(
                              itemCount: searchResult.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      child: new ListTile(
                                        title: Text(searchResult[index].title),
                                        subtitle:
                                            Text(searchResult[index].developer),
                                        leading: CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              "${searchResult[index].icon}"),
                                          backgroundColor: Colors.transparent,
                                        ),
                                        trailing: Icon(
                                          Icons.arrow_forward_ios_sharp,
                                          size: 15.0,
                                          // color: Colors.black,
                                        ),
                                        onTap: () {
                                          debugPrint(
                                              "${searchResult[index].appId}");
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  SearchAppPermissionList(
                                                packageName:
                                                    searchResult[index].appId,
                                                appName:
                                                    searchResult[index].title,
                                                iconString:
                                                    searchResult[index].icon,
                                                playURL:
                                                    searchResult[index].url,
                                                appSummary:
                                                    searchResult[index].summary,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.9,
                                      child: Divider(thickness: 1.0),
                                    ),
                                  ],
                                );
                              },
                            ),
                          )
                    : Expanded(
                        child: Center(
                          child: Container(
                            child: Text(
                              "Search an App to get its permission list",
                            ),
                          ),
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}

/*

gotAppList
    ? Expanded(
        child: ListView.builder(
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
                      backgroundImage: NetworkImage(
                          "${searchResult[index].icon}"),
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
      )
    : isLoading
        ? Expanded(
            child: Column(
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
            ),
          )
        : Expanded(
            child: Center(
              child: Container(
                child: Text(
                  "Search an App to get its permission list",
                ),
              ),
            ),
          ),

*/
