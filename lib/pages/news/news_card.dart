import 'package:flutter/material.dart';
import 'package:opec/pages/news/news_form.dart';
import 'package:opec/shared/extension.dart';
import 'package:opec/widget/blank.dart';

import '../../shared/api_provider.dart';

newsCard(
  BuildContext context,
  dynamic model, {
  String username = "",
  String category = "",
}) {
  // print('---------------${model}');
  return Stack(
    children: <Widget>[
      Container(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        child: InkWell(
          onTap: () {
            if ((model['noti'] ?? "") != "") {
              postDio('${notificationApi}update', {
                'username': username,
                'category': category,
                "reference": '${model['noti']}',
                // "reference": '${model['noti']}',
                // "page": 'eventPage',
              });
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => NewsForm(code: model['code'], model: model),
              ),
            ).then((value) => model['noti'] = "");
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
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 0,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    margin: EdgeInsets.only(bottom: 5.0),
                    // height: 334,
                    width: 600,
                    child: Column(
                      children: [
                        Container(
                          height: 55,
                          decoration: BoxDecoration(
                            color: Color(0xFFEEBA33),
                            borderRadius: new BorderRadius.only(
                              topLeft: const Radius.circular(5.0),
                              topRight: const Radius.circular(5.0),
                            ),
                          ),
                          padding: EdgeInsets.all(5),
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    margin: EdgeInsets.all(3),
                                    height: 35,
                                    width: 35,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.white,
                                      backgroundImage:
                                          model['userList'][0]['imageUrl'] !=
                                                  null
                                              ? NetworkImage(
                                                model['userList'][0]['imageUrl'],
                                              )
                                              : null,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: EdgeInsets.fromLTRB(8, 0, 0, 0),
                                    child: Text(
                                      '${model['userList'][0]['firstName']} ${model['userList'][0]['lastName']}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Kanit',
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.fromLTRB(8, 0, 0, 0),
                                    child: Text(
                                      'วันที่ ' +
                                          dateStringToDate(model['createDate']),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Kanit',
                                        fontSize: 8.0,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          color: Colors.white,
                          constraints: BoxConstraints(
                            minHeight: 200,
                            maxHeight: 200,
                            minWidth: double.infinity,
                          ),
                          child:
                              model['imageUrl'] != null
                                  ? Image.network(
                                    '${model['imageUrl']}',
                                    width:
                                        MediaQuery.of(context).size.width /
                                        3.035,
                                    height:
                                        MediaQuery.of(context).size.width /
                                        3.035,
                                    fit:
                                        model['typeImageUrl'] == 'cover'
                                            ? BoxFit.cover
                                            : model['typeImageUrl'] == 'fill'
                                            ? BoxFit.fill
                                            : model['typeImageUrl'] == 'contain'
                                            ? BoxFit.contain
                                            : BoxFit.contain,
                                  )
                                  : BlankLoading(height: 200),
                        ),
                        Container(
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: new BorderRadius.only(
                              bottomLeft: const Radius.circular(5.0),
                              bottomRight: const Radius.circular(5.0),
                            ),
                            color: Color(0xFFFFFFFF),
                          ),
                          padding: EdgeInsets.all(5.0),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${model['title']}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: 15.0,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      Positioned(
        top: 5,
        right: 15,
        child:
            (model['noti'] ?? "") != ""
                ? Container(
                  alignment: Alignment.center,
                  width: 30,
                  // height: 90.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.red,
                  ),
                  child: Text(
                    "N",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                )
                : Container(),
      ),
    ],
  );
}
