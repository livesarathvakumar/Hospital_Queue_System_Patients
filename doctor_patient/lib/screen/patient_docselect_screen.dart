import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_patient/model/user_model.dart';
import 'package:doctor_patient/screen/profile_screen.dart';
import 'package:doctor_patient/screen/patient_appointment_form_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'login_screen.dart';

class PatientsDoctorSelectScreen extends StatefulWidget {
  const PatientsDoctorSelectScreen({Key? key}) : super(key: key);

  @override
  _PatientsDoctorSelectScreenState createState() =>
      _PatientsDoctorSelectScreenState();
}

enum MenuItem {
  profilepage,
  logout,
}

class ScreenArguments {
  final String departmentId;
  final String doctorId;

  ScreenArguments(this.departmentId, this.doctorId);
}

class _PatientsDoctorSelectScreenState
    extends State<PatientsDoctorSelectScreen> {
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

  String? department;

  @override
  Widget build(BuildContext context) {
    final departmentid = ModalRoute.of(context)!.settings.arguments;

    final Query<Map<String, dynamic>> _doctorList = FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'doctor')
        .where('departmentId', isEqualTo: departmentid);

    print(departmentid);
    print('helo world');
    return Scaffold(
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
              child: Text(' Select a Doctor',
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
                child: Container(
                    margin: EdgeInsets.all(0),
                    child: StreamBuilder(
                        stream: _doctorList.snapshots(),
                        builder: (context,
                            AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                          if (streamSnapshot.hasData) {
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: ClampingScrollPhysics(),
                              itemCount: streamSnapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                final DocumentSnapshot documentSnapshot =
                                    streamSnapshot.data!.docs[index];
                                return Card(
                                  color: Colors.green[100],
                                  shadowColor: Colors.green[200],
                                  margin: const EdgeInsets.all(10),
                                  child: ListTile(
                                    onTap: () {
                                      print(
                                        documentSnapshot.id,
                                      );
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const PatientsAppointmentFormScreen(),
                                              // Pass the arguments as part of the RouteSettings. The
                                              // DetailScreen reads the arguments from these settings.
                                              settings: RouteSettings(
                                                  arguments: ScreenArguments(
                                                      documentSnapshot[
                                                          'departmentId'],
                                                      documentSnapshot.id))));
                                    },
                                    leading: Icon(
                                      Icons.supervised_user_circle,
                                      color: Colors.black,
                                    ),
                                    title: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(documentSnapshot['firstName'],
                                          textAlign: TextAlign.right,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                          )),
                                    ),
                                  ),
                                );
                              },
                            );
                          } else if (streamSnapshot.hasError) {
                            return Text('has error');
                          } else {
                            return Text('Currently Doctors are not available');
                          }
                        })))
          ]),
        ));
  }

  // the logout function
  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()));
  }
}
