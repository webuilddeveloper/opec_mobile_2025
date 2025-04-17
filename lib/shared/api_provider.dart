// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:opec/shared/facebook_firebase.dart';
import 'package:opec/shared/google.dart';
import 'package:opec/shared/line.dart';
import 'package:opec/user.dart';
import 'dart:io';

import 'package:opec/widget/dialog.dart';

const versionName = '4.0.1';
const versionNumber = 401;
const prVersion = 'user-type';
const tutorial = 'isTutorial';

// flutter build appbundle --no-tree-shake-icons
// flutter build apk --no-tree-shake-icons
// flutter build apk --build-name=3.7.0 --build-number=85

// const server = 'https://6f74-118-173-89-89.ap.ngrok.io/';
// const server = 'http://122.155.223.63/opec-api/';
const gatewayEndpoint = 'https://gateway.we-builds.com';
const server = 'https://opec.we-builds.com/opec-api/';
const serverUpload = 'https://opec.we-builds.com/opec-document/upload';
const serverLineNoti = 'https://notify-api.line.me/api/notify';
const serverOTP = 'https://portal-otp.smsmkt.com/api/';
const serverSt = 'https://core148.we-builds.com/st-api/api/Statistic/Create';

// const url = 'http://122.155.223.63';
const url = 'https://opec.we-builds.com';
const urlRegister = '$url/opec-register-api/';
const versionReadApi = '$url/opec-version-api/m/v2/version/read';
const facebookLogin = '$url/opec-register-api/m/v2/register/facebook/login';
const profileReadApi = '$url/opec-register-api/m/v4/register/read';
const isNotVerifyApi =
    '$url/opec-register-api/m/v2/register/checkOrganizationActive';

const bannerReadApi = '$url/opec-ads-api/m/Banner/main/read';
//'$url/opec-ads-api/m/v2/MainPopup/read'
const mainPopupReadApi = '$url/opec-api/m/MainPopup/read';
const rotationReadApi = '$url/opec-api/m/Rotation/';
// const bannerReadApi = '$serverTest/td-opec-api/m/Banner/main/read';
// const mainPopupReadApi = '$serverTest/td-opec-api/m/MainPopup/read';
// const rotationReadApi = '$serverTest/td-opec-api/m/Rotation/main/read';

const newsReadApi = '$url/opec-news-api/m/news/read';
const eventMarkRead2Api = '$url/opec-event-api/m/event/mark/read2';
const eventReadApi = '$url/opec-event-api/m/event/read';
const eventCategoryReadApi = '$url/opec-event-api/m/event/category/read';
const eventCommentReadApi = '$url/opec-event-api/m/event/comment/read';
const eventGalleryReadApi = '$url/opec-event-api/m/event/gallery/read';

const sharedApi = '${server}configulation/shared/';
const registerApi = '${server}m/register/';
const newsGalleryApi = '${server}m/news/gallery/read';
const newsApi = '${server}m/news/';
const eventApi = '${server}m/eventCalendar/';
const funtApi = '${server}m/funt/';
const pollApi = '${server}m/poll/';
const poiApi = '${server}m/poi/';
const poiGalleryApi = '${server}m/poi/gallery/read';
const faqApi = '${server}m/faq/';
const knowledgeApi = '${server}m/knowledge/';
const cooperativeApi = '${server}m/cooperativeForm/';
const contactApi = '${server}m/contact/';
const bannerApi = '${server}banner/';
const bannerGalleryApi = '${server}m/banner/gallery/read';
const privilegeApi = "${server}m/privilege/";
const privilegeGalleryApi = '${server}m/privilege/gallery/read';
const privilegeSpecialReadApi =
    'http://122.155.223.63/td-we-mart-api/m/privilege/opec/read';
const privilegeSpecialCategoryReadApi =
    'http://122.155.223.63/td-we-mart-api/m/privilege/category/read';

const menuApi = "${server}m/menu/";
const aboutUsApi = "${server}m/aboutus/";
const notificationApi = '${server}m/v2/notification/';
const welfareApi = '${server}m/welfare/';
const welfareGalleryApi = '${server}m/welfare/gallery/read';
const pollGalleryApi = '${server}m/poll/gallery/read';
const reporterApi = '${server}m/reporter/';
const reporterGalleryApi = '${server}m/Reporter/gallery/';
const fundApi = '${server}m/fund/';
const fileOnlineApi = '${server}m/fileOnline/';

