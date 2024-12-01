import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:restaurant_app/screens/home_screen.dart';
import 'screens/welcome_screen.dart';  

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: FirebaseOptions(
    apiKey: "AIzaSyBA4FyZGYt2WoF_Wux_F48sFhQZ6YZM3xw",
    authDomain: "trabalho03-32770.firebaseapp.com",
    databaseURL: "https://trabalho03-32770-default-rtdb.firebaseio.com/",
    projectId: "trabalho03-32770",
    storageBucket: "trabalho03-32770.firebasestorage.app",
    messagingSenderId: "1010732791381",
    appId: "1:1010732791381:web:333c50cf1905388b5746dc"
    ),    
  );

  runApp(const RestaurantApp());
}

class RestaurantApp extends StatelessWidget {
  const RestaurantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurant App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: {
        '/': (context) => WelcomeScreen(),
        '/home': (context) => HomeScreen()
      }
    );
  }
}
