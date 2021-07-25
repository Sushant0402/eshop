import 'package:eshop/providers/order.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart' show Cart; //only import Cart from cart.dart
import '../widget/cartItem.dart';
import 'package:eshop/screens/order_screen.dart';

class CartScreen extends StatelessWidget {
  static const routeName = "CartScreen";

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Cart"),
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(10),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(), //space take all the space between widget.
                  Chip(label: Text("\$"+cart.totalAmount.toStringAsFixed(2))),
                  SizedBox(
                    width: 5,
                  ),
                  OrderButton(cart: cart)
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              child: cart.items.length == 0  ? Center(child: Text("It feels so light 🛒"),) :ListView.builder(
                itemBuilder: (context, index) {
                  return CartItem(
                    id: cart.items.values.toList()[index].id,
                    itemkey: cart.items.keys.toList()[index],
                    title: cart.items.values.toList()[index].title,
                    price: cart.items.values.toList()[index].price,
                    quantity: cart.items.values.toList()[index].quantity,
                  );
                },
                itemCount: cart.itemCount,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key? key,
    required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {

  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      child: _isLoading? CircularProgressIndicator() : Text("ORDER NOW"),
      onPressed: widget.cart.totalAmount <=0 || _isLoading ? null : () async {
        try {
          await showDialog(context: context, builder: (context) =>
              AlertDialog(
                title: Text("Confirm Order"),
                content: Text("Do you want to place the order ?"),
                actions: [
                  TextButton(child: Text("Cancel"),
                    onPressed: () => Navigator.pop(context),),
                  TextButton(child: Text("Ok"), onPressed: () async {
                    Navigator.pop(context);
                    setState(() {
                      _isLoading = true;
                    });
                    await Provider.of<Order>(context, listen: false).addOrder(
                        widget.cart.items.values.toList(),
                        widget.cart.totalAmount);
                    await widget.cart.clearCart();
                    setState(() {
                      _isLoading = false;
                    });
                  },)
                ],
              )
          );
          await Future.delayed(Duration(seconds: 1));
          showDialog(context: context, builder: (context) =>
              AlertDialog(
                title: Text("Go To Order Screen"),
                content: Text("Do you want to go to order screen?"),
                actions: [
                  TextButton(child: Text("Cancel"),
                    onPressed: () => Navigator.pop(context),),
                  TextButton(child: Text("Ok"), onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(
                        context, OrderScreen.routeName);
                  })
                ],
              )
          );
        }catch(error){
          print(error);
        }
      });
  }
}

