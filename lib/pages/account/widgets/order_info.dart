import 'package:flutter/material.dart';
import 'package:phone_store/pages/account/widgets/order_status.dart';
import 'package:phone_store/provider/order_provider.dart';
import 'package:provider/provider.dart';

class OrderInfoPage extends StatefulWidget {
  const OrderInfoPage({super.key});
  static String routeName = '/order_info';
  @override
  State<OrderInfoPage> createState() => _OrderInfoPageState();
}

class _OrderInfoPageState extends State<OrderInfoPage> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(0, 255, 255, 255),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.keyboard_backspace,
            color: Color.fromRGBO(203, 89, 128, 1),
          ),
        ),
        title: Text(
          'Quản lí đơn hàng',
          style: TextStyle(
            color: Color.fromRGBO(203, 89, 128, 1),
          ),
        ),
      ),
      body: StreamBuilder(
          stream:
              Provider.of<OrderProvider>(context, listen: false).streamOrder(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: const CircularProgressIndicator());
            } else {
              final data = snapshot.data;
              int waitingPrepair = 0;
              int waitingDelivery = 0;
              int completeOrder = 0;
              if (data != null) {
                waitingPrepair = data
                    .where((order) => order.orderStatus == "Chờ giao hàng")
                    .toList()
                    .length;
                waitingDelivery = data
                    .where((order) => order.orderStatus == "Đang giao hàng")
                    .toList()
                    .length;
                completeOrder = data
                    .where((order) => order.orderStatus == "Đã giao")
                    .toList()
                    .length;
              }

              return Container(
                width: size.width,
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 30,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Đơn mua',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              'Xem lịch sử mua hàng',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            Icon(Icons.arrow_right_rounded),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              OrderStatusPage.routeName,
                              arguments: {"index": 0},
                            );
                          },
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(3.0),
                                    child: Icon(
                                      Icons.alarm_on_outlined,
                                      size: 30,
                                    ),
                                  ),
                                  if (waitingPrepair > 0)
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: CircleAvatar(
                                        radius: 6,
                                        backgroundColor: Colors.red,
                                        child: Text(
                                          waitingPrepair.toString(),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 8,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Text(
                                'Chờ giao hàng',
                                style: TextStyle(
                                  fontSize: 11,
                                ),
                              )
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              OrderStatusPage.routeName,
                              arguments: {"index": 1},
                            );
                          },
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(3.0),
                                    child: Icon(
                                      Icons.fire_truck,
                                      size: 30,
                                    ),
                                  ),
                                  if (waitingDelivery > 0)
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: CircleAvatar(
                                        radius: 6,
                                        backgroundColor: Colors.red,
                                        child: Text(
                                          waitingDelivery.toString(),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 8,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Text(
                                'Đang giao hàng',
                                style: TextStyle(
                                  fontSize: 11,
                                ),
                              )
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              OrderStatusPage.routeName,
                              arguments: {"index": 2},
                            );
                          },
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(3.0),
                                    child: Icon(
                                      Icons.download_done_rounded,
                                      size: 30,
                                    ),
                                  ),
                                  if (completeOrder > 0)
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: CircleAvatar(
                                        radius: 6,
                                        backgroundColor: Colors.red,
                                        child: Text(
                                          completeOrder.toString(),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 8,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Text(
                                'Đã giao',
                                style: TextStyle(
                                  fontSize: 11,
                                ),
                              )
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              OrderStatusPage.routeName,
                              arguments: {"index": 3},
                            );
                          },
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(3.0),
                                child: Icon(
                                  Icons.stars,
                                  size: 30,
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Text(
                                'Đánh giá',
                                style: TextStyle(
                                  fontSize: 11,
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }
          }),
    );
  }
}
