import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:opec/pages/auth/login.dart';
import 'package:opec/shared/api_provider.dart';
import 'package:opec/widget/blank.dart';

import '../../shared/extension.dart';

// ignore: must_be_immutable
class Profile extends StatefulWidget {
  Profile({Key? key, required this.model, required this.nav}) : super(key: key);

  Future<dynamic> model;
  final Function nav;
  final storage = FlutterSecureStorage();

  @override
  _Profile createState() => _Profile();
}

class _Profile extends State<Profile> {
  final storage = FlutterSecureStorage();
  List<dynamic> dataLv0 = [];
  final seen = Set<String>();
  List unique = [];

  @override
  void initState() {
    super.initState();
  }

  Future<dynamic> getDataLv0() async {
    final result = await postObjectData('organization/category/read', {
      'category': 'lv0',
    });

    if (result['status'] == 'S') {
      setState(() {
        dataLv0 = result['objectData'];
      });
    }
  }

  void goLogin() async {
    await storage.delete(key: 'dataUserLoginOPEC');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: widget.model, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        // AsyncSnapshot<Your object type>
        // data from refresh api
        if (snapshot.hasData) {
          if (snapshot.data.length > 0) {
            // if (widget.checkOrganization)

            //opecCategoryId
            //1:ครู 2:บุคลากรทางการศึกษา 3:บุคลากรทั่วไป
            // 6:ผู้บริหาร
            // 18:ผู้อำนวยการ 20:ผู้รับใบอนุญาต
            // 21:ผู้จัดการ
            if (((snapshot.data['opecCategoryId'] ?? "0") == "18") ||
                ((snapshot.data['opecCategoryId'] ?? "0") == "1") ||
                ((snapshot.data['opecCategoryId'] ?? "0") == "2") ||
                ((snapshot.data['opecCategoryId'] ?? "0") == "19"))
              return cardPersonnel(model: snapshot.data);
            else
              return cardGeneral(model: snapshot.data);
            // else {
            //   goLogin();
            //   return Container();
            // }
          } else {
            goLogin();
            return Container();
          }
        } else if (snapshot.hasError) {
          print('----- Profile hasError -----');
          goLogin();
          return BlankLoading();
        } else {
          print('----- Profile else ${snapshot.data} -----');
          return Container(
            height: 50,
            child: InkWell(
              onTap: () {
                logout(context);
                goLogin();
              },
              child: Center(child: Text('ออกจากระบบ')),
            ),
          );
        }
      },
    );
  }

  Widget cardPersonnel({dynamic model}) {
    var checkCard = model['opecCategoryId'] ?? '0';
    return Container(
      padding: EdgeInsets.all(15),
      alignment: Alignment.bottomCenter,
      decoration: BoxDecoration(
        image: DecorationImage(
          // image: AssetImage("assets/background/bg_profile_c.png"),
          image:
              checkCard == "18"
                  ? AssetImage("assets/background/bg_profile_a.png")
                  : checkCard == "1"
                  ? AssetImage("assets/background/bg_profile_b.png")
                  : checkCard == "2"
                  ? AssetImage("assets/background/bg_profile_c.png")
                  : checkCard == "19"
                  ? AssetImage("assets/background/bg_profile_a.png")
                  : AssetImage("assets/background/bg_profile_c.png"),
          fit: BoxFit.fill,
        ),
      ),
      // decoration: BoxDecoration(
      //   borderRadius: new BorderRadius.circular(15),
      //   color: Colors.amber,
      //   gradient: LinearGradient(
      //     colors: [
      //       Color(0xFFFFA62E),
      //       Color(0xFFEB542C),
      //       Color(0xFF981424),
      //     ],
      //   ),
      // ),
      child: InkWell(
        onTap: () => widget.nav(),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(
                          '${model['imageUrl']}' != '' ? 0.0 : 5.0,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          color: Colors.black12,
                        ),
                        height: 50,
                        width: 50,
                        child: GestureDetector(
                          onTap: () => widget.nav(),
                          child:
                              model['imageUrl'] != '' &&
                                      model['imageUrl'] != null
                                  ? CircleAvatar(
                                    backgroundColor: Colors.black,
                                    backgroundImage:
                                        model['imageUrl'] != null
                                            ? NetworkImage(model['imageUrl'])
                                            : null,
                                  )
                                  : Container(
                                    padding: EdgeInsets.all(10.0),
                                    child: Image.asset(
                                      'assets/images/user_not_found.png',
                                      color:
                                          Theme.of(context).primaryColorLight,
                                    ),
                                  ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => widget.nav(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                padding: EdgeInsets.only(
                                  left: 375 * 3 / 100,
                                  right: 375 * 1 / 100,
                                ),
                                child: Text(
                                  model['opecCategoryName'] ?? '',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Kanit',
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(
                                  left: 375 * 3 / 100,
                                  right: 375 * 1 / 100,
                                ),
                                child: Text(
                                  '${model['firstName']} ${model['lastName']}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Kanit',
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => widget.nav(),
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        // image: AssetImage("assets/logo/icons/bg_arrow_r_a.png"),
                        image:
                            checkCard == "18"
                                ? AssetImage(
                                  "assets/logo/icons/bg_arrow_r_a.png",
                                )
                                : checkCard == "1"
                                ? AssetImage(
                                  "assets/logo/icons/bg_arrow_r_b.png",
                                )
                                : checkCard == "2"
                                ? AssetImage(
                                  "assets/logo/icons/bg_arrow_r_c.png",
                                )
                                : AssetImage(
                                  "assets/logo/icons/bg_arrow_r_c.png",
                                ),
                        fit: BoxFit.cover,
                      ),
                    ),
                    padding: EdgeInsets.all(8.0),
                    margin: EdgeInsets.only(right: 10.0),
                    width: 33,
                    height: 34,
                  ),
                ),
              ],
            ),
            SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.all(0.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          color: Color(0XFFEEBA33),
                        ),
                        height: 40,
                        width: 40,
                        child: GestureDetector(
                          onTap: () => widget.nav(),
                          child: Container(
                            padding: EdgeInsets.all(10.0),
                            child: Image.asset(
                              'assets/images/logo_fund.png',
                              fit: BoxFit.fill,
                              //color: Theme.of(context).primaryColorLight,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => widget.nav(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                padding: EdgeInsets.only(
                                  left: 375 * 3 / 100,
                                  right: 375 * 1 / 100,
                                ),
                                child: Text(
                                  'ยอดสะสมกองทุน',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Kanit',
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                model['certificateStop'] != ""
                    ? Text(
                      'หมดอายุวันที่  ' +
                          dateStringToDateStringFormat(
                            model['certificateStop'],
                          ),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Kanit',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                    : Container(),
                // Expanded(
                //   child: Row(
                //     children: [
                //       Container(
                //         padding: EdgeInsets.all(0.0),
                //         decoration: BoxDecoration(
                //             borderRadius: BorderRadius.circular(40),
                //             color: Color(0XFFEEBA33)),
                //         height: 40,
                //         width: 40,
                //         child: GestureDetector(
                //           onTap: () => widget.nav(),
                //           child: Container(
                //             padding: EdgeInsets.all(10.0),
                //             child: Image.asset(
                //               'assets/images/logo_profile.png',
                //               fit: BoxFit.fill,
                //               //color: Theme.of(context).primaryColorLight,
                //             ),
                //           ),
                //         ),
                //       ),
                //       Expanded(
                //         child: GestureDetector(
                //           onTap: () => widget.nav(),
                //           child: Column(
                //             crossAxisAlignment: CrossAxisAlignment.start,
                //             mainAxisAlignment: MainAxisAlignment.center,
                //             mainAxisSize: MainAxisSize.max,
                //             children: [
                //               Container(
                //                 padding: EdgeInsets.only(
                //                   left: 375 * 3 / 100,
                //                   right: 375 * 1 / 100,
                //                 ),
                //                 child: Text(
                //                   'ต่ออายุใบอนุญาติ',
                //                   style: TextStyle(
                //                     color: Colors.white,
                //                     fontSize: 13.0,
                //                     fontWeight: FontWeight.bold,
                //                     fontFamily: 'Kanit',
                //                   ),
                //                   maxLines: 1,
                //                   overflow: TextOverflow.ellipsis,
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget cardGeneral({dynamic model}) {
    var checkCard = model['opecCategoryId'] ?? '0';
    return Container(
      padding: EdgeInsets.only(left: 15, top: 15, right: 15, bottom: 30),
      alignment: Alignment.bottomCenter,
      decoration: BoxDecoration(
        image: DecorationImage(
          // image: AssetImage("assets/background/bg_profile.png"),
          image:
              checkCard == '3'
                  ? AssetImage("assets/background/bg_profile_d.png")
                  : AssetImage("assets/background/bg_profile.png"),
          fit: BoxFit.cover,
        ),
      ),
      // decoration: BoxDecoration(
      //   borderRadius: new BorderRadius.circular(15),
      //   color: Colors.amber,
      //   gradient: LinearGradient(
      //     colors: [
      //       Color(0xFFF7F7F7),
      //       Color(0xFF707070),
      //     ],
      //   ),
      // ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(0.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    color: Colors.black12,
                  ),
                  height: 50,
                  width: 50,
                  child: GestureDetector(
                    onTap: () => widget.nav(),
                    child:
                        model['imageUrl'] != '' && model['imageUrl'] != null
                            ? CircleAvatar(
                              backgroundColor: Colors.black,
                              backgroundImage:
                                  model['imageUrl'] != null
                                      ? NetworkImage(model['imageUrl'])
                                      : null,
                            )
                            : Container(
                              padding: EdgeInsets.all(10.0),
                              child: Image.asset(
                                'assets/images/user_not_found.png',
                                color: Theme.of(context).primaryColorLight,
                              ),
                            ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => widget.nav(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          padding: EdgeInsets.only(
                            left: 375 * 3 / 100,
                            right: 375 * 1 / 100,
                          ),
                          child: Text(
                            model['opecCategoryName'] != '' &&
                                    model['opecCategoryName'] != null
                                ? model['opecCategoryName']
                                : 'บุคลากรทั่วไป',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Kanit',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(
                            left: 375 * 3 / 100,
                            right: 375 * 1 / 100,
                          ),
                          child: Text(
                            '${model['firstName']} ${model['lastName']}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Kanit',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => widget.nav(),
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  // image: AssetImage("assets/logo/icons/bg_arrow_r.png"),
                  image:
                      checkCard == '3'
                          ? AssetImage("assets/logo/icons/bg_arrow_r_d.png")
                          : AssetImage("assets/logo/icons/bg_arrow_r.png"),
                  fit: BoxFit.cover,
                ),
              ),
              // decoration: BoxDecoration(
              //   borderRadius: new BorderRadius.circular(8),
              //   color: Color(0xFFEEBA33),
              // ),
              margin: EdgeInsets.only(right: 10.0),
              width: 33,
              height: 34,
            ),
          ),
        ],
      ),
    );
  }
}
