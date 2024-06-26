import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kazgeowarningmobile/pages/api_constans.dart';
import 'package:kazgeowarningmobile/pages/map_realtime_page.dart';
import 'package:kazgeowarningmobile/pages/news_item_page.dart';
import 'package:kazgeowarningmobile/pages/notifications_page.dart';
import 'package:kazgeowarningmobile/pages/profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class News {
  final String title;
  final String subtitle;
  final DateTime  publicationDate;
  final String imageUrl;
  final int id;

  News({
    required this.title,
    required this.subtitle,
    required this.publicationDate,
    required this.imageUrl,
    required this.id
  });
}


class NewsPage extends StatefulWidget {
  @override
  _NewsPage createState() => _NewsPage();
}

class _NewsPage extends State<NewsPage> {
  List<News> filteredNews = [];
  List<News> news = [];
  var userData;
 
  @override
  void initState() {
    super.initState();
    fetchNews();
  }


void onSearchTextChanged(String text) {
  setState(() {
    if (text.isEmpty) {
      // Если текстовое поле пустое, показать все новости
      filteredNews = news;
    } else {
      // Фильтровать новости по введенному тексту
      filteredNews = news.where((news) =>
          news.title.toLowerCase().contains(text.toLowerCase())).toList();
    }
  });
}

  Future<void> fetchNews() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('token');

  final Map<String, String> headers = {'x-auth-token': token!};

  final response = await http.get(
    Uri.parse('$baseUrl/internal/api/news'),
    headers: headers,
  );
  
  print(response);
  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
    print(data);

    // Преобразование данных в объекты новостей
    List<News> fetchedNews = data.map((json) => News(
      title: json['title'],
      subtitle: json['subtitle'],
      publicationDate: DateTime.parse(json['publicationDate']),
      imageUrl: json['imageUrl'],
      id: json['id'],
    )).toList();

    setState(() {
      news = fetchedNews; 
      filteredNews = fetchedNews; 
    });
  } else {
    throw Exception('Failed to load news');
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDFDFDF),
      body: Column(
        children: [
          Padding(
  padding: const EdgeInsets.only(top: 55.0, left: 24.0, right: 24),
  child: Container(
    margin: EdgeInsets.only(bottom: 16.0),
    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Color(0xFFE8E8E8), width: 2),
    ),
    child: Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left:5,right: 10.0, ),
          child: Image.asset(
            'assets/images/filter.png', // Путь к изображению фильтра
            width: 40,
            height: 30,
          ),
        ),
        Expanded(
          child: TextField(
            onChanged: onSearchTextChanged,
            decoration: InputDecoration(
              hintText: 'Search...',
              border: InputBorder.none,
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0,right:15),
          child: Image.asset(
            'assets/images/search.png', // Путь к изображению поиска
            width: 24,
            height: 24,
          ),
        ),
      ],
    ),
  ),
),

          

          
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                children: filteredNews.map((newsItem) {
                  return GestureDetector(
                  onTap: () {
                                // Обработка нажатия, например, переход на другую страницу
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => NewsItemPage(newsItem.id)),
                                );
                              },

                  child: Container(
                    margin: EdgeInsets.only(bottom: 16.0),
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Color(0xFFE8E8E8), width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(30),
          ),
ClipRRect(
  borderRadius: BorderRadius.circular(30), // Установите радиус закругления здесь
  child: CachedNetworkImage(
    imageUrl: newsItem.imageUrl,
    placeholder: (context, url) => CircularProgressIndicator(),
    fit: BoxFit.cover,
    width: MediaQuery.of(context).size.width, 
    errorWidget: (context, url, error) {
      print("Ошибка загрузки изображения: $error");
      return Icon(Icons.error); // Или любой другой виджет, который вы хотите показать в случае ошибки
    },
  ),
),

                        SizedBox(height: 12.0),
                        Text(
                          newsItem.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          newsItem.subtitle,
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'Published: ${newsItem.publicationDate.toString().substring(0, 16)}',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 14.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
      
      
      
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
                image: AssetImage('assets/images/news_active.png'),
                height: 28, // Задаем высоту иконки
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

  // Обработчик нажатия на элементы нижней навигационной панели
void _onItemTapped(int index) {
  print(index);
  switch (index) {
    case 0:
    print('NEWS:');
  
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