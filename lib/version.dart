import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:opec/shared/api_provider.dart';
import 'package:opec/widget/dialog.dart';
import 'package:opec/splash.dart';
import 'package:url_launcher/url_launcher.dart';

class VersionPage extends StatefulWidget {
  @override
  _VersionPageState createState() => _VersionPageState();
}

class _VersionPageState extends State<VersionPage> {
  Future<dynamic> futureModel = Future.value(null);

  @override
  void initState() {
    _callRead();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: FutureBuilder<dynamic>(
          future: futureModel,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data['isActive']) {
                if (versionNumber < snapshot.data['versionNum']) {
                  return Center(
                    child: Container(
                      color: Colors.white,
                      child: dialogVersion(
                        context,
                        title: snapshot.data['title'],
                        description: snapshot.data['description'],
                        isYesNo: !snapshot.data['isForce'],
                        callBack: (param) {
                          if (param) {
                            launch(snapshot.data['url']);
                          } else {
                            _callGoSplash();
                          }
                        },
                      ),
                    ),
                  );
                } else {
                  _callGoSplash();
                }
              } else {
                _callGoSplash();
              }
              return Container();
            } else if (snapshot.hasError) {
              _callGoSplash();
              return Container();
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }

  _callRead() async {
    if (Platform.isAndroid) {
      Dio dio = new Dio();
      var response = await dio.post(
        '$gatewayEndpoint/py-api/opec/version/read',
        data: {'platform': 'Android'},
      );

      setState(() {
        futureModel = Future.value(response.data['data'][0]);
      });

      //futureModel = postDio(versionReadApi, {'platform': 'Android'});
    } else if (Platform.isIOS) {
      Dio dio = new Dio();
      var response = await dio.post(
        '$gatewayEndpoint/py-api/opec/version/read',
        data: {'platform': 'Ios'},
      );

      setState(() {
        futureModel = Future.value(response.data['data'][0]);
      });

    }
  }

  _callGoSplash() {

    SchedulerBinding.instance.addPostFrameCallback((_) {
      Navigator.push(
          context, new MaterialPageRoute(builder: (context) => SplashPage()));
    });
  }
}
