class UserRegister {
  final String email;
  final String nome;
  final String senha;
  final String confirmacaoDeSenha;
  final String cpf;
  final String telefone;
  final String endereco;
  final String role;

  UserRegister({
    required this.email,
    required this.nome,
    required this.senha,
    required this.confirmacaoDeSenha,
    required this.cpf,
    required this.telefone,
    required this.endereco,
    required this.role
  });

  bool get isValid {
    return email.isNotEmpty &&
           nome.isNotEmpty &&
           senha.isNotEmpty &&
           confirmacaoDeSenha.isNotEmpty &&
           cpf.isNotEmpty &&
           telefone.isNotEmpty &&
           endereco.isNotEmpty &&
           senha == confirmacaoDeSenha;
  }
}
