

import 'package:flutter/foundation.dart';
import 'package:eshop/providers/product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../exception/http_exception.dart';

class Products with ChangeNotifier {

  String authToken;
  String userId;

  Products(this.authToken,this.userId, this._items);

  List<Product> _items = [
    Product(
      id: 'p1',
      title: 'Red Shirt',
      description: 'A red shirt - it is pretty red!',
      price: 29.99,
      imageUrl:
          'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    ),
    Product(
      id: 'p2',
      title: 'Trousers',
      description: 'A nice pair of trousers.',
      price: 59.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    ),
    Product(
      id: 'p3',
      title: 'Yellow Scarf',
      description: 'Warm and cozy - exactly what you need for the winter.',
      price: 19.99,
      imageUrl:
          'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    ),
    Product(
      id: 'p4',
      title: 'A Pan',
      description: 'Prepare any meal you want.',
      price: 49.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    ),
  ];

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((product) => product.isFavourite == true).toList();
  }

  Future<void> getAndSetProduct({bool filterByUser = false}) async {

    final filterString = filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : ''; //this is filter string, when we go to manage product screen
    //so there only those product will be available that is added by user not other products, so we have to filter product
    //in url we add some query command that is understood by firebase to filter product, here we are filtering product on basis of creator Id
    //when we are main page then we do not filter product.

    var url =
        'https://e-shop-c5244-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString';

    try {
      final response = await http.get(Uri.parse(url));

      var extractedData = json.decode(response.body);

      if(extractedData == null) return;

      url = "https://e-shop-c5244-default-rtdb.firebaseio.com/userFavourite/$userId.json?auth=$authToken";

      extractedData = extractedData as  Map<String, dynamic>;

      final favouriteResponse = await http.get(Uri.parse(url));

      var favouriteData = json.decode(favouriteResponse.body);


      final List<Product> loadedProducts = [];

      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          title: prodData["title"],
          id: prodId,
          description: prodData["description"],
          price: prodData["price"],
          imageUrl: prodData["imageURL"],
          isFavourite:favouriteData == null ? false : favouriteData[prodId] ?? false,
        ));
      });

      _items = loadedProducts;
      notifyListeners();

    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> addProduct(Product product) async {
    final url =
        "https://e-shop-c5244-default-rtdb.firebaseio.com/products.json?auth=$authToken";

    try {
      //await ensures that flow of program will wait here to complete this and then move to next.
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            "title": product.title,
            "description": product.description,
            "imageURL": product.imageUrl,
            "price": product.price,
            "creatorId":userId,
          }));

      Product newProduct = Product(
        title: product.title,
        imageUrl: product.imageUrl,
        price: product.price,
        description: product.description,
        id: json.decode(response.body)["name"], //when we save our data on server the server will response us with
        //the id of the data stored on firebase.
      );

      _items.add(newProduct);
      notifyListeners(); //this is important to notify all listeners that are listening to this data

    } catch (error) {
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product product) async{
    final productIndex = _items.indexWhere((prod) => prod.id == id); //this will return index where this condition match.

    if(productIndex < 0) return;

    final url = "https://e-shop-c5244-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken";
    //when we are patching the data, if our data consist on extra data point like in our case favourite, that we are not providing in patch,
    //then firebase not will not remove the not given data, but not given data will remain in their previous state.
    await http.patch(Uri.parse(url), body: json.encode({
      "title": product.title,
      "price": product.price,
      "imageURL": product.imageUrl,
      "description": product.description,
    }));
    _items[productIndex] = product;
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    final index = _items.indexWhere((element) => element.id == id);
    final product = _items[index];
    _items.removeAt(index);//initially we are removing item from our memory
    notifyListeners();

    final url = "https://e-shop-c5244-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken";

    final response = await http.delete(Uri.parse(url)); //then we are trying to delete the item from the server
    if(response.statusCode >= 400){
      //and for some reason if we are not able to delete then we insert the product back into the list.
      _items.insert(index, product);
      notifyListeners();
      throw HttpException("Could not delete Product.");
    }

  }

  Product getItemById(String id) {
    return _items.firstWhere((product) => product.id == id);
  }
}
