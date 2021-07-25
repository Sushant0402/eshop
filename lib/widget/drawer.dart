import 'package:eshop/screens/auth_screen.dart';
import 'package:eshop/screens/manage_product_screen.dart';
import 'package:eshop/screens/order_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:eshop/screens/product_overview_screen.dart';
import 'package:provider/provider.dart';
import 'package:eshop/providers/auth.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Text("Shopper", style: TextStyle(
                fontSize: 30, fontWeight: FontWeight.bold,
              ),),
              GestureDetector(
                child: ListTile(
                  leading: Icon(Icons.shop),
                  title: Text("Shop"),
                ),
                onTap: (){
                  Navigator.pushReplacementNamed(context, ProductOverviewScreen.routeName);
                },
              ),
              GestureDetector(
                child: ListTile(
                  leading: Icon(Icons.receipt),
                  title: Text("Orders"),
                ),
                onTap: (){
                  Navigator.pushReplacementNamed(context, OrderScreen.routeName);
                },
              ),
              GestureDetector(
                child: ListTile(
                  leading: Icon(Icons.edit),
                  title: Text("Manage Products"),
                ),
                onTap: (){
                  Navigator.pushReplacementNamed(context, ManageProductScreen.routeName);
                },
              ),
              GestureDetector(
                child: ListTile(
                  leading: Icon(Icons.exit_to_app),
                  title: Text("Logout"),
                ),
                onTap: () async {
                  Navigator.of(context).pop();
                  await Provider.of<Auth>(context, listen: false).logout();
                  // Navigator.pushReplacementNamed(context, AuthScreen.routeName);
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
