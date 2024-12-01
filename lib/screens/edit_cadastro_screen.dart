import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class EditCadastroScreen extends StatefulWidget {
  const EditCadastroScreen({super.key});

  @override
  _EditCadastroScreenState createState() => _EditCadastroScreenState();
}

class _EditCadastroScreenState extends State<EditCadastroScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _userTimeController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _enderecoController = TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          _nomeController.text = userDoc['nome'] ?? '';
          dynamic createdAt = userDoc['createdAt'];
          if (createdAt is Timestamp) {
            _userTimeController.text =
                DateFormat('dd/MM/yyyy HH:mm').format(createdAt.toDate());
          } else {
            _userTimeController.text = 'Data não disponível';
          }

          _cpfController.text = userDoc['cpf'] ?? '';
          _phoneController.text = userDoc['telefone'] ?? '';
          _enderecoController.text = userDoc['endereco'] ?? '';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar os dados: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  } else {
    setState(() {
      _isLoading = false;
    });
  }
}

  Future<void> _updateUserData() async {
    if (_formKey.currentState?.validate() == true) {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        try {
          await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({
            'nome': _nomeController.text,
            'createdAt': _userTimeController.text,
            'cpf': _cpfController.text,
            'telefone': _phoneController.text,
            'endereco': _enderecoController.text,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dados atualizados com sucesso!')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao atualizar os dados.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EDITAR SEUS DADOS'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nomeController,
                        decoration: const InputDecoration(
                          labelText: 'Atualize seu nome...',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira seu nome';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _userTimeController,
                        decoration: const InputDecoration(
                          labelText: 'Data de cadastro',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _cpfController,
                        decoration: const InputDecoration(
                          labelText: 'Atualize seu CPF...',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira seu CPF';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Atualize seu telefone...',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira seu telefone';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                        TextFormField(
                        controller: _enderecoController,
                        decoration: const InputDecoration(
                          labelText: 'Atualize seu endereco...',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.house),
                        ),
                        keyboardType: TextInputType.streetAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira seu endereco';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      ElevatedButton.icon(
                        onPressed: _updateUserData,
                        icon: const Icon(Icons.save),
                        label: const Text('SALVAR ALTERAÇÕES'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
