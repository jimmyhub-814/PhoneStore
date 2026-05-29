import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; 
import 'package:phone_store/pages/account/widgets/order_status.dart';
import 'package:phone_store/pages/account/widgets/user_info.dart';

class AccountPage extends StatefulWidget {
  static String routeName = '/account';
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  //current logged in user
  final currentUser = FirebaseAuth.instance.currentUser!;

  //future to fetch user details
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
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
      body: Container(
        padding: EdgeInsets.all(10),
        color: Color.fromRGBO(203, 109, 128, 1),
        child: Column(
          children: [
            FutureBuilder(
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
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          flex: 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user!['userName'],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                user['userEmail'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Flexible(
                          flex: 1,
                          child: ClipOval(
                            child: Image.network(
                              user['userImage'],
                              width: 65,
                              height: 65,
                              fit: BoxFit.cover,
                            ),
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
            SizedBox(
              height: 20,
            ),
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
                    leading: Icon(
                      Icons.account_box,
                      color: Color.fromRGBO(203, 109, 128, 1),
                    ),
                    title: Text('Quản lý tài khoản'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pushNamed(context, UserInfoPage.routeName);
                    },
                  ),
                  Divider(
                    color: Color.fromRGBO(231, 234, 237, 1),
                    indent: 16,
                    endIndent: 16,
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.shopping_bag_outlined,
                      color: Color.fromRGBO(203, 109, 128, 1),
                    ),
                    title: Text('Đã mua'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        OrderStatusPage.routeName,
                        arguments: {"index": 2},
                      );
                    },
                  ),
                  Divider(
                    color: Color.fromRGBO(231, 234, 237, 1),
                    indent: 16,
                    endIndent: 16,
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.stars,
                      color: Color.fromRGBO(203, 109, 128, 1),
                    ),
                    title: Text('Đánh giá'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        OrderStatusPage.routeName,
                        arguments: {"index": 3},
                      );
                    },
                  ),
                  Divider(
                    color: Color.fromRGBO(231, 234, 237, 1),
                    indent: 16,
                    endIndent: 16,
                  ),
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Thông báo'),
                            content: Text('Bạn có chắc chắn muốn đăng xuất?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('HỦY'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                 Navigator.of(context).pop();
                                    FirebaseAuth.instance.signOut();
                                    Navigator.pushNamed(
                                        context, '/');
                                },
                                child: Text('TIẾP TỤC'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text(
                      'Đăng xuất',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 13,
                      ),
                    ),
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
