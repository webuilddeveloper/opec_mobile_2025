import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:opec/version.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
   // ตั้งค่าภาษาเป็นไทย
  Intl.defaultLocale = 'th';
  initializeDateFormatting();

  // เรียกให้ Flutter พร้อมใช้งาน
  WidgetsFlutterBinding.ensureInitialized();

  // เริ่มต้น Firebase
  await Firebase.initializeApp();

  // รอให้ LineSDK ตั้งค่าเสร็จเรียบร้อย
  await LineSDK.instance.setup('1654861103').then((_) {
    print('LineSDK Prepared');
  });

  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF9A1120),
        ).copyWith(
          secondary: Color(
            0xFF9A1120,
          ), // กำหนด secondary เป็นสีเดียวกับ seedColor
        ),
        scaffoldBackgroundColor: Color(0xffe9ebee),
        primaryColor: Color(0xFF9A1120),
        primaryColorDark: Color(0xFFEEBA33),
        primaryColorLight: Color(0xFFdec6c6),
        unselectedWidgetColor: Color(0xFF6f0100),
        fontFamily: 'Kanit',
      ),
      title: 'สช. On Mobile.',
      home: VersionPage(),
    );
  }
}