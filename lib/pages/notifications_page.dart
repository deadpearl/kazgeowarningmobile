import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kazgeowarningmobile/pages/api_constans.dart';
import 'package:kazgeowarningmobile/pages/map_realtime_page.dart';
import 'package:kazgeowarningmobile/pages/news_page.dart';
import 'package:kazgeowarningmobile/pages/notification_item_page.dart';
import 'package:kazgeowarningmobile/pages/profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlertNotification {
  final String senderEmail;
  final String text;
  final bool seen;
  final int id;
  final String notificationType;

  AlertNotification(
      {required this.senderEmail,
      required this.text,
      required this.seen,
      required this.id,
      required this.notificationType});
}

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPage createState() => _NotificationsPage();
}

class _NotificationsPage extends State<NotificationsPage> {
  List<AlertNotification> notifications = [];
  var userData;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var email = prefs.getString('email');

    final Map<String, String> headers = {'x-auth-token': token!};

    final response = await http.get(
      Uri.parse(
          '$baseUrl/internal/api/notification/service/all?email=$email'),
      headers: headers,
    );
    print(response);
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      print(data);
      setState(() {
        notifications = data
            .map((json) => AlertNotification(
                senderEmail: 'kazgeowarning',
                text: json['text'],
                seen: json['seen'],
                id: json['id'],
                notificationType: json['notificationType']))
            .toList();
      });
    } else {
      throw Exception('Failed to load notifications');
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
            padding:
                const EdgeInsets.only(top: 45.0, left: 120.0, bottom: 15.0),
            child: Text(
              'Notifications',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];

                return GestureDetector(
                    onTap: () {
                      // Обработчик нажатия на уведомление
                      // Здесь вы можете отправить ID уведомления на другую страницу
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotificationItemPage(
                              notification.id,
                              notification
                                  .notificationType), // Передаем ID на другую страницу
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(
                          right: 20.0, left: 20.0, top: 8.0),
                      padding: const EdgeInsets.all(18.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                            color: const Color(0xFFE8E8E8), width: 5),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 5, // Радиус круга
                            backgroundColor: notification.seen
                                ? Colors.transparent
                                : Color(
                                    0xFF141C0C), // Цвет круга в зависимости от статуса seen
                            child: notification.seen
                                ? Container()
                                : Text(
                                    ''), // Пустой контейнер или текст, в зависимости от вашего предпочтения
                          ),
                          Image(
                              image:
                                  AssetImage('assets/images/Avatar_green.png')),
                          // Placeholder for image/icon

                          SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Kazgeowarning',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  notification.text.length > 70
                                      ? '${notification.text.substring(0, 70)}...'
                                      : notification.text,
                                  softWrap: true,
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ));
              },
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
              padding:
                  EdgeInsets.only(top: 14.0), // Увеличиваем отступ по вертикали
              child: Image(
                image: AssetImage('assets/images/news.png'),
                height: 24, // Задаем высоту иконки
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.symmetric(
                  vertical: 12.0), // Увеличиваем отступ по вертикали
              child: Image(
                image: AssetImage('assets/images/flame.png'),
                height: 24, // Задаем высоту иконки
              ),
            ),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.symmetric(
                  vertical: 12.0), // Увеличиваем отступ по вертикали
              child: Image(
                image: AssetImage('assets/images/bell_activewithnot.png'),
                height: 30, // Задаем высоту иконки
              ),
            ),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.symmetric(
                  vertical: 12.0), // Увеличиваем отступ по вертикали
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
            context, MaterialPageRoute(builder: (context) => NewsPage()));
        // Обработка нажатия на элемент "News"
        // Навигация на соответствующую страницу или выполнение действия
        break;
      case 1:
        print('FIRE:');
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => MapRealtimePage()));
        // Обработка нажатия на элемент "Search"
        // Навигация на соответствующую страницу или выполнение действия
        break;
      case 2:
        print('NOTIFICATIONS:');
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => NotificationsPage()));
        // Обработка нажатия на элемент "Notifications"
        // Навигация на соответствующую страницу или выполнение действия
        break;
      case 3:
        print('PROFILE:');
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => ProfilePage()));
        // Обработка нажатия на элемент "Profile"
        // Навигация на соответствующую страницу или выполнение действия
        break;
      default:
        break;
    }
  }
}
