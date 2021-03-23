import 'package:flutter/material.dart';

class AppCategories extends StatefulWidget {
  @override
  _AppCategoriesState createState() => _AppCategoriesState();
}

class _AppCategoriesState extends State<AppCategories> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: SizedBox(
        height: 150, // card height
        child: PageView.builder(
          itemCount: 10,
          controller: PageController(viewportFraction: 0.7),
          onPageChanged: (int index) => setState(() => _index = index),
          itemBuilder: (_, i) {
            return Transform.scale(
              scale: i == _index ? 1 : 0.85,
              child: Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Text(
                    "Card ${i + 1}",
                    style: TextStyle(fontSize: 30),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
