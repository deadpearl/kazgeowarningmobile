import 'package:flutter/material.dart';
import 'package:kazgeowarningmobile/pages/map_realtime_page.dart';
import 'package:kazgeowarningmobile/pages/profile_page.dart';
import 'pages/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
     // home: LoginPage(),
      //home: ProfilePage(),
      //home: MapRealtimePage(),
    );
  }
}