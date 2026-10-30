/// Posición del dispositivo en el momento de pedir una credencial.
final class UbicacionDispositivo {
  const UbicacionDispositivo({
    required this.latitud,
    required this.longitud,
    required this.precisionMetros,
    required this.obtenidaEn,
    this.altitudMetros,
    this.velocidadMps,
    this.rumboGrados,
    this.esSimulada = false,
  });

  final double latitud;
  final double longitud;

  /// Radio de error informado por el sistema operativo.
  final double precisionMetros;
  final DateTime obtenidaEn;

  /// Datos extra que entrega el GPS. La app los conoce, pero NO se envían al
  /// servidor porque no los usa (minimización de datos).
  final double? altitudMetros;
  final double? velocidadMps;
  final double? rumboGrados;

  /// `true` si el sistema avisa que la ubicación viene de una app de GPS
  /// falso. Solo informativo en el teléfono; no se envía.
  final bool esSimulada;

  bool get coordenadasValidas =>
      latitud >= -90 && latitud <= 90 && longitud >= -180 && longitud <= 180;

  /// `true` si se obtuvo hace como máximo [antiguedadMaxima].
  bool esReciente(DateTime ahora, Duration antiguedadMaxima) =>
      ahora.difference(obtenidaEn) <= antiguedadMaxima;
}
