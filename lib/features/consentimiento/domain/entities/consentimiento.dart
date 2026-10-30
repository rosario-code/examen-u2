/// Decisión del estudiante sobre los usos OPCIONALES de sus datos.
///
/// Los datos necesarios para el servicio (identidad y ubicación al generar el
/// QR) no dependen de este consentimiento: sin ellos no hay control de
/// ingreso. Aquí solo están los usos que la persona puede rechazar.
final class Consentimiento {
  const Consentimiento({
    required this.analitica,
    required this.novedades,
    required this.versionPolitica,
    required this.fecha,
  });

  /// Versión de la política de privacidad que la persona aceptó o rechazó.
  static const versionVigente = '1.0';

  /// Sin decisión guardada: todo apagado (privacidad por defecto).
  static const sinDecision = Consentimiento(
    analitica: false,
    novedades: false,
    versionPolitica: versionVigente,
    fecha: null,
  );

  /// «Analítica de uso»: registrar qué pantallas y acciones se usan.
  final bool analitica;

  /// «Novedades y eventos de la UPT»: avisos informativos del campus.
  final bool novedades;

  final String versionPolitica;

  /// Momento en que se guardó la decisión; `null` si aún no decidió.
  final DateTime? fecha;

  bool get decidido => fecha != null;
}
