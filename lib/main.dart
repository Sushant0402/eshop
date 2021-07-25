import 'package:eshop/providers/order.dart';
import 'package:eshop/providers/products_provider.dart';
import 'package:eshop/screens/cartScreen.dart';
import 'package:eshop/screens/order_screen.dart';
import 'package:flutter/material.dart';
import '../screens/product_detail_screen.dart';
import '../screens/product_overview_screen.dart';
import 'package:provider/provider.dart';
import 'providers/cart.dart';
import 'screens/manage_product_screen.dart';
import 'screens/edit_product_scree.dart';
import 'screens/auth_screen.dart';
import 'providers/auth.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        //when we want to subscribe to multiple data container then we can use MultiProvider
        providers: [
          ChangeNotifierProvider.value(
            //ChangeNotifierProvider is one type of provider given by provider package
            value:
                Auth(), //In ChangeNotifierProvider we have to register a data container class object
          ), //to which we want to listen for changes in data, here we have added Products class object because we want to listen to change in data of that class.
          ChangeNotifierProxyProvider<Auth, Products>(
            update: (context, auth, previousProducts) => Products(
                auth.token,
                auth.userId,
                previousProducts != null ? previousProducts.items : []),
            create: (context) => Products("", "", []),
          ),
          ChangeNotifierProxyProvider<Auth, Cart>(
            //proxyProvider means this provider is dependent on another provider.
            update: (context, auth, previousCart) => Cart(auth.token,
                auth.userId, previousCart != null ? previousCart.items : {}),
            create: (context) => Cart("", "", {}),
          ),
          ChangeNotifierProxyProvider<Auth, Order>(
            update: (context, auth, previousOrder) => Order(auth.token,
                auth.userId, previousOrder != null ? previousOrder.orders : []),
            create: (context) => Order("", "", []),
          ),
        ],
        child: Consumer<Auth>(
          builder: (ctx, auth, _) => MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.teal,
              accentColor: Color(0xff52ab98),
              fontFamily: "Sans",
              canvasColor: Color(0xffc8d8e4),
            ),
            home: auth.isAuth
                ? ProductOverviewScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (ctxt, authAutoLoginSnapShot) => authAutoLoginSnapShot
                                .connectionState ==
                            ConnectionState.waiting
                        //so if autoLogin is in waiting state the we will show circular progress bar
                        //and if autologin was successful then - the whole widget will be rebuild and user will show the product overview screen
                        ? SplashScreen()
                        //else we will render the auth screen.
                        : AuthScreen(),
                  ),
            routes: {
              ProductOverviewScreen.routeName: (context) =>
                  ProductOverviewScreen(),
              ProductDetailScreen.routeName: (context) => ProductDetailScreen(),
              CartScreen.routeName: (context) => CartScreen(),
              OrderScreen.routeName: (context) => OrderScreen(),
              ManageProductScreen.routeName: (context) => ManageProductScreen(),
              EditProductScreen.routeName: (context) => EditProductScreen(),
              AuthScreen.routeName: (context) => AuthScreen(),
            },
          ),
        ));
  }
}
