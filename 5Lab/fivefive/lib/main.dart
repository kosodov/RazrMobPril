import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather Forecast',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WeatherHomePage(),
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  _WeatherHomePageState createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  final String apiKey = "EGJ2SXSGJ9HGJHW37C6Z7FVRP";
  final List<String> cities = ["Moscow", "Saint Petersburg", "Yekaterinburg", "Novosibirsk", "Surgut"];
  String selectedCity = "Moscow";
  Map<String, dynamic>? weatherData;

  @override
  void initState() {
    super.initState();
    fetchWeatherData(selectedCity);
  }

  Future<void> fetchWeatherData(String city) async {
    final url = Uri.parse(
        'https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/$city?unitGroup=metric&key=$apiKey&contentType=json');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          weatherData = json.decode(response.body);
        });
      } else {
        showError("Error fetching data: ${response.statusCode}");
      }
    } catch (e) {
      showError("Error fetching data: $e");
    }
  }

  void showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Weather Forecast"),
      ),
      body: Column(
        children: [
          DropdownButton<String>(
            value: selectedCity,
            items: cities.map((city) {
              return DropdownMenuItem(
                value: city,
                child: Text(city),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedCity = value;
                });
                fetchWeatherData(value);
              }
            },
          ),
          Expanded(
            child: weatherData == null
                ? const Center(child: CircularProgressIndicator())
                : WeatherDetails(weatherData: weatherData!),
          ),
        ],
      ),
    );
  }
}

class WeatherDetails extends StatelessWidget {
  final Map<String, dynamic> weatherData;

  const WeatherDetails({super.key, required this.weatherData});

  @override
  Widget build(BuildContext context) {
    final currentConditions = weatherData["currentConditions"];
    final forecast = weatherData["days"];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Current Weather ${weatherData["."]}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Temperature: ${currentConditions["temp"]}°C"),
                Text("Humidity: ${currentConditions["humidity"]}%"),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Pressure: ${currentConditions["pressure"]} hPa"),
                Text("Wind: ${currentConditions["windspeed"]} km/h"),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Forecast for the next days:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...forecast.take(5).map((day) => ForecastTile(day: day)),
          ],
        ),
      ),
    );
  }
}

class ForecastTile extends StatelessWidget {
  final Map<String, dynamic> day;

  const ForecastTile({super.key, required this.day});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: SvgPicture.network(
          "https://www.weatherbit.io/static/img/icons/${day['icon']}.svg",
          width: 40,
          height: 40,
        ),
        title: Text(day["datetime"]),
        subtitle: Text(
            "High: ${day["tempmax"]}°C, Low: ${day["tempmin"]}°C, Conditions: ${day["conditions"]}"),
      ),
    );
  }
}
