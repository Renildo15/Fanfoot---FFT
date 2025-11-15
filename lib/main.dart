import 'package:fanfoot/db/database_helper.dart';
import 'package:fanfoot/features/editor/editor_page.dart';
import 'package:fanfoot/features/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  final db = await DatabaseHelper.instance.database;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(title: "Fanfoot"),
        '/editor': (context) => const EditorPage(),
      },
    );
  }
}
