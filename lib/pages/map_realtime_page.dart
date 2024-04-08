import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kazgeowarningmobile/components/my_textfield.dart';
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
    final mapTypeController = TextEditingController();
  final mapPresetController = TextEditingController();
   final regionController = TextEditingController();
    final cityAreaController = TextEditingController();
     final locationController = TextEditingController();
      final confidenceScaleController = TextEditingController();

DateTime? fromDate; // Дата "From"
DateTime? toDate;   // Дата "To"

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
                        decoration: BoxDecoration(
                          color: Colors.white, // Цвет заливки контейнера
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(30),
                            topLeft: Radius.circular(30),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: Offset(0, 3),
                            ),
                          ],
                          border: Border.all(color: Color(0xFFE8E8E8), width: 2), // Граница контейнера
                        ),
                        padding: EdgeInsets.only(right: 40, left: 40, top: 40),
                  height: 400,
                  child: Center(
                    
                   child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                      'Map Type',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                      DropdownButtonFormField<String>(
                        value: mapTypeController.text.isNotEmpty ? mapTypeController.text : null, // Устанавливаем значение, если оно не пустое
                        onChanged: (String? newValue) {
                          // Действие при изменении выбранного значения
                          mapTypeController.text = newValue!;
                        },
                        items: <String>['Fire Map', 'Forecast Map']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          labelText: 'Type',
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                      'Light Preset',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                      DropdownButtonFormField<String>(
                        value: mapPresetController.text.isNotEmpty ? mapPresetController.text : null, // Устанавливаем значение, если оно не пустое
                        onChanged: (String? newValue) {
                          // Действие при изменении выбранного значения
                          mapPresetController.text = newValue!;
                        },
                        items: <String>['Night', 'Light', 'Day', 'Dark']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          labelText: 'Mode',
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: onResetType,
                            child: Container(
                              padding: EdgeInsets.only(right: 52, left: 52, top: 10, bottom: 10),
                              margin: EdgeInsets.only(left: 3),
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Text(
                                  "RESET",
                                  style: TextStyle(
                                    color:Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: onTypeFilterApply,
                            child: Container(
                               padding: EdgeInsets.only(right: 52, left: 52, top: 10, bottom: 10),
                               margin: EdgeInsets.only(left: 23),
                              decoration: BoxDecoration(
                                color: Color(0xFF2A5725),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Text(
                                  "APPLY",
                                  style: TextStyle(
                                    color:Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),



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
              isScrollControlled: true,
              context: context,
              builder: (BuildContext context) {
                return FractionallySizedBox(
                heightFactor: 0.9,
                child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white, // Цвет заливки контейнера
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(30),
                            topLeft: Radius.circular(30),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: Offset(0, 3),
                            ),
                          ],
                          border: Border.all(color: Color(0xFFE8E8E8), width: 2), // Граница контейнера
                        ),
                        padding: EdgeInsets.only(right: 40, left: 40, top: 20),
                        height: 700,
                  child: Center(
                    
                   child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                     Text(
                      'Time Period',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                   /* Expanded(
      child: TextButton(
        onPressed: () {
         datatTimePicker.DatePicker.showDatePicker(
            context,
            showTitleActions: true,
            onChanged: (date) {
              print('change $date');
            },
            onConfirm: (date) {
              print('confirm $date');
              setState(() {
                fromDate = date;
              });
            },
            currentTime: DateTime.now(),
          );
        },
        child: Text(
          fromDate != null ? '${fromDate!.day}/${fromDate!.month}/${fromDate!.year}' : 'Select Date',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
    ),
    SizedBox(width: 20),*/
  /* Expanded(
      child: TextButton(
        onPressed: () {
          datatTimePicker.DatePicker.showDatePicker(
            context,
            onConfirm: (date) {
              print('confirm $date');
              setState(() {
                fromDate = date;
              });
            },
          );
        },
        child: Text(
          fromDate != null ? '${fromDate!.day}/${fromDate!.month}/${fromDate!.year}' : 'Select Date',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
    ),
    SizedBox(width: 20),*/
   /* Expanded(
      child: TextButton(
        onPressed: () {
          datatTimePicker.DatePicker.showDatePicker(
            context,
            onConfirm: (date) {
              print('confirm $date');
              setState(() {
                toDate = date;
              });
            },
          );
        },
        child: Text(
          toDate != null ? '${toDate!.day}/${toDate!.month}/${toDate!.year}' : 'Select Date',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
    ),*/
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    labelText: 'To',
                                  ),
                                ),
                              ),
                          SizedBox(height: 15),
                      Text(
                        'Region',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                      DropdownButtonFormField<String>(
                        value: regionController.text.isNotEmpty ? regionController.text : null,
                        onChanged: (String? newValue) {
                          regionController.text = newValue!;
                        },
                        items: <String>['Region 1', 'Region 2', 'Region 3']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          labelText: 'Region',
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Location',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                      DropdownButtonFormField<String>(
                        value: locationController.text.isNotEmpty ? locationController.text : null,
                        onChanged: (String? newValue) {
                          locationController.text = newValue!;
                        },
                        items: <String>['Location 1', 'Location 2', 'Location 3']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          labelText: 'Location',
                        ),
                      ),
                      SizedBox(height: 15),
                      Text(
                        'City/Area',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                      DropdownButtonFormField<String>(
                        value: cityAreaController.text.isNotEmpty ? cityAreaController.text : null,
                        onChanged: (String? newValue) {
                          cityAreaController.text = newValue!;
                        },
                        items: <String>['City/Area 1', 'City/Area 2', 'City/Area 3']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          labelText: 'City/Area',
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Confidence',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                     Expanded(
                          child: DropdownButtonFormField<String>(
                            value: confidenceScaleController.text.isNotEmpty ? confidenceScaleController.text : null,
                            onChanged: (String? newValue) {
                              confidenceScaleController.text = newValue!;
                            },
                            items: <String>['High', 'Nominal', 'Low']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            decoration: InputDecoration(
                              labelText: 'Scale',
                            ),
                          ),
                        ),




                      Container(
                        margin: EdgeInsets.only(bottom: 40, top: 25),
                      child: Row(
                        children: [
                          GestureDetector(
                            
                            onTap: onResetType,
                            child: Container(
                              padding: EdgeInsets.only(right: 52, left: 52, top: 10, bottom: 10),
                              margin: EdgeInsets.only(left: 3),
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Text(
                                  "RESET",
                                  style: TextStyle(
                                    color:Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: onTypeFilterApply,
                            child: Container(
                               padding: EdgeInsets.only(right: 52, left: 52, top: 10, bottom: 10),
                               margin: EdgeInsets.only(left: 23),
                              decoration: BoxDecoration(
                                color: Color(0xFF2A5725),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Text(
                                  "APPLY",
                                  style: TextStyle(
                                    color:Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                      )
                    ],
                  ),



                  ),
                )
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


void onTypeFilterApply() {

}

void onResetType() {

}

}