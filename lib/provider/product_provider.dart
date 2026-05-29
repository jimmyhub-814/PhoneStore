import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:phone_store/models/feedBack.dart';
import 'package:phone_store/models/products.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _items = [];
  List<Product> get items => [..._items];
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String userId = FirebaseAuth.instance.currentUser!.uid;

  Stream<List<Product>> streamAllProducts() {
    _isLoading = true;
    return FirebaseFirestore.instance.collection('products').snapshots().map(
      (snapshot) {
        final products = snapshot.docs
            .map((snapshot) {
              try {
                return Product.fromMap(snapshot.data());
              } catch (e) {
                print('Bỏ qua doc không hợp lệ: ${snapshot.id}');
              }
            })
            .whereType<Product>()
            .toList();
        _items.clear();
        _items.addAll(products);
        _isLoading = false;
        return products;
      },
    );
  }

  Stream<Product> streamProduct(String id) {
    return FirebaseFirestore.instance
        .collection('products')
        .doc(id)
        .snapshots()
        .map(
      (snapshot) {
        try {
          return Product.fromMap(snapshot.data() as Map<String, dynamic>);
        } catch (e) {
          debugPrint('Bỏ qua doc không hợp lệ: ${snapshot.id}');
          rethrow;
        }
      },
    );
  }

  Stream<List<Product>> streamProductsByCategory(String categoryId) {
    return FirebaseFirestore.instance
        .collection('products')
        .where('categoryId', isEqualTo: categoryId)
        .snapshots()
        .map((snapshot) {
      try {
        return snapshot.docs.map((doc) => Product.fromMap(doc.data())).toList();
      } catch (e) {
        debugPrint('Bỏ qua doc không hợp lệ: ${snapshot.docs}');
        rethrow;
      }
    });
  }

  Stream<List<Product>> relatedItem(String id, String categoryId) {
    return FirebaseFirestore.instance.collection('products').snapshots().map(
      (snapshot) {
        final products = snapshot.docs
            .map((doc) {
              try {
                final data = doc.data();
                if (data['id'] == null || data['categoryId'] == null)
                  return null;
                return Product.fromMap(data);
              } catch (e) {
                debugPrint('Bỏ qua doc không hợp lệ: ${doc.id}');
                return null;
              }
            })
            .whereType<Product>()
            .toList();

        return products
            .where((element) =>
                element.categoryId == categoryId && element.id != id)
            .toList();
      },
    );
  }

  Future<List<FeedBackModal>> getFeedBack(String productId) async {
    final docRef =
        FirebaseFirestore.instance.collection('products').doc(productId);
    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      return [];
    }

    List<dynamic> feedBackData = docSnapshot.data()?['feedBack'] ?? [];
    return feedBackData
        .map((data) {
          try {
            return FeedBackModal.fromMap(data as Map<String, dynamic>);
          } catch (e) {
            debugPrint('Bỏ qua phản hồi không hợp lệ: $data');
            return null;
          }
        })
        .whereType<FeedBackModal>()
        .toList();
  }

  Future<String> getUserName(String userId) async {
    final user = FirebaseFirestore.instance.collection('users').doc(userId);
    final docSnapshot = await user.get();
    if (!docSnapshot.exists) {
      return 'Unknown User';
    }
    String userData = docSnapshot.data()?['userName'] ?? [];

    return userData;
  }

  Future<String> totalFeedBack(String productId) async {
    final docRef =
        FirebaseFirestore.instance.collection('products').doc(productId);
    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      return '0';
    }

    final rawList = docSnapshot.data()?['feedBack'] as List<dynamic>?;

    if (rawList == null || rawList.isEmpty) {
      return '0';
    }

    // Chuyển từng item thành FeedBackModal
    List<FeedBackModal> feedBackData = rawList.map((item) {
      return FeedBackModal.fromMap(item); // giả sử bạn có fromMap
    }).toList();

    int total = 0;
    for (var item in feedBackData) {
      total += item.vote;
    }

    double average = total / feedBackData.length;
    return average.toStringAsFixed(1); // làm tròn 1 chữ số thập phân
  }

  List<Product> getList(String query) {
    if (query.isEmpty) return [];
    List<String> keywords = query.toLowerCase().split(" ");

    return _items.where((product) {
      String name = product.phoneName.toLowerCase();
      return keywords.every((word) => name.contains(word));
    }).toList();
  }
}
