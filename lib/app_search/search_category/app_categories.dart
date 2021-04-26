import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:privacywind/app_search/search_category/app_list.dart';
import 'package:privacywind/constants/app_search_constants.dart';

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
        height: 125,
        child: PageView.builder(
          itemCount: AppSearchConstants.APP_CATEGORIES.length,
          controller: PageController(viewportFraction: 0.8),
          onPageChanged: (int index) => setState(() => _index = index),
          itemBuilder: (_, i) {
            return Transform.scale(
              scale: i == _index ? 1 : 0.90,
              child: Card(
                child: InkWell(
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage(
                        'assets/icons/${AppSearchConstants.searchCategories[AppSearchConstants.APP_CATEGORIES[i]]}.png',
                        ),
                      ),
                    ),
                    child: Center(
                      child: ListTile(
                        title: Container(
                          padding: EdgeInsets.symmetric(vertical: 2),
                          color: Colors.grey[50],
                          child: Text(
                            AppSearchConstants.APP_CATEGORIES[i],
                            style: TextStyle(color: Colors.black, fontSize: 22,),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AppList(
                          categoryName: AppSearchConstants.APP_CATEGORIES[i],
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
