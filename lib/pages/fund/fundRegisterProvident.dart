import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opec/user.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:opec/shared/api_provider.dart';
import 'package:opec/widget/header.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FundRegisterProvident extends StatefulWidget {
  FundRegisterProvident({Key? key, required this.userData, required this.title})
    : super(key: key);
  final User userData;
  final String title;
  @override
  _FundRegisterProvidentState createState() => _FundRegisterProvidentState();
}

class _FundRegisterProvidentState extends State<FundRegisterProvident> {
  Future<dynamic> futureModel = Future.value(null);
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );
  TextEditingController txtyear = TextEditingController();
  final _selectedYear = [];
  // final _selectedMonth = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
  int year = 0;
  int month = 0;
  final f = NumberFormat("#,##0.00", "en_US");

  @override
  void initState() {
    var now = DateTime.now();
    var yearnumber = now.year;
    while (yearnumber >= 1800) {
      _selectedYear.add(yearnumber);
      yearnumber--;
    }

    _callRead();
    super.initState();
  }

  _callRead() {
    futureModel = postDio('${server}m/v2/FundRegisterProvident/read', {
      'year': this.year,
      "month": this.month,
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
            return _buildListView(snapshot.data);
          } else if (snapshot.hasError) {
            return Container();
          } else {
            return Container();
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
          _header(model),
          // _body(model),
          // _dashboard(model),
          // _timePeriod(),
          // _table(model),
        ],
      ),
    );
  }

  _header(dynamic model) {
    // DateTime now = DateTime.now();
    // String formattedDate = DateFormat('dd/MM/yyyy').format(now);
    return Padding(
      padding: EdgeInsets.all(0),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0XFFEEBA33),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
        ),
        // height: (MediaQuery.of(context).size.height * 25) / 100,
        width: (MediaQuery.of(context).size.width * 100) / 100,
        child: Column(
          children: [
            Material(
              child: Container(
                padding: EdgeInsets.all(10),
                color: Color(0XFFEEBA33),
                child: ClipRRect(
                  child: Image.asset(
                    'assets/images/fund.png',
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 20),
              child: Text(
                'สมัครสินเชื่อเพื่อสวัสดิการเงินทุนเลี้ยงชีพ',
                style: TextStyle(fontSize: 18, color: Color(0XFFFFFFFF)),
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 10, bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      launch(model[0]['link1']);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0XFFFFFFFF),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(
                          top: 10,
                          bottom: 10,
                          left: 20,
                          right: 20,
                        ),
                        child: Text(
                          '${model[0]['linkTitle1']}',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0XFFEEBA33),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  InkWell(
                    onTap: () {
                      launch(model[0]['link2']);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0XFFFFFFFF),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(
                          top: 10,
                          bottom: 10,
                          left: 20,
                          right: 20,
                        ),
                        child: Text(
                          '${model[0]['linkTitle2']}',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0XFF9A1120),
                          ),
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
    );
  }

  // _body(dynamic model) {
  //   return Padding(
  //     padding: EdgeInsets.all(15),
  //     child: Container(
  //       decoration: BoxDecoration(
  //         // border: Border.all(width: 2, color: Color(0xFFFFFFFF)),
  //         borderRadius: BorderRadius.circular(15),
  //         color: Color(0XFFF4A460),
  //       ),
  //       child: Padding(
  //         padding: EdgeInsets.all(15),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.max,
  //           children: [
  //             Row(
  //               children: [
  //                 Icon(Icons.circle, size: 20, color: Color(0XFF0000FF)),
  //                 Expanded(
  //                   child: InkWell(
  //                     onTap: () {
  //                       launch(model[0]['link1']);
  //                     },
  //                     child: Container(
  //                       margin: EdgeInsets.only(left: 15),
  //                       child: Text(
  //                         '${model[0]['linkTitle1']}',
  //                         style: TextStyle(
  //                           fontSize: 30,
  //                           decoration: TextDecoration.underline,
  //                           color: Color(0XFF0000FF),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             SizedBox(height: 30),
  //             Row(
  //               mainAxisSize: MainAxisSize.max,
  //               children: [
  //                 Icon(Icons.circle, size: 20, color: Color(0XFF0000FF)),
  //                 Expanded(
  //                   child: InkWell(
  //                     onTap: () {
  //                       launch(model[0]['link2']);
  //                     },
  //                     child: Container(
  //                       margin: EdgeInsets.only(left: 15),
  //                       child: Text(
  //                         '${model[0]['linkTitle2']}',
  //                         style: TextStyle(
  //                           fontSize: 30,
  //                           decoration: TextDecoration.underline,
  //                           color: Color(0XFF0000FF),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // _dashboard(dynamic model) {
  //   return Center(
  //     child: Container(
  //       child: SfCartesianChart(
  //         primaryXAxis: CategoryAxis(
  //           labelStyle: TextStyle(fontFamily: 'Kanit'),
  //           // Axis will be rendered based on the index values
  //           arrangeByIndex: true,
  //         ),
  //         series: [
  //           ColumnSeries<dynamic, String>(
  //             color: Color(0XFFEEBA33),
  //             dataSource: model,
  //             xValueMapper: (dynamic sales, _) => sales['monthAbbreviation'],
  //             yValueMapper: (dynamic sales, _) => sales['sales'],
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // _timePeriod() {
  //   return Padding(
  //     padding: EdgeInsets.all(15),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       children: [
  //         Container(
  //           child: Text(
  //             "เลือกช่วงเวลา",
  //             style: TextStyle(
  //               fontSize: 15.00,
  //               fontFamily: 'Kanit',
  //               color: Color(0XFF000000),
  //               fontWeight: FontWeight.w500,
  //             ),
  //           ),
  //         ),
  //         SizedBox(height: 8),
  //         Container(
  //           width: 300.0,
  //           padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
  //           decoration: BoxDecoration(
  //             color: Color(0xFF9A1120),
  //             borderRadius: BorderRadius.circular(10),
  //           ),
  //           child: DropdownButtonFormField(
  //             decoration: InputDecoration(
  //               errorStyle: TextStyle(
  //                 fontWeight: FontWeight.normal,
  //                 fontFamily: 'Kanit',
  //                 fontSize: 10.0,
  //               ),
  //               enabledBorder: UnderlineInputBorder(
  //                 borderSide: BorderSide(color: Colors.white),
  //               ),
  //             ),
  //             validator:
  //                 (value) =>
  //                     value == '' || value == null ? 'กรุณาเลือกปี' : null,
  //             hint: SizedBox(
  //               width: 266,
  //               child: Text(
  //                 'กรุณาเลือกปี',
  //                 style: TextStyle(
  //                   fontSize: 15.00,
  //                   fontFamily: 'Kanit',
  //                   color: Color(0XFFFFFFFF),
  //                 ),
  //                 textAlign: TextAlign.center,
  //               ),
  //             ),
  //             icon: Icon(Icons.arrow_drop_down, color: Color(0XFFFFFFFF)),
  //             onChanged: (newValue) {
  //               setState(() {
  //                 year = newValue as int;
  //                 _callRead();
  //               });
  //             },
  //             selectedItemBuilder: (BuildContext context) {
  //               return _selectedYear.map<Widget>((item) {
  //                 return SizedBox(
  //                   width: 266,
  //                   child: Text(
  //                     item.toString(),
  //                     style: TextStyle(
  //                       fontSize: 15.00,
  //                       fontFamily: 'Kanit',
  //                       color: Color(0xFFFFFFFF),
  //                     ),
  //                     textAlign: TextAlign.center,
  //                   ),
  //                 );
  //               }).toList();
  //             },
  //             items:
  //                 _selectedYear.map((item) {
  //                   return DropdownMenuItem(
  //                     value: item,
  //                     child: Center(
  //                       child: Text(
  //                         item.toString(),
  //                         style: TextStyle(
  //                           fontSize: 15.00,
  //                           fontFamily: 'Kanit',
  //                           color: Color(0xFF9A1120),
  //                         ),
  //                       ),
  //                     ),
  //                   );
  //                 }).toList(),
  //           ),
  //         ),
  //         SizedBox(height: 8),
  //         Container(
  //           width: 300.0,
  //           padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
  //           decoration: BoxDecoration(
  //             color: Color(0xFF9A1120),
  //             borderRadius: BorderRadius.circular(10),
  //           ),
  //           child: DropdownButtonFormField(
  //             decoration: InputDecoration(
  //               errorStyle: TextStyle(
  //                 fontWeight: FontWeight.normal,
  //                 fontFamily: 'Kanit',
  //                 fontSize: 10.0,
  //               ),
  //               enabledBorder: UnderlineInputBorder(
  //                 borderSide: BorderSide(color: Colors.white),
  //               ),
  //             ),
  //             validator:
  //                 (value) => value == '' || value == null ? 'กรุณาเดือน' : null,
  //             hint: SizedBox(
  //               width: 266,
  //               child: Text(
  //                 'กรุณาเดือน',
  //                 style: TextStyle(
  //                   fontSize: 15.00,
  //                   fontFamily: 'Kanit',
  //                   color: Color(0XFFFFFFFF),
  //                 ),
  //                 textAlign: TextAlign.center,
  //               ),
  //             ),
  //             icon: Icon(Icons.arrow_drop_down, color: Color(0XFFFFFFFF)),
  //             onChanged: (newValue) {
  //               setState(() {
  //                 month = newValue as int;
  //                 _callRead();
  //               });
  //             },
  //             selectedItemBuilder: (BuildContext context) {
  //               return _selectedMonth.map<Widget>((item) {
  //                 return SizedBox(
  //                   width: 266,
  //                   child: Text(
  //                     item.toString(),
  //                     style: TextStyle(
  //                       fontSize: 15.00,
  //                       fontFamily: 'Kanit',
  //                       color: Color(0xFFFFFFFF),
  //                     ),
  //                     textAlign: TextAlign.center,
  //                   ),
  //                 );
  //               }).toList();
  //             },
  //             items:
  //                 _selectedMonth.map((item) {
  //                   return DropdownMenuItem(
  //                     value: item,
  //                     child: Center(
  //                       child: Text(
  //                         item.toString(),
  //                         style: TextStyle(
  //                           fontSize: 15.00,
  //                           fontFamily: 'Kanit',
  //                           color: Color(0xFF9A1120),
  //                         ),
  //                       ),
  //                     ),
  //                   );
  //                 }).toList(),
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
  //         _textHeaderTabel('ปี', 2),
  //         _textHeaderTabel('เดือน', 2),
  //         _textHeaderTabel('ยอดสมทบก่อนหน้า', 3),
  //         _textHeaderTabel('ยอดสมทบงวดนี้', 3),
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
  //         _textDetailTabel(data['month'], 2, TextAlign.center),
  //         _textDetailTabel(data['year'].toString(), 2, TextAlign.center),
  //         _textDetailTabel(f.format(data['salesold']), 3, TextAlign.right),
  //         _textDetailTabel(f.format(data['sales']), 3, TextAlign.right),
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
}
