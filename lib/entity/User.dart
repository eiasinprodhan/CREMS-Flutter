class User {
  int? id;
  String? name;
  String? email;
  String? phone;
  String? password;
  String? photo;
  String? role;
  List<Null>? tokens;
  bool? active;
  bool? enabled;
  String? username;
  bool? credentialsNonExpired;
  bool? accountNonExpired;
  bool? accountNonLocked;
  bool? lock;

  User(
      {this.id,
        this.name,
        this.email,
        this.phone,
        this.password,
        this.photo,
        this.role,
        this.tokens,
        this.active,
        this.enabled,
        this.username,
        this.credentialsNonExpired,
        this.accountNonExpired,
        this.accountNonLocked,
        this.lock});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    password = json['password'];
    photo = json['photo'];
    role = json['role'];
    if (json['tokens'] != null) {
      tokens = <Null>[];
      json['tokens'].forEach((v) {
        tokens!.add(new Null.fromJson(v));
      });
    }
    active = json['active'];
    enabled = json['enabled'];
    username = json['username'];
    credentialsNonExpired = json['credentialsNonExpired'];
    accountNonExpired = json['accountNonExpired'];
    accountNonLocked = json['accountNonLocked'];
    lock = json['lock'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['password'] = this.password;
    data['photo'] = this.photo;
    data['role'] = this.role;
    if (this.tokens != null) {
      data['tokens'] = this.tokens!.map((v) => v.toJson()).toList();
    }
    data['active'] = this.active;
    data['enabled'] = this.enabled;
    data['username'] = this.username;
    data['credentialsNonExpired'] = this.credentialsNonExpired;
    data['accountNonExpired'] = this.accountNonExpired;
    data['accountNonLocked'] = this.accountNonLocked;
    data['lock'] = this.lock;
    return data;
  }
}