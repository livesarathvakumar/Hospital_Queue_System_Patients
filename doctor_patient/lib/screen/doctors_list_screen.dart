import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_patient/model/user_model.dart';
import 'package:doctor_patient/screen/add_doctor_screen.dart';
import 'package:doctor_patient/screen/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'login_screen.dart';

class DoctorsListScreen extends StatefulWidget {
  const DoctorsListScreen({Key? key}) : super(key: key);

  @override
  _DoctorsListScreenState createState() => _DoctorsListScreenState();
}

enum MenuItem {
  profilepage,
  logout,
}

class _DoctorsListScreenState extends State<DoctorsListScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  final Query<Map<String, dynamic>> _doctors = FirebaseFirestore.instance
      .collection('users')
      .where('role', isEqualTo: 'doctor');

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
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: SizedBox(
          height: 60,
          width: 60,
          child: FloatingActionButton(
            child: Icon(Icons.add),
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            elevation: 5.0,
            tooltip: "Press to Add Department",
            splashColor: Colors.blueAccent,
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => AddDoctor()));
            },
          ),
        ),
        appBar: AppBar(
          title: const Text("Doctors"),
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
            stream: _doctors.snapshots(),
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
