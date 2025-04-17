import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:opec/pages/teacher_job/teacher_job_appointment_interview_form.dart';
import 'package:opec/shared/api_provider.dart';
import 'package:opec/shared/extension.dart';
import 'package:opec/widget/dialog.dart';
import 'package:opec/widget/loading.dart';
import 'package:url_launcher/url_launcher.dart';

class TeacherJobFormBySchool extends StatefulWidget {
  const TeacherJobFormBySchool({
    Key? key,
    this.model,
    required this.profileCode,
  }) : super(key: key);

  final dynamic model;
  final String profileCode;

  @override
  State<TeacherJobFormBySchool> createState() => _TeacherJobFormBySchoolState();
}

class _TeacherJobFormBySchoolState extends State<TeacherJobFormBySchool> {
  final storage = FlutterSecureStorage();
  Future<dynamic> _futureApplyWorkN = Future.value(null);
  Future<dynamic> _futureApplyWorkA = Future.value(null);
  String _selectedDescription = '1';

  dynamic model;
  dynamic profile = {'firstName': '', 'lastName': ''};
  dynamic modelApplyWork;

  void initState() {
    print(widget.profileCode);
    model = widget.model;

    _callRead();
    _futureApplyWorkA = postDio('${server}m/teacherjob/applyWork/read', {
      // 'skip': 0,
      // 'limit': 4,
      'profileCode': '',
      'teacherJobCode': model['code'],
      'status': 'A',
    });
    _futureApplyWorkN = postDio('${server}m/teacherjob/applyWork/read', {
      // 'skip': 0,
      // 'limit': 4,
      'profileCode': '',
      'teacherJobCode': model['code'],
      'status': 'N',
    });

    super.initState();
  }

