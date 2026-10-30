import '../servicios/servicio_analitica.dart';
import 'consentimiento_use_cases.dart';

/// Envía un evento a la analítica SOLO si el usuario aceptó «Analítica de
/// uso». Si no aceptó (o retiró su consentimiento), el evento se descarta.
final class RegistrarEventoUseCase {
  const RegistrarEventoUseCase({
    required ObtenerConsentimientoUseCase obtenerConsentimiento,
    required ServicioAnalitica analitica,
  }) : _obtenerConsentimiento = obtenerConsentimiento,
       _analitica = analitica;

  final ObtenerConsentimientoUseCase _obtenerConsentimiento;
  final ServicioAnalitica _analitica;

  /// Devuelve `true` si el evento se envió.
  Future<bool> call(
    String evento, {
    Map<String, Object?> datos = const {},
  }) async {
    final consentimiento = await _obtenerConsentimiento();
    if (!consentimiento.analitica) return false;
    _analitica.registrar(evento, datos: datos);
    return true;
  }
}
