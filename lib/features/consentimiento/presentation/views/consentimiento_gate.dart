import 'package:flutter/material.dart';

/// Muestra la pantalla de consentimiento la primera vez que se abre la app
/// (cuando no hay una decisión guardada) y después continúa con [child].
class ConsentimientoGate extends StatefulWidget {
  const ConsentimientoGate({
    super.key,
    required this.hayDecision,
    required this.construirConsentimiento,
    required this.child,
  });

  final Future<bool> Function() hayDecision;

  /// Construye la pantalla de consentimiento; debe llamar a `alTerminar`
  /// cuando la persona guarde su decisión.
  final Widget Function(BuildContext context, VoidCallback alTerminar)
  construirConsentimiento;

  final Widget child;

  @override
  State<ConsentimientoGate> createState() => _ConsentimientoGateState();
}

class _ConsentimientoGateState extends State<ConsentimientoGate> {
  bool? _decidido;

  @override
  void initState() {
    super.initState();
    widget.hayDecision().then((valor) {
      if (mounted) setState(() => _decidido = valor);
    });
  }

  @override
  Widget build(BuildContext context) {
    return switch (_decidido) {
      null => const Scaffold(body: Center(child: CircularProgressIndicator())),
      false => widget.construirConsentimiento(
        context,
        () => setState(() => _decidido = true),
      ),
      true => widget.child,
    };
  }
}
