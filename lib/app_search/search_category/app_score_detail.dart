import 'package:flutter/material.dart';

class ScoreDetail extends StatelessWidget {
  // scoreType =>
  // 0 => PrivacyWind
  // 1 => Play Store
  final int scoreType;

  ScoreDetail({this.scoreType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("App Search"),
        centerTitle: true,
      ),
      body: scoreType == 0
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
                    child: Text("About the PrivacyWind Rating"),
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
                  child: Text(
                      "The weights to the permissions are assigned as follows :"),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
                  child: Text(
                    "3.33 : The application allowed the permission and used it.",
                    style: TextStyle(color: Colors.green),
                    textAlign: TextAlign.justify,
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
                  child: Text(
                    "1.33 : The application denied the permission and used it.",
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.justify,
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
                  child: Text(
                    "0.00 : The application did'nt ask the permission but used it.",
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
                    child: Text("About the Play Store Rating"),
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
                  child: Text(
                    "This score is calculated by the rating and reviews given by users on the Play Store ",
                    textAlign: TextAlign.justify,
                  ),
                ),
              ],
            ),
    );
  }
}
