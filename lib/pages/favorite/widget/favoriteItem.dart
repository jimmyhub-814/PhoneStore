import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phone_store/pages/profile/phone_profile.dart';
import 'package:phone_store/provider/product_provider.dart';
import 'package:provider/provider.dart';

class FavoriteItem extends StatefulWidget {
  FavoriteItem({super.key, required this.id});
  static const routeName = "/favoriteItem";
  String id;
  @override
  State<FavoriteItem> createState() => _FavoriteItemState();
}

class _FavoriteItemState extends State<FavoriteItem> {
  @override
  Widget build(BuildContext context) {
    var productList = Provider.of<ProductProvider>(context).items;
    var productItem =
        productList.firstWhere((product) => product.id == widget.id);
    if (Provider.of<ProductProvider>(context).isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return GestureDetector(
      onTap: (() {
        Navigator.pushNamed(context, PhoneProfilePage.routeName, arguments: {
          "id": productItem.id,
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
                    productItem.phoneImage,
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${productItem.phoneName}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${productItem.phoneDescription}',
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${NumberFormat("#,###", "en_US").format(
                                  productItem.phonePrice -
                                      ((productItem.phonePrice *
                                              productItem.phoneDiscount) /
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
                                '${NumberFormat("#,###", "en_US").format(productItem.phonePrice)}đ',
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
  }
}
