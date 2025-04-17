import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:opec/shared/api_provider.dart';
import 'package:opec/widget/header.dart';
import 'package:opec/widget/text_form_field.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'login.dart';

class RegisterPage extends StatefulWidget {
  final String username;
  final String password;
  final String facebookID;
  final String appleID;
  final String googleID;
  final String lineID;
  final String email;
  final String imageUrl;
  final String category;
  final String prefixName;
  final String firstName;
  final String lastName;
  final bool isShowStep1 = true;
  final bool isShowStep2 = false;

  RegisterPage({
    Key? key,
    required this.username,
    required this.password,
    required this.facebookID,
    required this.appleID,
    required this.googleID,
    required this.lineID,
    required this.email,
    required this.imageUrl,
    required this.category,
    required this.prefixName,
    required this.firstName,
    required this.lastName,
  }) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final storage = FlutterSecureStorage();

  final String _username = '';

  bool _isShowStep1 = true;
  bool _isShowStep2 = false;
  bool _checkedValue = false;
  // Register _register;
  List<dynamic> _dataPolicy = [];

  final _formKey = GlobalKey<FormState>();

  final txtUsername = TextEditingController();
  final txtPassword = TextEditingController();
  final txtConPassword = TextEditingController();
  final txtFirstName = TextEditingController();
  final txtLastName = TextEditingController();
  final txtPhone = TextEditingController();
  final txtEmail = TextEditingController();
  final txtPrefixName = TextEditingController();

  DateTime selectedDate = DateTime.now();
  TextEditingController txtDate = TextEditingController();

  Future<dynamic> futureModel = Future.value(null);

  ScrollController scrollController = ScrollController();

