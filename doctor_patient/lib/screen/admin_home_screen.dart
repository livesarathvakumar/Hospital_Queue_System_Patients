import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_patient/model/user_model.dart';
import 'package:doctor_patient/screen/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:doctor_patient/screen/patients_list_screen.dart';
import 'package:doctor_patient/screen/departments_list_screen.dart';
import 'package:doctor_patient/screen/doctors_list_screen.dart';

import 'login_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

enum MenuItem {
  profilepage,
  logout,
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  @override
  Widget build(BuildContext context) {
    final departmentBtn = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(5),
      color: Colors.green,
      child: MaterialButton(
          padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          minWidth: MediaQuery.of(context).size.width,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const DepartmentListScreen()),
            );
          },
          child: Text(
            "Departments",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          )),
    );

    final doctorsListBtn = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(5),
      color: Colors.green,
      child: MaterialButton(
          padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          minWidth: MediaQuery.of(context).size.width,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const DoctorsListScreen()),
            );
          },
          child: Text(
            "Doctors",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          )),
    );

    final patientsListBtn = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(5),
      color: Colors.green,
      child: MaterialButton(
          padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          minWidth: MediaQuery.of(context).size.width,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const PatientsListScreen()),
            );
          },
          child: Text(
            "Patients",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          )),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[800],
        title: const Text("Admin Dashboard"),
        centerTitle: true,
        actions: [
          PopupMenuButton<MenuItem>(
            onSelected: (value) {
              if (value == MenuItem.profilepage) {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => UserProfile()));
              } else if (value == MenuItem.logout) {
                logout(context);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                  value: MenuItem.profilepage, child: Text('Profile')),
              PopupMenuItem(value: MenuItem.logout, child: Text('Logout'))
            ],
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              departmentBtn,
              SizedBox(
                height: 15,
              ),
              doctorsListBtn,
              SizedBox(
                height: 15,
              ),
              patientsListBtn,
              SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // the logout function
  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()));
  }
}
