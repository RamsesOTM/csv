import 'package:flutter/material.dart';

import 'services/csv_node_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CsvTestPage(),
    );
  }
}

class CsvTestPage extends StatefulWidget {
  const CsvTestPage({super.key});

  @override
  State<CsvTestPage> createState() => _CsvTestPageState();
}

class _CsvTestPageState extends State<CsvTestPage> {
  final CsvNodeManager manager = CsvNodeManager();

  String resultado = 'Presiona el botón para realizar la prueba.';
  bool cargando = false;

  Future<void> probarCsv() async {
    setState(() {
      cargando = true;
      resultado = 'Procesando...';
    });

    try {
      // Datos de ejemplo
      final nodes = [
        ['ID', 'Sensor', 'Pin', 'Estado'],
        [1, 'DHT22', 4, 'Activo'],
        [2, 'MQ135', 34, 'Activo'],
        [3, 'LED', 19, 'Inactivo'],
      ];

      // Exportar
      final path = await manager.exportNodesToCsv(nodes);

      // Importar y verificar
      final importResult = await manager.verifyAndImportCsv(path);

      if (!mounted) return;

      setState(() {
        resultado =
            '${importResult['message']}\n\n'
            'Archivo: $path\n\n'
            'Datos: ${importResult['data']}';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        resultado = 'Error: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestor de Nodos IoT')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: cargando ? null : probarCsv,
                child: const Text('Probar exportación e importación'),
              ),

              const SizedBox(height: 20),

              if (cargando) const CircularProgressIndicator(),

              const SizedBox(height: 20),

              SelectableText(resultado, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
