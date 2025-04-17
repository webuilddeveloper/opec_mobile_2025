import 'package:flutter/material.dart';
import 'package:opec/widget/blank.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactListVertical extends StatefulWidget {
  ContactListVertical({
    Key? key,
    required this.model,
  }) : super(key: key);

  final Future<dynamic> model;

  @override
  _ContactListVertical createState() => _ContactListVertical();
}

class _ContactListVertical extends State<ContactListVertical> {
  @override
  void initState() {
    super.initState();
  }

  final List<String> items =
      List<String>.generate(10, (index) => "Item: ${++index}");

  _makePhoneCall(String url) async {
    url = 'tel:' + url;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
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
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          image: DecorationImage(
                                            image: NetworkImage(
                                                '${snapshot.data[index]['imageUrl']}'),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        // color: Color(0xFF9A1120),
                                        alignment: Alignment.centerLeft,
                                        width: 55.0,
                                        height: 55.0,
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.55,
                                            padding:
                                                EdgeInsets.only(left: 10.0),
                                            // color: Colors.red,
                                            child: Text(
                                              '${snapshot.data[index]['phone']}',
                                              style: TextStyle(
                                                  // fontWeight: FontWeight.normal,
                                                  fontSize: 15,
                                                  fontFamily: 'Kanit',
                                                  color: Color(0xFF6F0100)),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.55,
                                            padding:
                                                EdgeInsets.only(left: 10.0),
                                            // color: Colors.red,
                                            child: Text(
                                              '${snapshot.data[index]['title']}',
                                              style: TextStyle(
                                                // fontWeight: FontWeight.normal,
                                                fontSize: 12.0,
                                                fontFamily: 'Kanit',
                                                color: Color.fromRGBO(
                                                    0, 0, 0, 0.6),
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  InkWell(
                                    onTap: () {
                                      _makePhoneCall(
                                          snapshot.data[index]['phone']);
                                    },
                                    child: Container(
                                      width: 50.00,
                                      height: 50.00,
                                      // color: Color(0xFFA12624),
                                      padding: EdgeInsets.all(10.00),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(27),
                                        color: Color(0xFFA12624),
                                      ),
                                      child: Image.asset(
                                          'assets/images/phone.png'),
                                    ),
                                  ),
                                ],
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
