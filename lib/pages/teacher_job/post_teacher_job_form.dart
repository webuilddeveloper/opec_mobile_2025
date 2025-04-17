import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:opec/pages/teacher_job/teacher_job_by_school.dart';
import 'package:opec/shared/api_provider.dart';
import 'package:opec/user.dart';
import 'package:opec/widget/button.dart';
import 'package:opec/widget/loading.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as dtpicker;

class PostTeacherJobForm extends StatefulWidget {
  const PostTeacherJobForm({
    Key? key,
    this.model,
    required this.userData,
    this.title,
    required this.profileCode,
  }) : super(key: key);

  final dynamic model;
  final User userData;
  final dynamic title;
  final String profileCode;

  @override
  State<PostTeacherJobForm> createState() => _PostTeacherJobFormState();
}

class _PostTeacherJobFormState extends State<PostTeacherJobForm> {
  final storage = FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();
  Random random = Random();

  final FocusNode _schoolNameFocusNode = FocusNode();
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _salaryStartFocusNode = FocusNode();
  final FocusNode _salaryEndFocusNode = FocusNode();
  final FocusNode _receivedAmountFocusNode = FocusNode();

  late TextEditingController _schoolNameEditingController;
  late TextEditingController _titleEditingController;
  late TextEditingController _sexEditingController;
  late TextEditingController _jobTypeEditingController;
  late TextEditingController _dateStartEditingController;
  late TextEditingController _dateEndEditingController;
  late TextEditingController _salaryStartEditingController;
  late TextEditingController _salaryEndEditingController;
  late TextEditingController _receivedAmountEditingController;
  late TextEditingController _descriptionEditingController;
  late TextEditingController _aboutSchoolEditingController;
  late TextEditingController _emailAdmin1EditingController;
  late TextEditingController _emailAdmin2EditingController;
  late TextEditingController _emailAdmin3EditingController;

  int _selectedDay = 1;
  int _selectedMonth = 1;
  int _selectedYear = 2022;

  List<dynamic> _provinceList = [];
  List<dynamic> _districtList = [];
  List<Marker> markerSelect = [];
  List<Marker> markers = [];

  String _selectedProvince = '';
  String _selectedDistrict = '';
  String _imageUrl = '';

  DateTime now = DateTime.now();

  bool isShowMap = true;
  bool _isFullTime = false;
  bool _isPartTime = false;
  bool _isProfessionalLicense = false;
  bool _isPortfolio = false;
  bool _isCopyOfNationalIDCard = false;
  bool _isCopyOfHouseRegistration = false;
  bool _isMedicalCertificate = false;
  bool _isOther = false;

  double latitude = 13.765713;
  double longitude = 100.508381;
  double workExperience = 0.0;
  late RangeValues rangeSalary;

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
    _selectedDay = now.day;
    _selectedMonth = now.month;
    _selectedYear = now.year;

    _schoolNameEditingController = TextEditingController();
    _titleEditingController = TextEditingController();
    _sexEditingController = TextEditingController(text: '0');
    _jobTypeEditingController = TextEditingController(text: '0');
    _dateStartEditingController = TextEditingController(text: '');
    _dateEndEditingController = TextEditingController(text: '');
    _salaryStartEditingController = TextEditingController();
    _salaryEndEditingController = TextEditingController();
    _receivedAmountEditingController = TextEditingController(text: '1');
    _descriptionEditingController = TextEditingController();
    _aboutSchoolEditingController = TextEditingController();
    _emailAdmin1EditingController = TextEditingController();
    _emailAdmin2EditingController = TextEditingController();
    _emailAdmin3EditingController = TextEditingController();

    rangeSalary = RangeValues(0.0, 100000.0);

