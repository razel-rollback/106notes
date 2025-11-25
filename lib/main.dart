import 'package:flutter/material.dart';
import 'package:flutter_application5/auth_service.dart';
import 'package:flutter_application5/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application5/login_page.dart';
import 'firebase_options.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Crud  App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:  StreamBuilder(
        stream: AuthService().authStateChanges, 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            } 
            if (snapshot.hasData) {
              return const HomePage();
            } else {
              return const LoginPage();
            }
        },
    ),
  );
  }
}
