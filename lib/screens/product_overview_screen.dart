import 'package:eshop/providers/cart.dart';
import 'package:eshop/providers/products_provider.dart';
import 'package:eshop/screens/cartscreen.dart';
import 'package:eshop/widget/badge.dart';
import 'package:flutter/material.dart';
import 'package:eshop/widget/product_grid_builder.dart';
import 'package:provider/provider.dart';
import '../widget/drawer.dart';

enum FilterOption {
  Favorite,
  All,
}

class ProductOverviewScreen extends StatefulWidget {
  static const routeName = "/productOverviewScreen";

  @override
  _ProductOverviewScreenState createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  bool _showFavorite = false;
  bool _isLoading = false;
  bool _isInit = false;


  @override
  void didChangeDependencies() {
    if(!_isInit){
      setState(() {
        _isLoading = true;
      });
      print("fetching data");
      Provider.of<Cart>(context).getAndSetData();
      Provider.of<Products>(context).getAndSetProduct().then((value) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = true;
    super.didChangeDependencies();
  }


  @override
  Widget build(BuildContext context) {
    return Center(
        child: Scaffold(
        appBar: AppBar(
        title: Text("Shop"),
        actions: [
          PopupMenuButton(
              onSelected: (FilterOption selectedFilter) {
                setState(() {
                  if (selectedFilter == FilterOption.Favorite) {
                    _showFavorite = true;
                  } else {
                    _showFavorite = false;
                  }
                });
              },
              icon: Icon(Icons.filter_list),
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    child: Text("Show Favorite"),
                    value: FilterOption.Favorite,
                  ),
                  PopupMenuItem(
                    child: Text("Show All"),
                    value: FilterOption.All,
                  ),
                ];
              }),
          Consumer<Cart>(
            builder: (context, cart, child) {
              //here we are using a Badge widget to show user a badge on cart icon in appBar - that how many item is selected.
              return Badge(
                child: child as Widget,
                value: cart.itemCount.toString(),
                color: Theme.of(context).accentColor,
              );
            },
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          )
        ],
      ),
      drawer: MyDrawer(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ProductGridLayoutBuilder(_showFavorite),
    ));
  }
}
