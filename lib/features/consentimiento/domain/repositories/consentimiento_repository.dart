import '../entities/consentimiento.dart';

/// Dónde se guarda la decisión. El dominio no sabe que es el teléfono.
abstract interface class ConsentimientoRepository {
  /// La decisión guardada, o `null` si nunca decidió.
  Future<Consentimiento?> leer();

  Future<void> guardar(Consentimiento consentimiento);
}
