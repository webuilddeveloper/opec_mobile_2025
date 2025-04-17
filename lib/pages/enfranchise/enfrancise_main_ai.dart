import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:opec/menu.dart';

import 'package:opec/shared/api_provider.dart';
import 'package:opec/widget/dialog.dart';
import 'package:opec/widget/header.dart';
import 'package:opec/widget/link_url.dart';
import 'package:opec/widget/text_form_field.dart';
import 'dart:io' show Platform;

class EnfranchiseMainAi extends StatefulWidget {
  EnfranchiseMainAi({Key? key, required this.reference}) : super(key: key);
  final String reference;
  @override
  _EnfranchiseMainAi createState() => _EnfranchiseMainAi();
}

class _EnfranchiseMainAi extends State<EnfranchiseMainAi> {
  final storage = new FlutterSecureStorage();
  bool isConfirm = false;
  bool checkSendReply = true;
  int currentStep = 0;
  String profileCode = "";
  String ref_code = "";
  String updateDate = "";
  String expDate = "";
  String age = "";
  String test123 = "";
  String linkUrl =
      "https://deeplink.doctoratoz.co/?m=prod&a=daz&c=opeconmobile";
  Future<dynamic> _futureEnfrancise = Future.value(null);
  Future<dynamic> _futureProfile = Future.value(null);
  Future<dynamic> _futureChkEnfrancise = Future.value(null);
  Future<dynamic> _futurePoll = Future.value(null);
  bool isChkmodel = false;
  bool isPolicy = false;
  List<dynamic> listAnswer = [];
  dynamic _enfrancise;
  dynamic _profile;
  dynamic _chkenfrancise;
  String selectedType = '1';
  late int _selectedIndex;
  late String realAge;
  final _textEditingController = TextEditingController();

  @override
  void initState() {
    _callRead();
    super.initState();
  }

  void goBack() async {
    // Navigator.pop(context, false);
    Navigator.push(context, MaterialPageRoute(builder: (context) => Menu()));
  }

