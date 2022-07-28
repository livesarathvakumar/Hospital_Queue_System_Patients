import 'dart:convert';

class AppointmentModel {
  String id;
  String? departmentId;
  String? departmentName;
  String? doctorId;
  String? doctorName;
  String? date;
  String? userId;

  AppointmentModel({
    this.id = '',
    this.departmentId,
    this.departmentName,
    this.doctorId,
    this.doctorName,
    this.date,
    this.userId,
  });

  // sending data to our server
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'departmentId': departmentId,
      'departmentName': departmentName,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'date': date,
      'userId': userId,
    };
  }
}
