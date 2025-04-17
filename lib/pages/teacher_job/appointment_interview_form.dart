import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:opec/shared/api_provider.dart';
import 'package:opec/widget/button.dart';
import 'package:opec/widget/dialog.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as dtpicker;

class AppointmentInterviewForm extends StatefulWidget {
  const AppointmentInterviewForm({
    Key? key,
    this.model,
    required this.profileCode,
  }) : super(key: key);

  final dynamic model;
  final String profileCode;

  @override
  State<AppointmentInterviewForm> createState() =>
      _AppointmentInterviewFormState();
}

class _AppointmentInterviewFormState extends State<AppointmentInterviewForm> {
  final storage = FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();
  Random random = Random();

  final FocusNode _schoolNameFocusNode = FocusNode();
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _receivedAmountFocusNode = FocusNode();

  late TextEditingController _schoolNameEditingController;
  late TextEditingController _titleEditingController;
  late TextEditingController _receivedAmountEditingController;
  late TextEditingController _dateStartEditingController;
  late TextEditingController _dateEndEditingController;

  int _selectedDay = 1;
  int _selectedMonth = 1;
  int _selectedYear = 2022;

  List<Marker> markerSelect = [];
  List<Marker> markers = [];

  DateTime now = DateTime.now();

  bool isShowMap = true;

  double latitude = 13.765713;
  double longitude = 100.508381;

  dynamic model;
  dynamic modelTeacherJobResume;

  late LocationData? currentLocation;

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

  @override
  void initState() {
    model = widget.model;
    _selectedDay = now.day;
    _selectedMonth = now.month;
    _selectedYear = now.year;

    _schoolNameEditingController = TextEditingController();
    _titleEditingController = TextEditingController();
    _dateStartEditingController = TextEditingController(text: '');
    _dateEndEditingController = TextEditingController(text: '');
    _receivedAmountEditingController = TextEditingController(text: '1');

    read();
    super.initState();
  }

  void dispose() {
    _schoolNameEditingController.dispose();
    _titleEditingController.dispose();
    _receivedAmountEditingController.dispose();

    _schoolNameFocusNode.dispose();
    _titleFocusNode.dispose();
    _receivedAmountFocusNode.dispose();

    super.dispose();
  }