  _callRead() async {
    profileCode = await storage.read(key: 'profileCode25') ?? "";
    _futureEnfrancise = postDio('${server}m/enfranchise/readAI', {
      'code': profileCode,
      'reference': widget.reference,
    });
    _enfrancise = await _futureEnfrancise;
    _futureProfile = postDio(profileReadApi, {'code': profileCode});
    _profile = await _futureProfile;
    if (_profile['birthDay'] != null && _profile['birthDay'] != "") {
      var year = _profile['birthDay'].toString().substring(0, 4);
      DateTime now = DateTime.now();
      String curYear = DateFormat('yyyy').format(now);
      realAge = (int.parse(curYear) - int.parse(year)).toString();
    } else {
      realAge = "0";
    }
    setState(() {
      _futurePoll = postDio('${pollApi}all/readAI', {
        'skip': 0,
        'limit': 1,
        // 'code': '20220816133938-951-377',
        'category': "AI",
        // 'username': _profile['username']
      });
    });

    if (_enfrancise.length > 0) {
      isConfirm = true;
      currentStep = getSteps().length - 1;
      setState(() {
        txtFirstName.text = (_enfrancise[0]['firstName'] ?? '');
        txtLastName.text = (_enfrancise[0]['lastName'] ?? '');
        txtPhone.text = (_enfrancise[0]['phone'] ?? '');
        txtEmail.text = (_enfrancise[0]['email'] ?? '');
        _selectedAgeRange = (_enfrancise[0]['ageRange'] ?? '');
        age = (_enfrancise[0]['age'] ?? '');
        ref_code = (_enfrancise[0]['ref_code'] ?? '');
        updateDate = (_enfrancise[0]['updateDate'] ?? '');
        expDate = (_enfrancise[0]['expDate'] ?? '');
        linkUrl = (_enfrancise[0]['linkUrl'] ?? '');
      });
    } else {
      if (((_profile['opecCategoryId'] ?? "0") == "18") ||
          ((_profile['opecCategoryId'] ?? "0") == "1") ||
          ((_profile['opecCategoryId'] ?? "0") == "2")) {
        setState(() {
          txtFirstName.text = (_profile['firstName'] ?? '');
          txtLastName.text = (_profile['lastName'] ?? '');
          txtPhone.text = (_profile['phone'] ?? '');
          txtEmail.text = (_profile['email'] ?? '');
          age = realAge;
        });
      }
    }
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
        appBar: header(context, goBack, title: 'รับสิทธิ์'),
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
                  MaterialPageRoute(builder: (context) => Menu()),
                );
              } else {
                var ischk = false;
                if (currentStep == 0) {
                  ischk = await chkStep1(futureModel: _futurePoll);
                }
                if (currentStep == 1) ischk = await chkStep2();
                if (ischk) {
                  setState(() {
                    currentStep += 1;
                  });
                }
              }
            },
            onStepCancel:
                currentStep == 0
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
                    if (currentStep != 0 && !isLastStep)
                      Expanded(
                        child: ElevatedButton(
                          child: Text("Back"),
                          onPressed: detail.onStepCancel,
                        ),
                      ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            Color(0xFF9A1120),
                          ),
                        ),
                        child: Text(isLastStep ? "เสร็จสิ้น" : "ถัดไป"),
                        onPressed: detail.onStepContinue,
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

  chkStep2() async {
    var question1;
    var answers1;
    var question2;
    var answers2;
    if (isPolicy == true) {
      if (listAnswer.length > 0) {
        for (var i = 0; i < listAnswer.length; i++) {
          if (i == 0) {
            question1 = listAnswer[i]['question'];
            answers1 = listAnswer[i]['answers'];
          } else if (i == 1) {
            question2 = listAnswer[i]['question'];
            answers2 = listAnswer[i]['answers'];
          }
        }
      }
      if ((txtFirstName.text == "") ||
          (txtLastName.text == "") ||
          (txtPhone.text == "")) {
        dialog(
          context,
          title: 'ทำรายการไม่สำเสร็จ',
          description: 'กรุณากรอกข้อมูลให้ถูกต้องและครบถ้วน',
        );
        return false;
      } else {
        if (txtPhone.text.replaceAll('-', '').trim().length != 10) {
          dialog(
            context,
            title: 'เบอร์โทรศัพท์',
            description: 'กรุณาใส่เบอร์โทรให้ถูกต้อง',
          );
          return false;
        }
        if (txtPhone.text.replaceAll('-', '').trim().length == 10) {
          _futureChkEnfrancise = post('${server}m/enfranchise/readAI', {
            'phone': txtPhone.text.replaceAll('-', '').trim(),
          });
          _chkenfrancise = await _futureChkEnfrancise;
          if (_chkenfrancise.length > 0) {
            dialog(
              context,
              title: 'เบอร์โทรศัพท์',
              description: 'มีเบอร์โทรนี้อยู่ในระบบแล้ว ไม่สามารถรับสิทธิ์ได้',
            );
            return false;
          } else {
            var data = {
              "profileCode": profileCode,
              "reference": widget.reference,
              "firstName": txtFirstName.text,
              "lastName": txtLastName.text,
              "phone": txtPhone.text,
              "ageRange": _selectedAgeRange,
              "age": realAge,
              "isPolicy": isPolicy,
              "updateBy": _profile['username'],
              "question1": question1,
              "answers1": answers1,
              "question2": question2,
              "answers2": answers2,
            };

            postDio(server + 'm/enfranchise/createAI', data);
            // postDio(server + 'm/poll/reply/updateStatus',
            //     {'username': _profile['username']});

            postDio(server + 'm/policy/create', {
              "reference": "AI",
              "isActive": true,
            });
            chkPoll(futureModel: _futurePoll);
            _callRead();

            return true;
          }
        } else {
          var data = {
            "profileCode": profileCode,
            "reference": widget.reference,
            "firstName": txtFirstName.text,
            "lastName": txtLastName.text,
            "phone": txtPhone.text,
            "ageRange": _selectedAgeRange,
            "age": realAge,
            "isPolicy": isPolicy,
            "updateBy": _profile['username'],
            "question1": question1,
            "answers1": answers1,
            "question2": question2,
            "answers2": answers2,
          };
          postDio(server + 'm/enfranchise/createAI', data);
          // postDio(server + 'm/poll/reply/updateStatusAI',
          //     {'username': _profile['username']});

          postDio(server + 'm/policy/create', {
            "reference": "AI",
            "isActive": true,
          });
          chkPoll(futureModel: _futurePoll);
          _callRead();

          return true;
        }
      }
    } else {
      return false;
    }
  }

  chkStep1({required Future<dynamic> futureModel}) async {
    dynamic model = await futureModel;
    listAnswer = [];
    for (int i = 0; i < model['questions'].length; i++) {
      List<dynamic> data = model['questions'][i]['answers'];

      var answers = "";
      for (int idx = 0; idx < data.length; idx++) {
        if (data[idx]['value'] == true) {
          answers +=
              answers == "" ? data[idx]['title'] : ' , ' + data[idx]['title'];
        }
      }
      listAnswer.add({
        "question": model['questions'][i]['title'],
        "answers": answers,
      });
      if (model['questions'][i]['isRequired']) {
        // List<dynamic> data = model['questions'][i]['answers'];

        var checkValue = data.indexWhere(
          (item) => item['value'] == true && item['value'] != '',
        );

        if (checkValue == -1) {
          checkSendReply = false;
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return WillPopScope(
                onWillPop: () {
                  return Future.value(false);
                },
                child: CupertinoAlertDialog(
                  title: new Text(
                    'กรุณาตอบคำถาม',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Kanit',
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  content: Text(" "),
                  actions: [
                    CupertinoDialogAction(
                      isDefaultAction: true,
                      child: new Text(
                        "ตกลง",
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'Kanit',
                          color: Color(0xFFA9151D),
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            },
          );
          return false;
        } else {
          checkSendReply = true;
          return true;
        }
      } else {
        if (i == (model['questions'].length - 1)) {
          checkSendReply = true;
          return true;
        }
      }
    }
  }

  chkPoll({required Future<dynamic> futureModel}) async {
    dynamic model = await futureModel;
    String reference = model['code'];
    String title = '';

    if (checkSendReply) {
      var value = await storage.read(key: 'dataUserLoginOPEC') ?? "";
      var user = json.decode(value);
      model['questions']
          .map(
            (question) => {
              title = question['title'],
              reference = question['reference'],
              question['answers']
                  .map(
                    (answer) => {
                      if (answer['value'])
                        {
                          postObjectData('m/poll/reply/create', {
                            'reference': reference.toString(),
                            'username': user['username'].toString(),
                            'firstName': user['firstName'].toString(),
                            'lastName': user['lastName'].toString(),
                            'title': title.toString(),
                            'answer':
                                question['reference'] == 'text'
                                    ? answer['value'] == false
                                        ? ''
                                        : answer['value'].toString()
                                    : answer['title'].toString(),
                            'msgOther': (answer['msgOther'] ?? '').toString(),
                            'platform': Platform.operatingSystem.toString(),
                          }),
                        },
                    },
                  )
                  .toList(),
            },
          )
          .toList();
      return true;
    } else {
      return false;
    }
  }

  _contentStep1() {
    return Container(
      child: FutureBuilder<dynamic>(
        future: _futurePoll, // function where you call your api
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          // AsyncSnapshot<Your object type>
          dynamic questions = [];
          dynamic answers = [];
          if (snapshot.hasData) {
            questions = snapshot.data['questions'];
            answers = snapshot.data['answers'];
            return myCard(
              model: snapshot.data,
              questions: questions,
              answer: answers,
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }

  List<Step> getSteps() => [
    Step(
      state: currentStep > 0 ? StepState.complete : StepState.indexed,
      isActive: currentStep >= 0,
      title: Text("แบบทดสอบ"),
      content: _contentStep1(),
    ),
    Step(
      state: currentStep > 1 ? StepState.complete : StepState.indexed,
      isActive: currentStep >= 1,
      title: Text("ลงทะเบียน"),
      content: _contentStep2(),
    ),
    Step(
      state: currentStep > 2 ? StepState.complete : StepState.indexed,
      isActive: currentStep >= 2,
      title: Text("เสร็จสิ้น"),
      content: _contentStep3(),
    ),
  ];

  final txtFirstName = TextEditingController();
  final txtLastName = TextEditingController();
  final txtPhone = TextEditingController();
  final txtEmail = TextEditingController();
  final txtJob = TextEditingController();
  final List<dynamic> _itemAgeRange = [
    {'code': '25-35', 'title': '25-35', 'value': false},
    {'code': '36-40', 'title': '36-40', 'value': false},
    {'code': '41-45', 'title': '41-45', 'value': false},
    {'code': '46-50', 'title': '46-50', 'value': false},
  ];
  String _selectedAgeRange = '';

  _contentStep2() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          labelTextFormField('ชื่อ', mandatory: true),
          textFormField(txtFirstName, null, 'ชื่อ', 'ชื่อ', true, false, false),
          labelTextFormField('นามสกุล', mandatory: true),
          textFormField(
            txtLastName,
            null,
            'นามสกุล',
            'นามสกุล',
            true,
            false,
            false,
          ),
          // labelTextFormField('เบอร์โทรศัพท์', mandatory: true),
          labelTextFormField('* เบอร์โทรศัพท์ (10 หลัก)'),
          textFormPhoneField(
            txtPhone,
            'เบอร์โทรศัพท์ (10 หลัก)',
            'เบอร์โทรศัพท์ (10 หลัก)',
            true,
            false,
          ),
          labelTextFormField('ช่วงอายุ', mandatory: true),
          Column(
            children: [
              for (int index = 0; index < _itemAgeRange.length; index++)
                checkBoxSingle2(_itemAgeRange, index),
            ],
          ),
          CheckboxListTile(
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.symmetric(vertical: 0),
            value: isPolicy,
            title: Text(
              "ยินยอมให้บมจ. โตเกียวมารีนประกันชีวิต (ประเทศไทย) ติดต่อ นำเสนอข้อมูลข่าวสารโฆษณา รายการส่งเสริมการขาย โปรโมชั่น ส่วนลด สิทธิพิเศษกิจกรรมทางการตลาด และนำเสนอรวมทั้งพัฒนาสินค้าและการบริการของ กลุ่มโตเกียวมารีน คู่ค้า หรือพันธมิตรของบริษัทฯ ศึกษาแนวทางการประมวลผลข้อมูลส่วนบุคคลของบริษัทได้ที่นี้",
              style: TextStyle(fontFamily: 'Kanit'),
            ),
            onChanged:
                (value) => setState((() {
                  isPolicy = value ?? false;
                })),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 60),
            child: InkWell(
              onTap: () {
                launchURL(
                  'https://www.tokiomarine.com/th/th/life/privacy-policy.html',
                );
              },
              child: Text(
                'นโยบายความเป็นส่วนตัว',
                style: TextStyle(
                  fontSize: 13.00,
                  fontFamily: 'Kanit',
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0000FF),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  final txtnumber1 = TextEditingController();
  final txtnumber2 = TextEditingController();
  final txtnumber3 = TextEditingController();
  final txtnumber4 = TextEditingController();
  final txtnumber5 = TextEditingController();
  final txtnumber6 = TextEditingController();

  myCard({dynamic model, dynamic questions, dynamic answer}) {
    double height = MediaQuery.of(context).size.height / 1.5;
    return Container(
      alignment: Alignment.bottomCenter,
      color: Colors.white,
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: false,
              child: Stack(
                children: [
                  ListView(
                    children: [
                      Column(
                        children: [
                          Center(
                            child: Container(
                              // width: 170,
                              // height: 150,
                              child: Image.asset(
                                'assets/images/step1_ai.jpg',
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          SizedBox(height: 15),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children:
                                questions
                                    .map<Widget>(
                                      (item) => Column(
                                        children: [
                                          Container(
                                            alignment: Alignment.topLeft,
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 15.0,
                                            ),
                                            child: Text(
                                              item['isRequired']
                                                  ? '* ' + item['title']
                                                  : item['title'],
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: 'Kanit',
                                              ),
                                            ),
                                          ),
                                          Container(
                                            alignment: Alignment.topLeft,
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 15.0,
                                            ),
                                            child: Text(
                                              item['isRequired']
                                                  ? '(กรุณาเลือกคำตอบ)'
                                                  : '(ไม่จำเป็นต้องระบุ)',
                                              style: TextStyle(
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.w300,
                                                fontFamily: 'Kanit',
                                              ),
                                            ),
                                          ),
                                          // SizedBox(
                                          //   height: 15.0,
                                          // ),
                                          for (
                                            int i = 0;
                                            i < item['answers'].length;
                                            i++
                                          )
                                            item['category'] == 'multiple'
                                                ? checkBoxMultiple(
                                                  item['answers'],
                                                  i,
                                                )
                                                : checkBoxSingle(
                                                  item['answers'],
                                                  i,
                                                ),
                                          SizedBox(height: 10.0),
                                          item['title'] ==
                                                  'คุณมีพฤติกรรมเหล่านี้หรือไม่'
                                              ? Container(
                                                alignment: Alignment.centerLeft,
                                                margin: EdgeInsets.symmetric(
                                                  // vertical: 5.0,
                                                  horizontal: 10.0,
                                                ),
                                                child: Text(
                                                  'ถ้าใช่ คุณมีโอกาสป่วยเป็นโรคเกี่ยวกับหัวใจหรือมะเร็ง',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                ),
                                              )
                                              : Container(
                                                alignment: Alignment.centerLeft,
                                                margin: EdgeInsets.symmetric(
                                                  // vertical: 5.0,
                                                  horizontal: 10.0,
                                                ),
                                                child: Text(
                                                  'ถ้าใช่ คุณมีโอกาสป่วยเป็นโรคไตวายเรื้อรัง',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                ),
                                              ),
                                          SizedBox(height: 20.0),
                                        ],
                                      ),
                                    )
                                    .toList(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  textBoxOther(
    TextEditingController _textEditingController,
    dynamic item,
    int i,
    Key key,
  ) {
    return Container(
      padding: EdgeInsets.only(top: 15, left: 15, right: 15),
      child: TextField(
        key: key,
        //controller: _textEditingController,
        keyboardType: TextInputType.multiline,
        maxLines: 3,
        maxLength: 300,
        onChanged:
            (value) => setState(() {
              item[i]['msgOther'] = value;
            }),
        style: TextStyle(
          fontSize: 13,
          fontFamily: 'Kanit',
          fontWeight: FontWeight.w300,
        ),
        decoration: InputDecoration(
          fillColor: Colors.white,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.black.withAlpha(50),
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            gapPadding: 1,
          ),
          hintText: 'แสดงความคิดเห็น',
          contentPadding: const EdgeInsets.all(10.0),
        ),
      ),
    );
  }

  checkBoxSingle(dynamic answers, int i) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(
            // vertical: 5.0,
            horizontal: 5.0,
          ),
          // decoration: BoxDecoration(
          //   border: Border.all(color: Theme.of(context).primaryColorDark),
          //   borderRadius: BorderRadius.all(
          //     Radius.circular(5.0),
          //   ),
          //   color: Colors.white,
          // ),
          child: CheckboxListTile(
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(
              answers[i]['title'],
              style: TextStyle(
                fontSize: 14.0,
                fontFamily: 'Kanit',
                fontWeight: FontWeight.w300,
              ),
            ),
            value: answers[i]['value'],
            onChanged: (bool? value) {
              setState(() {
                _selectedIndex = i;
                for (int j = 0; j < answers.length; j++) {
                  if (j == _selectedIndex) {
                    answers[j]['value'] = !answers[j]['value'];
                  } else {
                    answers[j]['value'] = false;
                  }
                }
              });
            },
            activeColor: Theme.of(context).primaryColorDark,
            checkColor: Colors.white,
          ),
        ),
        answers[i]['value'] && answers[i]['isOther']
            ? textBoxOther(
              _textEditingController,
              answers,
              i,
              Key(i.toString()),
            )
            : Container(),
      ],
    );
  }

  checkBoxSingle2(dynamic answers, int i) {
    return Column(
      children: [
        Container(
          child: CheckboxListTile(
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.symmetric(vertical: 0),
            title: Text(
              answers[i]['title'] + ' ปี',
              style: TextStyle(
                fontSize: 14.0,
                fontFamily: 'Kanit',
                fontWeight: FontWeight.w500,
              ),
            ),
            value: answers[i]['value'],
            onChanged: (bool? value) {
              setState(() {
                _selectedIndex = i;
                for (int j = 0; j < answers.length; j++) {
                  if (j == _selectedIndex) {
                    answers[j]['value'] = !answers[j]['value'];
                    _selectedAgeRange = answers[j]['code'];
                  } else {
                    answers[j]['value'] = false;
                  }
                }
              });
            },
            activeColor: Theme.of(context).primaryColorDark,
            checkColor: Colors.white,
          ),
        ),
      ],
    );
  }

  checkBoxMultiple(dynamic answers, int i) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(
            // vertical: 5.0,
            horizontal: 5.0,
          ),
          // decoration: BoxDecoration(
          //   border: Border.all(color: Theme.of(context).primaryColorDark),
          //   borderRadius: BorderRadius.all(
          //     Radius.circular(5.0),
          //   ),
          //   color: Colors.white,
          // ),
          child: CheckboxListTile(
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(
              answers[i]['title'],
              style: TextStyle(
                fontSize: 14.0,
                fontFamily: 'Kanit',
                fontWeight: FontWeight.w300,
              ),
            ),
            value: answers[i]['value'],
            onChanged: (bool? value) {
              setState(() {
                answers[i]['value'] = !answers[i]['value'];
                answers[i]['msgOther'] = '';
                _textEditingController.text = '';
              });
            },
            activeColor: Theme.of(context).primaryColorDark,
            checkColor: Colors.white,
          ),
        ),
        answers[i]['value'] && answers[i]['isOther']
            ? textBoxOther(
              _textEditingController,
              answers,
              i,
              Key(i.toString()),
            )
            : Container(),
      ],
    );
  }

  _contentStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Center(
        //   child: Container(
        //     child: Image.asset(
        //       'assets/images/step3.jpg',
        //       fit: BoxFit.fill,
        //     ),
        //   ),
        // ),
        // SizedBox(height: 20),
        Container(
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
          child: Text(
            'ขอบคุณที่ร่วมทำแบบสอบถาม',
            style: TextStyle(
              fontSize: 20.00,
              fontFamily: 'Kanit',
              fontWeight: FontWeight.w500,
              color: Color(0xFF408C40),
            ),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
          child: Text(
            'รอลุ้นรับรางวัล',
            style: TextStyle(
              fontSize: 17.00,
              fontFamily: 'Kanit',
              fontWeight: FontWeight.w500,
              color: Color(0xFF408C40),
            ),
          ),
        ),
        SizedBox(height: 20),
        Center(
          child: Container(
            child: Image.asset('assets/images/step3_1.png', fit: BoxFit.fill),
          ),
        ),
        SizedBox(height: 10),

        Center(
          child: Container(
            child: Image.asset('assets/images/step3_2.png', fit: BoxFit.fill),
          ),
        ),
        SizedBox(height: 10),

        Center(
          child: Container(
            child: Image.asset('assets/images/step3_3.png', fit: BoxFit.fill),
          ),
        ),
        SizedBox(height: 10),

        // Center(
        //   child: Container(
        //     child: Image.asset(
        //       'assets/images/step1_ai.jpg',
        //       fit: BoxFit.fill,
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
