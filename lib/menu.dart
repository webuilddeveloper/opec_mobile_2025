import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:opec/pages/about_us/about_us_form.dart';
import 'package:opec/pages/auth/login.dart';
import 'package:opec/pages/contact/contact_list_category.dart';
import 'package:opec/pages/enfranchise/enfrancise_main.dart';
import 'package:opec/pages/enfranchise/enfrancise_main_ai.dart';
import 'package:opec/pages/event_calendar/event_calendar_main.dart';
import 'package:opec/pages/fileOnline/fileOnline_list.dart';
import 'package:opec/pages/fund/fundProvident.dart';
import 'package:opec/pages/fund/fundRegisterProvident.dart';
import 'package:opec/pages/fund/fundSavingsReport.dart';
import 'package:opec/pages/knowledge/knowledge_list.dart';
import 'package:opec/pages/main_popup/checkPermission_main.dart';
import 'package:opec/pages/main_popup/dialog_main_popup.dart';
import 'package:opec/pages/news/news_list.dart';
import 'package:opec/pages/notification/notification_list.dart';
import 'package:opec/pages/poll/poll_list.dart';
import 'package:opec/pages/privilege/privilege_main.dart';
import 'package:opec/pages/privilegeSpecial/privilege_special_list.dart';
import 'package:opec/pages/profile/identity_verification.dart';
import 'package:opec/pages/profile/profile.dart';
import 'package:opec/pages/profile/user_information.dart';
import 'package:opec/pages/question_and_answer/question_list.dart';
import 'package:opec/pages/reporter/reporter_list_category.dart';
import 'package:opec/pages/school/search_list_teacher_school.dart';
import 'package:opec/pages/teacher_job/profile_job.dart';
import 'package:opec/pages/teacher_job/teacher_job.dart';
import 'package:opec/pages/teacher_job/teacher_job_by_school.dart';
import 'package:opec/policy.dart';
import 'package:opec/shared/notification_service.dart';
import 'package:opec/user.dart';
import 'package:opec/widget/carousel.dart';
import 'package:opec/widget/dialog.dart';
import 'package:opec/widget/header.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:opec/shared/api_provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_app_badge/flutter_app_badge.dart';

class Menu extends StatefulWidget {
  @override
  _Menu createState() => _Menu();
}

