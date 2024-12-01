import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:restaurant_app/screens/cart_screen.dart';
import 'package:restaurant_app/screens/chat_screen.dart';
import 'package:restaurant_app/screens/edit_cadastro_screen.dart';
import 'package:restaurant_app/screens/history_screen.dart';
import 'package:restaurant_app/screens/widgets/prato_card.dart';

class PratosScreen extends StatefulWidget {
  const PratosScreen({super.key});

  @override
  State<PratosScreen> createState() => _PratosScreenState();
}

class _PratosScreenState extends State<PratosScreen> {
  String selectedCategory = 'Pizzas';
  Map<String, int> cartItems = {}; 
  Map<String, double> cartPrices = {}; 

  void resetCart() {
  setState(() {
      cartItems.clear();
      cartPrices.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.restaurant_menu),
            SizedBox(width: 8),
            Text('PRATOS'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartScreen(
                    cartItems: cartItems,
                    cartPrices: cartPrices,
                    resetCart: resetCart,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('pratos')
              .where('categoria', isEqualTo: selectedCategory)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Erro ao carregar dados.'));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('Nenhum prato encontrado.'));
            }

            final pratos = snapshot.data!.docs;

            return GridView.builder(
              itemCount: pratos.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) {
                final prato = pratos[index].data() as Map<String, dynamic>;
                final pratoName = prato['name'] ?? 'Nome indisponível';
                final double pratoPrice = (prato['price'] ?? 0.0).toDouble();
                return PratoCard(
                  name: pratoName,
                  description: prato['description'] ?? 'Descrição indisponível',
                  price: pratoPrice, 
                  imageUrl: prato['imageUrl'] ?? 'assets/default_image.png',
                  onAddToCart: () {
                    setState(() {
                      cartItems.update(
                        pratoName,
                        (value) => value + 1,
                        ifAbsent: () => 1,
                      );
                      cartPrices[pratoName] = pratoPrice;
                    });
                  },
                  onRemoveFromCart: () {
                    setState(() {
                      if (cartItems[pratoName] != null && cartItems[pratoName]! > 0) {
                        cartItems[pratoName] = cartItems[pratoName]! - 1;
                        if (cartItems[pratoName]! == 0) {
                          cartItems.remove(pratoName);
                          cartPrices.remove(pratoName);
                        }
                      }
                    });
                  },
                  quantity: cartItems[pratoName] ?? 0,
                );
              },
            );
          },
        ),
      ),
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'OPÇÕES',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          _buildDrawerItem('Pizzas'),
          _buildDrawerItem('Lanches'),
          _buildDrawerItem('Sobremesas'),
          _buildDrawerItem('Bebidas'),
          const Divider(),
          _buildDrawerItemPerfil(),
          _buildDrawerItemHistorico(),
          _buildDrawerItemSair(),
        ],
      ),
    );
  }

  ListTile _buildDrawerItem(String category) {
    return ListTile(
      title: Text(category),
      onTap: () {
        setState(() {
          selectedCategory = category;
        });
        Navigator.pop(context);
      },
    );
  }

  ListTile _buildDrawerItemSair() {
    return ListTile(
      leading: const Icon(Icons.exit_to_app),
      title: const Text('Sair'),
      onTap: () {
        Navigator.pop(context);
        Navigator.pop(context);
      },
    );
  }

  ListTile _buildDrawerItemPerfil() {
    return ListTile(
      leading: const Icon(Icons.person),
      title: const Text('Perfil'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EditCadastroScreen()),
        );
      },
    );
  }

  ListTile _buildDrawerItemHistorico() {
    return ListTile(
      leading: const Icon(Icons.history_edu_rounded),
      title: const Text('Pedidos'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HistoryScreen()),
        );
      },
    );
  }
}