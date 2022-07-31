import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_patient/model/user_model.dart';
import 'package:doctor_patient/screen/profile_screen.dart';
import 'package:doctor_patient/screen/patient_depselect_screen .dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:doctor_patient/screen/view_queue_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

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

class ViewQueueArguments {
  final String departmentId;
  final String doctorId;
  final String date;
  final int token;
  final String time;

  ViewQueueArguments(
      this.departmentId, this.doctorId, this.date, this.token, this.time);
}

String? appointmentid;

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

  // final _fireStore = FirebaseFirestore.instance;
  // Future<void> getData() async {
  //   // Get docs from collection reference
  //   QuerySnapshot querySnapshot =
  //       await _fireStore.collection('appointment').get();
  //   ;

  //   // Get data from docs and convert map to List
  //   final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
  //   //for a specific field
  //   final reportData =
  //       querySnapshot.docs.map((doc) => doc.get('date')).toList();

  //   print(reportData);
  //   QuerySnapshot snapshot = await _fireStore.collection('appointment').get();
  //   int count = snapshot.size;
  //   print(count);
  // }

  @override
  Widget build(BuildContext context) {
    //bookAppoinmentButton button
    // bool show = true;
    // print(show);
    // Future<int> getCount() async {
    //   int count = await FirebaseFirestore.instance
    //       .collection('appointment')
    //       .get()
    //       .then((value) => value.size);
    //   print(count);
    //   if (count == 0) {
    //     print('this');
    //     show = false;
    //     print(show);
    //   }
    //   return count;
    // }

    // //int text = getCount();
    // print(show);
    showButton() {
      return Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(30),
        color: Colors.green,
        child: MaterialButton(
            padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
            minWidth: MediaQuery.of(context).size.width,
            onPressed: () {
              //getData();
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => PatientsDepartmentSelectScreen()));
            },
            child: Text(
              "Book Appoinment",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            )),
      );
    }

    var today = DateTime.now();
    var fiftyDaysFromNow = today.add(Duration(minutes: 15));

    print(fiftyDaysFromNow);
    print('fiftyDaysFromNowfiftyDaysFromNow');
    final Query<Map<String, dynamic>> appointmentlist = FirebaseFirestore
        .instance
        .collection('appointment')
        .where('userId', isEqualTo: loggedInUser.uid)
        .where("timeformat", isGreaterThanOrEqualTo: fiftyDaysFromNow)
        .where('active', isEqualTo: true);
    // .orderBy("id");
    //.orderBy('id');

    // getData();
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
        body: SingleChildScrollView(
          padding: EdgeInsets.all(15),
          child: Column(children: <Widget>[
            SizedBox(
              height: 10,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Hi ${loggedInUser.firstName} ',
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 22)),
            ),
            SizedBox(
              height: 5,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(' Welcome Back',
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 20)),
            ),
            SizedBox(
              height: 20,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(' Your Appointments',
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.bold,
                      fontSize: 20)),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
                child: StreamBuilder(
                    stream: appointmentlist.snapshots(),
                    builder:
                        (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                      if (streamSnapshot.hasData) {
                        // 1984–04–02 00:00:00.000

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          itemCount: streamSnapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            final DocumentSnapshot documentSnapshot =
                                streamSnapshot.data!.docs[index];
                            appointmentid = documentSnapshot.id;
                            String strDt = documentSnapshot['date'];
                            DateTime parseDt = DateTime.parse(strDt);
                            print(DateFormat.Hms().format(
                                documentSnapshot['timeformat'].toDate()));
                            print('thissssssssss');
                            print(documentSnapshot['time']);
                            print(DateTime.now());
                            print('helllllllllllllll');
                            return Card(
                                color: Colors.green[100],
                                shadowColor: Colors.green[200],
                                clipBehavior: Clip.antiAlias,
                                margin: const EdgeInsets.all(5),
                                child: Column(
                                  children: [
                                    ListTile(
                                      onTap: () {
                                        print(documentSnapshot['token']);
                                        print('thissssss');

                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const ViewQueueScreen(),
                                                // Pass the arguments as part of the RouteSettings. The
                                                // DetailScreen reads the arguments from these settings.
                                                settings: RouteSettings(
                                                    arguments:
                                                        ViewQueueArguments(
                                                            documentSnapshot[
                                                                'departmentId'],
                                                            documentSnapshot[
                                                                'doctorId'],
                                                            documentSnapshot[
                                                                'date'],
                                                            documentSnapshot[
                                                                'token'],
                                                            documentSnapshot[
                                                                'time']))));
                                      },
                                      leading: Icon(
                                        Icons.date_range,
                                        color: Colors.black,
                                      ),
                                      title: Column(
                                        children: <Widget>[
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                                'Token No: ${documentSnapshot['token'].toString()}',
                                                textAlign: TextAlign.right,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20)),
                                          ),
                                          SizedBox(
                                            height: 05,
                                          ),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                                DateFormat.yMMMEd()
                                                    .format(parseDt),
                                                textAlign: TextAlign.right,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18)),
                                          ),
                                          SizedBox(
                                            height: 05,
                                          ),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                                documentSnapshot['time'],
                                                textAlign: TextAlign.right,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20)),
                                          ),
                                          SizedBox(
                                            height: 05,
                                          ),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                                documentSnapshot['doctorName'],
                                                textAlign: TextAlign.right,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18)),
                                          ),
                                          SizedBox(
                                            height: 05,
                                          ),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                                documentSnapshot[
                                                    'departmentName'],
                                                textAlign: TextAlign.right,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    //fontWeight: FontWeight.bold,
                                                    fontSize: 16)),
                                          ),
                                          SizedBox(
                                            height: 05,
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                        ],
                                      ),
                                      // subtitle: Text(
                                      //   DateFormat.yMMMEd().format(parseDt),
                                      //   style: TextStyle(
                                      //       fontWeight: FontWeight.bold,
                                      //       fontSize: 20),
                                      // ),
                                      trailing: SizedBox(
                                          width: 50,
                                          child: Row(
                                            children: [
                                              IconButton(
                                                  onPressed: () {
                                                    final departmentDoc =
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                'appointment')
                                                            .doc(
                                                                documentSnapshot
                                                                    .id);
                                                    departmentDoc.update(
                                                        {"active": false});
                                                    Fluttertoast.showToast(
                                                        msg:
                                                            "Appointment Deleted Successfully!");
                                                  },
                                                  icon: const Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                  )),
                                              // Text(
                                              //   documentSnapshot['time'],
                                              //   style: TextStyle(
                                              //       fontWeight: FontWeight.bold,
                                              //       fontSize: 20),
                                              // ),
                                            ],
                                          )),
                                    )
                                  ],
                                ));
                          },
                        );
                      } else if (streamSnapshot.hasError) {
                        return Text('has error');
                      } else {
                        print(1);
                        return Text('Currently Doctors are not available');
                      }
                    })),
            SizedBox(
              height: 10,
            ),
            showButton(),
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
