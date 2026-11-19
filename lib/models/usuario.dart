class Usuario {
  final String nome;
  final String email;
  final String? avatar;

  const Usuario(this.nome, this.email, this.avatar);

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      json['nome'] as String? ?? '',
      json['email'] as String? ?? '',
      json['avatar'] as String?,
    );
  }
}
