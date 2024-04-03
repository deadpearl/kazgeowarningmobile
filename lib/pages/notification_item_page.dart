import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kazgeowarningmobile/pages/map_realtime_page.dart';
import 'package:kazgeowarningmobile/pages/news_page.dart';
import 'package:kazgeowarningmobile/pages/profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notifications_page.dart';

class NotificationItemPage extends StatefulWidget {
   final int notificationId;
   final String notificationType; // Идентификатор уведомления

  NotificationItemPage(this.notificationId, this.notificationType);
  @override
  _NotificationItemPage createState() => _NotificationItemPage();
}

class _NotificationItemPage extends State<NotificationItemPage> {
  var notification;
 int _selectedIndex = -1;
 
 
  @override
  void initState() {
    super.initState();
    print('notificationId: ${widget.notificationId}');
    print('notificationType: ${widget.notificationType}');
    fetchNotifications();
  }


    Future<void> fetchNotifications() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token');

      final Map<String, String> headers = {'x-auth-token': token!};
  
      final response = await http.get(
        Uri.parse('http://192.168.0.63:8011/internal/api/notification/service/get-by-id?id=${widget.notificationId}&notificationType=${widget.notificationType}'),
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

    // We are sending a request to mark the notification as viewed, depending on the type of notification
    if (widget.notificationType == 'report') {
      await markReportAsSeen(widget.notificationId);
    } else if (widget.notificationType == 'alert') {
      await markAlertAsSeen(widget.notificationId);
    }
  

  }


Future<void> markReportAsSeen(int id) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('token');

  final Map<String, String> headers = {'x-auth-token': token!};

  final response = await http.put(
    Uri.parse('http://192.168.0.63:8011/internal/api/notification/service/report/seen/$id'),
    headers: headers,
  );
  if (response.statusCode == 200) {
    print('Report marked as seen');
  } else {
    print('Failed to mark report as seen');
  }
}

Future<void> markAlertAsSeen(int id) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('token');

  final Map<String, String> headers = {'x-auth-token': token!};

  final response = await http.put(
    Uri.parse('http://192.168.0.63:8011/internal/api/notification/service/alert/seen/$id'),
    headers: headers,
  );
  if (response.statusCode == 200) {
    print('Alert marked as seen');
  } else {
    print('Failed to mark alert as seen');
  }
}


@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFDFDFDF),
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 45.0, left: 20.0, bottom: 15.0, right: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  // Ваш обработчик кнопки "назад"
                   Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NotificationsPage(), // Передаем ID на другую страницу
            ),
                   );
                },
              ),
              Text(
                'Notifications',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 40), // Просто для выравнивания
            ],
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 48.0),
            padding: const EdgeInsets.all(18.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE8E8E8), width: 5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Image(image: AssetImage('assets/images/Avatar_green.png')),
                    ),
                    SizedBox(width: 12), // Добавляем отступ между изображением и текстом
                    Text(
                      'Kazgeowarning',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),

                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      SizedBox(height: 12),
                      Container(
                        padding: EdgeInsets.only(left: 18, right: 15),
                        width: double.infinity,
                        child: notification != null && notification['text'] != null
                          ? Text(
                              notification['text'],
                              softWrap: true,
                              overflow: TextOverflow.visible,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            )
                          : CircularProgressIndicator(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),

      
      
      
      
      
      
       // Отображаем индикатор загрузки, пока данные загружаются
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (int index) {
          // Вызываем функцию _onItemTapped и передаем в нее индекс выбранного элемента
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
                image: AssetImage('assets/images/bell_activewithnot.png'),
                height: 28, // Задаем высоту иконки
              ),
            ),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0), // Увеличиваем отступ по вертикали
              child: Image(
                image: AssetImage('assets/images/sharing.png'),
                height: 24, // Задаем высоту иконки
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