import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15.0),
      child: SpinKitThreeBounce(
        color: Colors.blue,
        size: 25.0,
      ),
    );
  }
}
