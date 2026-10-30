import '../../../core/log/registro_seguro.dart';
import '../domain/servicios/servicio_analitica.dart';

/// La app no tiene un servicio de analítica externo: los eventos se
/// escriben en el log, siempre enmascarados.
final class AnaliticaEnLog implements ServicioAnalitica {
  const AnaliticaEnLog();

  @override
  void registrar(String evento, {Map<String, Object?> datos = const {}}) {
    RegistroSeguro.info('ANALITICA evento=$evento datos=$datos');
  }
}
