import '../entities/consentimiento.dart';
import '../repositories/consentimiento_repository.dart';

/// Devuelve la decisión vigente. Si no hay ninguna, o se tomó con otra
/// versión de la política, los dos usos opcionales quedan apagados.
final class ObtenerConsentimientoUseCase {
  const ObtenerConsentimientoUseCase(this._repository);

  final ConsentimientoRepository _repository;

  Future<Consentimiento> call() async {
    final guardado = await _repository.leer();
    if (guardado == null ||
        guardado.versionPolitica != Consentimiento.versionVigente) {
      return Consentimiento.sinDecision;
    }
    return guardado;
  }
}

/// Guarda la decisión junto con la versión de la política («1.0») y la fecha.
final class GuardarConsentimientoUseCase {
  GuardarConsentimientoUseCase(this._repository, {DateTime Function()? ahora})
    : _ahora = ahora ?? DateTime.now;

  final ConsentimientoRepository _repository;
  final DateTime Function() _ahora;

  Future<Consentimiento> call({
    required bool analitica,
    required bool novedades,
  }) async {
    final consentimiento = Consentimiento(
      analitica: analitica,
      novedades: novedades,
      versionPolitica: Consentimiento.versionVigente,
      fecha: _ahora(),
    );
    await _repository.guardar(consentimiento);
    return consentimiento;
  }
}
