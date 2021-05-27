import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_weather/widgets/Weather.dart';
import 'package:flutter_weather/widgets/WeatherItem.dart';
import 'package:flutter_weather/models/WeatherData.dart';
import 'package:flutter_weather/models/ForecastData.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  bool isLoading = false;
  WeatherData weatherData;
  ForecastData forecastData;

  @override
  void initState() {
    super.initState();

    loadWeather();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
          backgroundColor: Colors.blueGrey,
          appBar: AppBar(
            title: Text('Flutter Weather App'),
          ),
          body: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: weatherData != null
                        ? Weather(weather: weatherData)
                        : Container(),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: isLoading
                        ? CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor:
                                new AlwaysStoppedAnimation(Colors.white),
                          )
                        : IconButton(
                            icon: new Icon(Icons.refresh),
                            tooltip: 'Refresh',
                            onPressed: loadWeather,
                            color: Colors.white,
                          ),
                  ),
                ],
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 200.0,
                  child: forecastData != null
                      ? ListView.builder(
                          itemCount: forecastData.list.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) => WeatherItem(
                              weather: forecastData.list.elementAt(index)))
                      : Container(),
                ),
              ),
            )
          ]))),
    );
  }

  loadWeather() async {
    setState(() {
      isLoading = true;
    });

    final lat = 25.5941;
    final lon = 85.1376;
    final weatherResponse = await http.get(
        'https://api.openweathermap.org/data/2.5/weather?APPID=8257c3245fe46476bbb73f8920f1418e&lat=${lat.toString()}&lon=${lon.toString()}&units=metric');
    //'https://api.openweathermap.org/data/2.5/weather?lat=${lat.toString()}&lon=${lon.toString()}&appid={8257c3245fe46476bbb73f8920f1418e}&units={metric}');

    final forecastResponse = await http.get(
        'https://api.openweathermap.org/data/2.5/forecast?APPID=8257c3245fe46476bbb73f8920f1418e&lat=${lat.toString()}&lon=${lon.toString()}&units=metric');

    if (weatherResponse.statusCode == 200 &&
        forecastResponse.statusCode == 200) {
      return setState(() {
        weatherData =
            new WeatherData.fromJson(jsonDecode(weatherResponse.body));
        forecastData =
            new ForecastData.fromJson(jsonDecode(forecastResponse.body));
        isLoading = false;
      });
    }

    setState(() {
      isLoading = false;
    });
  }
}
