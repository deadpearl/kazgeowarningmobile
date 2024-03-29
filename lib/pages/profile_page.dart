import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kazgeowarningmobile/pages/news_page.dart';
import 'package:kazgeowarningmobile/pages/notifications_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  var userData;
 int _selectedIndex = -1;
  @override
  void initState() {
    super.initState();
    fetchUserData();
  }
  
  Future<void> fetchUserData() async {
    try {
      // Получаем токен из SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token');

      var response = await http.get(
        Uri.parse('http://192.168.0.11:8011/internal/api/public/user/v1/token/$token'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        setState(() {
          userData = responseData['user']; // Сохраняем данные о пользователе
          print('PROFILE: ${userData}');
        });
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: userData != null
      ? Center(
        child: SingleChildScrollView(
        child: Column(
          
  children: [
    Container(
      
      margin: EdgeInsets.only(bottom: 16.0),
      padding: EdgeInsets.only(top: 80.0, left: 24, right: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFDFDFDF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFE8E8E8), width: 2),
      ),
      child: Column(
  children: [
    Container(
      margin: EdgeInsets.only(bottom: 16.0),
      padding: EdgeInsets.only(top: 10.0,bottom: 20, left: 24, right: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFE8E8E8), width: 2),
      ),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: userData['email'] ?? 'Enter your email',
            ),
            controller: TextEditingController(text: userData['email']),
          ),
          SizedBox(height: 16.0),
          TextField(
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: userData['password'] ?? 'Enter your password',
            ),
            controller: TextEditingController(text: userData['password']),
          ),
          SizedBox(height: 16.0),
          TextField(
            decoration: InputDecoration(
              labelText: 'Phone',
              hintText: userData['phone'] ?? 'Enter your phone number',
            ),
            controller: TextEditingController(text: userData['phone']),
          ),
        ],
      ),
    ),
    Container(
      margin: EdgeInsets.only(bottom: 16.0),
      padding: EdgeInsets.only(top: 0.0, left: 24,bottom: 20, right: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFE8E8E8), width: 2),
      ),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: userData['email'] ?? 'Enter your email',
            ),
            controller: TextEditingController(text: userData['email']),
          ),
          SizedBox(height: 16.0),
          TextField(
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: userData['password'] ?? 'Enter your password',
            ),
            controller: TextEditingController(text: userData['password']),
          ),
          SizedBox(height: 16.0),
          TextField(
            decoration: InputDecoration(
              labelText: 'Phone',
              hintText: userData['phone'] ?? 'Enter your phone number',
            ),
            controller: TextEditingController(text: userData['phone']),
          ),
        ],
      ),
    ),
    Container(
      margin: EdgeInsets.only(bottom: 16.0),
      padding: EdgeInsets.only(top: 0.0, left: 24,bottom: 20, right: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFE8E8E8), width: 2),
      ),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: userData['email'] ?? 'Enter your email',
            ),
            controller: TextEditingController(text: userData['email']),
          ),
          SizedBox(height: 16.0),
          TextField(
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: userData['password'] ?? 'Enter your password',
            ),
            controller: TextEditingController(text: userData['password']),
          ),
          SizedBox(height: 16.0),
          TextField(
            decoration: InputDecoration(
              labelText: 'Phone',
              hintText: userData['phone'] ?? 'Enter your phone number',
            ),
            controller: TextEditingController(text: userData['phone']),
         ),
        ],
      ),
    ),
  ],
),)
  ],),),


          
      )
      : CircularProgressIndicator(), 
      
      
      
      
      
      
      
      // Отображаем индикатор загрузки, пока данные загружаются
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: 0,
      onTap: (int index) {
        // Здесь вы можете добавить логику для навигации по разным экранам
        // В зависимости от индекса выбранного элемента
        _onItemTapped(index);
      },
      items: const [
        BottomNavigationBarItem(
          
          icon: Padding(
            padding: EdgeInsets.only(top: 14.0), // Увеличиваем отступ по вертикали
            child: Image(
              image: AssetImage('assets/images/news.png'),
              height: 24, // Задаем высоту иконки
            ),
            
          ),
          label: '',
          
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0), // Увеличиваем отступ по вертикали
            child: Image(
              image: AssetImage('assets/images/flame.png'),
              height: 24, // Задаем высоту иконки
            ),
          ),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0), // Увеличиваем отступ по вертикали
            child: Image(
              image: AssetImage('assets/images/notification.png'),
              height: 24, // Задаем высоту иконки
            ),
          ),
          label: 'Notifications',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0), // Увеличиваем отступ по вертикали
            child: Image(
              image: AssetImage('assets/images/profile.png'),
              height: 28, // Задаем высоту иконки
            ),
          ),
          label: 'Profile',
        ),
      ],
    ),
  );
}

void _onItemTapped(int index) {
  print(index);
  switch (index) {
    case 0:
    print('NEWS:');
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NewsPage()));
      // Обработка нажатия на элемент "News"
      // Навигация на соответствующую страницу или выполнение действия
      break;
    case 1:
    print('FIRE:');
      // Обработка нажатия на элемент "Search"
      // Навигация на соответствующую страницу или выполнение действия
      break;
    case 2:
    print('NOTIFICATIONS:');
     Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NotificationsPage()));
      // Обработка нажатия на элемент "Notifications"
      // Навигация на соответствующую страницу или выполнение действия
      break;
    case 3:
    print('PROFILE:');
      // Обработка нажатия на элемент "Profile"
      // Навигация на соответствующую страницу или выполнение действия
      break;
    default:
    
      break;
  }
}
}