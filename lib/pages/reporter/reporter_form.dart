import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:opec/shared/api_provider.dart';
import 'package:opec/widget/button.dart';
import 'package:opec/widget/header.dart';
import 'package:opec/widget/text_form_field.dart';

class ReporterFormPage extends StatefulWidget {
  ReporterFormPage({
    Key? key,
    required this.title,
    required this.code,
    required this.imageUrl,
  }) : super(key: key);

  final String title;
  final String code;
  final String imageUrl;

  @override
  _ReporterFormPageState createState() => _ReporterFormPageState();
}

class _ReporterFormPageState extends State<ReporterFormPage> {
  final storage = FlutterSecureStorage();


  final _formKey = GlobalKey<FormState>();


  final txtEmail = TextEditingController();
  final txtPassword = TextEditingController();
  final txtConPassword = TextEditingController();
  final txtPrefixName = TextEditingController();
  final txtFirstName = TextEditingController();
  final txtLastName = TextEditingController();
  final txtPhone = TextEditingController();
  final txtUsername = TextEditingController();
  final txtIdCard = TextEditingController();
  final txtLineID = TextEditingController();
  final txtOfficerCode = TextEditingController();
  final txtAddress = TextEditingController();
  final txtMoo = TextEditingController();
  final txtSoi = TextEditingController();
  final txtRoad = TextEditingController();

  final txtTitle = TextEditingController();
  final txtDescription = TextEditingController();
  double latitude = 13.743894;
  double longitude = 100.538592;

  late String currentLocation;
  bool isShowMap = true;

  List<dynamic> _itemImage = [];
  List<Marker> markers = [];
  List<Marker> markerSelect = [];

  addMarker(latLng, newSetState) {
    setState(() {
      latitude = latLng.latitude;
      longitude = latLng.longitude;
    });
    newSetState(() {
      markers.clear();

      markers.add(Marker(markerId: MarkerId('New'), position: latLng));
    });
  }

  selectMarker() async {
    setState(() {
      markerSelect = markers;
      isShowMap = true;
    });
  }

  DateTime selectedDate = DateTime.now();
  TextEditingController txtDate = TextEditingController();

  Future<dynamic> futureModel = Future.value(null);

  ScrollController scrollController = ScrollController();

  late XFile? _image;

  int year = 0;
  int month = 0;
  int day = 0;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    txtEmail.dispose();
    txtPassword.dispose();
    txtConPassword.dispose();
    txtFirstName.dispose();
    txtLastName.dispose();
    txtPhone.dispose();
    txtDate.dispose();
    txtTitle.dispose();
    txtDate.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // _getLocation();
    // futureModel = _getCurrentPosition();

    scrollController = ScrollController();

