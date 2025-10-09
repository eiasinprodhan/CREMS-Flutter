import 'package:crems/entity/Employee.dart';

class Project {
  int? id;
  String? name;
  int? budget;
  String? startDate;
  String? expectedEndDate;
  String? projectType;
  Employee? projectManager;
  String? description;

  Project({this.id, this.name, this.budget, this.startDate, this.expectedEndDate, this.projectType, this.projectManager, this.description});

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'],
      budget: json['budget'],
      startDate: json['startDate'],
      expectedEndDate: json['expectedEndDate'],
      projectType: json['projectType'],
      projectManager: json['projectManager'] != null ? Employee.fromJson(json['projectManager']) : null,
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'budget': budget,
      'startDate': startDate,
      'expectedEndDate': expectedEndDate,
      'projectType': projectType,
      'projectManager': projectManager?.toJson(),
      'description': description,
    };
  }
}