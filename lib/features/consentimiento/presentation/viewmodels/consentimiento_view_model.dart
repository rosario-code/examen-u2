import 'dart:async';

import '../../domain/usecases/consentimiento_use_cases.dart';
import '../states/consentimiento_state.dart';

/// Acciones de la pantalla de consentimiento: cargar la decisión guardada,
/// mover los interruptores y guardar (aceptar todo, rechazar todo o la
/// selección).
final class ConsentimientoViewModel {
  ConsentimientoViewModel({
    required ObtenerConsentimientoUseCase obtener,
    required GuardarConsentimientoUseCase guardar,
  }) : _obtener = obtener,
       _guardar = guardar;

  final ObtenerConsentimientoUseCase _obtener;
  final GuardarConsentimientoUseCase _guardar;
  final StreamController<ConsentimientoState> _states =
      StreamController<ConsentimientoState>.broadcast();

  ConsentimientoState currentState = const ConsentimientoCargando();
  Stream<ConsentimientoState> get states => _states.stream;

  Future<void> cargar() async {
    final c = await _obtener();
    _emit(
      ConsentimientoListo(
        analitica: c.analitica,
        novedades: c.novedades,
        versionPolitica: c.versionPolitica,
        guardadoEl: c.fecha,
      ),
    );
  }

  void cambiarAnalitica(bool valor) => _actualizar(analitica: valor);

  void cambiarNovedades(bool valor) => _actualizar(novedades: valor);

  /// Guarda lo que marcan los interruptores.
  Future<void> guardarSeleccion() async {
    final estado = currentState;
    if (estado is! ConsentimientoListo) return;
    await _guardarDecision(
      analitica: estado.analitica,
      novedades: estado.novedades,
    );
  }

  Future<void> aceptarTodo() =>
      _guardarDecision(analitica: true, novedades: true);

  Future<void> rechazarTodo() =>
      _guardarDecision(analitica: false, novedades: false);

  Future<void> _guardarDecision({
    required bool analitica,
    required bool novedades,
  }) async {
    final estado = currentState;
    if (estado is ConsentimientoListo) {
      _emit(estado.copyWith(guardando: true));
    }
    final c = await _guardar(analitica: analitica, novedades: novedades);
    _emit(
      ConsentimientoListo(
        analitica: c.analitica,
        novedades: c.novedades,
        versionPolitica: c.versionPolitica,
        guardadoEl: c.fecha,
      ),
    );
  }

  void _actualizar({bool? analitica, bool? novedades}) {
    final estado = currentState;
    if (estado is! ConsentimientoListo || estado.guardando) return;
    _emit(estado.copyWith(analitica: analitica, novedades: novedades));
  }

  void _emit(ConsentimientoState state) {
    currentState = state;
    if (!_states.isClosed) _states.add(state);
  }

  Future<void> dispose() => _states.close();
}