const fundGalleryApi = '${server}m/fund/gallery/read';
const questionApi = '${server}m/question/';
const answerApi = '${server}m/answer/';

//banner
const contactBannerApi = '${server}m/Banner/contact/';
const reporterBannerApi = '${server}m/Banner/reporter/';

const teacherApi = '${server}m/teacher/';
const teacherCategoryApi = '${server}m/fund/category/';
const teacherCommentApi = '${server}m/fund/comment/';
const teacherGalleryApi = '${server}m/fund/gallery/read';

const schoolApi = '${server}m/school/';
const schoolCategoryApi = '${server}m/fund/category/';
const schoolCommentApi = '${server}m/fund/comment/';
const schoolGalleryApi = '${server}m/fund/gallery/read';

//rotation
const rotationApi = '${server}rotation/';
const mainRotationApi = '${server}m/Rotation/main/';
const rotationGalleryApi = 'm/rotation/gallery/read';

//mainPopup

const forceAdsApi = '${server}m/ForceAds/';

// comment
const newsCommentApi = '${server}m/news/comment/';
const welfareCommentApi = '${server}m/welfare/comment/';
const poiCommentApi = '${server}m/poi/comment/';
const fundCommentApi = '${server}m/fund/comment/';

//category
const knowledgeCategoryApi = '${server}m/knowledge/category/';
const cooperativeCategoryApi = '${server}m/cooperativeForm/category/';
const newsCategoryApi = '${server}m/news/category/';
const privilegeCategoryApi = '${server}m/privilege/category/';
const contactCategoryApi = '${server}m/contact/category/';
const welfareCategoryApi = '${server}m/welfare/category/';
const fundCategoryApi = '${server}m/fund/category/';
const pollCategoryApi = '${server}m/poll/category/';
const poiCategoryApi = '${server}m/poi/category/';
const reporterCategoryApi = '${server}m/reporter/category/';

const splashApi = '${server}m/splash/read';

Future<dynamic> postCategory(String url, dynamic criteria) async {
  var body = json.encode({
    "permission": "all",
    "skip": criteria['skip'] ?? 0,
    "limit": criteria['limit'] ?? 1,
    "code": criteria['code'] ?? '',
    "reference": criteria['reference'] ?? '',
    "description": criteria['description'] ?? '',
    "category": criteria['category'] ?? '',
    "keySearch": criteria['keySearch'] ?? '',
    "username": criteria['username'] ?? '',
    "isHighlight": criteria['isHighlight'] ?? false,
  });

  var response = await http.post(
    Uri.parse(url),
    body: body,
    headers: {"Accept": "application/json", "Content-Type": "application/json"},
  );

  var data = json.decode(response.body);

  List<dynamic> list = [
    {'code': "", 'title': 'ทั้งหมด'},
  ];
  list = [...list, ...data['objectData']];

  return Future.value(list);
}

Future<dynamic> post(String url, dynamic criteria) async {
  // print(url);
  // print(criteria);
  var body = json.encode({
    "permission": "all",
    "skip": criteria['skip'] ?? 0,
    "limit": criteria['limit'] ?? 1,
    "code": criteria['code'] ?? '',
    "reference": criteria['reference'] ?? '',
    "description": criteria['description'] ?? '',
    "category": criteria['category'] ?? '',
    "keySearch": criteria['keySearch'] ?? '',
    "username": criteria['username'] ?? '',
    "password": criteria['password'] ?? '',
    "email": criteria['email'] ?? '',
    "firstName": criteria['firstName'] ?? '',
    "lastName": criteria['lastName'] ?? '',
    "title": criteria['title'] ?? '',
    "answer": criteria['answer'] ?? '',
    "isHighlight": criteria['isHighlight'] ?? false,
    "createBy": criteria['createBy'] ?? '',
    "isPublic": criteria['isPublic'] ?? false,
    "imageList": criteria['imageList'] ?? [],
    "profileCode": criteria['profileCode'] ?? '',
    "phone": criteria['phone'] ?? '',
  });

  var response = await http.post(
    Uri.parse(url),
    body: body,
    headers: {"Accept": "application/json", "Content-Type": "application/json"},
  );

  var data = json.decode(response.body);
  return Future.value(data['objectData']);
}

