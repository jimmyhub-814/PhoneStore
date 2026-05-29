import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChangeOrderInfo extends StatelessWidget {
  static const String routeName = '/changeOrderInfo';

  const ChangeOrderInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = ModalRoute.of(context)!.settings.arguments as Map;
    final currentUser = FirebaseAuth.instance.currentUser!;
    final nameController = TextEditingController(
        text: data['user']['userName'] ?? 'Chưa cập nhật');
    final phoneController = TextEditingController(
        text: data['user']['userPhone'] ?? 'Chưa cập nhật');
    final addressController =
        TextEditingController(text: data['user']['address'] ?? 'Chưa cập nhật');

    Future<void> updateInfo(String fieldName, String newInfo) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({
        '${fieldName}': newInfo,
      });
    }

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Color.fromRGBO(203, 89, 128, 1),
        title: Text(
          'Sửa Địa Chỉ',
          style: TextStyle(
            color: Color.fromRGBO(203, 89, 128, 1),
            fontSize: 18,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Địa chỉ giao hàng',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Họ và tên',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            TextFormField(
              controller: nameController,
              maxLines: 1,
              style: TextStyle(fontSize: 16),
              decoration: InputDecoration(
                border: InputBorder.none,
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: Icon(Icons.person, color: Colors.black54, size: 20),
                ),
                prefixIconConstraints:
                    BoxConstraints(minWidth: 0, minHeight: 0),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Số điện thoại',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            TextFormField(
              controller: phoneController,
              maxLines: 1,
              style: TextStyle(fontSize: 16),
              decoration: InputDecoration(
                border: InputBorder.none,
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: Icon(Icons.phone, color: Colors.black54, size: 20),
                ),
                prefixIconConstraints:
                    BoxConstraints(minWidth: 0, minHeight: 0),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Địa chỉ',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            TextFormField(
              controller: addressController,
              maxLines: 1,
              style: TextStyle(fontSize: 16),
              decoration: InputDecoration(
                border: InputBorder.none,
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child:
                      Icon(Icons.location_on, color: Colors.black54, size: 20),
                ),
                prefixIconConstraints:
                    BoxConstraints(minWidth: 0, minHeight: 0),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 0,
              blurRadius: 5,
              offset: Offset(0, -1),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 40,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromRGBO(178, 63, 86, 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  phoneController.text.isNotEmpty &&
                  addressController.text.isNotEmpty) {
                bool updated = false;

                if (nameController.text != data['user']['userName']) {
                  updateInfo('userName', nameController.text);
                  updated = true;
                }
                if (phoneController.text != data['user']['userPhone']) {
                  updateInfo('userPhone', phoneController.text);
                  updated = true;
                }
                if (addressController.text != data['user']['address']) {
                  updateInfo('address', addressController.text);
                  updated = true;
                }

                if (updated) {
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Không có thay đổi để cập nhật')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
                );
              }
            },
            child: Text(
              'Hoàn thành',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
