import 'dart:async';
import 'package:flutter/material.dart';
import 'package:opec/shared/api_provider.dart';
import 'package:opec/widget/dialog.dart';
import 'package:opec/widget/header.dart';

class OrganizationAddPage extends StatefulWidget {
  @override
  _OrganizationAddPageState createState() => _OrganizationAddPageState();
}

class _OrganizationAddPageState extends State<OrganizationAddPage> {
  Future<dynamic> futureLv0 = Future.value(null);
  Future<dynamic> futureLv1 = Future.value(null);
  Future<dynamic> futureLv2 = Future.value(null);
  Future<dynamic> futureLv3 = Future.value(null);
  Future<dynamic> futureLv4 = Future.value(null);

  String lv0 = '';
  String lv1 = '';
  String lv2 = '';
  String lv3 = '';
  String lv4 = '';

  @override
  void initState() {
    _callRead();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildScaffold();
  }

  _callRead() {
    futureLv0 = postDio('${server}organization/category/read', {
      'category': 'lv0',
    });
  }

  void goBack() async {
    Navigator.pop(context, false);
  }

  _buildScaffold() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: header(context, goBack, title: 'ประเภทสมาชิก'),
      body: _buildListView(),
    );
  }

  _buildListView() {
    return ListView(
      // shrinkWrap: true, // use it
      children: [
        SizedBox(height: 20),
        _widgetText(title: 'การสื่อสารระดับ 1'),
        _buildLv0(),
        SizedBox(height: 12),
        if (lv0 != '') _widgetText(title: 'การสื่อสารระดับ 2'),
        _buildLv1(),
        SizedBox(height: 12),
        if (lv1 != '') _widgetText(title: 'การสื่อสารระดับ 3'),
        _buildLv2(),
        SizedBox(height: 12),
        if (lv2 != '') _widgetText(title: 'การสื่อสารระดับ 4'),
        _buildLv3(),
        if (lv3 != '') _widgetText(title: 'การสื่อสารระดับ 5'),
        _buildLv4(),
        SizedBox(height: 12),
        Container(
          margin: EdgeInsets.only(top: 50, bottom: 50),
          padding: EdgeInsets.only(left: 50, right: 50),
          child: TextButton(
            child: Text('บันทึกข้อมูล'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white, // สีของข้อความ
              backgroundColor: Color(0xFF9A1120), // สีพื้นหลัง
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
                side: BorderSide(color: Color(0xFF9A1120)), // สีของขอบ
              ),
            ),
            onPressed: () {
              _callSave();
            },
          ),
        ),
      ],
    );
  }

  _buildLv0() {
    return FutureBuilder<dynamic>(
      future: futureLv0,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            shrinkWrap: true, // use it
            physics: ClampingScrollPhysics(),
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  setState(() {
                    lv1 = '';
                    lv2 = '';
                    lv3 = '';
                    lv4 = '';
                    lv0 =
                        lv0 == snapshot.data[index]['code']
                            ? ''
                            : snapshot.data[index]['code'];

                    futureLv1 = Future.value([]);
                    futureLv2 = Future.value([]);
                    futureLv3 = Future.value([]);
                    futureLv4 = Future.value([]);

                    if (lv0 != '')
                      futureLv1 = postDio(
                        '${server}organization/category/read',
                        {'category': 'lv1', 'lv0': lv0},
                      );
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(left: 50, right: 50, bottom: 5),
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color:
                        lv0 == snapshot.data[index]['code']
                            ? Color(0xFF9A1120)
                            : Colors.white,
                    border: Border.all(color: Color(0xFF9A1120)),
                  ),
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${snapshot.data[index]['title']}',
                          style: TextStyle(
                            color:
                                lv0 == snapshot.data[index]['code']
                                    ? Colors.white
                                    : Colors.black,
                          ),
                        ),
                        if (lv0 == snapshot.data[index]['code'])
                          Icon(Icons.check, color: Color(0xFFFFFFFF)),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Container(
              color: Colors.white,
              child: dialogFail(context, reloadApp: true),
            ),
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  _buildLv1() {
    return FutureBuilder<dynamic>(
      future: futureLv1,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            shrinkWrap: true, // use it
            physics: ClampingScrollPhysics(),
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  setState(() {
                    lv2 = '';
                    lv3 = '';
                    lv4 = '';
                    lv1 =
                        lv1 == snapshot.data[index]['code']
                            ? ''
                            : snapshot.data[index]['code'];
                    futureLv2 = Future.value([]);
                    futureLv3 = Future.value([]);
                    futureLv4 = Future.value([]);

                    if (lv1 != '')
                      futureLv2 = postDio(
                        '${server}organization/category/read',
                        {'category': 'lv2', 'lv1': lv1},
                      );
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(left: 50, right: 50, bottom: 5),
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color:
                        lv1 == snapshot.data[index]['code']
                            ? Color(0xFF9A1120)
                            : Colors.white,
                    border: Border.all(color: Color(0xFF9A1120)),
                  ),
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${snapshot.data[index]['title']}',
                          style: TextStyle(
                            color:
                                lv1 == snapshot.data[index]['code']
                                    ? Colors.white
                                    : Colors.black,
                          ),
                        ),
                        if (lv1 == snapshot.data[index]['code'])
                          Icon(Icons.check, color: Color(0xFFFFFFFF)),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Container(
              color: Colors.white,
              child: dialogFail(context, reloadApp: true),
            ),
          );
        } else {
          return Center(
            child: Container(
              child: lv0 != '' ? Text('Loading....') : Container(),
            ),
          );
        }
      },
    );
  }

  _buildLv2() {
    return FutureBuilder<dynamic>(
      future: futureLv2,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            shrinkWrap: true, // use it
            physics: ClampingScrollPhysics(),
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  setState(() {
                    lv3 = '';
                    lv4 = '';
                    lv2 =
                        lv2 == snapshot.data[index]['code']
                            ? ''
                            : snapshot.data[index]['code'];

                    futureLv3 = Future.value([]);
                    futureLv4 = Future.value([]);

                    if (lv2 != '')
                      futureLv3 = postDio(
                        '${server}organization/category/read',
                        {'category': 'lv3', 'lv2': lv2},
                      );
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(left: 50, right: 50, bottom: 5),
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color:
                        lv2 == snapshot.data[index]['code']
                            ? Color(0xFF9A1120)
                            : Colors.white,
                    border: Border.all(color: Color(0xFF9A1120)),
                  ),
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${snapshot.data[index]['title']}',
                          style: TextStyle(
                            color:
                                lv2 == snapshot.data[index]['code']
                                    ? Colors.white
                                    : Colors.black,
                          ),
                        ),
                        if (lv2 == snapshot.data[index]['code'])
                          Icon(Icons.check, color: Color(0xFFFFFFFF)),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Container(
              color: Colors.white,
              child: dialogFail(context, reloadApp: true),
            ),
          );
        } else {
          return Center(
            child: Container(
              child: lv1 != '' ? Text('Loading....') : Container(),
            ),
          );
        }
      },
    );
  }

  _buildLv3() {
    return FutureBuilder<dynamic>(
      future: futureLv3,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            shrinkWrap: true, // use it
            physics: ClampingScrollPhysics(),
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  setState(() {
                    lv4 = '';
                    lv3 =
                        lv3 == snapshot.data[index]['code']
                            ? ''
                            : snapshot.data[index]['code'];

                    futureLv4 = Future.value([]);
                    if (lv3 != '')
                      futureLv4 = postDio(
                        '${server}organization/category/read',
                        {'category': 'lv4', 'lv3': lv3},
                      );
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(left: 50, right: 50, bottom: 5),
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color:
                        lv3 == snapshot.data[index]['code']
                            ? Color(0xFF9A1120)
                            : Colors.white,
                    border: Border.all(color: Color(0xFF9A1120)),
                  ),
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${snapshot.data[index]['title']}',
                          style: TextStyle(
                            color:
                                lv3 == snapshot.data[index]['code']
                                    ? Colors.white
                                    : Colors.black,
                          ),
                        ),
                        if (lv3 == snapshot.data[index]['code'])
                          Icon(Icons.check, color: Color(0xFFFFFFFF)),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Container(
              color: Colors.white,
              child: dialogFail(context, reloadApp: true),
            ),
          );
        } else {
          return Center(
            child: Container(
              child: lv2 != '' ? Text('Loading....') : Container(),
            ),
          );
        }
      },
    );
  }

  _buildLv4() {
    return FutureBuilder<dynamic>(
      future: futureLv4,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            shrinkWrap: true, // use it
            physics: ClampingScrollPhysics(),
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  setState(() {
                    lv4 =
                        lv4 == snapshot.data[index]['code']
                            ? ''
                            : snapshot.data[index]['code'];
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(left: 50, right: 50, bottom: 5),
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color:
                        lv4 == snapshot.data[index]['code']
                            ? Color(0xFF9A1120)
                            : Colors.white,
                    border: Border.all(color: Color(0xFF9A1120)),
                  ),
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${snapshot.data[index]['title']}',
                          style: TextStyle(
                            color:
                                lv4 == snapshot.data[index]['code']
                                    ? Colors.white
                                    : Colors.black,
                          ),
                        ),
                        if (lv4 == snapshot.data[index]['code'])
                          Icon(Icons.check, color: Color(0xFFFFFFFF)),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Container(
              color: Colors.white,
              child: dialogFail(context, reloadApp: true),
            ),
          );
        } else {
          return Center(
            child: Container(
              child: lv3 != '' ? Text('Loading....') : Container(),
            ),
          );
        }
      },
    );
  }

  _callSave() async {
    if (lv0 == '') {
      dialog(
        context,
        title: 'ไม่สามารถบันทึกข้อมูลได้',
        description: 'กรุณาเลือกประเภทการสื่อสาร \nอย่างน้อย 1 รายการ',
        callBack: () {},
      );
    } else {
      await postDio('${server}m/v2/register/organization/create', {
        'lv0': lv0,
        'lv1': lv1,
        'lv2': lv2,
        'lv3': lv3,
        'lv4': lv4,
      });

      Navigator.pop(context, true);
    }
  }

  _widgetText({required String title}) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
    );
  }
}
