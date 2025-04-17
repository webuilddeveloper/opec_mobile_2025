import 'package:flutter/services.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';

Future<LoginResult> loginLine() async {
  // final loginOption = LoginOption(false, 'normal', requestCode: 8192);

  // return await LineSDK.instance.login(
  //   scopes: ["profile", "openid", "email"],
  //   option: loginOption,
  // );

  return await LineSDK.instance.login(scopes: ["profile", "openid", "email"]);
}

Future<void> logoutLine() async {
  try {
    await LineSDK.instance.logout();
  } on PlatformException catch (e) {
    print(e.message);
  }
  // LineSDK.instance.logout();
}
