import 'package:flutter/material.dart';
import 'package:privacywind/app_search/search_category/app_list.dart';

class AppCategories extends StatefulWidget {
  @override
  _AppCategoriesState createState() => _AppCategoriesState();
}

class _AppCategoriesState extends State<AppCategories> {
  int _index = 0;
  List<String> categories = [
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: SizedBox(
        height: 150,
        child: PageView.builder(
          itemCount: categories.length,
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
                child: ListTile(
                  title: Center(
                    child: Text(
                      categories[i],
                      style: TextStyle(fontSize: 30),
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AppList(
                          categoryName: categories[i],
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
