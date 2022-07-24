import 'dart:convert';

class DoctorModel {
  String id;
  String? firstName;
  String? departmentId;

  DoctorModel({
    this.id = '',
    this.firstName,
    this.departmentId,
  });

  // sending data to our server
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'role': 'doctor',
      'departmentId': departmentId
    };
  }
}
