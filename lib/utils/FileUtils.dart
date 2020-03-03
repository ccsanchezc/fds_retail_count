import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class FileUtils {
  static Future<String> get getFilePath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get getFile async {
    final path = await getFilePath;
   // final path = await FilePicker.getFilePath(type: FileType.ANY);
    return File('$path/info.txt');
  }

  static Future<File> saveToFile(String data) async {
    final file = await getFile;
    print(file.path);
    return file.writeAsString(data);
  }

  static Future<String> readFromFile() async {
    try {
      //final file = await getFile;
      final file = await FilePicker.getFile(type: FileType.CUSTOM, fileExtension: 'txt');
      String fileContents = await file.readAsString();

    //  print(fileContents);
      return fileContents;
    } catch (e) {
      return "";
    }
  }
}