import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:opec/menu.dart';
import 'package:opec/pages/auth/register.dart';
import 'dart:io';
import 'package:opec/shared/api_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:opec/shared/apple_firebase.dart';
import 'package:opec/shared/google.dart';
import 'package:opec/shared/line.dart';
import 'package:opec/widget/text_form_field.dart';
import 'package:url_launcher/url_launcher.dart';
import 'forgot_password.dart';

DateTime now = DateTime.now();
void main() {
  // Intl.defaultLocale = 'th';

  runApp(LoginPage());
}

class LoginPage extends StatefulWidget {
  LoginPage({Key? key, this.title}) : super(key: key);
  final String? title;
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final storage = FlutterSecureStorage();

  String _username = '';
  String _password = '';
  String _facebookID = '';
  String _appleID = '';
  String _googleID = '';
  String _lineID = '';
  String _email = '';
  String _imageUrl = '';
  String _category = '';
  String _prefixName = '';
  String _firstName = '';
  String _lastName = '';

  late Map userProfile;
  bool _loadingSubmit = false;

  final txtUsername = TextEditingController();
  final txtPassword = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    txtUsername.dispose();
    txtPassword.dispose();

    super.dispose();
  }

  @override
  void initState() {
    setState(() {
      _username = "";
      _password = "";
      _facebookID = "";
      _appleID = "";
      _googleID = "";
      _lineID = "";
      _email = "";
      _imageUrl = "";
      _category = "";
      _prefixName = "";
      _firstName = "";
      _lastName = "";
    });
    // checkStatus();
    super.initState();
  }

  void checkStatus() async {
    final storage = FlutterSecureStorage();
    String value = await storage.read(key: 'dataUserLoginOPEC') ?? "";
    if (value != '') {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          // builder: (context) => PermissionRegisterPage(),
          builder: (context) => Menu(),
        ),
        (Route<dynamic> route) => false,
      );
    }
  }

  //login username / password
  Future<dynamic> login() async {
    if ((_username == '') && _category == 'guest') {
      setState(() => _loadingSubmit = false);
      return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: Text(
            'กรุณากรอกชื่อผู้ใช้',
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
    } else if ((_password == '') && _category == 'guest') {
      setState(() => _loadingSubmit = false);
      return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: Text(
            'กรุณากรอกรหัสผ่าน',
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
      // String url = _category == 'guest'
      //     ? 'm/Register/login'
      //     : 'm/Register/$_category/login';

      // final result = await postLoginRegister(url, {
      //   'username': _username.toString(),
      //   'password': _password.toString(),
      //   'category': _category.toString(),
      //   'email': _email.toString(),
      // });
      Dio dio = Dio();
      var response = await dio.post(
        '$gatewayEndpoint/py-api/opec/register/read',
        data: {
          'username': _username.toString(),
          'password': _password.toString(),
          'category': _category.toString(),
        },
      );

      dynamic result;
      setState(() {
        result = response.data;
      });
      if (result['code'] == 200) {
        await storage.write(
          key: 'dataUserLoginOPEC',
          value: jsonEncode(result['data'][0]),
        );

        await createStorageApp(category: _category.toString(), model: {
          'code': result['data'][0]['code'],
          'imageUrl': result['data'][0]['imageUrl'],
          'firstName': result['data'][0]['firstName'],
          'lastName': result['data'][0]['lastName']
        });

        setState(() => _loadingSubmit = false);

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            // builder: (context) => PermissionRegisterPage(),
            builder: (context) => Menu(),
          ),
          (Route<dynamic> route) => false,
        );
      } else {
        setState(() => _loadingSubmit = false);
        if (_category == 'guest') {
          return showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) => CupertinoAlertDialog(
              title: Text(
                result['message'],
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
          setState(() => _loadingSubmit = false);
          register();
        }
      }
    }
  }

  Future<dynamic> register() async {
    final result = await postDio('m/Register/create', {
      'username': _username,
      'password': _password,
      'category': _category,
      'email': _email,
      'facebookID': _facebookID,
      'appleID': _appleID,
      'googleID': _googleID,
      'lineID': _lineID,
      'imageUrl': _imageUrl,
      'prefixName': _prefixName,
      'firstName': _firstName,
      'lastName': _lastName,
      'status': "N",
      'platform': Platform.operatingSystem.toString(),
      'birthDay': "",
      'phone': "",
      'countUnit': "[]"
    });

    if (result.status == 'S') {
      await storage.write(
        key: 'dataUserLoginOPEC',
        value: jsonEncode(result.objectData),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => Menu(),
        ),
        (Route<dynamic> route) => false,
      );
    } else {
      return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: Text(
            result.message,
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
    }
  }

  //login guest
  void loginWithGuest() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _loadingSubmit = true;
      _category = 'guest';
      _username = txtUsername.text;
      _password = txtPassword.text;
      _facebookID = "";
      _appleID = "";
      _googleID = "";
      _lineID = "";
      _email = "";
      _imageUrl = "";
      _prefixName = "";
      _firstName = "";
      _lastName = "";
    });

    await storage.write(
      key: 'imageUrlSocial',
      value: '',
    );

    await storage.write(
      key: 'categorySocial',
      value: '',
    );
    login();
  }

  TextStyle style = TextStyle(
    fontFamily: 'Kanit',
    fontSize: 18.0,
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          return Future.value(false);
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              Image.asset(
                "assets/background/login.png",
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
              ),
              Column(
                children: [
                  Expanded(
                    child: _listViewloging(),
                  ),
                  Container(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: (MediaQuery.of(context).size.height / 100) * 8,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                              "assets/background/backgroundFooter.png"),
                          fit: BoxFit.fill,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'ยังไม่มีบัญชีผู้ใช้?',
                            style: TextStyle(
                              fontSize: 17.00,
                              fontFamily: 'Kanit',
                              color: Color(0XFFFFFFFF),
                            ),
                          ),
                          SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      RegisterPage(
                                    username: "",
                                    password: "",
                                    facebookID: "",
                                    appleID: "",
                                    googleID: "",
                                    lineID: "",
                                    email: "",
                                    imageUrl: "",
                                    category: "guest",
                                    prefixName: "",
                                    firstName: "",
                                    lastName: "",
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              "สมัครสมาชิก",
                              style: TextStyle(
                                fontSize: 17.00,
                                fontFamily: 'Kanit',
                                fontWeight: FontWeight.w500,
                                color: Color(0XFFFFFFFF),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              if (_loadingSubmit)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.4),
                    alignment: Alignment.center,
                    child: Container(
                      height: 80,
                      width: 80,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: CircularProgressIndicator(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  _listViewloging() {
    final loginButon = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(10.0),
      color: Color(0xFFA9151D),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        height: 40,
        onPressed: () {
          loginWithGuest();
        },
        child: Text(
          'เข้าสู่ระบบ',
          style: TextStyle(
            fontSize: 18.0,
            color: Colors.white,
            fontWeight: FontWeight.normal,
            fontFamily: 'Kanit',
          ),
        ),
      ),
    );

    return ListView(
      padding: EdgeInsets.all(10),
      physics: ClampingScrollPhysics(),
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
          ),
        ),
        Row(
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              height: 50.0,
              child: Image.asset(
                "assets/background/logoLogin.png",
                fit: BoxFit.contain,
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.only(left: 70.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Text(
                    //   'สำนักงานคณะกรรมการส่งเสริม',
                    //   style: TextStyle(
                    //     fontSize: 16.00,
                    //     fontFamily: 'Kanit',
                    //     fontWeight: FontWeight.w500,
                    //     color: Colors.white,
                    //   ),
                    //   textAlign: TextAlign.center,
                    // ),
                    Text(
                      'การศึกษาเอกชน',
                      style: TextStyle(
                        fontSize: 20.00,
                        fontFamily: 'Kanit',
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height > 640 ? 20.0 : 0,
        ),
        Container(
          child: Container(
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 10,
              child: Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          'เข้าสู่ระบบ',
                          style: TextStyle(
                            fontSize: 18.00,
                            fontFamily: 'Kanit',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Text(
                        //   ' (สำหรับสมาชิก)',
                        //   style: TextStyle(
                        //     fontSize: 15.00,
                        //     fontFamily: 'Kanit',
                        //     fontWeight: FontWeight.w100,
                        //   ),
                        // ),
                      ],
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height > 640
                            ? 20
                            : 10.0),
                    labelTextField(
                      'ชื่อผู้ใช้งาน',
                      Icon(
                        Icons.person,
                        color: Color(0xFF6F0100),
                        size: 20.00,
                      ),
                    ),
                    SizedBox(
                        height:
                            MediaQuery.of(context).size.height > 640 ? 5.0 : 0),
                    textField(
                      txtUsername,
                      null,
                      'ชื่อผู้ใช้งาน',
                      'ชื่อผู้ใช้งาน',
                      true,
                      false,
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height > 640
                            ? 15
                            : 10.0),
                    labelTextField(
                      'รหัสผ่าน',
                      Icon(
                        Icons.lock,
                        color: Color(0xFF6F0100),
                        size: 20.00,
                      ),
                    ),
                    SizedBox(
                        height:
                            MediaQuery.of(context).size.height > 640 ? 5.0 : 0),
                    textField(
                      txtPassword,
                      null,
                      'รหัสผ่าน',
                      'รหัสผ่าน',
                      true,
                      true,
                    ),
                    SizedBox(
                      height:
                          MediaQuery.of(context).size.height > 640 ? 30 : 20.0,
                    ),
                    loginButon,
                    SizedBox(
                      height:
                          MediaQuery.of(context).size.height > 640 ? 10 : 5.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ForgotPasswordPage(),
                              ),
                            );
                          },
                          child: Text(
                            "ลืมรหัสผ่าน",
                            style: TextStyle(
                              fontSize: 12.00,
                              fontFamily: 'Kanit',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(width: 15),
                        Text(
                          '|',
                          style: TextStyle(
                            fontSize: 15.00,
                            fontFamily: 'Kanit',
                            color: Color(0XFF9A1120),
                          ),
                        ),
                        SizedBox(width: 15),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    RegisterPage(
                                  username: "",
                                  password: "",
                                  facebookID: "",
                                  appleID: "",
                                  googleID: "",
                                  lineID: "",
                                  email: "",
                                  imageUrl: "",
                                  category: "guest",
                                  prefixName: "",
                                  firstName: "",
                                  lastName: "",
                                ),
                              ),
                            );
                          },
                          child: Text(
                            "สมัครสมาชิก",
                            style: TextStyle(
                              fontSize: 12.00,
                              fontFamily: 'Kanit',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '',
                          style: TextStyle(
                            fontSize: 14.00,
                            fontFamily: 'Kanit',
                          ),
                        ),
                        Text(
                          ' หรือเข้าสู่ระบบโดย ',
                          style: TextStyle(
                            fontSize: 14.00,
                            fontFamily: 'Kanit',
                            color: Color(0xFF6F0100),
                          ),
                        ),
                        Text(
                          '',
                          style: TextStyle(
                            fontSize: 14.00,
                            fontFamily: 'Kanit',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height:
                          MediaQuery.of(context).size.height > 640 ? 8 : 5.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        if (Platform.isIOS)
                          Container(
                            alignment: FractionalOffset(0.5, 0.5),
                            height: 50.0,
                            width: 50.0,
                            child: IconButton(
                              onPressed: () async {
                                pressApple();
                              },
                              icon: Image.asset(
                                "assets/logo/socials/apple.png",
                              ),
                              padding: EdgeInsets.all(5.0),
                            ),
                          ),
                        Container(
                          alignment: FractionalOffset(0.5, 0.5),
                          height: 50.0,
                          width: 50.0,
                          child: IconButton(
                            onPressed: () async {
                              pressFacebook();
                            },
                            icon: Image.asset(
                              "assets/logo/socials/Group379.png",
                            ),
                            padding: EdgeInsets.all(5.0),
                          ),
                        ),
                        Container(
                          alignment: FractionalOffset(0.5, 0.5),
                          height: 50.0,
                          width: 50.0,
                          child: IconButton(
                            onPressed: () async {
                              pressGoogle();
                            },
                            icon: Image.asset(
                              "assets/logo/socials/Group380.png",
                            ),
                            padding: EdgeInsets.all(5.0),
                          ),
                        ),
                        Container(
                          alignment: FractionalOffset(0.5, 0.5),
                          height: 50.0,
                          width: 50.0,
                          child: IconButton(
                            onPressed: () async {
                              pressLine();
                            },
                            icon: Image.asset(
                              "assets/logo/socials/Group381.png",
                            ),
                            padding: EdgeInsets.all(5.0),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height > 640 ? 15.0 : 0,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'หากผ่านหน้าจอนี้ไป แสดงว่าคุณยอมรับ',
              style: TextStyle(
                fontSize: 13.00,
                fontFamily: 'Kanit',
                fontWeight: FontWeight.w500,
                color: Color(0xFF707070),
              ),
            ),
            InkWell(
              onTap: () {
                // launchUrl(
                //   Uri.parse('https://policy.we-builds.com/opec'),
                //   mode: LaunchMode.externalApplication,
                // );
                launchUrl(Uri.parse('https://policy.we-builds.com/opec/'));
              },
              child: Text(
                'นโยบายความเป็นส่วนตัว',
                style: TextStyle(
                  fontSize: 13.00,
                  fontFamily: 'Kanit',
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0000FF),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 90),
      ],
    );
  }

  pressApple() async {
    FocusScope.of(context).unfocus();
    try {
      setState(() => _loadingSubmit = true);
      var obj = await signInWithApple();

      // print(
      //     '----- email ----- ${obj.credential}');
      // print(obj.credential.identityToken[4]);
      // print(obj.credential.identityToken[8]);

      var model = {
        "username": obj.user?.email ?? obj.user?.uid,
        "email": obj.user?.email ?? '',
        "imageUrl": '',
        "firstName": obj.user?.email,
        "lastName": '',
        "appleID": obj.user?.uid
      };

      Dio dio = Dio();
      var response = await dio.post(
        '${server}m/v2/register/apple/login',
        data: model,
      );

      await createStorageApp(
        model: response.data['objectData'],
        category: 'apple',
      );

      setState(() => _loadingSubmit = false);
      if (obj.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            // builder: (context) =>
            //     PermissionRegisterPage(),
            builder: (context) => Menu(),
          ),
        );
      }
    } catch (e) {
      setState(() => _loadingSubmit = false);
    }
  }

  pressFacebook() async {
    final LoginResult result = await FacebookAuth.instance
        .login(); // by default we request the email and the public profile
    // or FacebookAuth.i.login()
    if (result.status == LoginStatus.success) {
      // you are logged
      final AccessToken? accessToken = result.accessToken;

      // user is logged
      print(accessToken.toString());
      final userData = await FacebookAuth.i.getUserData();
      print(userData['email'].toString());

      try {
        setState(() => _loadingSubmit = true);

        var model = {
          "username": userData['email'].toString(),
          "email": userData['email'].toString(),
          "imageUrl": userData['picture']['data']['url'].toString(),
          "firstName": userData['name'].toString(),
          "lastName": '',
          "facebookID": userData['id'].toString()
        };

        Dio dio = Dio();
        var response = await dio.post(
          '${server}m/v2/register/facebook/login',
          data: model,
        );

        setState(() async {
          _loadingSubmit = false;

          await storage.write(
            key: 'categorySocial',
            value: 'Facebook',
          );

          await storage.write(
            key: 'imageUrlSocial',
            value: userData['picture']['data']['url'].toString(),
          );

          await createStorageApp(
            model: response.data['objectData'],
            category: 'facebook',
          );

          if (accessToken != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Menu(),
              ),
            );
          }
        });

        // setState(() => _loadingSubmit = false);
      } catch (e) {
        setState(() => _loadingSubmit = false);
      }
        } else {
      print(result.status);
      print(result.message);
    }

  }

  pressGoogle() async {
    FocusScope.of(context).unfocus();
    try {
      setState(() => _loadingSubmit = true);

      var obj = await signInWithGoogle();
      print('----- Login Google ----- ' + obj.toString());
      if (obj.user != null) {
        var model = {
          "username": obj.user?.email,
          "email": obj.user?.email,
          "imageUrl": obj.user?.photoURL ?? '',
          "firstName": obj.user?.displayName,
          "lastName": '',
          "googleID": obj.user?.uid
        };

        Dio dio = Dio();
        var response = await dio.post(
          '${server}m/v2/register/google/login',
          data: model,
        );

        await storage.write(
          key: 'categorySocial',
          value: 'Google',
        );

        await storage.write(
          key: 'imageUrlSocial',
          value: obj.user?.photoURL ?? '',
        );

        await createStorageApp(
          model: response.data['objectData'],
          category: 'google',
        );

        setState(() => _loadingSubmit = false);
        if (obj.user != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Menu(),
            ),
          );
        }
      }
      setState(() => _loadingSubmit = false);
    } catch (e) {
      setState(() => _loadingSubmit = false);
    }
  }

  pressLine() async {
    FocusScope.of(context).unfocus();
    try {
      setState(() => _loadingSubmit = true);
      var obj = await loginLine();
      // _buildDialog(obj.toString());
      // print('----- obj -----' +
      //     obj.toString());
      final idToken = obj.accessToken.idToken;
      // _buildDialog('----- idToken -----' +
      //     idToken.toString());

      // _buildDialog(idToken.toString());
      // print('----- idToken -----' +
      //     idToken.toString());
      final userEmail = (idToken != null)
          ? idToken['email'] ?? ''
          : '';

      // _buildDialog('----- userEmail -----' +
      //     userEmail);

      // _buildDialog(
      //     '----- userProfile -----' +
      //         obj.userProfile.toString());

      var model = {
        "username": (userEmail != '' && userEmail != null)
            ? userEmail
            : obj.userProfile?.userId,
        "email": userEmail,
        "imageUrl": (obj.userProfile?.pictureUrl != '' &&
                obj.userProfile?.pictureUrl != null)
            ? obj.userProfile?.pictureUrl
            : '',
        "firstName": obj.userProfile?.displayName,
        "lastName": '',
        "lineID": obj.userProfile?.userId
      };

      Dio dio = Dio();
      var response = await dio.post(
        '${server}m/v2/register/line/login',
        data: model,
      );


      await storage.write(
        key: 'categorySocial',
        value: 'Line',
      );

      await storage.write(
        key: 'imageUrlSocial',
        value: model['imageUrl'],
      );

      await createStorageApp(
        model: response.data['objectData'],
        category: 'line',
      );

      setState(() => _loadingSubmit = false);

      if (obj.userProfile != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            // builder: (context) =>
            //     PermissionRegisterPage(),
            builder: (context) => Menu(),
          ),
        );
      }
          setState(() => _loadingSubmit = false);
    } catch (e) {
      setState(() => _loadingSubmit = false);
    }
  }
}
