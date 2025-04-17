import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:opec/shared/api_provider.dart';
import 'package:opec/widget/dialog.dart';
import 'package:opec/widget/header.dart';

class SettingNotificationPage extends StatefulWidget {
  @override
  _SettingNotificationPageState createState() =>
      _SettingNotificationPageState();
}

class _SettingNotificationPageState extends State<SettingNotificationPage> {
  final storage = new FlutterSecureStorage();

  String _username = '';
  Future<dynamic> futureModel = Future.value(null);

  ScrollController scrollController = new ScrollController();

  bool isSwitchedEventPage = false;
  bool isSwitchedContactPage = false;
  bool isSwitchedKnowledgePage = false;
  bool isSwitchedMainPage = false;
  bool isSwitchedNewsPage = false;
  bool isSwitchedPoiPage = false;
  bool isSwitchedPollPage = false;
  bool isSwitchedPrivilegePage = false;
  bool isSwitchedReporterPage = false;
  bool isSwitchedWelfarePage = false;
  bool isSwitchedCooperativeFormPage = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    futureModel = readNotification();
    super.initState();
  }

  Future<dynamic> readNotification() async {
    var value = await storage.read(key: 'dataUserLoginOPEC') ?? "";
    var user = json.decode(value);
    if (user['code'] != '') {
      setState(() {
        _username = user['username'] ?? '';
      });
    }
    final result = await postObjectData('m/register/notification/read', {
      'username': _username,
    });
    if (result['status'] == 'S') {
      await storage.write(
        key: 'dataNotificationOPEC',
        value: jsonEncode(result['objectData']),
      );

      setState(() {
        isSwitchedMainPage = result['objectData']['mainPage'];
        isSwitchedNewsPage = result['objectData']['newsPage'];
        isSwitchedEventPage = result['objectData']['eventPage'];
        isSwitchedContactPage = result['objectData']['contactPage'];
        isSwitchedKnowledgePage = result['objectData']['knowledgePage'];
        isSwitchedPrivilegePage = result['objectData']['privilegePage'];
        isSwitchedPoiPage = result['objectData']['poiPage'];
        isSwitchedPollPage = result['objectData']['pollPage'];
        isSwitchedReporterPage = result['objectData']['reporterPage'];
        isSwitchedWelfarePage = result['objectData']['welfarePage'];
        isSwitchedCooperativeFormPage =
            result['objectData']['cooperativeFormPage'];
      });
    }
  }

  Future<dynamic> updateNotication() async {
    var value = await storage.read(key: 'dataNotificationOPEC') ?? "";
    var data = json.decode(value);
    data['eventPage'] = isSwitchedEventPage;
    data['contactPage'] = isSwitchedContactPage;
    data['knowledgePage'] = isSwitchedKnowledgePage;
    data['mainPage'] = isSwitchedMainPage;
    data['newsPage'] = isSwitchedNewsPage;
    data['poiPage'] = isSwitchedPoiPage;
    data['pollPage'] = isSwitchedPollPage;
    data['privilegePage'] = isSwitchedPrivilegePage;
    data['reporterPage'] = isSwitchedReporterPage;
    data['welfarePage'] = isSwitchedWelfarePage;
    data['cooperativeFormPage'] = isSwitchedCooperativeFormPage;

    final result = await postObjectData('m/Register/notification/update', data);

    if (result['status'] == 'S') {
      await storage.write(
        key: 'dataNotificationOPEC',
        value: jsonEncode(result['objectData']),
      );

      setState(() {
        isSwitchedEventPage = result['objectData']['eventPage:'] ?? '';
        isSwitchedContactPage = result['objectData']['contactPage:'] ?? '';
        isSwitchedKnowledgePage = result['objectData']['knowledgePage:'] ?? '';
        isSwitchedMainPage = result['objectData']['mainPage'] ?? '';
        isSwitchedNewsPage = result['objectData']['newsPage'] ?? '';
        isSwitchedPoiPage = result['objectData']['poiPage'] ?? '';
        isSwitchedPollPage = result['objectData']['pollPage'] ?? '';
        isSwitchedPrivilegePage = result['objectData']['privilegePage'] ?? '';
        isSwitchedReporterPage = result['objectData']['reporterPage'] ?? '';
        isSwitchedWelfarePage = result['objectData']['welfarePage'] ?? '';
        isSwitchedCooperativeFormPage =
            result['objectData']['cooperativeFormPage'] ?? '';
      });
    }
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

  card() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      child: Padding(padding: EdgeInsets.all(10), child: contentCard()),
    );
  }

  contentCard() {
    return Column(
      // shrinkWrap: true,
      // physics: ClampingScrollPhysics(),
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: 5),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color(0xFFE2E2E2),
                width: 1.0,
              ),
            ),
          ),
          alignment: Alignment.centerLeft,
          child: Row(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.73,
                margin: EdgeInsets.only(left: 10.0, right: 10.0),
                child: Text(
                  'ระบบแจ้งเตือน',
                  style: new TextStyle(
                    fontSize: 13.0,
                    //color: Color(0xFF9D040C),
                    fontWeight: FontWeight.normal,
                    fontFamily: 'Kanit',
                  ),
                ),
              ),
              Container(
                height: 40.0,
                alignment: Alignment.centerRight,
                child: Switch(
                  value: isSwitchedMainPage,
                  onChanged: (value) {
                    setState(() {
                      isSwitchedMainPage = value;
                    });
                    updateNotication();
                  },
                  activeTrackColor: Color(0xFFFEE9E8),
                  activeColor: Color(0xFF9D040C),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 5),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color(0xFFE2E2E2),
                width: 1.0,
              ),
            ),
          ),
          alignment: Alignment.centerLeft,
          child: Row(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.73,
                margin: EdgeInsets.only(left: 10.0, right: 10.0),
                child: Text(
                  'ประกาศ สช.',
                  style: new TextStyle(
                    fontSize: 13.0,
                    //color: Color(0xFF9D040C),
                    fontWeight: FontWeight.normal,
                    fontFamily: 'Kanit',
                  ),
                ),
              ),
              Container(
                height: 40.0,
                alignment: Alignment.centerRight,
                child: Switch(
                  value: isSwitchedNewsPage,
                  onChanged: (value) {
                    setState(() {
                      isSwitchedNewsPage = value;
                    });
                    updateNotication();
                  },
                  activeTrackColor: Color(0xFFFEE9E8),
                  activeColor: Color(0xFF9D040C),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 5),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color(0xFFE2E2E2),
                width: 1.0,
              ),
            ),
          ),
          alignment: Alignment.centerLeft,
          child: Row(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.73,
                margin: EdgeInsets.only(left: 10.0, right: 10.0),
                child: Text(
                  'ปฎิทินกิจกรรม',
                  style: new TextStyle(
                    fontSize: 13.0,
                    //color: Color(0xFF9D040C),
                    fontWeight: FontWeight.normal,
                    fontFamily: 'Kanit',
                  ),
                ),
              ),
              Container(
                height: 40.0,
                alignment: Alignment.centerRight,
                child: Switch(
                  value: isSwitchedEventPage,
                  onChanged: (value) {
                    setState(() {
                      isSwitchedEventPage = value;
                    });
                    updateNotication();
                  },
                  activeTrackColor: Color(0xFFFEE9E8),
                  activeColor: Color(0xFF9D040C),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 5),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color(0xFFE2E2E2),
                width: 1.0,
              ),
            ),
          ),
          alignment: Alignment.centerLeft,
          child: Row(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.73,
                margin: EdgeInsets.only(left: 10.0, right: 10.0),
                child: Text(
                  'เบอร์ติดต่อเร่งด่วน',
                  style: new TextStyle(
                    fontSize: 13.0,
                    //color: Color(0xFF9D040C),
                    fontWeight: FontWeight.normal,
                    fontFamily: 'Kanit',
                  ),
                ),
              ),
              Container(
                height: 40.0,
                alignment: Alignment.centerRight,
                child: Switch(
                  value: isSwitchedContactPage,
                  onChanged: (value) {
                    setState(() {
                      isSwitchedContactPage = value;
                    });
                    updateNotication();
                  },
                  activeTrackColor: Color(0xFFFEE9E8),
                  activeColor: Color(0xFF9D040C),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 5),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color(0xFFE2E2E2),
                width: 1.0,
              ),
            ),
          ),
          alignment: Alignment.centerLeft,
          child: Row(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.73,
                margin: EdgeInsets.only(left: 10.0, right: 10.0),
                child: Text(
                  'สมาชิกต้องรู้',
                  style: new TextStyle(
                    fontSize: 13.0,
                    //color: Color(0xFF9D040C),
                    fontWeight: FontWeight.normal,
                    fontFamily: 'Kanit',
                  ),
                ),
              ),
              Container(
                height: 40.0,
                alignment: Alignment.centerRight,
                child: Switch(
                  value: isSwitchedKnowledgePage,
                  onChanged: (value) {
                    setState(() {
                      isSwitchedKnowledgePage = value;
                    });
                    updateNotication();
                  },
                  activeTrackColor: Color(0xFFFEE9E8),
                  activeColor: Color(0xFF9D040C),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 5),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color(0xFFE2E2E2),
                width: 1.0,
              ),
            ),
          ),
          alignment: Alignment.centerLeft,
          child: Row(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.73,
                margin: EdgeInsets.only(left: 10.0, right: 10.0),
                child: Text(
                  'สิทธิประโยชน์อื่นๆ',
                  style: new TextStyle(
                    fontSize: 13.0,
                    //color: Color(0xFF9D040C),
                    fontWeight: FontWeight.normal,
                    fontFamily: 'Kanit',
                  ),
                ),
              ),
              Container(
                height: 40.0,
                alignment: Alignment.centerRight,
                child: Switch(
                  value: isSwitchedPrivilegePage,
                  onChanged: (value) {
                    setState(() {
                      isSwitchedPrivilegePage = value;
                    });
                    updateNotication();
                  },
                  activeTrackColor: Color(0xFFFEE9E8),
                  activeColor: Color(0xFF9D040C),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 5),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color(0xFFE2E2E2),
                width: 1.0,
              ),
            ),
          ),
          alignment: Alignment.centerLeft,
          child: Row(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.73,
                margin: EdgeInsets.only(left: 10.0, right: 10.0),
                child: Text(
                  'กดดูรู้ที่เรียน',
                  style: new TextStyle(
                    fontSize: 13.0,
                    //color: Color(0xFF9D040C),
                    fontWeight: FontWeight.normal,
                    fontFamily: 'Kanit',
                  ),
                ),
              ),
              Container(
                height: 40.0,
                alignment: Alignment.centerRight,
                child: Switch(
                  value: isSwitchedPoiPage,
                  onChanged: (value) {
                    setState(() {
                      isSwitchedPoiPage = value;
                    });
                    updateNotication();
                  },
                  activeTrackColor: Color(0xFFFEE9E8),
                  activeColor: Color(0xFF9D040C),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 5),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color(0xFFE2E2E2),
                width: 1.0,
              ),
            ),
          ),
          alignment: Alignment.centerLeft,
          child: Row(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.73,
                margin: EdgeInsets.only(left: 10.0, right: 10.0),
                child: Text(
                  'แบบสอบถาม',
                  style: new TextStyle(
                    fontSize: 13.0,
                    //color: Color(0xFF9D040C),
                    fontWeight: FontWeight.normal,
                    fontFamily: 'Kanit',
                  ),
                ),
              ),
              Container(
                height: 40.0,
                alignment: Alignment.centerRight,
                child: Switch(
                  value: isSwitchedPollPage,
                  onChanged: (value) {
                    setState(() {
                      isSwitchedPollPage = value;
                    });
                    updateNotication();
                  },
                  activeTrackColor: Color(0xFFFEE9E8),
                  activeColor: Color(0xFF9D040C),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 5),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color(0xFFE2E2E2),
                width: 1.0,
              ),
            ),
          ),
          alignment: Alignment.centerLeft,
          child: Row(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.73,
                margin: EdgeInsets.only(left: 10.0, right: 10.0),
                child: Text(
                  'ข้อเสนอแนะ',
                  style: new TextStyle(
                    fontSize: 13.0,
                    //color: Color(0xFF9D040C),
                    fontWeight: FontWeight.normal,
                    fontFamily: 'Kanit',
                  ),
                ),
              ),
              Container(
                height: 40.0,
                alignment: Alignment.centerRight,
                child: Switch(
                  value: isSwitchedReporterPage,
                  onChanged: (value) {
                    setState(() {
                      isSwitchedReporterPage = value;
                    });
                    updateNotication();
                  },
                  activeTrackColor: Color(0xFFFEE9E8),
                  activeColor: Color(0xFF9D040C),
                ),
              ),
            ],
          ),
        ),
        // Container(
        //   margin: EdgeInsets.only(top: 5),
        //   decoration: BoxDecoration(
        //     border: Border(
        //       bottom: BorderSide(
        //         color: Color(0xFFE2E2E2),
        //         width: 1.0,
        //       ),
        //     ),
        //   ),
        //   alignment: Alignment.centerLeft,
        //   child: Row(
        //     children: <Widget>[
        //       Container(
        //         width: MediaQuery.of(context).size.width * 0.73,
        //         margin: EdgeInsets.only(left: 10.0, right: 10.0),
        //         child: Text(
        //           'แบบฟอร์มสหกรณ์',
        //           style: new TextStyle(
        //             fontSize: 13.0,
        //             //color: Color(0xFF9D040C),
        //             fontWeight: FontWeight.normal,
        //             fontFamily: 'Kanit',
        //           ),
        //         ),
        //       ),
        //       Container(
        //         height: 40.0,
        //         alignment: Alignment.centerRight,
        //         child: Switch(
        //           value: isSwitchedCooperativeFormPage,
        //           onChanged: (value) {
        //             setState(() {
        //               isSwitchedCooperativeFormPage = value;
        //             });
        //             updateNotication();
        //           },
        //           activeTrackColor: Color(0xFFFEE9E8),
        //           activeColor: Color(0xFF9D040C),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),

        Container(
          margin: EdgeInsets.only(top: 5),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color(0xFFE2E2E2),
                width: 1.0,
              ),
            ),
          ),
          alignment: Alignment.centerLeft,
          child: Row(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.73,
                margin: EdgeInsets.only(left: 10.0, right: 10.0),
                child: Text(
                  'กองทุนและสวัสดิการ',
                  style: new TextStyle(
                    fontSize: 13.0,
                    //color: Color(0xFF9D040C),
                    fontWeight: FontWeight.normal,
                    fontFamily: 'Kanit',
                  ),
                ),
              ),
              Container(
                height: 40.0,
                alignment: Alignment.centerRight,
                child: Switch(
                  value: isSwitchedWelfarePage,
                  onChanged: (value) {
                    setState(() {
                      isSwitchedWelfarePage = value;
                    });
                    updateNotication();
                  },
                  activeTrackColor: Color(0xFFFEE9E8),
                  activeColor: Color(0xFF9D040C),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: header(context, goBack, title: 'ตั้งค่าการแจ้งเตือน'),
        backgroundColor: Colors.white,
        body: FutureBuilder<dynamic>(
          future: futureModel,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasError)
              return Center(
                child: Container(
                  color: Colors.white,
                  child: dialogFail(context),
                ),
              );
            else
              return Container(
                child: ListView(
                  controller: scrollController,
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  // padding: EdgeInsets.only(top: 10),
                  children: <Widget>[
                    new Column(
                      // alignment: Alignment.topCenter,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.topCenter,
                          margin: EdgeInsets.symmetric(
                            horizontal: 5.0,
                            // vertical: 10.0,
                          ),
                          child: contentCard(),
                        ),
                      ],
                    ),
                  ],
                ),
              );
          },
        ));
  }
}
