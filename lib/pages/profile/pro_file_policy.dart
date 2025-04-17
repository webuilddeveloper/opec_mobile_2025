import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:opec/shared/api_provider.dart';
import 'package:opec/widget/dialog.dart';
import 'package:opec/widget/header.dart';
import 'package:url_launcher/url_launcher.dart';

class ProFilePolicyPage extends StatefulWidget {
  @override
  _ProFilePolicyPageState createState() => _ProFilePolicyPageState();
}

class _ProFilePolicyPageState extends State<ProFilePolicyPage> {
  Future<dynamic> futureModel = Future.value(null);
  ScrollController scrollController = ScrollController();
  @override
  void initState() {
    _callRead();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildPolicy();
  }

  _callRead() {
    futureModel = postDio('${server}m/policy/readAccept', {
      "category": "application",
    });
  }

  void goBack() async {
    Navigator.pop(context, false);
  }

  _buildPolicy() {
    return Scaffold(
      appBar: header(context, goBack, title: 'นโยบาย'),
      backgroundColor: Colors.white,
      body: FutureBuilder<dynamic>(
        future: futureModel,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              child: SingleChildScrollView(
                controller: scrollController,
                physics: ClampingScrollPhysics(),
                // padding: const EdgeInsets.all(10.0),
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[card(snapshot.data)],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Container(
                color: Colors.white,
                child: dialogFail(context, reloadApp: true),
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            // return Center(
            //   child: Positioned.fill(
            //       child: Container(
            //         color: Colors.black.withOpacity(0.1),
            //         alignment: Alignment.center,
            //         child: Container(
            //           height: 80,
            //           width: 80,
            //           alignment: Alignment.center,
            //           decoration: BoxDecoration(
            //             color: Colors.white,
            //             borderRadius: BorderRadius.circular(10.0),
            //           ),
            //           child: CircularProgressIndicator(
            //             color: Theme.of(context).primaryColor,
            //           ),
            //         ),
            //       ),
            //     ),
            // );
            return Center(child: Container());
          } else {
            return Center(child: Container());
          }
        },
      ),
    );
  }

  card(dynamic model) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 5,
      child: Padding(
        padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 20.0),
        child: formContentStep1(model),
      ),
    );
  }

  formContentStep1(dynamic model) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (var item in model)
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.width * 0.5,
                    width: MediaQuery.of(context).size.width,
                    child: Image.network(item['imageUrl'], fit: BoxFit.cover),
                  ),
                  Text(
                    item['title'],
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Kanit',
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  // new HtmlView(
                  //   data: item['description'].toString(),
                  //   scrollable:
                  //       false, //false to use MarksownBody and true to use Marksown
                  // ),
                  Html(
                    data: item['description'].toString(),
                    onLinkTap:
                        (url, attributes, element) =>
                            launchUrl(Uri.parse(url ?? "")),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
