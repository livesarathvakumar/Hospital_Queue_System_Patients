import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_patient/model/user_model.dart';
import 'package:doctor_patient/screen/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:doctor_patient/screen/add_department_screen.dart';
import 'package:doctor_patient/screen/admin_home_screen.dart';
import 'package:doctor_patient/screen/patient_home_screen.dart';

import 'login_screen.dart';

class ViewQueueScreen extends StatefulWidget {
  const ViewQueueScreen({Key? key}) : super(key: key);

  @override
  _ViewQueueScreenState createState() => _ViewQueueScreenState();
}

enum MenuItem {
  profilepage,
  logout,
  dashboard,
}

class _ViewQueueScreenState extends State<ViewQueueScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  final Query<Map<String, dynamic>> appointment =
      FirebaseFirestore.instance.collection('appointment').orderBy("token");

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as ViewQueueArguments;
    print(args.doctorId);
    print(args.departmentId);
    print(args.date);
    print('args.doctorId');
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: SizedBox(
        height: 60,
        width: 60,
        child: FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          elevation: 5.0,
          tooltip: "Press to Add Department",
          splashColor: Colors.blueAccent,
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => AddDepartment()));
          },
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.green[800],
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
              } else if (value == MenuItem.dashboard) {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => AdminHomeScreen()));
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                  value: MenuItem.profilepage, child: Text('Profile')),
              PopupMenuItem(value: MenuItem.logout, child: Text('Logout')),
              PopupMenuItem(value: MenuItem.dashboard, child: Text('Dashboard'))
            ],
          )
        ],
      ),
      body: StreamBuilder(
          stream: appointment.snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
            if (streamSnapshot.hasData) {
              return GridView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemCount: streamSnapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final DocumentSnapshot documentSnapshot =
                      streamSnapshot.data!.docs[index];
                  return SizedBox(
                      height: 50,
                      width: 100,
                      child: Card(
                          margin: const EdgeInsets.all(5),
                          child: TextButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.green),
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white),
                            ),
                            onPressed: () {},
                            child: Text(documentSnapshot['token'].toString()),
                          )));
                },
              );
            } else if (streamSnapshot.hasError) {
              return Text('has error');
            } else {
              return Text('no data');
            }
          }),
    );
  }

  // the logout function
  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()));
  }
}
