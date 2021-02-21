import 'package:flutter/material.dart';

class PermissionIconData {
  BuildContext context;

  PermissionIconData({this.context});

  Icon getPermissionIcon(String permissionType) {
    Map<String, Icon> permissionIcons = {
      "Camera": Icon(
        Icons.camera_alt_outlined,
        color: Theme.of(context).iconTheme.color,
      ),
      "Contacts": Icon(
        Icons.contacts_outlined,
        color: Theme.of(context).iconTheme.color,
      ),
      "Location": Icon(
        Icons.location_on_outlined,
        color: Theme.of(context).iconTheme.color,
      ),
      "Microphone": Icon(
        Icons.mic_none_outlined,
        color: Theme.of(context).iconTheme.color,
      ),
      "Phone": Icon(
        Icons.local_phone_outlined,
        color: Theme.of(context).iconTheme.color,
      ),
      "SMS": Icon(
        Icons.sms_outlined,
        color: Theme.of(context).iconTheme.color,
      ),
      "Storage": Icon(
        Icons.folder_open_outlined,
        color: Theme.of(context).iconTheme.color,
      )
    };

    return permissionIcons[permissionType];
  }
}
