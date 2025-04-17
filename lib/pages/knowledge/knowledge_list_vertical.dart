import 'package:flutter/material.dart';
import 'package:opec/pages/knowledge/knowledge_form.dart';

class KnowledgeListVertical extends StatefulWidget {
  KnowledgeListVertical({Key? key, required this.model}) : super(key: key);

  final Future<dynamic> model;

  @override
  _KnowledgeListVertical createState() => _KnowledgeListVertical();
}

class _KnowledgeListVertical extends State<KnowledgeListVertical> {
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
        // AsyncSnapshot<Your object type>

        if (snapshot.hasData) {
          if (snapshot.data.length == 0) {
            return Container(
              height: 200,
              alignment: Alignment.center,
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
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: MediaQuery.of(context).size.width /
                      (MediaQuery.of(context).size.height -
                          (MediaQuery.of(context).size.height * 25 / 100)),
                ),
                physics: ClampingScrollPhysics(),
                shrinkWrap: true,
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: <Widget>[
                      Container(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => KnowledgeForm(
                                  code: snapshot.data[index]['code'],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 5.0,
                              vertical: 0.0,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Image.network(
                                snapshot.data[index]['imageUrl'],
                                //fit: BoxFit.cover,
                                fit: snapshot.data[index]['typeImage'] ==
                                        'cover'
                                    ? BoxFit.cover
                                    : snapshot.data[index]['typeImage'] ==
                                            'fill'
                                        ? BoxFit.fill
                                        : snapshot.data[index]['typeImage'] ==
                                                'contain'
                                            ? BoxFit.contain
                                            : BoxFit.cover,
                                height: MediaQuery.of(context).size.height *
                                    30 /
                                    100,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        child: Center(
                          child: Image.asset('assets/images/bar.png'),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          }
        } else {
          return Container(
            height: 800,
            padding: EdgeInsets.only(left: 5.0, right: 5.0),
            child: GridView.count(
              crossAxisCount: 2,
              children: List.generate(
                10,
                (index) {
                  return Column(
                    children: <Widget>[
                      Expanded(
                        child: GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.only(left: 30, right: 30),
                            child: Container(
                              decoration: new BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 0,
                                    blurRadius: 7,
                                    offset: Offset(
                                        0, 3), // changes position of shadow
                                  ),
                                ],
                                borderRadius: new BorderRadius.circular(6.0),
                              ),
                            ),
                            // height: 205,
                          ),
                        ),
                      ),
                      Container(
                        child: Center(
                          child: Image.asset('assets/images/bar.png'),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        }
      },
    );
  }
}
