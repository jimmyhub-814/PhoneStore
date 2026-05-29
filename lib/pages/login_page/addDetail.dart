import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:phone_store/models/user.dart';

class AddDetailPage extends StatefulWidget {
  const AddDetailPage({super.key});
static const String routeName = '/add_detail_page';
  @override
  State<AddDetailPage> createState() => _AddDetailPageState();
}

class _AddDetailPageState extends State<AddDetailPage> {
  final _confirmController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _dateController = TextEditingController();
  final _genderController = TextEditingController();
  final _phoneController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final ImagePicker picker = ImagePicker();

  XFile? _pickedImage;
  String? userImg;

  @override
  void dispose() {
    _confirmController.dispose();
    _fullNameController.dispose();
    _dateController.dispose();
    _genderController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future addUserDetails(UserApp userapp) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User is not authenticated.");
      }

      String userId = user.uid;
      print("Authenticated user ID: $userId"); // Debugging log

      final userCartRef =
          FirebaseFirestore.instance.collection('users').doc(userId);
      await userCartRef.set(
        userapp.toMap(),
      );

      print("User details added successfully for user ID: $userId");
    } catch (e) {
      print("Failed to add user details: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add user details: $e')),
      );
    }
  }

  Future<void> _selectDate() async {
    DateTime? _picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime(2007),
    );
    if (_picked != null) {
      // Định dạng ngày
      String formattedDate = DateFormat('yyyy-MM-dd').format(_picked);

      // Cập nhật giá trị của TextEditingController
      setState(() {
        _dateController.text = formattedDate;
      });
    }
  }

  Future<void> _pickImageCamera() async {
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _pickedImage = image;
      });
    }
  }

  Future<void> _pickImageGallery() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedImage = image;
      });
    }
  }

  void uploadImage() async {
    await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _pickImageCamera();
              },
              child: const Text('Camera'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _pickImageGallery();
              },
              child: const Text('Gallery'),
            ),
          ],
        ),
      ),
    );
  }

  Future signUp() async {
    if (_pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please pick an image')),
      );
      return;
    }
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      final path = 'users/${userId}.jpg';
      final ref = FirebaseStorage.instance.ref().child(path);
      await ref.putFile(File(_pickedImage!.path));
      userImg = await ref.getDownloadURL();
      final user = UserApp(
        id: userId,
        userName: _fullNameController.text.trim(),
        userEmail: FirebaseAuth.instance.currentUser!.email!,
        userDate: _dateController.text.trim(),
        userGender: _genderController.text.trim(),
        userImage: userImg!,
        userPhone: _phoneController.text.trim(),
        userAddress: '',
        favorite: [],
        cart: [],
      );
      await addUserDetails(user);
      Navigator.pushReplacementNamed(context, '/homePage');
      print('User details added successfully');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('The email is already in use.')),
        );
      } else if (e.code == 'invalid-email') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('The email address is invalid.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: ${e.message}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Column(
                      children: [
                        _pickedImage == null
                            ? const Icon(Icons.image_outlined, size: 100)
                            : Stack(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.all(3),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        File(_pickedImage!.path),
                                        height: 100,
                                        width: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _pickedImage = null;
                                        });
                                      },
                                      child: const CircleAvatar(
                                        radius: 5,
                                        backgroundColor:
                                            Color.fromARGB(255, 74, 74, 74),
                                        child: Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                        TextButton(
                          onPressed: uploadImage,
                          child: const Text('Pick Product Image'),
                        ),
                      ],
                    ),
                    AddDetailForm(
                      inputController: _fullNameController,
                      hintText: "Full Name",
                      message: 'Enter your name',
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    IntlPhoneField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: const Color.fromARGB(255, 135, 135, 135),
                              width: 1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: const Color.fromARGB(255, 135, 135, 135),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                              color: const Color.fromARGB(255, 109, 109, 109),
                              width: 2),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      initialCountryCode: 'VN',
                      disableLengthCheck: true,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: AddDetailForm(
                            inputController: _dateController,
                            hintText: 'Date',
                            message: 'Choose your birthday',
                            tapFunction: _selectDate,
                            readOnly: true,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          flex: 1,
                          child: AddDetailForm(
                            inputController: _genderController,
                            readOnly: true,
                            hintText: 'Gender',
                            message: 'Choose your gender',
                            tapFunction: () async {
                              final selected = await showDialog<String>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text("Choose Gender"),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: ["Female", "Male", "Other"].map(
                                      (gender) {
                                        return ListTile(
                                          title: Text(gender),
                                          onTap: () =>
                                              Navigator.pop(context, gender),
                                        );
                                      },
                                    ).toList(),
                                  ),
                                ),
                              );

                              if (selected != null) {
                                setState(() {
                                  _genderController.text = selected;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            signUp();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Please fix the errors')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 211, 88, 123),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 5,
                        ),
                        child: const Text(
                          "Sign up",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AddDetailForm extends StatelessWidget {
  final inputController;
  final Widget? child;
  String hintText;
  String message;
  IconButton? suffix;
  final VoidCallback? tapFunction;
  bool? readOnly;
  bool? obscureText;
  AddDetailForm({
    super.key,
    required this.inputController,
    required this.hintText,
    required this.message,
    this.child,
    this.tapFunction,
    this.readOnly,
    this.suffix,
    this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            readOnly: readOnly ?? false,
            obscureText: obscureText ?? false,
            obscuringCharacter: "*",
            onTap: tapFunction,
            controller: inputController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return message;
              }
              return null;
            },
            decoration: InputDecoration(
              suffixIcon: suffix,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                    color: const Color.fromARGB(255, 135, 135, 135), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                    color: const Color.fromARGB(255, 109, 109, 109), width: 2),
              ),
              hintText: hintText,
              hintStyle: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}
