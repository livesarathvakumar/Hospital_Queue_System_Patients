import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_patient/model/user_model.dart';
import 'package:doctor_patient/screen/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'login_screen.dart';

class PatientsHomeScreen extends StatefulWidget {
  const PatientsHomeScreen({Key? key}) : super(key: key);

  @override
  _PatientsHomeScreenState createState() => _PatientsHomeScreenState();
}

enum MenuItem {
  profilepage,
  logout,
}

class _PatientsHomeScreenState extends State<PatientsHomeScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      this.loggedInUser = UserModel.fromMap(value.data());
      setState(() {});
    });
  }

  final Query<Map<String, dynamic>> _doctors = FirebaseFirestore.instance
      .collection('users')
      .where('role', isEqualTo: 'doctor');

  final CollectionReference _products =
      FirebaseFirestore.instance.collection('departments');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient Home"),
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
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(36.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[],
              ),
            ),
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
