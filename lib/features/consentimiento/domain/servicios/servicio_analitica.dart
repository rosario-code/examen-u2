/// Destino de los eventos de analítica. La app no usa un servicio externo:
/// la implementación real los escribe en el log enmascarado.
abstract interface class ServicioAnalitica {
  void registrar(String evento, {Map<String, Object?> datos = const {}});
}
