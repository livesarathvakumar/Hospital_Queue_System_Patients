import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_patient/model/user_model.dart';
import 'package:doctor_patient/screen/profile_screen.dart';
import 'package:doctor_patient/screen/patient_docselect_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:doctor_patient/model/appointment_model.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:doctor_patient/screen/patient_home_screen.dart';
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

//final TextEditingController appointmentdate = new TextEditingController();
//final TextEditingController appointmenttime = new TextEditingController();
String? selectdate;
String? time;
String? departmentId;
String? departmentName;
String? doctorId;
String? doctorName;
int? timeslotId;

final timeSlotEditingController = new TextEditingController();

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

    final timeSlotField = TextFormField(
        autofocus: false,
        enabled: false,
        controller: timeSlotEditingController..text = '',
        keyboardType: TextInputType.name,
        validator: (value) {
          RegExp regex = new RegExp(r'^.{3,}$');
          if (value!.isEmpty) {
            return ("Select a time slot");
          }
          return null;
        },
        onSaved: (value) {
          timeSlotEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.punch_clock),
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Time Slots",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));

    //appointmentButton button
    final appointmentButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: Colors.redAccent,
      child: MaterialButton(
          padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          minWidth: MediaQuery.of(context).size.width,
          onPressed: () {
            final appointment = AppointmentModel();
            createAppointment(appointment);
          },
          child: Text(
            "Book Appoinment",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          )),
    );

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
                            doctorId = documentSnapshot.id;
                            doctorName = documentSnapshot['firstName'];
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
                          departmentId = documentSnapshot.id;
                          departmentName = documentSnapshot['name'];
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
            DateTimePicker(
              type: DateTimePickerType.date,
              dateMask: 'd MMM, yyyy',
              //initialValue: DateTime.now().toString(),
              firstDate: DateTime(2022),
              lastDate: DateTime(2100),
              icon: Icon(Icons.event),
              dateLabelText: 'Date',
              timeLabelText: "Time",
              selectableDayPredicate: (date) {
                // Disable weekend days to select from the calendar
                // if (date.weekday == 6 || date.weekday == 7) {
                //   return false;
                // }

                return true;
              },
              onChanged: (val) {
                selectdate = val;
                print('changed value');
                print(val);
              },
              validator: (val) {
                print(val);
                return null;
              },
              onSaved: (val) {
                print('saved value');
                print(val);
              },
            ),
            SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 250,
              child: StreamBuilder(
                  stream: _timeslots.snapshots(),
                  builder:
                      (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                    if (streamSnapshot.hasData) {
                      return GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                        ),
                        itemCount: streamSnapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final DocumentSnapshot documentSnapshot =
                              streamSnapshot.data!.docs[index];
                          return SizedBox(
                              height: 70,
                              width: 100,
                              child: Card(
                                  margin: const EdgeInsets.all(5),
                                  child: TextButton(
                                    style: ButtonStyle(
                                      foregroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.blue),
                                    ),
                                    onPressed: () {
                                      timeSlotEditingController.text =
                                          documentSnapshot['times'];
                                      print(
                                        documentSnapshot['timeid'],
                                      );
                                      timeslotId = documentSnapshot['timeid'];
                                      time = documentSnapshot['times'];
                                      print(timeslotId);
                                      print(time);
                                    },
                                    child: Text(documentSnapshot['times']),
                                  )));
                        },
                      );
                    } else if (streamSnapshot.hasError) {
                      return Text('has error');
                    } else {
                      return Text('no data');
                    }
                  }),
            ),
            timeSlotField,
            SizedBox(
              height: 10,
            ),
            appointmentButton,
          ]),
        ));
  }

  Future createAppointment(AppointmentModel appointment) async {
    final appointmentCollection =
        FirebaseFirestore.instance.collection('appointment').doc();
    print(doctorId);
    print(selectdate);
    //strDt = selectdate
    appointment.id = appointmentCollection.id;
    appointment.departmentId = departmentId;
    appointment.departmentName = departmentName;
    appointment.doctorId = doctorId;
    appointment.doctorName = doctorName;
    appointment.date = selectdate;
    appointment.userId = loggedInUser.uid;
    appointment.timeslotId = timeslotId;
    appointment.time = time;

    final json = appointment.toJson();
    await appointmentCollection.set(json);
    Fluttertoast.showToast(msg: "Appointment Created Successfully!");

    Navigator.pushAndRemoveUntil(
        (context),
        MaterialPageRoute(builder: (context) => PatientsHomeScreen()),
        (route) => false);
  }

  // the logout function
  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()));
  }
}
