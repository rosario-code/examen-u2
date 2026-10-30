import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';
import '../states/consentimiento_state.dart';
import '../viewmodels/consentimiento_view_model.dart';

/// Pantalla «Privacidad»: el estudiante acepta o rechaza por separado cada
/// uso opcional de sus datos. Se muestra la primera vez que se abre la app y
/// se vuelve a abrir desde el perfil con la decisión guardada.
class ConsentimientoPage extends StatefulWidget {
  const ConsentimientoPage({
    super.key,
    required this.viewModel,
    required this.onGuardado,
    this.primeraVez = false,
    this.onVerAvisoPrivacidad,
  });

  final ConsentimientoViewModel viewModel;

  /// Se llama después de guardar la decisión.
  final VoidCallback onGuardado;

  /// La primera vez no hay botón "atrás": hay que decidir para continuar.
  final bool primeraVez;

  final VoidCallback? onVerAvisoPrivacidad;

  @override
  State<ConsentimientoPage> createState() => _ConsentimientoPageState();
}

class _ConsentimientoPageState extends State<ConsentimientoPage> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(widget.viewModel.cargar);
  }

  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  Future<void> _guardarCon(Future<void> Function() accion) async {
    await accion();
    if (mounted) widget.onGuardado();
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacidad'),
        automaticallyImplyLeading: !widget.primeraVez,
      ),
      body: SafeArea(
        child: StreamBuilder<ConsentimientoState>(
          stream: widget.viewModel.states,
          initialData: widget.viewModel.currentState,
          builder: (context, snapshot) {
            final estado = snapshot.data;
            if (estado is! ConsentimientoListo) {
              return const Center(child: CircularProgressIndicator());
            }
            final vm = widget.viewModel;
            final bloqueado = estado.guardando;
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text('Tus datos, tu decisión', style: textos.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  'Para controlar tu ingreso usamos solo tu identidad y, al '
                  'generar el QR, tu ubicación. Lo de abajo es opcional: '
                  'puedes aceptar o rechazar cada uso por separado y '
                  'cambiarlo cuando quieras.',
                  style: textos.bodyMedium?.copyWith(
                    color: AppColors.textoSecundario,
                  ),
                ),
                const SizedBox(height: 20),
                _UsoOpcional(
                  icono: Icons.insights_outlined,
                  titulo: 'Analítica de uso',
                  descripcion:
                      'Saber qué pantallas usas para mejorar la app. '
                      'Sin tu nombre, correo ni código.',
                  valor: estado.analitica,
                  onChanged: bloqueado ? null : vm.cambiarAnalitica,
                ),
                const SizedBox(height: 12),
                _UsoOpcional(
                  icono: Icons.campaign_outlined,
                  titulo: 'Novedades y eventos de la UPT',
                  descripcion:
                      'Avisos informativos del campus. Los avisos de '
                      'seguridad de tu cuenta llegan siempre.',
                  valor: estado.novedades,
                  onChanged: bloqueado ? null : vm.cambiarNovedades,
                ),
                const SizedBox(height: 16),
                Text(
                  estado.guardadoEl == null
                      ? 'Política de privacidad v${estado.versionPolitica} · '
                            'aún no has decidido'
                      : 'Política de privacidad v${estado.versionPolitica} · '
                            'decisión guardada el '
                            '${_fecha(estado.guardadoEl!)}',
                  style: textos.bodySmall?.copyWith(
                    color: AppColors.textoSecundario,
                  ),
                ),
                if (widget.onVerAvisoPrivacidad != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: widget.onVerAvisoPrivacidad,
                      child: const Text('Leer el aviso de privacidad'),
                    ),
                  ),
                const SizedBox(height: 16),
                // Aceptar y rechazar: mismo tipo de botón, mismo tamaño y
                // mismo color. Ninguno se destaca sobre el otro.
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: bloqueado
                            ? null
                            : () => _guardarCon(vm.rechazarTodo),
                        child: const Text('Rechazar todo'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: bloqueado
                            ? null
                            : () => _guardarCon(vm.aceptarTodo),
                        child: const Text('Aceptar todo'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: bloqueado
                      ? null
                      : () => _guardarCon(vm.guardarSeleccion),
                  child: const Text('Guardar mi selección'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  static String _fecha(DateTime f) {
    String dos(int n) => n.toString().padLeft(2, '0');
    return '${dos(f.day)}/${dos(f.month)}/${f.year} '
        '${dos(f.hour)}:${dos(f.minute)}';
  }
}

class _UsoOpcional extends StatelessWidget {
  const _UsoOpcional({
    required this.icono,
    required this.titulo,
    required this.descripcion,
    required this.valor,
    required this.onChanged,
  });

  final IconData icono;
  final String titulo;
  final String descripcion;
  final bool valor;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SwitchListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        secondary: Icon(icono, color: AppColors.azulUpt),
        title: Text(titulo),
        subtitle: Text(descripcion),
        value: valor,
        onChanged: onChanged,
      ),
    );
  }
}
