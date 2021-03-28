import 'package:flutter/material.dart';
import 'package:privacywind/app_search/search_category/app_detail_model.dart';
import 'package:privacywind/constants/permissions_icon_data.dart';

class AppCompare extends StatefulWidget {
  final List<AppDetail> compareApps;

  AppCompare({this.compareApps});

  @override
  _AppCompareState createState() => _AppCompareState();
}

class _AppCompareState extends State<AppCompare> {
  List<String> permissions = [
    "Camera",
    "Contacts",
    "Location",
    "Microphone",
    "Phone",
    "SMS",
    "Storage",
  ];

  @override
  Widget build(BuildContext context) {
    debugPrint(
        "${widget.compareApps[0].appName} => ${widget.compareApps[0].permissionList.toString()}");
    debugPrint(
        "${widget.compareApps[1].appName} => ${widget.compareApps[1].permissionList.toString()}");

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
        columnWidths: {
          0: FractionColumnWidth(0.4),
          1: FractionColumnWidth(0.3),
          2: FractionColumnWidth(0.3),
        },
        children: [
          TableRow(
            children: [
              TableCell(child: Container()),
              TableCell(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: CircleAvatar(
                    backgroundImage:
                        NetworkImage("${widget.compareApps[0].iconString}"),
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ),
              TableCell(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: CircleAvatar(
                    backgroundImage:
                        NetworkImage("${widget.compareApps[1].iconString}"),
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ),
            ],
          ),
          for (var perm in permissions)
            TableRow(
              children: [
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: PermissionIconData(context: context)
                        .getPermissionIcon(perm),
                  ),
                ),
                TableCell(
                  child: isPermissionInList(
                    perm,
                    widget.compareApps[0].permissionList,
                  ),
                ),
                TableCell(
                  child: isPermissionInList(
                    perm,
                    widget.compareApps[1].permissionList,
                  ),
                ),
              ],
            ),
          TableRow(
            children: [
              TableCell(
                child: Container(),
              ),
              TableCell(
                child: Container(),
              ),
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
