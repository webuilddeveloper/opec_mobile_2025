import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:opec/widget/dialog.dart';
import 'package:opec/widget/header.dart';

import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class AboutUsForm extends StatefulWidget {
  AboutUsForm({Key? key, required this.model, required this.title}) : super(key: key);
  final String title;
  final Future<dynamic> model;

  @override
  _AboutUsForm createState() => _AboutUsForm();
}

class _AboutUsForm extends State<AboutUsForm> {
  // final Set<Marker> _markers = {};
  final Completer<GoogleMapController> _mapController = Completer();

  @override
  void initState() {
    super.initState();
  }

  void goBack() async {
    Navigator.pop(context, false);
  }

  void launchURLMap(String lat, String lng) async {
    String homeLat = lat;
    String homeLng = lng;

    final String googleMapslocationUrl =
        "https://www.google.com/maps/search/?api=1&query=" +
            homeLat +
            ',' +
            homeLng;

    final String encodedURl = Uri.encodeFull(googleMapslocationUrl);

    if (await canLaunch(encodedURl)) {
      await launch(encodedURl);
    } else {
      throw 'Could not launch $encodedURl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        // Note: Sensitivity is integer used when you don't want to mess up vertical drag
        if (details.delta.dx > 10) {
          // Right Swipe
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: header(context, goBack, title: 'เกี่ยวกับเรา'),
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (OverscrollIndicatorNotification overScroll) {
            return false;
          },
          child: FutureBuilder<dynamic>(
            future: widget.model, // function where you call your api
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              // AsyncSnapshot<Your object type>
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container();
              } else {
                if (snapshot.hasError) {
                  return dialogFail(context);
                } else if (snapshot.hasData) {
                  return hasData(snapshot.data);
                } else {
                  return hasDataNot();
                }
              }
            },
          ),
        ),
      ),
    );
  }

  hasData(model) {
    var lat = double.parse(model['latitude'] != '' ? model['latitude'] : 0.0);
    var lng = double.parse(model['longitude'] != '' ? model['longitude'] : 0.0);
    return Container(
      color: Colors.white,
      child: ListView(
        physics: ScrollPhysics(),
        shrinkWrap: true,
        // controller: _controller,
        children: [
          Stack(
            children: [
              Container(
                // padding: EdgeInsets.only(top: 50),
                // color: Colors.orange,
                child: Image.network(
                  model['imageBgUrl'],
                  height: 350.0,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                (loadingProgress.expectedTotalBytes ?? 0)
                            : null,
                      ),
                    );
                  },
                ),
              ),
              // SubHeader(th: "เกี่ยวกับเรา", en: "About Us"),
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(
                  top: 290.0,
                  left: 15.0,
                  right: 15.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 0,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                height: 120.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      // color: Colors.orange,
                      padding: EdgeInsets.all(5.0),
                      child: Image.network(
                        model['imageLogoUrl'],
                        height: 90,
                        width: 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(left: 10.0, right: 10.0),
                        child: Text(
                          model['title'],
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Kanit',
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
          SizedBox(
            height: 20.0,
          ),
          rowData(
            image: Image.asset(
              "assets/logo/icons/Group56.png",
            ),
            title: model['address'] ?? '',
          ),
          rowData(
            image: Image.asset(
              "assets/logo/icons/Path34.png",
            ),
            title: model['telephone'] ?? '',
            value: '${model['telephone']}',
            typeBtn: 'phone',
          ),
          rowData(
            image: Image.asset(
              "assets/logo/icons/Group62.png",
            ),
            title: model['email'] ?? '',
            value: '${model['email']}',
            typeBtn: 'email',
          ),
          rowData(
            image: Image.asset(
              "assets/logo/icons/Group369.png",
            ),
            title: model['site'] ?? '',
            value: '${model['site']}',
            typeBtn: 'link',
          ),
          rowData(
            image: Image.asset(
              "assets/logo/icons/Group356.png",
            ),
            title: model['titleFacebook'] ?? model['facebook'],
            value: '${model['facebook']}',
            typeBtn: 'link',
          ),
          rowData(
            image: Image.asset(
              "assets/logo/icons/youtube.png",
            ),
            title: model['titleYoutube'] ?? model['youtube'],
            value: '${model['youtube']}',
            typeBtn: 'link',
          ),
          // rowData(
          //   image: Image.asset(
          //     "assets/logo/socials/Group331.png",
          //   ),
          //   title: model['lineOfficial'] ?? '',
          //   value: '${model['lineOfficial']}',
          //   typeBtn: 'link',
          // ),
          SizedBox(
            height: 10.0,
          ),
          // googleMap(lat, lng),
          Container(
            height: MediaQuery.of(context).size.height * 0.5,
            width: double.infinity,
            child: googleMap(lat, lng),
          ),
          Container(
            padding: EdgeInsets.all(15),
            color: Colors.transparent,
            child: Material(
              elevation: 5.0,
              borderRadius: BorderRadius.circular(10.0),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(
                    color: Color(0xFFA9151D),
                  ),
                ),
                child: MaterialButton(
                  minWidth: MediaQuery.of(context).size.width,
                  onPressed: () {
                    launchURLMap(lat.toString(), lng.toString());
                  },
                  child: Text(
                    'ตำแหน่ง Google Map',
                    style: TextStyle(
                      color: Color(0xFFA9151D),
                      fontFamily: 'Kanit',
                      fontSize: 15.0,
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  hasDataNot() {
    return Container(
      color: Colors.white,
      child: ListView(
        physics: ScrollPhysics(),
        shrinkWrap: true,
        // controller: _controller,
        children: [
          Stack(
            children: [
              Container(
                padding: EdgeInsets.only(top: 50),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 0,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                // color: Colors.orange,
                child: Image.network('',
                    height: 350, width: double.infinity, fit: BoxFit.cover),
              ),
              // SubHeader(th: "เกี่ยวกับเรา", en: "About Us"),
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(top: 350.0, left: 15.0, right: 15.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 0,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                height: 120.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      // color: Colors.orange,
                      padding: EdgeInsets.symmetric(vertical: 17.0),
                      child: Image.asset(
                        "assets/logo/logo.png",
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(left: 10.0, right: 5.0),
                        child: Text(
                          'สหกรณ์ออมทรัพท์ตำรวจทางหลวง จำกัด',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'Kanit',
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
          SizedBox(
            height: 20.0,
          ),
          rowData(
            image: Image.asset(
              "assets/logo/icons/Group56.png",
            ),
            title: '-',
          ),
          rowData(
            image: Image.asset(
              "assets/logo/icons/Path34.png",
            ),
            title: '-',
          ),
          rowData(
            image: Image.asset(
              "assets/logo/icons/Group62.png",
            ),
            title: '-',
          ),
          rowData(
            image: Image.asset(
              "assets/logo/icons/Group369.png",
            ),
            title: '-',
          ),
          rowData(
            image: Image.asset(
              "assets/logo/icons/Group356.png",
            ),
            title: '-',
          ),
          rowData(
            image: Image.asset(
              "assets/logo/icons/youtube.png",
            ),
            title: '-',
          ),
          rowData(
            image: Image.asset(
              "assets/logo/socials/Group331.png",
            ),
            title: '-',
          ),
          SizedBox(
            height: 25.0,
          ),
          Container(
            height: 300,
            width: double.infinity,
            child: googleMap(13.8462512, 100.5234803),
          ),
        ],
      ),
    );
  }

  googleMap(double lat, double lng) {
    return GoogleMap(
      myLocationEnabled: true,
      compassEnabled: true,
      tiltGesturesEnabled: false,
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
        target: LatLng(lat, lng),
        zoom: 16,
      ),
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
        new Factory<OneSequenceGestureRecognizer>(
          () => new EagerGestureRecognizer(),
        ),
      ].toSet(),
      onMapCreated: (GoogleMapController controller) {
        _mapController.complete(controller);
      },
      // onTap: _handleTap,
      markers: <Marker>[
        Marker(
          markerId: MarkerId('1'),
          position: LatLng(lat, lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      ].toSet(),
    );
  }

  Widget rowData({
    required Image image,
    String title = '',
    String value = '',
    String typeBtn = '',
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.0),
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      child: Row(
        children: [
          Container(
            width: 30.0,
            height: 30.0,
            decoration: BoxDecoration(
                color: Color(0xFF6F0100),
                borderRadius: BorderRadius.circular(15)),
            child: Container(
              padding: EdgeInsets.all(5.0),
              child: image,
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => typeBtn != ''
                  ? typeBtn == 'email'
                      ? launch('mailto:' + value)
                      : typeBtn == 'phone'
                          ? launch('tel://' + value)
                          : typeBtn == 'link'
                              ? launch(value)
                              : null
                  : null,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 12,
                    color: Color(0xFF6F0100),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