    super.initState();
  }

  // Future<dynamic> _getCurrentPosition() async {
    // var res = await getCurrentPosition();
    // setState(() {
    //   latitude = res.latitude;
    //   longitude = res.longitude;
    //   markers.add(
    //     Marker(
    //       markerId: MarkerId('New'),
    //       position: LatLng(res.latitude, res.longitude),
    //     ),
    //   );
    // });
  // }

  // void _getLocation() async {
    // Position position = await getCurrentPosition(
    //   desiredAccuracy: LocationAccuracy.best,
    // );

    // final coordinates = new Coordinates(position.latitude, position.longitude);

    // var address = await Geocoder.google(
    //   'AIzaSyD-pkE26l2sWEU_CrbDz6b2myMe5Ab7jJo',
    //   language: 'th',
    // ).findAddressesFromCoordinates(coordinates);

    // setState(() {
    //   currentLocation = address.first.adminArea;
    // });
  // }

  Future<dynamic> submitReporter() async {
    var value = await storage.read(key: 'dataUserLoginOPEC') ?? "";
    var user = json.decode(value);

    var data = {
      "title": txtTitle.text,
      "enTitle": txtTitle.text,
      "description": txtDescription.text,
      "enDescription": txtDescription.text,
      "category": widget.code,
      "latitude": latitude.toString(),
      "longitude": longitude.toString(),
      "createBy": user['username'] ?? '',
      "firstName": user['firstName'] ?? '',
      "lastName": user['lastName'] ?? '',
      "imageUrlCreateBy": user['imageUrl'] ?? '',
      "imageUrl": widget.imageUrl,
      "gallery": _itemImage,
      "province": currentLocation,
      "lv0": user['lv0'],
      "lv1": user['lv1'],
      "lv2": user['lv2'],
      "lv3": user['lv3'],
      "lv4": user['lv4'],
      "language": 'th',
      "platform": Platform.operatingSystem.toString(),
    };

    final result = await postObjectData('m/Reporter/create', data);

    if (result['status'] == 'S') {
      return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () {
              return Future.value(false);
            },
            child: CupertinoAlertDialog(
              title: Text(
                'บันทึกข้อมูลเรียบร้อยแล้ว',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Kanit',
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
              ),
              content: Text(" "),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text(
                    "ตกลง",
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Kanit',
                      color: Color(0xFF005C9E),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    goBack();
                  },
                ),
              ],
            ),
          );
        },
      );
    } else {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () {
              return Future.value(false);
            },
            child: CupertinoAlertDialog(
              title: Text(
                'บันทึกข้อมูลไม่สำเร็จ',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Kanit',
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
              ),
              content: Text(
                result['message'],
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Kanit',
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
              ),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text(
                    "ตกลง",
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Kanit',
                      color: Color(0xFF005C9E),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Navigator.of(context).pop();
                    // goBack();
                  },
                ),
              ],
            ),
          );
        },
      );
    }
  }

  contentCard() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ListView(
          controller: scrollController,
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 5.0),
            ),
            Text(
              '* หัวข้อ',
              style: TextStyle(
                fontSize: 18.00,
                fontFamily: 'Kanit',
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 5.0),
            textFormField(
              txtTitle,
              null,
              'หัวข้อ',
              'หัวข้อ',
              true,
              false,
              false,
            ),
            SizedBox(height: 15.0),
            Text(
              '* รายละเอียด',
              style: TextStyle(
                fontSize: 18.00,
                fontFamily: 'Kanit',
                fontWeight: FontWeight.w500,
              ),
            ),
            TextFormField(
              style: TextStyle(
                color: Color(0xFFA9151D),
                fontWeight: FontWeight.normal,
                fontFamily: 'Kanit',
                fontSize: 15.00,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xFFEEBA33),
                contentPadding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
                hintText: 'รายละเอียด',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                errorStyle: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontFamily: 'Kanit',
                  fontSize: 10.0,
                ),
              ),
              validator: (model) {
                model = model ?? "";
                if (model.isEmpty) {
                  return 'กรุณากรอกรายละเอียด.';
                }
                return null;
              },
              controller: txtDescription,
              enabled: true,
              keyboardType: TextInputType.multiline,
              minLines: 1, //Normal textInputField will be displayed
              maxLines: null,
            ),
            SizedBox(height: 15.0),
            Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'เพิ่มรูปภาพ',
                        style: TextStyle(
                          fontSize: 18.00,
                          fontFamily: 'Kanit',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'สามารถอัพโหลดรูปภาพได้เกิน 10 รูป',
                        style: TextStyle(
                          fontSize: 12.00,
                          fontFamily: 'Kanit',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 35.0,
                        height: 35.0,
                        decoration: BoxDecoration(
                          color: Color(0xFFA9151D),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: MaterialButton(
                          onPressed: () {
                            _showPickerImage(context);
                          },
                          padding: EdgeInsets.all(5.0),
                          child: Image.asset(
                            'assets/logo/icons/picture.png',
                            height: 20.0,
                            width: 20.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_itemImage.length > 0)
              Container(
                padding: EdgeInsets.only(top: 10.0),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1 / 1,
                  ),
                  physics: ClampingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _itemImage.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.only(top: 5.0),
                      width: 400,
                      child: MaterialButton(
                        onPressed: () {
                          dialogDeleteImage(_itemImage[index]['id'].toString());
                        },
                        child: Image.network(
                          _itemImage[index]['imageUrl'],
                          width: 1000,
                          fit: BoxFit.cover,
                        ),
                        // ),
                      ),
                    );
                  },
                ),
              ),
            SizedBox(height: 15.0),
            Text(
              'ตำแหน่ง',
              style: TextStyle(
                fontSize: 18.00,
                fontFamily: 'Kanit',
                fontWeight: FontWeight.w500,
              ),
            ),
            if (markerSelect.length > 0 && isShowMap)
              Container(
                height: 250.0,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      latitude != 0 ? latitude : 13.743894,
                      longitude != 0 ? longitude : 100.538592,
                    ),
                    zoom: 14,
                  ),
                  markers: markerSelect.toSet(),
                ),
              ),
            Container(
              margin: EdgeInsets.only(top: 10.0),
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              // padding: EdgeInsets.symmetric(horizontal: 80.0),
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
                      setState(() {
                        isShowMap = false;
                      });

                      showGeneralDialog(
                        context: context,
                        barrierDismissible: true,
                        barrierLabel: MaterialLocalizations.of(context)
                            .modalBarrierDismissLabel,
                        barrierColor: Colors.black45,
                        transitionDuration: const Duration(milliseconds: 200),
                        pageBuilder: (
                          BuildContext context,
                          Animation animation,
                          Animation secondaryAnimation,
                        ) {
                          return StatefulBuilder(
                            builder: (context, newSetState) {
                              return Center(
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                  color: Colors.white,
                                  child: Stack(
                                    // alignment: Alignment.topCenter,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(
                                            top: MediaQuery.of(context)
                                                .padding
                                                .top),
                                        height: MediaQuery.of(context)
                                                .size
                                                .height -
                                            MediaQuery.of(context).padding.top,
                                        child: GoogleMap(
                                          myLocationEnabled: true,
                                          initialCameraPosition: CameraPosition(
                                            target: LatLng(
                                              latitude != 0
                                                  ? latitude
                                                  : 13.743894,
                                              longitude != 0
                                                  ? longitude
                                                  : 100.538592,
                                            ),
                                            zoom: 14,
                                          ),
                                          markers: markers.toSet(),
                                          onTap: (newLatLng) {
                                            addMarker(newLatLng, newSetState);
                                          },
                                        ),
                                      ),
                                      buttonCenter(
                                        context: context,
                                        margin: EdgeInsets.only(
                                            top: MediaQuery.of(context)
                                                    .size
                                                    .height -
                                                100),
                                        backgroundColor:
                                            Theme.of(context).primaryColor,
                                        title: 'ตกลง',
                                        fontColor: Colors.white,
                                        callback: () {
                                          selectMarker();
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      Container(
                                        width: double.infinity,
                                        alignment: Alignment.topLeft,
                                        margin: EdgeInsets.only(
                                            top: MediaQuery.of(context)
                                                    .padding
                                                    .top +
                                                10),
                                        child: buttonCloseBack(context),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.near_me,
                          color: Theme.of(context).primaryColor,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'ตำแหน่ง Google Map',
                          style: TextStyle(
                            color: Color(0xFFA9151D),
                            fontFamily: 'Kanit',
                            fontSize: 15.0,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.7,
                margin: EdgeInsets.symmetric(vertical: 10.0),
                child: Material(
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(5.0),
                  color: Color(0xFFA9151D),
                  child: MaterialButton(
                    height: 40,
                    onPressed: () {
                      final form = _formKey.currentState;
                      if (form != null && form.validate()) {
                        form.save();
                        submitReporter();
                      }
                    },
                    child: Text(
                      'บันทึกข้อมูล',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                        fontFamily: 'Kanit',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  dialogDeleteImage(String code) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(
          'ต้องการลบรูปภาพ ใช่ไหม',
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Kanit',
            color: Colors.black,
            fontWeight: FontWeight.normal,
          ),
        ),
        content: Text(''),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text(
              "ยกเลิก",
              style: TextStyle(
                fontSize: 13,
                fontFamily: 'Kanit',
                color: Color(0xFF005C9E),
                fontWeight: FontWeight.normal,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text(
              "ลบ",
              style: TextStyle(
                fontSize: 13,
                fontFamily: 'Kanit',
                color: Color(0xFFA9151D),
                fontWeight: FontWeight.normal,
              ),
            ),
            onPressed: () {
              deleteImage(code);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  deleteImage(String code) async {
    setState(() {
      _itemImage.removeWhere((c) => c['id'].toString() == code.toString());
    });
  }

  _imgFromCamera() async {
    // File image = await ImagePicker.pickImage(
    //   source: ImageSource.camera,
    //   imageQuality: 100,
    // );

    // setState(() {
    //   _image = image;
    // });
    _upload();
  }

  _imgFromGallery() async {
    // File image = await ImagePicker.pickImage(
    //   source: ImageSource.gallery,
    //   imageQuality: 100,
    // );

    // setState(() {
    //   _image = image;
    // });
    _upload();
  }

  void _upload() async {
    if (_image == null) return;

    Random random = Random();
    uploadImage(_image!).then((res) {
      setState(() {
        _itemImage.add({'imageUrl': res, 'id': random.nextInt(100)});
      });
      // setState(() {
      //   _imageUrl = res;
      // });
    }).catchError((err) {
      print(err);
    });
  }

  void _showPickerImage(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.photo_library),
                  title: Text(
                    'อัลบั้มรูปภาพ',
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Kanit',
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    _imgFromGallery();
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo_camera),
                  title: Text(
                    'กล้องถ่ายรูป',
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Kanit',
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    _imgFromCamera();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void goBack() async {
    Navigator.pop(context);
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => ReporterListCategory(),
    //   ),
    // );
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
        backgroundColor: Colors.white,
        appBar: header(context, goBack, title: widget.title),
        body: Container(
          child: ListView(
            controller: scrollController,
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            children: <Widget>[
              Container(
                color: Colors.white,
                child: contentCard(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
