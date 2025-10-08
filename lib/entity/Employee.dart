class Employee {
  int? id;
  String? name;
  String? email;
  String? password;
  String? phone;
  int? nid;
  String? joiningDate;
  String? role;
  String? salaryType;
  int? salary;
  bool? status;
  String? photo;
  String? country;
  String? address;
  Null? totalSalary;
  Null? lastSalary;
  User? user;

  Employee(
      {this.id,
        this.name,
        this.email,
        this.password,
        this.phone,
        this.nid,
        this.joiningDate,
        this.role,
        this.salaryType,
        this.salary,
        this.status,
        this.photo,
        this.country,
        this.address,
        this.totalSalary,
        this.lastSalary,
        this.user});

  Employee.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    password = json['password'];
    phone = json['phone'];
    nid = json['nid'];
    joiningDate = json['joiningDate'];
    role = json['role'];
    salaryType = json['salaryType'];
    salary = json['salary'];
    status = json['status'];
    photo = json['photo'];
    country = json['country'];
    address = json['address'];
    totalSalary = json['totalSalary'];
    lastSalary = json['lastSalary'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['password'] = this.password;
    data['phone'] = this.phone;
    data['nid'] = this.nid;
    data['joiningDate'] = this.joiningDate;
    data['role'] = this.role;
    data['salaryType'] = this.salaryType;
    data['salary'] = this.salary;
    data['status'] = this.status;
    data['photo'] = this.photo;
    data['country'] = this.country;
    data['address'] = this.address;
    data['totalSalary'] = this.totalSalary;
    data['lastSalary'] = this.lastSalary;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}
