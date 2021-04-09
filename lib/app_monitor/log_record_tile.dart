import 'package:flutter/material.dart';
import 'package:privacywind/constants/permissions_icon_data.dart';

class LogRecordTile extends StatelessWidget {
  final String permissionType;
  final String startTime;
  final String endTime;

  LogRecordTile({
    this.permissionType,
    this.startTime,
    this.endTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          PermissionIconData(context: context)
              .getPermissionIcon(permissionType),
          Text(permissionType),
          Text(
            "${startTime.substring(0, 8)}\n${startTime.substring(9, startTime.length)}",
            textAlign: TextAlign.center,
          ),
          Text(
            " - ",
            textAlign: TextAlign.center,
          ),
          Text(
            "${endTime.substring(0, 8)}\n${endTime.substring(9, endTime.length)}",
            textAlign: TextAlign.center,
          ),
          // Text(endTime),
        ],
      ),
    );
  }
}
