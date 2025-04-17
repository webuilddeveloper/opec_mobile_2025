import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:opec/menu.dart';

import 'package:opec/shared/api_provider.dart';
import 'package:opec/widget/dialog.dart';
import 'package:opec/widget/header.dart';
import 'package:opec/widget/text_form_field.dart';


class CheckPermissionMain extends StatefulWidget {
  CheckPermissionMain({Key? key, required this.reference}) : super(key: key);
  final String reference;
  @override
  _CheckPermissionMain createState() => _CheckPermissionMain();
}

class _CheckPermissionMain extends State<CheckPermissionMain> {
  final storage = new FlutterSecureStorage();
  bool isConfirm = false;
  int currentStep = 0;
  String profileCode = "";
  String updateDate = "";
  String expDate = "";
  String linkUrl =
      "https://deeplink.doctoratoz.co/?m=prod&a=daz&c=opeconmobile";
  dynamic _model;
  String selectedType = '1';

  @override
  void initState() {
    _callRead();
    super.initState();
  }

  void goBack() async {
    // Navigator.pop(context, false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Menu(),
      ),
    );
  }

  _callRead() async {
    profileCode = await storage.read(key: 'profileCode25') ?? "";
    // _futureProfile = postDio(profileReadApi, {'code': profileCode});
    // _profile = await _futureProfile;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        // Note: Sensitivity is integer used when you don't want to mess up vertical drag
        if (details.delta.dx > 10) {
          // Right Swipe
          Navigator.pop(context);
        } else if (details.delta.dx < -0) {
          //Left Swipe
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: header(context, goBack, title: 'ตรวจสอบสิทธิ์'),
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (OverscrollIndicatorNotification overScroll) {
            return false;
          },
          child: Stepper(
            type: StepperType.horizontal,
            currentStep: currentStep,
            //onStepTapped: (step) => setState(() => currentStep = step),
            onStepContinue: () async {
              final isLastStep = currentStep == getSteps().length - 1;
              if (isLastStep) {
                setState(() {
                  isConfirm = true;
                });
                // print('-------- isLastStep -----');
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Menu(),
                  ),
                );
              } else {
                var ischk = false;
                if (currentStep == 0) ischk = await chkStep1();

                if (ischk) {
                  setState(() {
                    currentStep += 1;
                  });
                }
              }
            },
            onStepCancel: currentStep == 0
                ? null
                : () => setState(() {
                      currentStep -= 1;
                    }),
            steps: getSteps(),
            controlsBuilder: (context, ControlsDetails detail) {
              final isLastStep = currentStep == getSteps().length - 1;
              return Container(
                margin: EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    if (currentStep != 0 && isLastStep)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: detail.onStepCancel,
                          child: Text("กลับ"),
                        ),
                      ),
                    SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            Color(0xFF9A1120),
                          ),
                        ),
                        onPressed: detail.onStepContinue,
                        child: Text(isLastStep ? "เสร็จสิ้น" : "ถัดไป"),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  chkStep1() async {
    if (txtIdCard.text != '' || txtUserName.text != '') {
      print('$url/td-opec-api/m/checkPermission/read');
      _model = await postDio('$url/td-opec-api/m/checkPermission/read',
          {'idcard': txtIdCard.text, 'username': txtUserName.text});
      return true;
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialogFail(
            context,
            title: 'กรุณารหัสประจำตัวประชาชน หรือ กรอกชื่อและนามสกุล',
            background: Colors.transparent,
          );
        },
      );
      return false;
    }
  }

  List<Step> getSteps() => [
        Step(
          state: currentStep > 0 ? StepState.complete : StepState.indexed,
          isActive: currentStep >= 0,
          title: Text("ตรวจสอบ"),
          content: _contentStep1(),
        ),
        Step(
          state: currentStep > 2 ? StepState.complete : StepState.indexed,
          isActive: currentStep >= 1,
          title: Text("เสร็จสิ้น"),
          content: _contentStep2(),
        ),
      ];

  final txtIdCard = TextEditingController();
  final txtUserName = TextEditingController();

  _contentStep1() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ตรวจสอบสิทธิ์รับเงิน 2,000 บาท',
            style: TextStyle(
              fontSize: 17.00,
              fontFamily: 'Kanit',
              fontWeight: FontWeight.w500,
              // color: Color(0xFFBC0611),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            'กรุณาใส่เลขบัตรประชาชน',
            style: TextStyle(
              fontSize: 13.00,
              fontFamily: 'Kanit',
              // fontWeight: FontWeight.w500,
              color: Color(0xFF707070),
            ),
          ),
          labelTextFormField('รหัสประจำตัวประชาชน', mandatory: false),
          textFormIdCardField(
            txtIdCard,
            'รหัสประจำตัวประชาชน',
            'รหัสประจำตัวประชาชน',
            true,
            false,
          ),
          Text(
            'หรือกรอกชื่อและนามสกุลของคุณครูที่ท่านต้องการตรวจสอบ',
            style: TextStyle(
              fontSize: 13.00,
              fontFamily: 'Kanit',
              // fontWeight: FontWeight.w500,
              color: Color(0xFF707070),
            ),
          ),
          labelTextFormField('ชื่อและนามสกุล', mandatory: false),
          textFormField(
            txtUserName,
            null,
            'ชื่อและนามสกุล',
            'ชื่อและนามสกุล',
            true,
            false,
            false,
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            '''ข้อมูลนักเรียนอายุ 2 ปี ที่มีสิทธิ์ตามมาตรการให้ความช่วยเหลือผู้ปกครองและนักเรียนด้านค่าใช้จ่ายทางด้านการศึกษา จำนวน 2,000 บาทต่อนักเรียน 1 คน
            
หมายเหตุ : ใช้ข้อมูลนักเรียน ณ วันที่ 18 ตุลาคม 2564''',
            style: TextStyle(
              fontSize: 17.00,
              fontFamily: 'Kanit',
              fontWeight: FontWeight.w500,
              // color: Color(0xFFBC0611),
            ),
          ),
        ],
      ),
    );
  }

  _contentStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
          child: Text(
            'ตรวจสอบสิทธิ์เสร็จสิ้น',
            style: TextStyle(
              fontSize: 20.00,
              fontFamily: 'Kanit',
              fontWeight: FontWeight.w500,
              color: Color(0xFF408C40),
            ),
          ),
        ),
        SizedBox(height: 10),
        _model == null
            ? Container(
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
                child: Text(
                  'ไม่พบสิทธิ์ของท่าน',
                  style: TextStyle(
                    fontSize: 20.00,
                    fontFamily: 'Kanit',
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFFF3300),
                  ),
                ),
              )
            : Container(
                height: (MediaQuery.of(context).size.height / 100) * 50,
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.only(
                              left: (MediaQuery.of(context).size.width / 100) *
                                  5),
                          width: (MediaQuery.of(context).size.width / 100) * 37,
                          child: new Text(
                            "โรงเรียน",
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Kanit',
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Container(
                          child: new Text(
                            '   ${_model["school_Name"]}',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Kanit',
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.only(
                              left: (MediaQuery.of(context).size.width / 100) *
                                  5),
                          width: (MediaQuery.of(context).size.width / 100) * 37,
                          child: new Text(
                            "เบอร์ติดต่อโรงเรียน",
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Kanit',
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Container(
                          child: new Text(
                            '   ${_model["phone"]}',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Kanit',
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.only(
                              left: (MediaQuery.of(context).size.width / 100) *
                                  5),
                          width: (MediaQuery.of(context).size.width / 100) * 37,
                          child: new Text(
                            "จังหวัด",
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Kanit',
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Container(
                          child: new Text(
                            '   ${_model["province"]}',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Kanit',
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.only(
                              left: (MediaQuery.of(context).size.width / 100) *
                                  5),
                          width: (MediaQuery.of(context).size.width / 100) * 37,
                          child: new Text(
                            "รหัสบัตรประชาชน",
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Kanit',
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Container(
                          child: new Text(
                            '   ${_model["idcard"]}',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Kanit',
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.only(
                              left: (MediaQuery.of(context).size.width / 100) *
                                  5),
                          width: (MediaQuery.of(context).size.width / 100) * 37,
                          child: new Text(
                            "ชื่อ - นามสกุล",
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Kanit',
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Container(
                          child: new Text(
                            '   ${_model["firstName"]} ${_model["lastName"]}',
                            style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Kanit',
                                color: Colors.black,
                                overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.only(
                              left: (MediaQuery.of(context).size.width / 100) *
                                  5),
                          width: (MediaQuery.of(context).size.width / 100) * 37,
                          child: new Text(
                            "วันเดือนปีเกิด",
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Kanit',
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Container(
                          child: new Text(
                            (_model["birthDate"] ?? '').toString() != ''
                                ? "   ${DateFormat("dd-MM-yyyy").format(DateTime.parse(_model["birthDate"].replaceAll("-", "")))}"
                                : '',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Kanit',
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                  ],
                ),
              ),
      ],
    );
  }
}
