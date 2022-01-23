import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/orders.dart';
import '../providers/cart.dart' show Cart;
import '../widgets/cart_item.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);
  static const routeName = '/cart';

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final cartData = Provider.of<Cart>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart Items'),
      ),
      body: Column(
        children: <Widget>[
          Card(
            margin: const EdgeInsets.all(15),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  const Spacer(),
                  Chip(
                    label: Text(
                      '\$${cartData.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  TextButton(
                      onPressed: cartData.totalAmount <= 0
                          ? null
                          : () async {
                              setState(() {
                                _isLoading = true;
                              });
                              await Provider.of<Orders>(context, listen: false)
                                  .addOrder(
                                cartData.items.values.toList(),
                                cartData.totalAmount,
                              );
                              cartData.clear();
                              setState(() {
                                _isLoading = false;
                              });
                            },
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('ORDER NOW'))
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: cartData.items.length,
              itemBuilder: (_, index) => CartItem(
                id: cartData.items.values.toList()[index].id,
                productId: cartData.items.keys.toList()[index],
                price: cartData.items.values.toList()[index].price,
                quantity: cartData.items.values.toList()[index].quantity,
                title: cartData.items.values.toList()[index].title,
              ),
            ),
          )
        ],
      ),
    );
  }
}
