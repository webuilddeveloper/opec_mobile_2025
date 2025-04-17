import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:opec/pages/teacher_job/teacher_job.dart';
import 'package:opec/shared/api_provider.dart';
import 'package:opec/widget/dialog.dart';
import 'package:opec/widget/loading.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as dtpicker;

class ProfileJobPage extends StatefulWidget {
  const ProfileJobPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<ProfileJobPage> createState() => _ProfileJobPageState();
}

class _ProfileJobPageState extends State<ProfileJobPage> {
  final storage = FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();
  Random random = Random();

  final FocusNode _firstNameFocusNode = FocusNode();
  final FocusNode _lastNameFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();

  late TextEditingController _firstNameEditingController;
  late TextEditingController _lastNameEditingController;
  late TextEditingController _sexEditingController;
  late TextEditingController _educationEditingController;
  late TextEditingController _birthDayEditingController;

  late TextEditingController _phoneEditingController;
  late TextEditingController _emailEditingController;
  late TextEditingController _universityEditingController;
  late TextEditingController _facultyEditingController;
  late TextEditingController _graduationYearEditingController;
  late TextEditingController _gradeEditingController;
  late TextEditingController _remarkEditingController;

  double workExperience = 0.0;
  late RangeValues rangeSalary;

  bool acceptPDPA = false;

  bool _isFullTime = false;
  bool _isPartTime = false;
  bool _isNearArea = false;
  bool _isFarArea = false;
  bool _isOverTime = false;
  bool _isCompensation = false;

  int _selectedDay = 1;
  int _selectedMonth = 1;
  int _selectedYear = 1980;

  String _imageUrl = '';

  List<dynamic> files = [];
  List<dynamic> _provinceList = [];
  List<dynamic> _districtList = [];
  String _selectedProvince = '';
  String _selectedDistrict = '';
  DateTime now = DateTime.now();
  dynamic resultTeacherJobResume;

  String imagePDF = 'assets/images/pdf.png';

  @override
  void initState() {
    _firstNameEditingController = TextEditingController();
    _lastNameEditingController = TextEditingController();
    _sexEditingController = TextEditingController(text: 'ทุกเพศ');
    _educationEditingController = TextEditingController();
    _birthDayEditingController = TextEditingController(text: '');

    _phoneEditingController = TextEditingController();
    _emailEditingController = TextEditingController();
    _universityEditingController = TextEditingController();
    _facultyEditingController = TextEditingController();
    _graduationYearEditingController = TextEditingController();
    _gradeEditingController = TextEditingController();
    _remarkEditingController = TextEditingController();

    rangeSalary = RangeValues(0.0, 100000.0);
    _getProvince();

    _callRead();
    super.initState();
  }

  void dispose() {
    _firstNameEditingController.dispose();
    _lastNameEditingController.dispose();
    _sexEditingController.dispose();
    _educationEditingController.dispose();

    _phoneEditingController.dispose();
    _emailEditingController.dispose();
    _universityEditingController.dispose();
    _facultyEditingController.dispose();
    _graduationYearEditingController.dispose();
    _gradeEditingController.dispose();
    _remarkEditingController.dispose();

    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _phoneFocusNode.dispose();
    _emailFocusNode.dispose();

    super.dispose();
  }

  // _addListener() {
  //   _textFieldFocusNode.addListener(() {
  //     setState(() {
  //       _canClearTextFieldError = _textFieldFocusNode.hasFocus;
  //     });
  //   });
  // }

