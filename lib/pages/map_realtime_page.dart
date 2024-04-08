import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kazgeowarningmobile/pages/news_page.dart';
import 'package:kazgeowarningmobile/pages/notifications_page.dart';
import 'package:kazgeowarningmobile/pages/profile_page.dart';
import 'package:flutter_map/flutter_map.dart';
import 'dart:ui';
import 'package:latlong2/latlong.dart';



class MapRealtimePage extends StatefulWidget {

  @override
  _MapRealtimePage createState() => _MapRealtimePage();
}

class FireRTData {
  final String latitude;
  final String longitude;
  final DateTime acqDate;
  final String confidence;

  FireRTData({
    required this.latitude,
    required this.longitude,
    required this.acqDate,
    required this.confidence,
  });
}

class _MapRealtimePage extends State<MapRealtimePage> {
  var markersData;
   List<Marker> markers = [];
 
  @override
  void initState() {
    super.initState();
    searchMarkers();
  }


  Future<void> searchMarkers() async {
 var fireDataDTO = {
  };
  var jsonData = jsonEncode(fireDataDTO);
    final response = await http.post(
      Uri.parse('http://192.168.0.63:8011/internal/api/data/RTData/getByFilter'),
      body: jsonData,
       headers: {'Content-Type': 'application/json'},
    );
    print(response);
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      print(data);
      setState(() {
        markersData = data.map((json) => FireRTData(
              latitude: json['latitude'],
              longitude: json['longitude'],
              acqDate: DateTime.parse(json['acqDate']),
              confidence: json['confidence'],
            )).toList();
            addMarkers();
      });
    } else {
        // Если запрос неудачен, выведите сообщение об ошибке
        print('Request failed with status: ${response.statusCode}'); 
      }
  }

void addMarkers() {
  if (markersData != null) {
    markers = List<Marker>.from(markersData.map((markerData) {
      return Marker(
        width: 10,
        height: 10,
        point: LatLng(double.parse(markerData.latitude), double.parse(markerData.longitude)),
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
        ),
      );
    }).toList());
    setState(() {});
  }
}



 @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        /*MapboxMap(
          styleString: "mapbox://styles/mapbox/satellite-streets-v12",
          initialCameraPosition: CameraPosition(
            target: LatLng(48.0196, 66.9237,),
            zoom: 3,
          ),
          onMapCreated: onMapCreated,
          accessToken: 'sk.eyJ1IjoiZGVhZHBlYXJsIiwiYSI6ImNsdWZhNnJhOTBwOGgyam9jNmQ0MGRnNXAifQ.NrFzF026xXzIPOwr3ppc9g',
        ),*/
        FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(48.0196, 66.9237),
            initialZoom: 4,
          ),
          children: [
            TileLayer(
            urlTemplate: 'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}',
                    additionalOptions: {
                      'accessToken':'sk.eyJ1IjoiZGVhZHBlYXJsIiwiYSI6ImNsdWZhNnJhOTBwOGgyam9jNmQ0MGRnNXAifQ.NrFzF026xXzIPOwr3ppc9g',
                      'id': 'mapbox/satellite-streets-v12'
                    }
            ),
            MarkerLayer(markers: markers)
          
          ],
          ),
        
        Positioned(
          top: 60,
          left: 40,
          child: Row(
            children: [
              GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return Container(
                  height: 200,
                  color: Colors.white,
                  child: Center(
                    child: Text('Bottom Sheet Content'),
                  ),
                );
              },
            );
          },
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
            child: Image.asset('assets/images/map.png'),
          ),
        ),

              SizedBox(width: 210),
              GestureDetector(
                  onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return Container(
                  height: 200,
                  color: Colors.white,
                  child: Center(
                    child: Text('Bottom Sheet Content'),
                  ),
                );
              },
            );
          },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                  ),
                  child: Image.asset('assets/images/filter.png'),
                ),
              ),
            ],
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
                image: AssetImage('assets/images/flame_active.png'),
                height: 30, // Задаем высоту иконки
              ),
            ),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0), // Увеличиваем отступ по вертикали
              child: Image(
                image: AssetImage('assets/images/bell_withnot.png'),
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