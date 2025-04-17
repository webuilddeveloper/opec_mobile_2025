import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:opec/shared/api_provider.dart';
import 'package:opec/widget/dialog.dart';
import 'package:opec/widget/header.dart';
import 'package:opec/widget/text_form_field.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
// import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ConnectSocialPage extends StatefulWidget {
  @override
  _ConnectSocialPageState createState() => _ConnectSocialPageState();
}

class _ConnectSocialPageState extends State<ConnectSocialPage> {
  final storage = FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();

  String _facebookID = '';
  String _appleID = '';
  String _googleID = '';
  String _lineID = '';
  String _category = '';
  String _code = '';
  String _username = '';
  late Map userProfile;

  String categorySelected = "";

  final txtUsername = TextEditingController();
  final txtPassword = TextEditingController();
  final txtConPassword = TextEditingController();

  bool showTxtPasswordOld = true;
  bool showTxtPassword = true;
  bool showTxtConPassword = true;
  final bool _isOnlyWebLogin = false;

  bool showIsEdit = false;
  String linkAccount = '';

  DateTime selectedDate = DateTime.now();
  TextEditingController dateCtl = TextEditingController();

  Future<dynamic> futureModel = Future.value(null);

  ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    txtUsername.dispose();
    txtPassword.dispose();
    txtConPassword.dispose();
    super.dispose();
  }

  @override
  void initState() {
    readStorage();
    super.initState();
  }

  Future<dynamic> readUser() async {
    final result = await postObjectData("m/Register/read", {'code': _code});

    if (result['status'] == 'S') {
      await storage.write(
        key: 'dataUserLoginOPEC',
        value: jsonEncode(result['objectData'][0]),
      );

      if (result['objectData'][0]['password'] == '') {
        setState(() {
          showIsEdit = true;
        });
      }

      setState(() {
        txtUsername.text = result['objectData'][0]['username'] ?? '';
        txtPassword.text = result['objectData'][0]['password'] ?? '';
        // _imageUrl = result['objectData'][0]['imageUrl'] ?? '';
        _facebookID = result['objectData'][0]['facebookID'] ?? '';
        _appleID = result['objectData'][0]['appleID'] ?? '';
        _googleID = result['objectData'][0]['googleID'] ?? '';
        _lineID = result['objectData'][0]['lineID'] ?? '';
        _code = result['objectData'][0]['code'] ?? '';
      });
    }
  }

  Future<dynamic> submitConnectSocial() async {
    var value = await storage.read(key: 'dataUserLoginOPEC') ?? "";
    var user = json.decode(value);
    user['appleID'] = _appleID;
    user['googleID'] = _googleID;
    user['lineID'] = _lineID;
    user['facebookID'] = _facebookID;
    user['category'] = _category;

    String password = categorySelected == 'guest' ? txtPassword.text : '';
    var criteria = {
      'code': user['code'],
      'appleID': _appleID,
      'googleID': _googleID,
      'lineID': _lineID,
      'password': password,
      'username': txtUsername.text,
      'facebookID': _facebookID,
      'category': categorySelected,
      'linkAccount': user['linkAccount'],
    };

    final result = await postDio(
      '${server}m/Register/linkAccount/create',
      criteria,
    );

    //reset category;
    if (result != null) {
      await storage.write(key: 'dataUserLoginOPEC', value: jsonEncode(result));
      readStorage();
      setState(() {
        categorySelected = '';
      });

      return showDialog(
        context: context,
        builder:
            (BuildContext context) => CupertinoAlertDialog(
              title: Text(
                'เชื่อมต่อบัญชีเรียบร้อยแล้ว',
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
                    "ยกเลิก",
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
    } else {
      setState(() {
        categorySelected = '';
      });
      return showDialog(
        context: context,
        builder:
            (BuildContext context) => CupertinoAlertDialog(
              title: Text(
                'เชื่อมต่อบัญชีไม่สำเร็จ',
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
                    "ยกเลิก",
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
  }

  Future<dynamic> submitUnLinkConnectSocial(String getCategory) async {
    var value = await storage.read(key: 'dataUserLoginOPEC') ?? "";
    var user = json.decode(value);
    var result;

    if (user['category'] != getCategory) {
      user['category'] = getCategory;
      result = await postDio('${server}m/Register/linkAccount/delete', user);
    }

    if (result != null) {
      await storage.write(key: 'dataUserLoginOPEC', value: jsonEncode(result));
      readStorage();
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => UserInformationPage(),
      //   ),
      // );

      return showDialog(
        context: context,
        builder:
            (BuildContext context) => CupertinoAlertDialog(
              title: Text(
                'ยกเลิกการเชื่อมต่อบัญชีเรียบร้อยแล้ว',
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
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
      );
    } else {
      return showDialog(
        context: context,
        builder:
            (BuildContext context) => CupertinoAlertDialog(
              title: Text(
                'ยกเลิกการเชื่อมต่อบัญชีไม่สำเร็จ',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Kanit',
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
              ),
              content: Text(
                '',
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
  }

  readStorage() async {
    var value = await storage.read(key: 'dataUserLoginOPEC') ?? "";
    var user = json.decode(value);

    if (user['code'] != '') {
      setState(() {
        linkAccount = user['linkAccount'];
        // _imageUrl = user['imageUrl'] ?? '';
        _facebookID = user['facebookID'] ?? '';
        _appleID = user['appleID'] ?? '';
        _googleID = user['googleID'] ?? '';
        _lineID = user['lineID'] ?? '';
        _code = user['code'] ?? '';
        _username = user['username'] ?? '';
        // _password = user['password'] ?? '';
        txtUsername.text = user['username'] ?? '';
        txtPassword.text = user['password'] ?? '';
        futureModel = readUser();
      });
    }
  }

  getGuestAccount() async {
    var value = await storage.read(key: 'dataUserLoginOPEC') ?? "";
    var user = json.decode(value);
    if (user['linkAccount'] != '' && user['linkAccount'] != null) {
      return postDio('${server}m/register/linkAccount/check', {
        'linkAccount': user['linkAccount'],
        'category': 'guest',
      });
    } else if (user['category'] == 'guest') {
      return postDio('${server}m/register/read', {
        'code': user['code'],
        'category': 'guest',
      });
    } else {
      return Future.value({});
    }
  }

  //login appleID
  // final Future<bool> _isAvailableFuture = AppleSignIn.isAvailable();

  //login line sdk
  void loginWithLine() async {
    try {
      final loginOption = LoginOption(
        _isOnlyWebLogin,
        'normal',
        requestCode: 8192,
      );

      final result = await LineSDK.instance.login(
        scopes: ["profile", "openid", "email"],
        option: loginOption,
      );

      // final idToken = result.accessToken.idToken;
      // final userEmail =
      //     (idToken != null)
      //         ? idToken['email'] != null
      //             ? idToken['email']
      //             : ''
      //         : '';

      setState(() {
        // _email = userEmail.toString() ?? '';
        _category = 'line';
        _lineID = (result.userProfile?.userId ?? "").toString();
      });
      submitConnectSocial();
    } on PlatformException catch (e) {
      switch (e.code.toString()) {
        case "CANCEL":
          print(
            "คุณยกเลิกการเข้าสู่ระบบ เมื่อสักครู่คุณกดยกเลิกการเข้าสู่ระบบ กรุณาเข้าสู่ระบบใหม่อีกครั้ง",
          );
          break;
        case "AUTHENTICATION_AGENT_ERROR":
          print(
            "คุณไม่อนุญาติการเข้าสู่ระบบด้วย LINE เมื่อสักครู่คุณกดยกเลิกการเข้าสู่ระบบ กรุณาเข้าสู่ระบบใหม่อีกครั้ง",
          );
          break;
        default:
          print(
            "เกิดข้อผิดพลาด เกิดข้อผิดพลาดไม่ทราบสาเหตุ กรุณาเข้าสู่ระบบใหม่อีกครั้ง${e.code}",
          );
          break;
      }
    }
  }

  //login google
  Future<dynamic> loginWithGoogle() async {
    final GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: <String>[
        'email',
        'https://www.googleapis.com/auth/contacts.readonly',
      ],
    );

    try {
      final result = await _googleSignIn.signIn();

      setState(() {
        // _email = result.email.toString() ?? '';
        _category = 'google';
        _googleID = (result?.id ?? "").toString();
      });
      submitConnectSocial();
    } catch (err) {
      print(err);
    }
  }

  //login facebook
  // static final FacebookLogin facebookSignIn = new FacebookLogin();
  // Future<dynamic> loginWithFacebook() async {
  //   final FacebookLoginResult result = await facebookSignIn.logIn(
  //     [
  //       'email',
  //       'public_profile',
  //     ],
  //   );

  //   switch (result.status) {
  //     case FacebookLoginStatus.loggedIn:
  //       final token = result.accessToken.token;
  //       final graphResponse = await http.get(
  //         'https://graph.facebook.com/v2.12/me?fields=email,name,first_name,middle_name,last_name,about,picture.type(large)&access_token=${token}',
  //       );

  //       if (graphResponse.statusCode == 200) {
  //         final profile = json.decode(graphResponse?.body);
  //         setState(() {
  //           userProfile = profile;
  //         });

  //         setState(() {
  //           _email = userProfile['email'].toString() ?? '';
  //           _category = 'facebook';
  //           _facebookID = userProfile['id'].toString();
  //         });

  //         submitConnectSocial();
  //       }

  //       break;
  //     case FacebookLoginStatus.cancelledByUser:
  //       print('Login cancelled by the user.');
  //       break;
  //     case FacebookLoginStatus.error:
  //       print('Something went wrong with the login process.\n'
  //           'Here\'s the error Facebook gave us: ${result.errorMessage}');
  //       break;
  //   }
  // }

  Row rowContentButton(
    String urlImage,
    String title,
    String getIDSocial, {
    Function()? press,
  }) {
    return Row(
      children: <Widget>[
        Container(
          width: 35.0,
          height: 35.0,
          child: Padding(
            padding: EdgeInsets.all(2.0),
            child: Image.asset(urlImage, height: 20.0, width: 20.0),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.normal,
              fontFamily: 'Kanit',
            ),
          ),
        ),
        InkWell(
          onTap: press,
          child: Text(
            getIDSocial == '' ? 'เชื่อมต่อ' : 'ยกเลิกการเชื่อมต่อ',
            style: TextStyle(
              fontSize: 14.0,
              color: getIDSocial == '' ? Color(0xFF9A1120) : Color(0xFFFC4137),
              fontWeight: FontWeight.normal,
              fontFamily: 'Kanit',
            ),
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        context,
        () => Navigator.pop(context, false),
        title: 'การเชื่อมต่อ',
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<dynamic>(
        future: futureModel,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Container(color: Colors.white, child: dialogFail(context)),
            );
          } else {
            return ListView(
              controller: scrollController,
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 20),
              physics: ClampingScrollPhysics(),
              children: <Widget>[
                SizedBox(height: 20),
                rowContentButton(
                  "assets/logo/socials/facebook.png",
                  "Facebook",
                  _facebookID,
                  press:
                      () => {
                        categorySelected = 'facebook',
                        if (_facebookID == '')
                          {
                            // loginWithFacebook(),
                          }
                        else if (linkAccount != '')
                          {submitUnLinkConnectSocial('facebook')},
                      },
                ),
                Divider(),
                rowContentButton(
                  "assets/logo/socials/line.png",
                  "Line",
                  _lineID,
                  press:
                      () => {
                        categorySelected = 'line',
                        if (_lineID == '')
                          {loginWithLine()}
                        else if (linkAccount != '')
                          {submitUnLinkConnectSocial('line')},
                      },
                ),
                Divider(),
                rowContentButton(
                  "assets/logo/socials/google.png",
                  "Google",
                  _googleID,
                  press:
                      () => {
                        categorySelected = "google",
                        if (_googleID == '')
                          {loginWithGoogle()}
                        else if (linkAccount != '')
                          {submitUnLinkConnectSocial('google')},
                      },
                ),
                Divider(),
                Row(
                  children: <Widget>[
                    Container(
                      width: 35.0,
                      height: 35.0,
                      child: Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Image.asset(
                          "assets/logo/logo.png",
                          height: 20.0,
                          width: 20.0,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'เข้าใช้ด้วยบัญชี สช. On Mobile',
                        style: TextStyle(
                          fontSize: 14.0,
                          // color: Color(0xFF9A1120),
                          fontWeight: FontWeight.normal,
                          fontFamily: 'Kanit',
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(),
                FutureBuilder(
                  future: getGuestAccount(),
                  builder: (context, guestAccount) {
                    if (guestAccount.hasData) {
                      var data = guestAccount.data as List;
                      if (data.isNotEmpty) {
                        showIsEdit = false;
                      } else {
                        showIsEdit = true;
                      }
                      return buildForm();
                    } else {
                      return Container(
                        height: 200,
                        child: Center(
                          child: Container(
                            height: 50,
                            width: 50,
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      );
                    }
                  },
                ),
                SizedBox(height: 40),
              ],
            );
          }
        },
      ),
    );
  }

  Form buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: labelTextFormField('* ชื่อผู้ใช้งาน'),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: textFormField(
              txtUsername,
              null,
              'ชื่อผู้ใช้งาน',
              'ชื่อผู้ใช้งาน',
              _username != '' ? false : true,
              false,
              false,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: labelTextFormFieldPasswordOldNew('* รหัสผ่าน', true),
          ),
          buildFieldWithVisibility(
            controller: txtPassword,
            enabled: showIsEdit,
            isVisibility: showTxtPassword,
            press:
                () => setState(() {
                  showTxtPassword = !showTxtPassword;
                }),
            validator: (model) {
              if (model.isEmpty) {
                return 'กรุณากรอกรหัสผ่านใหม่.';
              }

              String pattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9]).{6,}$';
              RegExp regex = RegExp(pattern);
              if (!regex.hasMatch(model)) {
                return 'กรุณากรอกรูปแบบรหัสผ่านให้ถูกต้อง.';
              }
            },
          ),
          if (showIsEdit)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: labelTextFormField('* ยืนยันรหัสผ่าน'),
            ),
          if (showIsEdit)
            buildFieldWithVisibility(
              controller: txtConPassword,
              enabled: showIsEdit,
              isVisibility: showTxtConPassword,
              press:
                  () => setState(() {
                    showTxtConPassword = !showTxtConPassword;
                  }),
              validator: (model) {
                if (model.isEmpty) {
                  return 'กรุณากรอกยืนยันรหัสผ่านใหม่.';
                }

                if (model != txtPassword.text) {
                  return 'กรุณากรอกรหัสผ่านให้ตรงกัน.';
                }

                String pattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9]).{6,}$';
                RegExp regex = RegExp(pattern);
                if (!regex.hasMatch(model)) {
                  return 'กรุณากรอกรูปแบบรหัสผ่านให้ถูกต้อง.';
                }
              },
            ),
          SizedBox(height: 20),
          if (showIsEdit)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Stack(
                children: [
                  Container(
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Color(0xFF9A1120),
                    ),
                    child: Text(
                      'ยืนยัน',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                        fontFamily: 'Kanit',
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        splashColor: Colors.red.withOpacity(0.5),
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        onTap: () {
                          final form = _formKey.currentState;
                          setState(() {
                            categorySelected = 'guest';
                          });
                          if (form != null && form.validate()) {
                            form.save();
                            submitConnectSocial();
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Container buildFieldWithVisibility({
    required TextEditingController controller,
    bool isVisibility = false,
    bool enabled = false,
    required Function validator,
    required Function press,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: TextFormField(
        obscureText: isVisibility,
        style: TextStyle(
          color: enabled ? Color(0xFF9A1120) : Colors.white,
          fontWeight: FontWeight.normal,
          fontFamily: 'Kanit',
          fontSize: 15.0,
        ),
        decoration: InputDecoration(
          suffixIcon: IconButton(
            icon: Icon(isVisibility ? Icons.visibility : Icons.visibility_off),
            onPressed: () => press(),
          ),
          filled: true,
          fillColor: enabled ? Color(0xFFEEBA33) : Color(0xFF707070),
          contentPadding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
          hintText: 'ยืนยันรหัสผ่านใหม่',
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
        validator: (value) => validator(value),
        controller: controller,
        enabled: enabled,
      ),
    );
  }
}
