import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:opec/pages/teacher_job/job_list_teacher.dart';
import 'package:opec/pages/teacher_job/notification_job.dart';
import 'package:opec/shared/api_provider.dart';

class SearchListJobTeacherPage extends StatefulWidget {
  @override
  _SearchListJobTeacherPageState createState() =>
      _SearchListJobTeacherPageState();
}

class _SearchListJobTeacherPageState extends State<SearchListJobTeacherPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final storage = FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();
  List<dynamic> _provinceList = [];
  List<dynamic> _districtList = [];
  String _selectedProvince = '';
  String _selectedDistrict = '';
  late TextEditingController _jobTypeEditingController;
  late TextEditingController _salaryStartEditingController;
  late TextEditingController _salaryEndEditingController;
  final FocusNode _salaryStartFocusNode = FocusNode();
  final FocusNode _salaryEndFocusNode = FocusNode();

  dynamic profile = {'firstName': '', 'lastName': ''};

  String apiKey = '';

  void initState() {
    // GooglePlace(apiKey, headers: {'location': 'ORLEANS_LAT,ORLEANS_LNG'});

    _jobTypeEditingController = TextEditingController(text: '');
    _salaryStartEditingController = TextEditingController(text: '0');
    _salaryEndEditingController = TextEditingController(text: '100000');
    _getProvince();
    // _getGeoLocationPosition();
    _callResumeData();
    // _callReadCount();
    super.initState();
  }

  // _callReadCount() async {
  //   var profileCode = await storage.read(key: 'profileCode25');
  //   var result = await postDio(server + 'm/teacherjob/resume/count', {
  //     'profileCode': profileCode,
  //   });

  //   setState(() {
  //     _countData = result;
  //   });
  // }

  void dispose() {
    _jobTypeEditingController.dispose();
    _salaryStartEditingController.dispose();
    _salaryEndEditingController.dispose();
    super.dispose();
  }

  _callResumeData() async {
    var value = await storage.read(key: 'resumeData') ?? "";
    var result = json.decode(value);

    setState(() {
      profile = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      endDrawer: NotificationJobDrawer(),
      endDrawerEnableOpenDragGesture: false,
      drawerEdgeDragWidth: 0,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [Container()],
        backgroundColor: Colors.white,
        toolbarHeight: 50,
        flexibleSpace: Container(
          margin: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 10,
            left: 15,
            right: 15,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
      body: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
          TextEditingController().clear();
        },
        child: ListView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 15),
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 15),
                  _provinceWidget(),
                  SizedBox(height: 15),
                  _districtWidget(),
                  SizedBox(height: 15),
                  _jobTypeWidget(),
                  SizedBox(height: 15),
                  _salaryWidget(
                    _salaryStartEditingController,
                    'เงินเดือนเริ่มต้น',
                    _salaryStartFocusNode,
                    'กรุณากรอกข้อมูลเงินเดือนเริ่มต้น เช่น 0',
                  ),
                  SizedBox(height: 15),
                  _salaryWidget(
                    _salaryEndEditingController,
                    'เงินเดือนสิ้นสุด',
                    _salaryEndFocusNode,
                    'กรุณากรอกข้อมูลเงินเดือนสิ้นสุด เช่น 100000',
                  ),
                  SizedBox(height: 15),
                ],
              ),
            ),
            GestureDetector(
              onTap: () async {
                final form = _formKey.currentState;
                if (form != null && form.validate()) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => JobListTeacherPage(
                            province: _selectedProvince,
                            district: _selectedDistrict,
                            jobType: _jobTypeEditingController.text,
                            salaryStart: _salaryStartEditingController.text,
                            salaryEnd: _salaryEndEditingController.text,
                          ),
                    ),
                  );
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
                  'ค้นหา',
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 10),
          ],
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

  _jobTypeWidget() {
    return DropdownButtonFormField(
      decoration: _searchDecoration(),
      // validator: (value) => value == '' || value == null ? 'ประเภทงาน' : null,
      hint: SizedBox(
        width: 100,
        child: Text(
          'ประเภทงาน',
          style: TextStyle(fontSize: 13.00, color: Color(0xFF707070)),
          textAlign: TextAlign.start,
        ),
      ),
      icon: Icon(Icons.arrow_drop_down, color: Colors.black),
      value: _jobTypeEditingController.text,
      onChanged: (newValue) {
        setState(() {
          _jobTypeEditingController.text = (newValue ?? "").toString();
        });
      },
      selectedItemBuilder: (BuildContext context) {
        return [
          {'display': 'ทั้งหมด', 'value': ''},
          {'display': 'ประจำ', 'value': '0'},
          {'display': 'ไม่ประจำ', 'value': '1'},
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
            {'display': 'ทั้งหมด', 'value': ''},
            {'display': 'ประจำ', 'value': '0'},
            {'display': 'ไม่ประจำ', 'value': '1'},
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

  _provinceWidget() {
    // List<dynamic> list = [
    //   {'code': '', 'title': 'ทั้งหมด'}
    // ];
    // list = [...list, ..._provinceList];
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
              _selectedDistrict = '';
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
              _selectedDistrict = '';
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

  _salaryWidget(
    TextEditingController editingController,
    String labelText,
    FocusNode focusNode,
    String validatorText,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _textFormSearchWork(
            editingController,
            labelText: labelText,
            focusNode: focusNode,
            validator: (value) {
              if (value == null || value.isEmpty) {
                focusNode.requestFocus();
                return validatorText;
              }
            },
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
            ],
          ),
        ),
      ],
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

  //
}
