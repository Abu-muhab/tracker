import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tracker/views/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: SizedBox(
            height: 25,
            width: 25,
            child: CircularProgressIndicator(),
          ));
        }
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          routes: {
            "/": (context) => HomeView(),
            // "/login": (context) => LoginView(),
          },
          initialRoute: "/",
        );
      },
      future: Firebase.initializeApp(),
    );
  }
}
