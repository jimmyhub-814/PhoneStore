import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:phone_store/pages/home_page/home_page.dart';
import 'package:phone_store/pages/login_page/addDetail.dart';
import 'package:phone_store/pages/login_page/login_page.dart';

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return LoginPage();
    }

    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          // Nếu chưa có hồ sơ → sang trang điền chi tiết
          return AddDetailPage();
        }

        // Nếu có → vào homepage
        return HomePage();
      },
    );
  }
}
