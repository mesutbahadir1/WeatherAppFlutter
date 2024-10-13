import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hava_durumu/search_page.dart';
import 'package:hava_durumu/widgets/daily_weather_cards.dart';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String location = "Gölcük";
  double? temperature;
  final String key = 'f3038386807a6cadb9696be157966958';
  var locationData;
  String backGr = 'c';
  Position devicePosition = Position(
      longitude: -74.0060,  // Example longitude for New York, USA
      latitude: 40.7128,    // Example latitude for New York, USA
      timestamp: DateTime.now(),
      accuracy: 5.0,        // Example accuracy in meters
      altitude: 10.0,       // Example altitude in meters
      heading: 90.0,        // Example heading in degrees
      speed: 3.0,           // Example speed in meters per second
      speedAccuracy: 1.0    // Example speed accuracy in meters per second
  );

  String? icon;

  List<String> icons = ["04d", "50d", "01d", "04d", "01d"];
  List<double> temperatures = [2.34, 3.2, 6.7, 4.3, 12.3];
  List<String> dates = ["Pazartesi", "Salı", "Çarşamba", "Perşembe", "Cuma"];

  Future<void> getLocationData() async {
    locationData = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$location&appid=$key&units=metric'));
    final locationDataParsed = jsonDecode(locationData.body);
    setState(() {
      temperature = locationDataParsed['main']['temp'];
      location = locationDataParsed['name'];
      backGr = locationDataParsed['weather'][0]['main'];
      icon = locationDataParsed['weather'].first['icon'];
    });
  }

  Future<void> getDailyForecastByLatLon() async {

    var forecastData = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?lat=${devicePosition.latitude}&lon=${devicePosition.longitude}&appid=$key&units=metric'));
    var forecastDataParsed = jsonDecode(forecastData.body);
    temperatures.clear();
    icons.clear();
    dates.clear();

    setState(() {
      for (int i = 0; i < 5; i++) {
        var forecast = forecastDataParsed['list'][i * 8];
        temperatures.add(forecast['main']['temp']);
        icons.add(forecast['weather'][0]['icon']);
        dates.add(forecast['dt_txt']);
      }
    });
  }

  @override
  void initState() {
    getLocationData();
    getDailyForecastByLatLon();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/$backGr.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: (temperature == null)
          ? Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 100,
                width: 100,
                child: LoadingIndicator(
                  indicatorType: Indicator.lineSpinFadeLoader,
                  strokeWidth: 10,
                  colors: [
                    Colors.blue,
                    Colors.white,
                  ],
                  pathBackgroundColor: Colors.green,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Please wait, Retrieving Weather Data ',
                style: TextStyle(fontSize: 17),
              ),
            ],
          ),
        ),
      )
          : Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 100,
                child: Image.network(
                    "http://openweathermap.org/img/wn/$icon@4x.png"),
              ),
              Text(
                "$temperatureº C",
                style: const TextStyle(
                  fontSize: 70,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    location,
                    style: const TextStyle(
                      fontSize: 30,
                    ),
                  ),
                  IconButton(
                      onPressed: () async {
                        final selectedCity = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SearchPage()));
                        location = selectedCity;
                        getLocationData();
                      },
                      icon: const Icon(Icons.search))
                ],
              ),
              SizedBox(
                height: 20,
              ),
              buildWeatherCards(context)
            ],
          ),
        ),
      ),
    );
  }

  Widget buildWeatherCards(BuildContext context) {
    List<DailyWeatherCard> cards = [];
    for (int i = 0; i < 5; i++) {
      cards.add(DailyWeatherCard(
          icon: icons[i], temperature: temperatures[i], date: dates[i]));
    }

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.25,
      width: MediaQuery.of(context).size.width * 0.9,
      child: ListView(scrollDirection: Axis.horizontal, children: cards),
    );
  }
}
