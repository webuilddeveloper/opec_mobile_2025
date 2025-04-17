import 'package:flutter/material.dart';
import 'package:opec/shared/api_provider.dart';
import 'package:opec/shared/extension.dart';
import 'package:opec/widget/loading.dart';

// ignore: must_be_immutable
class ListContentHorizontalPrivilegeSpecial extends StatefulWidget {
  ListContentHorizontalPrivilegeSpecial(
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
  _ListContentHorizontalPrivilegeSpecial createState() =>
      _ListContentHorizontalPrivilegeSpecial();
}

class _ListContentHorizontalPrivilegeSpecial
    extends State<ListContentHorizontalPrivilegeSpecial> {
  Future<dynamic> _futureModel = Future.value(null);

  @override
  void initState() {
    _futureModel = postDio(privilegeSpecialReadApi,
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
      future: _futureModel, // function where you call your api
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
                          color: Color(0xFF1B6CA8),
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
                          'ทั้งหมด',
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'Kanit',
                            color: Color(0xFF707070),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 220,
                  color: Colors.transparent,
                  child: renderCard(
                    widget.title,
                    widget.model,
                    widget.navigationForm,
                  ),
                ),
              ],
            );
          } else {
            return Container();
          }
        } else {
          return Container();
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
            return myCard(
              index,
              snapshot.data.length,
              snapshot.data[index],
              context,
              navigationForm,
            );
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
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.grey.withOpacity(0.5),
        //     spreadRadius: 0,
        //     blurRadius: 7,
        //     offset: Offset(0, 3), // changes position of shadow
        //   ),
        // ],
        borderRadius: new BorderRadius.circular(5),
        color: Colors.white,
      ),
      width: 170.0,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            height: 165,
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
            margin: EdgeInsets.only(top: 160),
            padding: EdgeInsets.all(5),
            alignment: Alignment.topLeft,
            decoration: BoxDecoration(
              borderRadius: new BorderRadius.only(
                bottomLeft: const Radius.circular(5.0),
                bottomRight: const Radius.circular(5.0),
              ),
              color: Colors.transparent,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model['title'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    color: Color(0xFF000000),
                    fontFamily: 'Kanit',
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                Text(
                  model['dateEnd'] != 'Invalid date'
                      ? 'จนถึง ${dateStringToDateStringFormat(model['dateEnd'])}'
                      : 'จนถึง ไม่มีกำหนด',
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 8,
                    fontFamily: 'Kanit',
                    color: Color(0xFF000000),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
