import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:doctor_patient/screen/patient_home_screen.dart';
import 'package:doctor_patient/screen/admin_home_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String role = 'patient';

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  void _checkRole() async {
    User? user = FirebaseAuth.instance.currentUser;
    final DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    setState(() {
      role = snap['role'];
    });

    if (role == 'patient') {
      navigateNext(PatientsHomeScreen());
    } else if (role == 'admin') {
      navigateNext(AdminHomeScreen());
    }
  }

  void navigateNext(Widget route) {
    Timer(const Duration(milliseconds: 500), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => route));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                height: 180,
                child: Image.asset(
                  "assets/doctorpatient.png",
                  fit: BoxFit.contain,
                )),
            Text('Welcome')
          ],
        ),
      ),
    );
  }
}
