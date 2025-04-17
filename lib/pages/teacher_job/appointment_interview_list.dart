import 'package:flutter/material.dart';
import 'package:opec/pages/teacher_job/appointment_interview_form.dart';
import 'package:opec/shared/api_provider.dart';
import 'package:opec/shared/extension.dart';
import 'package:opec/widget/dialog.dart';

class AppointmentInterviewList extends StatefulWidget {
  const AppointmentInterviewList({
    Key? key,
    this.model,
    required this.profileCode,
  }) : super(key: key);

  final dynamic model;
  final String profileCode;

  @override
  State<AppointmentInterviewList> createState() =>
      _AppointmentInterviewListState();
}

class _AppointmentInterviewListState extends State<AppointmentInterviewList> {
  Future<dynamic> _futureAppointmentInterview = Future.value(null);
  dynamic modelApplyWork;

  @override
  void initState() {
    print(widget.profileCode);
    modelApplyWork = widget.model;
    _callRead();

    super.initState();
  }

  void dispose() {
    super.dispose();
  }

  _callRead() async {
    _futureAppointmentInterview =
        postDio(server + 'm/teacherjob/appointmentInterview/read', {
      'profileCode': widget.profileCode,
    });
  }

  Future<dynamic> sendEmail(
    dynamic model,
    dynamic modelApplyWork,
  ) async {
    var dateStart = dateStringToDateStringFormat(model['dateStart']);
    var dateEnd = dateStringToDateStringFormat(model['dateEnd']);

    final result = await postObjectData('m/teacherjob/sendEmail', {
      'email': '${model['resumeEmail']},${modelApplyWork['resumeEmail']}',
      'subject': model['title'],
      'description':
          'สถานที่สัมภาษณ์ : ${model['schoolName']} \nวันกำหนดสัมภาษณ์ : $dateStart-$dateEnd \nหากมีข้อสงศัยโปรดติดต่อกลับอีเมลที่ได้รับ'
    });

    // setState(() {
    // });
    print(result['status']);

    if (result['status'] == 'S') {
      update(model, modelApplyWork);
      return _dialogSuccess();
    } else {
      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(result['message'].toString()),
          );
        },
      );
    }
  }

  update(
    dynamic model,
    dynamic modelApplyWork,
  ) async {
    var result =
        await postDioMessage(server + 'm/teacherjob/applyWork/update', {
      'code': modelApplyWork['code'],
      'status': 'A',
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
            child: Row(children: [
              InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  child: Image.asset('assets/images/arrow_left_box_red.png'),
                ),
              ),
            ]),
          ),
        ),
        body: ListView(
          padding: EdgeInsets.fromLTRB(
              15, 0, 15, MediaQuery.of(context).padding.bottom + 30),
          physics: BouncingScrollPhysics(),
          children: [
            SizedBox(height: 20),
            Text(
              'ตารางนัดสัมภาษณ์',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            FutureBuilder<dynamic>(
              future: _futureAppointmentInterview,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.separated(
                    physics: ClampingScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: ((context, index) => _card(
                          snapshot.data[index],
                          modelApplyWork: modelApplyWork,
                        )),
                    separatorBuilder: (_, __) => SizedBox(height: 10),
                    itemCount: snapshot.data.length,
                  );
                } else {
                  return Container(
                    height: 304,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                      color: Color(0xFFEEBA33),
                    ),
                  );
                }
              },
            ),
            SizedBox(height: 50),
            Center(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AppointmentInterviewForm(
                        model: modelApplyWork,
                        profileCode: widget.profileCode,
                      ),
                    ),
                  );
                },
                child: Container(
                  height: 40,
                  width: 230,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Color(0xFFEEBA33),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'สร้างนัดสัมภาษณ์',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(dynamic model, {dynamic modelApplyWork}) {
    print(model);
    return InkWell(
      onTap: () async {
        dialogAppointmentInterview(
          context,
          title: 'ยืนยันนัด',
          description:
              'กรุณายืนยันนัดสัมภาษณ์ หลังจากยืนยันแล้วระบบจะแจ้งเมลไปยังผู้สมัครต่อไป',
          yes: 'ยืนยัน',
          no: 'ยกเลิก',
          callBackYes: () async {
            sendEmail(model, modelApplyWork);
          },
        );
      },
      child: Container(
        height: 130,
        width: double.infinity,
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Color(0xFFFFFFFF),
          border: Border.all(color: Color(0xFFF3E4E6)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model['title'],
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 2,
                  ),
                  SizedBox(height: 5),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(17),
                      color: Color(0x7DFDF7E8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/feather-map-pin.png',
                          height: 10,
                          width: 8,
                        ),
                        SizedBox(width: 5),
                        Text(
                          model['schoolName'],
                          style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFFEEBA33),
                              overflow: TextOverflow.ellipsis),
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(17),
                      color: Color(0x7DFDF7E8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/noun-schedule.png',
                          height: 10,
                          width: 10,
                        ),
                        SizedBox(width: 5),
                        Text(
                          '${dateStringToDateStringFormatDot(model['dateStart'])} - ${dateStringToDateStringFormatDot(model['dateEnd'])}',
                          style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFFEEBA33),
                              overflow: TextOverflow.ellipsis),
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Color(0xFFEEBA33),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '3',
                    style: TextStyle(
                      fontSize: 33,
                      color: Color(0xFFFFFFFF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '/${model['receivedAmount']}',
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xFFFFFFFF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
                      'ยืนยันนัดสัมภาษณ์สำเร็จ ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'กรุณาตรวจสอบข้อความ\nที่อีเมลที่ลงทะเบียนไว้',
                      style: TextStyle(
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
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
                    )
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
//
}