  int _selectedDay = 0;
  int _selectedMonth = 0;
  int _selectedYear = 0;
  int year = 0;
  int month = 0;
  int day = 0;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    txtUsername.dispose();
    txtPassword.dispose();
    txtConPassword.dispose();
    txtFirstName.dispose();
    txtLastName.dispose();
    super.dispose();
  }

  @override
  void initState() {
    var now = DateTime.now();
    setState(() {
      year = now.year;
      month = now.month;
      day = now.day;
      _selectedYear = now.year;
      _selectedMonth = now.month;
      _selectedDay = now.day;

      futureModel = readPolicy();
    });

    super.initState();
  }

  Future<dynamic> readPolicy() async {
    final result = await postObjectData('m/policy/read', {
      'username': this._username,
      'category': 'register',
    });

    if (result['status'] == 'S') {
      if (result['objectData'].length > 0) {
        setState(() {
          _dataPolicy = [..._dataPolicy, ...result['objectData']];
        });
      }
    }
  }

  Future<Null> checkValueStep1() async {
    if (_checkedValue) {
      setState(() {
        _isShowStep1 = false;
        _isShowStep2 = true;
        scrollController.jumpTo(scrollController.position.minScrollExtent);
      });
    } else {
      return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () {
              return Future.value(false);
            },
            child: CupertinoAlertDialog(
              title: Text(
                'กรุณาติ้ก ยอมรับข้อตกลงเงื่อนไข',
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
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        },
      );
    }
  }

  Future<dynamic> submitRegister() async {
    final result = await postLoginRegister('m/Register/create', {
      'username': txtUsername.text,
      'password': txtPassword.text,
      'facebookID': "",
      'appleID': "",
      'googleID': "",
      'lineID': "",
      'email': txtEmail.text,
      'imageUrl': "",
      'category': "guest",
      'prefixName': txtPrefixName.text,
      'firstName': txtFirstName.text,
      'lastName': txtLastName.text,
      'phone': txtPhone.text,
      'birthDay': DateFormat(
        "yyyyMMdd",
      ).format(DateTime(_selectedYear, _selectedMonth, _selectedDay)),
      'status': "N",
      'platform': Platform.operatingSystem.toString(),
      'countUnit': "[]",
    });

    if (result.status == 'S') {
      return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () {
              return Future.value(false);
            },
            child: CupertinoAlertDialog(
              title: Text(
                'ลงทะเบียนเรียบร้อยแล้ว',
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
                    goBack();
                    // Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        },
      );
    } else {
      return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () {
              return Future.value(false);
            },
            child: CupertinoAlertDialog(
              title: Text(
                result.message ?? "",
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
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        },
      );
    }
  }

  myWizard() {
    return ListView(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      children: [
        Container(
          padding: EdgeInsets.only(
            top: 0.0,
            left: 30.0,
            right: 30.0,
            bottom: 0.0,
          ),
          child: Column(
            children: <Widget>[
              Row(
                children: [
                  Column(
                    children: <Widget>[
                      Container(
                        width: 50.0,
                        height: 50.0,
                        padding: EdgeInsets.all(5),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color:
                              _isShowStep1
                                  ? Color(0xFFFFC324)
                                  : Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.all(Radius.circular(25.0)),
                          border: Border.all(
                            color: Color(0xFFFFC324),
                            width: 2.0,
                          ),
                        ),
                        child: Text(
                          '1',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20.0,
                            color: _isShowStep1 ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Kanit',
                          ),
                        ),
                      ),
                      Text(
                        'ข้อตกลง',
                        style: TextStyle(
                          fontSize: 10.0,
                          color: Colors.white,
                          fontWeight: FontWeight.w100,
                          fontFamily: 'Kanit',
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.all(5),
                        height: 2.0,
                        color: Color(0xFFFFC324),
                      ),
                    ),
                  ),
                  Column(
                    children: <Widget>[
                      Container(
                        width: 50.0,
                        height: 50.0,
                        padding: EdgeInsets.all(5),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color:
                              _isShowStep2
                                  ? Color(0xFFFFC324)
                                  : Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.all(Radius.circular(25.0)),
                          border: Border.all(
                            color: Color(0xFFFFC324),
                            width: 2.0,
                          ),
                        ),
                        child: Text(
                          '2',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20.0,
                            color: _isShowStep2 ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Kanit',
                          ),
                        ),
                      ),
                      Text(
                        'ข้อมูลส่วนตัว',
                        style: TextStyle(
                          fontSize: 10.0,
                          color: Colors.white,
                          fontWeight: FontWeight.w100,
                          fontFamily: 'Kanit',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  card() {
    return Card(
      color: Colors.white,
      // shape: RoundedRectangleBorder(
      //   borderRadius: BorderRadius.circular(15.0),
      // ),
      // elevation: 5,
      child: Padding(padding: EdgeInsets.all(0), child: formContentStep2()),
      // child: _isShowStep1 ? formContentStep1() : formContentStep2()),
    );
  }

  formContentStep1() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (var item in _dataPolicy)
          Html(
            data: item['description'].toString(),
            onLinkTap:
                (url, attributes, element) => launchUrl(Uri.parse(url ?? "")),
          ),
        Container(
          alignment: Alignment.center,
          child: CheckboxListTile(
            activeColor: Color(0xFFA9151D),
            title: Text(
              "ฉันยอมรับข้อตกลงในการบริการ",
              style: TextStyle(
                fontSize: 10.0,
                fontWeight: FontWeight.normal,
                fontFamily: 'Kanit',
              ),
            ),
            value: _checkedValue,
            onChanged: (newValue) {
              setState(() {
                _checkedValue = newValue ?? false;
              });
            },
            controlAffinity:
                ListTileControlAffinity.leading, //  <-- leading Checkbox
          ),
        ),
        Container(
          alignment: Alignment.topRight,
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 0.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFFC324), // สีพื้นหลัง
              foregroundColor: Colors.white, // สีข้อความ
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: BorderSide(color: Color(0xFFFFC324)), // ขอบของปุ่ม
              ),
            ),
            onPressed: () {
              checkValueStep1();
            },
            child: Text(
              "ถัดไป >",
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.white,
                fontWeight: FontWeight.normal,
                fontFamily: 'Kanit',
              ),
            ),
          ),
        ),
      ],
    );
  }

  formContentStep2() {
    return (Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'ข้อมูลผู้ใช้งาน',
            style: TextStyle(
              // fontSize: 14.00,
              fontFamily: 'Kanit',
              fontWeight: FontWeight.w500,
              // color: Color(0xFFBC0611),
            ),
          ),
          // SizedBox(height: 5.0),
          labelTextFormField('ชื่อผู้ใช้งาน', mandatory: true),
          textFormField(
            txtUsername,
            null,
            'ชื่อผู้ใช้งาน',
            'ชื่อผู้ใช้งาน',
            true,
            false,
            false,
          ),
          // labelTextFormField('* รหัสผ่าน'),
          labelTextFormFieldPasswordOldNew('รหัสผ่าน', true, mandatory: true),
          textFormField(
            txtPassword,
            txtConPassword.text,
            'รหัสผ่าน',
            'รหัสผ่าน',
            true,
            true,
            false,
          ),
          labelTextFormField('ยืนยันรหัสผ่าน', mandatory: true),
          TextFormField(
            obscureText: true,
            style: TextStyle(
              color: Color(0xFFA9151D),
              // fontWeight: FontWeight.normal,
              fontFamily: 'Kanit',
              // fontSize: 15.00,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: Color(0xFFEEBA33),
              contentPadding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
              // hintText: hintText,
              // focusedBorder: UnderlineInputBorder(
              //   borderSide: BorderSide(color: Colors.amber, width: 0.5),
              // ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide.none,
              ),
              errorStyle: TextStyle(
                fontWeight: FontWeight.normal,
                fontFamily: 'Kanit',
                fontSize: 10.0,
              ),
            ),
            validator: (model) {
              model = model ?? "";
              if (model.isEmpty) {
                return 'กรุณากรอกข้อมูล. $model';
              }
              if (model != txtPassword.text) {
                return 'กรุณากรอกรหัสผ่านให้ตรงกัน.';
              }
              return null;
            },
            controller: txtConPassword,
            enabled: true,
          ),

          SizedBox(height: 15.0),
          Text(
            'ข้อมูลส่วนตัว',
            style: TextStyle(
              // fontSize: 18.00,
              fontFamily: 'Kanit',
              fontWeight: FontWeight.w500,
              // color: Color(0xFFBC0611),
            ),
          ),
          // SizedBox(height: 5.0),
          labelTextFormField('คำนำหน้า', mandatory: true),
          textFormField(
            txtPrefixName,
            null,
            'คำนำหน้า',
            'คำนำหน้า',
            true,
            false,
            false,
          ),
          labelTextFormField('ชื่อ', mandatory: true),
          textFormField(txtFirstName, null, 'ชื่อ', 'ชื่อ', true, false, false),
          labelTextFormField('นามสกุล', mandatory: true),
          textFormField(
            txtLastName,
            null,
            'นามสกุล',
            'นามสกุล',
            true,
            false,
            false,
          ),

          labelTextFormField('เบอร์โทรศัพท์ (10 หลัก)', mandatory: true),
          textFormPhoneField(
            txtPhone,
            'เบอร์โทรศัพท์ (10 หลัก)',
            'เบอร์โทรศัพท์ (10 หลัก)',
            true,
            true,
          ),
          labelTextFormField('อีเมล', mandatory: true),
          textFormField(txtEmail, null, 'อีเมล', 'อีเมล', true, false, true),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              margin: EdgeInsets.only(top: 15.0, bottom: 10.0),
              child: Material(
                elevation: 5.0,
                borderRadius: BorderRadius.circular(5.0),
                color: Color(0xFF9A1120),
                child: MaterialButton(
                  minWidth: MediaQuery.of(context).size.width,
                  height: 40,
                  onPressed: () {
                    final form = _formKey.currentState;
                    if (form != null && form.validate()) {
                      if (txtConPassword.text == txtPassword.text) {
                        form.save();
                        submitRegister();
                      }
                    } else {}
                  },
                  child: Text(
                    'สมัครสมาชิก',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                      fontFamily: 'Kanit',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }

  void goBack() async {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: futureModel,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // return Center(child: Text('Please wait its loading...'));
          // return Center(
          //   child: CircularProgressIndicator(),
          // );
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/background/login.png"),
                fit: BoxFit.cover,
              ),
            ),
          );
        } else {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return GestureDetector(
              onHorizontalDragUpdate: (details) {
                // Note: Sensitivity is integer used when you don't want to mess up vertical drag
                if (details.delta.dx > 10) {
                  // Right Swipe
                  Navigator.pop(context);
                }
              },

              child: Scaffold(
                appBar: header(context, goBack, title: 'สมัครสมาชิก'),
                backgroundColor: Colors.white,
                body: Container(
                  child: ListView(
                    controller: scrollController,
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    padding: const EdgeInsets.all(15.0),
                    children: <Widget>[
                      // myWizard(),
                      // card(),
                      formContentStep2(),
                    ],
                  ),
                ),
              ),
            );
          }
        }
      },
    );
  }
}
