import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:phone_store/app_constant.dart';
import 'package:phone_store/auth/authGate.dart';
import 'package:phone_store/firebase_options.dart'; 
import 'package:phone_store/pages/account/account.dart';
import 'package:phone_store/pages/account/widgets/cancelOrder.dart';
import 'package:phone_store/pages/account/widgets/changeInfoOrder.dart';
import 'package:phone_store/pages/account/widgets/detailOrder.dart';
import 'package:phone_store/pages/account/widgets/feedBack.dart';
import 'package:phone_store/pages/account/widgets/order_info.dart';
import 'package:phone_store/pages/account/widgets/order_status.dart';
import 'package:phone_store/pages/account/widgets/user_info.dart';
import 'package:phone_store/pages/categoryItem/category.dart';
import 'package:phone_store/pages/home_page/home_page.dart';
import 'package:phone_store/pages/account/widgets/changePass_page.dart';
import 'package:phone_store/pages/home_page/widgets/buyItem.dart';
import 'package:phone_store/pages/home_page/widgets/home_body.dart';
import 'package:phone_store/pages/login_page/addDetail.dart';
import 'package:phone_store/pages/login_page/verifyOTP.dart';
import 'package:phone_store/pages/notifications/notification.dart';
import 'package:phone_store/pages/profile/phone_profile.dart';
import 'package:phone_store/pages/search/search_page.dart';
import 'package:phone_store/pages/shopping_page/shopping_page.dart';
import 'package:phone_store/provider/category_provider.dart';
import 'package:phone_store/provider/favorite_provider.dart';
import 'package:phone_store/provider/order_provider.dart';
import 'package:phone_store/provider/product_provider.dart';
import 'package:phone_store/provider/cart_provider.dart';
import 'package:phone_store/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = AppConstant.stripePublishableKey;
  await Stripe.instance.applySettings();
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    print("Firebase initialized successfully!");
  } catch (e) {
    print("Firebase initialization error: $e");
  }

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  EmailOTP.config(
    appName: 'Phone Store',
    expiry: 60000,
    otpType: OTPType.numeric,
    emailTheme: EmailTheme.v1,
    otpLength: 4,
  );
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: Colors.red,
      child: Center(
        child: Text(
          details.exceptionAsString(),
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  };
  // debugPaintSizeEnabled = true;
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        child: MaterialApp(
          theme: ThemeData(
            scaffoldBackgroundColor: Colors.white,
          ),
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(1.0),
              ),
              child: child!,
            );
          },
          debugShowCheckedModeBanner: false,
          title: 'Flutter ',
          initialRoute: '/',
          routes: {
            '/': (context) => AuthGate(),
            '/homePage': (context) => HomePage(),
            '/homeBody': (context) => HomeBody(),
            '/category': (context) => CategoryPage(),
            '/phone_profile': (context) => PhoneProfilePage(),
            '/account': (context) => AccountPage(),
            '/user_info': (context) => UserInfoPage(),
            '/order_info': (context) => OrderInfoPage(),
            '/shopping_page': (context) => ShoppingPage(),
            '/setting_page': (context) => SettingPage(),
            '/order_status': (context) => OrderStatusPage(),
            '/changePass_page': (context) => ChangepassPage(),
            '/otppage': (context) => VerifyOTPPage(),
            '/search_page': (context) => SearchPage(),
            '/buyItem': (context) => BuyItem(),
            '/orderDetail': (context) => DetailOrder(),
            '/changeOrderInfo': (context) => ChangeOrderInfo(),
            '/cancelOrder': (context) => CancelOrderPage(),
            '/feedBackPage': (context) => FeedBackPage(),
            '/add_detail_page': (context) => AddDetailPage(),
          },
        ),
      ),
    );
  }
}
