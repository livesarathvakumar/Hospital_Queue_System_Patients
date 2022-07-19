import 'dart:convert';

class DepartmentModel {
  String id;
  String? name;

  DepartmentModel({
    this.id = '',
    this.name,
  });

  // sending data to our server
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
