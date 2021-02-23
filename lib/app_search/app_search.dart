import 'package:flutter/material.dart';

class AppSearch extends StatefulWidget {
  @override
  _AppSearchState createState() => _AppSearchState();
}

class _AppSearchState extends State<AppSearch> {
  String searchTerm;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: NestedScrollView(
        headerSliverBuilder: (context, value) => [
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
              child: TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  prefixIcon: Icon(Icons.search_rounded),
                  labelText: "Search App",
                  contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
                ),
                onChanged: (value) {
                  searchTerm = value;
                },
                onFieldSubmitted: (value) {
                  // TODO : Get list of apps matching the search term
                  debugPrint(searchTerm);
                },
              ),
            ),
          ),
        ],
        body: Center(
          // child: Container(
          //   child: Text("Search an App to get its permission list"),
          // ),
          child: GridView.count(
            crossAxisCount: 2,
            children: [
              Text("Tile 0"),
              Text("Tile 1"),
              Text("Tile 2"),
              Text("Tile 3"),
              Text("Tile 4"),
              Text("Tile 5"),
              Text("Tile 6"),
              Text("Tile 7"),
              Text("Tile 8"),
            ],
          ),
        ),
      ),
    );
  }
}
