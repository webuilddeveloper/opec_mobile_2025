import 'dart:async';
import 'package:flutter/material.dart';
import 'package:opec/pages/profile/organization_add.dart';
import 'package:opec/shared/api_provider.dart';
import 'package:opec/widget/dialog.dart';
import 'package:opec/widget/header.dart';

class OrganizationPage extends StatefulWidget {
  @override
  _OrganizationPageState createState() => _OrganizationPageState();
}

class _OrganizationPageState extends State<OrganizationPage> {
  Future<dynamic> futureModel = Future.value(null);

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
    futureModel = postDio('${server}m/V2/register/organization/read', {});
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
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 12),
      child: ListView(
        shrinkWrap: true, // use it
        children: [
          _buildOrganization(),
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: _widgetTextTitileHeader(title: 'สถานะสมาชิก'),
          ),
          _buildDataApi(),
        ],
      ),
    );
  }

  _buildOrganization() {
    return FutureBuilder<dynamic>(
      future: futureModel,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return Container(
            child: InkWell(
              onTap: () async {
                final msg = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrganizationAddPage(),
                  ),
                );
                if (msg) {
                  setState(() {
                    _callRead();
                  });

                  dialog(
                    context,
                    title: 'เพิ่มประเภทสมาชิกเรียบร้อย',
                    description:
                        'เราจะทำการส่งเรื่องของท่าน \nเพื่อทำการยืนยันต่อไป',
                    callBack: () {},
                  );
                }
              },
              child: Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 12),
                child: Row(
                  children: [
                    Icon(Icons.add_circle_sharp, color: Color(0xFF9A1120)),
                    Text(
                      '  เพิ่มประเภทสมาชิก',
                      style: TextStyle(
                        color: Color(0xFF9A1120),
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
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
    );
  }

  _buildDataApi() {
    return FutureBuilder<dynamic>(
      future: futureModel,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            physics: ScrollPhysics(),
            shrinkWrap: true, // use it
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              return InkWell(
                child: Container(
                  margin: EdgeInsets.only(top: 5, bottom: 5),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color(0xFFFFE0CA),
                    border: Border.all(color: Color(0xFFFFE0CA)),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _widgetTextTitileHeader(
                              title: '${snapshot.data[index]['titleLv0']}',
                            ),
                            _widgetTextTitileDetail(
                              title:
                                  '${snapshot.data[index]['titleLv1']} ${snapshot.data[index]['titleLv2']}  ${snapshot.data[index]['titleLv3']} ${snapshot.data[index]['titleLv4']}',
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  color: Color(snapshot.data[index]['colorId']),
                                ),
                                _widgetTextTitileStatus(
                                  status: '${snapshot.data[index]['status']}',
                                  color: snapshot.data[index]['colorId'],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          InkWell(
                            onTap: () async {
                              dialog(
                                context,
                                title: 'ท่านต้องการยกเลิกประเภทสมาชิก?',
                                description:
                                    'เมื่อทำการยกเลิกแล้ว ท่านต้อง \nเลือกประเภทสมาชิกใหม่ ท่านแน่ใจใช่หรือไม่',
                                isYesNo: true,
                                callBack: () async {
                                  await postDio(
                                    '${server}m/v2/register/organization/delete',
                                    {
                                      'lv0': snapshot.data[index]['lv0'],
                                      'lv1': snapshot.data[index]['lv1'],
                                      'lv2': snapshot.data[index]['lv2'],
                                      'lv3': snapshot.data[index]['lv3'],
                                      'lv4': snapshot.data[index]['lv4'],
                                    },
                                  );
                                  setState(() {
                                    _callRead();
                                  });
                                },
                              );
                            },
                            child: Icon(
                              Icons.cancel,
                              color: Color(0xFFFF7514),
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ],
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
          return Center(child: Container());
        }
      },
    );
  }

  _widgetTextTitileHeader({required String title}) {
    return Text(
      title,
      textAlign: TextAlign.start,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
    );
  }

  _widgetTextTitileDetail({required String title}) {
    return Text(
      title,
      textAlign: TextAlign.start,
      style: TextStyle(fontSize: 14),
    );
  }

  _widgetTextTitileStatus({required String status, required int color}) {
    return Text(
      status,
      textAlign: TextAlign.start,
      style: TextStyle(fontSize: 15, color: Color(color)),
    );
  }
}
