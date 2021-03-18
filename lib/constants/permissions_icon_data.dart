import 'package:flutter/material.dart';

class PermissionIconData {
  BuildContext context;

  PermissionIconData({this.context});

  Icon getPermissionIcon(String permissionType) {
    Map<String, Icon> permissionIcons = {
      "Camera": Icon(
        Icons.camera_alt,
        color: Theme.of(context).iconTheme.color,
      ),
      "Contacts": Icon(
        Icons.contacts,
        color: Theme.of(context).iconTheme.color,
      ),
      "Location": Icon(
        Icons.location_on,
        color: Theme.of(context).iconTheme.color,
      ),
      "Microphone": Icon(
        Icons.mic,
        color: Theme.of(context).iconTheme.color,
      ),
      "Phone": Icon(
        Icons.local_phone,
        color: Theme.of(context).iconTheme.color,
      ),
      "SMS": Icon(
        Icons.sms,
        color: Theme.of(context).iconTheme.color,
      ),
      "Storage": Icon(
        Icons.folder,
        color: Theme.of(context).iconTheme.color,
      )
    };

    return permissionIcons[permissionType];
  }
}
