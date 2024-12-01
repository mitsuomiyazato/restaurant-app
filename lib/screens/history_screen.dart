import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:restaurant_app/models/order.dart';
import 'package:intl/intl.dart'; 

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  Future<String?> _getUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  String formatDate(String dateString) {
    final DateTime dateTime = DateTime.parse(dateString);
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm'); 
    return formatter.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Pedidos'),
      ),
      body: FutureBuilder<String?>(
        future: _getUserId(), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar dados.'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Usuário não está logado.'));
          }

          final userId = snapshot.data!; 

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('orders')
                .where('userId', isEqualTo: userId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(child: Text('Erro ao carregar pedidos.'));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('Nenhum pedido encontrado.'));
              }

              final orders = snapshot.data!.docs;
              return ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final orderData = orders[index].data() as Map<String, dynamic>;
                  final order = UserOrder(
                    userId: orderData['userId'],
                    userName: orderData['userName'],
                    address: orderData['address'],
                    items: List<Map<String, dynamic>>.from(orderData['items']),
                    total: orderData['total'] ?? 0.0,
                    paymentMethod: orderData['paymentMethod'],
                    orderDate: orderData['orderDate'],
                  );

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text('Endereço: ${order.address}'),
                          const SizedBox(height: 8),
                          Text('Data do Pedido: ${formatDate(order.orderDate)}'),
                          const SizedBox(height: 8),
                          Text('Método de Pagamento: ${order.paymentMethod}'),
                          const SizedBox(height: 8),
                          Text('Total: R\$ ${(order.total).toStringAsFixed(2)}'),
                          const SizedBox(height: 12),
                          const Text(
                            'Itens:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Column(
                            children: order.items.map((item) {
                              return ListTile(
                                title: Text('- ${item['name'] ?? 'Item sem nome'};'),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
