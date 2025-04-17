import 'package:flutter/material.dart';
import 'package:opec/pages/privilege/privilege_form.dart';

class PrivilegeListVertical extends StatefulWidget {
  PrivilegeListVertical({Key? key, required this.model}) : super(key: key);

  final Future<dynamic> model;

  @override
  _PrivilegeListVertical createState() => _PrivilegeListVertical();
}

class _PrivilegeListVertical extends State<PrivilegeListVertical> {
  @override
  void initState() {
    super.initState();
  }

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
              padding: EdgeInsets.all(10.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                ),
                physics: ClampingScrollPhysics(),
                shrinkWrap: true,
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  // return Container(height: 300.0,color: Colors.red,margin: EdgeInsets.all(5.0),);
                  return myCard(index, snapshot.data.length,
                      snapshot.data[index], context);
                  // return demoItem(snapshot.data[index]);
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

  demoItem(dynamic model) {
    return Column(
      children: <Widget>[
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PrivilegeForm(
                    code: model['code'],
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(1),
              decoration: new BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 0,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
                borderRadius: new BorderRadius.circular(6.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.network(
                  model['imageUrl'],
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
  }

  myCard(int index, int lastIndex, dynamic model, BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PrivilegeForm(code: model['code'], model: model),
          ),
        );
      },
      child: Container(
        margin: index % 2 == 0
            ? EdgeInsets.only(bottom: 5.0, right: 5.0)
            : EdgeInsets.only(bottom: 5.0, left: 5.0),
        decoration: BoxDecoration(
          borderRadius: new BorderRadius.circular(5),
          color: Color(0xFFFFFFFF),
        ),
        child: Column(
          // alignment: Alignment.topCenter,
          children: [
            Expanded(
              child: Container(
                height: 157.0,
                decoration: BoxDecoration(
                  borderRadius: new BorderRadius.only(
                    topLeft: const Radius.circular(5.0),
                    topRight: const Radius.circular(5.0),
                  ),
                  color: Colors.white.withAlpha(220),
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: NetworkImage(model['imageUrl']),
                  ),
                ),
              ),
            ),
            Container(
              // margin: EdgeInsets.only(top: 157.0),
              padding: EdgeInsets.all(5),
              alignment: Alignment.topLeft,
              height: 40,
              decoration: BoxDecoration(
                  borderRadius: new BorderRadius.only(
                    bottomLeft: const Radius.circular(5.0),
                    bottomRight: const Radius.circular(5.0),
                  ),
                  color: Colors.black.withAlpha(10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model['title'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      color: Color(0xFF9A1120),
                      fontFamily: 'Kanit',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Text(
                  //   dateStringToDate(model['createDate']),
                  //   style: TextStyle(
                  //     fontWeight: FontWeight.normal,
                  //     fontSize: 8,
                  //     fontFamily: 'Kanit',
                  //     color: Color(0xFF9A1120),
                  //   ),
                  //   overflow: TextOverflow.ellipsis,
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
