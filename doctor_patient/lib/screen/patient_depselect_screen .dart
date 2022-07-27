import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_patient/model/user_model.dart';
import 'package:doctor_patient/screen/profile_screen.dart';
import 'package:doctor_patient/screen/patient_docselect_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'login_screen.dart';

class PatientsDepartmentSelectScreen extends StatefulWidget {
  const PatientsDepartmentSelectScreen({Key? key}) : super(key: key);

  @override
  _PatientsDepartmentSelectScreenState createState() =>
      _PatientsDepartmentSelectScreenState();
}

enum MenuItem {
  profilepage,
  logout,
}

class _PatientsDepartmentSelectScreenState
    extends State<PatientsDepartmentSelectScreen> {
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

  final CollectionReference _products =
      FirebaseFirestore.instance.collection('departments');

  String? deperatmentIds;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Departments"),
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
        body: Padding(
          padding: EdgeInsets.all(15),
          child: Column(children: <Widget>[
            SizedBox(
              height: 5,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(' Select a Department',
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            SizedBox(
              height: 20,
            ),
            SizedBox(
              height: 150,
              child: departmentBox(),
            ),
            SizedBox(
              height: 20,
            )
          ]),
        ));
  }

  Widget departmentBox() => StreamBuilder(
      stream: _products.snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
        if (streamSnapshot.hasData) {
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: streamSnapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final DocumentSnapshot documentSnapshot =
                  streamSnapshot.data!.docs[index];
              return Container(
                  color: Colors.white,
                  width: 150,
                  height: 100,
                  child: Card(
                    color: Colors.green,
                    margin: const EdgeInsets.all(5),
                    child: ListTile(
                      onTap: () {
                        //createDoctorListView();
                        deperatmentIds = documentSnapshot.id;
                        print(documentSnapshot.id);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const PatientsDoctorSelectScreen(),
                            // Pass the arguments as part of the RouteSettings. The
                            // DetailScreen reads the arguments from these settings.
                            settings:
                                RouteSettings(arguments: documentSnapshot.id),
                          ),
                        );
                      },
                      title: Text(documentSnapshot['name'],
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 18, color: Colors.white)),
                    ),
                  ));
            },
          );
        } else if (streamSnapshot.hasError) {
          return Text('has error');
        } else {
          return Text('no data');
        }
      });

  // the logout function
  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()));
  }
}
