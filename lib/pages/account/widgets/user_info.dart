import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:phone_store/pages/account/widgets/changePass_page.dart';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});
  static String routeName = '/user_info';
  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  //current logged in user
  final currentUser = FirebaseAuth.instance.currentUser!;
  final _fullNameController = TextEditingController();
  final _passController = TextEditingController();
  final _dateController = TextEditingController();
  final _genderController = TextEditingController();
  final _emailController = TextEditingController();
  //future to fetch user details
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
  }

  Future<void> updateInfo(String fieldName, String newInfo) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .update({
      '${fieldName}': newInfo,
    });
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
      String formattedDate = DateFormat('MM-dd-yyyy').format(_picked);

      // Cập nhật giá trị của TextEditingController
      setState(() {
        _dateController.text = formattedDate;
        updateInfo("date", _dateController.text);
      });
    }
  }

  Future<void> updateUserEmail(String newEmail) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // ignore: deprecated_member_use
        await user.updateEmail(newEmail);
        await user.reload();
        print("Email updated successfully!");
      } catch (e) {
        print("Failed to update email: $e");
      }
    }
  }

  void changeGender() async {
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
                onTap: () {
                  setState(() {
                    _genderController.text = gender;
                    updateInfo("gender", _genderController.text);
                    Navigator.pop(context);
                  });
                },
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
  }

  void changeEmail(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: TextField(
            controller: _emailController,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
                _emailController.clear();
              },
              child: Text("Hủy"),
            ),
            TextButton(
              onPressed: () async {
                String newName = _emailController.text.trim();

                if (newName.isNotEmpty) {
                  await updateUserEmail(newName);

                  if (mounted) {
                    setState(() {});
                  }
                }

                Navigator.of(context, rootNavigator: true).pop();
                _emailController.clear();
              },
              child: Text("Đồng ý"),
            ),
          ],
        );
      },
    );
  }

  void changeName(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: TextField(
            controller: _fullNameController,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
                _fullNameController.clear();
              },
              child: Text("Hủy"),
            ),
            TextButton(
              onPressed: () async {
                String newName = _fullNameController.text.trim();

                if (newName.isNotEmpty) {
                  await updateInfo('fullName', newName);

                  if (mounted) {
                    setState(() {});
                  }
                }

                Navigator.of(context, rootNavigator: true).pop();
                _fullNameController.clear();
              },
              child: Text("Đồng ý"),
            ),
          ],
        );
      },
    );
  }

  void changePassWord(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: TextField(
            controller: _passController,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
                _passController.clear();
              },
              child: Text("Quên mật khẩu"),
            ),
            TextButton(
              onPressed: () async {
                String newName = _passController.text.trim();

                if (newName.isNotEmpty) {
                  await updateInfo('fullName', newName);

                  if (mounted) {
                    setState(() {});
                  }
                }

                Navigator.of(context, rootNavigator: true).pop();
                _fullNameController.clear();
              },
              child: Text("Đồng ý"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(203, 109, 128, 1),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.keyboard_backspace_sharp,
            color: Colors.white,
          ),
        ),
      ),
      body: FutureBuilder(
        future: getUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            Map<String, dynamic>? user = snapshot.data!.data();
            return Container(
              padding: EdgeInsets.all(10),
              color: Color.fromRGBO(203, 109, 128, 1),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: Text('Tên'),
                          title: Text(
                            user!['userName'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          trailing: Icon(Icons.edit, size: 14,),
                          onTap: () {
                            changeName(context);
                          },
                        ),
                        Divider(
                          color: Color.fromRGBO(231, 234, 237, 1),
                          indent: 16,
                          endIndent: 16,
                        ),
                        ListTile(
                          leading: Text('Giới tính'),
                          title: Text(
                            user['userGender'],
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          trailing: Icon(Icons.edit, size: 14,),
                          onTap: () {
                            changeGender();
                          },
                        ),
                        Divider(
                          color: Color.fromRGBO(231, 234, 237, 1),
                          indent: 16,
                          endIndent: 16,
                        ),
                        ListTile(
                          leading: Text('Ngày sinh'),
                          title: Text(
                            user['userDate'],
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          trailing: Icon(Icons.edit, size: 14,),
                          onTap: () {
                            _selectDate();
                          },
                        ),
                        Divider(
                          color: Color.fromRGBO(231, 234, 237, 1),
                          indent: 16,
                          endIndent: 16,
                        ),
                        ListTile(
                          leading: Text('Số điện thoại'),
                          title: Text(
                            user['userPhone'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          trailing: Icon(Icons.edit, size: 14,),
                          onTap: () {},
                        ),
                        Divider(
                          color: Color.fromRGBO(231, 234, 237, 1),
                          indent: 16,
                          endIndent: 16,
                        ),
                        ListTile(
                          leading: Text('Email'),
                          title: Text(
                            user['userEmail'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          trailing: Icon(Icons.edit, size: 14,),
                          onTap: () {
                            changeEmail(context);
                          },
                        ),
                        Divider(
                          color: Color.fromRGBO(231, 234, 237, 1),
                          indent: 16,
                          endIndent: 16,
                        ),
                        ListTile(
                          leading: Text('Mật khẩu'),
                          trailing: Icon(Icons.edit, size: 14,),
                          onTap: () {
                            Navigator.pushNamed(
                                context, ChangepassPage.routeName,
                                arguments: {
                                  'email': user['userEmail'],
                                });
                          },
                        ),
                        Divider(
                          color: Color.fromRGBO(231, 234, 237, 1),
                          indent: 16,
                          endIndent: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Center(
              child: Text('Không có dữ liệu!'),
            );
          }
        },
      ),
    );
  }
}
