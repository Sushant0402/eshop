import 'package:eshop/widget/drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order.dart' show Order;
import '../widget/order_item.dart';

class OrderScreen extends StatefulWidget {
  static const routeName = "OrderScreen";

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    setState(() {
      _isLoading = true;
    });
    Future.delayed(Duration.zero)
        .then((value) =>
            Provider.of<Order>(context, listen: false).getAndSetOrder())
        .then((value) => setState(() {
              _isLoading = false;
            }));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final orderData = Provider.of<Order>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Orders"),
      ),
      drawer: MyDrawer(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : orderData.orders.length == 0 ? Center(child: Text("Buy Something to see here 🎈"),) : ListView.builder(
              itemCount: orderData.orders.length,
              itemBuilder: (context, index) =>
                  OrderItem(order: orderData.orders[index]),
            ),
    );
  }
}
