import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart' show Html;

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:opec/shared/api_provider.dart';
import 'package:opec/shared/extension.dart';
import 'package:opec/widget/gallery_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class ContentPoi extends StatefulWidget {
  ContentPoi({
    Key? key,
    required this.code,
    required this.url,
    this.model,
    required this.urlGallery,
    this.pathShare = '',
  }) : super(key: key);

  final String code;
  final String url;
  final dynamic model;
  final String urlGallery;
  final String pathShare;

  @override
  _ContentPoi createState() => _ContentPoi();
}

class _ContentPoi extends State<ContentPoi> {
  Future<dynamic> _futureModel = Future.value(null);

  String _urlShared = '';
  List urlImage = [];
  List<ImageProvider> urlImageProvider = [];
  late LocationData currentLocation;

  Completer<GoogleMapController> _mapController = Completer();

  @override
  void initState() {
    super.initState();
    _futureModel = post(widget.url, {
      'skip': 0,
      'limit': 1,
      'code': widget.code,
    });

    readGallery();
    sharedApi();
  }

  void launchURLMap(String lat, String lng) async {
    String homeLat = lat;
    String homeLng = lng;
    // currentLocation = await getCurrentLocation();

    final String googleMapslocationUrl =
        "https://www.google.com/maps/search/?api=1&query=" +
        homeLat +
        ',' +
        homeLng;
    // "https://www.google.co.th/maps/dir/"
    // + currentLocation.latitude.toString() + "," + currentLocation.longitude.toString() + "/"
    // + homeLat + "," + homeLng;

    final String encodedURl = Uri.encodeFull(googleMapslocationUrl);

    if (await canLaunch(encodedURl)) {
      await launch(encodedURl);
    } else {
      throw 'Could not launch $encodedURl';
    }
  }

