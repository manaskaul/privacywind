import 'package:flutter/material.dart';
import 'package:privacywind/app_search/search_category/app_detail_model.dart';
import 'package:privacywind/app_search/search_category/app_score_detail.dart';
import 'package:privacywind/constants/app_search_constants.dart';
import 'package:privacywind/constants/loading.dart';
import 'package:privacywind/constants/permissions_icon_data.dart';

class AppDetails extends StatefulWidget {
  final String packageName, appName, iconString, appSummary, playURL, scoreText;
  final int compareListSize;
  final List<String> compareList;

  AppDetails({
    this.packageName,
    this.appName,
    this.iconString,
    this.appSummary,
    this.playURL,
    this.scoreText,
    this.compareListSize,
    this.compareList,
  });

  @override
  _AppDetailsState createState() => _AppDetailsState();
}

class _AppDetailsState extends State<AppDetails> {
  List<dynamic> permissionsList = [];
  bool hasPermissions = false;
  String appScore;
  String camWeight, micWeight, locWeight;

  @override
  void initState() {
    super.initState();
    debugPrint("Compare List => ${widget.compareList.toString()}");
    getAppScore();
    getAppPermissions(widget.packageName, widget.appName, widget.iconString);
  }

  getAppScore() async {
    await AppSearchConstants.getAppRating(widget.packageName).then((value) {
      setState(() {
        appScore = value;
      });
    });
    // setState(() {
    //   appScore = AppSearchConstants.getAppScore();
    // });
  }

  getAppPermissions(
      String packageName, String appName, String iconString) async {
    await AppSearchConstants.getSearchAppPermissions(
            packageName, appName, iconString)
        .then((value) {
      if (mounted) {
        setState(() {
          permissionsList = value;
          hasPermissions = true;
        });
      }
    });
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
                      backgroundImage: NetworkImage("${widget.iconString}"),
                      radius: 60.0,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        top: 10.0, bottom: 10.0, left: 15.0, right: 15.0),
                    child: Text(
                      widget.appName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 25.0,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.only(bottom: 10.0, left: 15.0, right: 15.0),
                    child: Text(
                      widget.appSummary,
                      maxLines: 2,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15.0,
                      ),
                    ),
                  ),
                  if (appScore == null)
                    InkWell(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 5.0),
                        child: Column(
                          children: [
                            Container(
                              child: Text(
                                "${widget.scoreText}",
                                style: TextStyle(fontSize: 18.0),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 2.0),
                              child: Text("Play Store"),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ScoreDetail(
                              scoreType: 1,
                            ),
                          ),
                        );
                      },
                    )
                  else
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 5.0, horizontal: 5.0),
                              child: Column(
                                children: [
                                  Container(
                                    child: Text(
                                      "${appScore.toString()}",
                                      style: TextStyle(fontSize: 18.0),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(top: 2.0),
                                    child: Text("PrivacyWind"),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ScoreDetail(
                                    scoreType: 0,
                                  ),
                                ),
                              );
                            },
                          ),
                          Container(
                            child: Text("|"),
                          ),
                          InkWell(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 5.0, horizontal: 5.0),
                              child: Column(
                                children: [
                                  Container(
                                    child: Text(
                                      "${widget.scoreText}",
                                      style: TextStyle(fontSize: 18.0),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(top: 2.0),
                                    child: Text("Play Store"),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ScoreDetail(
                                    scoreType: 1,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  Container(
                    padding: EdgeInsets.only(bottom: 5.0),
                    child: OutlineButton(
                      borderSide:
                          BorderSide(color: Theme.of(context).primaryColor),
                      child: Text(
                        "Open in Play Store",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      onPressed: () async {
                        try {
                          await AppSearchConstants.openAppInPlayStore(
                              widget.playURL);
                        } catch (e) {
                          Scaffold.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text("Could not open app in Play Store !"),
                              action: SnackBarAction(
                                label: "Close",
                                onPressed: () {},
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.85,
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
              : permissionsList.length != 0
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
                  : Center(child: Text("This app requires no permission")),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: getFloatingActionButtonColor(),
        label: Text(
          "Add to Compare",
          style: TextStyle(
            color: getTextColor(),
          ),
        ),
        onPressed:
            widget.compareListSize < AppSearchConstants.MAX_COMPARE_APPS &&
                    permissionsList.isNotEmpty &&
                    (widget.compareList.isEmpty ||
                        widget.compareList.indexOf(widget.appName) == -1)
                ? () async {
                    Navigator.pop(
                      context,
                      AppDetail(
                        appName: widget.appName,
                        packageName: widget.packageName,
                        iconString: widget.iconString,
                        playURL: widget.playURL,
                        permissionList: permissionsList,
                      ),
                    );
                  }
                : null,
      ),
    );
  }

  getTextColor() {
    if (widget.compareListSize < AppSearchConstants.MAX_COMPARE_APPS &&
        permissionsList.isNotEmpty &&
        (widget.compareList.isEmpty ||
            widget.compareList.indexOf(widget.appName) == -1)) {
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
    if (widget.compareListSize < AppSearchConstants.MAX_COMPARE_APPS &&
        permissionsList.isNotEmpty &&
        (widget.compareList.isEmpty ||
            widget.compareList.indexOf(widget.appName) == -1)) {
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
