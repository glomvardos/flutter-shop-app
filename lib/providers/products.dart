import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];
  final String authToken;
  // var _showFavoritesOnly = false;
  Products(this.authToken, this._items);
  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((product) => product.isFavorite).toList();
  }

  Future<void> fetchProducts() async {
    final url = Uri.parse(
        'https://flutter-shop-app-25ee3-default-rtdb.europe-west1.firebasedatabase.app/products.json?auth=$authToken');
    final response = await http.get(url);
    if (json.decode(response.body) == null) {
      return;
    }
    final transformedData = json.decode(response.body) as Map<String, dynamic>;
    final List<Product> loadedProducts = [];
    transformedData.forEach(
      (prodId, prodData) {
        loadedProducts.add(
          Product(
            id: prodId,
            title: prodData['title'],
            price: prodData['price'],
            description: prodData['description'],
            imageUrl: prodData['imageUrl'],
            isFavorite: prodData['isFavorite'],
          ),
        );
      },
    );
    _items = loadedProducts;
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse(
        'https://flutter-shop-app-25ee3-default-rtdb.europe-west1.firebasedatabase.app/products.json?auth=$authToken');

    try {
      await http.post(
        url,
        body: json.encode(
          {
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
            'isFavorite': product.isFavorite,
          },
        ),
      );

      // _items.insert(0,newProduct); Insert at the start of the list.
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Product findById(String productId) {
    return _items.firstWhere((pdItem) => pdItem.id == productId);
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url = Uri.parse(
          'https://flutter-shop-app-25ee3-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json?auth=$authToken');
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'price': newProduct.price,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {}
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(
        'https://flutter-shop-app-25ee3-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json?auth=$authToken');
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeWhere((prod) => prod.id == id);
    await http.delete(url).then(
      (res) {
        if (res.statusCode >= 400) {
          throw Exception('Something went wriong');
        }
        existingProduct = null as Product;
      },
    ).catchError(
      (_) {
        _items.insert(existingProductIndex, existingProduct);
        notifyListeners();
      },
    );

    notifyListeners();
  }

  // void showFavoritesOnlyHandler() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAllHandler() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }
}
