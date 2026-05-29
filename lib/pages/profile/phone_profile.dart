import 'package:collection/collection.dart'; 
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phone_store/models/cart.dart';
import 'package:phone_store/models/products.dart';
import 'package:phone_store/pages/home_page/widgets/buyItem.dart';
import 'package:phone_store/pages/search/search_page.dart';
import 'package:phone_store/provider/cart_provider.dart';
import 'package:phone_store/pages/shopping_page/shopping_page.dart';
import 'package:phone_store/provider/favorite_provider.dart';
import 'package:phone_store/provider/product_provider.dart';
import 'package:provider/provider.dart';

class PhoneProfilePage extends StatefulWidget {
  static const routeName = '/phone_profile';
  PhoneProfilePage({super.key});

  @override
  State<PhoneProfilePage> createState() => _PhoneProfilePageState();
}

class _PhoneProfilePageState extends State<PhoneProfilePage> {
 
  void addToCart(String id, int quantity) {
    final cartProvider = context.read<CartProvider>();

    // Lấy cart item và sản phẩm theo id
    Cart? cartItem =
        cartProvider.cart.firstWhereOrNull((item) => item.id == id);
    Product? product = cartProvider.items.firstWhereOrNull((p) => p.id == id);

    if (product == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sản phẩm không tồn tại hoặc chưa được tải')),
      );
      return;
    }

    final currentQuantityInCart = cartItem?.quantity ?? 0;
    final totalQuantity = currentQuantityInCart + quantity;

