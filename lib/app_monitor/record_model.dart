import 'dart:core';

class Record {
  String appName;
  String permissionUsed;
  bool permissionAllowed;
  String startTime;
  String endTime;

  Record({
    this.appName,
    this.permissionUsed,
    this.permissionAllowed,
    this.startTime,
    this.endTime,
  });
}
