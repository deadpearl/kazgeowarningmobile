import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kazgeowarningmobile/pages/api_constans.dart';
import 'package:kazgeowarningmobile/pages/news_page.dart';
import 'package:kazgeowarningmobile/pages/notifications_page.dart';
import 'package:kazgeowarningmobile/pages/profile_page.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';

//profile functionlatiy
//when tap on notification open the notification item page
//signup functionality

class MapRealtimePage extends StatefulWidget {
  @override
  _MapRealtimePage createState() => _MapRealtimePage();
}

class FireRTData {
  final String latitude;
  final String longitude;
  final DateTime acqDate;
  final String confidence;
  final String region;

  FireRTData({
    required this.latitude,
    required this.longitude,
    required this.acqDate,
    required this.confidence,
    required this.region
  });
}

class City {
  final String name;
  final double latitude;
  final double longitude;

  City(this.name, this.latitude, this.longitude);
}

class Region {
  final String regionId;
  final String name;

  Region(this.regionId, this.name);
}

class FireForecastData {
  final String latitude;
  final String longitude;
  final DateTime acqDate;
  final String dangerLevel;
  final String region;

  FireForecastData({
    required this.latitude,
    required this.longitude,
    required this.acqDate,
    required this.dangerLevel,
    required this.region
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
  final TextEditingController regionsController = TextEditingController();
  late String tileLayerUrl = '';
  City? defaultCity = null;
  Region defaultRegion = Region('UNK', 'Undetected Region');

  final List<City> cities = [
    City('Almaty', 43.25667, 76.92861),
    City('Shymkent', 42.3, 69.6),
    City('Taraz', 42.9, 71.36667),
    City('Pavlodar', 52.28333, 76.96667),
    City('Ust-Kamenogorsk', 49.97143, 82.60586),
    City('Kyzylorda', 44.85278, 65.50917),
    City('Semey', 50.42675, 80.26669),
    City('Aktobe', 50.27969, 57.20718),
    City('Karagandy', 49.80187, 73.10211),
    City('Kostanay', 53.21435, 63.62463),
    City('Oral', 51.23333, 51.36667),
    City('Atyrau', 47.11667, 51.88333),
    City('Nur-Sultan', 51.1801, 71.44598),
    City('Turkestan', 43.29733, 68.25175),
    City('Kokshetau', 53.28333, 69.4),
    City('Ekibastuz', 51.72371, 75.32287),
    City('Taldykorgan', 45.01556, 78.37389),
    City('Petropavl', 54.86667, 69.15),
    City('Aksu', 52.04023, 76.92748),
    City('Temirtau', 50.05494, 72.96464)
  ];

  final List<Region> regions = [
    Region('ABA', 'Abay Region'),
    Region('AKM', 'Akmola Region'),
    Region('AKT', 'Aqtöbe Region'),
    Region('ALA', 'Almaty'),
    Region('ALM', 'Almaty Region'),
    Region('AST', 'Astana'),
    Region('ATY', 'Atyrau Region'),
    Region('VOS', 'East Kazakhstan Region'),
    Region('ZHA', 'Jambyl Region'),
    Region('ZHE', 'Jetisu Region'),
    Region('KAR', 'Karaganda Region'),
    Region('KUS', 'Kostanay Region'),
    Region('KZY', 'Kyzylorda Region'),
    Region('MAN', 'Mangystau Region'),
    Region('SEV', 'North Kazakhstan Region'),
    Region('PAV', 'Pavlodar Region'),
    Region('SHY', 'Shymkent'),
    Region('TUR', 'Turkistan Region'),
    Region('YUZ', 'Ulytau Region'),
    Region('ZAP', 'West Kazakhstan Region'),
    Region('UNK', 'Undetected Region'),
  ];

  City? getCityByName(String name) {
    for (City city in cities) {
      if (city.name == name) {
        return city;
      }
    }
    return null; // Вернуть null, если город не найден
  }

  Region? findRegionByIdOrName(String? query) {
    if (query == null) {
      return null;
    }

    for (Region region in regions) {
      if (region.regionId == query || region.name == query) {
        return region;
      }
    }

    return null;
  }

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
    if (markersData != null) {
      markersData.clear();
    }
    City? selectedCity = getCityByName(regionController.text);
    Region? selectedRegion = findRegionByIdOrName(regionsController.text);
    markers.clear();
    var fireDataDTO = {
      'regionId': selectedRegion?.regionId,
      'latitude': selectedCity?.latitude,
      'longitude': selectedCity?.longitude,
      'dateFrom': _fromDateController.text.isNotEmpty
          ? DateFormat('yyyy-MM-dd').format(fromDate)
          : null,
      'dateTo': _toDateController.text.isNotEmpty
          ? DateFormat('yyyy-MM-dd').format(toDate)
          : null,
      'timeFrom': null,
      'timeTo': null,
      'confidence': confidenceScaleController.text.isNotEmpty
          ? convertConfidence(confidenceScaleController.text)
          : null,
    };
    var jsonData = jsonEncode(fireDataDTO);
    final response = await http.post(
      Uri.parse('$baseUrl/internal/api/data/RTData/getByFilter'),
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
                   region: json['regionId']['name_eng']
                ))
            .toList();
        addMarkers();
      });
    } else {
      // Если запрос неудачен, выведите сообщение об ошибке
      print('Request failed with status: ${response.statusCode}');
    }
    Navigator.of(context).pop();
  }

  String convertConfidence(String confidence) {
    if (confidence == 'High') {
      return 'h';
    } else if (confidence == 'Nominal') {
      return 'n';
    } else if (confidence == 'Low') {
      return 'l';
    } else {
      return '';
    }
  }
  String convertConfidenceBackwards(String confidence) {
    if (confidence == 'h') {
      return 'High';
    } else if (confidence == 'n') {
      return 'Nominal';
    } else if (confidence == 'l') {
      return 'Low';
    } else {
      return 'Undefined';
    }
  }

  Future<void> onForecastFilterApply() async {
    markers.clear();
    if (markersData != null) {
      markersData.clear();
    }
    City? selectedCity = getCityByName(regionController.text);
    markers.clear();
    var fireDataDTO = {
      'regionId': null,
      'latitude': selectedCity?.latitude,
      'longitude': selectedCity?.longitude,
      'dateFrom': _fromDateController.text.isNotEmpty
          ? DateFormat('yyyy-MM-dd').format(fromDate)
          : null,
      'dateTo': _toDateController.text.isNotEmpty
          ? DateFormat('yyyy-MM-dd').format(toDate)
          : null,
      'dangerLevelFrom': dangerLevelFromController.text.isNotEmpty
          ? dangerLevelFromController.text
          : null,
      'dangerLevelTo': dangerLevelToController.text.isNotEmpty
          ? dangerLevelToController.text
          : null,
    };
    var jsonData = jsonEncode(fireDataDTO);
    final response = await http.post(
      Uri.parse('$baseUrl/internal/api/data/ForecastData/getByFilter'),
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
                  region: json['regionId']['name_eng']
                ))
            .toList();
        addMarkers();
      });
    } else {
      // Если запрос неудачен, выведите сообщение об ошибке
      print('Request failed with status: ${response.statusCode}');
    }
    Navigator.of(context).pop();
  }

