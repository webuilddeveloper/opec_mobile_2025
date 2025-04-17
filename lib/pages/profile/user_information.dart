import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:opec/pages/auth/login.dart';
import 'package:opec/pages/enfranchise/enfrancise_list.dart';
import 'package:opec/pages/fileOnline/fileOnline_list.dart';
import 'package:opec/pages/fund/fundProvident.dart';
import 'package:opec/pages/fund/fundRegisterProvident.dart';
import 'package:opec/pages/fund/fundSavingsReport.dart';
import 'package:opec/pages/profile/identity_verification.dart';
import 'package:opec/pages/profile/organization.dart';
import 'package:opec/pages/profile/pro_file_policy.dart';
import 'package:opec/pages/profile/setting_notification.dart';
import 'package:opec/pages/school/school_index.dart';
import 'package:opec/pages/teacher/teacher_index.dart';
import 'package:opec/shared/api_provider.dart';
import 'package:opec/user.dart';
import 'package:opec/widget/dialog.dart';
import 'package:opec/widget/header.dart';
import 'change_password.dart';
import 'edit_user_information.dart';

class UserInformationPage extends StatefulWidget {
  UserInformationPage({Key? key, required this.userData}) : super(key: key);
  final User userData;
  @override
  _UserInformationPageState createState() => _UserInformationPageState();
}

class _UserInformationPageState extends State<UserInformationPage> {
  final storage = FlutterSecureStorage();
  String _imageUrl = '';
  String _category = '';

  final txtUsername = TextEditingController();
  final txtPassword = TextEditingController();
  final txtConPassword = TextEditingController();
  final txtFirstName = TextEditingController();
  final txtLastName = TextEditingController();

