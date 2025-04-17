import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:opec/shared/api_provider.dart';
import 'package:opec/shared/extension.dart';
import 'package:opec/widget/dialog.dart';
import 'package:opec/widget/loading.dart';
import 'package:url_launcher/url_launcher.dart';

class TeacherJobForm extends StatefulWidget {
  const TeacherJobForm({Key? key, this.model}) : super(key: key);

  final dynamic model;

  @override
  State<TeacherJobForm> createState() => _TeacherJobFormState();
}

class _TeacherJobFormState extends State<TeacherJobForm> {
  final storage = new FlutterSecureStorage();
  String _selectedDescription = '1';

  dynamic model;
  dynamic profile = {'firstName': '', 'lastName': ''};
  dynamic applyWork;
  dynamic profileCode;

  Future<dynamic> _futureApplyWork = Future.value(null);

  void initState() {
    model = widget.model;
    _callRead();
    _readTeacherJob();
    _callResumeData();
    _futureApplyWork = postDio('${server}m/teacherjob/applyWork/read', {
      'profileCode': profileCode,
    });
    super.initState();
  }

  _callRead() async {
    profileCode = await storage.read(key: 'profileCode25');
  }

  _readTeacherJob() async {
    var result = await postDio('${server}m/teacherjob/read', {
      'code': widget.model['code'],
    });
    if (result.length > 0) {
      setState(() {
        model = result[0];
      });
    }
  }

