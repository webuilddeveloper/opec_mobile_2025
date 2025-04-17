import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:opec/shared/api_provider.dart';
import 'package:opec/widget/loading.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as dtpicker;

class ProfileJobBySchoolPage extends StatefulWidget {
  const ProfileJobBySchoolPage({Key? key, this.model}) : super(key: key);

  final dynamic model;

  @override
  State<ProfileJobBySchoolPage> createState() => _ProfileJobBySchoolPageState();
}

class _ProfileJobBySchoolPageState extends State<ProfileJobBySchoolPage> {
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
    _callRead(widget.model);
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
                      Stack(
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
                    ],
                  ),
                  SizedBox(height: 30),
                  Text(
                    'การศึกษา',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
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
                          enabled: false,
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
                          enabled: false,
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
                          enabled: false,
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
                          enabled: false,
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
                          enableFeedback: true,
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
                          onChanged: null,
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
                                    color: Color(0xFF707070),
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
                                        color: Color(0xFF707070),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
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
                                  color: Color(0xFF707070),
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
                          enabled: false,
                          validator: (value) {},
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _textFormSearchWork(
                          _facultyEditingController,
                          labelText: 'คณะ / เอก',
                          enabled: false,
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
                          enabled: false,
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
                          enabled: false,
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
                    onChanged: null,
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
                    onChanged: null,
                    min: 0,
                    max: 100000,
                    divisions: 100000,
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
                          onTap: null,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _otherFilter(
                          'งานชั่วคราว',
                          _isPartTime,
                          onTap: null,
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
                          onTap: null,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _otherFilter(
                          'ไกลพื้นที่',
                          _isFarArea,
                          onTap: null,
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
                          onTap: null,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _otherFilter(
                          'มีค่าตอบแทนเพิ่มเติม',
                          _isCompensation,
                          onTap: null,
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
                            ? Image.asset(
                              'assets/images/add_image_file.png',
                              height: 70,
                              width: 70,
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
                    enabled: false,
                    style: TextStyle(color: Colors.grey),
                    decoration: _searchDecoration(
                      labelText: 'อื่นๆ ที่อยากบอกให้เพิ่มเติม',
                    ),
                    minLines: 6,
                    maxLines: 6,
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
      onChanged: null,
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
                    ],
                  ),
                ),
              )
              .toList(),
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
      style: TextStyle(color: enabled ? Colors.black : Colors.grey),
      decoration: _searchDecoration(labelText: labelText),
      validator: (value) => validator(value),
      controller: model,
      enabled: enabled,
    );
  }

  GestureDetector _otherFilter(String title, bool value, {Function()? onTap}) {
    return GestureDetector(
      onTap: () => onTap,
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
          onChanged: null,
          items:
              _provinceList.map((item) {
                return DropdownMenuItem(
                  value: item['code'],
                  child: Text(
                    item['title'],
                    style: TextStyle(
                      fontSize: 15.00,
                      fontFamily: 'Kanit',
                      color: Color(0xFF707070),
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
          onChanged: null,
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
          onChanged: null,
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
          onChanged: null,
          items:
              _districtList.map((item) {
                return DropdownMenuItem(
                  value: item['code'],
                  child: Text(item['title'], style: TextStyle(fontSize: 15.00)),
                );
              }).toList(),
        );
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

  _callRead(result) async {
    if (result != null) {
      setState(() {
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
  }

  //
}