  Future<dynamic> futureModel = Future.value(null);
  ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    txtUsername.dispose();
    txtPassword.dispose();
    txtConPassword.dispose();
    txtFirstName.dispose();
    txtLastName.dispose();
    super.dispose();
  }

  @override
  void initState() {
    readStorage();
    super.initState();
  }

  void goBack() async {
    Navigator.pop(context, false);
  }

  void logout() async {
    var category = await storage.read(key: 'profileCategory');

    final GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: <String>[
        'email',
        'https://www.googleapis.com/auth/contacts.readonly',
      ],
    );

    if (category == 'google') {
      _googleSignIn.signOut();
    } else if (category == 'facebook') {
      // await facebookSignIn.logOut();
    }

    // delete
    await storage.deleteAll();

    storage.write(key: tutorial, value: "S");

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  readStorage() async {
    var value = await storage.read(key: 'dataUserLoginOPEC') ?? "";
    var user = json.decode(value);
    if (user['code'] != '') {
      setState(() {
        _imageUrl = user['imageUrl'] ?? '';
        _category = user['category'] ?? '';
      });
    }
  }

  // Future<Null> _callReadPolicyFund(String title, Function callBack) async {
  //   var policy = await postDio(server + "m/policy/read", {
  //     "category": "marketing",
  //   });

  //   postDio('${server}m/v2/register/checkOrganizationActive', {}).then((value) {
  //     if (value) {
  //       dialogBtn(
  //         context,
  //         title: 'แจ้งเตือนจากระบบ',
  //         description: 'กรุณากรอกข้อมูลสมาชิกหรืออยู่ระหว่างตรวจสอบข้อมูล',
  //         btnOk: "กรอกข้อมูลสมาชิก",
  //         isYesNo: true,
  //         callBack: (param) {
  //           if (param) {
  //             Navigator.push(
  //               context,
  //               MaterialPageRoute(
  //                 builder: (context) => IdentityVerificationPage(),
  //               ),
  //             );
  //           }
  //         },
  //       );
  //     } else {
  //       if (policy.length > 0) {
  //         dialogBtn(
  //           context,
  //           title: 'แจ้งเตือนจากระบบ',
  //           description: 'ท่านยังไม่ได้ยอมรับเงื่อนไข',
  //           btnOk: "ยอมรับเงื่อนไข",
  //           isYesNo: true,
  //           callBack: (param) {
  //             if (param) {
  //               Navigator.push(
  //                 context,
  //                 MaterialPageRoute(
  //                   // ignore: missing_required_param
  //                   // builder: (context) => PolicyIdentityVerificationPage(),
  //                   builder:
  //                       (context) => PolicyPage(
  //                         category: 'marketing',
  //                         navTo: () {
  //                           Navigator.pop(context);
  //                           callBack(true);
  //                         },
  //                       ),
  //                 ),
  //               );
  //             }
  //           },
  //         );
  //       } else {
  //         callBack(false);
  //       }
  //     }
  //   });
  // }

  card() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 5,
      child: Padding(padding: EdgeInsets.all(15), child: contentCard()),
    );
  }

  contentCard() {
    return ListView(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      padding: const EdgeInsets.all(10.0),
      // padding: EdgeInsets.only(top: 65.0),
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _headerIconV2(
                  'ยอดสะสมกองทุน',
                  'assets/images/logo_fund.png',
                  (widget.userData.checkOrganization != null
                      ? widget.userData.checkOrganization ?? false
                          ? true
                          : false
                      : false),
                  () {
                    postTrackClick('โปรไฟล์/ยอดสะสมกองทุน');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => FundSavingsReport(
                              title: 'ยอดสะสมกองทุน',
                              userData: widget.userData,
                            ),
                      ),
                    );
                    // _callReadPolicyFund(
                    //   'ยอดสะสมกองทุน',
                    //   (isPush) {
                    //     !isPush
                    //         ? Navigator.push(
                    //             context,
                    //             MaterialPageRoute(
                    //               builder: (context) => FundSavingsReport(
                    //                 title: 'ยอดสะสมกองทุน',
                    //                 userData: widget.userData,
                    //               ),
                    //             ),
                    //           )
                    //         : Navigator.pushReplacement(
                    //             context,
                    //             MaterialPageRoute(
                    //               builder: (context) => FundSavingsReport(
                    //                 title: 'ยอดสะสมกองทุน',
                    //                 userData: widget.userData,
                    //               ),
                    //             ),
                    //           );
                    //   },
                    // );
                  },
                ),
                _headerIconV2(
                  'ข้อมูลการกู้เงิน',
                  'assets/logo/icons/fund_loaninformation.png',
                  (widget.userData.checkOrganization != null
                      ? widget.userData.checkOrganization ?? false
                          ? true
                          : false
                      : false),
                  () {
                    postTrackClick('โปรไฟล์/ข้อมูลการกู้เงิน');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => FundProvident(
                              title: 'ข้อมูลการกู้เงิน',
                              userData: widget.userData,
                              imageUrl:
                                  'assets/logo/icons/fund_loaninformation.png',
                            ),
                      ),
                    );
                    // _callReadPolicyFund('ข้อมูลการกู้เงิน', (isPush) {
                    //   !isPush
                    //       ? Navigator.push(
                    //           context,
                    //           MaterialPageRoute(
                    //             builder: (context) => FundProvident(
                    //               title: 'ข้อมูลการกู้เงิน',
                    //               userData: widget.userData,
                    //               imageUrl:
                    //                   'assets/logo/icons/fund_loaninformation.png',
                    //             ),
                    //           ),
                    //         )
                    //       : Navigator.pushReplacement(
                    //           context,
                    //           MaterialPageRoute(
                    //             builder: (context) => FundProvident(
                    //               title: 'ข้อมูลการกู้เงิน',
                    //               userData: widget.userData,
                    //               imageUrl:
                    //                   'assets/logo/icons/fund_loaninformation.png',
                    //             ),
                    //           ),
                    //         );
                    // });
                  },
                ),
                _headerIconV2(
                  'ตรวจสอบ ข้อมูลครู',
                  'assets/logo/icons/icon_teacher.png',
                  true,
                  () {
                    postTrackClick('โปรไฟล์/ตรวจสอบ ข้อมูลครู');
                    // Call function
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BuildTeacherIndex(),
                      ),
                    );
                  },
                ),
                _headerIconV2(
                  'ตรวจสอบ โรงเรียนเอกชน',
                  'assets/logo/icons/icon_school.png',
                  true,
                  () {
                    postTrackClick('โปรไฟล์/ตรวจสอบ โรงเรียนเอกชน');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BuildSchoolIndex(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),

        //เกี่ยวกับคุณ
        Container(
          height: 40,
          child: Text(
            'เกี่ยวกับคุณ',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0XFF9A1120),
            ),
          ),
        ),

        ButtonTheme(
          child: TextButton(
            style: TextButton.styleFrom(padding: EdgeInsets.all(0.0)),
            child: rowContentButton(
              "assets/logo/icons/fund_fileOnline.png",
              "ยื่นเรื่องออนไลน์",
            ),
            onPressed:
                () => {
                  postTrackClick('โปรไฟล์/ยื่นเรื่องออนไลน์'),
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => FileOnlineList(
                            title: 'ยื่นเรื่องออนไลน์',
                            code: '',
                          ),
                    ),
                  ),
                },
          ),
        ),
        // _menu(
        //     'assets/logo/icons/fund_fileOnline.png', 'ยื่นเรื่องออนไลน์', true,
        //     () {
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (context) => FileOnlineList(
        //         title: 'ยื่นเรื่องออนไลน์',
        //       ),
        //     ),
        //   );
        // }),
        (widget.userData.checkOrganization != null
                ? widget.userData.checkOrganization ?? false
                    ? true
                    : false
                : false)
            ? ButtonTheme(
              child: TextButton(
                style: TextButton.styleFrom(padding: EdgeInsets.all(0.0)),
                child: rowContentButton(
                  "assets/logo/icons/fund_loaninformation.png",
                  "ข้อมูลการกู้เงิน",
                ),
                onPressed:
                    () => {
                      postTrackClick('โปรไฟล์/ข้อมูลการกู้เงิน'),
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => FundProvident(
                                title: 'ข้อมูลการกู้เงิน',
                                userData: widget.userData,
                                imageUrl:
                                    'assets/logo/icons/fund_loaninformation.png',
                              ),
                        ),
                      ),
                    },
              ),
            )
            : Container(),
        // _callReadPolicyFund('ข้อมูลการกู้เงิน', (isPush) {
        //   !isPush
        //       ? Navigator.push(
        //           context,
        //           MaterialPageRoute(
        //             builder: (context) => FundProvident(
        //               title: 'ข้อมูลการกู้เงิน',
        //               userData: widget.userData,
        //               imageUrl: 'assets/logo/icons/fund_loaninformation.png',
        //             ),
        //           ),
        //         )
        //       : Navigator.pushReplacement(
        //           context,
        //           MaterialPageRoute(
        //             builder: (context) => FundProvident(
        //               title: 'ข้อมูลการกู้เงิน',
        //               userData: widget.userData,
        //               imageUrl: 'assets/logo/icons/fund_loaninformation.png',
        //             ),
        //           ),
        //         );
        // });
        (widget.userData.checkOrganization != null
                ? widget.userData.checkOrganization ?? false
                    ? true
                    : false
                : false)
            ? ButtonTheme(
              child: TextButton(
                style: TextButton.styleFrom(padding: EdgeInsets.all(0.0)),
                child: rowContentButton(
                  "assets/logo/icons/fund_fundremittanceamount.png",
                  "ยอดสะสมกองทุน",
                ),
                onPressed:
                    () => {
                      postTrackClick('โปรไฟล์/ยอดสะสมกองทุน'),
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => FundSavingsReport(
                                title: 'ยอดสะสมกองทุน',
                                userData: widget.userData,
                              ),
                        ),
                      ),
                    },
              ),
            )
            : Container(),
        // onPressed: () => _callReadPolicyFund(
        //   'ยอดสะสมกองทุน',
        //   (isPush) {
        //     !isPush
        //         ? Navigator.push(
        //             context,
        //             MaterialPageRoute(
        //               builder: (context) => FundSavingsReport(
        //                 title: 'ยอดสะสมกองทุน',
        //                 userData: widget.userData,
        //               ),
        //             ),
        //           )
        //         : Navigator.pushReplacement(
        //             context,
        //             MaterialPageRoute(
        //               builder: (context) => FundSavingsReport(
        //                 title: 'ยอดสะสมกองทุน',
        //                 userData: widget.userData,
        //               ),
        //             ),
        //           );
        //   },
        // ),
        // _menu(
        //     'assets/logo/icons/fund_fundremittanceamount.png',
        //     'ยอดสะสมกองทุน',
        //     (widget.userData.checkOrganization != null
        //         ? widget.userData.checkOrganization
        //             ? true
        //             : false
        //         : false), () {
        //   // _callReadPolicyFund(
        //   //   'ยอดสะสมกองทุน',
        //   //   (isPush) {
        //   //     !isPush
        //   //         ? Navigator.push(
        //   //             context,
        //   //             MaterialPageRoute(
        //   //               builder: (context) => FundSavingsReport(
        //   //                 title: 'ยอดสะสมกองทุน',
        //   //                 userData: widget.userData,
        //   //               ),
        //   //             ),
        //   //           )
        //   //         : Navigator.pushReplacement(
        //   //             context,
        //   //             MaterialPageRoute(
        //   //               builder: (context) => FundSavingsReport(
        //   //                 title: 'ยอดสะสมกองทุน',
        //   //                 userData: widget.userData,
        //   //               ),
        //   //             ),
        //   //           );
        //   //   },
        //   // );
        // }),
        _menu(
          'assets/logo/icons/fund_medicaltreatmentrights.png',
          'สิทธิรักษาพยาบาล',
          (widget.userData.checkOrganization != null
              ? widget.userData.checkOrganization ?? false
                  ? true
                  : false
              : false),
          () {
            // _callReadPolicyFund('สิทธิรักษาพยาบาล', (isPush) {
            //   !isPush
            //       ? Navigator.push(
            //           context,
            //           MaterialPageRoute(
            //             builder: (context) => FundMedicalTreatment(
            //               title: 'สิทธิรักษาพยาบาล',
            //               userData: widget.userData,
            //               imageUrl:
            //                   'assets/logo/icons/fund_medicaltreatmentrights.png',
            //             ),
            //           ),
            //         )
            //       : Navigator.pushReplacement(
            //           context,
            //           MaterialPageRoute(
            //             builder: (context) => FundMedicalTreatment(
            //               title: 'สิทธิรักษาพยาบาล',
            //               userData: widget.userData,
            //               imageUrl:
            //                   'assets/logo/icons/fund_medicaltreatmentrights.png',
            //             ),
            //           ),
            //         );
            // });
          },
        ),
        (widget.userData.checkOrganization != null
                ? widget.userData.checkOrganization ?? false
                    ? true
                    : false
                : false)
            ? ButtonTheme(
              child: TextButton(
                style: TextButton.styleFrom(padding: EdgeInsets.all(0.0)),
                child: rowContentButton(
                  "assets/logo/icons/fund_welfare.png",
                  "กองทุนสงเคราะห์",
                ),
                onPressed:
                    () => {
                      postTrackClick('โปรไฟล์/กองทุนสงเคราะห์'),
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => FundRegisterProvident(
                                title: 'กองทุนสงเคราะห์',
                                userData: widget.userData,
                              ),
                        ),
                      ),
                    },
              ),
            )
            : Container(),

        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => FundRegisterProvident(
        //       title: 'กองทุนสงเคราะห์',
        //       userData: widget.userData,
        //     ),
        //   ),
        // );
        // }),
        //
        Container(
          padding: EdgeInsets.only(top: 10),
          height: 40,
          child: Text(
            'ตั้งค่าผู้ใช้',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0XFF9A1120),
            ),
          ),
        ),
        ButtonTheme(
          child: TextButton(
            style: TextButton.styleFrom(padding: EdgeInsets.all(0.0)),
            child: rowContentButton(
              "assets/logo/icons/Group105.png",
              "ข้อมูลผู้ใช้งาน",
            ),
            onPressed:
                () => {
                  postTrackClick('โปรไฟล์/ข้อมูลผู้ใช้งาน'),
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditUserInformationPage(),
                    ),
                  ).then((value) => readStorage()),
                },
          ),
        ),
        ButtonTheme(
          child: TextButton(
            style: TextButton.styleFrom(padding: EdgeInsets.all(0.0)),
            child: rowContentButton(
              "assets/logo/icons/2985813.png",
              "ข้อมูลสมาชิก",
            ),
            onPressed:
                () => {
                  postTrackClick('โปรไฟล์/ข้อมูลสมาชิก'),
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IdentityVerificationPage(),
                    ),
                  ).then((value) => readStorage()),
                },
          ),
        ),
        ButtonTheme(
          child: TextButton(
            style: TextButton.styleFrom(padding: EdgeInsets.all(0.0)),
            child: rowContentButton(
              "assets/icon_user_information_organization.png",
              "ประเภทสมาชิก",
            ),
            onPressed:
                () => {
                  postTrackClick('โปรไฟล์/ข้อมูลสมาชิก'),
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => OrganizationPage()),
                  ).then(
                    (value) => {}, //readStorage(),
                  ),
                },
          ),
        ),
        Container(
          padding: EdgeInsets.only(top: 10),
          height: 40,
          child: Text(
            'ตั้งค่าอื่นๆ',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0XFF9A1120),
            ),
          ),
        ),
        ButtonTheme(
          child: TextButton(
            style: TextButton.styleFrom(padding: EdgeInsets.all(0.0)),
            child: rowContentButton(
              "assets/logo/icons/Group103.png",
              "ตั้งค่าการแจ้งเตือน",
            ),
            onPressed:
                () => {
                  postTrackClick('โปรไฟล์/ตั้งค่าการแจ้งเตือน'),
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingNotificationPage(),
                    ),
                  ).then((value) => readStorage()),
                },
          ),
        ),
        // ButtonTheme(
        //   child: FlatButton(
        //     padding: EdgeInsets.all(0.0),
        //     child: rowContentButton(
        //       "assets/logo/icons/noun_Globe.png",
        //       "เปลี่ยนภาษา",
        //     ),
        //     // onPressed: () => Navigator.push(
        //     //   context,
        //     //   MaterialPageRoute(
        //     //     builder: (context) => ConnectSSOPage(goHome: false),
        //     //   ),
        //     // ).then(
        //     //   (value) => readStorage(),
        //     // ),
        //   ),
        // ),
        // ButtonTheme(
        //   child: FlatButton(
        //     padding: EdgeInsets.all(0.0),
        //     child: rowContentButton(
        //       "assets/logo/icons/Group109.png",
        //       "การเชื่อมต่อ",
        //     ),
        //     onPressed: () => Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //         builder: (context) => ConnectSocialPage(),
        //       ),
        //     ).then(
        //       (value) => readStorage(),
        //     ),
        //   ),
        // ),
        _category == 'guest'
            ? ButtonTheme(
              child: TextButton(
                style: TextButton.styleFrom(padding: EdgeInsets.all(0.0)),
                child: rowContentButton(
                  "assets/logo/icons/Group221.png",
                  "เปลี่ยนรหัสผ่าน",
                ),
                onPressed:
                    () => {
                      postTrackClick('โปรไฟล์/เปลี่ยนรหัสผ่าน'),
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangePasswordPage(),
                        ),
                      ).then((value) => readStorage()),
                    },
              ),
            )
            : Container(),
        ButtonTheme(
          child: TextButton(
            style: TextButton.styleFrom(padding: EdgeInsets.all(0.0)),
            child: rowContentButton("assets/logo/icons/2985813.png", "นโยบาย"),
            onPressed:
                () => {
                  postTrackClick('โปรไฟล์/นโยบาย'),
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // ignore: missing_required_param
                      builder: (context) => ProFilePolicyPage(),
                    ),
                  ).then(
                    (value) => {}, //readStorage(),
                  ),
                },
          ),
        ),
        ButtonTheme(
          child: TextButton(
            style: TextButton.styleFrom(padding: EdgeInsets.all(0.0)),
            child: rowContentButton(
              "assets/logo/icons/2985813.png",
              "สิทธิ์ที่เคยได้รับ",
            ),
            onPressed:
                () => {
                  postTrackClick('โปรไฟล์/สิทธิ์ที่เคยได้รับ'),
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // ignore: missing_required_param
                      builder: (context) => EnfranciseListPage(),
                    ),
                  ).then(
                    (value) => {}, //readStorage(),
                  ),
                },
          ),
        ),
        Padding(padding: EdgeInsets.only(top: 10.0)),
      ],
    );
  }

  rowContentButton(String urlImage, String title) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Color(0XFFFFFFFF),
      ),
      // alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            // width: MediaQuery.of(context).size.width * 0.80,
            padding: EdgeInsets.only(left: 10.0, right: 10.0),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13.0,
                color: Color(0xFF6F0100),
                fontWeight: FontWeight.normal,
                fontFamily: 'Kanit',
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 5, top: 5, bottom: 5, right: 10),
            alignment: Alignment.centerRight,
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Color(0XFFF5D896),
              ),
              child: Image.asset("assets/logo/icons/right.png"),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: headerV3(
        context,
        goBack,
        title: 'ข้อมูลผู้ใช้งาน',
        rightButton: () {},
      ),
      backgroundColor: Color(0xFFF7F7F7),
      body: FutureBuilder<dynamic>(
        future: futureModel,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasError) {
            return dialogFail(context);
          } else {
            return Container(
              child: ListView(
                controller: scrollController,
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                // padding: const EdgeInsets.all(10.0),
                children: <Widget>[
                  Column(
                    // alignment: Alignment.topCenter,
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          Center(
                            child: Container(
                              padding: EdgeInsets.all(
                                _imageUrl != '' ? 0.0 : 5.0,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                color: Colors.white70,
                              ),
                              height: 100,
                              width: 100,
                              // margin: EdgeInsets.only(top: 30.0),
                              child:
                                  _imageUrl != ''
                                      ? CircleAvatar(
                                        backgroundColor: Colors.black,
                                        backgroundImage:
                                            _imageUrl != ''
                                                ? NetworkImage(_imageUrl)
                                                : null,
                                      )
                                      : Container(
                                        padding: EdgeInsets.all(10.0),
                                        child: Image.asset(
                                          'assets/images/user_not_found.png',
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.secondary,
                                        ),
                                      ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 5),
                        child: Center(
                          child: Text(
                            '${widget.userData.firstName} ${widget.userData.lastName}',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Kanit',
                            ),
                          ),
                        ),
                      ),

                      widget.userData.checkOrganization != null
                          ? widget.userData.checkOrganization ?? false
                              ? Padding(
                                padding: EdgeInsets.only(bottom: 10),
                                child: Center(
                                  child: Text(
                                    'สมาชิกการศึกษาเอกชน',
                                    style: TextStyle(
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Kanit',
                                    ),
                                  ),
                                ),
                              )
                              : Container()
                          : Container(),
                      Container(color: Color(0XFFF7F7F7), child: contentCard()),
                      Container(
                        margin: EdgeInsets.only(top: 10.0),
                        color: Color(0XFFF7F7F7),
                        child: ButtonTheme(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.all(0.0),
                            ),
                            onPressed:
                                () => {postTrackClick("ออกจากระบบ"), logout()},
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.power_settings_new,
                                  color: Colors.red,
                                ),
                                Text(
                                  " ออกจากระบบ",
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color: Color(0xFFFC4137),
                                    fontWeight: FontWeight.normal,
                                    fontFamily: 'Kanit',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.only(right: 5),
                        child: Text(
                          versionName,
                          style: TextStyle(
                            // fontSize: 9.0,
                            color: Color(0xFF6F0100),
                            fontWeight: FontWeight.normal,
                            fontFamily: 'Kanit',
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      // Container(
                      //   width: MediaQuery.of(context).size.width,
                      //   padding: EdgeInsets.only(right: 5),
                      //   child: Text(
                      //     '1.1.10+1',
                      //     style: new TextStyle(
                      //       fontSize: 9.0,
                      //       color: Color(0xFF6F0100),
                      //       fontWeight: FontWeight.normal,
                      //       fontFamily: 'Kanit',
                      //     ),
                      //     textAlign: TextAlign.right,
                      //   ),
                      // ),
                    ],
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  _headerIconV2(title, imageUrl, isShow, Function callBack) {
    if (isShow) {
      return Expanded(
        flex: 1,
        child: InkWell(
          onTap: () {
            callBack();
          },
          child: Container(
            height: 100,
            color: Colors.transparent,
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(5),
                  child: Container(
                    alignment: Alignment.topCenter,
                    padding: EdgeInsets.all(0.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      color: Color(0XFFEEBA33),
                    ),
                    height: 50,
                    width: 50,
                    child: GestureDetector(
                      onTap: () => callBack(),
                      child: Container(
                        padding: EdgeInsets.all(10.0),
                        child: Image.asset(
                          imageUrl,
                          fit: BoxFit.fill,
                          //color: Theme.of(context).primaryColorLight,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12.00,
                      fontFamily: 'Kanit',
                      color: Theme.of(context).primaryColorDark,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  _menu(imageUrl, title, isShow, Function callBack) {
    if (isShow) {
      return ButtonTheme(
        child: TextButton(
          style: TextButton.styleFrom(padding: EdgeInsets.all(0.0)),
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Color(0XFFFFFFFF),
            ),
            // alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  alignment: Alignment.centerLeft,
                  // width: MediaQuery.of(context).size.width * 0.80,
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.0,
                      color: Color(0xFF707070),
                      fontWeight: FontWeight.normal,
                      fontFamily: 'Kanit',
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(
                    left: 5,
                    top: 5,
                    bottom: 5,
                    right: 10,
                  ),
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Color(0XFF707070),
                    ),
                    child: Image.asset(
                      "assets/logo/icons/right.png",
                      color: Color(0XFF000000),
                    ),
                  ),
                ),
              ],
            ),
          ),
          onPressed: () => callBack(),
        ),
      );
    } else {
      return Container();
    }
  }
}
