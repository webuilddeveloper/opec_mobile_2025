import 'package:flutter/material.dart';

checkCertificateTeacher(dynamic model) {
  int codeC = int.parse(model['certificateColor']);
  Color color = Color(codeC);
  String statusName = model['certificateStatusName'];

  return Container(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      color: color,
    ),
    child: Text(
      statusName,
      style: TextStyle(
        color: Colors.white,
        fontFamily: 'Kanit',
        fontSize: 12,
        fontWeight: FontWeight.normal,
      ),
    ),
  );
}
