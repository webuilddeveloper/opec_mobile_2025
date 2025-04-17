import 'package:flutter/material.dart';
import 'package:opec/shared/api_provider.dart';

class CategorySelector extends StatefulWidget {
  CategorySelector({Key? key, required this.model, required this.onChange})
    : super(key: key);

  //  final VoidCallback onTabCategory;
  final Function(String) onChange;
  final Future<dynamic> model;

  @override
  _CategorySelectorState createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  int selectedIndex = 0;

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
          return Container(
            height: 45.0,
            padding: EdgeInsets.only(left: 5.0, right: 5.0),
            margin: EdgeInsets.symmetric(horizontal: 10.0),
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
              color: Colors.white,
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    widget.onChange(snapshot.data[index]['code']);
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5.0,
                      vertical: 10.0,
                    ),
                    child: Text(
                      snapshot.data[index]['title'],
                      style: TextStyle(
                        color:
                            index == selectedIndex ? Colors.black : Colors.grey,
                        decoration:
                            index == selectedIndex
                                ? TextDecoration.underline
                                : null,
                        fontSize: 16.0,
                        fontWeight: FontWeight.normal,
                        letterSpacing: 1.2,
                        fontFamily: 'Kanit',
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        } else {
          return Container(
            height: 45.0,
            padding: EdgeInsets.only(left: 5.0, right: 5.0),
            margin: EdgeInsets.symmetric(horizontal: 10.0),
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
              color: Colors.white,
            ),
          );
        }
      },
    );
  }
}

class CategorySelector2 extends StatefulWidget {
  CategorySelector2({
    Key? key,
    required this.onChange,
    required this.path,
    this.code = '',
    this.skip,
    this.limit,
  }) : super(key: key);

  //  final VoidCallback onTabCategory;
  final Function(String, String) onChange;
  final String code;
  final String path;
  final dynamic skip;
  final dynamic limit;

  @override
  _CategorySelector2State createState() => _CategorySelector2State();
}

class _CategorySelector2State extends State<CategorySelector2> {
  dynamic res;
  String selectedIndex = '';
  String selectedTitleIndex = '';

  @override
  void initState() {
    res = postDioCategoryWeMart(widget.path, {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: res, // function where you call your api\
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        // AsyncSnapshot<Your object type>
        if (snapshot.hasData) {
          return Wrap(
            children:
                snapshot.data
                    .map<Widget>(
                      (c) => GestureDetector(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          widget.onChange(c['code'], c['title']);
                          setState(() {
                            selectedIndex = c['code'];
                            selectedTitleIndex = c['title'];
                          });
                        },
                        child: Container(
                          width: 85,
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(right: 10, bottom: 10),
                          decoration: new BoxDecoration(
                            borderRadius: new BorderRadius.circular(40),
                            color:
                                c['code'] == selectedIndex
                                    ? Color(0xFFFFFFFF).withOpacity(0.2)
                                    : Colors.transparent,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 5,
                          ),
                          child: Text(
                            c['title'],
                            style: TextStyle(
                              color: Color(0xFFFFFFFF),
                              // decoration: index == selectedIndex
                              //     ? TextDecoration.underline
                              //     : null,
                              fontSize: 14.0,
                              fontWeight: FontWeight.normal,
                              letterSpacing: 1.2,
                              fontFamily: 'Kanit',
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
          );
        } else {
          return Container(
            height: 25.0,
            // padding: EdgeInsets.only(left: 5.0, right: 5.0),
            // margin: EdgeInsets.symmetric(horizontal: 10.0),
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
              color: Colors.white,
            ),
          );
        }
      },
    );
  }
}
