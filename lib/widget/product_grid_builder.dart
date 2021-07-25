import 'package:eshop/providers/product.dart';

import '../providers/products_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'product_item.dart';

class ProductGridLayoutBuilder extends StatelessWidget {

  final bool _showFavorite;
  ProductGridLayoutBuilder(this._showFavorite);

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context); //here to build grid layout we are directly getting data from provider.
    //to get data from provider we have to go to provider and ask it for which type of data we want to listen to.
    //we provide the type of data in angular brackets <>, it is syntax of generic class.
    final products = _showFavorite ? productsData.favoriteItems : productsData.items;
    return GridView.builder(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        itemCount: products.length,
        itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
          value: products[index],
           //here i want to listen to change is data of every product item that builder is creating
          //so we are adding ChangeNotifierProvider to all product object, so we can listen to change of data in each product item.
          //here we are adding Product class as data container which we are getting from products which contain list of Product object.
          child: ProductItem(),
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 15,
          crossAxisSpacing: 10,
          childAspectRatio: 6 / 5, //height to width ratio of child
        ));
  }
}

/*
  important :
    when we have large amount of widget like in Grid view and List view, and use use provider on them, when these widgets rebuild
    flutter use previous widget instead rebuilding widget to improve performance and just update the data of widget, when we are using
    builder method this might not cope up this changing data of widget, so we should use .value constructor of ChangeNotifierProvider
    and this will not give any issue. Also when we are using Previous build object like in our case we have list of Product Object
    we are just using them as data container and not instantiating them, then we should use .value Constructor.

    Now when we have a single widget we should use builder method of ChangeNotifierProvider because .value constructor my lead to
    not required render which can lead to performance issue.
 */