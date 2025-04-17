import 'package:flutter/material.dart';
import 'package:opec/widget/blank.dart';

import 'package:url_launcher/url_launcher.dart';

class FileOnlineListVertical extends StatefulWidget {
  FileOnlineListVertical({
    Key? key,
    required this.model,
    required this.title,
    required this.url,
  }) : super(key: key);

  final Future<dynamic> model;
  final String title;
  final String url;

  @override
  _FileOnlineListVertical createState() => _FileOnlineListVertical();
}

class _FileOnlineListVertical extends State<FileOnlineListVertical> {
  @override
  void initState() {
    super.initState();
  }

  final List<String> items =
      List<String>.generate(10, (index) => "Item: ${++index}");

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: widget.model, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length == 0) {
            return Container(
              alignment: Alignment.center,
              height: 200,
              child: Text(
                'ไม่พบข้อมูล',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Kanit',
                  color: Color.fromRGBO(0, 0, 0, 0.6),
                ),
              ),
            );
          } else {
            return Container(
              // color: Colors.transparent,
              alignment: Alignment.center,
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: ListView.builder(
                physics: ScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        margin: EdgeInsets.only(bottom: 5.0),
                        // width: 600,
                        child: Column(
                          children: [
                            Container(
                              constraints: BoxConstraints(
                                minHeight: 80,
                                minWidth: double.infinity,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: new BorderRadius.circular(5.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 0,
                                    blurRadius: 7,
                                    offset: Offset(
                                        0, 3), // changes position of shadow
                                  ),
                                ],
                                color: Color(0xFFFFFFFF),
                              ),
                              padding: EdgeInsets.all(10.0),
                              alignment: Alignment.centerLeft,
                              child: InkWell(
                                onTap: () {
                                  launch(
                                      '${snapshot.data[index]['linkUrl']}');
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.55,
                                      padding: EdgeInsets.only(left: 10.0),
                                      // color: Colors.red,
                                      child: Text(
                                        '${snapshot.data[index]['title']}',
                                        style: TextStyle(
                                            // fontWeight: FontWeight.normal,
                                            fontSize: 15,
                                            fontFamily: 'Kanit',
                                            color: Color(0xFF6F0100)),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      // color: Colors.yellow,
                                      child: Icon(
                                        Icons.keyboard_arrow_right,
                                        color: Color.fromRGBO(0, 0, 0, 0.5),
                                        size: 40.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          }
        } else {
          return BlankLoading();
        }
      },
    );
  }
}
