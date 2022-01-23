import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../providers/cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchOrders() async {
    final url = Uri.parse(
        'https://flutter-shop-app-25ee3-default-rtdb.europe-west1.firebasedatabase.app/orders.json');
    final response = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    if (json.decode(response.body) == null) {
      return;
    }
    final transformedData = json.decode(response.body) as Map<String, dynamic>;
    transformedData.forEach(
      (orderId, orderItem) {
        loadedOrders.add(
          OrderItem(
            id: orderId,
            amount: orderItem['amount'],
            dateTime: DateTime.parse(orderItem['dateTime']),
            products: (orderItem['products'] as List<dynamic>)
                .map(
                  (item) => CartItem(
                    id: item['id'],
                    title: item['title'],
                    quantity: item['quantity'],
                    price: item['price'],
                  ),
                )
                .toList(),
          ),
        );
      },
    );
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.parse(
        'https://flutter-shop-app-25ee3-default-rtdb.europe-west1.firebasedatabase.app/orders.json');
    await http.post(
      url,
      body: json.encode(
        {
          'amount': total,
          'products': cartProducts
              .map((cp) => {
                    'id': cp.id,
                    'price': cp.price,
                    'quantity': cp.quantity,
                    'title': cp.title
                  })
              .toList(),
          'dateTime': DateTime.now().toIso8601String(),
        },
      ),
    );
    _orders.insert(
      0,
      OrderItem(
        id: DateTime.now().toString(),
        amount: total,
        products: cartProducts,
        dateTime: DateTime.now(),
      ),
    );
    notifyListeners();
  }
}
