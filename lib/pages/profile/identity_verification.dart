import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:opec/pages/auth/login.dart';
import 'package:opec/pages/profile/organization.dart';
import 'package:opec/shared/api_provider.dart';
import 'package:opec/widget/dialog.dart';
import 'package:opec/widget/header.dart';
import 'package:opec/widget/text_form_field.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as dtpicker;

class IdentityVerificationPage extends StatefulWidget {
  @override
  _IdentityVerificationPageState createState() =>
      _IdentityVerificationPageState();
}

class _IdentityVerificationPageState extends State<IdentityVerificationPage> {
  final storage = FlutterSecureStorage();

  late String _imageUrl;
  late String _code;
  late String _username;

  final _formKey = GlobalKey<FormState>();

  final String _selectedSex = '';

  final String _selectedMemberType = '';

  List<dynamic> _itemProvince = [];
  String _selectedProvince = '';

  List<dynamic> _itemDistrict = [];
  String _selectedDistrict = '';

  List<dynamic> _itemSubDistrict = [];
  String _selectedSubDistrict = '';

  List<dynamic> _itemPostalCode = [];
  String _selectedPostalCode = '';

  final txtEmail = TextEditingController();
  final txtPassword = TextEditingController();
  final txtConPassword = TextEditingController();
  final txtPrefixName = TextEditingController();
  final txtFirstName = TextEditingController();
  final txtLastName = TextEditingController();
  final txtPhone = TextEditingController();
  final txtUsername = TextEditingController();
  final txtIdCard = TextEditingController();
  final txtLineID = TextEditingController();
  final txtOfficerCode = TextEditingController();
  final txtAddress = TextEditingController();
  final txtMoo = TextEditingController();
  final txtSoi = TextEditingController();
  final txtRoad = TextEditingController();

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

  bool openOrganization = false;
  int totalLv = 0;

  List<dynamic> dataCountUnit = [];

  List<dynamic> dataPolicy = [];

