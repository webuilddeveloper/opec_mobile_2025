class LoginRegister {
  final String? status;
  final String? message;
  final User? objectData;

  LoginRegister({this.status, this.message, this.objectData});

  factory LoginRegister.fromJson(Map<String, dynamic> json) {
    return LoginRegister(
      status: json['status'] as String?,
      message: json['message'] as String?,
      objectData:
          json['objectData'] != null && json['objectData'] != ''
              ? User.fromJson(json['objectData'] as Map<String, dynamic>)
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'objectData': objectData?.toJson(),
  };
}

class User {
  String? prefixName = '';
  String? firstName = '';
  String? lastName = '';
  String? email = "";
  String? category = "";
  String? code = "";
  String? username = "";
  String? password = "";
  bool? isActive;
  String? status = "";
  String? createBy = "";
  String? createDate = "";
  String? imageUrl = "";
  String? updateBy = "";
  String? updateDate = "";
  String? birthDay = "";
  String? phone = "";
  String? facebookID = "";
  String? googleID = "";
  String? lineID = "";
  String? appleID = "";
  String? line = "";
  String? sex = "";
  String? address = "";
  String? tambonCode = "";
  String? tambon = "";
  String? amphoeCode = "";
  String? amphoe = "";
  String? provinceCode = "";
  String? province = "";
  String? postnoCode = "";
  String? postno = "";
  String? job = "";
  String? idcard = "";
  String? countUnit = "";
  String? lv0 = "";
  String? lv1 = "";
  String? lv2 = "";
  String? lv3 = "";
  String? lv4 = "";
  String? lv5 = "";
  String? linkAccount = "";
  String? officerCode = "";
  bool? checkOrganization = false;
  String? opecCategoryId = '';

  User.map(dynamic json) {
    prefixName = json['prefixName'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    email = json['email'];
    category = json['category'];
    code = json['code'];
    username = json['username'];
    password = json['password'];
    isActive = json['isActive'];
    status = json['status'];
    createBy = json['createBy'];
    createDate = json['createDate'];
    imageUrl = json['imageUrl'];
    updateBy = json['updateBy'];
    updateDate = json['updateDate'];
    birthDay = json['birthDay'];
    phone = json['phone'];
    facebookID = json['facebookID'];
    googleID = json['googleID'];
    lineID = json['lineID'];
    appleID = json['appleID'];
    line = json['line'];
    sex = json['sex'];
    address = json['address'];
    tambonCode = json['tambonCode'];
    tambon = json['tambon'];
    amphoeCode = json['amphoeCode'];
    amphoe = json['amphoe'];
    provinceCode = json['provinceCode'];
    province = json['province'];
    postnoCode = json['postnoCode'];
    postno = json['postno'];
    job = json['job'];
    idcard = json['idcard'];
    countUnit = json['countUnit'];
    lv0 = json['lv0'];
    lv1 = json['lv1'];
    lv2 = json['lv2'];
    lv3 = json['lv3'];
    lv4 = json['lv4'];
    lv5 = json['lv5'];
    linkAccount = json['linkAccount'];
    officerCode = json['officerCode'];
    checkOrganization = json['checkOrganization'];
    opecCategoryId = json['opecCategoryId'];
  }

  factory User.fromJson(dynamic json) {
    return User(
      prefixName: json['prefixName'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      category: json['category'] ?? '',
      code: json['code'] ?? '',
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      isActive: json['isActive'] ?? '',
      status: json['status'] ?? '',
      createBy: json['createBy'] ?? '',
      createDate: json['createDate'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      updateBy: json['updateBy'] ?? '',
      updateDate: json['updateDate'] ?? '',
      birthDay: json['birthDay'] ?? '',
      phone: json['phone'] ?? '',
      facebookID: json['facebookID'] ?? '',
      googleID: json['googleID'] ?? '',
      lineID: json['lineID'] ?? '',
      appleID: json['appleID'] ?? '',
      line: json['line'] ?? '',
      sex: json['sex'] ?? '',
      address: json['address'] ?? '',
      tambonCode: json['tambonCode'] ?? '',
      tambon: json['tambon'] ?? '',
      amphoeCode: json['amphoeCode'] ?? '',
      amphoe: json['amphoe'] ?? '',
      provinceCode: json['provinceCode'] ?? '',
      province: json['province'] ?? '',
      postnoCode: json['postnoCode'] ?? '',
      postno: json['postno'] ?? '',
      job: json['job'] ?? '',
      idcard: json['idcard'] ?? '',
      countUnit: json['countUnit'] ?? '',
      lv0: json['lv0'] ?? '',
      lv1: json['lv1'] ?? '',
      lv2: json['lv2'] ?? '',
      lv3: json['lv3'] ?? '',
      lv4: json['lv4'] ?? '',
      lv5: json['lv5'] ?? '',
      linkAccount: json['linkAccount'] ?? '',
      officerCode: json['officerCode'] ?? '',
      checkOrganization: json['checkOrganization'] ?? false,
      opecCategoryId: json['opecCategoryId'] ?? '0',
    );
  }

  User({
    this.prefixName,
    this.firstName,
    this.lastName,
    this.email,
    this.category,
    this.code,
    this.username,
    this.password,
    this.isActive,
    this.status,
    this.createBy,
    this.createDate,
    this.imageUrl,
    this.updateBy,
    this.updateDate,
    this.birthDay,
    this.phone,
    this.facebookID,
    this.googleID,
    this.lineID,
    this.appleID,
    this.line,
    this.sex,
    this.address,
    this.tambonCode,
    this.tambon,
    this.amphoeCode,
    this.amphoe,
    this.provinceCode,
    this.province,
    this.postnoCode,
    this.postno,
    this.job,
    this.idcard,
    this.countUnit,
    this.lv0,
    this.lv1,
    this.lv2,
    this.lv3,
    this.lv4,
    this.lv5,
    this.linkAccount,
    this.officerCode,
    this.checkOrganization,
    this.opecCategoryId,
  });

  Map<String, dynamic> toJson() => {
    'prefixName': prefixName,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'category': category,
    'code': code,
    'username': username,
    'password': password,
    'isActive': isActive,
    'status': status,
    'createBy': createBy,
    'createDate': createDate,
    'imageUrl': imageUrl,
    'updateBy': updateBy,
    'updateDate': updateDate,
    'birthDay': birthDay,
    'phone': phone,
    'facebookID': facebookID,
    'googleID': googleID,
    'lineID': lineID,
    'appleID': appleID,
    'line': line,
    'sex': sex,
    'address': address,
    'tambonCode': tambonCode,
    'tambon': tambon,
    'amphoeCode': amphoeCode,
    'amphoe': amphoe,
    'provinceCode': provinceCode,
    'province': province,
    'postnoCode': postnoCode,
    'postno': postno,
    'job': job,
    'idcard': idcard,
    'countUnit': countUnit,
    'lv0': lv0,
    'lv1': lv1,
    'lv2': lv2,
    'lv3': lv3,
    'lv4': lv4,
    'lv5': lv5,
    'linkAccount': linkAccount,
    'officerCode': officerCode,
    'checkOrganization': checkOrganization,
    'opecCategoryId': opecCategoryId,
  };

  save() {
    // print('saving user using a web service');
  }
}
