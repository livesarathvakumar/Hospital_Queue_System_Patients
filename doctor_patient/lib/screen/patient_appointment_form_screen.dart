import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_patient/model/user_model.dart';
import 'package:doctor_patient/screen/profile_screen.dart';
import 'package:doctor_patient/screen/patient_docselect_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:date_time_picker/date_time_picker.dart';

import 'login_screen.dart';

class PatientsAppointmentFormScreen extends StatefulWidget {
  const PatientsAppointmentFormScreen({Key? key}) : super(key: key);

  @override
  _PatientsAppointmentFormScreenState createState() =>
      _PatientsAppointmentFormScreenState();
}

enum MenuItem {
  profilepage,
  logout,
}

final TextEditingController appointmentdate = new TextEditingController();
final TextEditingController appointmenttime = new TextEditingController();

class _PatientsAppointmentFormScreenState
    extends State<PatientsAppointmentFormScreen> {
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

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;
    print(args.doctorId);
    print('args.doctorId');

    final Query<Map<String, dynamic>> _doctorList = FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'doctor')
        .where('id', isEqualTo: args.doctorId);

    final Query<Map<String, dynamic>> _products = FirebaseFirestore.instance
        .collection('departments')
        .where('id', isEqualTo: args.departmentId);

    final Query<Map<String, dynamic>> _timeslots =
        FirebaseFirestore.instance.collection('timeslots').orderBy('timeid');

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
        body: Padding(
          padding: EdgeInsets.all(15),
          child: Column(children: <Widget>[
            SizedBox(
              height: 5,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(' Appoinment',
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            SizedBox(
              height: 20,
            ),
            SizedBox(
                height: 70,
                child: StreamBuilder(
                    stream: _doctorList.snapshots(),
                    builder:
                        (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                      if (streamSnapshot.hasData) {
                        return ListView.builder(
                          itemCount: streamSnapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            final DocumentSnapshot documentSnapshot =
                                streamSnapshot.data!.docs[index];
                            return Card(
                                margin: const EdgeInsets.all(0),
                                child: SizedBox(
                                  height: 60,
                                  child: ListTile(
                                    title: Text(documentSnapshot['firstName']),
                                  ),
                                ));
                          },
                        );
                      } else if (streamSnapshot.hasError) {
                        return Text('has error');
                      } else {
                        return Text('Currently Doctors are not available');
                      }
                    })),
            SizedBox(
              height: 70,
              child: StreamBuilder(
                  stream: _products.snapshots(),
                  builder:
                      (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                    if (streamSnapshot.hasData) {
                      return ListView.builder(
                        itemCount: streamSnapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final DocumentSnapshot documentSnapshot =
                              streamSnapshot.data!.docs[index];
                          return Card(
                            margin: const EdgeInsets.all(0),
                            child: SizedBox(
                                height: 60,
                                child: ListTile(
                                  // onTap: () {
                                  //   print(
                                  //     documentSnapshot.id,
                                  //   );
                                  // },
                                  title: Text(documentSnapshot['name']),
                                )),
                          );
                        },
                      );
                    } else if (streamSnapshot.hasError) {
                      return Text('has error');
                    } else {
                      return Text('no data');
                    }
                  }),
            ),
            // SizedBox(
            //   height: 300,
            //   child: StreamBuilder(
            //       stream: _timeslots.snapshots(),
            //       builder:
            //           (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
            //         if (streamSnapshot.hasData) {
            //           return GridView.builder(
            //             gridDelegate:
            //                 const SliverGridDelegateWithFixedCrossAxisCount(
            //               crossAxisCount: 3,
            //             ),
            //             itemCount: streamSnapshot.data!.docs.length,
            //             itemBuilder: (context, index) {
            //               final DocumentSnapshot documentSnapshot =
            //                   streamSnapshot.data!.docs[index];
            //               return SizedBox(
            //                   height: 70,
            //                   width: 100,
            //                   child: Card(
            //                       margin: const EdgeInsets.all(5),
            //                       child: TextButton(
            //                         style: ButtonStyle(
            //                           foregroundColor:
            //                               MaterialStateProperty.all<Color>(
            //                                   Colors.blue),
            //                         ),
            //                         onPressed: () {
            //                           print(
            //                             documentSnapshot['timeid'],
            //                           );
            //                         },
            //                         child: Text(documentSnapshot['times']),
            //                       )));
            //             },
            //           );
            //         } else if (streamSnapshot.hasError) {
            //           return Text('has error');
            //         } else {
            //           return Text('no data');
            //         }
            //       }),
            // ),
            DateTimePicker(
              type: DateTimePickerType.dateTimeSeparate,
              dateMask: 'd MMM, yyyy',
              initialValue: DateTime.now().toString(),
              firstDate: DateTime(2022),
              lastDate: DateTime(2100),
              icon: Icon(Icons.event),
              dateLabelText: 'Date',
              timeLabelText: "Time",
              selectableDayPredicate: (date) {
                // Disable weekend days to select from the calendar
                if (date.weekday == 6 || date.weekday == 7) {
                  return false;
                }

                return true;
              },
              onChanged: (val) => print(val),
              validator: (val) {
                print(val);
                return null;
              },
              onSaved: (val) => print(val),
            )
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
