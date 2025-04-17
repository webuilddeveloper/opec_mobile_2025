import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opec/shared/api_provider.dart';
import 'package:opec/user.dart';
import 'package:opec/widget/header.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FundProvident extends StatefulWidget {
  FundProvident({
    Key? key,
    required this.userData,
    required this.title,
    required this.imageUrl,
  }) : super(key: key);
  final User userData;
  final String title;
  final String imageUrl;
  @override
  _FundProvidentState createState() => _FundProvidentState();
}

class _FundProvidentState extends State<FundProvident> {
  Future<dynamic> futureModel = Future.value(null);
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );
  TextEditingController txtyear = TextEditingController();
  int year = 0;
  int month = 0;
  final f = new NumberFormat("#,##0.00", "en_US");
  bool isLoad = false;

  @override
  void initState() {
    // var now = new DateTime.now();
    // var yearnumber = now.year;
    // while (yearnumber >= 1800) {
    //   _selectedYear.add(yearnumber);
    //   yearnumber--;
    // }

    _callRead();
    super.initState();
  }

  _callRead() {
    postDio('${server}m/v2/FundProvident/read', {
      'idCard': widget.userData.idcard ?? '',
    }).then((value) {
      setState(() {
        futureModel = Future.value(value);
        this.isLoad = true;
      });
    });
  }

  void _onRefresh() async {
    _callRead();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.loadComplete();
  }

  void goBack() async {
    Navigator.pop(context, false);
  }

  ////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    return _buildScaffold();
  }

  _buildScaffold() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: header(context, goBack, title: widget.title),
      body: FutureBuilder<dynamic>(
        future: futureModel,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            return _buildListView(
              snapshot.data.length > 0
                  ? snapshot.data[0]
                  : {'paymentDate': 'ไม่พบข้อมูล', 'price': 'ไม่พบข้อมูล'},
            );
          } else if (snapshot.hasError) {
            return _buildListView({
              'paymentDate': 'เกิดข้อผิดพลาด',
              'price': 'เกิดข้อผิดพลาด',
            });
          } else {
            return _buildListView({
              'paymentDate': 'ไม่พบข้อมูล',
              'price': 'ไม่พบข้อมูล',
            });
          }
        },
      ),
    );
  }

  _buildListView(dynamic model) {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: false,
      header: WaterDropHeader(
        complete: Container(child: Text('')),
        completeDuration: Duration(milliseconds: 0),
      ),
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: ListView(
        // shrinkWrap: true, // use it
        children: [
          Container(
            color: Color(0XFFEEBA33),
            height: (MediaQuery.of(context).size.height * 15) / 100,
            width: (MediaQuery.of(context).size.width * 100) / 100,
            child: _header(model),
          ),
          Stack(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0XFFEEBA33), width: 0),
                  color: Color(0XFFEEBA33),
                ),
                width: (MediaQuery.of(context).size.width * 100) / 100,
                height: 50,
                child: Text(''),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                  color: Color(0XFFFFFFFF),
                ),
                // height: (MediaQuery.of(context).size.height * 100) / 100,
                width: (MediaQuery.of(context).size.width * 100) / 100,
                // child: Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //_detail(),
                    // _table(model),
                    condition(),
                  ],
                ),
              ),
              // ),
            ],
          ),
        ],
      ),
    );
  }

  _header(dynamic model) {
    return Padding(
      padding: EdgeInsets.only(left: 15, top: 15, bottom: 15, right: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 10),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Color(0XFFFFFFFF),
                    borderRadius: BorderRadius.circular(150),
                  ),
                  width: 50,
                  height: 50,
                  child: Image.asset(
                    widget.imageUrl,
                    color: Color(0XFF9A1120),
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 15, left: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "วันที่ชำระเงิน",
                        style: TextStyle(
                          fontSize: 13.00,
                          fontFamily: 'Kanit',
                          color: Color(0XFFFFFFFF),
                          fontWeight: FontWeight.w500,
                        ),
                        // maxLines: 1,
                        // textAlign: TextAlign.center,
                      ),
                      this.isLoad
                          ? Text(
                            model['paymentDate'],
                            style: TextStyle(
                              fontSize: 13.00,
                              fontFamily: 'Kanit',
                              color: Color(0XFFFFFFFF),
                              fontWeight: FontWeight.w500,
                            ),
                            // maxLines: 1,
                            // textAlign: TextAlign.start,
                          )
                          : new Container(
                            // color: Colors.grey[300],
                            width: 30.0,
                            height: 30.0,
                            child: new Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: new Center(
                                child: new CircularProgressIndicator(
                                  backgroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.only(top: 10, right: 5),
              // height: (height * 25) / 100,
              // width: 200, //(width * 55) / 100,
              alignment: Alignment.centerRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.all(0),
                    child: Text(
                      "ยอดหนี้คงเหลือ",
                      style: TextStyle(
                        fontSize: 13.00,
                        fontFamily: 'Kanit',
                        color: Color(0XFFFFFFFF),
                        fontWeight: FontWeight.w500,
                      ),
                      // maxLines: 1,
                      textAlign: TextAlign.end,
                    ),
                  ),
                  this.isLoad
                      ? Container(
                        padding: EdgeInsets.all(0),
                        child: Text(
                          // f.format(model[0]['price'].toString()),
                          model['price'],
                          style: TextStyle(
                            fontSize: 20.00,
                            fontFamily: 'Kanit',
                            color: Color(0XFFFFFFFF),
                            fontWeight: FontWeight.w500,
                          ),
                          // maxLines: 1,
                          textAlign: TextAlign.end,
                        ),
                      )
                      : new Container(
                        // color: Colors.grey[300],
                        width: 50.0,
                        height: 50.0,
                        child: new Padding(
                          padding: const EdgeInsets.only(right: 20.0),
                          child: new Center(
                            child: new CircularProgressIndicator(
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // _detail() {
  //   DateTime now = DateTime.now();
  //   String formattedDate = DateFormat('dd/MM/yyyy').format(now);
  //   return Container(
  //     padding: EdgeInsets.only(top: 20, left: 20),
  //     margin: EdgeInsets.only(top: 10),
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.start,
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Container(
  //           child: Text(
  //             "ตารางการผ่อนชำระ",
  //             style: TextStyle(
  //               fontSize: 17.00,
  //               fontFamily: 'Kanit',
  //               color: Theme.of(context).primaryColor,
  //               fontWeight: FontWeight.w500,
  //             ),
  //           ),
  //         ),
  //         Container(
  //           child: Text(
  //             "ข้อมูล ณ วันที่ ${formattedDate}",
  //             style: TextStyle(
  //               fontSize: 10.00,
  //               fontFamily: 'Kanit',
  //               color: Color(0XFF707070),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // _table(dynamic model) {
  //   if (model.length > 0) {
  //     List<Widget> data() {
  //       List<Widget> list = [];
  //       list.add(_tableDataHeader());
  //       for (int i = 0; i < model.length; i++) {
  //         int index = model.indexOf(model[i]);
  //         list.add(_tableDataDetail(model[i], index));
  //       }
  //       return list;
  //     }

  //     return Container(
  //       padding: EdgeInsets.all(15),
  //       child: Column(children: data()),
  //     );
  //   } else {
  //     return Container(
  //       width: (MediaQuery.of(context).size.width * 100) / 100,
  //       padding: EdgeInsets.all(15),
  //       child: Text('ไม่พบข้อมูล', textAlign: TextAlign.center),
  //     );
  //   }
  // }

  // _tableDataHeader() {
  //   return Container(
  //     height: (MediaQuery.of(context).size.height * 3.5) / 100,
  //     width: (MediaQuery.of(context).size.width * 100) / 100,
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.only(
  //         topLeft: Radius.circular(5),
  //         topRight: Radius.circular(5),
  //       ),
  //       color: Color(0XFF9A1120),
  //     ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceAround,
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       mainAxisSize: MainAxisSize.max,
  //       children: [
  //         _textHeaderTabel('งวด', 2),
  //         _textHeaderTabel('เงินต้น', 2),
  //         _textHeaderTabel('ดอกเบี้ย', 3),
  //         _textHeaderTabel('ยอดคงเหลือ', 3),
  //       ],
  //     ),
  //   );
  // }

  // _tableDataDetail(dynamic data, int index) {
  //   return Container(
  //     // height: (MediaQuery.of(context).size.height * 3) / 100,
  //     width: (MediaQuery.of(context).size.width * 100) / 100,
  //     color: MaterialStateColor.resolveWith((states) {
  //       if ((index % 2) == 0) {
  //         return Color(0XFFF3E4E6);
  //       } else {
  //         return Color(0XFF00000000);
  //       }
  //     }),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceAround,
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         // Expanded(
  //         //   flex: 1,
  //         //   child: _textDetailTabel(data.month),
  //         // ),
  //         _textDetailTabel(data['installment'], 2, TextAlign.center),
  //         _textDetailTabel(f.format(data['principle']), 2, TextAlign.right),
  //         _textDetailTabel(f.format(data['interest']), 3, TextAlign.right),
  //         _textDetailTabel(f.format(data['balance']), 3, TextAlign.right),
  //       ],
  //     ),
  //   );
  // }

  // _textHeaderTabel(String txt, int flex) {
  //   return Expanded(
  //     flex: flex,
  //     child: Center(
  //       child: Text(
  //         txt,
  //         style: TextStyle(
  //           fontSize: 13,
  //           fontWeight: FontWeight.bold,
  //           color: Color(0XFFFFFFFF),
  //         ),
  //         textAlign: TextAlign.center,
  //       ),
  //     ),
  //   );
  // }

  // _textDetailTabel(String txt, int flex, TextAlign textAlign) {
  //   return Expanded(
  //     flex: flex,
  //     child: Padding(
  //       padding: EdgeInsets.all(5),
  //       child: Text(txt, style: TextStyle(fontSize: 12), textAlign: textAlign),
  //     ),
  //   );
  // }

  condition() {
    return Container(
      padding: EdgeInsets.only(top: 30, left: 10, right: 10, bottom: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Text(
              "เงื่อนไข:",
              style: TextStyle(
                fontSize: 13.00,
                fontFamily: 'Kanit',
                color: Color(0XFF000000),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            child: Text(
              '''เงินทุนเลี้ยงชีพ
ผู้มีสิทธิ ได้แก่ ผู้อำนวยการ ครู บุคลากรทางการศึกษาที่ลาออกจากงาน และทายาท
(คู่สมรส บุตร บิดา มารดา) กรณีถึงแก่กรรม
สิทธิที่จะได้รับ
1. เงินทุนเลี้ยงชีพประเภท 1 ได้แก่ เงินที่กองทุนสงเคราะห์จ่ายให้ผู้มีสิทธิเท่ากับเงินสะสมที่ผู้มีสิทธิ
ส่งพร้อมดอกเบี้ยเมื่อลาออกจากงาน
2. เงินทุนเลี้ยงชีพประเภท 2 ได้แก่ เงินที่กองทุนสงเคราะห์จ่ายให้แก่ผู้มีสิทธิเมื่อลาออกจากงาน
โดยไม่มีความผิดและออกจากงานกรณี ดังนี้
2.1 มีเวลาทำงานครบ 5 ปี ส่งเงินสะสมครบ 60 งวด สำหรับผู้อำนวยการ ครู และบุคลากร
ทางการศึกษาที่บรรจุตาม พ.ร.บ.โรงเรียนเอกชน พ.ศ. 2525 (บรรจุก่อนวันที่ 12 ม.ค. 51)
และมีเวลาทำงาน ครบ 10 ปี ส่งเงินสะสมครบ 120 งวด สำหรับผู้อำนวยการ ครู และ
บุคลากรทางการศึกษาที่บรรจุตาม พ.ร.บ.โรงเรียนเอกชน พ.ศ. 2550 แก้ไขเพิ่มเติม
ฉบับที่ 2 พ.ศ. 2554 (บรรจุตั้งแต่วันที่ 12 ม.ค. 51 เป็นต้นไป)
2.2 โรงเรียนเลิกกิจการ
2.3 โรงเรียนยุบชั้นเรียนทีละชั้น หรือทั้งระดับ
2.4 กรณีทุพพลภาพ
2.5 กรณีถึงแก่กรรม
เอกสารประกอบในการยื่นเบิก
1. สำเนาสมุดคู่ฝากธนาคารกรุงไทย จำกัด (มหาชน) ที่มีเลขและชื่อบัญชีของผู้อำนวยการ ครู
และบุคลากรทางการศึกษาผู้ขอเบิก และหน้าที่ใช้ปัจจุบัน
2. สำเนาหนังสือถอดถอนผู้อำนวยการ/ครู ใบลาออกจากผู้อำนวยการ/ครู
2. สำเนาหลักฐานใบนำส่งเงินสะสมและเงินสมทบเข้ากองทุนสงเคราะห์เดือนสุดท้าย
3. สำเนาสมุดประจำตัวผู้อำนวยการ รองผู้อำนวยการ ครู และบุคลากรทางการศึกษา หน้า 1,2,3,6
และ 10 หรือ 12 ลงจำหน่ายเรียบร้อยแล้วพร้อมสมุดเล่มจริง
5. กรณีไม่มีสมุดประจำตัวผู้อำนวยการ รองผู้อำนวยการ ครู และบุคลากรทางการศึกษา ให้ใช้
บัตร ร 8 ข หรือสำเนา สช. 8 หรือสำเนา สช. 18 หรือหนังสือแต่งตั้งผู้อำนวยการ ครู และ
บุคลากรทางการศึกษา สำเนาบัตรประจำตัวประชาชน (กรณีสมุดประจำตัวหายให้แนบสำเนาใบ
แจ้งความ)
6. สำเนาใบอนุญาตเลิกกิจการโรงเรียน ร12 (กรณีเลิกกิจการ) และสำเนาใบอนุญาตยุบชั้นเรียน ร12
(กรณียุบชั้นเรียน)
7. สำเนาแบบรายการภาษีเงินได้หัก ณ ที่จ่าย ภ.ง.ด.90 หรือ ภ.ง.ด.91 หรือ หนังสือรับรองการ
หักภาษี ณ ที่จ่าย ตามมาตรา 50 ทวิแห่งประมวลรัษฎากรสำหรับผู้อำนวยการ ครู และบุคลากร
ทางการศึกษาที่นำส่งเงินสะสมเข้ากองทุนสงเคราะห์เกิน 900 บาทต่อเดือนตั้งแต่บรรจุถึงเดือน
กันยายน 2551 และส่งเกิน 700 บาทต่อเดือนตั้งแต่เดือนตุลาคม 2551 ถึงปัจจุบัน
8. หลักฐานอื่นๆ เช่น หลักฐานการเปลี่ยนชื่อ เปลี่ยนชื่อสกุล ใบทะเบียนสมรส ใบสำคัญการหย่า
กรณีที่ผู้อำนวยการ ครู และบุคลากรทางการศึกษาถึงแก่กรรมใช้เอกสาร ดังนี้
1. สำเนาสมุดคู่ฝากธนาคารกรุงไทย จำกัด (มหาชน) ที่มีเลขและชื่อบัญชีของทายาท และหน้าที่
ใช้ปัจจุบัน
2. สำเนาหนังสือถอดถอนผู้อำนวยการ/ครู ให้ระบุวันถอดถอนตามวันถึงแก่กรรมตามที่ระบุไว้ใน
ใบมรณะบัตร
3. สำเนาหลักฐานใบนำส่งเงินสะสมและเงินสมทบเข้ากองทุนสงเคราะห์เดือนสุดท้าย
.สำเนาสมุดประจำตัวผู้อำนวยการ รองผู้อำนวยการ ครู และบุคลากรทางการศึกษา หน้า 1,2,3,6
และ 10 หรือ 12 พร้อมสมุดเล่มจริง
5. กรณีไม่มีสมุดประจำตัวผู้อำนวยการ รองผู้อำนวยการ ครู และบุคลากรทางการศึกษา ให้ใช้
บัตร ร 8 ข หรือสำเนา สช. 8 หรือสำเนา สซ. 18 หรือหนังสือแต่งตั้งผู้อำนวยการ ครู และ
บุคลากรทางการศึกษา สำเนาบัตรประจำตัวประชาชน (กรณีสมุดประจำตัวหายให้แนบสำเนา
ใบแจ้งความ)
6. สำเนาบัตรประจำตัวประชนชนของผู้ถึงแก่กรรม ทายาท บิดา มารดา พี่น้อง และพยาน
7. สำเนาทะเบียนบ้านของผู้ถึงแก่กรรม ทายาท บิดา มารดา พี่น้อง และพยาน
8. กรณีบิดา มารดาถึงแก่กรรมให้แนบใบมรณะบัตรของบิดา มารดา
10 กรณีครูไม่ได้สมรสให้แนบหนังสือรับรองการเป็นโสดเพิ่มเติม
9. หลักฐานอื่นๆ เช่น หลักฐานการเปลี่ยนชื่อ เปลี่ยนชื่อสกุล ใบทะเบียนสมรส ใบสำคัญการหย่า
หมายเหตุ : 1. ให้ผู้อำนวยการ ครู และบุคลากรทางการศึกษาผู้ใช้สิทธิรับรองสำเนาถูกต้องในสำเนาเอกสาร
ประกอบทุกฉบับ
2. ทุกครั้งที่มีการเปลี่ยนแปลงให้โรงเรียนบันทึกเพิ่มเติมในสมุดประจำตัวผู้อำนวยการ
รองผู้อำนวยการ ครู และบุคลากรทางการศึกษา โดยให้ผู้รับใบอนุญาตลงนาม หากไม่แจ้งต้อง
แนบเอกสารตามที่เจ้าหน้าที่ร้องขอ
''',
              style: TextStyle(
                fontSize: 10.00,
                fontFamily: 'Kanit',
                color: Color(0XFF000000),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
