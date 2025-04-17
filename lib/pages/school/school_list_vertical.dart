import 'package:flutter/material.dart';
import 'package:opec/pages/school/school_form.dart';
import 'package:opec/widget/blank.dart';

class SchoolListVertical extends StatefulWidget {
  SchoolListVertical({Key? key, required this.model}) : super(key: key);

  final Future<dynamic> model;

  @override
  _SchoolListVertical createState() => _SchoolListVertical();
}

class _SchoolListVertical extends State<SchoolListVertical> {
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
          if (snapshot.data['schoolOpec'].length == 0) {
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
            return card(snapshot.data['schoolOpec']);
          }
        } else if (snapshot.hasError) {
          return Container(
            alignment: Alignment.center,
            height: 200,
            width: double.infinity,
            child: Text(
              'Network ขัดข้อง',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Kanit',
                color: Color.fromRGBO(0, 0, 0, 0.6),
              ),
            ),
          );
        } else {
          return blankListData(context);
        }
      },
    );
  }

  card(dynamic model) {
    double width = MediaQuery.of(context).size.width;
    return Container(
      color: Colors.transparent,
      alignment: Alignment.center,
      padding: EdgeInsets.only(left: 10.0, right: 10.0),
      child: ListView.builder(
        physics: ScrollPhysics(),
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: model.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => SchoolForm(
                        // code: model[index]['code'],
                        model: model[index],
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
                        color: Colors.white,
                      ),
                      margin: EdgeInsets.only(bottom: 5.0),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Color(0xFFFFFFFF),
                              borderRadius: new BorderRadius.circular(5.0),
                            ),
                            padding: EdgeInsets.all(5),
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(width: 10.0),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      // color: Colors.red,
                                      width: width * 60 / 100,
                                      margin: EdgeInsets.only(left: 8),
                                      child: Text(
                                        '${model[index]['schoolName']}',
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontFamily: 'Kanit',
                                          fontSize: 15,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    ),
                                    SizedBox(height: 5.0),
                                    _rowTextdetail(
                                      'จังหวัด',
                                      model[index]['province'],
                                    ),
                                    _rowTextdetail(
                                      'ประเภทหลักสูตร:',
                                      model[index]['courseType'],
                                    ),
                                    _rowTextdetail(
                                      'ชื่อหลักสูตร:',
                                      model[index]['courseName'],
                                    ),
                                    SizedBox(height: 5),
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

  _rowTextdetail(txthead, txtdetail) {
    return Row(
      children: [
        Container(
          margin: EdgeInsets.only(left: 8),
          child: Text(
            txthead,
            style: TextStyle(
              color: Color(0xFF000000),
              fontFamily: 'Kanit',
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 8),
          child: Text(
            txtdetail,
            style: TextStyle(
              color: Color(0xFF9A1120),
              fontFamily: 'Kanit',
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