    if (totalQuantity > product.phoneQuantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Số lượng sản phẩm không đủ')),
      );
      return;
    }

    cartProvider.addCart(id, quantity);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã thêm vào giỏ hàng')),
    );
  }

  Widget build(BuildContext context) {
    final ValueNotifier<int> counter = ValueNotifier<int>(1);
    final ValueNotifier<bool> isMax = ValueNotifier<bool>(false);

    Size size = MediaQuery.of(context).size;
    final data = ModalRoute.of(context)!.settings.arguments as Map;

    return StreamBuilder(
      stream: Provider.of<ProductProvider>(context, listen: false)
          .streamProduct(data['id']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Center(child: Text("Không tìm thấy sản phẩm"));
        }
        final product = snapshot.data!;
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(58),
            child: AppBar(
              elevation: 0,
              foregroundColor: Colors.white,
              backgroundColor: Color.fromRGBO(203, 109, 128, 1),
              title: SizedBox(
                height: 36,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SearchPage()),
                          );
                        },
                        child: Hero(
                          tag: 'search-bar',
                          child: Material(
                            color: Colors.transparent,
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(11),
                                  color: Colors.white),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.search,
                                      size: 18,
                                      color:
                                          const Color.fromARGB(255, 82, 82, 82),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      'Tìm kiếm',
                                      style: TextStyle(
                                          color: const Color.fromARGB(
                                              255, 82, 82, 82)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, ShoppingPage.routeName);
                      },
                      icon: Icon(
                        Icons.shopping_cart_outlined,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  color: Color.fromRGBO(203, 109, 128, 1),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Column(
                        children: [
                          SizedBox(
                            height: size.width / 2.3,
                          ),
                          Container(
                            width: size.width,
                            padding: EdgeInsets.only(top: 35),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(56),
                              ),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Thông tin sản phẩm',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${product.phoneName}\n${product.phoneDescription}',
                                            style: TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                          Consumer<FavoriteProvider>(
                                            builder:
                                                (context, provider, child) {
                                              return Container(
                                                padding: EdgeInsets.all(
                                                  4,
                                                ),
                                                margin: const EdgeInsets.only(
                                                  right: 20,
                                                ),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color:
                                                          const Color.fromARGB(
                                                              255,
                                                              225,
                                                              225,
                                                              225),
                                                      width:
                                                          2), // viền màu xanh
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20), // bo góc nếu cần
                                                ),
                                                child: InkWell(
                                                  onTap: () {
                                                    provider.toggleFavorite(
                                                        product.id);
                                                  },
                                                  child: Icon(
                                                    Icons.favorite,
                                                    color: provider.checkItem(
                                                            product.id)
                                                        ? Colors.red
                                                        : const Color.fromARGB(
                                                            255, 225, 225, 225),
                                                    size: 20,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        'Số lượng',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            width: 33,
                                            height: 33,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Color.fromRGBO(
                                                  177, 234, 253, 1),
                                            ),
                                            child: GestureDetector(
                                              onTap: () {
                                                if (counter.value > 1) {
                                                  counter
                                                      .value--; // Prevent counter from going below 1
                                                }
                                              },
                                              child: const Icon(
                                                Icons.remove,
                                                color: Color.fromRGBO(
                                                    72, 182, 219, 1),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 15,
                                            ),
                                            child: ValueListenableBuilder<int>(
                                              valueListenable: counter,
                                              builder: (context, value, child) {
                                                return Text(
                                                  '$value',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          Container(
                                            width: 33,
                                            height: 33,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Color.fromRGBO(
                                                  177, 234, 253, 1),
                                            ),
                                            child: GestureDetector(
                                              onTap: isMax.value
                                                  ? null
                                                  : () {
                                                      if (product
                                                              .phoneQuantity >
                                                          counter.value) {
                                                        counter.value++;

                                                        isMax.value = false;
                                                      } else {
                                                        isMax.value = true;

                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                                'Số lượng sản phẩm đã đạt tối đa'),
                                                          ),
                                                        );
                                                      }
                                                    },
                                              child: const Icon(
                                                Icons.add,
                                                color: Color.fromRGBO(
                                                    72, 182, 219, 1),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Text(
                                        'Đánh giá',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      FutureBuilder(
                                        future: Provider.of<ProductProvider>(
                                                context)
                                            .getFeedBack(data['id']),
                                        builder: (context, snapshot) {
                                          final ValueNotifier<bool> isExpanded =
                                              ValueNotifier(false);
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Center(
                                                child:
                                                    CircularProgressIndicator());
                                          }
                                          if (!snapshot.hasData ||
                                              snapshot.data == null ||
                                              (snapshot.data as List).isEmpty) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 10,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  "Không có đánh giá cho sản phẩm này",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                          final feedbacks = snapshot.data!;

                                          return ValueListenableBuilder(
                                            valueListenable: isExpanded,
                                            builder: (context, value, _) {
                                              return Column(
                                                children: [
                                                  ...feedbacks
                                                      .asMap()
                                                      .entries
                                                      .map(
                                                    (entry) {
                                                      int index = entry.key;
                                                      var item = entry.value;
                                                      if (index > 0 && !value)
                                                        return SizedBox
                                                            .shrink();
                                                      return ListTile(
                                                        title: FutureBuilder(
                                                          future: Provider.of<
                                                                      ProductProvider>(
                                                                  context)
                                                              .getUserName(
                                                                  item.userId),
                                                          builder: (context,
                                                              snapshot) {
                                                            final userName =
                                                                snapshot.data;
                                                            return snapshot
                                                                        .connectionState ==
                                                                    ConnectionState
                                                                        .waiting
                                                                ? Text(
                                                                    "Đang tải tên người dùng...")
                                                                : Text(
                                                                    userName ??
                                                                        'Người dùng không xác định',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                    ),
                                                                  );
                                                          },
                                                        ),
                                                        subtitle: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children:
                                                                  List.generate(
                                                                item.vote,
                                                                (index) => Icon(
                                                                  Icons.star,
                                                                  color: Colors
                                                                      .yellow,
                                                                  size: 15,
                                                                ),
                                                              ),
                                                            ),
                                                            Text(item
                                                                .feedBackText)
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  ).toList(),
                                                  if (feedbacks.length > 1)
                                                    TextButton(
                                                      onPressed: () {
                                                        isExpanded.value =
                                                            !isExpanded.value;
                                                      },
                                                      style:
                                                          TextButton.styleFrom(
                                                        padding:
                                                            EdgeInsets.zero,
                                                        minimumSize: Size(0, 0),
                                                        tapTargetSize:
                                                            MaterialTapTargetSize
                                                                .shrinkWrap,
                                                        splashFactory: NoSplash
                                                            .splashFactory,
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            value
                                                                ? "Ẩn bớt"
                                                                : "Xem thêm",
                                                            style: TextStyle(
                                                                fontSize: 11,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: Colors
                                                                    .grey),
                                                          ),
                                                          Icon(
                                                            value
                                                                ? Icons
                                                                    .keyboard_arrow_up
                                                                : Icons
                                                                    .keyboard_arrow_down,
                                                            size: 12,
                                                            color: Colors.grey,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        'Sản phẩm liên quan',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      StreamBuilder(
                                        stream: Provider.of<ProductProvider>(
                                                context,
                                                listen: false)
                                            .relatedItem(
                                                product.id, product.categoryId),
                                        builder: (context, snapshotss) {
                                          if (snapshotss.connectionState ==
                                              ConnectionState.waiting) {
                                            return Center(
                                                child:
                                                    CircularProgressIndicator());
                                          }

                                          if (!snapshotss.hasData ||
                                              snapshotss.data == null) {
                                            return Center(
                                                child: Column(
                                              children: [
                                                Text("Không tìm thấy sản phẩm"),
                                                SizedBox(
                                                  height: size.width,
                                                ),
                                                Text("Không tìm thấy sản phẩm"),
                                              ],
                                            ));
                                          }
                                          final relatedProduct =
                                              snapshotss.data!;
                                          return relatedProduct.isNotEmpty
                                              ? GridView.builder(
                                                  physics:
                                                      NeverScrollableScrollPhysics(),
                                                  shrinkWrap: true,
                                                  gridDelegate:
                                                      SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 2,
                                                    crossAxisSpacing: 10,
                                                    mainAxisSpacing: 5,
                                                    childAspectRatio: 0.7,
                                                  ),
                                                  itemCount:
                                                      relatedProduct.length,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int index) {
                                                    print(
                                                        relatedProduct.length);
                                                    return GestureDetector(
                                                      onTap: (() {
                                                        Navigator.pushNamed(
                                                          context,
                                                          PhoneProfilePage
                                                              .routeName,
                                                          arguments: {
                                                            "id":
                                                                relatedProduct[
                                                                        index]
                                                                    .id,
                                                          },
                                                        );
                                                      }),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                          Radius.circular(10),
                                                        ),
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(
                                                              Radius.circular(
                                                                  10),
                                                            ),
                                                            border: Border.all(
                                                              width: 1,
                                                              color: Color
                                                                  .fromRGBO(
                                                                      225,
                                                                      225,
                                                                      225,
                                                                      1),
                                                            ),
                                                            color: Colors.white,
                                                          ),
                                                          width:
                                                              double.infinity,
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Expanded(
                                                                flex: 2,
                                                                child:
                                                                    Container(
                                                                  width: double
                                                                      .infinity,
                                                                  child: Image
                                                                      .network(
                                                                    relatedProduct[
                                                                            index]
                                                                        .phoneImage,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  width: 10),
                                                              Expanded(
                                                                flex: 1,
                                                                child:
                                                                    Container(
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          horizontal:
                                                                              10),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Text(
                                                                        '${relatedProduct[index].phoneName}',
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              10,
                                                                          fontWeight:
                                                                              FontWeight.w700,
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        '${relatedProduct[index].phoneDescription}',
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              10,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          height:
                                                                              1.5,
                                                                        ),
                                                                      ),
                                                                      Row(
                                                                        children:
                                                                            List.generate(
                                                                          5,
                                                                          (index) =>
                                                                              const Icon(
                                                                            Icons.star,
                                                                            color:
                                                                                Color(0xffFFD25D),
                                                                            size:
                                                                                15,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Row(
                                                                            children: [
                                                                              Text(
                                                                                '${NumberFormat("#,###", "en_US").format(
                                                                                  relatedProduct[index].phonePrice - ((relatedProduct[index].phonePrice * relatedProduct[index].phoneDiscount) / 100),
                                                                                )}đ',
                                                                                style: TextStyle(
                                                                                  color: Color(0xffEF6A62),
                                                                                  letterSpacing: 0.38,
                                                                                  fontWeight: FontWeight.w700,
                                                                                ),
                                                                              ),
                                                                              SizedBox(width: 10),
                                                                              Text(
                                                                                '${NumberFormat("#,###", "en_US").format(relatedProduct[index].phonePrice)}đ',
                                                                                style: TextStyle(
                                                                                  color: Colors.grey,
                                                                                  fontSize: 10,
                                                                                  fontWeight: FontWeight.w500,
                                                                                  decoration: TextDecoration.lineThrough,
                                                                                  decorationColor: Colors.grey,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                )
                                              : Center(
                                                  child: Text(
                                                    'Không có sản phẩm nào',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          width: size.width,
                          height: size.width / 2,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 40, right: 10),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    height: size.width / 2.2,
                                    width: size.width / 3,
                                    color: Colors.grey[200],
                                    child: FittedBox(
                                      fit: BoxFit.cover,
                                      child: Image.network(product.phoneImage),
                                    ),
                                  ),
                                ),
                              ),
                              Flexible(
                                flex: 1,
                                child: Container(
                                  height: size.width / 2.2,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.only(left: 20),
                                        height: size.width / 3.5,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${product.phoneName}',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 19,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  //    product.phoneVote.toString(),
                                                  '0',
                                                  style:
                                                      TextStyle(fontSize: 12),
                                                ),
                                                Icon(
                                                  Icons.star,
                                                  color: Colors.yellow,
                                                  size: 15,
                                                ),
                                              ],
                                            ),
                                            Text(
                                              '${NumberFormat("#,###", "en_US").format(product.phonePrice)}đ',
                                              maxLines: 1,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                decorationColor: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Flexible(
                                        flex: 2,
                                        child: Container(
                                          alignment: Alignment.centerLeft,
                                          height: 52,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(17),
                                              bottomLeft: Radius.circular(17),
                                            ),
                                            color:
                                                Color.fromRGBO(178, 63, 86, 1),
                                          ),
                                          child: Text(
                                            '${NumberFormat("#,###", "en_US").format(
                                              product.phonePrice -
                                                  ((product.phonePrice *
                                                          product
                                                              .phoneDiscount) /
                                                      100),
                                            )}đ',
                                            style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
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
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: Offset(0, 0),
                ),
              ],
            ),
            height: 62,
            child: BottomAppBar(
              padding: EdgeInsets.symmetric(horizontal: 10),
              color: const Color.fromARGB(255, 255, 255, 255),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        addToCart(product.id, counter.value);
                      },
                      child: Text(
                        'Thêm vào giỏ hàng',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Color(0xffb23f56),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Color(0xffb23f56), width: 1),
                          borderRadius: BorderRadius.circular(24.5),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (counter.value > 0) {
                          List<Cart> cartItems = [
                            Cart(id: product.id, quantity: counter.value),
                          ];
                          Navigator.pushNamed(
                            context,
                            BuyItem.routeName,
                            arguments: {
                              "product": cartItems,
                              "price": (product.phonePrice -
                                      ((product.phonePrice *
                                              product.phoneDiscount) /
                                          100)) *
                                  counter.value,
                            },
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Vui lòng chọn sản phẩm hợp lệ')),
                          );
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xffb23f56),
                          borderRadius: BorderRadius.circular(24.5),
                        ),
                        child: Center(
                          child: ValueListenableBuilder<int>(
                            valueListenable: counter,
                            builder: (context, value, child) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Mua ngay",
                                    maxLines: 1,
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.white),
                                  ),
                                  Text(
                                    '${NumberFormat("#,###", "en_US").format(
                                      (product.phonePrice -
                                              ((product.phonePrice *
                                                      product.phoneDiscount) /
                                                  100)) *
                                          counter.value,
                                    )}đ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
