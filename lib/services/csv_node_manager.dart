import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';

class CsvNodeManager {
  // EXPORTAR CONFIGURACIÓN DE NODOS
  Future<String> exportNodesToCsv(List<List<dynamic>> rows) async {
    final dir = await getApplicationDocumentsDirectory();

    final filePath = '${dir.path}/iot_nodes_config.csv';

    final file = File(filePath);

    // Convertir los datos a CSV
    final csvData = const ListToCsvConverter().convert(rows);

    // Calcular SHA-256
    final bytes = utf8.encode(csvData);
    final checksum = sha256.convert(bytes).toString();

    // Agregar checksum al archivo
    final fileContent = '# CHECKSUM:$checksum\n$csvData';

    await file.writeAsString(fileContent, encoding: utf8);

    return filePath;
  }

  // VERIFICAR E IMPORTAR ARCHIVO CSV
  Future<Map<String, dynamic>> verifyAndImportCsv(String filePath) async {
    final file = File(filePath);

    // Comprobar existencia
    if (!await file.exists()) {
      return {
        'success': false,
        'message': 'El archivo no existe.',
        'data': <List<dynamic>>[],
      };
    }

    final content = await file.readAsString(encoding: utf8);

    final lines = content.split('\n');

    // Verificar cabecera
    if (lines.isEmpty || !lines.first.startsWith('# CHECKSUM:')) {
      return {
        'success': false,
        'message': 'El archivo no contiene checksum.',
        'data': <List<dynamic>>[],
      };
    }

    // Obtener checksum original
    final originalChecksum = lines.first.replaceFirst('# CHECKSUM:', '').trim();

    // Recuperar contenido CSV
    final csvBody = lines.skip(1).join('\n');

    // Recalcular SHA-256
    final recalculatedChecksum = sha256
        .convert(utf8.encode(csvBody))
        .toString();

    // Comparar checksum
    if (originalChecksum != recalculatedChecksum) {
      return {
        'success': false,
        'message': 'El archivo ha sido alterado o está corrupto.',
        'data': <List<dynamic>>[],
      };
    }

    try {
      // Convertir CSV a lista
      final parsedCsv = const CsvToListConverter().convert(csvBody);

      return {
        'success': true,
        'message': 'Configuración importada correctamente.',
        'data': parsedCsv,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'No fue posible interpretar el archivo CSV.',
        'data': <List<dynamic>>[],
      };
    }
  }
}