    read();
    _getProvince();
    super.initState();
  }

  void dispose() {
    _schoolNameEditingController.dispose();
    _titleEditingController.dispose();
    _sexEditingController.dispose();
    _jobTypeEditingController.dispose();
    _salaryStartEditingController.dispose();
    _salaryEndEditingController.dispose();
    _receivedAmountEditingController.dispose();
    _descriptionEditingController.dispose();
    _aboutSchoolEditingController.dispose();
    _emailAdmin1EditingController.dispose();
    _emailAdmin2EditingController.dispose();
    _emailAdmin3EditingController.dispose();

    _schoolNameFocusNode.dispose();
    _titleFocusNode.dispose();
    _salaryStartFocusNode.dispose();
    _salaryEndFocusNode.dispose();
    _receivedAmountFocusNode.dispose();

    super.dispose();
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 10),
                      InkWell(
                        onTap: () => _showPickerImage(context),
                        child: Stack(
                          children: [
                            Container(
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Color(0xFFE4E4E4),
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add,
                                    color: Colors.black.withOpacity(0.45),
                                    size: 50,
                                  ),
                                  Text(
                                    'เพิ่มรูปปก',
                                    style: TextStyle(
                                      color: Colors.black.withOpacity(0.45),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_imageUrl != '')
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: loadingImageNetwork(
                                    _imageUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Text(
                    'สร้างประกาศรับสมัคร',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'กรุณากรอกข้อมูลให้ครบ เพื่อให้ได้คนที่ตรงความต้องการของท่าน',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF707070),
                      // fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 15),
                  _textFormSearchWork(
                    _titleEditingController,
                    labelText: 'ชื่อตำแหน่ง',
                    focusNode: _titleFocusNode,
                    validator: (value) {
                      if (value.isEmpty) {
                        _titleFocusNode.requestFocus();
                        return 'กรุณากรอกข้อมูลชื่อตำแหน่ง';
                      }
                    },
                  ),
                  SizedBox(height: 15),
                  _textFormSearchWork(
                    _schoolNameEditingController,
                    labelText: 'ชื่อโรงเรียน',
                    focusNode: _schoolNameFocusNode,
                    validator: (value) {
                      if (value.isEmpty) {
                        _schoolNameFocusNode.requestFocus();
                        return 'กรุณากรอกข้อมูลชื่อโรงเรียน';
                      }
                    },
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _provinceWidget()),
                      SizedBox(width: MediaQuery.of(context).size.width / 125),
                      Expanded(child: _districtWidget()),
                    ],
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
                      Expanded(child: _receivedAmountWidget()),
                      SizedBox(width: MediaQuery.of(context).size.width / 125),
                      Expanded(child: _sexWidget()),
                    ],
                  ),
                  SizedBox(height: 25),
                  Text(
                    'ประสบการณ์ทำงาน',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: workExperience,
                    onChanged: (value) {
                      setState(() => workExperience = value);
                    },
                    label: '${workExperience.floor()}',
                    min: 0,
                    max: 30,
                    divisions: 30,
                    activeColor: Color(0xFFEEBA33),
                    inactiveColor: Color(0xFFE4E4E4),
                  ),
                  Text(
                    'เงินเดือน',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  RangeSlider(
                    values: rangeSalary,
                    onChanged: (value) {
                      setState(() {
                        rangeSalary = value;
                      });
                    },
                    min: 0,
                    max: 100000,
                    divisions: 1000,
                    activeColor: Color(0xFFEEBA33),
                    inactiveColor: Color(0xFFE4E4E4),
                    labels: RangeLabels(
                      rangeSalary.start.floor().toString(),
                      rangeSalary.end.floor().toString(),
                    ),
                  ),
                  SizedBox(height: 25),
                  Text(
                    'รูปแบบสัญญา',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: _otherFilter(
                          'งานประจำ',
                          _isFullTime,
                          onTap:
                              () => setState(() => _isFullTime = !_isFullTime),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _otherFilter(
                          'งานชั่วคราว',
                          _isPartTime,
                          onTap:
                              () => setState(() => _isPartTime = !_isPartTime),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 25),
                  Text(
                    'ช่วงเวลารับสมัคร',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
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
                  SizedBox(height: 25),
                  Text(
                    'เอกสารแนบ',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'ท่านสามารถระบุเอกสารแนบจากผู้สมัครได้',
                    style: TextStyle(fontSize: 13, color: Color(0xFF707070)),
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: _otherFilter(
                          'ใบประกอบวิชาชีพ',
                          _isProfessionalLicense,
                          onTap:
                              () => setState(
                                () =>
                                    _isProfessionalLicense =
                                        !_isProfessionalLicense,
                              ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _otherFilter(
                          'ประวัติผลงาน',
                          _isPortfolio,
                          onTap:
                              () =>
                                  setState(() => _isPortfolio = !_isPortfolio),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: _otherFilter(
                          'สำเนาบัตรประชาชน',
                          _isCopyOfNationalIDCard,
                          onTap:
                              () => setState(
                                () =>
                                    _isCopyOfNationalIDCard =
                                        !_isCopyOfNationalIDCard,
                              ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _otherFilter(
                          'สำเนาทะเบียนบ้าน',
                          _isCopyOfHouseRegistration,
                          onTap:
                              () => setState(
                                () =>
                                    _isCopyOfHouseRegistration =
                                        !_isCopyOfHouseRegistration,
                              ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: _otherFilter(
                          'เอกสารตรวจร่างกาย',
                          _isMedicalCertificate,
                          onTap:
                              () => setState(
                                () =>
                                    _isMedicalCertificate =
                                        !_isMedicalCertificate,
                              ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _otherFilter(
                          'อื่นๆ',
                          _isOther,
                          onTap: () => setState(() => _isOther = !_isOther),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 25),
                  Text(
                    'รายละเอียดงาน',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _descriptionEditingController,
                    decoration: _searchDecoration(
                      labelText: 'รายละเอียดของงาน หรือ ลักษณะงาน',
                    ),
                    minLines: 6,
                    maxLines: 6,
                  ),
                  SizedBox(height: 25),
                  Text(
                    'เกี่ยวกับโรงเรียน',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _aboutSchoolEditingController,
                    decoration: _searchDecoration(
                      labelText: 'เกี่ยวกับโรงเรียน',
                    ),
                    minLines: 6,
                    maxLines: 6,
                  ),
                  SizedBox(height: 25),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(width: 2, color: Color(0xFFE4E4E4)),
                    ),
                  ),
                  SizedBox(height: 25),
                  Text(
                    'สิทธิ์การเข้าถึงประกาศ',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'ท่านสามารถระบุบุคลากรที่เข้าถึงข้อมูลผู้สมัครได้ เพียงกรอกอีเมลและชื่อของบุคลากรที่ท่านต้องการ',
                    style: TextStyle(fontSize: 13, color: Color(0xFF707070)),
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: _emailAdmin1EditingController,
                    decoration: _searchDecoration(labelText: 'อีเมลคนที่1'),
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: _emailAdmin2EditingController,
                    decoration: _searchDecoration(labelText: 'อีเมลคนที่2'),
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: _emailAdmin3EditingController,
                    decoration: _searchDecoration(labelText: 'อีเมลคนที่3'),
                  ),
                  SizedBox(height: 80),
                  GestureDetector(
                    onTap: () async {
                      final form = _formKey.currentState;
                      if (form != null && form.validate()) {
                        await _save();
                        _dialogSuccess();
                      }
                    },
                    child: Container(
                      height: 40,
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Color(0xFFEEBA33),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'บันทึกข้อมูล',
                        style: TextStyle(fontSize: 15, color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // image picker

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

  _imgFromCamera() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      _uploadImage(image);
    }
  }

  _imgFromGallery() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _uploadImage(image);
    }
  }

  void _uploadImage(XFile image) async {
    if (_imageUrl == '') return;

    uploadImage(image)
        .then((res) {
          setState(() {
            _imageUrl = res;
          });
        })
        .catchError((err) {
          print(err);
        });
  }

  GestureDetector _otherFilter(
    String title,
    bool value, {
    required Function onTap,
  }) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            width: 1,
            color: value ? Color(0xFFEEBA33) : Color(0xFFE4E4E4),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            color: value ? Color(0xFFEEBA33) : Colors.black,
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
                      'ลงประกาศสำเร็จ',
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
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => TeacherJobBySchoolPage(
                                  userData: widget.userData,
                                  profileCode: widget.profileCode,
                                ),
                          ),
                        );
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

  _provinceWidget() {
    return _selectedProvince != ''
        ? DropdownButtonFormField(
          decoration: _searchDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          ),
          validator:
              (value) =>
                  value == '' || value == null ? 'กรุณาเลือกจังหวัด' : null,
          hint: Text(
            '',
            style: TextStyle(fontSize: 13.00, color: Color(0xFF707070)),
            textAlign: TextAlign.start,
          ),
          value: _selectedProvince,
          onChanged: (newValue) {
            setState(() {
              _selectedDistrict = "";
              _districtList = [];
              _selectedProvince = (newValue ?? "").toString();
            });
            _getDistrict();
          },
          items:
              _provinceList.map((item) {
                return DropdownMenuItem(
                  value: item['code'],
                  child: Text(
                    item['title'],
                    style: TextStyle(
                      fontSize: 15.00,
                      fontFamily: 'Kanit',
                      color: Colors.black,
                    ),
                  ),
                );
              }).toList(),
        )
        : DropdownButtonFormField(
          decoration: _searchDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          ),
          validator:
              (value) =>
                  value == '' || value == null ? 'กรุณาเลือกจังหวัด' : null,
          hint: Text(
            'จังหวัด',
            style: TextStyle(fontSize: 15.00, fontFamily: 'Kanit'),
          ),
          onChanged: (newValue) {
            setState(() {
              _selectedDistrict = "";
              _districtList = [];
              _selectedProvince = (newValue ?? "").toString();
            });
            _getDistrict();
          },
          items:
              _provinceList.map((item) {
                return DropdownMenuItem(
                  value: item['code'],
                  child: Text(
                    item['title'],
                    style: TextStyle(
                      fontSize: 15.00,
                      fontFamily: 'Kanit',
                      color: Color(0xFF9A1120),
                    ),
                  ),
                );
              }).toList(),
        );
  }

  _districtWidget() {
    return _selectedDistrict != ''
        ? DropdownButtonFormField(
          decoration: _searchDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          ),
          validator:
              (value) =>
                  value == '' || value == null ? 'กรุณาเลือกอำเภอ' : null,
          hint: Text(
            'อำเภอ',
            style: TextStyle(fontSize: 15.00, fontFamily: 'Kanit'),
          ),
          value: _selectedDistrict,
          onChanged: (newValue) {
            setState(() {
              _selectedDistrict = (newValue ?? "").toString();
            });
          },
          items:
              _districtList.map((item) {
                return DropdownMenuItem(
                  value: item['code'],
                  child: Text(item['title'], style: TextStyle(fontSize: 15.00)),
                );
              }).toList(),
        )
        : DropdownButtonFormField(
          decoration: _searchDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          ),
          validator:
              (value) =>
                  value == '' || value == null ? 'กรุณาเลือกอำเภอ' : null,
          hint: Text(
            'อำเภอ',
            style: TextStyle(fontSize: 15.00, fontFamily: 'Kanit'),
          ),
          onChanged: (newValue) {
            setState(() {
              _selectedDistrict = (newValue ?? "").toString();
            });
          },
          items:
              _districtList.map((item) {
                return DropdownMenuItem(
                  value: item['code'],
                  child: Text(item['title'], style: TextStyle(fontSize: 15.00)),
                );
              }).toList(),
        );
  }

  _receivedAmountWidget() {
    return _textFormSearchWork(
      _receivedAmountEditingController,
      labelText: 'จำนวนที่รับ',
      focusNode: _receivedAmountFocusNode,
      validator: (value) {
        if (value == null || value.isEmpty) {
          _receivedAmountFocusNode.requestFocus();
          return 'กรุณากรอกข้อมูลจำนวนที่รับ';
        }
      },
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
    );
  }

  _sexWidget() {
    return DropdownButtonFormField(
      decoration: _searchDecoration(),
      validator: (value) => value == '' || value == null ? 'เพศ' : null,
      hint: SizedBox(
        width: 100,
        child: Text(
          'เพศ',
          style: TextStyle(fontSize: 13.00, color: Color(0xFF707070)),
          textAlign: TextAlign.start,
        ),
      ),
      icon: Icon(Icons.arrow_drop_down, color: Colors.black),
      value: _sexEditingController.text,
      onChanged: (newValue) {
        setState(() {
          _sexEditingController.text = (newValue ?? "").toString();
        });
      },
      selectedItemBuilder: (BuildContext context) {
        return [
          {'display': 'ทุกเพศ', 'value': '0'},
          {'display': 'ชาย', 'value': '1'},
          {'display': 'หญิง', 'value': '2'},
        ].map<Widget>((item) {
          return SizedBox(
            width: 100,
            child: Text(
              item['display'].toString(),
              style: TextStyle(
                fontSize: 15.00,
                fontFamily: 'Kanit',
                color: item['value'] == '' ? Color(0xFF707070) : Colors.black,
              ),
              textAlign: TextAlign.start,
            ),
          );
        }).toList();
      },
      items:
          [
            {'display': 'ทุกเพศ', 'value': '0'},
            {'display': 'ชาย', 'value': '1'},
            {'display': 'หญิง', 'value': '2'},
          ].map((item) {
            return DropdownMenuItem(
              value: item['value'],
              child: Center(
                child: Text(
                  item['display'].toString(),
                  style: TextStyle(
                    fontSize: 15.00,
                    fontFamily: 'Kanit',
                    color: Colors.black,
                  ),
                ),
              ),
            );
          }).toList(),
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
                  ? 'เริ่มต้น'
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
                  ? 'สิ้นสุด'
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
                  'เลือกตำแหน่งที่ตั้งโรงเรียน',
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
    var salaryStart = rangeSalary.start.floor().toString();
    var salaryEnd = rangeSalary.end.floor().toString();

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

    var result = await postDio('${server}m/teacherjob/create', {
      'imageUrl': _imageUrl,
      'title': _titleEditingController.text,
      'schoolName': _schoolNameEditingController.text,
      // 'jobType': _jobTypeEditingController.text,
      'province': _selectedProvince,
      'district': _selectedDistrict,
      'receivedAmount': int.parse(_receivedAmountEditingController.text),
      'sex': _sexEditingController.text,
      'workExperience': workExperience.floor().toString(),
      'salaryStart': int.parse(salaryStart),
      'salaryEnd': int.parse(salaryEnd),
      'latitude': latitude,
      'longitude': longitude,
      'isFullTime': _isFullTime,
      'isPartTime': _isPartTime,
      'dateStart': dateStart,
      'dateEnd': dateEnd,
      'isProfessionalLicense': _isProfessionalLicense,
      'isPortfolio': _isPortfolio,
      'isCopyOfNationalIDCard': _isCopyOfNationalIDCard,
      'isCopyOfHouseRegistration': _isCopyOfHouseRegistration,
      'isMedicalCertificate': _isMedicalCertificate,
      'isOther': _isOther,
      'description': _descriptionEditingController.text,
      'aboutSchool': _aboutSchoolEditingController.text,
      'emailAdmin1': _emailAdmin1EditingController.text,
      'emailAdmin2': _emailAdmin2EditingController.text,
      'emailAdmin3': _emailAdmin3EditingController.text,
      'isActive': true,
    });
    print(result);
  }

  read() async {
    currentLocation = await getCurrentLocation();
    if (currentLocation != null) {
      latitude = currentLocation!.latitude ?? 0;
      longitude = currentLocation!.longitude ?? 0;
    }
  }

  Future<dynamic> _getProvince() async {
    final result = await postObjectData("route/province/read", {});
    if (result['status'] == 'S') {
      setState(() {
        _provinceList = result['objectData'];
      });
    }
  }

  Future<dynamic> _getDistrict() async {
    final result = await postObjectData("route/district/read", {
      'province': _selectedProvince,
    });
    if (result['status'] == 'S') {
      setState(() {
        _districtList = result['objectData'];
      });
    }
  }

  //
}
