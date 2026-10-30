import 'package:flutter/foundation.dart';

/// Único punto de la app que escribe en el log (consola / Logcat).
///
/// Todo mensaje pasa por [enmascararDatosPersonales] antes de escribirse,
/// así ningún correo, celular ni DNI queda legible en el log.
abstract final class RegistroSeguro {
  /// Destino real del log. Se puede reemplazar en las pruebas.
  static void Function(String mensaje) escritor = _escribirEnConsola;

  static void info(String mensaje) => _escribir('INFO', mensaje);

  static void error(String mensaje) => _escribir('ERROR', mensaje);

  static void _escribir(String nivel, String mensaje) {
    escritor('[UPT][$nivel] ${enmascararDatosPersonales(mensaje)}');
  }

  // La única llamada directa a la consola de toda la app.
  static void _escribirEnConsola(String linea) => debugPrint(linea);
}

final _correo = RegExp(r'([A-Za-z0-9._%+-])[A-Za-z0-9._%+-]*@([A-Za-z0-9.-]+)');
final _celular = RegExp(r'(?<!\d)9\d{6}(\d{2})(?!\d)');
final _dni = RegExp(r'(?<!\d)\d{6}(\d{2})(?!\d)');

/// Enmascara correos, celulares peruanos (9 dígitos que empiezan con 9) y
/// DNI (8 dígitos). Deja solo lo mínimo para reconocer el formato:
/// `ana@correo.com` → `a***@correo.com`, `987654321` → `9******21`,
/// `45678912` → `******12`.
String enmascararDatosPersonales(String texto) {
  return texto
      .replaceAllMapped(_correo, (m) => '${m[1]}***@${m[2]}')
      .replaceAllMapped(_celular, (m) => '9******${m[1]}')
      .replaceAllMapped(_dni, (m) => '******${m[1]}');
}
