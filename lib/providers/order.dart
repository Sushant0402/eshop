import 'package:eshop/exception/http_exception.dart';
import 'package:flutter/foundation.dart';
import 'package:eshop/providers/cart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderItem {
  String id;
  double amount;
  List<CartItem> products;
  DateTime time;

  OrderItem(
      {required this.id,
      required this.amount,
      required this.products,
      required this.time});
}

class Order with ChangeNotifier {

  String authToken;
  String userId;
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Order(this.authToken, this.userId, this._orders);

  Future<void> getAndSetOrder() async {
    final url = "https://e-shop-c5244-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken";

    final response = await http.get(Uri.parse(url));

    if(response.statusCode >= 400) throw HttpException("Unable to fetch data");

    var extractedData = json.decode(response.body);

    if (extractedData == null) return;

    extractedData = extractedData as Map<String, dynamic>;

    final List<OrderItem> loadedData = [];

    extractedData.forEach(
      (orderId, orderData) => loadedData.add(
        OrderItem(
          id: orderId,
          amount: orderData["Total_amount"],
          time: DateTime.parse(orderData["time"]),
          products: (orderData["products"] as List<dynamic>)
              .map(
                (item) => CartItem(
              title: item["title"],
              id: item["id"],
              price: item["price"],
              quantity: item["quantity"],
            ),
          )
              .toList(),
        ),
      )
    );

    _orders = loadedData;
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = "https://e-shop-c5244-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken";

    final timeStamp = DateTime.now();
    final response = await http.post(Uri.parse(url),
        body: json.encode({
          "Total_amount": total,
          "time": timeStamp
              .toIso8601String(), //this string can be easily converted back to DateTime Object
          "products": cartProducts
              .map((prod) => {
                    "title": prod.title,
                    "price": prod.price,
                    "quantity": prod.quantity,
                    "id": prod.id,
                  })
              .toList(),
        }));

    if (response.statusCode >= 400) throw HttpException("Could not order item");

    _orders.insert(
        0,
        OrderItem(
            id: json.decode(response.body)["name"],
            amount: total,
            products: cartProducts,
            time: timeStamp));
    notifyListeners();
  }
}
