import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:phone_store/pages/login_page/addDetail.dart';
import 'package:phone_store/pages/login_page/forgotPass_page.dart';
import 'package:phone_store/pages/login_page/register_page.dart';

class LoginPage extends StatefulWidget {
 // final VoidCallback showRegisterPage;
  static String routeName = '/login_page';
  const LoginPage({super.key });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isSee = true;
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  Future signIn() async {
    if (_emailController.text.trim().isEmpty ||
        _passController.text.trim().isEmpty) {
      _showErrorDialog('Please enter your email and password.');
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;

      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address.';
          break;
        case 'user-disabled':
          errorMessage = 'This user has been disabled.';
          break;
        default:
          errorMessage = 'An unexpected error occurred. Please try again.';
      }

      _showErrorDialog(errorMessage);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Login Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _signInWithGoogle({required BuildContext context}) async {
    try {
      GoogleSignIn googleSignIn = GoogleSignIn();
      GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // Người dùng hủy đăng nhập
        return;
      }

      GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid) // Ưu tiên dùng uid thay vì email
            .get();

        if (!userDoc.exists) {
          Navigator.pushReplacementNamed(context, AddDetailPage.routeName);
        } else {
          Navigator.pushReplacementNamed(context, '/homePage');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đăng nhập thất bại')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi: $e')),
      );
    }
  }


  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: ListView(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 30),
                  child: Image.asset(
                    'assets/img/Login.png',
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const Text(
                  'Hey There, Welcome back',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 69, 69, 69),
                    decoration: TextDecoration.none,
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                LoginForm(
                  inputController: _emailController,
                  hintText: 'Email',
                  message: "Enter your email",
                  prefix: Icon(Icons.account_circle_sharp),
                ),
                const SizedBox(
                  height: 15,
                ),
                LoginForm(
                  inputController: _passController,
                  hintText: 'Password',
                  message: 'Enter your password',
                  suffix: IconButton(
                    icon: isSee
                        ? Icon(Icons.visibility_off)
                        : Icon(Icons.remove_red_eye),
                    onPressed: () {
                      setState(
                        () {
                          isSee = !isSee;
                        },
                      );
                    },
                  ),
                  prefix: Icon(Icons.lock),
                  obscureText: isSee,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return ForgotPassPage();
                            },
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          'Forgot password ?',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 211, 88, 123),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      "Sign in",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                  child: const Text(
                    'Or',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async { 
                     await _signInWithGoogle(context: context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 235, 235, 235),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 5,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 25),
                          child: Image.asset('assets/img/Google.png'),
                        ),
                        const Text(
                          'Continue with Google',
                          style: TextStyle(
                            color: Color.fromARGB(255, 178, 178, 178),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Need to create an account ? ',
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      GestureDetector(
                        onTap:  () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegisterPage(),
                            ),
                          );
                        },
                        child: Text(
                          'Sign up',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color.fromARGB(255, 211, 88, 123),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LoginForm extends StatelessWidget {
  final inputController;

  String hintText;
  String message;
  IconButton? suffix;
  Icon? prefix;

  bool? readOnly;
  bool? obscureText;
  LoginForm({
    super.key,
    required this.inputController,
    required this.hintText,
    required this.message,
    this.readOnly,
    this.suffix,
    this.prefix,
    this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            autofocus: false,
            obscureText: obscureText ?? false,
            obscuringCharacter: '*',
            readOnly: readOnly ?? false,
            controller: inputController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return message;
              }
              return null;
            },
            decoration: InputDecoration(
              prefixIcon: prefix,
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
        ],
      ),
    );
  }
}
