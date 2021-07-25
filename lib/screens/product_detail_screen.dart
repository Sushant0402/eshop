import 'package:eshop/providers/products_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductDetailScreen extends StatelessWidget {

  static const routeName="/productDetailScreen";

  @override
  Widget build(BuildContext context) {
    final String productId = ModalRoute.of(context)!.settings.arguments as String;
    final product = Provider.of<Products>(context, listen:false).getItemById(productId);
    return Scaffold(
      appBar: AppBar(
       title: Text(product.title),
      ),
      body:SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              height: 400,
              width: double.infinity,
              child: Hero(tag:product.id,child: Image.network(product.imageUrl, fit: BoxFit.contain,)),
            ),
            SizedBox(height: 20, child: Divider(),),
            Text(product.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text("\$${product.price.toString()}",style: TextStyle(fontSize: 30, fontWeight: FontWeight.w100, color: Colors.grey)),
            Text(product.description, style: TextStyle(fontSize: 15, color: Colors.black87),softWrap: true, textAlign: TextAlign.center,)
          ],
        ),
      ),
    );
  }
}
