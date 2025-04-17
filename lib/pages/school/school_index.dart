import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:opec/shared/api_provider.dart';
import 'package:opec/widget/button.dart';
import 'package:opec/widget/dialog.dart';
import 'package:opec/widget/header.dart';

import 'school_list.dart';

class BuildSchoolIndex extends StatefulWidget {
  BuildSchoolIndex({Key? key, this.menuModel, this.model, this.isAppbar = false})
      : super(key: key);

  final Future<dynamic>? model;
  final Future<dynamic>? menuModel;
  final bool isAppbar;

  @override
  BuildSchoolIndexState createState() => BuildSchoolIndexState();
}

class BuildSchoolIndexState extends State<BuildSchoolIndex> {
  dynamic _tempModel = {'imageUrl': '', 'schoolName': ''};
  final textEditingController = TextEditingController();
  List<dynamic> _itemProvince = [];
  String _selectedProvince = '';

  @override
  void initState() {
    _read();
    super.initState();
  }

  _read() {
    getProvince();
  }

  Future<dynamic> getProvince() async {
    final result = await postObjectData("route/province/read", {});
    if (result['status'] == 'S') {
      setState(() {
        _itemProvince = result['objectData'];
      });
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
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: widget.isAppbar
            ? PreferredSize(
                preferredSize: Size.fromHeight(0),
                child: AppBar(),
              )
            : header(context, () => {Navigator.pop(context)},
                title: 'ตรวจสอบโรงเรียน'),
        body: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: FutureBuilder<dynamic>(
            future: widget.menuModel,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.hasData) {
                return screen(snapshot.data, false);
              } else if (snapshot.hasError) {
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                  height: 90,
                  child: Center(
                    child: Text('Network ขัดข้อง'),
                  ),
                );
              } else {
                return screen(_tempModel, true);
              }
            },
          ),
        ),
      ),
    );
  }

  screen(dynamic model, bool isLoading) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Text(
              'ค้นหาข้อมูลโรงเรียน',
              style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).primaryColor),
            ),
          ),
          Container(
            child: Text(
              'กรุณากรอกชื่อโรงเรียนที่ท่านต้องการตรวจสอบ',
              style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Center(
            child: Container(
              width: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Text(
                      'ชื่อโรงเรียน',
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  TextFormField(
                    obscureText: false,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                      fontFamily: 'Kanit',
                      fontSize: 16.0,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFE8CACD),
                      contentPadding: EdgeInsets.fromLTRB(15.0, 5.0, 5.0, 5.0),
                      hintText: 'กรุณากรอกชื่อโรงเรียน',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                      errorStyle: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontFamily: 'Kanit',
                        fontSize: 10.0,
                      ),
                    ),
                    controller: textEditingController,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    child: Text(
                      'จังหวัด',
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    width: 5000.0,
                    padding: EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 0,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xFFE8CACD),
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                    ),
                    child: (_selectedProvince != '')
                        ? DropdownButtonFormField(
                            decoration: InputDecoration(
                              errorStyle: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontFamily: 'Kanit',
                                fontSize: 10.0,
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.transparent,
                                ),
                              ),
                            ),
                            validator: (value) => value == '' || value == null
                                ? 'กรุณาเลือกจังหวัด'
                                : null,
                            hint: Text(
                              'ทั้งหมด',
                              style: TextStyle(
                                fontSize: 15.00,
                                fontFamily: 'Kanit',
                              ),
                            ),
                            value: _selectedProvince,
                            onTap: () {
                              FocusScope.of(context).unfocus();
                              TextEditingController().clear();
                            },
                            onChanged: (newValue) {
                              setState(() {
                                _selectedProvince = (newValue ?? "").toString();
                              });
                            },
                            items: _itemProvince.map((item) {
                              return DropdownMenuItem(
                                value: item['code'],
                                child: Text(
                                  item['title'],
                                  style: TextStyle(
                                    fontSize: 15.00,
                                    fontFamily: 'Kanit',
                                    color: Color(
                                      0xFF000000,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          )
                        : DropdownButtonFormField(
                            decoration: InputDecoration(
                              errorStyle: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontFamily: 'Kanit',
                                fontSize: 10.0,
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.transparent,
                                ),
                              ),
                            ),
                            validator: (value) => value == '' || value == null
                                ? 'กรุณาเลือกจังหวัด'
                                : null,
                            // hint: Text(
                            //   'จังหวัด',
                            //   style: TextStyle(
                            //     fontSize: 15.00,
                            //     fontFamily: 'Kanit',
                            //   ),
                            // ),
                            onChanged: (newValue) {
                              setState(() {
                                _selectedProvince = (newValue ?? "").toString();
                              });
                            },
                            items: _itemProvince.map((item) {
                              return DropdownMenuItem(
                                value: item['code'],
                                child: Text(
                                  item['title'],
                                  style: TextStyle(
                                    fontSize: 15.00,
                                    fontFamily: 'Kanit',
                                    color: Color(
                                      0xFF000000,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  buttonFull(
                    title: 'ค้นหา',
                    backgroundColor: Theme.of(context).primaryColor,
                    fontColor: Colors.white,
                    callback: () => {checkNameEmpty()},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  checkNameEmpty() {
    FocusScope.of(context).unfocus();
    if (textEditingController.text != '') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SchoolList(
            keySearch: textEditingController.text,
            province: _selectedProvince,
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialogFail(
            context,
            title: 'กรุณากรอกชื่อโรงเรียน',
            background: Colors.transparent,
          );
        },
      );
    }
  }
  // .end
}
