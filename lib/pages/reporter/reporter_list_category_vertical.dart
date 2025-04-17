import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:opec/pages/reporter/reporter_form.dart';

// import 'reporter_list.dart';

class ReporterListCategoryVertical extends StatefulWidget {
  ReporterListCategoryVertical({
    Key? key,
    required this.model,
    required this.url,
  }) : super(key: key);

  final Future<dynamic> model;
  final String url;

  @override
  _ReporterListCategoryVertical createState() =>
      _ReporterListCategoryVertical();
}

class _ReporterListCategoryVertical
    extends State<ReporterListCategoryVertical> {
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
                          builder:
                              (context) => ReporterFormPage(
                                title: snapshot.data[index]['title'],
                                code: snapshot.data[index]['code'],
                                imageUrl: snapshot.data[index]['imageUrl'],
                              ),
                        ),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            // color: Color.fromRGBO(0, 0, 2, 1),
                          ),
                          margin: EdgeInsets.only(bottom: 5.0),
                          child: Column(
                            children: [
                              Container(
                                height: 80.0,
                                decoration: BoxDecoration(
                                  borderRadius: new BorderRadius.circular(5.0),
                                  color: Color(0xFFFFFFFF),
                                ),
                                padding: EdgeInsets.all(5.0),
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                '${snapshot.data[index]['imageUrl']}',
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          // color: Color(0xFF9A1120),
                                          alignment: Alignment.centerLeft,
                                          width: 60.0,
                                          height: 60.0,
                                          padding: EdgeInsets.all(5),
                                        ),
                                        Container(
                                          width:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.63,
                                          padding: EdgeInsets.all(5),
                                          // color: Colors.red,
                                          child: Text(
                                            '${snapshot.data[index]['title']}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 16,
                                              fontFamily: 'Kanit',
                                              color: Color.fromRGBO(
                                                0,
                                                0,
                                                0,
                                                0.6,
                                              ),
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
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
                            ],
                          ),
                        ),
                      ],
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

  Future<dynamic> downloadData() async {
    var body = json.encode({
      "permission": "all",
      "skip": 0,
      "limit": 999, // integer value type
    });
    var response = await http.post(
      Uri.parse(''),
      body: body,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
    );

    var data = json.decode(response.body);

    // int randomNumber = random.nextInt(10);
    // sleep(Duration(seconds: widget.sleep));
    return Future.value(data['objectData']);
    // return Future.value(response); // return your response
  }
}
