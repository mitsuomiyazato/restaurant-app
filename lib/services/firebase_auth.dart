import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;  // Use alias para Firebase Auth
import '../models/user.dart';

class FirebaseAuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  Future<UserRegister?> createUser(UserRegister user) async {
  try {
    firebase_auth.UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: user.email,
      password: user.senha,
    );
    return UserRegister(
      email: user.email,
      nome: user.nome,
      senha: user.senha,
      confirmacaoDeSenha: user.confirmacaoDeSenha,
      cpf: user.cpf,
      telefone: user.telefone,
      endereco: user.endereco,
      role: user.role
    );
  } on firebase_auth.FirebaseAuthException catch (e) {
    String errorMessage = 'Erro desconhecido ao criar o usuário.';
    if (e.code == 'email-already-in-use') {
      errorMessage = 'Este e-mail já está em uso.';
    }
    print('Erro ao criar usuário: $e');
    return Future.error(errorMessage);
  }
}

  Future<UserRegister?> signIn(String email, String senha) async {
    try {
      firebase_auth.UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );

      return UserRegister(
        email: email,
        senha: senha,
        nome: '',
        confirmacaoDeSenha: '', 
        cpf: '', 
        telefone: '', 
        endereco: '',
        role: ''
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('Erro no login: $e');
      return null;
    }
  }
}
