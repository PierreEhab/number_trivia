import 'package:flutter/material.dart';
import 'package:number_trivia/injection_container.dart';
import 'features/number_trivia/presentation/pages/number_trivia_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Number Trivia',
      theme: ThemeData(
        primaryColor: Colors.orange.shade800,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Colors.orange.shade600,
          primary: Colors.orange.shade800,
        ),
      ),
      home: const NumberTriviaPage(),
    );
  }
}
