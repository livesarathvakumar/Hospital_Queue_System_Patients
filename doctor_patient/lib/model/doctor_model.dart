import 'dart:convert';

class DoctorModel {
  String id;
  String? firstName;

  DoctorModel({
    this.id = '',
    this.firstName,
  });

  // sending data to our server
  Map<String, dynamic> toJson() {
    return {'id': id, 'firstName': firstName, 'role': 'doctor'};
  }
}
