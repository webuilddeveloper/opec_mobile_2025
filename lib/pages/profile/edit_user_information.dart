import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:opec/menu.dart';
import 'package:opec/shared/api_provider.dart';
import 'package:opec/widget/dialog.dart';
import 'package:opec/widget/header.dart';
import 'package:opec/widget/text_form_field.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as dtpicker;

class EditUserInformationPage extends StatefulWidget {
  @override
  _EditUserInformationPageState createState() =>
      _EditUserInformationPageState();
}

class _EditUserInformationPageState extends State<EditUserInformationPage> {
  final storage = FlutterSecureStorage();

  String _imageUrl = '';
  late String _code;

  final _formKey = GlobalKey<FormState>();

  String _selectedSex = '';

  String _selectedPosition = '';

  String _selectedProvince = '';

  String _selectedDistrict = '';

  String _selectedSubDistrict = '';

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

  late XFile? _image;

  int _selectedDay = 0;
  int _selectedMonth = 0;
  int _selectedYear = 0;
  int year = 0;
  int month = 0;
  int day = 0;

  String _categorySocial = '';
  String _imageUrlSocial = '';

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
  void initState() {
    futureModel = getUser();

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
    var categorySocial = await storage.read(key: 'categorySocial');
    // print('----------------categorySocial---$categorySocial-------------');
    if (categorySocial != '' && categorySocial != null)
      setState(() {
        _categorySocial = categorySocial;
      });

    var imageUrlSocial = await storage.read(key: 'imageUrlSocial');
    if (imageUrlSocial != '' && imageUrlSocial != null)
      setState(() {
        _imageUrlSocial = imageUrlSocial;
      });

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
          _selectedSex = result['objectData']['sex'] ?? '';
          _selectedPosition = result['objectData']['position'] ?? '';
        });
      }
    }
  }

  Future<dynamic> submitUpdateUser() async {
    var value = await storage.read(key: 'dataUserLoginOPEC') ?? "";
    var user = json.decode(value);
    user['imageUrl'] = _imageUrl;
    // user['prefixName'] = _selectedPrefixName;
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
    user['appleID'] = user['appleID'] != null ? user['appleID'] : "";
    user['position'] = _selectedPosition;

    // print('------------------------$_selectedPosition--------------------');
    final result = await postObjectData('m/Register/update', user);

    if (result['status'] == 'S') {
      await storage.write(
        key: 'dataUserLoginOPEC',
        value: jsonEncode(result['objectData']),
      );
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => UserInformationPage(),
      //   ),
      // );

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
                'อัพเดตข้อมูลเรียบร้อยแล้ว',
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
                      color: Color(0xFF9A1120),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => Menu()),
                      (Route<dynamic> route) => false,
                    );
                    // goBack();
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
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () {
              return Future.value(false);
            },
            child: CupertinoAlertDialog(
              title: Text(
                'อัพเดตข้อมูลไม่สำเร็จ',
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
        },
      );
    }
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
        // _selectedPrefixName = user['prefixName'];
        txtPrefixName.text = user['prefixName'] ?? '';
        _code = user['code'];
        _selectedProvince = user['provinceCode'] ?? '';
        _selectedDistrict = user['amphoeCode'] ?? '';
        _selectedSubDistrict = user['tambonCode'] ?? '';
        _selectedPostalCode = user['postnoCode'] ?? '';
      });

      if (user['birthDay'] != '') {
        var date = user['birthDay'];
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
        padding: const EdgeInsets.all(15.0),
        child: ListView(
          controller: scrollController,
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          // mainAxisAlignment: MainAxisAlignment.start,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
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

            labelTextFormField('อีเมล'),
            textFormFieldNoValidator(txtEmail, 'อีเมล', false, false),
            SizedBox(height: 15.0),
            labelTextFormField('เบอร์โทรศัพท์ (10 หลัก)', mandatory: true),
            textFormPhoneField(
              txtPhone,
              'เบอร์โทรศัพท์ (10 หลัก)',
              'เบอร์โทรศัพท์ (10 หลัก)',
              true,
              false,
            ),

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
          ],
        ),
      ),
    );
  }

  rowContentButton(String urlImage, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        children: <Widget>[
          Container(
            child: Padding(
              padding: EdgeInsets.all(5.0),
              child: Image.asset(urlImage, height: 5.0, width: 5.0),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: Color(0xFF0B5C9E),
            ),
            width: 30.0,
            height: 30.0,
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

  _imgFromCamera() async {
    // File image = await ImagePicker.pickImage(
    //   source: ImageSource.camera,
    //   imageQuality: 100,
    // );

    final ImagePicker _picker = ImagePicker();
    // Pick an image
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = image;
    });
    _upload();
  }

  _imgFromGallery() async {
    // File image = await ImagePicker.pickImage(
    //   source: ImageSource.gallery,
    //   imageQuality: 100,
    // );

    final ImagePicker _picker = ImagePicker();
    // Pick an image
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
    });

    _upload();
  }

  _imgFromNow() async {
    setState(() {
      _imageUrl = _imageUrlSocial;
    });
  }

  void _upload() async {
    if (_image == null) return;

    uploadImage(_image!)
        .then((res) {
          setState(() {
            _imageUrl = res;
          });
        })
        .catchError((err) {
          print(err);
        });
  }

  void _showPickerImage(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.photo_library),
                  title: Text(
                    'อัลบั้มรูปภาพ',
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Kanit',
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    _imgFromGallery();
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo_camera),
                  title: Text(
                    'กล้องถ่ายรูป',
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Kanit',
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    _imgFromCamera();
                    Navigator.of(context).pop();
                  },
                ),
                if (_categorySocial != '')
                  ListTile(
                    leading: Icon(Icons.photo_camera),
                    title: Text(
                      ' ใช้รูปโปรไฟล์จาก ' + _categorySocial,
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Kanit',
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    onTap: () {
                      _imgFromNow();
                      Navigator.of(context).pop();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void goBack() async {
    Navigator.pop(context, false);
    // Navigator.of(context).pushAndRemoveUntil(
    //   MaterialPageRoute(
    //     builder: (context) => UserInformationPage(),
    //   ),
    //   (Route<dynamic> route) => false,
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, goBack, title: 'ข้อมูลผู้ใช้งาน'),
      backgroundColor: Color(0xFFFFFFFF),
      body: FutureBuilder<dynamic>(
        future: futureModel,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Container(color: Colors.white, child: dialogFail(context)),
            );
          } else {
            return Container(
              child: ListView(
                controller: scrollController,
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.fill,
                            image: AssetImage(
                              'assets/background/backgroundUserInfo.png',
                            ),
                          ),
                        ),
                        height: 150.0,
                      ),
                      Container(
                        height: 150.0,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.fill,
                            image: AssetImage(
                              'assets/background/backgroundUserInfoColor.png',
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          width: 90.0,
                          height: 90.0,
                          margin: EdgeInsets.only(top: 30.0),
                          padding: EdgeInsets.all(
                            _imageUrl != '' ? 0.0 : 5.0,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(45),
                            color: Colors.white70,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              _showPickerImage(context);
                            },
                            child:
                                _imageUrl != ''
                                    ? CircleAvatar(
                                      backgroundColor: Colors.black,
                                      backgroundImage:
                                          _imageUrl != ''
                                              ? NetworkImage(_imageUrl)
                                              : null,
                                    )
                                    : Container(
                                      padding: EdgeInsets.all(10.0),
                                      child: Image.asset(
                                        'assets/images/user_not_found.png',
                                        color: Theme.of(context).colorScheme.secondary,
                                      ),
                                    ),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          width: 25.0,
                          height: 25.0,
                          margin: EdgeInsets.only(top: 90.0, left: 70.0),
                          child: Padding(
                            padding: EdgeInsets.all(0.0),
                            child: DecoratedBox(
                              decoration: ShapeDecoration(
                                shape: CircleBorder(),
                                image: DecorationImage(
                                  fit: BoxFit.contain,
                                  alignment: Alignment.center,
                                  image: AssetImage(
                                    "assets/logo/icons/Group37.png",
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(color: Colors.white, child: contentCard()),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
