
import 'package:flutter/material.dart';
import 'package:kazgeowarningmobile/pages/login_page.dart';

class MainPage extends StatelessWidget {
  MainPage({super.key});

  // text editing controllers

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
  children: [
    // Фотография на весь экран
    Image.asset(
      'assets/images/main.png', // Путь к вашей картинке в ассетах
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    ),
    // Размещение первого контейнера с текстом
    Positioned(
      left: 32,
      top: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset('assets/images/Avatar.png'),
                  SizedBox(width: 16),
                  Text(
                    'KazGeoWarning',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ],
      ),
    ),
    // Размещение второго контейнера с текстом
    const Positioned(
      right: 32,
      top: 140,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end, // Выравнивание текста по правому краю
                children: [
                  Text(
                    'Be Ready,',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Be Informed,',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Be Safe.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),
            ],
          ),
        ],
      ),
    ),


Align(
          alignment: Alignment.bottomCenter, // Выравнивание по нижнему центру
          child: Container(
            margin: EdgeInsets.only(bottom: 20), // Отступ от нижнего края
            padding: EdgeInsets.all(20), // Отступ внутри контейнера
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Делает контейнер по размеру содержимого
              children: [
                Text(
                  'Access vital information to safeguard yourself,',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
                Text(
                  'your loved ones, and your property.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 20),
                
                GestureDetector(
       onTap: () {
                  // Обработчик события нажатия, например, навигация на другую страницу
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
      child: Container(
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            "GET STARTED",
            style: TextStyle(
              color:Color(0xFF141C0C),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    ),
              ],
            ),
          ),
        ),



  ],
),

      ),
    );
  }

}