import 'package:eshop/providers/auth.dart';
import 'package:eshop/providers/cart.dart';
import 'package:eshop/providers/product.dart';
import 'package:flutter/material.dart';
import '../screens/product_detail_screen.dart';
import 'package:provider/provider.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context,
        listen:
            false); //as in Grid layout builder we added changeNotifier to every product item that builder is building
    //so now we can access that data using provider.of(context)
    //Provider is of generic type, we have to provide the provider to which changeNotifier we want to listen to, so we add that in <> brackets.

    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);

    final scaffold = ScaffoldMessenger.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, ProductDetailScreen.routeName,
                arguments: product.id);
          },
          child: Hero(
            tag: product.id,
            child: FadeInImage(
              placeholder: AssetImage('assets/images/loading_image.png'),
              image: NetworkImage(product.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        footer: GridTileBar(
            backgroundColor: Colors.black54,
            title: Text(
              product.title,
              textAlign: TextAlign.center,
            ),
            //now in this widget we only want to listen to changes in isFavourite property of product repeatedly
            //and rest of property for only once, now because to we are listening to Provider on top of this widget
            //the whole widget build again, so we can separate this iconButton from this class or we can use Consumer
            //on iconButton to get continuous update in data
            leading: Consumer<Product>(
              builder: (context, product, child) {
                return IconButton(
                  icon: Icon(
                    product.isFavourite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: product.isFavourite
                        ? Colors.red
                        : Theme.of(context).accentColor,
                  ),
                  onPressed: () async {
                    scaffold.hideCurrentSnackBar();
                    try {
                      await product.toggleFavorite(
                          authData.token, authData.userId);
                      product.isFavourite
                          ? scaffold.showSnackBar(SnackBar(
                              content:
                                  Text("${product.title} added to favourite!")))
                          : scaffold.showSnackBar(SnackBar(
                              content: Text(
                                  "${product.title} removed from favourite!")));
                    } catch (error) {
                      scaffold.showSnackBar(
                          SnackBar(content: Text("Could not fav!!")));
                    }
                    //this will toggle favourite, because of that the isFavourite property of this product object
                    //will change and it will notify listeners and this ProductItem widget is a listener to Product so this widget will be build again.
                  },
                );
              },
              // child: ; consume also takes a child widget where we can define the child which we want to use in builder
              //method, and those child we define here we get them in child arguments of builder, these are generally those
              //widgets which we don't want to rebuild, so we pass here and builder can use that widget.
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.shopping_bag,
                color: Theme.of(context).accentColor,
              ),
              onPressed: () async {
                scaffold.hideCurrentSnackBar();
                try {
                  await cart.addItems(product.title, product.price);
                  scaffold.showSnackBar(SnackBar(
                    content: cart.isProductInCart(product.id)
                        ? Text("${product.title} already in cart !!")
                        : Text("${product.title} added to cart !!"),
                    duration: Duration(seconds: 1),
                  ));
                } catch (error) {
                  scaffold.showSnackBar(SnackBar(
                      content:
                          Text("Could not Add ${product.title} to cart !!")));
                }
              },
            )),
      ),
    );
  }
}