  read() async {
    currentLocation = await getCurrentLocation();
    latitude = currentLocation?.latitude ?? 0;
    longitude = currentLocation?.longitude ?? 0;

    var result = await postDio('${server}m/teacherjob/resume/read', {
      'profileCode': widget.profileCode,
    });
    if (result.length > 0) {
      setState(() {
        result = result[0];
        modelTeacherJobResume = result;
      });
    }
    // print(modelTeacherJobResume);
    // print(model);

    if (modelTeacherJobResume != null && model != null) {
      setState(() {
        _titleEditingController.text = 'สัมภาษณ์${model['jobTitle']}';
        _schoolNameEditingController.text =
            'ห้องประชุม โรงเรียน${model['jobSchoolName']}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          toolbarHeight: 50,
          flexibleSpace: Container(
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10,
              left: 15,
              right: 15,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    child: Image.asset('assets/images/arrow_left_box_red.png'),
                  ),
                ),
                Expanded(
                  child: Container(
                    // color: Colors.red,
                    child: Center(
                      child: Text(
                        'สร้างนัดสัมภาษณ์',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              15,
              0,
              15,
              MediaQuery.of(context).padding.bottom + 10,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Text(
                    'รายละเอียด',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    'กรุณากรอกรายละเอียดของนัดสัมภาษณ์',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF707070),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 15),
                  _textFormSearchWork(
                    _titleEditingController,
                    labelText: 'ชื่อนัด',
                    focusNode: _titleFocusNode,
                    validator: (value) {
                      if (value.isEmpty) {
                        _titleFocusNode.requestFocus();
                        return 'กรุณากรอกข้อมูลชื่อนัด';
                      }
                    },
                  ),
                  SizedBox(height: 15),
                  _textFormSearchWork(
                    _schoolNameEditingController,
                    labelText: 'ชื่อสถานที่ในโรงเรียน',
                    focusNode: _schoolNameFocusNode,
                    validator: (value) {
                      if (value.isEmpty) {
                        _schoolNameFocusNode.requestFocus();
                        return 'กรุณากรอกข้อมูลชื่อสถานที่ในโรงเรียน';
                      }
                    },
                  ),
                  SizedBox(height: 10),
                  if (markerSelect.length > 0 && isShowMap)
                    Container(
                      height: 250.0,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            latitude != 0 ? latitude : 13.765713,
                            longitude != 0 ? longitude : 100.508381,
                          ),
                          zoom: 15,
                        ),
                        markers: markerSelect.toSet(),
                      ),
                    ),
                  _buttonGoogleMapWidget(),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _dateStartWidget()),
                      SizedBox(width: MediaQuery.of(context).size.width / 125),
                      Expanded(child: _dateEndWidget()),
                    ],
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _receivedAmountWidget()),
                      SizedBox(width: MediaQuery.of(context).size.width / 125),
                      Expanded(child: Container()),
                    ],
                  ),
                  SizedBox(height: 250),
                  Center(
                    child: InkWell(
                      onTap: () async {
                        final form = _formKey.currentState;
                        if (form != null && form.validate()) {
                          dialogAppointmentInterview(
                            context,
                            title: 'ยืนยันสร้างนัด',
                            description:
                                'กรุณาตรวจสอบรายละเอียดของนัดสัมภาษณ์ ก่อนยืนยัน',
                            yes: 'ยืนยัน',
                            no: 'ตรวจสอบ',
                            callBackYes: () async {
                              await _save();
                              _dialogSuccess();
                            },
                          );
                        }
                      },
                      child: Container(
                        height: 40,
                        width: 230,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Color(0xFFEEBA33),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'สร้างนัดสัมภาษณ์',
                          style: TextStyle(fontSize: 15, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<dynamic> _dialogSuccess() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () {
            return Future.value(false);
          },
          child: AlertDialog(
            contentPadding: EdgeInsets.all(0),
            content: Container(
              width: 290,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: const Color(0xFFFFFF),
              ),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 10),
                    Text(
                      'สร้างนัดสัมภาษณ์สำเร็จ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '',
                      style: TextStyle(fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 35,
                        width: 160,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(0xFFEEBA33),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'ตกลง',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontFamily: 'Kanit',
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // child: //Contents here
            ),
          ),
        );
      },
    );
  }

  dateStartDialogOpenPickerDate() {
    dtpicker.DatePicker.showDatePicker(
      context,
      theme: dtpicker.DatePickerTheme(
        containerHeight: 210.0,
        itemStyle: TextStyle(
          fontSize: 16.0,
          color: Color(0xFFEEBA33),
          fontWeight: FontWeight.normal,
          fontFamily: 'Kanit',
        ),
        doneStyle: TextStyle(
          fontSize: 16.0,
          color: Color(0xFFEEBA33),
          fontWeight: FontWeight.normal,
          fontFamily: 'Kanit',
        ),
        cancelStyle: TextStyle(
          fontSize: 16.0,
          color: Color(0xFFEEBA33),
          fontWeight: FontWeight.normal,
          fontFamily: 'Kanit',
        ),
      ),
      showTitleActions: true,
      minTime: DateTime(now.year - 100, 1, 1),
      maxTime: DateTime(now.year + 1, now.month, now.day),
      onConfirm: (date) {
        setState(() {
          _selectedYear = date.year;
          _selectedMonth = date.month;
          _selectedDay = date.day;
          _dateStartEditingController.value = TextEditingValue(
            text: DateFormat("dd/MM/yyyy").format(date),
          );
        });
      },
      currentTime: DateTime(_selectedYear, _selectedMonth, _selectedDay),
      locale: dtpicker.LocaleType.th,
    );
  }

  dateEndDialogOpenPickerDate() {
    dtpicker.DatePicker.showDatePicker(
      context,
      theme: dtpicker.DatePickerTheme(
        containerHeight: 210.0,
        itemStyle: TextStyle(
          fontSize: 16.0,
          color: Color(0xFFEEBA33),
          fontWeight: FontWeight.normal,
          fontFamily: 'Kanit',
        ),
        doneStyle: TextStyle(
          fontSize: 16.0,
          color: Color(0xFFEEBA33),
          fontWeight: FontWeight.normal,
          fontFamily: 'Kanit',
        ),
        cancelStyle: TextStyle(
          fontSize: 16.0,
          color: Color(0xFFEEBA33),
          fontWeight: FontWeight.normal,
          fontFamily: 'Kanit',
        ),
      ),
      showTitleActions: true,
      minTime: DateTime(now.year - 100, 1, 1),
      maxTime: DateTime(now.year + 1, now.month, now.day),
      onConfirm: (date) {
        setState(() {
          _selectedYear = date.year;
          _selectedMonth = date.month;
          _selectedDay = date.day;
          _dateEndEditingController.value = TextEditingValue(
            text: DateFormat("dd/MM/yyyy").format(date),
          );
        });
      },
      currentTime: DateTime(_selectedYear, _selectedMonth, _selectedDay),
      locale: dtpicker.LocaleType.th,
    );
  }

  TextFormField _textFormSearchWork(
    TextEditingController model, {
    String labelText = '',
    required Function validator,
    bool enabled = true,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    FocusNode? focusNode,
  }) {
    return TextFormField(
      keyboardType: keyboardType,
      focusNode: focusNode,
      inputFormatters: inputFormatters,
      cursorRadius: Radius.circular(10),
      style: TextStyle(color: Colors.black),
      decoration: _searchDecoration(labelText: labelText),
      validator: (value) => validator(value),
      controller: model,
      enabled: enabled,
    );
  }

  InputDecoration _searchDecoration({
    hintText = '',
    labelText = '',
    EdgeInsets contentPadding = const EdgeInsets.only(
      left: 14,
      right: 14,
      top: 12,
    ),
  }) {
    return InputDecoration(
      filled: true,
      hintText: hintText,
      hintStyle: TextStyle(fontSize: 12, color: Color(0xFF707070)),
      fillColor: Colors.transparent,
      contentPadding: contentPadding,
      labelText: labelText,
      labelStyle: TextStyle(color: Color(0xFF707070), fontSize: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(width: 1, color: Color(0xFFE4E4E4)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(width: 1, color: Color(0xFFE4E4E4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(width: 1, color: Color(0xFFEEBA33)),
      ),
      errorStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 10.0),
    );
  }

  _receivedAmountWidget() {
    return _textFormSearchWork(
      _receivedAmountEditingController,
      labelText: 'จำนวนที่รับสัมภาษณ์',
      focusNode: _receivedAmountFocusNode,
      validator: (value) {
        if (value == null || value.isEmpty) {
          _receivedAmountFocusNode.requestFocus();
          return 'กรุณากรอกข้อมูลจำนวนที่รับสัมภาษณ์';
        }
      },
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
    );
  }

  _dateStartWidget() {
    return GestureDetector(
      onTap: () => dateStartDialogOpenPickerDate(),
      child: Container(
        height: 48,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(width: 1, color: Color(0xFFE4E4E4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _dateStartEditingController.text == ''
                  ? 'วันเริ่มต้น'
                  : _dateStartEditingController.text,
              style: TextStyle(
                fontSize: 13,
                color:
                    _dateStartEditingController.text == ''
                        ? Color(0xFF707070)
                        : Colors.black,
              ),
            ),
            Image.asset(
              'assets/images/dropdown_calendar.png',
              width: 15,
              height: 13.5,
            ),
          ],
        ),
      ),
    );
  }

  _dateEndWidget() {
    return GestureDetector(
      onTap: () => dateEndDialogOpenPickerDate(),
      child: Container(
        height: 48,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(width: 1, color: Color(0xFFE4E4E4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _dateEndEditingController.text == ''
                  ? 'วันสิ้นสุด'
                  : _dateEndEditingController.text,
              style: TextStyle(
                fontSize: 13,
                color:
                    _dateEndEditingController.text == ''
                        ? Color(0xFF707070)
                        : Colors.black,
              ),
            ),
            Image.asset(
              'assets/images/dropdown_calendar.png',
              width: 15,
              height: 13.5,
            ),
          ],
        ),
      ),
    );
  }

  _buttonGoogleMapWidget() {
    return Container(
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
            border: Border.all(color: Color(0xFFA9151D)),
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
                barrierLabel:
                    MaterialLocalizations.of(context).modalBarrierDismissLabel,
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
                                  top: MediaQuery.of(context).padding.top,
                                ),
                                height:
                                    MediaQuery.of(context).size.height -
                                    MediaQuery.of(context).padding.top,
                                child: GoogleMap(
                                  myLocationEnabled: true,
                                  initialCameraPosition: CameraPosition(
                                    target: LatLng(
                                      latitude != 0 ? latitude : 13.765713,
                                      longitude != 0
                                          ? longitude
                                          : 100.508381,
                                    ),
                                    zoom: 20,
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
                                  top: MediaQuery.of(context).size.height - 100,
                                ),
                                backgroundColor: Theme.of(context).primaryColor,
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
                                  top: MediaQuery.of(context).padding.top + 10,
                                ),
                                child: buttonCloseBack(context),
                              ),
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
                Icon(Icons.near_me, color: Theme.of(context).primaryColor),
                SizedBox(width: 10),
                Text(
                  'เลือกตำแหน่งที่ตั้งสถานที่ในโรงเรียน',
                  style: TextStyle(
                    color: Color(0xFFA9151D),
                    fontFamily: 'Kanit',
                    fontSize: 15.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _save() async {
    var dateStart = _dateStartEditingController.text.replaceAll('/', '');
    var dateEnd = _dateEndEditingController.text.replaceAll('/', '');

    if (dateStart != '') {
      var yearDateStart = dateStart.substring(4, 8);
      var monthDateStart = dateStart.substring(2, 4);
      var dayDateStart = dateStart.substring(0, 2);
      dateStart = yearDateStart + monthDateStart + dayDateStart;
    }
    //
    if (dateEnd != '') {
      var yearDateEnd = dateEnd.substring(4, 8);
      var monthDateEnd = dateEnd.substring(2, 4);
      var dayDateEnd = dateEnd.substring(0, 2);
      dateEnd = yearDateEnd + monthDateEnd + dayDateEnd;
    }

    var result = await postDio(
      '${server}m/teacherjob/appointmentInterview/create',
      {
        'teacherJobCode': model['teacherJobCode'],
        'resumeCode': modelTeacherJobResume['code'],
        'profileCode': modelTeacherJobResume['profileCode'],
        'updateBy':
            '${modelTeacherJobResume['firstName']} ${modelTeacherJobResume['lastName']}',
        'title': _titleEditingController.text,
        'schoolName': _schoolNameEditingController.text,
        'receivedAmount': int.parse(_receivedAmountEditingController.text),
        'dateStart': dateStart,
        'dateEnd': dateEnd,
        'latitude': latitude,
        'longitude': longitude,
        'isActive': true,
      },
    );
    print(result);
  }

  //
}
