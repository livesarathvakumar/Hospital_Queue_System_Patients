import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_patient/model/user_model.dart';
import 'package:doctor_patient/screen/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:doctor_patient/screen/add_department_screen.dart';
import 'package:doctor_patient/screen/admin_home_screen.dart';

import 'login_screen.dart';

class DepartmentListScreen extends StatefulWidget {
  const DepartmentListScreen({Key? key}) : super(key: key);

  @override
  _DepartmentListScreenState createState() => _DepartmentListScreenState();
}

enum MenuItem {
  profilepage,
  logout,
  dashboard,
}

class _DepartmentListScreenState extends State<DepartmentListScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  final CollectionReference _products =
      FirebaseFirestore.instance.collection('departments');

  @override
  Widget build(BuildContext context) {
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
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => AddDepartment()));
            },
          ),
        ),
        appBar: AppBar(
          backgroundColor: Colors.green[800],
          title: const Text("Department List"),
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
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => AdminHomeScreen()));
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                    value: MenuItem.profilepage, child: Text('Profile')),
                PopupMenuItem(value: MenuItem.logout, child: Text('Logout')),
                PopupMenuItem(
                    value: MenuItem.dashboard, child: Text('Dashboard'))
              ],
            )
          ],
        ),
        body: StreamBuilder(
            stream: _products.snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
              if (streamSnapshot.hasData) {
                return ListView.builder(
                  itemCount: streamSnapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final DocumentSnapshot documentSnapshot =
                        streamSnapshot.data!.docs[index];
                    return Card(
                      color: Colors.green[100],
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(documentSnapshot['name']),
                        trailing: SizedBox(
                            width: 100,
                            child: Row(
                              children: [
                                IconButton(
                                    onPressed: () {
                                      final departmentDoc = FirebaseFirestore
                                          .instance
                                          .collection('departments')
                                          .doc(documentSnapshot.id);
                                      departmentDoc.delete();
                                    },
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ))
                              ],
                            )),
                      ),
                    );
                  },
                );
              } else if (streamSnapshot.hasError) {
                return Text('has error');
              } else {
                return Text('no data');
              }
            }));
  }

  // the logout function
  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()));
  }
}
