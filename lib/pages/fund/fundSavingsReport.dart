import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:opec/shared/api_provider.dart';
import 'package:opec/user.dart';
import 'package:opec/widget/header.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FundSavingsReport extends StatefulWidget {
  FundSavingsReport({Key? key, required this.userData, required this.title})
    : super(key: key);
  final User userData;
  final String title;
  @override
  _FundSavingsReportState createState() => _FundSavingsReportState();
}

class _FundSavingsReportState extends State<FundSavingsReport> {
  Future<dynamic> futureModel = Future.value(null);
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );
  TextEditingController txtyear = TextEditingController();
  final _selectedYear = [];
  int year = 0;
  int month = 0;
  final f = NumberFormat("#,##0.00", "en_US");

  bool isLoad = false;

  DateTime selectedDateStart = DateTime.now();
  DateTime selectedDateEnd = DateTime.now();
  DateTime dateStart = DateTime.now().add(Duration(days: -7300));
  DateTime dateEnd = DateTime.now();

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
    postDio('${server}m/v2/FundSavingsReport/read', {
      'startDate': DateFormat('yyyyMMdd').format(this.dateStart),
      'endDate': DateFormat('yyyyMMdd').format(this.dateEnd),
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
            return _buildListView(snapshot.data);
          } else if (snapshot.hasError) {
            return _buildListView([]);
          } else {
            return _buildListView([]);
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
          Stack(
            children: <Widget>[
              Container(
                color: Color(0XFFEEBA33),
                height: (MediaQuery.of(context).size.height * 30) / 100,
                width: (MediaQuery.of(context).size.width * 100) / 100,
                child: _header(model),
              ),
              Container(
                margin: EdgeInsets.only(
                  top: (MediaQuery.of(context).size.height * 25) / 100,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                  color: Color(0XFFFFFFFF),
                ),
                // height: (MediaQuery.of(context).size.height * 100) / 100,
                width: (MediaQuery.of(context).size.width * 100) / 100,
                child: Column(
                  children: [_timePeriod(), condition(), _table(model)],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _header(dynamic model) {
    var total =
        model.length > 0
            ? model.map<dynamic>((m) => m["deposit"]).reduce((a, b) => a + b)
            : 0;

    return Padding(
      padding: EdgeInsets.all(15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            child: Text(
              "ยอดสะสมกองทุน",
              style: TextStyle(
                fontSize: 15.00,
                fontFamily: 'Kanit',
                color: Color(0XFFFFFFFF),
                // fontWeight: FontWeight.w500,
              ),
            ),
          ),
          this.isLoad
              ? Container(
                child: Text(
                  f.format(total),
                  style: TextStyle(
                    fontSize: 40.00,
                    fontFamily: 'Kanit',
                    color: Color(0XFFFFFFFF),
                  ),
                ),
              )
              : Container(
                // color: Colors.grey[300],
                width: 70.0,
                height: 70.0,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  _timePeriod() {
    return Padding(
      padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            child: Text(
              "เลือกช่วงเวลา",
              style: TextStyle(
                fontSize: 17.00,
                fontFamily: 'Kanit',
                color: Color(0XFF000000),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  showMonthPicker(
                    context: context,
                    firstDate: DateTime(DateTime.now().year - 100, 5),
                    lastDate: DateTime(DateTime.now().year + 1, 9),
                    initialDate: selectedDateStart,
                  ).then(
                    (date) => setState(() {
                      if (date != null) {
                        if (date.isBefore(
                          DateTime(
                            dateEnd.year,
                            dateEnd.month + 1,
                            dateEnd.day,
                          ),
                        )) {
                          dateStart = date;
                          selectedDateStart = date;
                          this.isLoad = false;
                          _callRead();
                        }
                      }
                    }),
                  );
                },
                child: Container(
                  width: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Color(0XFFEEBA33)),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          'เดือนเริ่มต้น',
                          style: TextStyle(
                            fontSize: 15.00,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          DateFormat('MMM yy', 'th').format(dateStart),
                          style: TextStyle(
                            fontSize: 30.00,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 20),
              InkWell(
                onTap: () {
                  showMonthPicker(
                    context: context,
                    firstDate: DateTime(DateTime.now().year - 100, 5),
                    lastDate: DateTime(DateTime.now().year + 1, 9),
                    initialDate: selectedDateEnd,
                  ).then(
                    (date) => setState(() {
                      if (date != null)
                        if (DateTime(
                          dateStart.year,
                          dateStart.month - 1,
                          dateStart.day,
                        ).isBefore(date)) {
                          dateEnd = date;
                          selectedDateEnd = date;
                          this.isLoad = false;
                          _callRead();
                        }
                    }),
                  );
                },
                child: Container(
                  width: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Color(0XFFEEBA33)),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          'เดือนสิ้นสุด',
                          style: TextStyle(
                            fontSize: 15.00,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          DateFormat('MMM yy', 'th').format(dateEnd),
                          style: TextStyle(
                            fontSize: 30.00,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // new Container(
          //   width: 300.0,
          //   padding: EdgeInsets.symmetric(
          //     horizontal: 5,
          //     vertical: 0,
          //   ),
          //   decoration: BoxDecoration(
          //     color: Color(0xFF9A1120),
          //     borderRadius: BorderRadius.circular(
          //       10,
          //     ),
          //   ),
          //   child: DropdownButtonFormField(
          //     decoration: InputDecoration(
          //       errorStyle: TextStyle(
          //         fontWeight: FontWeight.normal,
          //         fontFamily: 'Kanit',
          //         fontSize: 10.0,
          //       ),
          //       enabledBorder: UnderlineInputBorder(
          //         borderSide: BorderSide(
          //           color: Colors.white,
          //         ),
          //       ),
          //     ),
          //     validator: (value) =>
          //         value == '' || value == null ? 'กรุณาเลือกปี' : null,
          //     hint: SizedBox(
          //       width: 266,
          //       child: Text(
          //         'กรุณาเลือกปี',
          //         style: TextStyle(
          //             fontSize: 15.00,
          //             fontFamily: 'Kanit',
          //             color: Color(0XFFFFFFFF)),
          //         textAlign: TextAlign.center,
          //       ),
          //     ),
          //     icon: Icon(
          //       Icons.arrow_drop_down,
          //       color: Color(0XFFFFFFFF),
          //     ),
          //     onChanged: (newValue) {
          //       setState(() {
          //         year = newValue;
          //         _callRead();
          //       });
          //     },
          //     selectedItemBuilder: (BuildContext context) {
          //       return _selectedYear.map<Widget>((item) {
          //         return SizedBox(
          //           width: 266,
          //           child: new Text(
          //             item.toString(),
          //             style: TextStyle(
          //               fontSize: 15.00,
          //               fontFamily: 'Kanit',
          //               color: Color(
          //                 0xFFFFFFFF,
          //               ),
          //             ),
          //             textAlign: TextAlign.center,
          //           ),
          //         );
          //       }).toList();
          //     },
          //     items: _selectedYear.map((item) {
          //       return DropdownMenuItem(
          //         child: Center(
          //           child: new Text(
          //             item.toString(),
          //             style: TextStyle(
          //               fontSize: 15.00,
          //               fontFamily: 'Kanit',
          //               color: Color(
          //                 0xFF9A1120,
          //               ),
          //             ),
          //           ),
          //         ),
          //         value: item,
          //       );
          //     }).toList(),
          //   ),
          // ),
          // SizedBox(height: 8),
          // new Container(
          //   width: 300.0,
          //   padding: EdgeInsets.symmetric(
          //     horizontal: 5,
          //     vertical: 0,
          //   ),
          //   decoration: BoxDecoration(
          //     color: Color(0xFF9A1120),
          //     borderRadius: BorderRadius.circular(
          //       10,
          //     ),
          //   ),
          //   child: DropdownButtonFormField(
          //     decoration: InputDecoration(
          //       errorStyle: TextStyle(
          //         fontWeight: FontWeight.normal,
          //         fontFamily: 'Kanit',
          //         fontSize: 10.0,
          //       ),
          //       enabledBorder: UnderlineInputBorder(
          //         borderSide: BorderSide(
          //           color: Colors.white,
          //         ),
          //       ),
          //     ),
          //     validator: (value) =>
          //         value == '' || value == null ? 'กรุณาเดือน' : null,
          //     hint: SizedBox(
          //       width: 266,
          //       child: Text(
          //         'กรุณาเดือน',
          //         style: TextStyle(
          //             fontSize: 15.00,
          //             fontFamily: 'Kanit',
          //             color: Color(0XFFFFFFFF)),
          //         textAlign: TextAlign.center,
          //       ),
          //     ),
          //     icon: Icon(
          //       Icons.arrow_drop_down,
          //       color: Color(0XFFFFFFFF),
          //     ),
          //     onChanged: (newValue) {
          //       setState(() {
          //         month = newValue;
          //         _callRead();
          //       });
          //     },
          //     selectedItemBuilder: (BuildContext context) {
          //       return _selectedMonth.map<Widget>((item) {
          //         return SizedBox(
          //           width: 266,
          //           child: new Text(
          //             item.toString(),
          //             style: TextStyle(
          //               fontSize: 15.00,
          //               fontFamily: 'Kanit',
          //               color: Color(
          //                 0xFFFFFFFF,
          //               ),
          //             ),
          //             textAlign: TextAlign.center,
          //           ),
          //         );
          //       }).toList();
          //     },
          //     items: _selectedMonth.map((item) {
          //       return DropdownMenuItem(
          //         child: Center(
          //           child: new Text(
          //             item.toString(),
          //             style: TextStyle(
          //               fontSize: 15.00,
          //               fontFamily: 'Kanit',
          //               color: Color(
          //                 0xFF9A1120,
          //               ),
          //             ),
          //           ),
          //         ),
          //         value: item,
          //       );
          //     }).toList(),
          //   ),
          // ),
        ],
      ),
    );
  }

  _table(dynamic model) {
    if (!this.isLoad) {
      return Container();
      // return new Container(
      //   // color: Colors.grey[300],
      //   width: 300.0,
      //   height: 300.0,
      //   child: new Padding(
      //       padding: const EdgeInsets.all(5.0),
      //       child: new Center(
      //           child: new CircularProgressIndicator(
      //               backgroundColor: Colors.white))),
      // );
    } else if (model.length > 0) {
      List<Widget> data() {
        List<Widget> list = [];
        list.add(_tableDataHeader());
        for (int i = 0; i < model.length; i++) {
          int index = model.indexOf(model[i]);
          list.add(_tableDataDetail(model[i], index));
        }
        return list;
      }

      return Container(
        padding: EdgeInsets.all(15),
        child: Column(children: data()),
      );
    } else {
      return Container(
        padding: EdgeInsets.all(15),
        child: Text('ไม่พบข้อมูล', textAlign: TextAlign.center),
      );
    }
  }

  _tableDataHeader() {
    return Container(
      height: (MediaQuery.of(context).size.height * 4.5) / 100,
      width: (MediaQuery.of(context).size.width * 100) / 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(5),
          topRight: Radius.circular(5),
        ),
        color: Color(0XFF9A1120),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          _textHeaderTabel('ปี', 1),
          _textHeaderTabel('เดือน', 1),
          _textHeaderTabel('งวดสมทบ', 2),
          _textHeaderTabel('วันที่จ่ายเงิน', 2),
          _textHeaderTabel('ยอดเงินสะสม 3%', 2),
        ],
      ),
    );
  }

  _tableDataDetail(dynamic data, int index) {
    return Container(
      // height: (MediaQuery.of(context).size.height * 3) / 100,
      width: (MediaQuery.of(context).size.width * 100) / 100,
      color: MaterialStateColor.resolveWith((states) {
        if ((index % 2) == 0) {
          return Color(0XFFF3E4E6);
        } else {
          return Color(0XFF00000000);
        }
      }),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Expanded(
          //   flex: 1,
          //   child: _textDetailTabel(data.month),
          // ),
          _textDetailTabel(data['period_year'].toString(), 1, TextAlign.center),
          _textDetailTabel(
            data['period_month'].toString(),
            1,
            TextAlign.center,
          ),
          _textDetailTabel(data['installment'].toString(), 2, TextAlign.center),

          // _textDetailTabel(data['billpayment_date'], 2, TextAlign.right),
          _textDetailTabel(
            data['billpayment_date'].toString().substring(6, 8) +
                '/' +
                data['billpayment_date'].toString().substring(4, 6) +
                '/' +
                data['billpayment_date'].toString().substring(0, 4),
            2,
            TextAlign.center,
          ),

          _textDetailTabel(f.format(data['deposit']), 2, TextAlign.center),
        ],
      ),
    );
  }

  _textHeaderTabel(String txt, int flex) {
    return Expanded(
      flex: flex,
      child: Center(
        child: Text(
          txt,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0XFFFFFFFF),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  _textDetailTabel(String txt, int flex, TextAlign textAlign) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: EdgeInsets.all(5),
        child: Text(txt, style: TextStyle(fontSize: 12), textAlign: textAlign),
      ),
    );
  }

  condition() {
    return Container(
      padding: EdgeInsets.only(top: 15, left: 15, right: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Text(
              "ข้อมูล ณ เดือน กุมภาพันธ์ ปี 2564",
              style: TextStyle(
                fontSize: 15.00,
                fontFamily: 'Kanit',
                color: Color(0XFF000000),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
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
              'สิทธิ์ในการรับเงินสมทบ ของโรงเรียน 3% และของรัฐบาล 6% เป็นไปตามระเบียบ ของกองทุนสงเคราะห์',
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
