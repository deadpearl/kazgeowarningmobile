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
import 'package:intl/intl.dart';

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

class FireForecastData {
  final String latitude;
  final String longitude;
  final DateTime acqDate;
  final String dangerLevel;

  FireForecastData({
    required this.latitude,
    required this.longitude,
    required this.acqDate,
    required this.dangerLevel,
  });
}

class _MapRealtimePage extends State<MapRealtimePage> {
  final mapTypeController = TextEditingController(text: 'Fire Map');
  final mapPresetController = TextEditingController();
  final regionController = TextEditingController();
  final cityAreaController = TextEditingController();
  final locationController = TextEditingController();
  final confidenceScaleController = TextEditingController();
  final dangerLevelFromController = TextEditingController();
   final dangerLevelToController = TextEditingController();
  late TextEditingController _fromDateController = TextEditingController();
  late TextEditingController _toDateController = TextEditingController();
  late String tileLayerUrl = '';

  var markersData;
  List<Marker> markers = [];

  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();

  Future<void> _fromSelectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fromDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != fromDate) {
      setState(() {
        fromDate = picked;
        _fromDateController.text =
            '${fromDate.day}/${fromDate.month}/${fromDate.year}';
      });
    }
  }

  Future<void> _toSelectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: toDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != toDate) {
      setState(() {
        toDate = picked;
        _toDateController.text = '${toDate.day}/${toDate.month}/${toDate.year}';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    tileLayerUrl = 'mapbox/satellite-streets-v12';
    fromDate = DateTime.now();
    toDate = DateTime.now();
    _fromDateController = TextEditingController(
      text: '${fromDate.day}/${fromDate.month}/${fromDate.year}',
    );
  }

  @override
  void dispose() {
    _fromDateController.dispose();
    super.dispose();
  }

  Future<void> onRealTimeFilterApply() async {
    markersData.clear();
     markers.clear();
    var fireDataDTO = {
  'regionId': regionController.text.isNotEmpty ? regionController.text : null,
  'latitude':  null,
  'longitude':  null,
  'dateFrom': _fromDateController.text.isNotEmpty ? DateFormat('yyyy-MM-dd').format(fromDate) : null,
  'dateTo': _toDateController.text.isNotEmpty ? DateFormat('yyyy-MM-dd').format(toDate) : null,
  'timeFrom': null, // Время не указано в форме, оставляем null
  'timeTo': null, // Время не указано в форме, оставляем null
  'confidence': confidenceScaleController.text.isNotEmpty ? confidenceScaleController.text : null,
};
    var jsonData = jsonEncode(fireDataDTO);
    final response = await http.post(
      Uri.parse(
          'http://192.168.0.63:8011/internal/api/data/RTData/getByFilter'),
      body: jsonData,
      headers: {'Content-Type': 'application/json'},
    );
    print(response);
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      print(data);
      setState(() {
        markersData = data
            .map((json) => FireRTData(
                  latitude: json['latitude'],
                  longitude: json['longitude'],
                  acqDate: DateTime.parse(json['acqDate']),
                  confidence: json['confidence'],
                ))
            .toList();
        addMarkers();
      });
    } else {
      // Если запрос неудачен, выведите сообщение об ошибке
      print('Request failed with status: ${response.statusCode}');
    }
  }



   Future<void> onForecastFilterApply() async {
     markers.clear();
     if (markersData != null) {
    markersData.clear();
  }
  markers.clear();
    var fireDataDTO = {
  'regionId': regionController.text.isNotEmpty ? regionController.text : null,
  'latitude':  null,
  'longitude':  null,
  'dateFrom': _fromDateController.text.isNotEmpty ? DateFormat('yyyy-MM-dd').format(fromDate) : null,
  'dateTo': _toDateController.text.isNotEmpty ? DateFormat('yyyy-MM-dd').format(toDate) : null,
  'dangerLevelFrom':dangerLevelFromController.text.isNotEmpty ? dangerLevelFromController.text : null,
  'dangerLevelTo': dangerLevelToController.text.isNotEmpty ? dangerLevelToController.text : null,
};
    var jsonData = jsonEncode(fireDataDTO);
    final response = await http.post(
      Uri.parse(
          'http://192.168.0.63:8011/internal/api/data/ForecastData/getByFilter'),
      body: jsonData,
      headers: {'Content-Type': 'application/json'},
    );
    print(response);
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      print(data);
      setState(() {
        markersData = data
            .map((json) => FireForecastData(
                  latitude: json['stationId']['latitude'],
                  longitude: json['stationId']['longitude'],
                  acqDate: DateTime.parse(json['time']),
                  dangerLevel: json['dangerLevel'],
                ))
            .toList();
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
          width: 30,
          height: 30,
          point: LatLng(double.parse(markerData.latitude),
              double.parse(markerData.longitude)),
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
          ),
        );
      }).toList());
      setState(() {});
    }
  }

  String getMapStyleUrl(String selectedPreset) {
    switch (selectedPreset.toLowerCase()) {
      case 'day':
        return 'mapbox/satellite-streets-v12';
      case 'light':
        return 'mapbox/light-v11';
      case 'dark':
        return 'mapbox/dark-v11';
      case 'night':
        return 'mapbox/navigation-night-v1';
      default:
        return 'mapbox/satellite-streets-v12';
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
                  urlTemplate:
                      'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}',
                  additionalOptions: {
                    'accessToken':
                        'sk.eyJ1IjoiZGVhZHBlYXJsIiwiYSI6ImNsdWZhNnJhOTBwOGgyam9jNmQ0MGRnNXAifQ.NrFzF026xXzIPOwr3ppc9g',
                    'id': tileLayerUrl,
                  }),
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
                            border: Border.all(
                                color: Color(0xFFE8E8E8),
                                width: 2), // Граница контейнера
                          ),
                          padding:
                              EdgeInsets.only(right: 40, left: 40, top: 40),
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
                                  value: mapTypeController.text.isNotEmpty
                                      ? mapTypeController.text
                                      : null, // Устанавливаем значение, если оно не пустое
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      mapTypeController.text = newValue ??
                                          ''; // Обновляем значение контроллера
                                    });
                                  },
                                  items: <String>['Fire Map', 'Forecast Map']
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
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
                                  value: mapPresetController.text.isNotEmpty
                                      ? mapPresetController.text
                                      : null, // Устанавливаем значение, если оно не пустое
                                  onChanged: (String? newValue) {
                                    // Действие при изменении выбранного значения
                                    mapPresetController.text = newValue!;
                                  },
                                  items: <String>[
                                    'Night',
                                    'Light',
                                    'Day',
                                    'Dark'
                                  ].map<DropdownMenuItem<String>>(
                                      (String value) {
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
                                        padding: EdgeInsets.only(
                                            right: 52,
                                            left: 52,
                                            top: 10,
                                            bottom: 10),
                                        margin: EdgeInsets.only(left: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.grey,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            "RESET",
                                            style: TextStyle(
                                              color: Colors.white,
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
                                        padding: EdgeInsets.only(
                                            right: 52,
                                            left: 52,
                                            top: 10,
                                            bottom: 10),
                                        margin: EdgeInsets.only(left: 23),
                                        decoration: BoxDecoration(
                                          color: Color(0xFF2A5725),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            "APPLY",
                                            style: TextStyle(
                                              color: Colors.white,
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
                    if (mapTypeController.text == 'Fire Map' || mapTypeController.text == '') {
                      showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        builder: (BuildContext context) {
                          return FractionallySizedBox(
                              heightFactor: 0.9,
                              child: Container(
                                decoration: BoxDecoration(
                                  color:
                                      Colors.white, // Цвет заливки контейнера
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
                                  border: Border.all(
                                      color: Color(0xFFE8E8E8),
                                      width: 2), // Граница контейнера
                                ),
                                padding: EdgeInsets.only(
                                    right: 40, left: 40, top: 20),
                                height: 700,
                                child: Center(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                      TextFormField(
                                        readOnly:
                                            true, // чтобы предотвратить ввод пользователем в поле
                                        controller: _fromDateController,
                                        onTap: () {
                                          _fromSelectDate(context);
                                        },
                                        decoration: InputDecoration(
                                          labelText: 'From',
                                        ),
                                      ),
                                      TextFormField(
                                        readOnly:
                                            true, // чтобы предотвратить ввод пользователем в поле
                                        controller: _toDateController,
                                        onTap: () {
                                          _toSelectDate(context);
                                        },
                                        decoration: InputDecoration(
                                          labelText: 'To',
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
                                        value: regionController.text.isNotEmpty
                                            ? regionController.text
                                            : null,
                                        onChanged: (String? newValue) {
                                          regionController.text = newValue!;
                                        },
                                        items: <String>[
                                          'Region 1',
                                          'Region 2',
                                          'Region 3'
                                        ].map<DropdownMenuItem<String>>(
                                            (String value) {
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
                                        value:
                                            locationController.text.isNotEmpty
                                                ? locationController.text
                                                : null,
                                        onChanged: (String? newValue) {
                                          locationController.text = newValue!;
                                        },
                                        items: <String>[
                                          'Location 1',
                                          'Location 2',
                                          'Location 3'
                                        ].map<DropdownMenuItem<String>>(
                                            (String value) {
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
                                        value:
                                            cityAreaController.text.isNotEmpty
                                                ? cityAreaController.text
                                                : null,
                                        onChanged: (String? newValue) {
                                          cityAreaController.text = newValue!;
                                        },
                                        items: <String>[
                                          'City/Area 1',
                                          'City/Area 2',
                                          'City/Area 3'
                                        ].map<DropdownMenuItem<String>>(
                                            (String value) {
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
                                          value: confidenceScaleController
                                                  .text.isNotEmpty
                                              ? confidenceScaleController.text
                                              : null,
                                          onChanged: (String? newValue) {
                                            confidenceScaleController.text =
                                                newValue!;
                                          },
                                          items: <String>[
                                            'High',
                                            'Nominal',
                                            'Low'
                                          ].map<DropdownMenuItem<String>>(
                                              (String value) {
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
                                          margin: EdgeInsets.only(
                                              bottom: 40, top: 25),
                                          child: Row(
                                            children: [
                                              GestureDetector(
                                                onTap: onResetType,
                                                child: Container(
                                                  padding: EdgeInsets.only(
                                                      right: 52,
                                                      left: 52,
                                                      top: 10,
                                                      bottom: 10),
                                                  margin:
                                                      EdgeInsets.only(left: 3),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: const Center(
                                                    child: Text(
                                                      "RESET",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: onRealTimeFilterApply,
                                                child: Container(
                                                  padding: EdgeInsets.only(
                                                      right: 52,
                                                      left: 52,
                                                      top: 10,
                                                      bottom: 10),
                                                  margin:
                                                      EdgeInsets.only(left: 23),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFF2A5725),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: const Center(
                                                    child: Text(
                                                      "APPLY",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ))
                                    ],
                                  ),
                                ),
                              ));
                        },
                      );
                    } 
                    
                    
                    
                    
                    else if (mapTypeController.text == 'Forecast Map') {
                          showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        builder: (BuildContext context) {
                          return FractionallySizedBox(
                              heightFactor: 0.97,
                              child: Container(
                                decoration: BoxDecoration(
                                  color:
                                      Colors.white, // Цвет заливки контейнера
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
                                  border: Border.all(
                                      color: Color(0xFFE8E8E8),
                                      width: 2), // Граница контейнера
                                ),
                                padding: EdgeInsets.only(
                                    right: 40, left: 40, top: 20),
                                height: 700,
                                child: Center(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                      TextFormField(
                                        readOnly:
                                            true, // чтобы предотвратить ввод пользователем в поле
                                        controller: _fromDateController,
                                        onTap: () {
                                          _fromSelectDate(context);
                                        },
                                        decoration: InputDecoration(
                                          labelText: 'From',
                                        ),
                                      ),
                                      TextFormField(
                                        readOnly:
                                            true, // чтобы предотвратить ввод пользователем в поле
                                        controller: _toDateController,
                                        onTap: () {
                                          _toSelectDate(context);
                                        },
                                        decoration: InputDecoration(
                                          labelText: 'To',
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
                                        value: regionController.text.isNotEmpty
                                            ? regionController.text
                                            : null,
                                        onChanged: (String? newValue) {
                                          regionController.text = newValue!;
                                        },
                                        items: <String>[
                                          'Region 1',
                                          'Region 2',
                                          'Region 3'
                                        ].map<DropdownMenuItem<String>>(
                                            (String value) {
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
                                        value:
                                            locationController.text.isNotEmpty
                                                ? locationController.text
                                                : null,
                                        onChanged: (String? newValue) {
                                          locationController.text = newValue!;
                                        },
                                        items: <String>[
                                          'Location 1',
                                          'Location 2',
                                          'Location 3'
                                        ].map<DropdownMenuItem<String>>(
                                            (String value) {
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
                                        value:
                                            cityAreaController.text.isNotEmpty
                                                ? cityAreaController.text
                                                : null,
                                        onChanged: (String? newValue) {
                                          cityAreaController.text = newValue!;
                                        },
                                        items: <String>[
                                          'City/Area 1',
                                          'City/Area 2',
                                          'City/Area 3'
                                        ].map<DropdownMenuItem<String>>(
                                            (String value) {
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
                                        'Danger Level*',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20,
                                        ),
                                      ),
                                      Expanded(
                                        child: DropdownButtonFormField<String>(
                                          value: dangerLevelFromController
                                                  .text.isNotEmpty
                                              ? dangerLevelFromController.text
                                              : null,
                                          onChanged: (String? newValue) {
                                            dangerLevelFromController.text =
                                                newValue!;
                                          },
                                          items: <String>[
                                            '10',
                                            '20',
                                            '30',
                                            '40',
                                            '50',
                                            '60',
                                            '70',
                                            '80',
                                            '90',
                                            '100',
                                          ].map<DropdownMenuItem<String>>(
                                              (String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                          decoration: InputDecoration(
                                            labelText: 'From',
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: DropdownButtonFormField<String>(
                                          value: dangerLevelToController
                                                  .text.isNotEmpty
                                              ? dangerLevelToController.text
                                              : null,
                                          onChanged: (String? newValue) {
                                            dangerLevelToController.text =
                                                newValue!;
                                          },
                                          items: <String>[
                                            '10',
                                            '20',
                                            '30',
                                            '40',
                                            '50',
                                            '60',
                                            '70',
                                            '80',
                                            '90',
                                            '100',
                                          ].map<DropdownMenuItem<String>>(
                                              (String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                          decoration: InputDecoration(
                                            labelText: 'To',
                                          ),
                                        ),
                                      ),
                                      Container(
                                          margin: EdgeInsets.only(
                                              bottom: 40, top: 25),
                                          child: Row(
                                            children: [
                                              GestureDetector(
                                                onTap: onResetType,
                                                child: Container(
                                                  padding: EdgeInsets.only(
                                                      right: 52,
                                                      left: 52,
                                                      top: 10,
                                                      bottom: 10),
                                                  margin:
                                                      EdgeInsets.only(left: 3),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: const Center(
                                                    child: Text(
                                                      "RESET",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: onForecastFilterApply,
                                                child: Container(
                                                  padding: EdgeInsets.only(
                                                      right: 52,
                                                      left: 52,
                                                      top: 10,
                                                      bottom: 10),
                                                  margin:
                                                      EdgeInsets.only(left: 23),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFF2A5725),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: const Center(
                                                    child: Text(
                                                      "APPLY",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ))
                                    ],
                                  ),
                                ),
                              ));
                        },
                      );
                    }
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
                image: AssetImage('assets/images/flame_active.png'),
                height: 30, // Задаем высоту иконки
              ),
            ),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.symmetric(
                  vertical: 12.0), // Увеличиваем отступ по вертикали
              child: Image(
                image: AssetImage('assets/images/bell_withnot.png'),
                height: 28, // Задаем высоту иконки
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

  void onTypeFilterApply() {
    String selectedPreset = mapPresetController.text.toLowerCase();
    String mapStyleUrl = getMapStyleUrl(selectedPreset);
    // Здесь вы можете обновить стиль вашей карты
    // Например, если вы используете FlutterMap, вы можете обновить URL-шаблон TileLayer
    setState(() {
      tileLayerUrl = mapStyleUrl;
    });
  }

  void onResetType() {}
}
