import 'package:flutter/material.dart';
import 'package:opec/pages/reporter/reporter_history_form.dart';
import 'package:opec/shared/extension.dart';
import 'package:flutter/rendering.dart';

class ReporterHistoryListVertical extends StatefulWidget {
  ReporterHistoryListVertical({
    Key? key,
    required this.model,
    required this.url,
    this.urlComment = '',
    required this.urlGallery,
  }) : super(key: key);

  final Future<dynamic> model;
  final String url;
  final String urlComment;
  final String urlGallery;

  @override
  _ReporterHistoryListVertical createState() => _ReporterHistoryListVertical();
}

class _ReporterHistoryListVertical extends State<ReporterHistoryListVertical> {
  @override
  void initState() {
    super.initState();
  }

  final List<String> items =
      List<String>.generate(10, (index) => "Item: ${++index}");

  checkImageAvatar(String? img) {
    return CircleAvatar(
      backgroundColor: Colors.white,
      backgroundImage: img != null
          ? NetworkImage(
              img,
            )
          : null,
    );
  }

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
              color: Colors.transparent,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: ListView.builder(
                physics: ScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReporterHistortForm(
                            url: widget.url,
                            code: snapshot.data[index]['code'],
                            model: snapshot.data[index],
                            urlComment: widget.urlComment,
                            urlGallery: widget.urlGallery,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 0,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      margin: EdgeInsets.only(bottom: 2.0, top: 5.0),
                      width: MediaQuery.of(context).size.width,
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Color(0xFFFFFFFF),
                        ),
                        padding: EdgeInsets.all(5.0),
                        alignment: Alignment.centerLeft,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 50,
                              child: Text(
                                '${snapshot.data[index]['title']}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Kanit',
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 5.0),
                              child: Text(
                                'วันที่ ' +
                                    dateStringToDate(
                                        snapshot.data[index]['createDate']),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Kanit',
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                            Text(
                              snapshot.data[index]['status2'] == "N"
                                  ? 'รอดำเนินการ'
                                  : snapshot.data[index]['status2'] == "A"
                                      ? 'กำลังดำเนินการ'
                                      : snapshot.data[index]['status2'] == "C"
                                          ? 'ดำเนินการแล้ว'
                                          : snapshot.data[index]['status2'] ==
                                                  "D"
                                              ? 'ยกเลิกการดำเนินการ'
                                              : "",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontFamily: 'Kanit',
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.normal,
                                  color: snapshot.data[index]['status2'] == "N"
                                      ? Color(0xFF005C9E)
                                      : snapshot.data[index]['status2'] == "A"
                                          ? Color(0xFFFF8900)
                                          : snapshot.data[index]['status2'] ==
                                                  "C"
                                              ? Color(0xFF1AD14C)
                                              : Color(0xFFF23A36)),
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }
        } else {
          return Container();
        }
      },
    );
  }
}