class _Menu extends State<Menu> with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _readNoti();
      // _addBadger();
    });
  }

  final storage = new FlutterSecureStorage();
  DateTime? currentBackPressTime;

  // Profile profile = new Profile(model: Future.value({}));
  // Profile profile;

  Future<dynamic> _futureProfile = Future.value(null);
  Future<dynamic> _futureTeacherJobResume = Future.value(null);
  // Future<dynamic> _futureOrganizationImage = Future.value(null);
  Future<dynamic> _futureAboutUs = Future.value(null);
  Future<dynamic> _futureMainPopUp = Future.value(null);
  Future<dynamic> _futureRotation = Future.value(null);
  Future<dynamic> _futureNoti = Future.value(null);
  dynamic _futureCheck;
  dynamic _isNewsCount = false;
  dynamic _isPrivilegeCount = false;

  LatLng latLng = LatLng(0, 0);
  dynamic policyPrivilege;
  dynamic policyAtoZ;
  int nortiCount = 0;

  String currentLocation = '-';
  final seen = <String>{};
  List unique = [];
  List resultImageLv0 = [];
  List imageLv0 = [];

  String profileCode = "";

  late User userData;
  bool notShowOnDay = false;
  bool hiddenMainPopUp = false;
  bool showNoti = false;

  String userCode = '';
  String userOpecCategoryId = '';
  dynamic resultTeacherJobResume;

  PanelController panelController = new PanelController();
  bool showSlideUp = false;

  var loadingModel = {'title': '', 'imageUrl': ''};


  @override
  initState() {
    _callRead();
    super.initState();
    NotificationService.instance.start(context);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: headerV2(
        context,
        title: "สช. On Mobile",
        callback: () {
          postTrackClick('แจ้งเตือน');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NotificationList(title: 'แจ้งเตือน'),
            ),
          ).then((value) => _callRead());
        },
        showNoti: nortiCount,
      ),
      backgroundColor: Colors.white,
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) => confirmExit(),
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (OverscrollIndicatorNotification overScroll) {
            overScroll.disallowIndicator();
            return false;
          },
          child: checkRegister(context),
        ),
      ),
    );
  }

  FutureBuilder<dynamic> checkRegister(BuildContext context) {
    // print('----- checkRegister profileCode: $profileCode -----');
    double height = MediaQuery.of(context).size.height;
    return FutureBuilder<dynamic>(
      future: postDio(profileReadApi, {'code': profileCode}),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return _buildSlidingUp((snapshot.data['checkOrganization'] ?? false));
        } else if (snapshot.hasError) {
          postLineNoti();
          return Container(
            width: double.infinity,
            height: height,
            child: dialogFail(context, reloadApp: true),
          );
        } else {
          return _buildSlidingUp(false);
        }
      },
    );
  }

  _buildSlidingUp(checkCard) {
    double _panelHeightOpen = MediaQuery.of(context).size.height / 2;
    double _panelHeightClosed = 105;
    return SlidingUpPanel(
      controller: panelController,
      maxHeight:
          checkCard
              ? _panelHeightOpen
              : MediaQuery.of(context).size.height / 1.8,
      minHeight: _panelHeightClosed,
      parallaxEnabled: false,
      parallaxOffset: .5,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      body: _buildListView(checkCard),
      panelBuilder:
          (sc) =>
              panelController.panelPosition > 0.3
                  ? slideUp(sc, checkCard)
                  : slideDown(sc),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(15.0),
        topRight: Radius.circular(15.0),
      ),
      onPanelSlide: (double pos) => {setState(() {})},
    );
  }

  _buildListView(bool checkOrganization) {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: false,
      header: WaterDropHeader(
        complete: Container(child: Text('')),
        completeDuration: Duration(milliseconds: 0),
      ),
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: ListView(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 10, right: 10, top: 10),
            child: Profile(
              model: _futureProfile,
              nav: () {
                postTrackClick("โปรไฟล์");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => UserInformationPage(userData: userData),
                  ),
                ).then((value) => _callRead());
              },
            ),
          ),

          SizedBox(height: 10.0),
          Container(
            alignment: Alignment.center,
            color: Colors.transparent,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(left: 15, right: 15),
            child: Container(
              height: 40,
              margin: EdgeInsets.only(top: 7),
              // child: KeySearch(),
              child: InkWell(
                onTap: () {
                  postTrackClick("ตรวจสอบรายชื่อครูและโรงเรียนสังกัด สช.");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchListTeacherSchoolPage(),
                    ),
                  );
                },
                child: Container(
                  // height: 30,
                  padding: EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(width: 1, color: Color(0XFFEEBA33)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // _buildCurrentLocationBar(),
                      Text(
                        'ตรวจสอบรายชื่อครูและโรงเรียนสังกัด สช.',
                        style: TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 13,
                          color: Color(0xFF707070),
                        ),
                      ),
                      // SizedBox(width: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFEEBA33),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        height: double.infinity,
                        padding: EdgeInsets.all(10),
                        child: Image.asset(
                          'assets/images/search.png',
                          // height: 18.0,
                          // width: 18.0,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 15),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: CarouselRotation(
              model: _futureRotation,
              nav: (String path, String action, dynamic model, String code) {
                postTrackClick("แบนเนอร์");
                if (action == 'out') {
                  postDio('${server}m/Rotation/innserlog', model);
                  launch(path);
                  // launch(path);
                } else if (action == 'in') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => CarouselForm(
                            code: code,
                            model: model,
                            url: rotationReadApi,
                            urlGallery: rotationGalleryApi,
                          ),
                    ),
                  );
                } else if (action.toUpperCase() == 'P') {
                  postDio('${server}m/Rotation/innserlog', model);
                  _callReadPolicyPrivilegeAtoZ(code);
                } else if (action.toUpperCase() == 'CP') {
                  postDio('${server}m/Rotation/innserlog', model);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => CheckPermissionMain(reference: code),
                    ),
                  );
                } else if (action.toUpperCase() == 'AI') {
                  postDio('${server}m/Rotation/innserlog', model);
                  _callReadPolicyPrivilegeAI('AI');
                }
              },
            ),
          ),

          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'บริการ สช.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0XFF9A1120),
              ),
            ),
          ),
          SizedBox(height: 10.0),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              _buildButtonMenu(
                'assets/images/long_news.png',
                'NEWS',
                _isNewsCount,
              ),
              _buildButtonMenu('assets/images/long_event.png', 'EVENT', false),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              _buildButtonMenu(
                'assets/images/long_knowledge.png',
                'KNOWLEDGE',
                false,
              ),
              _buildButtonMenu(
                'assets/images/long_otherbenefits.png',
                'OTHERBENFITS',
                _isPrivilegeCount,
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              _buildButtonMenu(
                'assets/images/long_privilege.png',
                'PRIVILEGESPECIAL',
                false,
              ),
              _buildButtonMenu('assets/images/long_poi.png', 'POI', false),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              _buildButtonMenu(
                'assets/images/long_reporter.png',
                'ยื่นเรื่องออนไลน์',
                false,
              ),
              _buildButtonMenu('assets/images/long_poll.png', 'POLL', false),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              _buildButtonMenu(
                'assets/images/long_about_us.png',
                'ABOUT_US',
                false,
              ),
              _buildButtonMenu(
                'assets/images/long_contact.png',
                'CONTACT',
                false,
              ),
            ],
          ),
          SizedBox(height: 200.0),
        ],
      ),
    );
  }

  confirmExit() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      toastFail(
        context,
        text: 'กดอีกครั้งเพื่อออก',
        color: Colors.black,
        fontColor: Colors.white,
      );
    } else {
      SystemNavigator.pop();
    }
  }

  Profile profileBar() {
    return Profile(
      model: _futureProfile,
      nav: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserInformationPage(userData: userData),
          ),
        );
      },
    );
  }

  _callRead() async {
    dynamic data;
    dynamic result;
    _readNoti();
    profileCode = await storage.read(key: 'profileCode25') ?? "";
    if (profileCode != '') {
      _futureProfile = postDio(profileReadApi, {'code': profileCode});
      _futureTeacherJobResume = postDio('${server}m/teacherjob/resume/read', {
        'profileCode': profileCode,
      });
      // _futureOrganizationImage = postDio(organizationImageReadApi, {
      //   "code": profileCode,
      // });

      policyPrivilege = await postDio("${server}m/policy/read", {
        "category": "marketing",
      });

      policyAtoZ = await postDio("${server}m/policy/readAtoZ", {
        "reference": "AtoZ",
      });

      data = await _futureProfile;
      result = await _futureTeacherJobResume;
      if (result.length > 0) {
        setState(() {
          result = result[0];
          resultTeacherJobResume = result;
        });
      }
    } else {
      logout(context);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
        (Route<dynamic> route) => false,
      );
    }

    var token = await storage.read(key: 'token');
    if (token != '' && token != null) {
      postDio('${server}m/v2/register/token/create', {
        'token': token,
        'profileCode': profileCode,
      });
    }

    // var imageUrlSocial = await storage.read(key: 'profileImageUrl');
    // if (imageUrlSocial != '' && imageUrlSocial != null) {
    //   setState(() {
    //     _imageUrl = imageUrlSocial;
    //   });
    // }

    userCode = data['code'];
    userOpecCategoryId = data['opecCategoryId'];

    setState(() {
      userData = new User(
        idcard: data['idcard'] != '' ? data['idcard'] : '',
        username: data['username'] != '' ? data['username'] : '',
        password: data['password'] != '' ? data['password'].toString() : '',
        firstName: data['firstName'] != '' ? data['firstName'] : '',
        lastName: data['lastName'] != '' ? data['lastName'] : '',
        imageUrl: data['imageUrl'] != '' ? data['imageUrl'] : '',
        category: data['category'] != '' ? data['category'] : '',
        countUnit: data['countUnit'] != '' ? data['countUnit'] : '',
        address: data['address'] != '' ? data['address'] : '',
        status: data['status'] != '' ? data['status'] : '',
        checkOrganization: data['checkOrganization'],
        opecCategoryId: data['opecCategoryId'],
      );
    });

    _futureCheck = await post('${questionApi}check', {
      'profileCode': profileCode,
    });

    Dio dio = new Dio();
    var response = await dio.get('$gatewayEndpoint/py-api/opec/rotation/');

    setState(() {
      _futureRotation = Future.value(response.data['data'][0]);
    });

    _futureMainPopUp = post(mainPopupReadApi, {'skip': 0, 'limit': 10});

    _futureAboutUs = post('${aboutUsApi}read', {});

    _getLocation();
    _callReadPolicy();
  }

  _readNoti() async {
    var _profile = await _futureProfile;
    if (_profile != null) {
      dynamic _username = _profile["username"];
      dynamic _category = _profile["category"];
      _futureNoti = postDio('${notificationApi}count', {
        "username": _username,
        "category": _category,
      });
      var _norti = await _futureNoti;
      setState(() {
        nortiCount = _norti['total'];
        _isNewsCount = (_norti['newsPage'] ?? 0) > 0 ? true : false;
        _isPrivilegeCount = (_norti['privilegePage'] ?? 0) > 0 ? true : false;
        // _isEventCount = (_norti['eventPage'] ?? 0) > 0 ? true : false;
        // _isPollCount = (_norti['pollPage'] ?? 0) > 0 ? true : false;
      });
      FlutterAppBadge.count(nortiCount);
    } else {
      FlutterAppBadge.count(0);
    }
  }

  getImageLv0() async {
    await storage.delete(key: 'imageLv0');
    var value = await storage.read(key: 'dataUserLoginOPEC') ?? "";
    if (value == '') {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
        (Route<dynamic> route) => false,
      );
    }
    var data = json.decode(value);
    var countUnit = json.decode(data['countUnit']);
    var rawLv0 = [];

    if (rawLv0.length == 0) {
      countUnit
          .map(
            (e) => {
              if (e['status'] != null)
                {
                  if (e['status'] == 'A') {rawLv0.add(e['lv0'].toString())},
                },
            },
          )
          .toList();
    }

    unique = rawLv0.where((str) => seen.add(str)).toList();

    rawLv0.forEach((element) async {
      await post('${server}organization/read', {'code': element}).then(
        (value) => {
          if (value.length > 0) {imageLv0.add(value[0]['imageUrl'])},
        },
      );
    });

    storage.write(key: 'imageLv0', value: jsonEncode(imageLv0));
    var image0 = await storage.read(key: 'imageLv0') ?? "";
    resultImageLv0 = json.decode(image0);
    unique = [];
    imageLv0 = [];
  }

  getMainPopUp() async {
    var result = await post(mainPopupReadApi, {'skip': 0, 'limit': 100});

    if (result.length > 0) {
      var valueStorage = await storage.read(key: 'mainPopupOPEC');
      var dataValue;
      if (valueStorage != null) {
        dataValue = json.decode(valueStorage);
      } else {
        dataValue = null;
      }

      var now = new DateTime.now();
      DateTime date = new DateTime(now.year, now.month, now.day);

      if (dataValue != null) {
        var index = dataValue.indexWhere(
          (c) =>
              c['username'] == userData.username &&
              c['date'].toString() ==
                  DateFormat("ddMMyyyy").format(date).toString() &&
              c['boolean'] == "true",
        );

        if (index == -1) {
          this.setState(() {
            hiddenMainPopUp = false;
          });
          return showDialog(
            barrierDismissible: false, // close outside
            context: context,
            builder: (_) {
              return WillPopScope(
                onWillPop: () {
                  return Future.value(false);
                },
                child: MainPopupDialog(
                  model: _futureMainPopUp,
                  type: 'mainPopup',
                  username: userData.username ?? "",
                  url: '$url/opec-api/m/MainPopup/',
                  urlGallery: '$url/opec-api/m/MainPopup/gallery/read',
                ),
              );
            },
          );
        } else {
          this.setState(() {
            hiddenMainPopUp = true;
          });
        }
      } else {
        this.setState(() {
          hiddenMainPopUp = false;
        });
        return showDialog(
          barrierDismissible: false, // close outside
          context: context,
          builder: (_) {
            return WillPopScope(
              onWillPop: () {
                return Future.value(false);
              },
              child: MainPopupDialog(
                model: _futureMainPopUp,
                type: 'mainPopup',
                username: userData.username ?? "",
                url: '$url/opec-api/m/MainPopup/',
                urlGallery: '$url/opec-api/m/MainPopup/gallery/read',
              ),
            );
          },
        );
      }
    }
  }

  getCurrentUserData() async {
    if (userData.category == null) {
      return Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
        (Route<dynamic> route) => false,
      );
    }

    await post('${registerApi}read', {"username": userData.username}).then(
      (data) => {
        if (userData.username == data[0]['username'])
          {
            storage.write(key: 'dataUserLoginOPEC', value: jsonEncode(data[0])),
            setState(() {
              userData = new User(
                username: data[0]['username'] != '' ? data[0]['username'] : '',
                password: data[0]['password'] != '' ? data[0]['password'] : '',
                firstName:
                    data[0]['firstName'] != '' ? data[0]['firstName'] : '',
                lastName: data[0]['lastName'] != '' ? data[0]['lastName'] : '',
                imageUrl: data[0]['imageUrl'] != '' ? data[0]['imageUrl'] : '',
                category: data[0]['category'] != '' ? data[0]['category'] : '',
                countUnit:
                    data[0]['countUnit'] != '' ? data[0]['countUnit'] : '',
                address: data[0]['address'] != '' ? data[0]['address'] : '',
                status: data[0]['status'] != '' ? data[0]['status'] : '',
              );
            }),
          },
      },
    );
  }

  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  void _onRefresh() async {
    // getCurrentUserData();
    _getLocation();
    _callRead();

    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
    // _refreshController.loadComplete();
  }

  void _onLoading() async {
    await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.loadComplete();
  }

  Future<Null> _callReadPolicy() async {
    var policy = await postDio("${server}m/policy/read", {
      "category": "application",
    });
    if (policy.length > 0) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder:
              (context) => PolicyPage(
                category: 'application',
                navTo: () {
                  // Navigator.pop(context);
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => Menu()),
                    (Route<dynamic> route) => false,
                  );
                },
              ),
        ),
        (Route<dynamic> route) => false,
      );

      // if (!isPolicyFasle) {
      //   logout(context);
      //   _onRefresh();
      // }
    } else {
      getMainPopUp();
    }
  }

  Future<Null> _callReadPolicyPrivilege(String title) async {
    if (policyPrivilege.length > 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          // ignore: missing_required_param
          // builder: (context) => PolicyIdentityVerificationPage(),
          builder:
              (context) => PolicyPage(
                category: 'marketing',
                navTo: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PrivilegeMain(title: title),
                    ),
                  );
                },
              ),
        ),
      );

      // if (!isPolicyFasle) {
      //   logout(context);
      //   _onRefresh();
      // }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PrivilegeMain(title: title)),
      );
    }
  }

  _getLocation() async {
    // print('currentLocation');
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    // print('------ Position -----' + position.toString());

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
      // localeIdentifier: 'th',
    );
    // print('----------' + placemarks.toString());

    setState(() {
      latLng = LatLng(position.latitude, position.longitude);
      currentLocation = placemarks.first.administrativeArea ?? "";
    });
  }

  _buildButtonMenu(imageUrl, type, isCount) {
    return Stack(
      children: <Widget>[
        InkWell(
          onTap: () {
            switch (type) {
              case 'NEWS':
                postTrackClick("ข่าวประชาสัมพันธ์");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => NewsList(
                          title: 'ข่าวประชาสัมพันธ์',
                          profileCode: profileCode,
                          profileUserName: userData.username ?? "",
                          profileCategory: userData.category ?? "",
                        ),
                  ),
                ).then((value) => _callRead());
                break;
              case 'KNOWLEDGE':
                postTrackClick("สมาชิกต้องรู้");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => KnowledgeList(title: 'สมาชิกต้องรู้'),
                  ),
                );
                break;
              case 'Q_A':
                postTrackClick("ถาม - ตอบ");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => BuildQuestionList(
                          isSchool: _futureCheck['isSchool'],
                          menuModel: {'title': 'ถาม - ตอบ'},
                        ),
                  ),
                );
                break;
              case 'OTHERBENFITS':
                postTrackClick("สิทธิประโยชน์อื่นๆ");
                // storage.write(
                //   key: 'isBadgerPrivilege',
                //   value: '0', //_isPrivilegeCount.toString(),
                // );
                // setState(() {
                //   _isPrivilegeCount = false;
                //   _addBadger();
                // });
                _callReadPolicyPrivilege('สิทธิประโยชน์อื่นๆ');
                break;
              case 'PRIVILEGESPECIAL':
                postTrackClick("สิทธิพิเศษ");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => PrivilegeSpecialList(title: 'สิทธิพิเศษ'),
                  ),
                );
                break;
              case 'POLL':
                postTrackClick("แบบสอบถาม");
                // storage.write(
                //   key: 'isBadgerPoll',
                //   value: '0', //_pollCount.toString(),
                // );
                // setState(() {
                //   _isPollCount = false;
                //   _addBadger();
                // });
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            PollList(title: 'แบบสอบถาม', userData: userData),
                  ),
                ).then((value) => _callRead());
                break;
              case 'POI':
                postTrackClick("กดดูรู้ที่เรียน");
                launch(
                  'https://peso.opec.go.th/web/SchoolPublic.htm?mode=initSchoolSearch',
                );
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => PoiList(
                //       title: 'กดดูรู้ที่เรียน',
                //     ),
                //   ),
                // );
                break;
              case 'REPORTER':
                postTrackClick("ข้อเสนอแนะ");
                postDio(
                  '${urlRegister}m/v3/register/checkOrganizationActive',
                  {},
                ).then((value) {
                  if (value) {
                    dialogBtn(
                      context,
                      title: 'แจ้งเตือนจากระบบ',
                      description:
                          'กรุณากรอกข้อมูลสมาชิกหรืออยู่ระหว่างตรวจสอบข้อมูล',
                      btnOk: "กรอกข้อมูลสมาชิก",
                      isYesNo: true,
                      callBack: (param) {
                        if (param) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => IdentityVerificationPage(),
                            ),
                          ).then((value) => _callRead());
                        }
                      },
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                ReporterListCategory(title: 'ข้อเสนอแนะ'),
                      ),
                    );
                  }
                });
                break;
              case 'CONTACT':
                postTrackClick("สมุดโทรศัพท์");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ContactListCategory(title: 'สมุดโทรศัพท์'),
                  ),
                );
                break;
              case 'ABOUT_US':
                postTrackClick("เกี่ยวกับเรา");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => AboutUsForm(
                          model: _futureAboutUs,
                          title: 'เกี่ยวกับเรา',
                        ),
                  ),
                );
                break;
              case 'EVENT':
                postTrackClick("ปฏิทินกิจกรรม");
                // storage.write(
                //   key: 'isBadgerEvent',
                //   value: '0', //_eventCount.toString(),
                // );
                // setState(() {
                //   _isEventCount = false;
                //   _addBadger();
                // });
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => EventCalendarMain(title: 'ปฏิทินกิจกรรม'),
                  ),
                ).then((value) => _callRead());
                break;
              case 'ยื่นเรื่องออนไลน์':
                postTrackClick("ยื่นเรื่องออนไลน์");
                launch(
                  'https://pss.opec.go.th/web/OpecJob.htm?mode=initTracking',
                );
                break;
              default:
            }
          },
          child:
              (type != '')
                  ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    width: (MediaQuery.of(context).size.width / 100) * 50,
                    height: (MediaQuery.of(context).size.height / 100) * 10,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5.0),
                      child: Image.asset(imageUrl, fit: BoxFit.fill),
                    ),
                  )
                  : Container(),
        ),
        Positioned(
          top: 5,
          right: 10,
          child:
              isCount
                  ? Container(
                    alignment: Alignment.center,
                    width: 30,
                    // height: 90.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.red,
                    ),
                    child: Text(
                      'N',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  )
                  : Container(),
        ),
      ],
    );
  }

  void togglePanel() =>
      panelController.isPanelOpen
          ? panelController.close()
          : panelController.open();

  Widget slideDown(ScrollController sc) {
    return ListView(
      controller: sc,
      children: <Widget>[
        Center(
          child: InkWell(
            onTap: togglePanel,
            child: Container(
              margin: EdgeInsets.only(top: 10),
              width: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Color(0XFF9A1120),
              ),
              height: 4,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 20, top: 10, right: 20),
          child: InkWell(
            onTap: togglePanel,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.grey[200],
              ),
              alignment: Alignment.center,
              child: Text(
                'บริการอิเล็กทรอนิกส์',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0XFF9A1120),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget slideUp(ScrollController sc, checkCard) {
    return ListView(
      controller: sc,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      children: <Widget>[
        Center(
          child: InkWell(
            onTap: togglePanel,
            child: Container(
              margin: EdgeInsets.only(top: 10),
              width: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Color(0XFF9A1120),
              ),
              height: 4,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 20, top: 20, right: 20),
          child: Container(
            height: 40,
            child: Text(
              'บริการอิเล็กทรอนิกส์',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0XFF9A1120),
              ),
            ),
          ),
        ),
        _menuSlideUp(
          'assets/logo/icons/fund_fileOnline.png',
          'ยื่นเรื่องออนไลน์',
          'รายละเอียด',
        ),
        checkCard
            ? Column(
              children: [
                _menuSlideUp(
                  'assets/logo/icons/fund_loaninformation.png',
                  'ข้อมูลการกู้เงิน',
                  'รายละเอียด',
                ),
                _menuSlideUp(
                  'assets/logo/icons/fund_fundremittanceamount.png',
                  'ยอดสะสมกองทุน',
                  'รายละเอียด',
                ),
                _menuSlideUp(
                  'assets/logo/icons/fund_medicaltreatmentrights.png',
                  'สิทธิรักษาพยาบาล',
                  'พบกันเร็วๆนี้',
                ),
                _menuSlideUp(
                  'assets/logo/icons/fund_welfare.png',
                  'กองทุนสงเคราะห์',
                  'รายละเอียด',
                ),
              ],
            )
            : Container(),
        Padding(
          padding: EdgeInsets.only(left: 20, top: 10, right: 20),
          child: InkWell(
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => UserInformationPage(userData: userData),
                  ),
                ),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Color(0XFFEEBA33),
              ),
              alignment: Alignment.center,
              child: Text(
                'แสดงทั้งหมด',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0XFFFFFFFF),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  _menuSlideUp(imageUrl, title, buttonName, {String subTitle = ''}) {
    return Padding(
      padding: EdgeInsets.only(left: 10, top: 5, right: 10, bottom: 5),
      child: InkWell(
        onTap: () {
          postTrackClick(title);
          switch (title) {
            case 'โรงเรียนหาครู':
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => TeacherJobBySchoolPage(
                        userData: userData,
                        profileCode: profileCode,
                      ),
                ),
              );
              break;
            case 'หางานครู':
              resultTeacherJobResume != null
                  ? Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => TeacherJobPage(model: resultTeacherJobResume),
                    ),
                  )
                  : Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileJobPage(title: ''),
                    ),
                  );
              break;
            case 'ยื่นเรื่องออนไลน์':
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FileOnlineList(title: title, code: ''),
                ),
              );
              break;
            case 'ข้อมูลการกู้เงิน':
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => FundProvident(
                        title: title,
                        userData: userData,
                        imageUrl: imageUrl,
                      ),
                ),
              );
              break;
            case 'ยอดสะสมกองทุน':
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          FundSavingsReport(title: title, userData: userData),
                ),
              );
              break;
            case 'สิทธิรักษาพยาบาล':
              break;
            case 'กองทุนสงเคราะห์':
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => FundRegisterProvident(
                        title: 'กองทุนสงเคราะห์',
                        userData: userData,
                      ),
                ),
              );
              break;
            default:
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(height: 40, width: 40, child: Image.asset(imageUrl)),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 10, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Color(0XFF9A1120),
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Kanit',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subTitle,
                      style: TextStyle(
                        color: Color(0XFF000000),
                        fontSize: 10.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Text(
                buttonName,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 13.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Kanit',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Null> _callReadPolicyPrivilegeAtoZ(code) async {
    if (policyAtoZ.length <= 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => PolicyPage(
                category: 'AtoZ',
                navTo: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EnfranchiseMain(reference: code),
                    ),
                  );
                },
              ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EnfranchiseMain(reference: code),
        ),
      );
    }
  }

  Future<Null> _callReadPolicyPrivilegeAI(code) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnfranchiseMainAi(reference: code),
      ),
    );
  }
}
