import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../exception/http_exception.dart';
import 'dart:convert';

class CartItem {
  final String title;
  final String id;
  final double price;
  final int quantity;

  CartItem({
    required this.title,
    required this.id,
    required this.price,
    required this.quantity,
  });
}

class Cart with ChangeNotifier {

  String authToken;
  String userId;

  Cart(this.authToken, this.userId, this._items);

  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount{
    return _items.length;
  }

  double get totalAmount{
    double total = 0;

    _items.forEach((key, cartItem) {
      total += cartItem.quantity*cartItem.price;
    });

    return total;
  }


  Future<void> addItems(String title, double price) async {
    final url = "https://e-shop-c5244-default-rtdb.firebaseio.com/cart/$userId.json?auth=$authToken";

    try{

      final response = await http.post(Uri.parse(url), body:json.encode({
        "title": title,
        "price": price,
        "quantity": 1,
      }));

      final id = json.decode(response.body)["name"];
      _items.putIfAbsent(
        id, //this will wo
        () => CartItem(
          title: title,
          id: id,
          price: price,
          quantity: 1,
        ),
      );

      notifyListeners();

    }catch(error){
      throw error;
    }
  }


  Future<void> incrementQuantity(String id) async{
    final url = "https://e-shop-c5244-default-rtdb.firebaseio.com/cart/$userId/$id.json?auth=$authToken";

    try{
        final response = await http.patch(Uri.parse(url), body: json.encode({
          "quantity": _items[id]!.quantity+1,
        }));

        if(response.statusCode >= 400) throw HttpException("Could not update quantity");

        if (_items.containsKey(id)) {
          _items.update(
              id,
                  (existingCartItem) => CartItem(
                title: existingCartItem.title,
                id: existingCartItem.id,
                price: existingCartItem.price,
                quantity: existingCartItem.quantity + 1,
              ));
        }
        notifyListeners();
    }
    catch(error){
      throw error;
    }
  }


  Future<void> decrementQuantity(String id) async {
    final url = "https://e-shop-c5244-default-rtdb.firebaseio.com/cart/$userId/$id.json?auth=$authToken";

    try{
      final response = await http.patch(Uri.parse(url), body: json.encode({
        "quantity": _items[id]!.quantity - 1,
      }));

      if(response.statusCode >= 400) throw HttpException("Could not update quantity");

      if (_items.containsKey(id)) {
        _items.update(
            id,
                (existingCartItem) => CartItem(
              title: existingCartItem.title,
              id: existingCartItem.id,
              price: existingCartItem.price,
              quantity: existingCartItem.quantity - 1,
            ));
      }
      notifyListeners();
    }
    catch(error){
      throw error;
    }
  }

  Future<void> removeItemFromCart(String id) async{

    final url = "https://e-shop-c5244-default-rtdb.firebaseio.com/cart/$userId/$id.json?auth=$authToken";
    try{

       final response = await http.delete(Uri.parse(url));
      if(response.statusCode >= 400) throw HttpException("Could not delete item from cart.");
      _items.remove(id);
      notifyListeners();

    }
    catch(error){
      throw error;
    }
  }

  Future<void> clearCart() async {
    final url = "https://e-shop-c5244-default-rtdb.firebaseio.com/cart/$userId.json?auth=$authToken";
    final response = await http.delete(Uri.parse(url));
    if(response.statusCode >= 400) throw HttpException("Could not clear cart");
    _items = {};
    notifyListeners();
  }

  Future<void> getAndSetData() async{
    final url = "https://e-shop-c5244-default-rtdb.firebaseio.com/cart/$userId.json?auth=$authToken";

    try{

       final response = await http.get(Uri.parse(url));

       var extractedData = json.decode(response.body);

       if(extractedData == null) return;

       extractedData = extractedData as  Map<String, dynamic>;

       final Map<String, CartItem> loadedCart = {};

       extractedData.forEach((key, cartItem) {
         loadedCart.putIfAbsent(key, (){
           return CartItem(
             title: cartItem["title"],
             id: key,
             price: cartItem["price"],
             quantity: cartItem["quantity"]
           );
         });
       });

       _items = loadedCart;
       notifyListeners();
       print("items loaded in cart");
    }
    catch(error){
      throw error;
    }
  }

  bool isProductInCart(String id){
    final productList = _items.values.toList();

    if(productList.any((prod) => prod.id == id)){
      return true;
    }
    return false;
  }
}
