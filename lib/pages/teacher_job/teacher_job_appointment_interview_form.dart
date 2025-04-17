import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:opec/pages/teacher_job/appointment_interview_list.dart';
import 'package:opec/shared/api_provider.dart';
import 'package:opec/widget/loading.dart';
import 'package:url_launcher/url_launcher.dart';

class TeacherJobAppointmentInterviewForm extends StatefulWidget {
  const TeacherJobAppointmentInterviewForm({
    Key? key,
    this.model,
    this.model1,
    required this.profileCode,
  }) : super(key: key);

  final dynamic model;
  final dynamic model1;
  final String profileCode;

  @override
  State<TeacherJobAppointmentInterviewForm> createState() =>
      _TeacherJobAppointmentInterviewFormState();
}

class _TeacherJobAppointmentInterviewFormState
    extends State<TeacherJobAppointmentInterviewForm> {
  final storage = FlutterSecureStorage();
  List<dynamic> files = [];
  Random random = Random();
  late TextEditingController _remarkEditingController;

  dynamic model;
  dynamic modelTeacherJob;
  dynamic profile = {'firstName': '', 'lastName': ''};
  dynamic applyWork;
  dynamic profileCode;

  void initState() {
    print(widget.profileCode);
    model = widget.model;
    print(model);
    print(widget.model1);
    _remarkEditingController = TextEditingController();

    _callRead();
    super.initState();
  }

  void dispose() {
    _remarkEditingController.dispose();

    super.dispose();
  }

  _callRead() async {
    var result = await postDio('${server}m/teacherjob/applyWork/read', {
      'code': model['code'],
      'profileCode': '',
    });

    // var resultTeacherJob =
    //     await postDio(server + 'm/teacherjob/read', {'code': ''});

    // if (resultTeacherJob != null) {
    //   setState(() {
    //     modelTeacherJob = resultTeacherJob[0];
    //   });
    // }

    if (result.length > 0) {
      setState(() {
        model = result[0];
        _remarkEditingController.text = model['resumeRemark'];
        if (model['resumeFiles'] != '') {
          // set files
          files = [];
          var filesSplit = model['resumeFiles'].split(',');
          for (var i = 0; i < filesSplit.length; i++) {
            var splitType = filesSplit[i].split('.');
            var splitTitle = filesSplit[i].split('/');

            String type = filesSplit[i];
            type = splitType[splitType.length - 1];

            String title = filesSplit[i];
            title = splitTitle[splitTitle.length - 1];

            files.add({
              'title': title,
              'type': type,
              'value': filesSplit[i],
              'id': random.nextInt(100),
            });
          }
          //
        }
      });
    }
  }

  update(dynamic model, dynamic modelApplyWork) async {
    var result =
        await postDioMessage('${server}m/teacherjob/applyWork/update', {
          'code': modelApplyWork['code'],
          'status': 'N',
          'updateBy': '${model['resumeFirstName']} ${model['resumeLastName']}',
        });
    print(result);
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
                  // onTap: () => update(model,),
                  child: Container(
                    width: 40,
                    height: 40,
                    child: Image.asset(
                      'assets/images/delete_appointment_interview.png',
                    ),
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
            //
            SizedBox(height: 20),
            Container(
              // height: 235,
              alignment: Alignment.center,
              padding: EdgeInsets.fromLTRB(15, 20, 15, 25),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Color(0xFFFDF7E8),
              ),
              child: Container(
                child: Column(
                  children: [
                    Container(
                      child: ClipRRect(
                        child: loadingImageNetwork(
                          model['resumeImageUrl'],
                          width: 90,
                          height: 90,
                          fit: BoxFit.fill,
                        ),
                        borderRadius: BorderRadius.circular(45),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '${model['resumeFirstName']} ${model['resumeLastName']}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        // color: Color(0xFF9A1120),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'ผู้สมัคร${model['jobTitle']}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        // color: Color(0xFF9A1120).withOpacity(0.5),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Wrap(
                      children: <Widget>[
                        buttonAppointmentInterview(
                          title:
                              'ประสบการณ์ ${model['resumeWorkExperience']} ปี',
                          backgroundColor: Color(0xFFFFFFFFF),
                        ),
                      ],
                      spacing: 10,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 25),
            Text(
              'ข้อมูลพื้นฐาน',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                // color: Color(0xFF9A1120).withOpacity(0.5),
              ),
              textAlign: TextAlign.start,
            ),
            SizedBox(height: 5),
            rowBasicInformationAppointmentInterview(
              image: 'assets/images/sex_appointment_interview.png',
              titleModel: model['resumeSex'],
              title: 'เพศ',
            ),
            SizedBox(height: 5),
            rowBasicInformationAppointmentInterview(
              image: 'assets/images/birthday_appointment_interview.png',
              titleModel: model['resumeBirthDay'],
              title: 'วันเกิด',
            ),
            SizedBox(height: 5),
            rowBasicInformationAppointmentInterview(
              image: 'assets/images/sex_appointment_interview.png',
              titleModel:
                  '${model['resumeFaculty']} , ${model['resumeUniversity']}',
              title: 'จบการศึกษาเมื่อปี ${model['resumeGraduationYear']}',
            ),
            SizedBox(height: 5),
            rowBasicInformationAppointmentInterview(
              image: 'assets/images/map_appointment_interview.png',
              titleModel:
                  '${model['resumeDistrictName']} , ${model['resumeProvinceName']}',
              title: 'เมืองปัจจุบัน',
            ),
            SizedBox(height: 30),
            Text(
              'สิ่งที่แนบมาด้วย',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                // color: Color(0xFF9A1120).withOpacity(0.5),
              ),
              textAlign: TextAlign.start,
            ),
            SizedBox(height: 5),
            ...files
                .map<Widget>(
                  (e) => rowAttachmentAppointmentInterview(
                    titleModel: e['title'],
                    value: e['value'],
                  ),
                )
                .toList(),
            SizedBox(height: 25),
            Text(
              'ข้อความจากผู้สมัคร',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                // color: Color(0xFF9A1120).withOpacity(0.5),
              ),
              textAlign: TextAlign.start,
            ),
            SizedBox(height: 5),
            TextFormField(
              enabled: false,
              controller: _remarkEditingController,
              decoration: _searchDecoration(),
              minLines: 4,
              maxLines: 6,
            ),
            SizedBox(height: 40),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => AppointmentInterviewList(
                          model: model,
                          profileCode: widget.profileCode,
                        ),
                  ),
                );
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
                  'นัดสัมภาษณ์',
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _searchDecoration({
    hintText = '',
    labelText = '',
    EdgeInsets contentPadding = const EdgeInsets.only(
      left: 14,
      right: 14,
      top: 12,
    ),
  }) {
    return InputDecoration(
      filled: true,
      hintText: hintText,
      hintStyle: TextStyle(fontSize: 12, color: Color(0xFF707070)),
      fillColor: Colors.transparent,
      contentPadding: contentPadding,
      labelText: labelText,
      labelStyle: TextStyle(color: Color(0xFF707070), fontSize: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(width: 1, color: Color(0xFFE4E4E4)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(width: 1, color: Color(0xFFE4E4E4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(width: 1, color: Color(0xFFEEBA33)),
      ),
      errorStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 10.0),
    );
  }

  //
}

buttonAppointmentInterview({
  required String title,
  Color? backgroundColor,
  // double width = double.infinity,
  // double fontSize = 18.0,
  // double elevation = 5.0,
  // FontWeight fontWeight = FontWeight.normal,
  // Color fontColor = Colors.black,
  // EdgeInsets margin,
  // EdgeInsets padding,
  // Function callback,
}) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(17),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/awesome_check_circle.png',
          width: 10,
          height: 10,
        ),
        SizedBox(width: 5),
        Text(
          title,
          style: TextStyle(
            color: Color(0xFFEEBA33),
            fontSize: 11,
            // fontWeight: FontWeight.normal,
          ),
        ),
      ],
    ),
  );
}

