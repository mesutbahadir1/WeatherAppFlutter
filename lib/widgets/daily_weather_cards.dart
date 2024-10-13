import 'package:flutter/material.dart';

class DailyWeatherCard extends StatelessWidget {
  const DailyWeatherCard(
      {Key? key,
      required this.icon,
      required this.temperature,
      required this.date})
      : super(
          key: key,
        );
  final String icon;
  final double temperature;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      child: SizedBox(
        height: 100,
        width: 100,
        child: Column(
          children: [
            Image.network("http://openweathermap.org/img/wn/$icon@4x.png"),
            Text(
              "$temperatureº C",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(date),
          ],
        ),
      ),
    );
  }
}
