class UserModel{
  late var user_id;
  late var person_id;
  late var type;
  late var id;
  late var personObj;
  late var passwd;
  late var token;
  late var isUseMailling;
  late var isUseSms;
  late var level;
  late var points;
  late var cash;
  late var comment;
  late var data;
  late var memo;
  late var loginTimes;
  late var lastLogin;
  late var regDate;
  late var isUse;


  UserModel({
    required this.user_id,
    required this.person_id,
    required this.personObj,
    required this.type,
    required this.id,
    required this.passwd,
    required this.token,
    required this.isUseMailling,
    required this.isUseSms,
    required this.level,
    required this.points,
    required this.cash,
    required this.comment,
    required this.data,
    required this.memo,
    required this.loginTimes,
    required this.lastLogin,
    required this.regDate,
    required this.isUse,
  });

  UserModel.fromJson(Map<String, dynamic> json){
    user_id = json['user_id'];
    person_id = json['person_id'];
    personObj = json['personObj'];
    type = json['type'];
    id = json['id'];
    passwd = json['passwd'];
    token = json['token'];
    isUseMailling = json['isUseMailling'];
    isUseSms = json['isUseSms'];
    level = json['level'];
    points = json['points'];
    cash = json['cash'];
    comment = json['comment'];
    data = json['data'];
    memo = json['memo'];
    loginTimes = json['loginTimes'];
    lastLogin = json['lastLogin'];
    regDate = json['regDate'];
    isUse = json['isUse'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.user_id;
    data['person_id'] = this.person_id;
    data['personObj'] = this.personObj;
    data['type'] = this.type;
    data['id'] = this.id;
    data['passwd'] = this.passwd;
    data['token'] = this.token;
    data['isUseMailling'] = this.isUseMailling;
    data['isUseSms'] = this.isUseSms;
    data['level'] = this.level;
    data['points'] = this.points;
    data['cash'] = this.cash;
    data['comment'] = this.comment;
    data['data'] = this.data;
    data['memo'] = this.memo;
    data['loginTimes'] = this.loginTimes;
    data['lastLogin'] = this.lastLogin;
    data['regDate'] = this.regDate;
    data['isUse'] = this.isUse;
    return data;
  }

}