void addMarkers() {
    if (markersData != null) {
        markers = List<Marker>.from(markersData.map((markerData) {
            // Получите цвет маркера на основе уверенности
            Color markerColor = getMarkerColor(markerData.confidence);

            // Создаем маркер
            return Marker(
                width: 10,  // Задаем ширину маркера
                height: 10, // Задаем высоту маркера
                point: LatLng(double.parse(markerData.latitude),
                    double.parse(markerData.longitude)),
                child: GestureDetector(
                    onTap: () {
                        // При нажатии на маркер, показываем всплывающее окно (popup)
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                                return AlertDialog(
                                    title: Text('Marker Info'),
                                    content: Text(
                                        'Latitude: ${markerData.latitude}\nLongitude: ${markerData.longitude}\nConfidence: ${convertConfidenceBackwards(markerData.confidence)}\nRegion: ${markerData.region}',
                                    ),
                                    actions: [
                                        TextButton(
                                            onPressed: () {
                                                // Закрываем всплывающее окно
                                                Navigator.of(context).pop();
                                            },
                                            child: Text('Close'),
                                        ),
                                    ],
                                );
                            },
                        );
                    },
                    child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                            color: markerColor,
                            shape: BoxShape.circle,
                        ),
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

  Color getMarkerColor(String confidence) {
    if (confidence == 'n') {
      return Color(0xFFF77E21).withOpacity(0.8); // Цвет для 'n'
    } else if (confidence == 'h') {
      return Color(0xFFD61C4E).withOpacity(0.8); // Цвет для 'h'
    } else if (confidence == 'l') {
      return Color(0xFFFAC213).withOpacity(0.8); // Цвет для 'l'
    } else {
      return Colors.orange.withOpacity(0.8); // Цвет по умолчанию
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
          Align(
  alignment: Alignment.topCenter, // Позиционируем `Row` сверху по центру
  child: Padding(
    padding: const EdgeInsets.only(top: 60,left:30, right:30), // Отступ сверху
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
  mainAxisAlignment: MainAxisAlignment.center, // Выравнивание по центру
  children: [
    GestureDetector(
      onTap: onResetType,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10), // Уменьшенные отступы
        margin: EdgeInsets.only(left: 3),
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          "RESET",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    ),
    SizedBox(width: 16), // Пространство между кнопками
    GestureDetector(
      onTap: onTypeFilterApply,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10), // Уменьшенные отступы
        decoration: BoxDecoration(
          color: Color(0xFF2A5725),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          "APPLY",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
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
                GestureDetector(
                  onTap: () {
                    if (mapTypeController.text == 'Fire Map' ||
                        mapTypeController.text == '') {
                      showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        builder: (BuildContext context) {
                          return FractionallySizedBox(
                              heightFactor: 0.85,
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
                                        'City',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20,
                                        ),
                                      ),
                                      DropdownButtonFormField<City>(
                                        value: regionController.text.isNotEmpty
                                            ? cities.firstWhere(
                                                (city) =>
                                                    city.name ==
                                                    regionController.text,
                                                orElse: () => defaultCity!,
                                              )
                                            : null,
                                        onChanged: (City? newValue) {
                                          if (newValue != null) {
                                            regionController.text =
                                                newValue.name;
                                            print(
                                                'Selected city: ${newValue.name}, Latitude: ${newValue.latitude}, Longitude: ${newValue.longitude}');
                                            // Вы можете использовать координаты города здесь
                                          }
                                        },
                                        items: cities
                                            .map<DropdownMenuItem<City>>(
                                                (City city) {
                                          return DropdownMenuItem<City>(
                                            value: city,
                                            child: Text(city.name),
                                          );
                                        }).toList(),
                                        decoration: InputDecoration(
                                          labelText: 'City',
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
                                      DropdownButtonFormField<Region>(
                                        value: regionsController.text.isNotEmpty
                                            ? regions.firstWhere(
                                                (region) =>
                                                    region.regionId ==
                                                    regionsController.text,
                                                orElse: () => defaultRegion,
                                              )
                                            : null,
                                        onChanged: (Region? newValue) {
                                          if (newValue != null) {
                                            regionsController.text =
                                                newValue.regionId;
                                          }
                                        },
                                        items: regions
                                            .map<DropdownMenuItem<Region>>(
                                                (Region region) {
                                          return DropdownMenuItem<Region>(
                                            value: region,
                                            child: Text(region.name),
                                          );
                                        }).toList(),
                                        decoration: InputDecoration(
                                          labelText: 'Region',
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
  mainAxisAlignment: MainAxisAlignment.center, // Центрирование элементов в `Row`
  children: [
    Flexible(
      child: GestureDetector(
        onTap: onResetType,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10), // Уменьшенные отступы
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
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
    ),
    SizedBox(width: 10), // Промежуток между кнопками
    Flexible(
      child: GestureDetector(
        onTap: onRealTimeFilterApply,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10), // Уменьшенные отступы
          margin: EdgeInsets.only(left: 10),
          decoration: BoxDecoration(
            color: Color(0xFF2A5725),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
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
    ),
  ],
)
)
                                    ],
                                  ),
                                ),
                              ));
                        },
                      );
                    } else if (mapTypeController.text == 'Forecast Map') {
                      showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        builder: (BuildContext context) {
                          return FractionallySizedBox(
                              heightFactor: 0.85,
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
                                        'City',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20,
                                        ),
                                      ),
                                      DropdownButtonFormField<City>(
                                        value: regionController.text.isNotEmpty
                                            ? cities.firstWhere(
                                                (city) =>
                                                    city.name ==
                                                    regionController.text,
                                                orElse: () => defaultCity!,
                                              )
                                            : null,
                                        onChanged: (City? newValue) {
                                          if (newValue != null) {
                                            regionController.text =
                                                newValue.name;
                                            print(
                                                'Selected city: ${newValue.name}, Latitude: ${newValue.latitude}, Longitude: ${newValue.longitude}');
                                            // Вы можете использовать координаты города здесь
                                          }
                                        },
                                        items: cities
                                            .map<DropdownMenuItem<City>>(
                                                (City city) {
                                          return DropdownMenuItem<City>(
                                            value: city,
                                            child: Text(city.name),
                                          );
                                        }).toList(),
                                        decoration: InputDecoration(
                                          labelText: 'City',
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
                                      DropdownButtonFormField<Region>(
                                        value: regionsController.text.isNotEmpty
                                            ? regions.firstWhere(
                                                (region) =>
                                                    region.regionId ==
                                                    regionsController.text,
                                                orElse: () => defaultRegion,
                                              )
                                            : null,
                                        onChanged: (Region? newValue) {
                                          if (newValue != null) {
                                            regionsController.text =
                                                newValue.regionId;
                                          }
                                        },
                                        items: regions
                                            .map<DropdownMenuItem<Region>>(
                                                (Region region) {
                                          return DropdownMenuItem<Region>(
                                            value: region,
                                            child: Text(region.name),
                                          );
                                        }).toList(),
                                        decoration: InputDecoration(
                                          labelText: 'Region',
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
  mainAxisAlignment: MainAxisAlignment.center, // Центрирование виджетов в Row
  children: [
    Flexible(
      child: GestureDetector(
        onTap: onResetType,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          margin: EdgeInsets.only(left: 3),
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
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
    ),
    SizedBox(width: 10), // Промежуток между кнопками
    Flexible(
      child: GestureDetector(
        onTap: onForecastFilterApply,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          margin: EdgeInsets.only(left: 10),
          decoration: BoxDecoration(
            color: Color(0xFF2A5725),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
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
    ),
  ],
),
)
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
  )
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
    Navigator.of(context).pop();
  }

  void onResetType() {}
}
