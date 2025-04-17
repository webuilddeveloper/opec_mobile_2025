import 'package:flutter/material.dart';
import 'package:opec/pages/fund/fund_form.dart';
import 'package:opec/shared/extension.dart';
import 'package:flutter/rendering.dart';
import 'package:opec/widget/blank.dart';

class FundListVertical extends StatefulWidget {
  FundListVertical({
    Key? key,
    required this.model,
    required this.url,
    this.urlComment = '',
    required this.urlGallery, required this.site,
  }) : super(key: key);

  final String site;
  final Future<dynamic> model;
  final String url;
  final String urlComment;
  final String urlGallery;

  @override
  _FundListVertical createState() => _FundListVertical();
}

class _FundListVertical extends State<FundListVertical> {
  @override
  void initState() {
    super.initState();
  }

  final List<String> items =
      List<String>.generate(10, (index) => "Item: ${++index}");

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
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
              alignment: Alignment.center,
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
                          builder: (context) => FundForm(
                            code: snapshot.data[index]['code'],
                            model: snapshot.data[index],
                          ),
                        ),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                // color: Color.fromRGBO(0, 0, 2, 1),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 0,
                                    blurRadius: 7,
                                    offset: Offset(
                                        0, 3), // changes position of shadow
                                  ),
                                ],
                              ),
                              margin: EdgeInsets.only(bottom: 5.0),
                              height: 100,
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Color(0xFFFFFFFF),
                                      borderRadius:
                                          new BorderRadius.circular(5.0),
                                    ),
                                    padding: EdgeInsets.all(5),
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              // margin: EdgeInsets.all(5),
                                              height: 90,
                                              width: 90,
                                              child: Container(
                                                child: Image.network(
                                                  '${snapshot.data[index]['imageUrl']}',
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              // color: Colors.red,
                                              width: width * 60 / 100,
                                              margin: EdgeInsets.fromLTRB(
                                                  8, 0, 0, 0),
                                              child: Text(
                                                '${snapshot.data[index]['title']}',
                                                style: TextStyle(
                                                  color: Color(0xFF000000),
                                                  fontFamily: 'Kanit',
                                                  fontSize: 15,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.fromLTRB(
                                                  8, 0, 0, 0),
                                              child: Text(
                                                dateStringToDate(snapshot
                                                    .data[index]['createDate']),
                                                style: TextStyle(
                                                  color: Color(0xFF000000),
                                                  fontFamily: 'Kanit',
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }
        } else {
          return blankListData(context);
        }
      },
    );
  }
}
