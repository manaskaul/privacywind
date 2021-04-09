import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:privacywind/app_search/AppModel.dart';
import 'package:url_launcher/url_launcher.dart';

class AppSearchConstants {
  static const List<String> APP_CATEGORIES = [
    "Art & Design",
    "Business",
    "Communication",
    "Dating",
    "Education",
    "Entertainment",
    "Finance",
    "Games",
    "Health & Fitness",
    "Lifestyle",
    "Music & Audio",
    "Photography",
    "Social",
    "Tools"
  ];

  static const List<String> PERMISSIONS_LIST = [
    "Camera",
    "Contacts",
    "Location",
    "Microphone",
    "Phone",
    "SMS",
    "Storage",
  ];

  static const int MIN_COMPARE_APPS = 2;
  static const int MAX_COMPARE_APPS = 3;

  static getColumnWidths(int length) {
    if (length == 2) {
      return {
        0: FractionColumnWidth(0.4),
        1: FractionColumnWidth(0.3),
        2: FractionColumnWidth(0.3),
      };
    } else if (length == 3) {
      return {
        0: FractionColumnWidth(0.25),
        1: FractionColumnWidth(0.25),
        2: FractionColumnWidth(0.25),
        3: FractionColumnWidth(0.25),
      };
    }
  }

  static Future<List<AppModel>> getAppListFromSearchResult(
      String searchTerm) async {
    try {
      print(searchTerm);
      var url = "https://permission-api.herokuapp.com/api/search/$searchTerm";
      var client = http.Client();
      var response = await client.get(url);

      Iterable l = json.decode(response.body);
      List<AppModel> parsed =
          List<AppModel>.from(l.map((model) => AppModel.fromJson(model)));

      return parsed;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  static Future<dynamic> getSearchAppPermissions(
      String packageName, String appName, String iconString) async {
    try {
      var url =
          "https://permission-api.herokuapp.com/api/permission/$packageName";
      var client = http.Client();
      var response = await client.get(url);

      var parsed = json.decode(response.body);

      return parsed;
    } catch (e) {
      debugPrint(e);
      return null;
    }
  }

  static Future<void> openAppInPlayStore(String url) async {
    if (await (canLaunch(url))) {
      try {
        await launch(url);
      } catch (e) {
        debugPrint(e.toString());
      }
    } else {
      debugPrint("Could Not launch app");
    }
  }

  // TODO : get the score for provide app name
  static Future<String> getAppRating(String appName) {
    try {} catch (e) {
      debugPrint(e);
      return null;
    }
  }

  static Future<List<String>> getAppRatingForList(List<String> appList) async {
    bool hasAllNullValues = true;
    List<String> appScores;
    for (String appName in appList) {
      await getAppRating(appName).then((value) {
        if (value != null) {
          hasAllNullValues = false;
          appScores.add(value);
        }
      });
    }
    return hasAllNullValues ? null : appScores;
  }

  static String getAppScore() {
    var max = 4;
    var min = 1;
    double val = Random().nextDouble() * (max - min + 1) + min;
    return Random().nextBool() ? val.toStringAsFixed(2) : null;
  }

  static List<String> getAppScoreForList(List<String> appList) {
    return Random().nextBool()
        ? appList.length == 2
            ? [null, "3.71"]
            : ["2.75", "3.71", null]
        : null;
  }
}
