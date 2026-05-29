import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phone_store/pages/profile/phone_profile.dart';
import 'package:phone_store/provider/favorite_provider.dart';
import 'package:phone_store/provider/product_provider.dart';
import 'package:provider/provider.dart';

class BestSellerItem extends StatefulWidget {
  const BestSellerItem({super.key});

  @override
  State<BestSellerItem> createState() => _BestSellerItemState();
}

class _BestSellerItemState extends State<BestSellerItem> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nổi bật trong tháng',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        SizedBox(
          height: size.width / 4.9,
          child: StreamBuilder(
            stream: Provider.of<ProductProvider>(context, listen: false)
                .streamAllProducts(),
            builder: (context, snapshot) {
              final products = snapshot.data ?? [];
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (!snapshot.hasData || products.isEmpty) {
                return const Center(
                  child: Text(
                    'No products available',
                    style: TextStyle(color: Colors.red),
                  ),
                );
              } else {
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, PhoneProfilePage.routeName,
                            arguments: {
                              "id": product.id,
                            });
                      },
                      child: Container(
                        margin: index != products.length - 1
                            ? const EdgeInsets.only(right: 15)
                            : const EdgeInsets.only(right: 0),
                        padding: index != 0
                            ? const EdgeInsets.only(top: 5)
                            : const EdgeInsets.only(top: 5, left: 5),
                        width: size.width / 1.8,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                SizedBox(
                                  height: size.width / 5,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      product.phoneImage,
                                      fit: BoxFit.cover,
                                      width: size.width / 5,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: -5,
                                  left: -5,
                                  child: Consumer<FavoriteProvider>(
                                    builder: (context, provider, child) {
                                      return Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          color: Colors.white,
                                        ),
                                        child: InkWell(
                                          splashColor: Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          onTap: () {
                                            provider.toggleFavorite(
                                              product.id,
                                            );
                                          },
                                          child: Icon(
                                            provider.checkItem(product.id)
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color:
                                                provider.checkItem(product.id)
                                                    ? Colors.red
                                                    : const Color(0xffCBCBCB),
                                            size: 14,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            SizedBox(
                              height: size.width / 4.5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    product.phoneName.length > 25
                                        ? product.phoneName.substring(0, 25) +
                                            '...'
                                        : product.phoneName,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    product.phoneDescription,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      height: 1.5,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      FutureBuilder<String>(
                                        future: Provider.of<ProductProvider>(
                                                context,
                                                listen: false)
                                            .totalFeedBack(product.id),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                            return const SizedBox(
                                              width: 20,
                                              height: 10,
                                              child: CircularProgressIndicator(strokeWidth: 1),
                                            );
                                          } else if (snapshot.hasError) {
                                            return const Text(
                                              '0',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            );
                                          } else {
                                            return Text(
                                              snapshot.data ?? '1',
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                      const Icon(
                                        Icons.star,
                                        color: Color(0xffF6A623),
                                        size: 12,
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${NumberFormat("#,###", "en_US").format(
                                      product.phonePrice -
                                          ((product.phonePrice *
                                                  product.phoneDiscount) /
                                              100),
                                    )}đ',
                                    style: const TextStyle(
                                      color: Color(0xffEF6A62),
                                      letterSpacing: 0.38,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
