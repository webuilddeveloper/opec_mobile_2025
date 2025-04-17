import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart' show Html;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:opec/shared/api_provider.dart';
import 'package:opec/shared/extension.dart';
import 'package:opec/widget/gallery_view.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class ContentReporter extends StatefulWidget {
  ContentReporter({
    Key? key,
    required this.code,
    required this.url,
    this.model,
    required this.urlGallery,
  }) : super(key: key);

  final String code;
  final String url;
  final dynamic model;
  final String urlGallery;

  @override
  _ContentReporter createState() => _ContentReporter();
}

class _ContentReporter extends State<ContentReporter> {
  Future<dynamic> _futureModel = Future.value(null);

  List urlImage = [];
  List<ImageProvider> urlImageProvider = [];

  final Completer<GoogleMapController> _mapController = Completer();

  @override
  void initState() {
    super.initState();
    _futureModel = post(widget.url, {
      'skip': 0,
      'limit': 1,
      'code': widget.code,
    });

    readGallery();
  }

  Future<dynamic> readGallery() async {
    final result = await postObjectData('m/Reporter/gallery/read', {
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
          return myContentReporter(
            snapshot.data[0],
          ); //   return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          // return Container();
          return myContentReporter(widget.model);
          // return myContentReporter(widget.model);
        }
      },
    );
  }

  myContentReporter(dynamic model) {
    List image = [];
    List<ImageProvider> imagePro = [];
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
                        model['imageUrlCreateBy'] != null
                            ? NetworkImage('${model['imageUrlCreateBy']}')
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
                          '${model['firstName']} ${model['lastName']}',
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
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
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
      // gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
      //   new Factory<OneSequenceGestureRecognizer>(
      //     () => new EagerGestureRecognizer(),
      //   ),
      // ].toSet(),
      onMapCreated: (GoogleMapController controller) {
        _mapController.complete(controller);
      },
      // onTap: _handleTap,
      markers: <Marker>{
        Marker(
          markerId: MarkerId('1'),
          position: LatLng(lat, lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      },
    );
  }
}
