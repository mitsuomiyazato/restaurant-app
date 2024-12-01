import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_app/screens/cadastro_screen.dart';
import 'package:restaurant_app/screens/pratos_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;
  bool _saveCredentials = false; 
  String _errorMessage = '';

  Future<void> _login() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PratosScreen()),
      );
    } on FirebaseAuthException catch (e) {
      _errorMessage = 'Erro ao cadastrar. Tente novamente.';
      
      if (e.code == 'invalid-email') {
        setState(() {
        _errorMessage = 'E-mail inválido!';
      });
      }
      else if (e.code == 'missing-password')
      {
        setState(() {
        _errorMessage = 'Digite uma senha!';
      });
      }
      else if (e.code == 'invalid-credential')
      {
        setState(() {
        _errorMessage = 'Conta inexistente!';
      });
      }       
      else
      {
        setState(() {
        _errorMessage = 'Erro ao logar.';
      });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 80,
                  backgroundImage: AssetImage('assets/logo.png'),
                ),
                const SizedBox(height: 40),
                if (_errorMessage.isNotEmpty)
                  Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Insira seu email...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Insira sua senha...',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility 
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !_passwordVisible,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Switch(
                      value: _saveCredentials,
                      onChanged: (bool value) {
                        setState(() {
                          _saveCredentials = value;
                        });
                      },
                    ),
                    const Text(
                      'Salvar credenciais',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: _login, 
                  icon: const Icon(Icons.login),
                  label: const Text('ENTRAR'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CadastroScreen()),
                    );
                  },
                  icon: const Icon(Icons.person_add),
                  label: const Text('Criar Conta'),
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