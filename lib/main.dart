import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kazgeowarningmobile/pages/main_page.dart';
import 'package:kazgeowarningmobile/pages/map_realtime_page.dart';
import 'package:kazgeowarningmobile/pages/notifications_page.dart';
import 'package:kazgeowarningmobile/pages/profile_page.dart';
import 'package:kazgeowarningmobile/pages/signup.dart';
import 'package:overlay_support/overlay_support.dart';
import 'pages/login_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // Инициализируем Firebase до запуска приложения
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();
      String? deviceToken = await messaging.getToken();
      print("onMessage: ${deviceToken}");
  runApp(MyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Background message handling triggered");
  print("Handling a background message: ${message}");
  print("Handling a background message: ${message}");
}

void checkToken() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  String? savedToken = await getSavedDeviceToken();
  if (savedToken == null) {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();
    try {
      String? deviceToken = await messaging.getToken();
      saveToken(deviceToken!);
    } catch (e) {
      print('Ошибка при получении deviceToken: $e');
    }
  }
}

Future<String?> getSavedDeviceToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var deviceToken = prefs.getString('deviceToken');
  print('Device Token: $deviceToken');
  return deviceToken;
}

void saveToken(String deviceToken) async {
SharedPreferences prefs = await SharedPreferences.getInstance();
prefs.setString('deviceToken', deviceToken);
  /*var deviceTokenDTO = {
    'deviceToken': deviceToken,
    'userEmail': userEmail
  };
  var jsonData = jsonEncode(deviceTokenDTO);
  try {
    final response = await http.post(
      Uri.parse(
          'http://192.168.0.12:8011/internal/api/notification/service/save-device-token'),
      body: jsonData,
      headers: {'Content-Type': 'application/json'},
    );
    print(response);
  } catch (e) {
    print('Ошибка при отправке токена на сервер: $e');
  }*/
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

 final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

    @override
  void initState() {
    super.initState();
    
    checkToken();
    _firebaseMessaging.requestPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("onMessage: ${message.notification}");
      // Действия при получении уведомления в активном режиме приложения

      showOverlayNotification((context) {
      return Card(
        color: Colors.white,
        margin: const EdgeInsets.symmetric(vertical: 50, horizontal: 15),
        child: ListTile(
          minVerticalPadding: 0,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          leading: SizedBox.fromSize(
              size: const Size(40, 40),
              child: ClipOval( child: Image.asset('assets/images/Avatar.png'))
            ),
          title: Text(message.notification!.title??""),
          subtitle: Text(message.notification?.body??""),
          trailing: IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                OverlaySupportEntry.of(context)!.dismiss();
              }),
        ),
      );
    }, duration: Duration(milliseconds: 4000));
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("onLaunch / onResume: ${message.data}");
      // Действия при запуске или возобновлении приложения из уведомления
    });
  }


  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
     child: MaterialApp(
      debugShowCheckedModeBanner: false,
       //home: LoginPage(),
      //home: ProfilePage(),
      home: NotificationsPage(),
      //home: MapRealtimePage(),
      //home: MainPage()
      //home: SignUpPage()

    )
    );
  }
}
