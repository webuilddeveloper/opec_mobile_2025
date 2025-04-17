import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:opec/shared/api_provider.dart';
import 'package:opec/splash.dart';
import 'package:fluttertoast/fluttertoast.dart';

dialogVersion(
  BuildContext context, {
  required String title,
  required String description,
  bool isYesNo = false,
  required Function callBack,
}) {
  return CupertinoAlertDialog(
    title: Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontFamily: 'Kanit',
        color: Colors.black,
        fontWeight: FontWeight.normal,
      ),
    ),
    content: Column(
      children: [
        Text(
          description,
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Kanit',
            color: Colors.black,
            fontWeight: FontWeight.normal,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'เวอร์ชั่นปัจจุบัน $versionName',
          style: TextStyle(
            fontSize: 12,
            fontFamily: 'Kanit',
            color: Colors.black,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    ),
    actions: [
      Container(
        color: Color(0xFF9A1120),
        child: CupertinoDialogAction(
          isDefaultAction: true,
          child: Text(
            "อัพเดท",
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Kanit',
              color: Color(0xFFFFFFFF),
              fontWeight: FontWeight.normal,
            ),
          ),
          onPressed: () {
            if (isYesNo) {
              callBack(true);
              // Navigator.pop(context, false);
            } else {
              callBack(true);
              // Navigator.pop(context, false);
            }
          },
        ),
      ),
      if (isYesNo)
        Container(
          color: Color(0xFF707070),
          child: CupertinoDialogAction(
            isDefaultAction: true,
            child: Text(
              "ภายหลัง",
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Kanit',
                color: Color(0xFFFFFFFF),
                fontWeight: FontWeight.normal,
              ),
            ),
            onPressed: () {
              callBack(false);
              Navigator.pop(context, false);
            },
          ),
        ),
    ],
  );
}

dialogFail(
  BuildContext context, {
  bool reloadApp = false,
  String title = 'การเชื่อมต่อมีปัญหากรุณาลองใหม่อีกครั้ง',
  Color background = Colors.white,
}) {
  return WillPopScope(
    onWillPop: () {
      return Future.value(reloadApp);
    },
    child: Container(
      height: double.infinity,
      width: double.infinity,
      color: background,
      child: CupertinoAlertDialog(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Kanit',
            color: Colors.black,
            fontWeight: FontWeight.normal,
          ),
        ),
        content: Text(" "),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text(
              "ตกลง",
              style: TextStyle(
                fontSize: 13,
                fontFamily: 'Kanit',
                color: Color(0xFFA9151D),
                fontWeight: FontWeight.normal,
              ),
            ),
            onPressed: () {
              reloadApp
                  ? Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => SplashPage(),
                      ),
                      (Route<dynamic> route) => false,
                    )
                  : Navigator.pop(context, false);
            },
          ),
        ],
      ),
    ),
  );
}


toastFail(
  BuildContext context, {
  String text = 'การเชื่อมต่อผิดพลาด',
  Color color = Colors.grey,
  Color fontColor = Colors.white,
  int duration = 3,
}) {
  return Fluttertoast.showToast(
    msg: text, // ข้อความที่จะแสดง
    toastLength:
        duration == 0
            ? Toast.LENGTH_SHORT
            : Toast.LENGTH_LONG, // ระยะเวลาในการแสดง Toast
    gravity: ToastGravity.BOTTOM, // ตำแหน่งการแสดง Toast
    backgroundColor: color, // สีพื้นหลัง
    textColor: fontColor, // สีของข้อความ
    fontSize: 16.0, // ขนาดตัวอักษร
  );
}

dialogBtn(BuildContext context,
    {required String title,
    required String description,
    bool isYesNo = false,
    String btnOk = 'ตกลง',
    String btnCancel = 'ยกเลิก',
    required Function callBack}) {
  return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Kanit',
              color: Colors.black,
              fontWeight: FontWeight.normal,
            ),
          ),
          content: Text(
            description,
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Kanit',
              color: Colors.black,
              fontWeight: FontWeight.normal,
            ),
          ),
          actions: [
            Container(
              color: Color(0xFF9A1120),
              child: CupertinoDialogAction(
                isDefaultAction: true,
                child: Text(
                  btnOk,
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Kanit',
                    color: Color(0xFFFFFFFF),
                    fontWeight: FontWeight.normal,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context, false);
                  callBack(true);
                },
              ),
            ),
            if (isYesNo)
              Container(
                color: Color(0xFF707070),
                child: CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text(
                    btnCancel,
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Kanit',
                      color: Color(0xFFFFFFFF),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context, false);
                    callBack(false);
                  },
                ),
              ),
          ],
        );
      });
}

dialog(BuildContext context,
    {required String title,
    required String description,
    bool isYesNo = false,
    Function? callBack}) {
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Kanit',
            color: Colors.black,
            fontWeight: FontWeight.normal,
          ),
        ),
        content: Text(
          description,
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Kanit',
            color: Colors.black,
            fontWeight: FontWeight.normal,
          ),
        ),
        actions: [
          Container(
            color: Color(0xFF9A1120),
            child: CupertinoDialogAction(
              isDefaultAction: true,
              child: Text(
                "ตกลง",
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Kanit',
                  color: Color(0xFFFFFFFF),
                  fontWeight: FontWeight.normal,
                ),
              ),
              onPressed: () {
                if (isYesNo) {
                  callBack!();
                  Navigator.pop(context, false);
                } else {
                  Navigator.pop(context, false);
                }
              },
            ),
          ),
          if (isYesNo)
            Container(
              color: Color(0xFF707070),
              child: CupertinoDialogAction(
                isDefaultAction: true,
                child: Text(
                  "ยกเลิก",
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Kanit',
                    color: Color(0xFFFFFFFF),
                    fontWeight: FontWeight.normal,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context, false);
                },
              ),
            ),
        ],
      );
    },
  );
}

dialogAppointmentInterview(
  BuildContext context, {
  String title = '',
  String description = '',
  String yes = 'ตกลง',
  String no = 'ยกเลิก',
  bool isYesNo = false,
  Function()? callBackYes,
}) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () {
          return Future.value(false);
        },
        child: AlertDialog(
          contentPadding: EdgeInsets.all(0),
          content: Container(
            padding: EdgeInsets.symmetric(horizontal: 15),
            width: MediaQuery.of(context).size.width / 2,
            height: 150,
            child: Column(
              children: [
                SizedBox(height: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: callBackYes,
                      child: Container(
                        height: 35,
                        width: 100,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: Color(0xFFEEBA33),
                        ),
                        child: Text(
                          yes,
                          style: TextStyle(
                            fontSize: 17,
                            fontFamily: 'Kanit',
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    SizedBox(width: 15),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 35,
                        width: 100,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Color(0xFF707070),
                          ),
                          color: Color(0xFFFFFFFF),
                        ),
                        child: Text(
                          no,
                          style: TextStyle(
                            fontSize: 17,
                            fontFamily: 'Kanit',
                            color: Color(0xFF707070),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // child: //Contents here
          ),
        ),
      );
    },
  );
}
