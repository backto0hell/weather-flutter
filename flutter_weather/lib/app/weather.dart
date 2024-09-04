import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart' as intl;
import 'package:intl/date_symbol_data_local.dart' as data_local;

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  _WeatherAppState createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  var temp;
  var currently;
  var forecast;
  String selectedCity = 'Moscow';

  final Map<String, String> cityUrls = {
    'Moscow':
        'http://api.openweathermap.org/data/2.5/weather?q=Moscow&units=metric&lang=ru&appid=0661d96c7d714194d61633a5bb32283d',
    'Saint Petersburg':
        'http://api.openweathermap.org/data/2.5/weather?q=Saint Petersburg&units=metric&lang=ru&appid=0661d96c7d714194d61633a5bb32283d',
    'Rostov':
        'http://api.openweathermap.org/data/2.5/weather?q=Rostov&units=metric&lang=ru&appid=0661d96c7d714194d61633a5bb32283d',
    'Khanty-Mansiysk':
        'http://api.openweathermap.org/data/2.5/weather?q=Khanty-Mansiysk&units=metric&lang=ru&appid=0661d96c7d714194d61633a5bb32283d',
    'Yekaterinburg':
        'http://api.openweathermap.org/data/2.5/weather?q=Yekaterinburg&units=metric&lang=ru&appid=0661d96c7d714194d61633a5bb32283d',
  };

  Future getWeather() async {
    http.Response response = await http.get(Uri.parse(cityUrls[selectedCity]!));

    var results = jsonDecode(response.body);
    setState(() {
      this.temp = results['main']['temp'].round();
      this.currently = results['weather'][0]['main'];
    });

    http.Response responseForecast = await http.get(Uri.parse(
        'http://api.openweathermap.org/data/2.5/forecast?q=$selectedCity&units=metric&lang=ru&appid=0661d96c7d714194d61633a5bb32283d'));
    var resultsForecast = jsonDecode(responseForecast.body);
    var list = resultsForecast['list'] as List;
    var distinctDates =
        list.map((item) => DateTime.parse(item['dt_txt']).day).toSet();
    var forecastList = distinctDates
        .map((date) => list
            .firstWhere((item) => DateTime.parse(item['dt_txt']).day == date))
        .toList();
    setState(() {
      this.forecast = forecastList;
    });
  }

  String getWeatherIcon(String weatherCondition) {
    if (weatherCondition.toLowerCase().contains('cloud')) {
      return 'lib/assets/images/cloud.png';
    } else if (weatherCondition.toLowerCase().contains('sun')) {
      return 'lib/assets/images/sun.png';
    } else if (weatherCondition.toLowerCase().contains('rain')) {
      return 'lib/assets/images/rainy.png';
    } else if (weatherCondition.toLowerCase().contains('storm')) {
      return 'lib/assets/images/storm.png';
    } else {
      return 'lib/assets/images/sunny.png';
    }
  }

  @override
  void initState() {
    super.initState();
    data_local
        .initializeDateFormatting('ru_RU', null)
        .then((_) => getWeather());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather'),
        actions: <Widget>[
          DropdownButton<String>(
            value: selectedCity,
            items: cityUrls.keys.map((String city) {
              return DropdownMenuItem<String>(
                value: city,
                child: Text(city),
              );
            }).toList(),
            onChanged: (String? newCity) {
              setState(() {
                selectedCity = newCity!;
                getWeather();
              });
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Now',
                    style: TextStyle(fontSize: 10),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Image.asset(
                    getWeatherIcon(currently),
                    height: 130,
                  ),
                  Text('$temp°', style: const TextStyle(fontSize: 40)),
                  Text('$currently', style: const TextStyle(fontSize: 40))
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: ListView.builder(
                itemCount: forecast == null ? 0 : forecast.length,
                itemBuilder: (context, index) {
                  var date = DateTime.parse(forecast[index]['dt_txt']);
                  var formattedDate =
                      intl.DateFormat('EEEE', 'en_EN').format(date);
                  return Card(
                    color: Colors.lightBlue[100],
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Text(formattedDate,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 20),
                                textAlign: TextAlign.center),
                          ),
                          Expanded(
                            child: Image.asset(
                                getWeatherIcon(
                                    forecast[index]['weather'][0]['main']),
                                width: 60,
                                height: 60),
                          ),
                          Expanded(
                            child: Text(
                                '${forecast[index]['main']['temp'].round()}°',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 30),
                                textAlign: TextAlign.center),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