  Future<LocationData?> getCurrentLocation() async {
    Location location = Location();
    try {
      return await location.getLocation();
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        // Permission denied
      }
      return null;
    }
  }

  Future<dynamic> readGallery() async {
    final result = await postObjectData(widget.urlGallery, {
      'code': widget.code,
    });

    if (result['status'] == 'S') {
      List data = [];
      List<ImageProvider> dataPro = [];

      for (var item in result['objectData']) {
        data.add(item['imageUrl']);
        if (item['imageUrl'] != null) {
          dataPro.add(NetworkImage(item['imageUrl']));
        }
      }
      setState(() {
        urlImage = data;
        urlImageProvider = dataPro;
      });
    }
  }

  Future<dynamic> sharedApi() async {
    await postConfigShare().then(
      (result) => {
        if (result['status'] == 'S')
          {
            setState(() {
              _urlShared = result['objectData']['description'];
            }),
          },
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: _futureModel, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        // AsyncSnapshot<Your object type>
        if (snapshot.hasData) {
          // setState(() {
          //   urlImage = [snapshot.data[0].imageUrl];
          // });
          return myContentPoi(
            snapshot.data[0],
          ); //   return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return myContentPoi(widget.model);
          // return myContentPoi(widget.model);
        }
      },
    );
  }

  myContentPoi(dynamic model) {
    List image = ['${model['imageUrl']}'];
    List<ImageProvider> imagePro = [];
    if (model['imageUrl'] != null) {
      imagePro.add(NetworkImage(model['imageUrl']));
    }
    return ListView(
      shrinkWrap: true, // 1st add
      physics: ClampingScrollPhysics(), // 2nd
      children: [
        Container(
          // width: 500.0,
          color: Color(0xFFFFFFF),
          child: GalleryView(
            imageUrl: [...image, ...urlImage],
            imageProvider: [...imagePro, ...urlImageProvider],
            typeImage: model['typeImage'],
          ),
        ),
        Container(
          // color: Colors.green,
          padding: EdgeInsets.only(right: 10.0, left: 10.0),
          margin: EdgeInsets.only(right: 50.0, top: 10.0),
          child: Text(
            '${model['title']}',
            style: TextStyle(
              fontSize: 18.0,
              fontFamily: 'Kanit',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10, left: 10),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage:
                        model['userList'][0]['imageUrl'] != null
                            ? NetworkImage(
                              '${model['userList'][0]['imageUrl']}',
                            )
                            : null,
                    // child: Image.network(
                    //     '${snapshot.data[0]['imageUrlCreateBy']}'),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          model['userList'] != null
                              ? '${model['userList'][0]['firstName']} ${model['userList'][0]['lastName']}'
                              : '${model['createBy']}',
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'Kanit',
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              dateStringToDate(model['createDate']) + ' | ',
                              style: TextStyle(
                                fontSize: 10,
                                fontFamily: 'Kanit',
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            Text(
                              'เข้าชม ' + '${model['view']}' + ' ครั้ง',
                              style: TextStyle(
                                fontSize: 10,
                                fontFamily: 'Kanit',
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 74.0,
              height: 31.0,
              // decoration: BoxDecoration(
              //     image: DecorationImage(
              //       image: AssetImage('assets/images/share.png'),
              //     )),
              alignment: Alignment.centerRight,
              child: TextButton(
                style: TextButton.styleFrom(padding: EdgeInsets.all(0.0)),
                onPressed: () {
                  final RenderBox box = context.findRenderObject() as RenderBox;
                  ;
                  Share.share(
                    _urlShared +
                        widget.pathShare +
                        '${model['code']}' +
                        ' ${model['title']}',
                    subject: '${model['title']}',
                    sharePositionOrigin:
                        box.localToGlobal(Offset.zero) & box.size,
                  );
                },
                child: Image.asset('assets/images/share.png'),
              ),
            ),
          ],
        ),
        Container(height: 10),
        Padding(
          padding: const EdgeInsets.only(right: 10, left: 10),
          // child: HtmlView(
          //   data: model['description'],
          //   scrollable:
          //       false, //false to use MarksownBody and true to use Marksown
          // ),
          child: Html(
            data: model['description'],
            onLinkTap:
                (url, attributes, element) => launchUrl(Uri.parse(url ?? "")),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10, left: 10),
          child: Text(
            'ที่ตั้ง',
            style: TextStyle(fontSize: 15, fontFamily: 'Kanit'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10, left: 10),
          child: Text(
            model['address'] != '' ? model['address'] : '-',
            style: TextStyle(fontSize: 10, fontFamily: 'Kanit'),
          ),
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
                border: Border.all(color: Color(0xFFA9151D)),
              ),
              child: MaterialButton(
                minWidth: MediaQuery.of(context).size.width,
                onPressed: () {
                  launchURLMap(model['latitude'], model['longitude']);
                },
                child: Text(
                  'ขอทราบเส้นทาง',
                  style: TextStyle(
                    color: Color(0xFFA9151D),
                    fontFamily: 'Kanit',
                    fontSize: 15.0,
                  ),
                ),
              ),
            ),
          ),
        ),
        Container(
          height: 250,
          width: double.infinity,
          child: googleMap(
            model['latitude'] != ''
                ? double.parse(model['latitude'])
                : 13.8462512,
            model['longitude'] != ''
                ? double.parse(model['longitude'])
                : 100.5234803,
          ),
        ),
      ],
    );
  }

  googleMap(double lat, double lng) {
    return GoogleMap(
      myLocationEnabled: true,
      compassEnabled: true,
      tiltGesturesEnabled: false,
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(target: LatLng(lat, lng), zoom: 16),
      gestureRecognizers:
          <Factory<OneSequenceGestureRecognizer>>{
            Factory<OneSequenceGestureRecognizer>(
              () => EagerGestureRecognizer(),
            ),
          },
      onMapCreated: (GoogleMapController controller) {
        _mapController.complete(controller);
      },
      // onTap: _handleTap,
      markers:
          <Marker>{
            Marker(
              markerId: MarkerId('1'),
              position: LatLng(lat, lng),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueRed,
              ),
            ),
          },
    );
  }
}