Future<dynamic> postAny(String url, dynamic criteria) async {
  var body = json.encode({
    "permission": "all",
    "skip": criteria['skip'] ?? 0,
    "limit": criteria['limit'] ?? 1,
    "code": criteria['code'] ?? '',
    "category": criteria['category'] ?? '',
    "username": criteria['username'] ?? '',
    "password": criteria['password'] ?? '',
    "createBy": criteria['createBy'] ?? '',
    "imageUrlCreateBy": criteria['imageUrlCreateBy'] ?? '',
    "reference": criteria['reference'] ?? '',
    "description": criteria['description'] ?? '',
  });

  var response = await http.post(
    Uri.parse(url),
    body: body,
    headers: {"Accept": "application/json", "Content-Type": "application/json"},
  );

  var data = json.decode(response.body);

  return Future.value(data['status']);
}

Future<dynamic> postAnyObj(String url, dynamic criteria) async {
  var body = json.encode({
    "permission": "all",
    "skip": criteria['skip'] ?? 0,
    "limit": criteria['limit'] ?? 1,
    "code": criteria['code'] ?? '',
    "createBy": criteria['createBy'] ?? '',
    "imageUrlCreateBy": criteria['imageUrlCreateBy'] ?? '',
    "reference": criteria['reference'] ?? '',
    "description": criteria['description'] ?? '',
  });

  var response = await http.post(
    Uri.parse(url),
    body: body,
    headers: {"Accept": "application/json", "Content-Type": "application/json"},
  );

  var data = json.decode(response.body);

  return Future.value(data);
}

Future<dynamic> postLogin(String url, dynamic criteria) async {
  var body = json.encode({
    "category": criteria['category'] ?? '',
    "password": criteria['password'] ?? '',
    "username": criteria['username'] ?? '',
    "email": criteria['email'] ?? '',
  });

  var response = await http.post(
    Uri.parse(url),
    body: body,
    headers: {"Accept": "application/json", "Content-Type": "application/json"},
  );

  var data = json.decode(response.body);

  return Future.value(data['objectData']);
}

Future<dynamic> postObjectData(String url, dynamic criteria) async {
  var body = json.encode(criteria);
  var response = await http.post(
    Uri.parse(server + url),
    body: body,
    headers: {"Accept": "application/json", "Content-Type": "application/json"},
  );

  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    return {
      "status": data['status'],
      "message": data['message'],
      "objectData": data['objectData'],
    };
    // Future.value(data['objectData']);
  } else {
    return {"status": "F"};
  }
}

Future<dynamic> postObjectData2(String url, dynamic criteria) async {
  var body = json.encode(criteria);

  var response = await http.post(
    Uri.parse(url),
    body: body,
    headers: {"Accept": "application/json", "Content-Type": "application/json"},
  );

  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    return {
      "status": data['status'],
      "message": data['message'],
      "objectData": data['objectData'],
    };
    // Future.value(data['objectData']);
  } else {
    return {"status": "F"};
  }
}

Future<dynamic> postConfigShare() async {
  var body = json.encode({});

  var response = await http.post(
    Uri.parse('${server}configulation/shared/read'),
    body: body,
    headers: {"Accept": "application/json", "Content-Type": "application/json"},
  );

  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    return {
      // Future.value(data['objectData']);
      "status": data['status'],
      "message": data['message'],
      "objectData": data['objectData'],
    };
  } else {
    return {"status": "F"};
  }
}

// Future<File> convertimageTofile(imgUrl) async {
//   var response = await http.get(Uri.parse(imgUrl));
//   Directory documentDirectory = await getApplicationDocumentsDirectory();
//   File file = File(join(documentDirectory.path, 'imagetest.png'));
//   file.writeAsBytesSync(response.bodyBytes);
//   return file;
// }

