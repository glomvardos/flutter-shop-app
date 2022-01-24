import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/widgets/order_item.dart';
import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({Key? key}) : super(key: key);
  static const routeName = '/orders';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Orders'),
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder(
        future: Provider.of<Orders>(context, listen: false).fetchOrders(),
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            return Consumer<Orders>(
              builder: (ctx, ordersData, child) => ListView.builder(
                itemCount: ordersData.orders.length,
                itemBuilder: (_, index) => OrderItem(
                  order: ordersData.orders[index],
                ),
              ),
            );
          } else if (snapshot.data == null) {
            return const Center(
              child: Text("You don't have any orders yet"),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
