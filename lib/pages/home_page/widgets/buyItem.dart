import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phone_store/models/order.dart';
import 'package:phone_store/models/products.dart';
import 'package:phone_store/pages/home_page/widgets/sucess.dart';
import 'package:phone_store/provider/cart_provider.dart';
import 'package:phone_store/provider/order_provider.dart';
import 'package:phone_store/provider/product_provider.dart';
import 'package:provider/provider.dart';

import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:phone_store/payment_service.dart';

class BuyItem extends StatefulWidget {
  static const routeName = '/buyItem';
  const BuyItem({super.key});

  @override
  State<BuyItem> createState() => _BuyItemState();
}

class _BuyItemState extends State<BuyItem> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  ValueNotifier<String> selected =
      ValueNotifier<String>('Thanh toán khi nhận hàng');
  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
  }

  bool isLoading = false;
  Map<String, dynamic>? paymentIntent;
  PaymentService paymentService = PaymentService();
  int quantity = 1;

  Future<bool> makePayment(double price) async {
    try {
      if (!mounted) return false;
      setState(() => isLoading = true);
      paymentIntent = null;
      paymentIntent =
          await paymentService.createPaymentIntent('${price}', 'USD');
      if (paymentIntent == null) {
        throw Exception("Không tạo được PaymentIntent");
      }

      //   Ensure Stripe is initialized before calling initPaymentSheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent!['client_secret'],
          merchantDisplayName: 'Sell Phone',
          style: ThemeMode.light,
          allowsDelayedPaymentMethods: false,
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: 'VN',
            currencyCode: 'VND',
            testEnv: true,
          ),
        ),
      );

      // Add a short delay to ensure the payment sheet is ready
      await Future.delayed(Duration(milliseconds: 300));

      return await displayPaymentSheet();
    } catch (e) {
      print("Error making payment: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Không thể khởi tạo thanh toán: $e")),
      );
      return false;
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      paymentIntent = null; // Reset payment intent after successful payment
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment successful!")),
      );
      return true;
    } on StripeException catch (e) {
      print('Stripe exception: ${e.error.localizedMessage}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Thanh toán thất bại")),
      );
      return false;
    } catch (e) {
      print("Error displaying payment sheet: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi hiển thị form thanh toán: $e")),
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final data = ModalRoute.of(context)!.settings.arguments as Map; 
    final List<Product> listProduct = []; 
    List<int> quantities = [];
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Thanh toán',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 230, 77, 50),
      ),
      body: StreamBuilder(
        stream: getUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            Map<String, dynamic>? user = snapshot.data!.data();
            return Column(
              children: [
                Expanded(
                  child: Container(
                    color: const Color.fromARGB(255, 241, 241, 241),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/changeOrderInfo',
                                arguments: {
                                  "user": user,
                                });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Color.fromARGB(255, 230, 77, 50),
                                ),
                                const SizedBox(width: 5),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(user?['userName'] ?? ''),
                                        SizedBox(width: 5),
                                        Text(
                                          user?['userPhone'] ??
                                              'Chưa có số điện thoại',
                                          maxLines: 1,
                                          style: TextStyle(
                                            color: const Color.fromARGB(
                                                255, 173, 173, 173),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      user?['address'] ?? 'Chưa cập nhật',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                Spacer(),
                                Icon(Icons.arrow_forward_ios),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        StreamBuilder(
                          stream: Provider.of<ProductProvider>(context,listen: false).streamAllProducts(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (snapshot.hasData) {
                              final products = snapshot.data!;

                              for (var product in products) {
                                for (var i = 0;
                                    i < data['product'].length;
                                    i++) {
                                  if (product.id == data['product'][i].id) {
                                    listProduct.add(product);
                                    quantities.add(data['product'][i].quantity);
                                  }
                                }
                              }
                              if (products.isEmpty) {
                                return const Center(
                                  child: Text('No products available'),
                                );
                              }
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: listProduct.length,
                                itemBuilder: (context, i) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Container(
                                    width: size.width - 30,
                                    height: 70,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.network(
                                            listProduct[i].phoneImage,
                                            width: 70,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                listProduct[i].phoneName,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    '${NumberFormat("#,###", "en_US").format(
                                                      listProduct[i]
                                                              .phonePrice -
                                                          ((listProduct[i]
                                                                      .phonePrice *
                                                                  listProduct[i]
                                                                      .phoneDiscount) /
                                                              100),
                                                    )}đ',
                                                    style: TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 230, 77, 50),
                                                      letterSpacing: 0.38,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    '${NumberFormat("#,###", "en_US").format(listProduct[i].phonePrice)}đ',
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      decoration: TextDecoration
                                                          .lineThrough,
                                                    ),
                                                  ),
                                                  Spacer(),
                                                  Text(
                                                    'x${quantities[i]}',
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return const Center(
                                child: Text('No products available'),
                              );
                            }
                          },
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Phương thức thanh toán',
                                maxLines: 1,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              ValueListenableBuilder<String>(
                                valueListenable: selected,
                                builder: (context, value, child) {
                                  final options = [
                                    'Thanh toán khi nhận hàng',
                                    'Thanh toán bằng thẻ ngân hàng'
                                  ];

                                  return Column(
                                    children: List.generate(
                                        options.length * 2 - 1, (index) {
                                      if (index.isOdd) {
                                        return Divider(
                                            height: 1); // Divider giữa các tile
                                      } else {
                                        final option = options[index ~/ 2];
                                        return RadioListTile<String>(
                                          title: Text(
                                            '$option',
                                            maxLines: 1,
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                          value: option,
                                          groupValue: value,
                                          onChanged: (newValue) {
                                            selected.value = newValue!;
                                          },
                                          activeColor: Colors
                                              .blue, // 🌟 Màu của ô chọn khi được chọn
                                          controlAffinity: ListTileControlAffinity
                                              .trailing, // Đưa ô chọn ra sau title
                                          visualDensity: VisualDensity
                                              .compact, // Thu gọn chiều cao
                                          // Thu gọn tổng thể
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 16),
                                        );
                                      }
                                    }),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 70,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Tổng cộng',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            '${NumberFormat("#,###", "en_US").format(data['price'])}đ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xffEF6A62),
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: isLoading
                            ? null
                            : () async {
                                setState(() {
                                  isLoading = true;
                                });

                                if (user!['address'] == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Vui lòng cập nhật địa chỉ đặt hàng.'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );

                                  setState(() {
                                    isLoading = false;
                                  });
                                  return;
                                }

                                final order = UserOrder(
                                  id: DateTime.now()
                                      .millisecondsSinceEpoch
                                      .toString(),
                                  nameUser: user['userName'],
                                  userId:
                                      FirebaseAuth.instance.currentUser!.uid,
                                  orderProduct: data['product'],
                                  orderStatus: 'Chờ giao hàng',
                                  userDate: DateFormat('HH:mm dd/MM/yyyy')
                                      .format(DateTime.now()),
                                  userPhone: user['userPhone'],
                                  userAddress: user['userAddress'],
                                  methodPayment: selected.value,
                                  totalPrice: data['price'],
                                );

                                if (selected.value ==
                                    'Thanh toán khi nhận hàng') {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (_) => const Center(
                                        child: CircularProgressIndicator()),
                                  );

                                  await Provider.of<OrderProvider>(context,
                                          listen: false)
                                      .uploadOrderToFirebase(order);
                                  Provider.of<CartProvider>(context,
                                          listen: false)
                                      .deleteProductWhenBuy(data['product']);

                                  if (mounted) {
                                    Navigator.pop(
                                        context); // pop loading dialog
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => CompleteOrder()),
                                    );
                                  }
                                } else if (selected.value ==
                                    'Thanh toán bằng thẻ ngân hàng') {
                                  final isPaid =
                                      await makePayment(data['price']);

                                  if (!isPaid) {
                                    // Nếu thanh toán thất bại, thông báo lỗi và không làm gì thêm
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              "Thanh toán thất bại. Vui lòng thử lại")),
                                    );
                                    setState(() => isLoading = false);
                                    return;
                                  }

                                  // Nếu thanh toán thành công thì mới upload đơn hàng
                                  if (mounted) {
                                    await Provider.of<OrderProvider>(context,
                                            listen: false)
                                        .uploadOrderToFirebase(order);

                                    await Future.delayed(Duration(seconds: 1));

                                    if (mounted) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => CompleteOrder()),
                                      );
                                    }
                                  }

                                  setState(() => isLoading = false);
                                }
                              },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Text(
                            'Đặt hàng',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 230, 77, 50),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            );
          } else {
            return const Center(
              child: Text('No user data available'),
            );
          }
        },
      ),
    );
  }
}
