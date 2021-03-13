import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AccessibilityDialogBox extends StatelessWidget {
  static const platform = const MethodChannel("com.example.test_permissions_app/permissions");
  
  final String title = "Permission";
  final String description =
      "To use this App Monitor feature you need to activate app in ACCESSIBILITY settings.\n\nAfter turning this on you would be able to use this feature.";

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Theme.of(context).canvasColor,
            borderRadius: BorderRadius.circular(20.0),
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
              Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: FlatButton(
                      child: Text(
                        "No",
                        style: TextStyle(fontSize: 18),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        SystemChannels.platform
                            .invokeMethod('SystemNavigator.pop');
                      },
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: FlatButton(
                      child: Text(
                        "Okay",
                        style: TextStyle(fontSize: 18),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        platform.invokeMethod("openAccessibilitySettings");
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
