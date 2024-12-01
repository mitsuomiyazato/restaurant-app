import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/order.dart'; 

class PaymentScreen extends StatefulWidget {
  final double total;
  final List<Map<String, dynamic>> items;
  final VoidCallback resetCart;

  const PaymentScreen({
    super.key,
    required this.total,
    required this.items,
    required this.resetCart,  
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPaymentMethod = 'Cartão';

  void _submitOrder() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário não autenticado!')),
      );
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final userData = userDoc.data();

      if (userData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dados do usuário não encontrados!')),
        );
        return;
      }
      final order = UserOrder(
        userId: user.uid,
        userName: userData['nome'],
        address: userData['endereco'],
        items: widget.items,
        total: widget.total,
        paymentMethod: _selectedPaymentMethod,
        orderDate: DateTime.now().toIso8601String(),
      );

      await FirebaseFirestore.instance.collection('orders').add(order.toMap());

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Pedido realizado com sucesso!'),
          content: const Text('Seu pedido foi salvo com sucesso.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                widget.resetCart(); 
                Navigator.pop(context);
                Navigator.pop(context); 
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar pedido: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tela de Pagamento')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total a pagar: R\$ ${widget.total.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Escolha a forma de pagamento:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Column(
              children: [
                RadioListTile<String>(
                  title: const Text('Dinheiro'),
                  value: 'Dinheiro',
                  groupValue: _selectedPaymentMethod,
                  onChanged: (value) {
                    setState(() {
                      _selectedPaymentMethod = value!;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Cartão'),
                  value: 'Cartão',
                  groupValue: _selectedPaymentMethod,
                  onChanged: (value) {
                    setState(() {
                      _selectedPaymentMethod = value!;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Pix'),
                  value: 'Pix',
                  groupValue: _selectedPaymentMethod,
                  onChanged: (value) {
                    setState(() {
                      _selectedPaymentMethod = value!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _submitOrder,
                child: const Text('Pagar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
