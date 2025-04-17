import 'package:flutter/material.dart';

import 'package:opec/pages/privilegeSpecial/list_content_horizontal_privilegeSpecial.dart';
import 'package:opec/pages/privilegeSpecial/privilege_special_form.dart';
import 'package:opec/pages/privilegeSpecial/privilege_special_list_vertical.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:opec/widget/tab_category.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:opec/shared/api_provider.dart';

class PrivilegeSpecialList extends StatefulWidget {
  PrivilegeSpecialList({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _PrivilegeSpecialList createState() => _PrivilegeSpecialList();
}

class _PrivilegeSpecialList extends State<PrivilegeSpecialList> {
  late PrivilegeSpecialListVertical gridView;
  final txtDescription = TextEditingController();
  bool hideSearch = true;
  bool isMain = true;
  bool isHighlight = false;
  String keySearch = '';
  String categorySelected = '';
  String categoryTitleSelected = '';

  int _limit = 0;
  Future<dynamic> futureModel = Future.value(null);
  List<dynamic> listData = [];
  List<dynamic> category = [];

  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _onLoading();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onLoading() async {
    category = await postDioCategoryWeMartNoAll(
      privilegeSpecialCategoryReadApi,
      {},
    );

    setState(() {
      _limit = _limit + 10;
      gridView = PrivilegeSpecialListVertical(
        model: postDio(privilegeSpecialReadApi, {
          'skip': 0,
          'limit': _limit,
          'category': categorySelected != '' ? categorySelected : '',
          "keySearch": keySearch != '' ? keySearch : '',
          // 'profileCode': profileCode
        }),
      );
    });
    // }

    await Future.delayed(Duration(milliseconds: 1000));

    _refreshController.loadComplete();
  }

  void goBack() async {
    Navigator.pop(context, false);
  }

  _buildList() {
    // return Container();
    return Expanded(
      child: SmartRefresher(
        enablePullDown: false,
        enablePullUp: true,
        footer: ClassicFooter(
          loadingText: ' ',
          canLoadingText: ' ',
          idleText: ' ',
          idleIcon: Icon(Icons.arrow_upward, color: Colors.transparent),
        ),
        controller: _refreshController,
        onLoading: _onLoading,
        child:
            keySearch == ''
                ? categorySelected == ''
                    ? ListView(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(), // 2nd
                      children: [
                        for (int i = 0; i < category.length; i++)
                          ListContentHorizontalPrivilegeSpecial(
                            code: category[i]['code'],
                            title: category[i]['title'],
                            model: postDio(privilegeSpecialReadApi, {
                              'skip': 0,
                              'limit': 10,
                              'category': category[i]['code'],
                            }),
                            navigationList: () {
                              setState(() {
                                keySearch = '';
                                isMain = false;
                                categorySelected = category[i]['code'];
                                categoryTitleSelected = category[i]['title'];
                              });
                            },
                            navigationForm: (String code, dynamic model) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => PrivilegeSpecialForm(
                                        code: code,
                                        model: model,
                                      ),
                                ),
                              );
                            },
                          ),
                      ],
                    )
                    : reloadList()
                : reloadList(),
      ),
    );
  }

  reloadList() {
    // print(categorySelected);
    // print(categoryTitleSelected);
    return gridView = PrivilegeSpecialListVertical(
      model: postDio(privilegeSpecialReadApi, {
        'skip': 0,
        'limit': _limit,
        'category': categorySelected != '' ? categorySelected : '',
        "keySearch": keySearch != '' ? keySearch : '',
        // 'profileCode': profileCode
      }),
      title: categoryTitleSelected,
    );
  }

  _buildHead() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2A9EB5), Color(0xFF4D4CCC), Color(0xFF8206C7)],
        ),
      ),
      padding: EdgeInsets.only(bottom: 10),
      child: Container(
        // height: 120,
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 10),
              Stack(
                alignment: Alignment.centerLeft,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      child: Image.asset(
                        "assets/images/back_arrow.png",
                        color: Colors.white,
                        width: 40,
                        height: 40,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    height: 40,
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 20,
                        color: Colors.white,
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              CategorySelector2(
                onChange: (String val, String valTitle) {
                  setState(() {
                    categorySelected = val;
                    categoryTitleSelected = valTitle;
                  });
                  _onLoading();
                },
                path: (privilegeSpecialCategoryReadApi),
                code: '',
              ),
            ],
          ),
        ),
      ),
    );
  }

  _buildFooter() {
    return Positioned(
      bottom: 0 + MediaQuery.of(context).padding.bottom,
      left: 0,
      right: 0,
      child: InkWell(
        onTap: () {
          // launch('https://www.google.com/');
        },
        child: Image.asset(
          'assets/images/download_wemart.png',
          // fit: BoxFit.fill,
        ),
      ),
    );
  }

  Widget _buildMain() {
    return Column(
      children: [
        _buildHead(),
        SizedBox(height: 20),
        _buildList(),
        SizedBox(height: 60),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        // Note: Sensitivity is integer used when you don't want to mess up vertical drag
        if (details.delta.dx > 10) {
          // Right Swipe
          Navigator.pop(context);
        } else if (details.delta.dx < -0) {
          //Left Swipe
        }
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF2A9EB5),
                  Color(0xFF4D4CCC),
                  Color(0xFF8206C7),
                ],
              ),
            ),
          ),
        ),
        backgroundColor: Colors.white,
        body: Stack(children: [_buildMain(), _buildFooter()]),
      ),
    );
  }
}
