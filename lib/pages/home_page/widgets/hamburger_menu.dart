import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; 
import 'package:phone_store/pages/account/account.dart';
import 'package:phone_store/pages/account/widgets/order_info.dart';

class HamburgerBar extends StatefulWidget {
  const HamburgerBar({super.key});

  @override
  State<HamburgerBar> createState() => _HamburgerBarState();
}

class _HamburgerBarState extends State<HamburgerBar> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Color.fromRGBO(203, 109, 128, 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 45,
            ),
            Text(
              'ZendVN',
              style: TextStyle(
                fontSize: 40,
                color: Colors.white,
                fontFamily: 'Sniglet',
              ),
            ),
            SizedBox(
              height: 90,
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(40),
                  ),
                ),
                child: Wrap(
                  runSpacing: 25,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  children: [
                    TextButton(
                      onPressed: () {
                        Scaffold.of(context).closeDrawer();
                      },
                      child: Text(
                        'Trang chủ',
                        style: TextStyle(
                          fontFamily: 'Sniglet',
                          color: Color.fromRGBO(7, 255, 225, 1),
                          fontSize: 20,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, OrderInfoPage.routeName);
                      },
                      child: Text(
                        'Thông tin đơn hàng',
                        style: TextStyle(
                          fontFamily: 'Sniglet',
                          color: Color.fromRGBO(203, 109, 128, 1),
                          fontSize: 20,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AccountPage.routeName);
                      },
                      child: Text(
                        'Thông tin cá nhân',
                        style: TextStyle(
                          fontFamily: 'Sniglet',
                          color: Color.fromRGBO(203, 109, 128, 1),
                          fontSize: 20,
                        ),
                      ),
                    ),
                    Divider(
                      color: Color.fromRGBO(203, 109, 128, 1),
                    ),
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext dialogContext) {
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
                                    Navigator.of(dialogContext).pop();
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
