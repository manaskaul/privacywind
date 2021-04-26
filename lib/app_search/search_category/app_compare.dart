import 'package:flutter/material.dart';
import 'package:privacywind/app_search/search_category/app_detail_model.dart';
import 'package:privacywind/constants/app_search_constants.dart';
import 'package:privacywind/constants/permissions_icon_data.dart';

class AppCompare extends StatefulWidget {
  final List<AppDetail> compareApps;

  AppCompare({this.compareApps});

  @override
  _AppCompareState createState() => _AppCompareState();
}

class _AppCompareState extends State<AppCompare> {
  List<String> appScores;

  @override
  void initState() {
    super.initState();
    getAppScores();
  }

  getAppScores() async {
    List<String> appNames = [];
    for (var app in widget.compareApps) {
      appNames.add(app.packageName);
    }
    await AppSearchConstants.getAppRatingForList(appNames).then((value) {
      setState(() {
        appScores = value;
        debugPrint("App scores => ${appScores.toString()}");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("App Search"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          border: TableBorder(
            verticalInside: BorderSide(color: Colors.grey.shade300),
            horizontalInside: BorderSide(color: Colors.grey.shade300),
          ),
          columnWidths:
              AppSearchConstants.getColumnWidths(widget.compareApps.length),
          children: [
            TableRow(
              children: [
                TableCell(child: Container()),
                for (var app in widget.compareApps)
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage("${app.iconString}"),
                        backgroundColor: Colors.transparent,
                        radius: 40.0,
                      ),
                    ),
                  ),
              ],
            ),
            TableRow(
              children: [
                TableCell(child: Container()),
                for (var app in widget.compareApps)
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        app.appName,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            for (var perm in AppSearchConstants.PERMISSIONS_LIST)
              TableRow(
                children: [
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: PermissionIconData(context: context)
                          .getPermissionIcon(perm),
                    ),
                  ),
                  for (var app in widget.compareApps)
                    TableCell(
                      child: isPermissionInList(perm, app.permissionList),
                    ),
                ],
              ),
            if (appScores != null)
              TableRow(
                children: [
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                        "PrivacyWind",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  for (String score in appScores)
                    TableCell(
                      child: score == null
                          ? Text(
                              "-",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                            )
                          : Text(
                              score,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                            ),
                    ),
                ],
              ),
            TableRow(
              children: [
                TableCell(child: Container()),
                for (var app in widget.compareApps)
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: IconButton(
                        icon: Image.asset("assets/icons/play_store_icon.png"),
                        onPressed: () async {
                          await AppSearchConstants.openAppInPlayStore(
                              app.playURL);
                        },
                      ),
                    ),
                  ),
              ],
            ),
            TableRow(
              children: [
                TableCell(
                  child: Container(),
                ),
                for (var app in widget.compareApps)
                  TableCell(
                    child: Container(),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  checkIcon() {
    return Container(
      child: Icon(
        Icons.check_circle_outline,
        color: Colors.red,
      ),
    );
  }

  crossIcon() {
    return Container(
      child: Icon(
        Icons.cancel_outlined,
        color: Colors.green,
      ),
    );
  }

  isPermissionInList(String permission, List<dynamic> permissionList) {
    return permissionList.contains(permission) ? checkIcon() : crossIcon();
  }
}
