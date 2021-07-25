import 'package:eshop/screens/product_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';

class CartItem extends StatelessWidget {
  final String id;
  final String itemkey;
  final String title;
  final double price;
  final int quantity;

  CartItem(
      {required this.id,
      required this.itemkey,
      required this.title,
      required this.price,
      required this.quantity});

  @override
  Widget build(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    return Dismissible(
      key: ValueKey(id),
      background: Container(
        padding: EdgeInsets.only(right: 20),
        color: Theme.of(context).errorColor,
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
        alignment: Alignment.centerRight,
        margin: EdgeInsets.all(5),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction){
        return showDialog(context: context, builder: (ctx){
          return AlertDialog(
            title: Text("Are you sure?"),
            content: Text("Do you want to remove this item from cart ?"),
            actions: [
              TextButton(onPressed: (){
                Navigator.pop(ctx, false);
              }, child: Text("Cancel")),
              TextButton(onPressed: (){
                Navigator.of(context).pop(true);
              }, child: Text("Ok"))
            ],
          );
        });
      },
      onDismissed: (direction) {
        Provider.of<Cart>(context, listen: false).removeItemFromCart(itemkey);
      },
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, ProductDetailScreen.routeName,
              arguments: id);
        },
        child: Card(
          margin: EdgeInsets.all(5),
          child: ListTile(
            leading: CircleAvatar(
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: FittedBox(child: Text("\$$price")),
              ),
            ),
            title: Text(title),
            subtitle: Text("Total \$${(quantity*price).toStringAsFixed(2)}"),
            trailing: SizedBox(
              width: 80,
              child: Row(
                children: [
                  Text("$quantity x"),
                  SizedBox(
                    width: 30,
                    child: IconButton(icon: Icon(Icons.add,), onPressed: () async {
                      try{
                        await Provider.of<Cart>(context, listen: false).incrementQuantity(id);
                      }
                      catch(error){
                        scaffold.showSnackBar(SnackBar(content: Text("Could not Increment!!")));
                      }
                    },),
                  ),
                  if(quantity > 1)SizedBox(
                    width: 30,
                    child: IconButton(icon: Icon(Icons.remove,), onPressed: () async {
                      try{
                        await Provider.of<Cart>(context, listen: false).decrementQuantity(id);
                      }
                      catch(error){
                        scaffold.showSnackBar(SnackBar(content: Text("Could not Increment!!")));
                      }
                    },),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