  @override
  void initState() {
    // readStorage();
    getUser();
    // getProvince();

    scrollController = ScrollController();
    var now = DateTime.now();
    setState(() {
      year = now.year;
      month = now.month;
      day = now.day;
      _selectedYear = now.year;
      _selectedMonth = now.month;
      _selectedDay = now.day;
    });
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    txtEmail.dispose();
    txtPassword.dispose();
    txtConPassword.dispose();
    txtFirstName.dispose();
    txtLastName.dispose();
    txtPhone.dispose();
    txtDate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: futureModel,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Container(color: Colors.white, child: dialogFail(context)),
          );
        } else {
          return Scaffold(
            appBar: header(context, goBack, title: 'ข้อมูลสมาชิก'),
            backgroundColor: Color(0xFFFFFFFF),
            body: Container(
              child: ListView(
                controller: scrollController,
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                children: <Widget>[
                  Container(color: Colors.white, child: contentCard()),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Future<dynamic> getPolicy() async {
    final result = await postObjectData("m/policy/read", {
      "category": "application",
      "username": _username,
    });
    if (result['status'] == 'S') {
      if (result['objectData'].length > 0) {
        for (var i in result['objectData']) {
          result['objectData'][i].isActive = "";
          result['objectData'][i].agree = false;
          result['objectData'][i].noAgree = false;
        }
        setState(() {
          dataPolicy = result['objectData'];
        });
      }
    }
  }

  Future<dynamic> getProvince() async {
    final result = await postObjectData("route/province/read", {});
    if (result['status'] == 'S') {
      setState(() {
        _itemProvince = result['objectData'];
      });
    }
  }

  Future<dynamic> getDistrict() async {
    final result = await postObjectData("route/district/read", {
      'province': _selectedProvince,
    });
    if (result['status'] == 'S') {
      setState(() {
        _itemDistrict = result['objectData'];
      });
    }
  }

  Future<dynamic> getSubDistrict() async {
    final result = await postObjectData("route/tambon/read", {
      'province': _selectedProvince,
      'district': _selectedDistrict,
    });
    if (result['status'] == 'S') {
      setState(() {
        _itemSubDistrict = result['objectData'];
      });
    }
  }

  Future<dynamic> getPostalCode() async {
    final result = await postObjectData("route/postcode/read", {
      'tambon': _selectedSubDistrict,
    });
    if (result['status'] == 'S') {
      setState(() {
        _itemPostalCode = result['objectData'];
      });
    }
  }

  bool isValidDate(String input) {
    try {
      final date = DateTime.parse(input);
      final originalFormatString = toOriginalFormatString(date);
      return input == originalFormatString;
    } catch (e) {
      return false;
    }
  }

  String toOriginalFormatString(DateTime dateTime) {
    final y = dateTime.year.toString().padLeft(4, '0');
    final m = dateTime.month.toString().padLeft(2, '0');
    final d = dateTime.day.toString().padLeft(2, '0');
    return "$y$m$d";
  }

  Future<dynamic> getUser() async {
    var value = await storage.read(key: 'dataUserLoginOPEC') ?? "";

    var user = json.decode(value);

    if (user['code'] != '') {
      setState(() {
        _code = user['code'];
      });

      final result = await postObjectData("m/Register/read", {'code': _code});

      if (result['status'] == 'S') {
        await storage.write(
          key: 'dataUserLoginOPEC',
          value: jsonEncode(result['objectData']),
        );

        if (result['objectData']['birthDay'] != '') {
          if (isValidDate(result['objectData']['birthDay'])) {
            var date = result['objectData']['birthDay'];
            var year = date.substring(0, 4);
            var month = date.substring(4, 6);
            var day = date.substring(6, 8);
            DateTime todayDate = DateTime.parse(year + '-' + month + '-' + day);
            setState(() {
              _selectedYear = todayDate.year;
              _selectedMonth = todayDate.month;
              _selectedDay = todayDate.day;
              txtDate.text = DateFormat("dd-MM-yyyy").format(todayDate);
            });
          }
        }

        setState(() {
          _username = result['objectData']['username'] ?? '';
          dataCountUnit =
              result['objectData']['countUnit'] != ''
                  ? json.decode(result['objectData']['countUnit'])
                  : [];
          _imageUrl = result['objectData']['imageUrl'] ?? '';
          txtFirstName.text = result['objectData']['firstName'] ?? '';
          txtLastName.text = result['objectData']['lastName'] ?? '';
          txtEmail.text = result['objectData']['email'] ?? '';
          txtPhone.text = result['objectData']['phone'] ?? '';
          // _selectedPrefixName = result['objectData']['prefixName'];
          _code = result['objectData']['code'] ?? '';
          txtPhone.text = result['objectData']['phone'] ?? '';
          txtUsername.text = result['objectData']['username'] ?? '';
          txtIdCard.text = result['objectData']['idcard'] ?? '';
          txtLineID.text = result['objectData']['lineID'] ?? '';
          txtOfficerCode.text = result['objectData']['officerCode'] ?? '';
          txtAddress.text = result['objectData']['address'] ?? '';
          txtMoo.text = result['objectData']['moo'] ?? '';
          txtSoi.text = result['objectData']['soi'] ?? '';
          txtRoad.text = result['objectData']['road'] ?? '';
          txtPrefixName.text = result['objectData']['prefixName'] ?? '';

          _selectedProvince = result['objectData']['provinceCode'] ?? '';
          _selectedDistrict = result['objectData']['amphoeCode'] ?? '';
          _selectedSubDistrict = result['objectData']['tambonCode'] ?? '';
          _selectedPostalCode = result['objectData']['postnoCode'] ?? '';
          // _selectedSex = result['objectData']['sex'] ?? '';
          // _selectedMemberType = result['objectData']['memberType'] ?? '';
        });
      }
      if (_selectedProvince != '') {
        getPolicy();
        getProvince();
        getDistrict();
        getSubDistrict();
        setState(() {
          futureModel = getPostalCode();
        });
      } else {
        getPolicy();
        setState(() {
          futureModel = getProvince();
        });
      }
    }
  }

  Future<dynamic> submitUpdateUser() async {
    var codeLv0 = "";
    var codeLv1 = "";
    var codeLv2 = "";
    var codeLv3 = "";
    var codeLv4 = "";
    var codeLv5 = "";

    // var dataRow = dataCountUnit;
    for (var i in dataCountUnit) {
      if (codeLv0 != "") {
        codeLv0 = codeLv0 + "," + i['lv0'];
      } else {
        codeLv0 = i['lv0'];
      }

      if (codeLv1 != "") {
        codeLv1 = codeLv1 + "," + i['lv1'];
      } else {
        codeLv1 = i['lv1'];
      }

      if (codeLv2 != "") {
        codeLv2 = codeLv2 + "," + i['lv2'];
      } else {
        codeLv2 = i['lv2'];
      }

      if (codeLv3 != "") {
        codeLv3 = codeLv3 + "," + i['lv3'];
      } else {
        codeLv3 = i['lv3'];
      }

      if (codeLv4 != "") {
        codeLv4 = codeLv4 + "," + i['lv4'];
      } else {
        codeLv4 = i['lv4'];
      }
      if (codeLv5 != "") {
        codeLv5 = codeLv4 + "," + i['lv4'];
      } else {
        codeLv5 = i['lv4'];
      }
    }


    var value = await storage.read(key: 'dataUserLoginOPEC') ?? "";
    var user = json.decode(value);
    user['imageUrl'] = _imageUrl;
    // user['prefixName'] = _selectedPrefixName ?? '';
    user['prefixName'] = txtPrefixName.text;
    user['firstName'] = txtFirstName.text;
    user['lastName'] = txtLastName.text;
    user['email'] = txtEmail.text;
    user['phone'] = txtPhone.text;

    user['birthDay'] = DateFormat(
      "yyyyMMdd",
    ).format(DateTime(_selectedYear, _selectedMonth, _selectedDay));
    user['sex'] = _selectedSex;
    user['address'] = txtAddress.text;
    user['soi'] = txtSoi.text;
    user['moo'] = txtMoo.text;
    user['road'] = txtRoad.text;
    user['tambon'] = '';
    user['amphoe'] = '';
    user['province'] = '';
    user['postno'] = '';
    user['tambonCode'] = _selectedSubDistrict;
    user['amphoeCode'] = _selectedDistrict;
    user['provinceCode'] = _selectedProvince;
    user['postnoCode'] = _selectedPostalCode;
    user['idcard'] = txtIdCard.text;
    user['officerCode'] = txtOfficerCode.text;
    user['linkAccount'] =
        user['linkAccount'] != null ? user['linkAccount'] : '';
    user['countUnit'] = json.encode(dataCountUnit);
    user['lv0'] = codeLv0;
    user['lv1'] = codeLv1;
    user['lv2'] = codeLv2;
    user['lv3'] = codeLv3;
    user['lv4'] = codeLv4;
    user['lv5'] = codeLv5;
    user['memberType'] = _selectedMemberType;
    // user['status'] = "V";
    // user['status'] = index == -1 ? user['status'] : "V";
    user['appleID'] = user['appleID'] != null ? user['appleID'] : "";

    final result = await postObjectData('m/Register/update', user);

    if (result['status'] == 'S') {
      await storage.write(
        key: 'dataUserLoginOPEC',
        value: jsonEncode(result['objectData']),
      );

      // if (_selectedMemberType == "O") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OrganizationPage()),
      );
    } else {
      return showDialog(
        context: context,
        builder:
            (BuildContext context) => CupertinoAlertDialog(
              title: Text(
                'ยืนยันตัวตนไม่สำเร็จ',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Kanit',
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
              ),
              content: Text(
                result['message'],
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Kanit',
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
              ),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text(
                    "ตกลง",
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Kanit',
                      color: Color(0xFF9A1120),
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
    }
    // }
  }

  readStorage() async {
    var value = await storage.read(key: 'dataUserLoginOPEC') ?? "";
    var user = json.decode(value);

    if (user['code'] != '') {
      setState(() {
        _imageUrl = user['imageUrl'] ?? '';
        txtFirstName.text = user['firstName'] ?? '';
        txtLastName.text = user['lastName'] ?? '';
        txtEmail.text = user['email'] ?? '';
        txtPhone.text = user['phone'] ?? '';
        txtPrefixName.text = user['prefixName'] ?? '';
        // _selectedPrefixName = user['prefixName'];
        _code = user['code'];
      });

    }
  }

  card() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 5,
      child: Padding(padding: EdgeInsets.all(15), child: contentCard()),
    );
  }

  dialogOpenPickerDate() {
    dtpicker.DatePicker.showDatePicker(
      context,
      theme: dtpicker.DatePickerTheme(
        containerHeight: 210.0,
        itemStyle: TextStyle(
          fontSize: 16.0,
          color: Color(0xFF9A1120),
          fontWeight: FontWeight.normal,
          fontFamily: 'Kanit',
        ),
        doneStyle: TextStyle(
          fontSize: 16.0,
          color: Color(0xFF9A1120),
          fontWeight: FontWeight.normal,
          fontFamily: 'Kanit',
        ),
        cancelStyle: TextStyle(
          fontSize: 16.0,
          color: Color(0xFF9A1120),
          fontWeight: FontWeight.normal,
          fontFamily: 'Kanit',
        ),
      ),
      showTitleActions: true,
      minTime: DateTime(1800, 1, 1),
      maxTime: DateTime(year, month, day),
      onConfirm: (date) {
        setState(() {
          _selectedYear = date.year;
          _selectedMonth = date.month;
          _selectedDay = date.day;
          txtDate.value = TextEditingValue(
            text: DateFormat("dd-MM-yyyy").format(date),
          );
        });
      },
      currentTime: DateTime(_selectedYear, _selectedMonth, _selectedDay),
      locale: dtpicker.LocaleType.th,
    );
  }

  contentCard() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView(
          controller: scrollController,
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          children: <Widget>[
            Padding(padding: EdgeInsets.only(top: 5.0)),

            labelTextFormField('ชื่อ', mandatory: true),
            textFormField(
              txtFirstName,
              null,
              'ชื่อ',
              'ชื่อ',
              true,
              false,
              false,
            ),
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
            // labelTextFormField('* เบอร์โทรศัพท์ (10 หลัก)'),
            // textFormPhoneField(
            //   txtPhone,
            //   'เบอร์โทรศัพท์ (10 หลัก)',
            //   'เบอร์โทรศัพท์ (10 หลัก)',
            //   true,
            //   false,
            // ),
            labelTextFormField('วันเดือนปีเกิด', mandatory: true),
            GestureDetector(
              onTap: () => dialogOpenPickerDate(),
              child: AbsorbPointer(
                child: TextFormField(
                  controller: txtDate,
                  style: TextStyle(
                    color: Color(0xFF9A1120),
                    fontWeight: FontWeight.normal,
                    fontFamily: 'Kanit',
                    fontSize: 15.0,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFEEBA33),
                    contentPadding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
                    //hintText: "วันเดือนปีเกิด",
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
                      return 'กรุณากรอกวันเดือนปีเกิด.';
                    }
                    return null;
                  },
                ),
              ),
            ),
            labelTextFormField('รหัสประจำตัวประชาชน', mandatory: true),
            textFormIdCardField(
              txtIdCard,
              'รหัสประจำตัวประชาชน',
              'รหัสประจำตัวประชาชน',
              true,
              true,
            ),

            labelTextFormField('จังหวัด', mandatory: true),
            Container(
              width: 5000.0,
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
              decoration: BoxDecoration(
                color: Color(0xFFEEBA33),
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  (_selectedProvince != '')
                      ? DropdownButtonFormField(
                        decoration: InputDecoration(
                          errorStyle: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontFamily: 'Kanit',
                            fontSize: 10.0,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        validator:
                            (value) =>
                                value == '' || value == null
                                    ? 'กรุณาเลือกจังหวัด'
                                    : null,
                        // hint: Text(
                        //   'จังหวัด',
                        //   style: TextStyle(
                        //     fontSize: 15.00,
                        //     fontFamily: 'Kanit',
                        //   ),
                        // ),
                        value: _selectedProvince,
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          TextEditingController().clear();
                        },
                        onChanged: (newValue) {
                          setState(() {
                            _selectedDistrict = "";
                            _itemDistrict = [];
                            _selectedSubDistrict = "";
                            _itemSubDistrict = [];
                            _selectedPostalCode = "";
                            _itemPostalCode = [];
                            _selectedProvince = (newValue ?? "").toString();
                          });
                          getDistrict();
                        },
                        items:
                            _itemProvince.map((item) {
                              return DropdownMenuItem(
                                value: item['code'],
                                child: Text(
                                  item['title'],
                                  style: TextStyle(
                                    fontSize: 15.00,
                                    fontFamily: 'Kanit',
                                    color: Color(0xFF9A1120),
                                  ),
                                ),
                              );
                            }).toList(),
                      )
                      : DropdownButtonFormField(
                        decoration: InputDecoration(
                          errorStyle: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontFamily: 'Kanit',
                            fontSize: 10.0,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        validator:
                            (value) =>
                                value == '' || value == null
                                    ? 'กรุณาเลือกจังหวัด'
                                    : null,
                        // hint: Text(
                        //   'จังหวัด',
                        //   style: TextStyle(
                        //     fontSize: 15.00,
                        //     fontFamily: 'Kanit',
                        //   ),
                        // ),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedDistrict = "";
                            _itemDistrict = [];
                            _selectedSubDistrict = "";
                            _itemSubDistrict = [];
                            _selectedPostalCode = "";
                            _itemPostalCode = [];
                            _selectedProvince = (newValue ?? "").toString();
                          });
                          getDistrict();
                        },
                        items:
                            _itemProvince.map((item) {
                              return DropdownMenuItem(
                                value: item['code'],
                                child: Text(
                                  item['title'],
                                  style: TextStyle(
                                    fontSize: 15.00,
                                    fontFamily: 'Kanit',
                                    color: Color(0xFF9A1120),
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
            ),
            labelTextFormField('อำเภอ', mandatory: true),
            Container(
              width: 5000.0,
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
              decoration: BoxDecoration(
                color: Color(0xFFEEBA33),
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  (_selectedDistrict != '')
                      ? DropdownButtonFormField(
                        decoration: InputDecoration(
                          errorStyle: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontFamily: 'Kanit',
                            fontSize: 10.0,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        validator:
                            (value) =>
                                value == '' || value == null
                                    ? 'กรุณาเลือกอำเภอ'
                                    : null,
                        // hint: Text(
                        //   'อำเภอ',
                        //   style: TextStyle(
                        //     fontSize: 15.00,
                        //     fontFamily: 'Kanit',
                        //   ),
                        // ),
                        value: _selectedDistrict,
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          TextEditingController().clear();
                        },
                        onChanged: (newValue) {
                          setState(() {
                            _selectedSubDistrict = "";
                            _itemSubDistrict = [];
                            _selectedPostalCode = "";
                            _itemPostalCode = [];
                            _selectedDistrict = (newValue ?? "").toString();
                            getSubDistrict();
                          });
                        },
                        items:
                            _itemDistrict.map((item) {
                              return DropdownMenuItem(
                                value: item['code'],
                                child: Text(
                                  item['title'],
                                  style: TextStyle(
                                    fontSize: 15.00,
                                    fontFamily: 'Kanit',
                                    color: Color(0xFF9A1120),
                                  ),
                                ),
                              );
                            }).toList(),
                      )
                      : DropdownButtonFormField(
                        decoration: InputDecoration(
                          errorStyle: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontFamily: 'Kanit',
                            fontSize: 10.0,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        validator:
                            (value) =>
                                value == '' || value == null
                                    ? 'กรุณาเลือกอำเภอ'
                                    : null,
                        // hint: Text(
                        //   'อำเภอ',
                        //   style: TextStyle(
                        //     fontSize: 15.00,
                        //     fontFamily: 'Kanit',
                        //   ),
                        // ),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedSubDistrict = "";
                            _itemSubDistrict = [];
                            _selectedPostalCode = "";
                            _itemPostalCode = [];
                            _selectedDistrict = (newValue ?? "").toString();
                            getSubDistrict();
                          });
                        },
                        items:
                            _itemDistrict.map((item) {
                              return DropdownMenuItem(
                                value: item['code'],
                                child: Text(
                                  item['title'],
                                  style: TextStyle(
                                    fontSize: 15.00,
                                    fontFamily: 'Kanit',
                                    color: Color(0xFF9A1120),
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
            ),
            labelTextFormField('ตำบล', mandatory: true),
            Container(
              width: 5000.0,
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
              decoration: BoxDecoration(
                color: Color(0xFFEEBA33),
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  (_selectedSubDistrict != '')
                      ? DropdownButtonFormField(
                        decoration: InputDecoration(
                          errorStyle: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontFamily: 'Kanit',
                            fontSize: 10.0,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        validator:
                            (value) =>
                                value == '' || value == null
                                    ? 'กรุณาเลือกตำบล'
                                    : null,
                        // hint: Text(
                        //   'ตำบล',
                        //   style: TextStyle(
                        //     fontSize: 15.00,
                        //     fontFamily: 'Kanit',
                        //   ),
                        // ),
                        value: _selectedSubDistrict,
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          TextEditingController().clear();
                        },
                        onChanged: (newValue) {
                          setState(() {
                            _selectedPostalCode = "";
                            _itemPostalCode = [];
                            _selectedSubDistrict = (newValue ?? "").toString();
                            getPostalCode();
                          });
                        },
                        items:
                            _itemSubDistrict.map((item) {
                              return DropdownMenuItem(
                                value: item['code'],
                                child: Text(
                                  item['title'],
                                  style: TextStyle(
                                    fontSize: 15.00,
                                    fontFamily: 'Kanit',
                                    color: Color(0xFF9A1120),
                                  ),
                                ),
                              );
                            }).toList(),
                      )
                      : DropdownButtonFormField(
                        decoration: InputDecoration(
                          errorStyle: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontFamily: 'Kanit',
                            fontSize: 10.0,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        validator:
                            (value) =>
                                value == '' || value == null
                                    ? 'กรุณาเลือกตำบล'
                                    : null,
                        // hint: Text(
                        //   'ตำบล',
                        //   style: TextStyle(
                        //     fontSize: 15.00,
                        //     fontFamily: 'Kanit',
                        //   ),
                        // ),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedPostalCode = "";
                            _itemPostalCode = [];
                            _selectedSubDistrict = (newValue ?? "").toString();
                            getPostalCode();
                          });
                        },
                        items:
                            _itemSubDistrict.map((item) {
                              return DropdownMenuItem(
                                value: item['code'],
                                child: Text(
                                  item['title'],
                                  style: TextStyle(
                                    fontSize: 15.00,
                                    fontFamily: 'Kanit',
                                    color: Color(0xFF9A1120),
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
            ),
            labelTextFormField('รหัสไปรษณีย์', mandatory: true),
            Container(
              width: 5000.0,
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
              decoration: BoxDecoration(
                color: Color(0xFFEEBA33),
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  (_selectedPostalCode != '')
                      ? DropdownButtonFormField(
                        decoration: InputDecoration(
                          errorStyle: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontFamily: 'Kanit',
                            fontSize: 10.0,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        validator:
                            (value) =>
                                value == '' || value == null
                                    ? 'กรุณาเลือกรหัสไปรษณีย์'
                                    : null,
                        // hint: Text(
                        //   'รหัสไปรษณีย์',
                        //   style: TextStyle(
                        //     fontSize: 15.00,
                        //     fontFamily: 'Kanit',
                        //   ),
                        // ),
                        value: _selectedPostalCode,
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          TextEditingController().clear();
                        },
                        onChanged: (newValue) {
                          setState(() {
                            _selectedPostalCode = (newValue ?? "").toString();
                          });
                        },
                        items:
                            _itemPostalCode.map((item) {
                              return DropdownMenuItem(
                                value: item['code'],
                                child: Text(
                                  item['postCode'],
                                  style: TextStyle(
                                    fontSize: 15.00,
                                    fontFamily: 'Kanit',
                                    color: Color(0xFF9A1120),
                                  ),
                                ),
                              );
                            }).toList(),
                      )
                      : DropdownButtonFormField(
                        decoration: InputDecoration(
                          errorStyle: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontFamily: 'Kanit',
                            fontSize: 10.0,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        validator:
                            (value) =>
                                value == '' || value == null
                                    ? 'กรุณาเลือกรหัสไปรษณีย์'
                                    : null,
                        // hint: Text(
                        //   'รหัสไปรษณีย์',
                        //   style: TextStyle(
                        //     fontSize: 15.00,
                        //     fontFamily: 'Kanit',
                        //   ),
                        // ),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedPostalCode = (newValue ?? "").toString();
                          });
                        },
                        items:
                            _itemPostalCode.map((item) {
                              return DropdownMenuItem(
                                value: item['code'],
                                child: Text(
                                  item['postCode'],
                                  style: TextStyle(
                                    fontSize: 15.00,
                                    fontFamily: 'Kanit',
                                    color: Color(0xFF9A1120),
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
            ),
            labelTextFormField('ที่อยู่ปัจจุบัน'),
            textFormFieldNoValidator(
              txtAddress,
              'ที่อยู่ปัจจุบัน',
              true,
              false,
            ),
            labelTextFormField('หมู่ที่'),
            textFormFieldNoValidator(txtMoo, 'หมู่ที่', true, false),
            labelTextFormField('ซอย'),
            textFormFieldNoValidator(txtSoi, 'ซอย', true, false),
            labelTextFormField('ถนน'),
            textFormFieldNoValidator(txtRoad, 'ถนน', true, false),
            Padding(padding: EdgeInsets.only(top: 10.0)),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.7,
                margin: EdgeInsets.symmetric(vertical: 10.0),
                child: Material(
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(10.0),
                  color: Color(0xFF9A1120),
                  child: MaterialButton(
                    minWidth: MediaQuery.of(context).size.width,
                    height: 40,
                    onPressed: () {
                      final form = _formKey.currentState;
                      if (form != null && form.validate()) {
                        form.save();
                        submitUpdateUser();
                      }
                    },
                    child: Text(
                      'บันทึกข้อมูล',
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

            SizedBox(height: 100),
            InkWell(
              onTap: () {
                logout();
              },
              child: Container(
                alignment: Alignment.centerRight,
                child: Text('1.0.4', style: TextStyle(fontSize: 8)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void logout() async {
    var category = await storage.read(key: 'profileCategory');

    final GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: <String>[
        'email',
        'https://www.googleapis.com/auth/contacts.readonly',
      ],
    );

    if (category == 'google') {
      _googleSignIn.disconnect();
    } else if (category == 'facebook') {
      // await facebookSignIn.logOut();
    }

    // delete
    await storage.deleteAll();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  dropdownMenuItemHaveData(
    String _selected,
    List<dynamic> _item,
    String title,
  ) {
    return DropdownButtonFormField(
      decoration: InputDecoration(
        errorStyle: TextStyle(
          fontWeight: FontWeight.normal,
          fontFamily: 'Kanit',
          fontSize: 10.0,
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
      validator: (value) => value == null ? 'กรุณาเลือก' + title : null,
      hint: Text(title, style: TextStyle(fontSize: 15.00, fontFamily: 'Kanit')),
      value: _selected,
      onChanged: (newValue) {
        setState(() {
          _selected = (newValue ?? "").toString();
        });
      },
      items:
          _item.map((item) {
            return DropdownMenuItem(
              value: item['code'],
              child: Text(
                item['title'],
                style: TextStyle(
                  fontSize: 15.00,
                  fontFamily: 'Kanit',
                  color: Color(0xFF9A1120),
                ),
              ),
            );
          }).toList(),
    );
  }

  dropdownMenuItemNoHaveData(
    String _selected,
    List<dynamic> _item,
    String title,
  ) {
    return DropdownButtonFormField(
      decoration: InputDecoration(
        errorStyle: TextStyle(
          fontWeight: FontWeight.normal,
          fontFamily: 'Kanit',
          fontSize: 10.0,
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
      validator:
          (value) => value == '' || value == null ? 'กรุณาเลือก' + title : null,
      hint: Text(title, style: TextStyle(fontSize: 15.00, fontFamily: 'Kanit')),
      // value: _selected,
      onChanged: (newValue) {
        setState(() {
          _selected = (newValue ?? "").toString();
        });
      },
      items:
          _item.map((item) {
            return DropdownMenuItem(
              value: item['code'],
              child: Text(
                item['title'],
                style: TextStyle(
                  fontSize: 15.00,
                  fontFamily: 'Kanit',
                  color: Color(0xFF9A1120),
                ),
              ),
            );
          }).toList(),
    );
  }

  rowContentButton(String urlImage, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: Color(0xFF0B5C9E),
            ),
            width: 30.0,
            height: 30.0,
            child: Padding(
              padding: EdgeInsets.all(5.0),
              child: Image.asset(urlImage, height: 5.0, width: 5.0),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.63,
            margin: EdgeInsets.only(left: 10.0, right: 10.0),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12.0,
                color: Color(0xFF9A1120),
                fontWeight: FontWeight.normal,
                fontFamily: 'Kanit',
              ),
            ),
          ),
          Container(
            alignment: Alignment.centerRight,
            child: Image.asset(
              "assets/icons/Group6232.png",
              height: 20.0,
              width: 20.0,
            ),
          ),
        ],
      ),
    );
  }

  void goBack() async {
    Navigator.pop(context, false);
  }
}
