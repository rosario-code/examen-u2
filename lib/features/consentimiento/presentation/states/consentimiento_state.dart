/// Estados de la pantalla de consentimiento.
sealed class ConsentimientoState {
  const ConsentimientoState();
}

final class ConsentimientoCargando extends ConsentimientoState {
  const ConsentimientoCargando();
}

/// Interruptores visibles. [guardadoEl] es la fecha de la decisión guardada,
/// o `null` si la persona todavía no decidió.
final class ConsentimientoListo extends ConsentimientoState {
  const ConsentimientoListo({
    required this.analitica,
    required this.novedades,
    required this.versionPolitica,
    this.guardadoEl,
    this.guardando = false,
  });

  final bool analitica;
  final bool novedades;
  final String versionPolitica;
  final DateTime? guardadoEl;
  final bool guardando;

  ConsentimientoListo copyWith({
    bool? analitica,
    bool? novedades,
    bool? guardando,
  }) {
    return ConsentimientoListo(
      analitica: analitica ?? this.analitica,
      novedades: novedades ?? this.novedades,
      versionPolitica: versionPolitica,
      guardadoEl: guardadoEl,
      guardando: guardando ?? this.guardando,
    );
  }
}
