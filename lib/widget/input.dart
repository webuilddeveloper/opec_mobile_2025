import 'package:flutter/material.dart';

inputWithLabel(
    {required BuildContext context,
    required TextEditingController textEditingController,
    bool checkText = false,
    required Function callback,
    String title = '',
    double fontSizeTitle = 20.0,
    FontWeight fontWeightTitle = FontWeight.w500,
    Color fontColorTitle = Colors.black,
    String hintText = '',
    required Function validator,
    bool isShowPattern = false,
    bool hasBorder = false,
    Color enabledBorderColor = const Color(0xFF9A1120),
    Color focusedBorderColor = const Color(0xFF9A1120),
    bool isShowIcon = false,
    TextInputType? keyboardType, //TextInputType.multiline
    int maxLines = 1,
    int? maxLength,
    bool isPassword = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        child: Text(
          title,
          style: TextStyle(
            color: fontColorTitle,
            fontFamily: 'Kanit',
            fontSize: fontSizeTitle,
            fontWeight: fontWeightTitle,
          ),
        ),
      ),
      SizedBox(
        height: 9.0,
      ),
      TextFormField(
        keyboardType: keyboardType,
        maxLines: maxLines,
        maxLength: maxLength,
        obscureText: isPassword ? checkText : false,
        style: TextStyle(
          // color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.normal,
          fontFamily: 'Kanit',
          fontSize: 13.0,
        ),
        decoration: InputDecoration(
          border: hasBorder
              ? new OutlineInputBorder(
                  borderSide: new BorderSide(
                    color: Colors.red,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                )
              : null,
          enabledBorder: hasBorder
              ? OutlineInputBorder(
                  borderSide: BorderSide(
                    color: enabledBorderColor,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                )
              : null,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.only(
            left: 5.0,
            right: 5.0,
            top: 19.0,
          ),
          hintText: hintText,
          errorStyle: TextStyle(
            fontWeight: FontWeight.normal,
            fontFamily: 'Kanit',
            fontSize: 12.0,
          ),
        ),
        validator: (model) {
          return validator(model);
        },
        controller: textEditingController,
        // enabled: true,
      ),
      isShowPattern
          ? Text(
              '(รหัสผ่านต้องมีตัวอักษร A-Z, a-z และ 0-9 ความยาวขั้นต่ำ 6 ตัวอักษร)',
              style: TextStyle(
                fontSize: 10.00,
                fontFamily: 'Kanit',
                color: Color(0xFFFF0000),
              ),
            )
          : Container(),
    ],
  );
}
