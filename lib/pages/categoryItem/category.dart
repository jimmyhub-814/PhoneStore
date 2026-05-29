import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phone_store/pages/profile/phone_profile.dart';
import 'package:phone_store/provider/product_provider.dart';
import 'package:provider/provider.dart';

class CategoryPage extends StatefulWidget {
  CategoryPage({super.key});
  static const routeName = "/category";
  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  @override
  Widget build(BuildContext context) {
    final data = ModalRoute.of(context)!.settings.arguments as Map;

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Color.fromRGBO(203, 89, 128, 1),
        title: Text(
          data['categoryName'],
          style: TextStyle(
            color: Color.fromRGBO(203, 89, 128, 1),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: Provider.of<ProductProvider>(context, listen: false)
            .streamProductsByCategory(data['categoryId']),
        builder: (context, snapshot) {
          print("Category ID: ${data['categoryId']}");
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            print("Error: ${snapshot.error}");
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            print("No products found for category: ${data['categoryId']}");
            return Center(
              child: Text(
                'No categories available',
                style:
                    TextStyle(color: const Color.fromARGB(255, 215, 215, 215)),
              ),
            );
          } else {
            final products = snapshot.data!;
            print("Products found: ${products.length}");

            return GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 5,
                childAspectRatio: 0.7,
              ),
              itemCount: products.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: (() {
                    Navigator.pushNamed(context, PhoneProfilePage.routeName,
                        arguments: {
                          "id": products[index].id,
                        });
                  }),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                        border: Border.all(
                          width: 1,
                          color: Color.fromRGBO(225, 225, 225, 1),
                        ),
                        color: Colors.white,
                      ),
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              width: double.infinity,
                              child: Image.network(
                                products[index].phoneImage,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          /// PHẦN MÔ TẢ DƯỚI
                          Expanded(
                            flex: 1,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${products[index].phoneName}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    '${products[index].phoneDescription}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      height: 1.5,
                                    ),
                                  ),
                                  Row(
                                    children: List.generate(
                                      5,
                                      (index) => const Icon(
                                        Icons.star,
                                        color: Color(0xffFFD25D),
                                        size: 15,
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
                                              products[index].phonePrice -
                                                  ((products[index].phonePrice *
                                                          products[index]
                                                              .phoneDiscount) /
                                                      100),
                                            )}đ',
                                            style: TextStyle(
                                              color: Color(0xffEF6A62),
                                              letterSpacing: 0.38,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            '${NumberFormat("#,###", "en_US").format(products[index].phonePrice)}đ',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                              decoration:
                                                  TextDecoration.lineThrough,
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
            );
          }
        },
      ),
    );
  }
}
