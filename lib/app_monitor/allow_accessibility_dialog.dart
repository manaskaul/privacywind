import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class AccessibilityDialogBox extends StatelessWidget {
  static const platform =
      const MethodChannel("com.example.test_permissions_app/permissions");

  final String title = "Permission";
  final String description =
      "To use this App Monitor feature you need to activate app in ACCESSIBILITY SETTINGS.\n\nTo monitor location you need to give access to LOCATION PERMISSION";

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        child: contentBox(context),
      ),
    );
  }

  showLocationStatus() async {
    var locationStatus = await Permission.location.status;
    if (!locationStatus.isGranted) {
      Permission.location.request();
    }
  }

  contentBox(context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Theme.of(context).canvasColor,
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                description,
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 20,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: OutlineButton(
                  child: Text(
                    "Okay !",
                    style: TextStyle(fontSize: 18),
                  ),
                  onPressed: () async {
                    await platform.invokeMethod("setAccessibilityInfoDialogSeen");
                    Navigator.of(context).pop();
                    showLocationStatus();
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
