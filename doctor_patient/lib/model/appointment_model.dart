import 'dart:convert';

class AppointmentModel {
  String id;
  String? departmentId;
  String? doctorId;
  DateTime? date;
  DateTime? time;

  AppointmentModel({
    this.id = '',
    this.departmentId,
    this.doctorId,
    this.date,
    this.time,
  });

  // sending data to our server
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'departmentId': departmentId,
      'doctorId': doctorId,
      'date': date,
      'time': time,
    };
  }
}
