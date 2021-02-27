import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:convert';
import 'package:privacywind/app_search/search_app_permissions_list.dart';
import 'AppModel.dart';
import 'package:http/http.dart' as http;


class AppSearch extends StatefulWidget {
  @override
  _AppSearchState createState() => _AppSearchState();
}

class _AppSearchState extends State<AppSearch> {
  static const platform =
      const MethodChannel("com.example.test_permissions_app/permissions");

  bool gotAppList = false;
  List<AppModel> searchResult = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: NestedScrollView(
        headerSliverBuilder: (context, value) => [
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
              child: TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  prefixIcon: Icon(Icons.search_rounded),
                  labelText: "Search App",
                  contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
                ),
                onFieldSubmitted: (value) async {
                  if (value != "") {
                    await getSearchResult(value);
                    if (searchResult.isEmpty) {
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Error in searching"),
                          action: SnackBarAction(
                            label: "Okay !",
                            onPressed: () {},
                          ),
                        ),
                      );
                    } else {
                      setState(() {
                        gotAppList = true;
                      });
                    }
                  } else {
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Search Field is Empty"),
                        action: SnackBarAction(
                          label: "Okay !",
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
        body: gotAppList
            ? ListView.builder(
                itemCount: searchResult.length,
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        child: new ListTile(
                          title: Text(searchResult[index].title),
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage("${searchResult[index].icon}"),
                            backgroundColor: Colors.transparent,
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
                                builder: (context) => SearchAppPermissionList(
                                  packageName: searchResult[index].appId,
                                  appname: searchResult[index].title,
                                  iconstring: searchResult[index].icon,
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
              )
            : Center(
                child: Container(
                  child: Text("Search an App to get its permission list"),
                ),
              ),
      ),
    );
  }

  Future<void> getSearchResult(String searchTerm) async {
    try {
      print(searchTerm);
      var url = "https://permission-api.herokuapp.com/api/search/${searchTerm}";
      var client = http.Client();
      var response = await client.get(url);

      Iterable l = json.decode(response.body);
      List<AppModel> parsed = List<AppModel>.from(l.map((model)=> AppModel.fromJson(model)));

      searchResult = parsed;
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
