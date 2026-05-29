import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FavoriteProvider extends ChangeNotifier {
  String userId = FirebaseAuth.instance.currentUser!.uid;

// USER favorite
  List<String> _favorite = [];
  List<String> get favorite => [..._favorite];
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  FavoriteProvider() {
    loadFavorite();
  }

  Future<void> loadFavorite() async {
    _isLoading = true;
    notifyListeners();
    _favorite = await _getFavoriteList(userId);
    notifyListeners();
  }

//ADD TO favorite
  void toggleFavorite(String id) async{
    String? favoriteItem = _favorite.firstWhereOrNull((item) {
      return item == id;
    });

    if (favoriteItem != null) {
      print("❌ Xóa khỏi danh sách yêu thích");
      _favorite.removeWhere((item) => item == id);
    } else {
      print("✅ Thêm vào danh sách yêu thích");
      _favorite.add(id);
    }

    _uploadFavoriteToFirebase(userId, _favorite);
    await loadFavorite();
    notifyListeners();
  }

  bool checkItem(String id) {
    String? favoriteItem = _favorite.firstWhereOrNull((item) {
      return item == id;
    });
    if (favoriteItem != null) {
      return true;
    } else {
      return false;
    }
  }

  void handleRemove(String id) {
    _favorite.removeWhere((item) => item == id);
    _uploadFavoriteToFirebase(userId, _favorite);
    notifyListeners();
  }
//SAVE DATA

  Future<void> _uploadFavoriteToFirebase(
      String userId, List<String> favoriteList) async {
    return FirebaseFirestore.instance.collection('users').doc(userId).update({
      'favorite': favoriteList,
    });
  }

  Future<List<String>> _getFavoriteList(String userId) async {
    try {
      final userFavoriteRef =
          FirebaseFirestore.instance.collection('users').doc(userId);
      final docSnapshot = await userFavoriteRef.get();

      if (docSnapshot.exists) {
        List<dynamic> favoriteData = docSnapshot.data()?['favorite'] ?? [];

        // Kiểm tra xem trường 'favorite' có phải là một danh sách hay không và trả về các giá trị đã map.
        return favoriteData.map((item) => item.toString()).toList();
      } else {
        // Xử lý trường hợp không tìm thấy tài liệu người dùng
        print("Không tìm thấy tài liệu người dùng.");
        return [];
      }
    } catch (e) {
      // Ghi lại lỗi và trả về một danh sách rỗng nếu có lỗi xảy ra
      print("Lỗi khi lấy danh sách yêu thích: $e");
      return [];
    }
  }
}