  _callRead() async {
    var profileCode = await storage.read(key: 'profileCode25');

    if (profileCode != '' && profileCode != null) {
      var result = await postDio('${server}m/teacherjob/resume/read', {
        'profileCode': profileCode,
      });

      if (result.length > 0) {
        setState(() {
          result = result[0];
          resultTeacherJobResume = result;
          print('resultTeacherJobResume : $resultTeacherJobResume');
          _imageUrl = result['imageUrl'];
          _firstNameEditingController.text = result['firstName'];
          _lastNameEditingController.text = result['lastName'];
          _sexEditingController.text = result['sex'];
          _birthDayEditingController.text = result['birthDay'];
          _phoneEditingController.text = result['phone'];
          _emailEditingController.text = result['email'];
          _selectedProvince = result['province'];
          _selectedDistrict = result['district'];
          _universityEditingController.text = result['university'];
          _facultyEditingController.text = result['faculty'];
          _graduationYearEditingController.text = result['graduationYear'];
          _gradeEditingController.text = result['gpa'];

          workExperience = double.parse(result['workExperience']);
          rangeSalary = RangeValues(
            double.parse(result['expectedSalaryStart']),
            double.parse(result['expectedSalaryEnd']),
          );

          _isFullTime = result['isFullTime'];
          _isPartTime = result['isPartTime'];
          _isNearArea = result['isNearArea'];
          _isFarArea = result['isFarArea'];
          _isCompensation = result['isCompensation'];
          _isOverTime = result['isOverTime'];

          _remarkEditingController.text = result['remark'];
          acceptPDPA = result['ispdpa'];

          // set files
          files = [];
          var filesSplit = result['files'].split(',');
          for (var i = 0; i < filesSplit.length; i++) {
            var splitTitle = filesSplit[i].split('.');

            String type = filesSplit[i];
            type = splitTitle[splitTitle.length - 1];

            files.add({
              'type': type,
              'value': filesSplit[i],
              'id': random.nextInt(100),
            });
          }
          _getDistrict();
        });
      }
      // else {
      //   return toastFail(context);
      // }
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
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(0xFFE4E4E4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.keyboard_arrow_left_rounded),
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
                        onTap:
                            () => _showPickerImage(
                              context,
                              title: 'เพิ่มรูปทางการ',
                            ),
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
                                    'เพิ่มรูปทางการ',
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
                    'การศึกษา',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'กรุณากรอกประวัติของท่าน เพื่อที่เราจะทำการหางานที่เหมาะกับท่าน',
                    style: TextStyle(fontSize: 13, color: Color(0xFF707070)),
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _textFormSearchWork(
                          _firstNameEditingController,
                          labelText: 'ชื่อ',
                          focusNode: _firstNameFocusNode,
                          validator: (value) {
                            if (value.isEmpty) {
                              _firstNameFocusNode.requestFocus();
                              return 'กรุณากรอกข้อมูลชื่อ';
                            }
                          },
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _textFormSearchWork(
                          _lastNameEditingController,
                          labelText: 'นามสกุล',
                          focusNode: _lastNameFocusNode,
                          validator: (value) {
                            if (value.isEmpty) {
                              _lastNameFocusNode.requestFocus();
                              return 'กรุณากรอกข้อมูลนามสกุล';
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _textFormSearchWork(
                          _phoneEditingController,
                          labelText: 'เบอร์โทรศัพท์',
                          focusNode: _phoneFocusNode,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              _phoneFocusNode.requestFocus();
                              return 'กรุณากรอกข้อมูลเบอร์โทรศัพท์';
                            }
                          },
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                            LengthLimitingTextInputFormatter(10),
                          ],
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _textFormSearchWork(
                          _emailEditingController,
                          labelText: 'อีเมล',
                          focusNode: _emailFocusNode,
                          validator: (value) {
                            if (value.isEmpty) {
                              _emailFocusNode.requestFocus();
                              return 'กรุณากรอกข้อมูลอีเมล';
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: DropdownButtonFormField(
                          decoration: _searchDecoration(),
                          validator:
                              (value) =>
                                  value == '' || value == null ? 'เพศ' : null,
                          hint: SizedBox(
                            width: 100,
                            child: Text(
                              'เพศ',
                              style: TextStyle(
                                fontSize: 13.00,
                                color: Color(0xFF707070),
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: Colors.black,
                          ),
                          value: _sexEditingController.text,
                          onChanged: (newValue) {
                            setState(() {
                              _sexEditingController.text =
                                  (newValue ?? "").toString();
                            });
                          },
                          selectedItemBuilder: (BuildContext context) {
                            return [
                              {'display': 'ทุกเพศ', 'value': 'ทุกเพศ'},
                              {'display': 'ชาย', 'value': 'ชาย'},
                              {'display': 'หญิง', 'value': 'หญิง'},
                            ].map<Widget>((item) {
                              return SizedBox(
                                width: 100,
                                child: Text(
                                  item['display'].toString(),
                                  style: TextStyle(
                                    fontSize: 15.00,
                                    fontFamily: 'Kanit',
                                    color:
                                        item['value'] == ''
                                            ? Color(0xFF707070)
                                            : Colors.black,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                              );
                            }).toList();
                          },
                          items:
                              [
                                {'display': 'ทุกเพศ', 'value': 'ทุกเพศ'},
                                {'display': 'ชาย', 'value': 'ชาย'},
                                {'display': 'หญิง', 'value': 'หญิง'},
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
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => dialogOpenPickerDate(),
                          child: Container(
                            height: 48,
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(
                                width: 1,
                                color: Color(0xFFE4E4E4),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _birthDayEditingController.text == ''
                                      ? 'วันเดือนปีเกิด'
                                      : _birthDayEditingController.text,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color:
                                        _birthDayEditingController.text == ''
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
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 25),
                  Text(
                    'ที่พักอาศัยของท่าน',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _provinceWidget()),
                      SizedBox(width: 8),
                      Expanded(child: _districtWidget()),
                    ],
                  ),
                  SizedBox(height: 25),
                  Text(
                    'การศึกษา',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _textFormSearchWork(
                          _universityEditingController,
                          labelText: 'มหาลัย',
                          validator: (value) {},
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _textFormSearchWork(
                          _facultyEditingController,
                          labelText: 'คณะ / เอก',
                          validator: (value) {},
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _textFormSearchWork(
                          _graduationYearEditingController,
                          labelText: 'ปีที่จบการศึกษา',
                          validator: (value) {},
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                            LengthLimitingTextInputFormatter(4),
                          ],
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _textFormSearchWork(
                          _gradeEditingController,
                          validator: (value) {},
                          labelText: 'เกรดเฉลี่ย',
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.]'),
                            ),
                            LengthLimitingTextInputFormatter(4),
                          ],
                        ),
                      ),
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
                    workExperience == 30
                        ? 'ระยะเวลา 30+ ปี'
                        : 'ระยะเวลา ${workExperience.floor()} ปี',
                  ),
                  SizedBox(height: 10),
                  Text(
                    'เงินเดือนที่คาดหวัง',
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${rangeSalary.start.floor()}'),
                      Text('${rangeSalary.end.floor()}'),
                    ],
                  ),
                  SizedBox(height: 25),
                  Text(
                    'ความต้องการอื่นๆ',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'ท่านสามารถระบุความต้องการ เพื่อให้ได้งานที่ตรงใจท่านมากที่สุด',
                    style: TextStyle(fontSize: 13, color: Color(0xFF707070)),
                  ),
                  SizedBox(height: 10),
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
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _otherFilter(
                          'ใกล้พื้นที่อยู่',
                          _isNearArea,
                          onTap:
                              () => setState(() => _isNearArea = !_isNearArea),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _otherFilter(
                          'ไกลพื้นที่',
                          _isFarArea,
                          onTap: () => setState(() => _isFarArea = !_isFarArea),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _otherFilter(
                          'มีค่าล่วงเวลา',
                          _isOverTime,
                          onTap:
                              () => setState(() => _isOverTime = !_isOverTime),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _otherFilter(
                          'มีค่าตอบแทนเพิ่มเติม',
                          _isCompensation,
                          onTap:
                              () => setState(
                                () => _isCompensation = !_isCompensation,
                              ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 25),
                  Text(
                    'แนบไฟล์เพิ่มเติม',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'ท่านสามารถแนบใบประกอบวิชาชีพ และประวัติผลงาน (Resume) โดยเป็นไฟล์นามสกุล pdf หรือ jpg',
                    style: TextStyle(fontSize: 13, color: Color(0xFF707070)),
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 150,
                    padding: EdgeInsets.all(4),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(width: 1, color: Color(0xFFE4E4E4)),
                    ),
                    child:
                        files.isEmpty
                            ? InkWell(
                              onTap: () {
                                if (files.isEmpty) {
                                  _showPickerImage(
                                    context,
                                    file: true,
                                    title: 'แนบไฟล์เพิ่มเติม',
                                  );
                                }
                              },
                              child: Image.asset(
                                'assets/images/add_image_file.png',
                                height: 70,
                                width: 70,
                              ),
                            )
                            : _listViewFiles(),
                  ),
                  SizedBox(height: 25),
                  Text(
                    'เพิ่มเติม',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _remarkEditingController,
                    decoration: _searchDecoration(
                      labelText: 'อื่นๆ ที่อยากบอกให้เพิ่มเติม',
                    ),
                    minLines: 6,
                    maxLines: 6,
                  ),
                  SizedBox(height: 30),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            acceptPDPA = !acceptPDPA;
                          });
                        },
                        child: Container(
                          height: 30,
                          width: 30,
                          child:
                              acceptPDPA
                                  ? Image.asset(
                                    'assets/images/check_box_pdpa.png',
                                  )
                                  : Image.asset(
                                    'assets/images/empty_check_box_pdpa.png',
                                  ),
                        ),
                      ),
                      SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ยินยอมให้ใช้ข้อมูล PDPA',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            // onTap: () =>
                            //     toastFail(context, text: 'อ่านข้อมูลเพิ่มเติม'),
                            onTap: () {
                              launch('https://policy.we-builds.com/opec2/');
                            },
                            child: Text(
                              'อ่านข้อมูลเพิ่มเติม',
                              style: TextStyle(
                                fontSize: 15,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          Text(
                            '* หากผ่านหน้าจอนี้ไป แสดงว่าคุณยอมรับ',
                            style: TextStyle(
                              fontSize: 13.00,
                              fontFamily: 'Kanit',
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF707070),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 65),
                  GestureDetector(
                    onTap: () async {
                      final form = _formKey.currentState;
                      if (form != null && form.validate()) {
                        if (!acceptPDPA) {
                          return toastFail(
                            context,
                            text: 'ยินยอมให้ใช้ข้อมูล PDPA',
                          );
                        } else {
                          bool status = await _save();
                          if (status) {
                            if (widget.title == 'แก้ไขข้อมูล') {
                              Navigator.pop(context);
                            } else {
                              await _callRead();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => TeacherJobPage(
                                        model: resultTeacherJobResume,
                                      ),
                                ),
                              );
                            }
                          } else {
                            return toastFail(context, text: 'เกิดข้อผิดพลาด');
                          }
                        }
                      }
                    },
                    child: Container(
                      height: 40,
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color:
                            acceptPDPA
                                ? Color(0xFFEEBA33)
                                : Colors.black.withOpacity(0.4),
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

  dialogOpenPickerDate() {
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
          _birthDayEditingController.value = TextEditingValue(
            text: DateFormat("dd/MM/yyyy").format(date),
          );
        });
      },
      currentTime: DateTime(_selectedYear, _selectedMonth, _selectedDay),
      locale: dtpicker.LocaleType.th,
    );
  }

  ClipRRect _listViewFiles() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: ClampingScrollPhysics(),
        children: [
          ...files
              .map<Widget>(
                (e) => Padding(
                  padding: EdgeInsets.only(right: 5),
                  child: Stack(
                    children: [
                      InkWell(
                        onTap:
                            () => launchUrl(
                              Uri.parse(e['value']),
                              mode: LaunchMode.externalApplication,
                            ),
                        child: Container(
                          height: double.infinity,
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Color(0xFFE4E4E4)),
                          ),
                          child:
                          // Text(e['type']),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child:
                                e['type'] == 'pdf'
                                    ? Image.asset(imagePDF)
                                    : loadingImageNetwork(
                                      e['value'],
                                      fit: BoxFit.contain,
                                    ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 3,
                        top: 3,
                        child: GestureDetector(
                          onTap:
                              (() => setState(
                                () => files.removeWhere(
                                  (c) => c['id'] == e['id'],
                                ),
                              )),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(
                              Icons.remove_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              _showPickerImage(context, file: true, title: 'แนบไฟล์เพิ่มเติม');
            },
            child: Container(
              height: double.infinity,
              width: 100,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Color(0xFFE4E4E4)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/add_image_file.png',
                  height: 50,
                  width: 50,
                ),
              ),
            ),
          ),
        ],
      ),
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

  void _filePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
    );
    // , allowedExtensions: ['jpg', 'png', 'pdf']

    if (result != null) {
      List<String> wh = [];
      String notSupport = '';
      result.paths.forEach((e) {
        String type = '';
        var splitTitle = (e ?? "").split('.');
        type = splitTitle[splitTitle.length - 1];
        if (type == 'jpeg' || type == 'jpg' || type == 'png' || type == 'pdf') {
          wh.add(e ?? "");
        } else {
          notSupport = type;
        }
      });

      if (notSupport != '') {
        toastFail(context, text: 'ไม่รองรับไฟล์ $notSupport');
        return;
      }

      List<File> res = wh.map((path) => File(path)).toList();
      _upload(res);
    } else {
      // User canceled the picker
    }
  }

  void _upload(List<File> values) async {
    values.forEach((c) async {
      uploadFile(c, caption: 'resume')
          .then((res) {
            String type = 'png';
            var splitTitle = res.split('.');
            type = splitTitle[splitTitle.length - 1];

            setState(() {
              files.add({
                'type': type,
                'value': res,
                'id': random.nextInt(100),
              });
            });
          })
          .catchError((err) {
            return;
            // print(err);
          });
    });
  }

  _save() async {
    String filesString = '';
    files.forEach((e) {
      if (filesString == '') {
        filesString = e['value'];
      } else {
        filesString = '$filesString,' + e['value'];
      }
    });

    // var province =
    //     _provinceList.firstWhere((e) => e['code'] == _selectedProvince);
    // var district =
    //     _districtList.firstWhere((e) => e['code'] == _selectedDistrict);

    var birth = _birthDayEditingController.text.replaceAll('-', '');
    var result = await postDio('${server}m/teacherjob/resume/cau', {
      'imageUrl': _imageUrl,
      'firstName': _firstNameEditingController.text,
      'lastName': _lastNameEditingController.text,
      'sex': _sexEditingController.text,
      'birthDay': birth,
      'phone': _phoneEditingController.text,
      'email': _emailEditingController.text,
      'province': _selectedProvince,
      'district': _selectedDistrict,
      'university': _universityEditingController.text,
      'faculty': _facultyEditingController.text,
      'graduationYear': _graduationYearEditingController.text,
      'gpa': _gradeEditingController.text,
      'workExperience': workExperience.floor().toString(),
      'expectedSalaryStart': rangeSalary.start.floor().toString(),
      'expectedSalaryEnd': rangeSalary.end.floor().toString(),
      'isFullTime': _isFullTime,
      'isPartTime': _isPartTime,
      'isNearArea': _isNearArea,
      'isFarArea': _isFarArea,
      'isOverTime': _isOverTime,
      'isCompensation': _isCompensation,
      'remark': _remarkEditingController.text,
      'ispdpa': acceptPDPA,
      'files': filesString,
    });
    if (result != null) {
      storage.write(key: 'resumeCode', value: result['code']);
      await storage.write(key: 'resumeData', value: jsonEncode(result));
      return true;
    } else {
      return false;
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

  // image picker

  void _showPickerImage(context, {bool file = false, String title = ''}) {
    print('title : $title');
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
                    _imgFromGallery(title);
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
                    _imgFromCamera(title);
                    Navigator.of(context).pop();
                  },
                ),
                if (file)
                  ListTile(
                    leading: Icon(Icons.picture_as_pdf_sharp),
                    title: Text(
                      'เลือกไฟล์ pdf',
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Kanit',
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    onTap: () {
                      _filePicker();
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

  _imgFromCamera(String title) async {
    print('title : $title');
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      _uploadImage(image, title);
    }
  }

  _imgFromGallery(String title) async {
    print('title : $title');
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _uploadImage(image, title);
    }
  }

  void _uploadImage(XFile image, String title) async {
    print('title : $title');

    uploadImage(image)
        .then((res) {
          if (title == 'เพิ่มรูปทางการ') {
            setState(() {
              _imageUrl = res;
            });
          } else {
            String type = res;
            var splitTitle = res.split('.');
            type = splitTitle[splitTitle.length - 1];

            setState(() {
              files.add({
                'type': type,
                'value': res,
                'id': random.nextInt(100),
              });
            });
          }
        })
        .catchError((err) {
          print(err);
        });
  }
}
