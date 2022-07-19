import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_patient/model/user_model.dart';
import 'package:doctor_patient/screen/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'login_screen.dart';

class PatientsListScreen extends StatefulWidget {
  const PatientsListScreen({Key? key}) : super(key: key);

  @override
  _PatientsListScreenState createState() => _PatientsListScreenState();
}

enum MenuItem {
  profilepage,
  logout,
}

class _PatientsListScreenState extends State<PatientsListScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  final Query<Map<String, dynamic>> _patients = FirebaseFirestore.instance
      .collection('users')
      .where('role', isEqualTo: 'patient');

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Patients"),
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
        body: StreamBuilder(
            stream: _patients.snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
              if (streamSnapshot.hasData) {
                return ListView.builder(
                  itemCount: streamSnapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final DocumentSnapshot documentSnapshot =
                        streamSnapshot.data!.docs[index];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(documentSnapshot['firstName']),
                        trailing: SizedBox(
                            width: 100,
                            child: Row(
                              children: [
                                IconButton(
                                    onPressed: () => UserProfile(),
                                    icon: const Icon(Icons.delete))
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
