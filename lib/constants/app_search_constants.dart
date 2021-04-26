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
    "Music & Audio",
    "Photography",
    "Social",
    "Tools"
  ];

  static const searchCategories = {
    "Art & Design": "ART_AND_DESIGN",
    "Business": "BUSINESS",
    "Communication": "COMMUNICATION",
    "Dating": "DATING",
    "Education": "EDUCATION",
    "Entertainment": "ENTERTAINMENT",
    "Finance": "FINANCE",
    "Games": "GAME",
    "Music & Audio": "MUSIC_AND_AUDIO",
    "Photography": "PHOTOGRAPHY",
    "Social": "SOCIAL",
    "Tools": "TOOLS",
  };

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

  static Future<List<AppModel>> getAppListForCategory(
      String categoryType) async {
    try {
      print(searchCategories[categoryType]);
      var url =
          "https://permission-api.herokuapp.com/api/list/${searchCategories[categoryType]}";
      var client = http.Client();
      var response = await client.get(url);

      Iterable l = json.decode(response.body);
      List<AppModel> parsed = List<AppModel>.from(l.map((model) => AppModel.fromJson(model)));

      return parsed;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  static Future<dynamic> getSearchAppPermissions(String packageName, String appName, String iconString) async {
    try {
      var url = "https://permission-api.herokuapp.com/api/permission/$packageName";
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

  static Future<String> getAppRating(String packageName) async {
    try {
      var url = "https://permission-api.herokuapp.com/api/rating/$packageName";
      var client = http.Client();
      var response = await client.get(url);

      if (response.body != "null") {
        var parsed = json.decode(response.body);
        return parsed["rating"].toString();
      } else {
        return null;
      }
    } catch (e) {
      debugPrint(e);
      return null;
    }
  }

  static Future<List<String>> getAppRatingForList(List<String> appList) async {
    bool hasAllNullValues = true;
    List<String> appScores = [];
    for (String packageName in appList) {
      await getAppRating(packageName).then((value) {
        if (value != null) {
          hasAllNullValues = false;
        }
        appScores.add(value);
      });
    }
    return hasAllNullValues ? null : appScores;
  }

  static String getAppScore() {
    double val = 7.80;
    return val.toStringAsFixed(2);
  }

  static List<String> getAppScoreForList(List<String> appList) {
    double val1 = 7.80;
    double val2 = 8.55;
    double val3 = 7.65;
    return appList.length == 2
        ? [val1.toStringAsFixed(2), val2.toStringAsFixed(2)]
        : [val1.toStringAsFixed(2), val2.toStringAsFixed(2), val3.toStringAsFixed(2)];
  }
}
