import 'package:flutter/material.dart';

Container imageCircle(
  BuildContext context, {
  String image = '',
  double height = 150.0,
  double width = 150.0,
  double radius = 70.0,
  EdgeInsets? margin,
}) {
  return Container(
    height: height,
    width: width,
    margin: margin,
    child: image != '' && image != 'null'
        ? CircleAvatar(
            radius: radius,
            backgroundColor: Colors.grey,
            backgroundImage: NetworkImage(image),
          )
        : Container(
            decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(width / 2)),
            padding: EdgeInsets.all(15),
            child: Image.asset(
              'assets/images/user_not_found.png',
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
  );
}
