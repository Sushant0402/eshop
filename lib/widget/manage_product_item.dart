import 'package:eshop/providers/products_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../screens/edit_product_scree.dart';
import 'package:provider/provider.dart';

class ManageProductItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String id;

  ManageProductItem({required this.id,required this.title, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    return Card(
      elevation: 5,
      child: ListTile(
        leading: CircleAvatar(backgroundImage: NetworkImage(imageUrl),),
        title: Text(title),
        trailing: Container(
          width: 100,
          child: Row(
            children: [
              IconButton(onPressed: (){
                Navigator.pushNamed(context, EditProductScreen.routeName, arguments: id);
              }, icon: Icon(Icons.edit)),
              IconButton(onPressed: () async {
                try {
                  await Provider.of<Products>(context, listen: false).deleteProduct(id);
                }
                catch(error){
                  //we are using await and scaffoldMessenger need context, but when when we are using await
                  //widget tree is not aware of the context, so we have to store he context before handling error.
                  scaffold.showSnackBar(SnackBar(content: Text("Deletion Failed!!")));
                }
              }, icon: Icon(Icons.delete), color: Theme.of(context).errorColor,)
            ],
          ),
        ),
      ),
    );
  }
}
