import 'dart:core';

class Record {
  String appName;
  String permissionUsed;
  int permissionAllowed;
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
