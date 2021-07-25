import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../exception/http_exception.dart';
import 'dart:convert';

class Product with ChangeNotifier{
  final String title;
  final String id;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavourite;

  Product({
    required this.title,
    required this.id,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavourite = false,
  });

  Future<void> toggleFavorite(String token, String userId) async{
    final url = "https://e-shop-c5244-default-rtdb.firebaseio.com/userFavourite/$userId/$id.json?auth=$token";
    //here favourite of single user will be store in the database according to their userId and id of product.
    isFavourite = !isFavourite;
    notifyListeners();//after toggling the favourite we have to notify listeners

    final response = await http.put(Uri.parse(url), body: json.encode(
      isFavourite,
    ));


    if(response.statusCode >= 400){
      isFavourite = !isFavourite;
      notifyListeners();
      throw HttpException("Could not favourite item");
    }
  }
}
