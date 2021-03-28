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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("App Search"),
        centerTitle: true,
      ),
      body: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        border: TableBorder(
          verticalInside: BorderSide(color: Colors.grey.shade300),
          horizontalInside: BorderSide(color: Colors.grey.shade300),
        ),
        columnWidths: widget.compareApps.length == 2
            ? {
                0: FractionColumnWidth(0.4),
                1: FractionColumnWidth(0.3),
                2: FractionColumnWidth(0.3),
              }
            : {
                0: FractionColumnWidth(0.25),
                1: FractionColumnWidth(0.25),
                2: FractionColumnWidth(0.25),
                3: FractionColumnWidth(0.25),
              },
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
                    child: isPermissionInList(
                      perm,
                      app.permissionList,
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
