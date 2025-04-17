import 'package:flutter/material.dart';
import 'package:opec/shared/api_provider.dart';
import 'package:opec/shared/extension.dart';
import 'package:opec/widget/loading.dart';

// ignore: must_be_immutable
class ListContentHorizontalPrivilege extends StatefulWidget {
  ListContentHorizontalPrivilege(
      {Key? key,
      required this.title,
      required this.code,
      required this.model,
      required this.navigationList,
      required this.navigationForm})
      : super(key: key);

  final String code;
  final String title;
  final Future<dynamic> model;
  final Function() navigationList;
  final Function(String, dynamic) navigationForm;

  @override
  _ListContentHorizontalPrivilege createState() =>
      _ListContentHorizontalPrivilege();
}

class _ListContentHorizontalPrivilege
    extends State<ListContentHorizontalPrivilege> {
  Future<dynamic> _futurePrivilege = Future.value(null);

  @override
  void initState() {
    _futurePrivilege = post('${privilegeApi}read',
        {'skip': 0, 'limit': 100, 'category': widget.code});
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: _futurePrivilege, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length > 0) {
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(left: 10.0),
                      margin: EdgeInsets.only(bottom: 5.0, top: 10.0),
                      child: Text(
                        widget.title,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                          fontFamily: 'Kanit',
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        widget.navigationList();
                      },
                      child: Container(
                        padding: EdgeInsets.only(right: 10.0),
                        margin: EdgeInsets.only(bottom: 5.0, top: 10.0),
                        child: Text(
                          'ดูทั้งหมด',
                          style: TextStyle(fontSize: 12.0, fontFamily: 'Kanit'),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 200,
                  color: Colors.transparent,
                  child: renderCard(
                    widget.title,
                    widget.model,
                    widget.navigationForm,
                  ),
                ),
                SizedBox(height: 10),
              ],
            );
          } else {
            return Container();
          }
        } else {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 10.0),
                    margin: EdgeInsets.only(bottom: 5.0),
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        // color: Color(0xFF9A1120),
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        fontFamily: 'Kanit',
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      widget.navigationList();
                    },
                    child: Container(
                        padding: EdgeInsets.only(right: 10.0),
                        margin: EdgeInsets.only(bottom: 5.0),
                        child: Image.asset(
                          'assets/images/double_arrow_right.png',
                          height: 15.0,
                        )),
                  ),
                ],
              ),
              Container(
                height: 190,
                color: Colors.transparent,
                child: renderCard(
                    widget.title, widget.model, widget.navigationForm),
              ),
            ],
          );
        }
      },
    );
  }
}

renderCard(String title, Future<dynamic> model, Function navigationForm) {
  return FutureBuilder<dynamic>(
    future: model, // function where you call your api
    builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
      // AsyncSnapshot<Your object type>

      if (snapshot.hasData) {
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: snapshot.data.length,
          itemBuilder: (context, index) {
            return myCard(index, snapshot.data.length, snapshot.data[index],
                context, navigationForm);
          },
        );
        // } else if (snapshot.hasError) {
        //   return Center(child: Text('Error: ${snapshot.error}'));
      } else {
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 10,
          itemBuilder: (context, index) {
            return ListContentHorizontalLoading();
          },
        );
      }
    },
  );
}

renderCardList(String title, Future<dynamic> model, Function navigationForm) {
  return ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: 10,
    itemBuilder: (context, index) {
      return ListContentHorizontalLoading();
    },
  );
}

myCard(int index, int lastIndex, dynamic model, BuildContext context,
    Function navigationForm) {
  return InkWell(
    onTap: () {
      navigationForm(model['code'], model);
    },
    child: Container(
      margin: index == 0
          ? EdgeInsets.only(left: 10.0, right: 5.0)
          : index == lastIndex - 1
              ? EdgeInsets.only(left: 5.0, right: 15.0)
              : EdgeInsets.symmetric(horizontal: 5.0),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 0,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
        borderRadius: new BorderRadius.circular(5),
        // color: Color(0xFF9A1120),
        color: Colors.transparent,
      ),
      width: 170.0,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            height: 150.0,
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
          Container(
            margin: EdgeInsets.only(top: 150.0),
            padding: EdgeInsets.all(5),
            alignment: Alignment.topLeft,
            decoration: BoxDecoration(
              borderRadius: new BorderRadius.only(
                bottomLeft: const Radius.circular(5.0),
                bottomRight: const Radius.circular(5.0),
              ),
              color: Theme.of(context).primaryColorLight,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    child: Text(
                      model['title'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: Color(0xFF6f0100),
                        fontFamily: 'Kanit',
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ),
                Container(
                  child: Text(
                    dateStringToDate(model['createDate']),
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 8,
                      fontFamily: 'Kanit',
                      color: Color(0xFF6f0100),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
