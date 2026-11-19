class Lugar {
  final String nome;
  final String descricao;
  final double? latitude;
  final double? longitude;

  const Lugar(this.nome, this.descricao, this.latitude, this.longitude);

  factory Lugar.fromJson(Map<String, dynamic> json) {
    return Lugar(
      json['nome'] as String,
      json['descricao'] as String? ?? '',
      double.tryParse('${json['latitude']}'),
      double.tryParse('${json['longitude']}'),
    );
  }
}
