import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ticket/flutter_ticket.dart';
import 'package:intl/intl.dart';
import 'package:opec/menu.dart';

import 'package:opec/shared/api_provider.dart';
import 'package:opec/widget/dialog.dart';
import 'package:opec/widget/header.dart';
import 'dart:io' show Platform;
import 'package:url_launcher/url_launcher.dart';

class EnfrancisePage extends StatefulWidget {
  EnfrancisePage({Key? key, required this.reference}) : super(key: key);

  final String reference;
  @override
  _EnfrancisePageState createState() => _EnfrancisePageState();
}

class _EnfrancisePageState extends State<EnfrancisePage> {
  Future<dynamic> futureModel = Future.value(null);
  ScrollController scrollController = ScrollController();
  String selectedType = '1';
  String linkUrl = "https://deeplink.doctoratoz.co/?m=dev&a=daz&c=facebook";
  @override
  void initState() {
    _callRead();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildEnfrancise();
  }

  _callRead() {
    futureModel = postDio('${server}m/enfranchise/readAccept', {
      "reference": widget.reference,
    });
  }

  void goBack() async {
    Navigator.pop(context, false);
  }

  _buildEnfrancise() {
    return Scaffold(
      appBar: header(context, goBack, title: 'สิทธิ์ที่เคยได้รับ'),
      backgroundColor: Colors.white,
      body: FutureBuilder<dynamic>(
        future: futureModel,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              child: SingleChildScrollView(
                controller: scrollController,
                physics: ClampingScrollPhysics(),
                // padding: const EdgeInsets.all(10.0),
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[card(snapshot.data)],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Container(
                color: Colors.white,
                child: dialogFail(context, reloadApp: true),
              ),
            );
          } else {
            return Center(child: Container());
          }
        },
      ),
    );
  }

  card(dynamic model) {
    // return Card(
    //   color: Colors.white,
    //   shape: RoundedRectangleBorder(
    //     borderRadius: BorderRadius.circular(15.0),
    //   ),
    //   elevation: 5,
    //   child: Padding(
    //       padding: EdgeInsets.only(left: 10.0, right: 10.0),
    //       child: formContentStep1(model)),
    // );
    return Padding(padding: EdgeInsets.all(10), child: formContentStep1(model));
  }

  formContentStep1(dynamic model) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (var item in model)
          Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  child: Text(
                    'การจองเสร็จสมบูรณ์',
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
                    'ขอบคุณที่เลือกปรึกษาหมอกับเรา',
                    style: TextStyle(
                      fontSize: 13.00,
                      fontFamily: 'Kanit',
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF707070),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Ticket(
                  dashedBottom: true,
                  innerRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20.0),
                    bottomRight: Radius.circular(20.0),
                  ),
                  outerRadius: BorderRadius.all(Radius.circular(20.0)),
                  boxShadow: [
                    BoxShadow(color: Colors.black),
                    BoxShadow(color: Colors.white),
                  ],
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          if (Platform.isAndroid) {
                            launch(
                              'https://play.google.com/store/apps/details?id=co.doctoratoz.app&hl=th&gl=US',
                            );
                          } else if (Platform.isIOS) {
                            launch(
                              'https://apps.apple.com/th/app/doctor-a-to-z/id1484302837',
                            );
                          }
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(10),
                          // width: (MediaQuery.of(context).size.width / 100) * 80,
                          child: Center(
                            child: Image.asset('assets/images/doctor.png'),
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: Text(
                          '   ${item['firstName']}  ${item['lastName']}',
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'Kanit',
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              child: Text(
                                "ใช้สิทธิ์ได้ถึง",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Kanit',
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Container(
                              child: Text(
                                (item['updateDate'] ?? '').toString() != ''
                                    ? "   ${DateFormat("dd-MM-yyyy").format(DateTime.parse(item['updateDate'].substring(0, 8)).add(const Duration(days: 60)))}"
                                    : '',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Kanit',
                                  color: Color(0XFF9A1120),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Ticket(
                  innerRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  ),
                  outerRadius: BorderRadius.all(Radius.circular(20.0)),
                  boxShadow: [
                    BoxShadow(color: Colors.black),
                    BoxShadow(color: Colors.white),
                  ],
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      Container(
                        alignment: Alignment.center,
                        width: (MediaQuery.of(context).size.width / 100) * 65,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Color(0XFFEEBA34),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            Flexible(
                              flex: 1,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    selectedType = '1';
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color:
                                        selectedType == '1'
                                            ? Color(0XFFEEBA34)
                                            : Color(0XFFF3E4E6),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'โค้ด',
                                    style: TextStyle(
                                      fontFamily: 'Kanit',
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          selectedType == '1'
                                              ? Color(0XFF981424)
                                              : Color(0XFF707070),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    selectedType = '2';
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color:
                                        selectedType == '2'
                                            ? Color(0XFFEEBA34)
                                            : Color(0XFFF3E4E6),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'รายละเอียด',
                                    style: TextStyle(
                                      fontFamily: 'Kanit',
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          selectedType == '2'
                                              ? Color(0XFF981424)
                                              : Color(0XFF707070),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      selectedType == "1"
                          ? Container(
                            height:
                                (MediaQuery.of(context).size.height / 100) * 33,
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(top: 30, bottom: 40),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${item['ref_code']}',
                                    style: TextStyle(
                                      fontSize: 35.00,
                                      fontFamily: 'Kanit',
                                      fontWeight: FontWeight.w500,
                                      // color: Color(0xFFBC0611),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: InkWell(
                                    onTap: () async {
                                      await Clipboard.setData(
                                        ClipboardData(
                                          text: '${item['ref_code']}',
                                        ),
                                      );
                                      launch(linkUrl);
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      width:
                                          (MediaQuery.of(context).size.width /
                                              100) *
                                          30,
                                      height:
                                          (MediaQuery.of(context).size.height /
                                              100) *
                                          5,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: Color(0xFF9A1120),
                                      ),
                                      child: Text(
                                        "ใช้รหัส",
                                        style: TextStyle(
                                          fontSize: 16.00,
                                          fontFamily: 'Kanit',
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                          : Container(
                            height:
                                (MediaQuery.of(context).size.height / 100) * 33,
                            child: Column(
                              children: [
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(
                                        left:
                                            (MediaQuery.of(context).size.width /
                                                100) *
                                            12,
                                      ),
                                      width:
                                          (MediaQuery.of(context).size.width /
                                              100) *
                                          37,
                                      child: Text(
                                        "ชื่อ - นามสกุล",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Kanit',
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      child: Text(
                                        '   ${item['firstName']}  ${item['lastName']}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Kanit',
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(
                                        left:
                                            (MediaQuery.of(context).size.width /
                                                100) *
                                            12,
                                      ),
                                      width:
                                          (MediaQuery.of(context).size.width /
                                              100) *
                                          37,
                                      child: Text(
                                        "เบอร์โทรศัพท์",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Kanit',
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      child: Text(
                                        '   ${item['phone']}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Kanit',
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(
                                        left:
                                            (MediaQuery.of(context).size.width /
                                                100) *
                                            12,
                                      ),
                                      width:
                                          (MediaQuery.of(context).size.width /
                                              100) *
                                          37,
                                      child: Text(
                                        "อีเมล",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Kanit',
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      child: Text(
                                        '   ${item['email']}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Kanit',
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(
                                        left:
                                            (MediaQuery.of(context).size.width /
                                                100) *
                                            12,
                                      ),
                                      width:
                                          (MediaQuery.of(context).size.width /
                                              100) *
                                          37,
                                      child: Text(
                                        "ช่วงอายุ",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Kanit',
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      child: Text(
                                        '   ${item['ageRange']}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Kanit',
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(
                                        left:
                                            (MediaQuery.of(context).size.width /
                                                100) *
                                            12,
                                      ),
                                      width:
                                          (MediaQuery.of(context).size.width /
                                              100) *
                                          37,
                                      child: Text(
                                        "อาชีพ",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Kanit',
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      child: Text(
                                        '   ${item['job']}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Kanit',
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(
                                        left:
                                            (MediaQuery.of(context).size.width /
                                                100) *
                                            12,
                                      ),
                                      width:
                                          (MediaQuery.of(context).size.width /
                                              100) *
                                          37,
                                      child: Text(
                                        "จังหวัด",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Kanit',
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      child: Text(
                                        '   ${item['province']}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Kanit',
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(
                                        left:
                                            (MediaQuery.of(context).size.width /
                                                100) *
                                            12,
                                      ),
                                      width:
                                          (MediaQuery.of(context).size.width /
                                              100) *
                                          37,
                                      child: Text(
                                        "วันที่รับสิทธิ์",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Kanit',
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      child: Text(
                                        (item['updateDate'] ?? '').toString() !=
                                                ''
                                            ? "   ${DateFormat("dd-MM-yyyy").format(DateTime.parse(item['updateDate'].substring(0, 8)))}"
                                            : '',
                                        style: TextStyle(
                                          fontSize: 14,
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
                  ),
                ),
                SizedBox(height: 20),
                InkWell(
                  onTap: () {
                    launch(
                      'https://www.youtube.com/watch?v=yhrxbrhALMQ&t=195s',
                    );
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'ขั้นตอนการใช้งาน Doctor A to Z',
                      style: TextStyle(
                        fontSize: 15.00,
                        fontFamily: 'Kanit',
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0000FF),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'บริการช่วยเหลือติดต่อ',
                    style: TextStyle(
                      fontSize: 13.00,
                      fontFamily: 'Kanit',
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF707070),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    await launch("https://line.me/ti/p/~@doctoratoz");
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Text(
                          '1. Line : ',
                          style: TextStyle(
                            fontSize: 13.00,
                            fontFamily: 'Kanit',
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF707070),
                          ),
                        ),
                        Text(
                          '@doctoratoz',
                          style: TextStyle(
                            fontSize: 13.00,
                            fontFamily: 'Kanit',
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF0000FF),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    await launch('tel:02 080 3911');
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Text(
                          '2. Tel : ',
                          style: TextStyle(
                            fontSize: 13.00,
                            fontFamily: 'Kanit',
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF707070),
                          ),
                        ),
                        Text(
                          '02 080 3911',
                          style: TextStyle(
                            fontSize: 13.00,
                            fontFamily: 'Kanit',
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF0000FF),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        Container(
          margin: EdgeInsets.only(top: 10),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      Color(0xFF9A1120),
                    ),
                  ),
                  child: Text("เสร็จสิ้น"),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Menu()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
