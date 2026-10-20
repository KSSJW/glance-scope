import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glance_scope/page/connection_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );

  runApp(const GlanceSscope());
}

class GlanceSscope extends StatelessWidget {
  const GlanceSscope({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Glance Sscope',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: Colors.teal,
        ),
        useMaterial3: true,
      ),
      home: const ConnectionPage(),
    );
  }
}