  _callRead() async {
    var result = await postDio('${server}m/teacherjob/read', {
      'code': model['code'],
    });
    // var applyWork = await postDio(server + 'm/teacherjob/applyWork/read', {
    //   'profileCode': profileCode,
    //   'teacherJobCode': model['code'],
    // });

    if (result.length > 0) {
      setState(() {
        model = result[0];
      });
    }

    // if (applyWork.length > 0) {
    //   setState(() {
    //     modelApplyWork = applyWork[0];
    //   });
    // }

    // print(modelApplyWork);
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
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    child: Image.asset('assets/images/arrow_left_box_red.png'),
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
                  Stack(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 90,
                            width: 90,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: loadingImageNetwork(
                              model['imageUrl'],
                              width: 60,
                              height: 60,
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: InkWell(
                          onTap:
                              () => buildModalTeacherJobFormBySchool(
                                context,
                                // model,
                              ),
                          child: Container(
                            child: Image.asset(
                              'assets/images/i_teacher_job_form.png',
                              width: 20,
                              height: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
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
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ผู้ผ่านเข้าสัมภาษณ์',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                // InkWell(
                //   // onTap: () => Navigator.push(
                //   //   context,
                //   //   MaterialPageRoute(
                //   //       builder: (_) => JobListPage(filter: {}),
                //   //       ),
                //   // ),
                //   child: Text(
                //     'ดูทั้งหมด',
                //     style: TextStyle(
                //       fontSize: 13,
                //       fontWeight: FontWeight.normal,
                //       decoration: TextDecoration.underline,
                //     ),
                //   ),
                // ),
              ],
            ),
            SizedBox(height: 10),
            _buildFutureListVerticalTeacherJob(model),
            SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ใบสมัคร',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                // InkWell(
                //   // onTap: () => Navigator.push(
                //   //   context,
                //   //   MaterialPageRoute(
                //   //       builder: (_) => JobListPage(filter: {}),
                //   //       ),
                //   // ),
                //   child: Text(
                //     'ดูทั้งหมด',
                //     style: TextStyle(
                //       fontSize: 13,
                //       fontWeight: FontWeight.normal,
                //       decoration: TextDecoration.underline,
                //     ),
                //   ),
                // ),
              ],
            ),
            SizedBox(height: 10),
            _buildFutureListTeacherJob(),
            SizedBox(height: 60),
            Center(
              child: Text(
                'ปิดรับสมัคร                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 ',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFFEEBA33),
                  decoration: TextDecoration.underline,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildModalTeacherJobFormBySchool(
    BuildContext context,
    // dynamic model,
  ) {
    return showCupertinoModalBottomSheet(
      context: context,
      barrierColor: Colors.white.withOpacity(0.4),
      backgroundColor: Colors.white.withOpacity(0.4),
      builder: (context) {
        return StatefulBuilder(
          builder: (
            BuildContext context,
            StateSetter setState /*You can rename this!*/,
          ) {
            return Material(
              type: MaterialType.transparency,
              child: Container(
                height: MediaQuery.of(context).size.height * 60 / 100,
                width: double.infinity,
                margin: EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 6,
                      offset: Offset(0.75, 0),
                      color: Colors.grey.withOpacity(0.4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(15),
                      child: Column(
                        children: [
                          // Center(
                          //   child: Text(
                          //     title,
                          //     style:
                          //         TextStyle(fontSize: 20, color: Color(0xFF011895)),
                          //   ),
                          // ),
                          SizedBox(height: 37),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _iconDetail(
                                Image.asset('assets/images/location_red.png'),
                                'สถานที่',
                                '${model['provinceName']}',
                              ),
                              _iconDetail(
                                Image.asset('assets/images/wallet_red.png'),
                                'เงินเดือน',
                                checkSalary(
                                  model['salaryStart'],
                                  model['salaryEnd'],
                                ),
                              ),
                              _iconDetail(
                                Image.asset(
                                  'assets/images/employee_card_red.png',
                                ),
                                'จำนวนที่รับ',
                                '${model['receivedAmount']} คน',
                              ),
                              _iconDetail(
                                Image.asset('assets/images/calendar_red.png'),
                                'รับสมัครถึง',
                                dateStringToDate(
                                  '${model['dateEnd']}',
                                  separate: '/',
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 20),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Color(0xFF707070).withOpacity(0.15),
                                width: 3,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _btnDetail('ลักษณะงาน', '1', setState),
                              _btnDetail('เกี่ยวกับโรงเรียน', '2', setState),
                            ],
                          ),
                          SizedBox(height: 15),
                          if (_selectedDescription == '1')
                            Html(
                              data: model['description'],
                              style: {
                                "body": Style(
                                  color: Colors.black.withOpacity(0.5),
                                ),
                              },
                              onLinkTap:
                                  (url, attributes, element) =>
                                      launchUrl(Uri.parse(url ?? "")),
                            ),
                          if (_selectedDescription == '2')
                            Html(
                              data: model['aboutSchool'],
                              style: {
                                "body": Style(
                                  color: Colors.black.withOpacity(0.5),
                                ),
                              },
                              onLinkTap:
                                  (url, attributes, element) =>
                                      launchUrl(Uri.parse(url ?? "")),
                            ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 15,
                      right: 15,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: 35,
                          width: 35,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF9A1120),
                          ),
                          child: Icon(
                            Icons.clear,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  _btnDetail(String title, String data, StateSetter setState) {
    return Expanded(
      child: InkWell(
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

  _cardTeacherJob(dynamic model) {
    return InkWell(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => TeacherJobAppointmentInterviewForm(
                    model: model,
                    profileCode: widget.profileCode,
                    // title: title,
                  ),
            ),
          ),
      child: Container(
        height: 160,
        width: 120,
        decoration: BoxDecoration(
          color: Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: Color(0xFFF3E4E6)),
        ),
        child: Column(
          children: [
            SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(60),
              child: Image.network(
                model['resumeImageUrl'],
                height: 85,
                width: 85,
                fit: BoxFit.fill,
              ),
            ),
            SizedBox(height: 10),
            Text(
              '${model['resumeFirstName']} ${model['resumeLastName']}',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              margin: EdgeInsets.symmetric(vertical: 2),
              decoration: BoxDecoration(
                color: Color(0xFFF3E4E6),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Text(
                'ประสบการณ์ ${model['resumeWorkExperience']} ปี',
                style: TextStyle(
                  color: Color(0xFF9A1120),
                  fontSize: 11,
                  // fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _cardVerticalTeacherJob(dynamic model, dynamic modelTeacherJob) {
    var workExperienceModelTeacherJob = int.parse(
      modelTeacherJob['workExperience'],
    );
    var workExperienceModel = int.parse(model['resumeWorkExperience']);
    bool workExperience = false;
    bool isFullTime = false;

    if (workExperienceModel > workExperienceModelTeacherJob) {
      workExperience = true;
    } else {
      workExperience = false;
    }

    if (model['resumeIsFullTime'] == modelTeacherJob['isFullTime']) {
      isFullTime = true;
    } else {
      isFullTime = false;
    }

    return InkWell(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => TeacherJobAppointmentInterviewForm(
                    model: model,
                    profileCode: widget.profileCode,
                    // title: title,
                  ),
            ),
          ),
      child: Container(
        // height: 130,
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Color(0xFFF3E4E6)),
        ),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: Image.network(
                    model['resumeImageUrl'],
                    height: 70,
                    width: 70,
                    fit: BoxFit.fill,
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),
                        Container(
                          child: Text(
                            '${model['resumeFirstName']} ${model['resumeLastName']}',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 5),
                        Container(
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 5,
                            children: <Widget>[
                              workExperience
                                  ? buttonAppointmentInterview(
                                    title:
                                        'ประสบการณ์ ${model['resumeWorkExperience']} ปี',
                                    backgroundColor: Color(0xFFFDF7E8),
                                  )
                                  : Container(),
                              isFullTime
                                  ? buttonAppointmentInterview(
                                    title: 'ประจำ',
                                    backgroundColor: Color(0xFFFDF7E8),
                                  )
                                  : Container(),
                              // buttonAppointmentInterview(
                              //   title:
                              //       'เงินเดือน ${model['resumeExpectedSalaryStart']}-${model['resumeExpectedSalaryEnd']}',
                              //   backgroundColor: Color(0xFFFDF7E8),
                              // ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10),
              ],
            ),
            Positioned(
              right: 0,
              top: 0,
              child: InkWell(
                child: Container(
                  child: Image.asset(
                    'assets/images/appointment_interview.png',
                    width: 30,
                    height: 30,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildFutureListVerticalTeacherJob(modelTeacherJob) {
    return Container(
      height: 270,
      child: FutureBuilder<dynamic>(
        future: _futureApplyWorkA,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.length == 0) {
              return Container(
                width: double.infinity,
                child: Center(child: Text('ไม่มีข้อมูล')),
              );
            } else {
              return ListView.separated(
                shrinkWrap: true,
                physics: BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                separatorBuilder: (_, __) => SizedBox(width: 10),
                itemCount: snapshot.data.length,
                itemBuilder:
                    (context, index) => _cardVerticalTeacherJob(
                      snapshot.data[index],
                      modelTeacherJob,
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
      ),
    );
  }

  _buildFutureListTeacherJob() {
    return Container(
      height: 160,
      child: FutureBuilder<dynamic>(
        future: _futureApplyWorkN,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.length == 0) {
              return Container(
                height: 160,
                width: double.infinity,
                // color: Colors.red,
                child: Center(child: Text('ไม่มีข้อมูล')),
              );
            } else {
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                physics: BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                separatorBuilder: (_, __) => SizedBox(width: 10),
                itemCount: snapshot.data.length,
                itemBuilder:
                    (context, index) => _cardTeacherJob(snapshot.data[index]),
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
      ),
    );
  }

  //
}
