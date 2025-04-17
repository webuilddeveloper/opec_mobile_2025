import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:opec/menu.dart';
import 'package:opec/pages/auth/login.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Future<dynamic> futureModel = Future.value(null);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _callTimer(3);
    return _buildSplash();
  }

  _buildSplash() {
    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: Scaffold(
        body: Image.asset(
          'assets/splash.png',
          fit: BoxFit.cover,
          height: double.infinity,
          width: double.infinity,
        ),
      ),
    );
  }

  _callTimer(time) async {
    var _duration = new Duration(seconds: time);
    return new Timer(_duration, _callNavigatorPage);
  }

  _callNavigatorPage() async {
    final storage = new FlutterSecureStorage();
    String value = await storage.read(key: 'profileCode25') ?? "";
    if (value != '') {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => Menu(),
        ),
        (Route<dynamic> route) => false,
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => LoginPage(),
          // builder: (context) => MenuV2(),
        ),
        (Route<dynamic> route) => false,
      );
    }
  }
}
