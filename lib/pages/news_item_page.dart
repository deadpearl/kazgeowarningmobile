import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kazgeowarningmobile/pages/api_constans.dart';
import 'package:kazgeowarningmobile/pages/map_realtime_page.dart';
import 'package:kazgeowarningmobile/pages/news_page.dart';
import 'package:kazgeowarningmobile/pages/notifications_page.dart';
import 'package:kazgeowarningmobile/pages/profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewsItemPage extends StatefulWidget {
   final int notificationId;

  NewsItemPage(this.notificationId);
  @override
  _NewsItemPage createState() => _NewsItemPage();
}

class _NewsItemPage extends State<NewsItemPage> {
  var notification;
 
 
  @override
  void initState() {
    super.initState();
    print('notificationId: ${widget.notificationId}');
    fetchNotifications();
  }


    Future<void> fetchNotifications() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token');

      final Map<String, String> headers = {'x-auth-token': token!};
  
      final response = await http.get(
        Uri.parse('$baseUrl/internal/api/news/${widget.notificationId}'),
        headers: headers,
      );
    print(response);
    if (response.statusCode == 200) {
        var responseData = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          notification = responseData; // Сохраняем данные о пользователе
          print('PROFILE: ${notification}');
        });
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFDFDFDF),
    body: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 45.0, left: 25.0, bottom: 0.0, right: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NewsPage()),
                    );
                  },
                ),
                Text(
                  'News',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 40), // Для выравнивания
              ],
            ),
          ),
          // Белый контейнер
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 48.0),
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Color(0xFFE8E8E8), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: 
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: notification != null && notification['imageUrl'] != null
                    ? CachedNetworkImage(
                        imageUrl: notification['imageUrl'],
                        placeholder: (context, url) => CircularProgressIndicator(),
                        fit: BoxFit.cover,
                        width: 325,
                        height: 450,
                        errorWidget: (context, url, error) {
                          print("Ошибка загрузки изображения: $error");
                          return Icon(Icons.error);
                        },
                      )
                    : CircularProgressIndicator(),
                ),
                SizedBox(height: 20),
                // Текст и дата
                if (notification != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (notification['title'] != null)
                        Text(
                          notification['title'],
                          softWrap: true,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      SizedBox(height: 20),
                      if (notification['publicationDate'] != null)
                        Text(
                          notification['publicationDate'].toString().substring(0, 10),
                          softWrap: true,
                          style: TextStyle(
                            color: Color(0xFF2A5725),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      SizedBox(height: 20),
                      if (notification['text'] != null)
                        Text(
                          notification['text'],
                          textAlign: TextAlign.justify,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis, // Обрезка текста, если он выходит за пределы
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
          )
          // Остальная часть содержимого страницы
        ],
      ),
    ),
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: 0,
      onTap: (int index) {
        _onItemTapped(index);
      },
      items: const [
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.only(top: 14.0),
            child: Image(
              image: AssetImage('assets/images/news.png'),
              height: 24,
            ),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Image(
              image: AssetImage('assets/images/flame.png'),
              height: 24,
            ),
          ),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Image(
              image: AssetImage('assets/images/bell_withnot.png'),
              height: 28,
            ),
          ),
          label: 'Notifications',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Image(
              image: AssetImage('assets/images/sharing.png'),
              height: 24,
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage()));
      // Обработка нажатия на элемент "Profile"
      // Навигация на соответствующую страницу или выполнение действия
      break;
    default:
    
      break;
  }
}
}