//upload with dio
Future<String> uploadImage(XFile file) async {
  Dio dio = Dio();
  String fileName = file.path.split('/').last;
  FormData formData = FormData.fromMap({
    "ImageCaption": "flutter",
    "Image": await MultipartFile.fromFile(file.path, filename: fileName),
  });

  var response = await dio.post(serverUpload, data: formData);

  return response.data['imageUrl'];
}

//upload with dio
Future<String> uploadFile(File file, {String caption = 'opec'}) async {
  Dio dio = Dio();
  String fileName = file.path.split('/').last;
  FormData formData = FormData.fromMap({
    "ImageCaption": caption,
    "Image": await MultipartFile.fromFile(file.path, filename: fileName),
  });

  var response = await dio.post(serverUpload, data: formData);

  return response.data['imageUrl'];
}

//upload with http
upload(File file) async {
  var uri = Uri.parse(serverUpload);
  var request =
      http.MultipartRequest('POST', uri)
        ..fields['ImageCaption'] = 'flutter2'
        ..files.add(
          await http.MultipartFile.fromPath(
            'Image',
            file.path,
            contentType: MediaType('application', 'x-tar'),
          ),
        );
  var response = await request.send();
  if (response.statusCode == 200) {
    return response;
  }
}

createStorageApp({dynamic model, required String category}) async {
  final storage = FlutterSecureStorage();

  await storage.write(key: 'profileCategory', value: category);

  await storage.write(key: 'profileCode25', value: model['code']);

  await storage.write(key: 'profileImageUrl', value: model['imageUrl']);

  await storage.write(key: 'profileFirstName', value: model['firstName']);

  await storage.write(key: 'profileLastName', value: model['lastName']);

  storage.write(key: 'profileUserName', value: model['username']);

  await storage.write(key: 'dataUserLoginOPEC', value: jsonEncode(model));
}

Future<dynamic> postDio(
  String url,
  dynamic criteria, {
  bool pCode = false,
}) async {
  final storage = FlutterSecureStorage();
  final profileCode = await storage.read(key: 'profileCode25');
  if (pCode) {
    criteria = {'profileCode': profileCode, ...criteria};
  }
  if (profileCode != '' && profileCode != null) {
    criteria = {'profileCode': profileCode, ...criteria};
  }

  Dio dio = Dio();

  var response = await dio.post(url, data: criteria);
  // print(response.data['objectData'].toString());
  return Future.value(response.data['objectData']);
}

Future<dynamic> postDioMessage(
  String url,
  dynamic criteria, {
  bool pCode = false,
}) async {
  final storage = FlutterSecureStorage();
  final profileCode = await storage.read(key: 'profileCode25');
  if (pCode) {
    criteria = {'profileCode': profileCode, ...criteria};
  }
  if (profileCode != '' && profileCode != null) {
    criteria = {'profileCode': profileCode, ...criteria};
  }
  Dio dio = Dio();
  print('-----dio url-----$url');
  print('-----dio criteria-----$criteria');
  var response = await dio.post(url, data: criteria);
  print('-----dio message-----${response.data['objectData']}');
  return Future.value(response.data['objectData']);
}

Future<dynamic> postDioCategoryWeMart(String url, dynamic criteria) async {
  // print(url);
  // print(criteria);
  final storage = FlutterSecureStorage();
  // var platform = Platform.operatingSystem.toString();
  final profileCode = await storage.read(key: 'profileCode25');

  if (profileCode != '' && profileCode != null) {
    criteria = {'profileCode': profileCode, ...criteria};
  }

  Dio dio = Dio();
  var response = await dio.post(url, data: criteria);
  var data = response.data['objectData'];

  List<dynamic> list = [
    {'code': "", 'title': 'ทั้งหมด'},
  ];

  list = [...data, ...list];
  return Future.value(list);
}

Future<dynamic> postDioCategoryWeMartNoAll(String url, dynamic criteria) async {
  // print(url);
  // print(criteria);
  final storage = FlutterSecureStorage();
  // var platform = Platform.operatingSystem.toString();
  final profileCode = await storage.read(key: 'profileCode25');

  if (profileCode != '' && profileCode != null) {
    criteria = {'profileCode': profileCode, ...criteria};
  }

  Dio dio = Dio();
  var response = await dio.post(url, data: criteria);
  var data = response.data['objectData'];

  List<dynamic> list = [
    // {'code': "", 'title': 'ทั้งหมด'}
  ];

  list = [...data];
  return Future.value(list);
}

