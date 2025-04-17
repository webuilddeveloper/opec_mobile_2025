import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:opec/pages/main_popup/checkPermission_main.dart';
import 'package:opec/pages/main_popup/mainpop_up_form.dart';
import 'package:opec/policy.dart';
import 'package:opec/widget/button.dart';
import 'package:opec/widget/carousel.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:opec/pages/enfranchise/enfrancise_main.dart';
import 'package:opec/shared/api_provider.dart';

import '../enfranchise/enfrancise_main_ai.dart';

class MainPopupDialog extends StatefulWidget {
  MainPopupDialog({
    Key? key,
    required this.model,
    this.url = '',
    this.urlGallery = '',
    required this.type,
    required this.username,
  }) : super(key: key);

  final Future<dynamic> model;
  final String urlGallery;
  final String url;
  final String type;
  final String username;

  @override
  _MainPopupDialogState createState() => new _MainPopupDialogState();
}

class _MainPopupDialogState extends State<MainPopupDialog> {
  final storage = new FlutterSecureStorage();

  bool notShowOnDay = false;

  void setHiddenMainPopup() async {
    this.setState(() {
      notShowOnDay = !notShowOnDay;
    });

    var value = await storage.read(key: widget.type + 'OPEC');
    var dataValue;
    if (value != null) {
      dataValue = json.decode(value);
    } else {
      dataValue = null;
    }

    var now = new DateTime.now();
    DateTime date = new DateTime(now.year, now.month, now.day);

    if (dataValue != null) {
      var index = dataValue.indexWhere((c) => c['username'] == widget.username);

      if (index == -1) {
        dataValue.add({
          'boolean': notShowOnDay.toString(),
          'username': widget.username,
          'date': DateFormat("ddMMyyyy").format(date).toString(),
        });

        await storage.write(
          key: widget.type + 'OPEC',
          value: jsonEncode(dataValue),
        );
      } else {
        dataValue[index]['boolean'] = notShowOnDay.toString();
        // dataValue[index]['boolean'] = dataValue[index]['boolean'] == "true"
        //     ? "true"
        //     : notShowOnDay.toString();
        dataValue[index]['username'] = widget.username;
        dataValue[index]['date'] =
            DateFormat("ddMMyyyy").format(date).toString();

        await storage.write(
          key: widget.type + 'OPEC',
          value: jsonEncode(dataValue),
        );
      }
    } else {
      var itemData = [
        {
          'boolean': notShowOnDay.toString(),
          'username': widget.username,
          'date': DateFormat("ddMMyyyy").format(date).toString(),
        },
      ];

      await storage.write(
        key: widget.type + 'OPEC',
        value: jsonEncode(itemData),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0)),
        height: MediaQuery.of(context).size.height * 0.8,
        width: width,
        child: Column(
          children: [
            Container(
              alignment: Alignment.topRight,
              child: Container(child: buttonCloseBack(context)),
            ),
            MainPopup(
              model: widget.model,
              nav: (
                String path,
                String action,
                dynamic model,
                String code,
                String urlGallery,
              ) {
                postTrackClick("ป้ายโฆษณา");
                if (action == 'out') {
                  // launch(path);
                  postDio('${server}m/Rotation/innserlog', model);
                  launch(path);
                } else if (action == 'in') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => CarouselForm(
                            code: code,
                            model: model,
                            url: widget.url,
                            urlGallery: widget.urlGallery,
                          ),
                    ),
                  );
                } else if (action.toUpperCase() == 'P') {
                  postDio('${server}m/Rotation/innserlog', model);
                  _callReadPolicyPrivilegeAtoZ(code);
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => EnfranchiseMain(reference: code),
                  //   ),
                  // );
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => TelemedicineMain(reference: code),
                  //   ),
                  // );
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
                  // postDio('${server}m/Rotation/innserlog', model);
                  _callReadPolicyPrivilegeAI('AI');
                }
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.only(left: 5.0, top: 10.0, bottom: 10.0),
                  alignment: Alignment.topLeft,
                  child: InkWell(
                    onTap: () => {setHiddenMainPopup()},
                    child: new Icon(
                      !notShowOnDay
                          ? Icons.check_box_outline_blank
                          : Icons.check_box,
                      color: Colors.lightGreenAccent,
                      size: 40.0,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(left: 10.0, top: 10.0, bottom: 10.0),
                  child: InkWell(
                    onTap: () => {setHiddenMainPopup()},
                    child: Text(
                      'ไม่ต้องแสดงเนื้อหาอีกภายในวันนี้',
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'Kanit',
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<Null> _callReadPolicyPrivilegeAtoZ(code) async {
    var policy = await postDio(server + "m/policy/readAtoZ", {
      "reference": "AtoZ",
    });
    if (policy.length <= 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          // ignore: missing_required_param
          // builder: (context) => PolicyIdentityVerificationPage(),
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
    // var policy =
    //     await postDio(server + "m/policy/readAtoZ", {"reference": "AI"});
    // if (policy.length <= 0) {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       // ignore: missing_required_param
    //       // builder: (context) => PolicyIdentityVerificationPage(),
    //       builder: (context) => PolicyV2Page(
    //         category: 'AI',
    //         navTo: () {
    //           Navigator.pop(context);
    //           Navigator.pushReplacement(
    //             context,
    //             MaterialPageRoute(
    //               builder: (context) => EnfranchiseMainAi(
    //                 reference: code,
    //               ),
    //             ),
    //           );
    //         },
    //       ),
    //     ),
    //   );
    // } else {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) => EnfranchiseMainAi(
    //         reference: code,
    //       ),
    //     ),
    //   );
    // }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnfranchiseMainAi(reference: code),
      ),
    );
  }
}
