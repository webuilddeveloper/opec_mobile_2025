import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:flutter/material.dart';

class CarouselBanner extends StatefulWidget {
  CarouselBanner(
      {Key? key, required this.model, required this.nav, this.height= 160, this.isHideRow = true})
      : super(key: key);

  final Future<dynamic> model;
  final Function(String, String, dynamic, String, String) nav;
  final double height;
  final bool isHideRow;
  @override
  _CarouselBanner createState() => _CarouselBanner();
}

class _CarouselBanner extends State<CarouselBanner> {
  final txtDescription = TextEditingController();
  int _current = 0;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    txtDescription.dispose();
    super.dispose();
  }

  final List<String> imgList = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return FutureBuilder<dynamic>(
      future: widget.model, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length > 0) {
            return Column(
              children: [
                InkWell(
                  onTap: () {
                    widget.nav(
                      snapshot.data[_current]['linkUrl'],
                      snapshot.data[_current]['action'],
                      snapshot.data[_current],
                      snapshot.data[_current]['code'],
                      '',
                    );
                  },
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: widget.height,
                      viewportFraction: 1.0,
                      enlargeCenterPage: false,
                      autoPlay: true,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _current = index;
                        });
                      },
                    ),
                    items: snapshot.data.map<Widget>(
                      (document) {
                        return new Container(
                          child: Center(
                            child: Image.network(
                              document['imageUrl'],
                              fit: BoxFit.fill,
                              height: widget.height,
                              width: (width * 100) / 100,
                            ),
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ),
                !widget.isHideRow
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: snapshot.data.map<Widget>((url) {
                          int index = snapshot.data.indexOf(url);
                          return Container(
                              width: _current == index ? 20.0 : 5.0,
                              height: 5.0,
                              margin: _current == index
                                  ? EdgeInsets.symmetric(
                                      vertical: 5.0, horizontal: 1.0)
                                  : EdgeInsets.symmetric(
                                      vertical: 5.0, horizontal: 2.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                // shape: BoxShape.circle,
                                color: _current == index
                                    ? Color(0xFF6F0100)
                                    : Color.fromRGBO(0, 0, 0, 0.4),
                              ));
                        }).toList(),
                      )
                    : Container(),
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
