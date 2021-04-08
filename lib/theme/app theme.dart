import 'package:flutter/material.dart';

final String fontFam = "Lato";

class CustomThemeData {
  static ThemeData lightTheme(BuildContext context) {
    return ThemeData(
      fontFamily: fontFam,
      canvasColor: Colors.white,
      hintColor: Colors.grey,
      primaryColor: Colors.black,
      primarySwatch: Colors.grey,
      highlightColor: Colors.transparent,
      accentColor: Colors.lightBlue[700],
      textSelectionColor: Colors.lightBlue[700],
      cardTheme: Theme.of(context).cardTheme.copyWith(
            color: Colors.grey[300],
            elevation: 2.0,
            shadowColor: Colors.white,
          ),
      disabledColor: Colors.black,
      indicatorColor: Colors.black,
      appBarTheme: Theme.of(context).appBarTheme.copyWith(
            shadowColor: Colors.black,
            elevation: 1.0,
            color: Colors.white,
            centerTitle: true,
            brightness: Brightness.light,
            textTheme: Theme.of(context).textTheme.apply(
                  bodyColor: Colors.black,
                ),
            iconTheme: Theme.of(context).iconTheme.copyWith(
                  color: Colors.black,
                ),
          ),
      iconTheme: Theme.of(context).iconTheme.copyWith(
            color: Colors.black,
          ),
      brightness: Brightness.light,
      toggleableActiveColor: Colors.lightBlue[700],

      // backgroundColor: Colors.purple,
      // focusColor: Colors.purple,
      // buttonColor: Colors.purple,
      // hoverColor: Colors.purple,

      buttonTheme: Theme.of(context).buttonTheme.copyWith(
        buttonColor: Colors.lightBlue[700],
        disabledColor: Colors.grey[300],
        colorScheme: ColorScheme.dark(),
          ),

      // textTheme: Theme.of(context).textTheme,
    );
  }

  static ThemeData darkTheme(BuildContext context) {
    return ThemeData(
      fontFamily: fontFam,
      canvasColor: Colors.black,
      hintColor: Colors.grey,
      primaryColor: Colors.white,
      primarySwatch: Colors.grey,
      highlightColor: Colors.transparent,
      accentColor: Colors.lightBlue[700],
      textSelectionColor: Colors.lightBlue[700],
      cardTheme: Theme.of(context).cardTheme.copyWith(
            color: Colors.grey[700],
            elevation: 2.0,
            shadowColor: Colors.white,
          ),
      disabledColor: Colors.white,
      indicatorColor: Colors.white,
      appBarTheme: Theme.of(context).appBarTheme.copyWith(
            shadowColor: Colors.white,
            elevation: 1.0,
            color: Colors.black,
            centerTitle: true,
            brightness: Brightness.dark,
            textTheme: Theme.of(context).textTheme.apply(
                  bodyColor: Colors.white,
                ),
            iconTheme: Theme.of(context).iconTheme.copyWith(
                  color: Colors.white,
                ),
          ),

      iconTheme: Theme.of(context).iconTheme.copyWith(
            color: Colors.white,
          ),

      brightness: Brightness.dark,
      toggleableActiveColor: Colors.lightBlue[700],

      // backgroundColor: Colors.red,
      // buttonColor: Colors.red,
      // hoverColor: Colors.red,
      // focusColor: Colors.red,

      // accentColorBrightness: Brightness.light,
      // primaryColorBrightness: Brightness.light,

      buttonTheme: Theme.of(context).buttonTheme.copyWith(
            buttonColor: Colors.lightBlue[700],
            disabledColor: Colors.grey[700],
            colorScheme: ColorScheme.dark(),
          ),

      // textTheme: Theme.of(context).textTheme,
    );
  }
}
