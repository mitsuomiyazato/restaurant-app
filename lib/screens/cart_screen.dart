import 'package:flutter/material.dart';
import 'payment_screen.dart';

class CartScreen extends StatelessWidget {
  final Map<String, int> cartItems;
  final Map<String, double> cartPrices;
  final VoidCallback resetCart;

  const CartScreen({
    super.key,
    required this.cartItems,
    required this.cartPrices,
    required this.resetCart, 
  });

  @override
  Widget build(BuildContext context) {
    final total = cartItems.entries.fold<double>(
      0.0,
      (previousValue, entry) =>
          previousValue + (entry.value * (cartPrices[entry.key] ?? 0.0)),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Carrinho')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final pratoName = cartItems.keys.elementAt(index);
                  final quantity = cartItems[pratoName];
                  final price = cartPrices[pratoName];
                  return ListTile(
                    title: Text('$pratoName x$quantity'),
                    subtitle: Text('R\$ ${(price! * quantity!).toStringAsFixed(2)}'),
                  );
                },
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: R\$ ${total.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: total == 0
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentScreen(
                                total: total,
                                items: cartItems.entries
                                    .map((entry) => {
                                          'name': entry.key,
                                          'quantity': entry.value,
                                        })
                                    .toList(),
                                resetCart: resetCart,
                              ),
                            ),
                          );
                        },
                  child: const Text('Finalizar Pedido'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _calculateTotal() {
    double total = 0.0;
    cartItems.forEach((name, quantity) {
      total += (cartPrices[name] ?? 0.0) * quantity;
    });
    return total;
  }

  List<Map<String, dynamic>> _convertCartToItemList() {
    return cartItems.entries.map((entry) {
      final name = entry.key;
      final quantity = entry.value;
      final price = cartPrices[name] ?? 0.0;
      return {
        'name': name,
        'quantity': quantity,
        'price': price,
      };
    }).toList();
  }
}
