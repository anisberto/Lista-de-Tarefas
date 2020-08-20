import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<File> _getFile() async {
  final directory = await getApplicationDocumentsDirectory();
  return File("${directory.path}/data.json");
}

Future<File> _saveData() async {}
