import 'package:geolocator/geolocator.dart';

class LocalizacaoService {
  Future<Position> buscar() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception('Ative a localização do aparelho e tente novamente.');
    }
    var permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }
    if (permissao == LocationPermission.deniedForever) {
      throw Exception('Autorize a localização nas configurações do aparelho.');
    }
    if (permissao == LocationPermission.denied) {
      throw Exception('Permissão de localização negada.');
    }
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        timeLimit: Duration(seconds: 15),
      ),
    );
  }

  double distancia(Position origem, double latitude, double longitude) {
    return Geolocator.distanceBetween(
          origem.latitude,
          origem.longitude,
          latitude,
          longitude,
        ) /
        1000;
  }
}
