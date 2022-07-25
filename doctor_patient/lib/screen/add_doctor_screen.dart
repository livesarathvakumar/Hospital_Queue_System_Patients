import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_patient/screen/login_screen.dart';
import 'package:doctor_patient/screen/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:doctor_patient/model/doctor_model.dart';
import 'package:doctor_patient/screen/doctors_list_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AddDoctor extends StatefulWidget {
  const AddDoctor({Key? key}) : super(key: key);

  @override
  _AddDoctorState createState() => _AddDoctorState();
}

enum MenuItem {
  profilepage,
  logout,
}

class _AddDoctorState extends State<AddDoctor> {
  // form key
  final _formKey = GlobalKey<FormState>();

  // editing controller
  final TextEditingController doctorController = new TextEditingController();

  // string for displaying the error Message
  String? errorMessage;

  var _category, dropDown, departmentChoosen;

  //get departmentChoosen => null;

  @override
  Widget build(BuildContext context) {
    //email field
    final departmentField = TextFormField(
        autofocus: false,
        controller: doctorController,
        keyboardType: TextInputType.text,
        validator: (value) {
          if (value!.isEmpty) {
            return ("Please Enter Doctor Name");
          }
          return null;
        },
        onSaved: (value) {
          doctorController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          // prefixIcon: Icon(Icons.mail),
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Doctor Name",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));

    final addButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: Colors.redAccent,
      child: MaterialButton(
          padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          minWidth: MediaQuery.of(context).size.width,
          onPressed: () {
            final department = DoctorModel(
                firstName: doctorController.text, departmentId: _category);
            createDoctor(department);
          },
          child: Text(
            "Add",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          )),
    );
    return Scaffold(
        appBar: AppBar(
          title: const Text("Add Department"),
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
        body: Center(
            child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(children: <Widget>[
                  departmentField,
                  SizedBox(
                    height: 15,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Center(
                      child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('departments')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return Text('error');

                            return Container(
                              padding: EdgeInsets.only(bottom: 16.0),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 6,
                                    child: DropdownButton<String>(
                                      value: departmentChoosen,
                                      isDense: true,
                                      style: const TextStyle(fontSize: 18),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _category = newValue;
                                          dropDown = false;
                                          departmentChoosen = _category;
                                          print(_category);
                                        });
                                      },
                                      hint: Text('Select Department'),
                                      items: snapshot.data!.docs
                                          .map((DocumentSnapshot document) {
                                        //print(document.id);
                                        return DropdownMenuItem<String>(
                                          value: document.id,
                                          child: Text(document['name']),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          })),
                  addButton,
                ]))));
  }

  Future createDoctor(DoctorModel department) async {
    final deparmentCollection =
        FirebaseFirestore.instance.collection('users').doc();
    department.id = deparmentCollection.id;
    final json = department.toJson();
    await deparmentCollection.set(json);
    Fluttertoast.showToast(msg: "Docter Created Successfully!");

    Navigator.pushAndRemoveUntil(
        (context),
        MaterialPageRoute(builder: (context) => DoctorsListScreen()),
        (route) => false);
  }

  // the logout function
  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()));
  }
}
