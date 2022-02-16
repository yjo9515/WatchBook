class WatchbookMemberModel {
  late String joinType;
  late  String joinId;
  late String joinPw;
  late String joinRepasswd;
  late String joinName;
  late String joinNickname;
  late String joinPhone;

  WatchbookMemberModel({
    required this.joinType,
    required this.joinId,
    required this.joinPw,
    required this.joinRepasswd,
    required this.joinName,
    required this.joinNickname,
    required this.joinPhone,
  });

  WatchbookMemberModel.fromJson(Map<String, dynamic> json){
    joinType = json['type'];
    joinId = json['id'];
    joinPw = json['passwd'];
    joinRepasswd = json['repasswd'];
    joinNickname = json['nickname'];
    joinName = json['name'];
    joinPhone = json['handphone'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.joinType;
    data['id'] = this.joinId;
    data['password'] = this.joinPw;
    data['repasswd'] = this.joinRepasswd;
    data['nickname'] = this.joinNickname;
    data['name'] = this.joinName;
    data['handphone'] = this.joinPhone;
    return data;
  }

  String getId() => joinId;
}

class WatchbookCheckModel{
  bool loading;
  bool isToken;
  String url;
  bool isStudentChecked;
  bool isTeacherChecked;
  bool isAgree;
  bool isEmailAgree;
  bool isSMSAgree;

  WatchbookCheckModel({
    this.loading = true,
    this.isToken = true,
    this.url = 'http://m.watchbook.tv/',
    this.isTeacherChecked = true,
    this.isStudentChecked = false,
    this.isAgree = false,
    this.isEmailAgree = false,
    this.isSMSAgree = false
  });

}