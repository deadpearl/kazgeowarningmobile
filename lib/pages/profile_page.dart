import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kazgeowarningmobile/pages/api_constans.dart';
import 'package:kazgeowarningmobile/pages/map_realtime_page.dart';
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
        Uri.parse('$baseUrl/internal/api/public/user/v1/token/$token'),
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
    height: 320,
     width: double.infinity,
  color:const Color(0xFFDFDFDF),
  child: Stack(
    children: [
      // Фото внутри контейнера
      Image.asset(
        'assets/images/profile_back.png', // Путь к изображению
        fit: BoxFit.cover,
        width: double.infinity, // Заполнение контейнера
      ),
      // Фото поверх контейнера
      Positioned(
        top: 120, // Положение по вертикали
        left: 100, // Положение по горизонтали
        child: ClipRRect(
  borderRadius: BorderRadius.circular(100), // Установите радиус закругления здесь
  child: CachedNetworkImage(
    imageUrl: userData['imageUrl'],
    placeholder: (context, url) => CircularProgressIndicator(),
    fit: BoxFit.cover,
    width: 200, 
    errorWidget: (context, url, error) {
      print("Ошибка загрузки изображения: $error");
      return Icon(Icons.error); // Или любой другой виджет, который вы хотите показать в случае ошибки
    },
  ),
),
      ),
    ],
  ),
),



    Container(
      
      margin: EdgeInsets.only(bottom: 16.0),
      padding: EdgeInsets.only(top: 10.0, left: 24, right: 24, bottom: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFDFDFDF),
      ),
      child: Column(
  children: [




    Padding(
            padding: const EdgeInsets.only(top: 25.0, left: 00.0, bottom: 20.0),
            child: Text(
              'WELCOME BACK, ${userData['firstName'].toUpperCase()}!',
              style: TextStyle(
                color: Color(0xFF2A5725),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
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
              labelText: 'First Name',
              hintText: userData['firstName'] ?? 'Enter your first name',
            ),
            controller: TextEditingController(text: userData['firstName']),
          ),
          SizedBox(height: 16.0),
          TextField(
            decoration: InputDecoration(
              labelText: 'Last Name',
              hintText: userData['lastName'] ?? 'Enter your last name',
            ),
            controller: TextEditingController(text: userData['lastName']),
          ),
          SizedBox(height: 16.0),
          TextField(
            decoration: InputDecoration(
              labelText: 'Middle Name',
              hintText: userData['middleName'] ?? 'Enter your middle name',
            ),
            controller: TextEditingController(text: userData['middleName']),
          ),
        ],
      ),
    ),
    Padding(
            padding: const EdgeInsets.only(top: 5.0, left: 00.0, bottom: 20.0),
            child: Text(
              'CONTACT INFORMATION',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),
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
              labelText: 'Phone Number',
              hintText: userData['phoneNumber'] ?? 'Enter your phone number',
            ),
            controller: TextEditingController(text: userData['phoneNumber']),
          ),
          SizedBox(height: 16.0),
          TextField(
            decoration: InputDecoration(
              labelText: 'Birth Date',
              hintText: userData['birthDate'] ?? 'Enter your birth date',
            ),
            controller: TextEditingController(text: userData['birthDate']),
          ),
        ],
      ),
    ),
     Padding(
            padding: const EdgeInsets.only(top: 5.0, left: 00.0, bottom: 20.0),
            child: Text(
              'NOTIFICATION SETTINGS',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),
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
              labelText: 'Location',
              hintText: userData['locationId'] ?? 'Enter your location',
            ),
            controller: TextEditingController(text: userData['locationId']),
          ),
         
          SizedBox(height: 16.0),
          
         Container(
                margin: EdgeInsets.only(bottom: 16.0),
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Color(0xFFE8E8E8), width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Email'),
                      ],
                    ),
                    userData['notifyEmail'] ?? false
                      ? ElevatedButton(
                          
                          onPressed: () {},
                          child: Text('On'),
                        )
                      : ElevatedButton(
                          onPressed: () {},
                          child: Text('Off'),
                        ),
                        Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SMS'),
                      ],
                    ),
                    userData['notifySms'] ?? false
                      ? ElevatedButton(
                          onPressed: () {},
                          child: Text('On'),
                        )
                      : ElevatedButton(
                          onPressed: () {},
                          child: Text('Off'),
                        ),
                  ],
                ),
              ),
              
        ],
        
      ),
      
    ),
   Row(
  mainAxisAlignment: MainAxisAlignment.spaceAround,
  children: [
    Expanded(
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF727272),
          foregroundColor: Colors.white, // Серый цвет для первой кнопки
        ),
        child: Text('LOG OFF'),
      ),
    ),
    SizedBox(width: 8), // Добавляем небольшое расстояние между кнопками
    Expanded(
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          backgroundColor: Color(0xFF2A5725),
          foregroundColor: Colors.white, // Зеленый цвет для второй кнопки
        ),
        child: Text('SAVE'),
      ),
    )
  ],
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
              image: AssetImage('assets/images/bell_withnot.png'),
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
     Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MapRealtimePage()));
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