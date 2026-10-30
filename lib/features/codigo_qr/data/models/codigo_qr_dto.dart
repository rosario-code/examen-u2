import '../../../../core/error/failure.dart';
import '../../../ubicacion/domain/entities/ubicacion_dispositivo.dart';
import '../../domain/entities/codigo_qr.dart';

/// Lee la respuesta de `POST /codigos-qr` (campo `datos`).
final class CodigoQrDto {
  const CodigoQrDto({
    required this.codigoQr,
    required this.estado,
    required this.emitidaEn,
    required this.expiraEn,
    required this.duracionSegundos,
    required this.unSoloUso,
    required this.puntoAccesoNombre,
  });

  factory CodigoQrDto.fromJson(Map<String, Object?> json) {
    final codigo = json['codigo_qr'];
    final estado = json['estado'];
    final emitida = DateTime.tryParse('${json['emitida_en']}');
    final expira = DateTime.tryParse('${json['expira_en']}');
    final duracion = json['duracion_segundos'];
    if (codigo is! String ||
        codigo.isEmpty ||
        estado is! String ||
        emitida == null ||
        expira == null ||
        duracion is! int) {
      throw const DataFailure();
    }
    final ubicacion = json['ubicacion'];
    final punto = ubicacion is Map ? ubicacion['punto_acceso'] : null;
    final nombre = punto is Map ? punto['nombre'] : null;
    final unSoloUso = json['un_solo_uso'];
    return CodigoQrDto(
      codigoQr: codigo,
      estado: estado,
      emitidaEn: emitida,
      expiraEn: expira,
      duracionSegundos: duracion,
      unSoloUso: unSoloUso is bool ? unSoloUso : true,
      puntoAccesoNombre: nombre is String ? nombre : 'Punto de acceso',
    );
  }

  final String codigoQr;
  final String estado;
  final DateTime emitidaEn;
  final DateTime expiraEn;
  final int duracionSegundos;
  final bool unSoloUso;
  final String puntoAccesoNombre;

  CodigoQr toDomain() => CodigoQr(
    contenido: codigoQr,
    estado: estado,
    emitidoEn: emitidaEn,
    expiraEn: expiraEn,
    duracionSegundos: duracionSegundos,
    unSoloUso: unSoloUso,
    puntoAccesoNombre: puntoAccesoNombre,
  );
}

/// Convierte la entidad en el cuerpo `ubicacion` de `POST /codigos-qr`.
///
/// Envío mínimo: solo viajan los 4 campos que el servidor usa para validar
/// la zona (su esquema es `.strict()` y rechaza campos de más). La altitud,
/// la velocidad, el rumbo y `esSimulada` se quedan en el teléfono.
/// Las coordenadas viajan con 3 decimales como máximo (unos 110 m).
Map<String, Object?> ubicacionToJson(UbicacionDispositivo u) => {
  'latitud': redondearCoordenada(u.latitud),
  'longitud': redondearCoordenada(u.longitud),
  'precision_metros': u.precisionMetros,
  'obtenida_en': u.obtenidaEn.toUtc().toIso8601String(),
};

/// Deja una coordenada con 3 decimales como máximo.
double redondearCoordenada(double valor) => (valor * 1000).round() / 1000;
