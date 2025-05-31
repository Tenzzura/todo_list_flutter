import 'package:flutter/material.dart';
import 'package:to_do_list/pages/home_page.dart';
import 'package:to_do_list/services/database_service.dart';

void main() async {
  // inisialisasi database sebelum aplikasi berjalan
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDatabase();
  runApp(const MyApp());
}

// inisasialisasi database
Future<void> initializeDatabase() async {
  await DatabaseService.inisialisasi();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: HomePage(),
    );
  }
}