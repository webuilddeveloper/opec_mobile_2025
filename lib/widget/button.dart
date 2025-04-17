import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

buttonCloseBack(BuildContext context) {
  return Column(
    children: [
      Container(
        // width: 60,
        // color: Colors.red,
        // alignment: Alignment.centerRight,
        child: MaterialButton(
          minWidth: 29,
          onPressed: () {
            Navigator.pop(context);
          },
          color: Color(0xFFA9151D),
          textColor: Colors.white,
          child: Icon(Icons.close, size: 29),
          shape: CircleBorder(
            side: BorderSide(
              color: Colors.grey,
              width: 1.0,
              style: BorderStyle.solid,
            ),
          ),
        ),
      ),
    ],
    // mainAxisAlignment: MainAxisAlignment.center,
    // crossAxisAlignment: CrossAxisAlignment.end,
  );
}

buttonFull({
  double width = double.infinity,
  Color backgroundColor = Colors.white,
  String title = '',
  double fontSize = 18.0,
  double elevation = 5.0,
  FontWeight fontWeight = FontWeight.normal,
  Color fontColor = Colors.black,
  EdgeInsets? margin,
  EdgeInsets? padding,
  required Function callback,
}) {
  return Center(
    child: Container(
      width: width,
      margin: margin,
      child: Material(
        elevation: elevation,
        borderRadius: BorderRadius.circular(10.0),
        color: backgroundColor,
        child: MaterialButton(
          padding: padding,
          height: 40,
          onPressed: () {
            callback();
          },
          child: Text(
            title,
            style: TextStyle(
              fontSize: fontSize,
              color: fontColor,
              fontWeight: fontWeight,
              fontFamily: 'Kanit',
            ),
          ),
        ),
      ),
    ),
  );
}


buttonCenter(
    {required BuildContext context,
    Color backgroundColor = Colors.white,
    String title = '',
    double fontSize = 18.0,
    Color fontColor = Colors.black,
    EdgeInsets? margin,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 40.0),
    required Function callback}) {
  return Center(
    child: Container(
      margin: margin,
      child: Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(10.0),
        color: backgroundColor,
        child: MaterialButton(
          padding: padding,
          height: 40,
          onPressed: () {
            callback();
          },
          child: new Text(
            title,
            style: new TextStyle(
              fontSize: fontSize,
              color: fontColor,
              fontWeight: FontWeight.normal,
              fontFamily: 'Kanit',
            ),
          ),
        ),
      ),
    ),
  );
}
