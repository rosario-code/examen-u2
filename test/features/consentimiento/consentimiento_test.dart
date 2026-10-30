import 'package:aplicacion_estudiante/features/consentimiento/domain/entities/consentimiento.dart';
import 'package:aplicacion_estudiante/features/consentimiento/domain/repositories/consentimiento_repository.dart';
import 'package:aplicacion_estudiante/features/consentimiento/domain/servicios/servicio_analitica.dart';
import 'package:aplicacion_estudiante/features/consentimiento/domain/usecases/consentimiento_use_cases.dart';
import 'package:aplicacion_estudiante/features/consentimiento/domain/usecases/registrar_evento_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

/// Almacenamiento simulado: guarda la decisión en memoria, sin teléfono.
final class AlmacenamientoSimulado implements ConsentimientoRepository {
  Consentimiento? guardado;

  @override
  Future<Consentimiento?> leer() async => guardado;

  @override
  Future<void> guardar(Consentimiento consentimiento) async {
    guardado = consentimiento;
  }
}

/// Analítica simulada: solo anota los eventos que le llegan.
final class AnaliticaSimulada implements ServicioAnalitica {
  final eventos = <String>[];

  @override
  void registrar(String evento, {Map<String, Object?> datos = const {}}) {
    eventos.add(evento);
  }
}

void main() {
  late AlmacenamientoSimulado almacenamiento;
  late AnaliticaSimulada analitica;
  late ObtenerConsentimientoUseCase obtener;
  late GuardarConsentimientoUseCase guardar;
  late RegistrarEventoUseCase registrarEvento;

  setUp(() {
    almacenamiento = AlmacenamientoSimulado();
    analitica = AnaliticaSimulada();
    obtener = ObtenerConsentimientoUseCase(almacenamiento);
    guardar = GuardarConsentimientoUseCase(
      almacenamiento,
      ahora: () => DateTime(2026, 10, 30, 16, 40),
    );
    registrarEvento = RegistrarEventoUseCase(
      obtenerConsentimiento: obtener,
      analitica: analitica,
    );
  });

  group('Consentimiento (examen ítem 4)', () {
    test(
      '(a) sin decisión guardada, los dos usos opcionales están apagados',
      () async {
        final consentimiento = await obtener();

        expect(almacenamiento.guardado, isNull);
        expect(consentimiento.analitica, isFalse);
        expect(consentimiento.novedades, isFalse);
        expect(consentimiento.decidido, isFalse);
      },
    );

    test(
      '(b) al aceptar solo «Analítica de uso», queda encendida solo esa y se '
      'guarda la versión 1.0',
      () async {
        await guardar(analitica: true, novedades: false);

        final guardado = almacenamiento.guardado!;
        expect(guardado.analitica, isTrue);
        expect(guardado.novedades, isFalse);
        expect(guardado.versionPolitica, '1.0');
        expect(guardado.fecha, DateTime(2026, 10, 30, 16, 40));
      },
    );

    test(
      '(c) tras retirar «Analítica de uso», un evento de la app no llega a la '
      'analítica',
      () async {
        await guardar(analitica: true, novedades: false);
        await registrarEvento('qr_generado');
        expect(analitica.eventos, ['qr_generado']);

        // El usuario retira su consentimiento.
        await guardar(analitica: false, novedades: false);
        final enviado = await registrarEvento('historial_abierto');

        expect(enviado, isFalse);
        expect(analitica.eventos, ['qr_generado']);
      },
    );
  });
}
