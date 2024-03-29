import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_application/app_widgets/text_widgets/heading_text.dart';
import 'package:notes_application/global/current_user_data.dart';
import 'package:notes_application/global/dimensions.dart';
// import 'package:notes_application/models/user_class.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:notes_application/utils/auth.dart';
import 'package:notes_application/utils/cropper.dart';
import 'dart:io';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final String name = UserData.name;
  final String email = UserData.email;
  final String number = UserData.number;
  bool imageEdited = false;
  bool validated = false;
  late File pickedFile;

  @override
  void initState() {
    super.initState();
    _emailController.text = email;
    _nameController.text = name;
    _numberController.text = number;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  Future<void> selectFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null) return;

    imageEdited = true;

    pickedFile = await Cropper.cropSquareImage(File(result.files.first.path!));

    Fluttertoast.showToast(msg: 'File added successfully');
  }

  Future<void> updateUserInformation() async {
    if (!imageEdited &&
        email == _emailController.text.trim() &&
        name == _nameController.text.trim() &&
        number == _numberController.text.trim()) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    TextEditingController passwordController = TextEditingController();

    AlertDialog alert = AlertDialog(
      title: const HeadingText('Enter your password', 20, null, Colors.black),
      content: TextField(
        scrollPhysics: const BouncingScrollPhysics(),
        controller: passwordController,
        obscureText: true,
        decoration: InputDecoration(
          hintText: "Enter password",
          labelText: "Password",
          prefixIcon: Icon(
            Icons.lock_outline,
            size: height / 29.2333,
          ),
          labelStyle: TextStyle(
            fontSize: height / 54.8125,
          ),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Confirm'),
          onPressed: () async {
            AuthCredential credential = EmailAuthProvider.credential(
              email: UserData.email,
              password: passwordController.text,
            );
            User? user = FirebaseAuth.instance.currentUser;
            try {
              await user?.reauthenticateWithCredential(credential);
              validated = true;
            } catch (e) {
              Fluttertoast.showToast(msg: 'Invalid credentials');
            }
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
      ],
    );

    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );

    if (!validated) {
      return;
    }

    Auth().updateUserInformation(
      email: _emailController.text.trim(),
      name: _nameController.text.trim(),
      number: _numberController.text.trim(),
      profileImage: imageEdited ? pickedFile : null,
      oldImageUrl: UserData.profileImageURL,
    );
  }

  double height = Dimensions.screenHeight;
  double width = Dimensions.screenWidth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'discard',
            onPressed: () => Navigator.pop(context),
            child: const Icon(Icons.close),
          ),
          SizedBox(
            height: height / 100,
          ),
          FloatingActionButton(
            heroTag: 'updateUserInformation',
            onPressed: () async {
              await updateUserInformation();
              if (validated) {
                Navigator.of(context).pop();
              }
            },
            child: const Icon(Icons.check_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: height / 10,
            ),
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(height),
                    child: (imageEdited)
                        ? Image.file(
                            pickedFile,
                            height: height / 4,
                          )
                        : Image.network(
                            UserData.profileImageURL,
                            height: height / 4,
                          ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: width / 3,
                    ),
                    Container(
                      height: height * 0.05,
                      width: height * 0.05,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(width / 30),
                      ),
                      child: IconButton(
                        onPressed: () async {
                          await selectFile();
                          setState(() {});
                        },
                        icon: Icon(
                          Icons.edit_outlined,
                          color: Colors.white,
                          size: height / 30,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      hintText: "Enter user name",
                      labelText: "User name",
                      prefixIcon: Icon(
                        Icons.person_outline,
                        size: height / 29.2333,
                      ),
                      labelStyle: TextStyle(
                        fontSize: height / 54.8125,
                      ),
                      hintStyle: TextStyle(
                        fontSize: height / 53,
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "User name cannot be empty";
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: height / 87.7,
                  ),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: "Enter Email",
                      labelText: "Email",
                      prefixIcon: Icon(
                        Icons.mail_outline,
                        size: height / 29.2333,
                      ),
                      labelStyle: TextStyle(
                        fontSize: height / 54.8125,
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Email cannot be empty";
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: height / 87.7,
                  ),
                  TextFormField(
                    controller: _numberController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Enter phone number",
                      labelText: "Phone Number",
                      prefixIcon: Icon(
                        Icons.phone_outlined,
                        size: height / 29.2333,
                      ),
                      labelStyle: TextStyle(
                        fontSize: height / 54.8125,
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Phone number cannot be empty";
                      } else if (value.length < 10) {
                        return "Password must be at least 10 characters long";
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: height / 87.7,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
