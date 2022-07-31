import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_patient/screen/login_screen.dart';
import 'package:doctor_patient/screen/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:doctor_patient/model/department_model.dart';
import 'package:doctor_patient/screen/departments_list_screen.dart';

class AddDepartment extends StatefulWidget {
  const AddDepartment({Key? key}) : super(key: key);

  @override
  _AddDepartmentState createState() => _AddDepartmentState();
}

enum MenuItem {
  profilepage,
  logout,
}

class _AddDepartmentState extends State<AddDepartment> {
  // form key
  final _formKey = GlobalKey<FormState>();

  // editing controller
  final TextEditingController departmentController =
      new TextEditingController();

  // string for displaying the error Message
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    //email field
    final departmentField = TextFormField(
        autofocus: false,
        controller: departmentController,
        keyboardType: TextInputType.text,
        validator: (value) {
          if (value!.isEmpty) {
            return ("Please Enter Department");
          }
          return null;
        },
        onSaved: (value) {
          departmentController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          // prefixIcon: Icon(Icons.mail),
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Department Name",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));

    final addButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: Colors.green,
      child: MaterialButton(
          padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          minWidth: MediaQuery.of(context).size.width,
          onPressed: () {
            final department = DepartmentModel(name: departmentController.text);
            createDepartment(department);
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
        backgroundColor: Colors.green[800],
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
          child: Column(
            children: <Widget>[
              departmentField,
              SizedBox(
                height: 15,
              ),
              addButton
            ],
          ),
        ),
      ),
    );
  }

  Future createDepartment(DepartmentModel department) async {
    final deparmentCollection =
        FirebaseFirestore.instance.collection('departments').doc();
    department.id = deparmentCollection.id;
    final json = department.toJson();
    await deparmentCollection.set(json);
    Fluttertoast.showToast(msg: "Department Created Successfully!");

    Navigator.pushAndRemoveUntil(
        (context),
        MaterialPageRoute(builder: (context) => DepartmentListScreen()),
        (route) => false);
  }

  // the logout function
  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()));
  }
}
