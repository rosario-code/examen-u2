import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/entities/consentimiento.dart';
import '../domain/repositories/consentimiento_repository.dart';

/// Guarda la decisión en el teléfono (almacenamiento seguro) como JSON:
/// `{"version_politica":"1.0","analitica":true,"novedades":false,
/// "fecha":"2026-10-30T20:15:00.000Z"}`.
final class ConsentimientoSecureStorage implements ConsentimientoRepository {
  const ConsentimientoSecureStorage({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : _storage = storage;

  final FlutterSecureStorage _storage;
  static const _clave = 'upt_consentimiento';

  @override
  Future<void> guardar(Consentimiento consentimiento) {
    final json = jsonEncode({
      'version_politica': consentimiento.versionPolitica,
      'analitica': consentimiento.analitica,
      'novedades': consentimiento.novedades,
      'fecha': consentimiento.fecha?.toUtc().toIso8601String(),
    });
    return _storage.write(key: _clave, value: json);
  }

  @override
  Future<Consentimiento?> leer() async {
    try {
      final texto = await _storage.read(key: _clave);
      if (texto == null) return null;
      final json = jsonDecode(texto) as Map<String, dynamic>;
      final fecha = json['fecha'] as String?;
      return Consentimiento(
        versionPolitica: json['version_politica'] as String,
        analitica: json['analitica'] == true,
        novedades: json['novedades'] == true,
        fecha: fecha == null ? null : DateTime.parse(fecha).toLocal(),
      );
    } catch (_) {
      // Dato dañado o ilegible: se trata como "sin decisión" (todo apagado).
      return null;
    }
  }
}
