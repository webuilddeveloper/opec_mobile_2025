import 'package:flutter/material.dart';
import 'package:opec/pages/poll/poll_form.dart';
import 'package:opec/shared/extension.dart';
import 'package:opec/widget/blank.dart';
import 'package:opec/widget/dialog.dart';

class PollListVertical extends StatefulWidget {
  PollListVertical({
    Key? key,
    required this.model,
    this.title = '',
    required this.url,
    this.titleHome = '',
    required this.callBack,
  }) : super(key: key);

  final Future<dynamic> model;
  final String title;
  final String url;
  final String titleHome;
  final Function callBack;

  @override
  _PollListVertical createState() => _PollListVertical();
}

class _PollListVertical extends State<PollListVertical> {
  @override
  void initState() {
    super.initState();
  }

  final List<String> items = List<String>.generate(
    10,
    (index) => "Item: ${++index}",
  );

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
                      snapshot.data[index]['status2']
                          ? toastFail(context, text: 'คุณตอบแบบสอบถามนี้แล้ว')
                          : Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => PollForm(
                                    code: snapshot.data[index]['code'],
                                    model: snapshot.data[index],
                                    titleHome: widget.titleHome,
                                  ),
                            ),
                          );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Column(
                        //   children: [
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
                                  0,
                                  3,
                                ), // changes position of shadow
                              ),
                            ],
                          ),
                          margin: EdgeInsets.only(bottom: 5.0),
                          // height: 334,
                          // width: 600,
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color:
                                      snapshot.data[index]['status2']
                                          ? Colors.grey[300]
                                          : Colors.white,
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                padding: EdgeInsets.all(5),
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                              // loadingBuilder: (BuildContext context,
                                              //     Widget child,
                                              //     ImageChunkEvent loadingProgress) {
                                              //   if (loadingProgress == null)
                                              //     return child;
                                              //   return Container(
                                              //     color: Colors.white,
                                              //     height: 200,
                                              //     width: 600,
                                              //     child: loadingProgress
                                              //         .expectedTotalBytes !=
                                              //         null
                                              //         ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes : BlankLoading(width: 600.0,height: 200.0,),
                                              //   );
                                              // },
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
                                            8,
                                            0,
                                            0,
                                            0,
                                          ),
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
                                            8,
                                            0,
                                            0,
                                            0,
                                          ),
                                          child: Text(
                                            dateStringToDate(
                                              snapshot
                                                  .data[index]['createDate'],
                                            ),
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
                      //   ),
                      // ],
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
