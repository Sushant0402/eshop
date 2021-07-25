import 'package:eshop/providers/products_provider.dart';
import 'package:eshop/screens/edit_product_scree.dart';
import 'package:eshop/widget/drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widget/manage_product_item.dart';

class ManageProductScreen extends StatelessWidget {
  static const routeName = "ManageProduct";

  Future<void> _refreshPageAndReloadProduct(BuildContext context) async{
    await Provider.of<Products>(context, listen: false).getAndSetProduct(filterByUser: true); //here we are setting getAndSetProduct to true so we can filter product on basis of which
    //user has added/created it.
  }
  
  @override
  Widget build(BuildContext context) {
    // final product = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Products"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushNamed(context, EditProductScreen.routeName, arguments: "");
              },
              icon: Icon(Icons.add)),
        ],
      ),
      drawer: MyDrawer(),
      body: FutureBuilder(
        future: _refreshPageAndReloadProduct(context), //here future builder will help us to do something on basis of this future action to complete
        builder:(context, snapshot) => snapshot.connectionState == ConnectionState.waiting ?Center(child: CircularProgressIndicator(),) :RefreshIndicator( //in snapshot we get what is current status of future
          onRefresh: () => _refreshPageAndReloadProduct(context),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Consumer<Products>( //consumer builder provide context, an object that we are listening to, and a child which can be use to avoid rebuilding unnecessary widget
              builder:(context, product, _) => product.items.length == 0 ? Center(child : Text("You haven't added any product 😃")) : ListView.builder(
                itemCount: product.items.length,
                itemBuilder: (context, index) {
                  return ManageProductItem(
                    id: product.items[index].id,
                    title: product.items[index].title,
                    imageUrl: product.items[index].imageUrl,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