logout(BuildContext context) async {
  final storage = FlutterSecureStorage();
  storage.deleteAll();
  var profileCategory = await storage.read(key: 'profileCategory');
  if (profileCategory != '' && profileCategory != null) {
    switch (profileCategory) {
      case 'facebook':
        logoutFacebook();
        break;
      case 'google':
        logoutGoogle();
        break;
      case 'line':
        logoutLine();
        break;
      default:
        break;
    }
  }
}

Future<dynamic> postLineNoti() async {
  // Dio dio = new Dio();
  // dio.options.contentType = Headers.formUrlEncodedContentType;
  // dio.options.headers["Authorization"] =
  //     "Bearer " + "1RwnPOBFU0sN0LNBNWxkNpSOmpNjjKeVaFzwmg1c5zl";
  // var formData = FormData.fromMap({'message': "Opec ระบบขัดข้อง"});
  // var response = await dio.post(serverLineNoti, data: formData);
  // return Future.value(response.data['message']);
}

Future<dynamic> postOTPSend(String url, dynamic criteria) async {
  //https://portal-otp.smsmkt.com/api/otp-send
  //https://portal-otp.smsmkt.com/api/otp-validate
  Dio dio = Dio();
  dio.options.contentType = Headers.formUrlEncodedContentType;
  dio.options.headers["api_key"] = "db88c29e14b65c9db353c9385f6e5f28";
  dio.options.headers["secret_key"] = "XpM2EfFk7DKcyJzt";
  var response = await dio.post(serverOTP + url, data: criteria);
  // print('----------- -----------  ${response.data['result']}');
  return Future.value(response.data['result']);
}

Future<void> postTrackClick(String button) async {
  final storage = FlutterSecureStorage();
  final profileCode = await storage.read(key: 'profileCode25');
  var value = await storage.read(key: 'dataUserLoginOPEC') ?? "";
  var data = json.decode(value);

  dynamic criteria = {
    'button': button,
    'username': data['username'] != '' ? data['username'] ?? '' : '',
    'firstname': data['firstname'] != '' ? data['firstname'] ?? '' : '',
    'lastname': data['lastname'] != '' ? data['lastname'] ?? '' : '',
    'profileCode':
        data['code'] != '' ? data['code'] ?? profileCode : profileCode,
    'createBy': data['username'] != '' ? data['username'] ?? '' : '',
  };
  // print('-----dio uri-----' + server + "trackClick/create");
  // print('-----dio criteria-----' + criteria.toString());
  Dio dio = Dio();
  dio.post("${server}trackClick/create", data: criteria);
}

const splashReadApi = '${server}m/splash/read';

const organizationImageReadApi = '${server}m/v2/organization/image/read';

// return FutureBuilder<dynamic>(
//       future: _futureModel,
//       builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
//         if (snapshot.hasData) {
//           return Container();
//         } else if (snapshot.hasError) {
//           return Container();
//         } else {
//           return Container();
//         }
//       },
//     );

final storage = new FlutterSecureStorage();
updateBookmark(BuildContext context, model, profile) async {
  var profileCode = await storage.read(key: 'profileCode25');
  var result = await postDio(server + 'm/teacherjob/bookmark/create', {
    'profileCode': profileCode,
    'teacherJobCode': model['code'],
    'resumeCode': profile['code'],
    'updateBy': profile['firstName'] + " " + profile['lastName'],
    'isActive': true,
  });
  if (result != null) {
    return toastFail(context, text: 'บันทึกสำเร็จ');
  }
}

Future<LoginRegister> postLoginRegister(String url, dynamic criteria) async {
  var body = json.encode(criteria);

  var response = await http.post(
    Uri.parse(urlRegister + url),
    body: body,
    headers: {"Accept": "application/json", "Content-Type": "application/json"},
  );

  if (response.statusCode == 200) {
    var userMap = jsonDecode(response.body);

    var user = new LoginRegister.fromJson(userMap);
    return Future.value(user);
  } else {
    return Future.value(LoginRegister());
  }
}