rowBasicInformationAppointmentInterview({
  required String title,
  required String titleModel,
  required String image,
  Color? backgroundColor,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Image.asset(image, height: 30, width: 30),
      SizedBox(width: 15),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: Text(
                titleModel,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                  // color: Color(0xFF9A1120).withOpacity(0.5),
                ),
                textAlign: TextAlign.start,
              ),
            ),
            Container(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w300,
                  // color: Color(0xFF9A1120).withOpacity(0.5),
                ),
                textAlign: TextAlign.start,
              ),
            ),
            SizedBox(height: 10),
            Container(
              height: 1,
              width: double.infinity,
              color: Color(0x40707070),
            ),
          ],
        ),
      ),
    ],
  );
}

rowAttachmentAppointmentInterview({
  required String titleModel,
  Color? backgroundColor,
  required String value,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Image.asset(
        'assets/images/document_appointment_interview.png',
        height: 30,
        width: 30,
      ),
      SizedBox(width: 15),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: Text(
                titleModel,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                  // color: Color(0xFF9A1120).withOpacity(0.5),
                ),
                textAlign: TextAlign.start,
              ),
            ),
            SizedBox(height: 5),
            InkWell(
              onTap:
                  () => launchUrl(
                    Uri.parse(value),
                    mode: LaunchMode.externalApplication,
                  ),
              child: Container(
                height: 25,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(color: Color(0xFFEDB942)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/metro-file-picture.png',
                      height: 10,
                      width: 9,
                    ),
                    SizedBox(width: 5),
                    Container(
                      child: Text(
                        'วุฒิการศึกษา',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w300,
                          // color: Color(0xFF9A1120).withOpacity(0.5),
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              height: 1,
              width: double.infinity,
              color: Color(0x40707070),
            ),
          ],
        ),
      ),
    ],
  );
}