  _callResumeData() async {
    var value = await storage.read(key: 'resumeData') ?? "";
    var result = json.decode(value);

    setState(() {
      profile = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          toolbarHeight: 50,
          flexibleSpace: Container(
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10,
              left: 15,
              right: 15,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    child: Image.asset('assets/images/arrow_left_box_red.png'),
                  ),
                ),
                GestureDetector(
                  onTap: () => updateBookmark(context, model, profile),
                  child: Container(
                    width: 40,
                    height: 40,
                    child: Image.asset('assets/images/bookmark_box_pink.png'),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: ListView(
          padding: EdgeInsets.fromLTRB(
            15,
            0,
            15,
            MediaQuery.of(context).padding.bottom + 30,
          ),
          physics: BouncingScrollPhysics(),
          children: [
            SizedBox(height: 15),
            Container(
              // height: 220,
              alignment: Alignment.center,
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Color(0xFFEEBA33),
              ),
              child: Column(
                children: [
                  Container(
                    height: 90,
                    width: 90,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 5,
                          offset: Offset(0, 0.75),
                          color: Color(0xFF707070).withOpacity(0.5),
                        ),
                      ],
                    ),
                    child: loadingImageNetwork(
                      model['imageUrl'],
                      width: 59,
                      height: 56,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    model['title'],
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF9A1120),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    model['schoolName'],
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF9A1120).withOpacity(0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _boxOption(model['sexName']),
                      SizedBox(width: 10),
                      _boxOption(
                        model['jobTypeName'] == 'PartTime'
                            ? 'ชั่วคราว'
                            : 'ประจำ',
                      ),
                      SizedBox(width: 10),
                      _boxOption(model['provinceName']),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _iconDetail(
                  Image.asset(
                    'assets/images/location_red.png',
                    height: 40,
                    width: 28,
                  ),
                  'สถานที่',
                  '${model['provinceName']}',
                ),
                _iconDetail(
                  Image.asset(
                    'assets/images/wallet_red.png',
                    height: 32,
                    width: 35,
                  ),
                  'เงินเดือน',
                  checkSalary(model['salaryStart'], model['salaryEnd']),
                ),
                _iconDetail(
                  Image.asset(
                    'assets/images/employee_card_red.png',
                    height: 40,
                    width: 28,
                  ),
                  'จำนวนที่รับ',
                  '${model['receivedAmount']} คน',
                ),
                _iconDetail(
                  Image.asset(
                    'assets/images/calendar_red.png',
                    height: 35,
                    width: 35,
                  ),
                  'รับสมัครถึง',
                  dateStringToDate('${model['dateEnd']}', separate: '/'),
                ),
              ],
            ),
            Container(height: 3, color: Color(0xFF707070).withOpacity(0.15)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _btnDetail('ลักษณะงาน', '1'),
                _btnDetail('เกี่ยวกับโรงเรียน', '2'),
              ],
            ),
            SizedBox(height: 15),
            if (_selectedDescription == '1')
              Html(
                data: model['description'],
                style: {"body": Style(color: Colors.black.withOpacity(0.5))},
                onLinkTap:
                    (url, attributes, element) => launchUrl(
                      Uri.parse(url ?? ""),
                      mode: LaunchMode.externalApplication,
                    ),
              ),
            if (_selectedDescription == '2')
              Html(
                data: model['aboutSchool'],
                style: {"body": Style(color: Colors.black.withOpacity(0.5))},
                onLinkTap:
                    (url, attributes, element) => launchUrl(
                      Uri.parse(url ?? ""),
                      mode: LaunchMode.externalApplication,
                    ),
              ),
            SizedBox(height: 10),
            buildFutureApplyWork(),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  FutureBuilder buildFutureApplyWork() {
    return FutureBuilder<dynamic>(
      future: _futureApplyWork,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length > 0) {
            return GestureDetector(
              // onTap: () async {
              //   await _save();
              //   _dialogSuccess();
              // },
              child: Container(
                height: 40,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'ส่งใบสมัครแล้ว',
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
              ),
            );
          } else {
            return GestureDetector(
              onTap: () async {
                await _save();
                _dialogSuccess();
              },
              child: Container(
                height: 40,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Color(0xFFEEBA33),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'ส่งใบสมัคร',
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
              ),
            );
          }
        } else if (snapshot.hasError) {
          return Center(
            child: Container(
              color: Colors.white,
              child: dialogFail(context, reloadApp: true),
            ),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  _btnDetail(String title, String data) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedDescription = data),
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 3),
          decoration: BoxDecoration(
            color:
                _selectedDescription == data ? Color(0xFFF3E4E6) : Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            title,
            style: TextStyle(
              color:
                  _selectedDescription == data
                      ? Color(0xFF9A1120)
                      : Color(0xFF707070),
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }

  _iconDetail(Widget image, String title, String value) {
    return Expanded(
      child: Container(
        height: 140,
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 70,
              width: 70,
              // alignment: Alignment.center,
              // padding: EdgeInsets.all(15),
              // decoration: BoxDecoration(
              //   color: Color(0xFFF7F7F7),
              //   borderRadius: BorderRadius.circular(45),
              // ),
              child: image,
            ),
            Text(
              title,
              style: TextStyle(color: Color(0xFF707070), fontSize: 11),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  _boxOption(String title) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 1),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(title, style: TextStyle(fontSize: 13, color: Colors.white)),
    );
  }

  Future<dynamic> _dialogSuccess() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () {
            return Future.value(false);
          },
          child: AlertDialog(
            contentPadding: EdgeInsets.all(0),
            content: Container(
              width: 290,
              height: 160,
              decoration: new BoxDecoration(
                shape: BoxShape.rectangle,
                color: const Color(0xFFFFFF),
              ),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 10),
                    Text(
                      'ส่งใบสมัครสำเร็จ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'เราจะทำการส่งใบสมัครของท่าน ท่านสามารถเช็คสถานะที่ปุ่มแจ้งเตือนได้',
                      style: TextStyle(fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 35,
                        width: 160,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(0xFFEEBA33),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'ตกลง',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontFamily: 'Kanit',
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // child: //Contents here
            ),
          ),
        );
      },
    );
  }

  _save() async {
    var resumeCode = await storage.read(key: 'resumeCode');
    var result =
        await postDioMessage('${server}m/teacherjob/applyWork/create', {
          'teacherJobCode': model['code'],
          'profileCode': profileCode,
          'resumeCode': resumeCode,
          'updateBy': '${profile['firstName']} ${profile['lastName']}',
        });
    print(result);
  }
}
