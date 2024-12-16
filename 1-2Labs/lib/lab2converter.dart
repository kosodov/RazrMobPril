import 'package:flutter/material.dart';

void main() => runApp(UnitConverterApp());

class UnitConverterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Converteкr",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: UnitConverterScreen(),
    );
  }
}

class UnitConverterScreen extends StatefulWidget {
  @override
  _UnitConverterScreenState createState() => _UnitConverterScreenState();
}

class _UnitConverterScreenState extends State<UnitConverterScreen> {
  String selectedCategory = "Length";
  String fromUnit = "Meters";
  String toUnit = "Kilometers";
  String input = "";
  String result = "";

  final Map<String, List<String>> units = {
    "Length": ["Meters", "Kilometers", "Miles", "Yards"],
    "Weight": ["Kilograms", "Grams", "Pounds", "Ounces"],
    "Area": ["Square Meters", "Square Kilometers", "Hectares", "Acres"],
    "Temperature": ["Celsius", "Fahrenheit", "Kelvin"],
    "Currency": ["USD", "EUR", "RUB", "JPY"],
  };

  final Map<String, Function> conversionFunctions = {
    "Length": (String from, String to, double value) {
      if (from == "Meters" && to == "Kilometers") return value / 1000;
      if (from == "Kilometers" && to == "Meters") return value * 1000;
      if (from == "Meters" && to == "Miles") return value / 1609.34;
      if (from == "Miles" && to == "Meters") return value * 1609.34;
      if (from == "Kilometers" && to == "Miles") return value / 1.60934;
      if (from == "Miles" && to == "Kilometers") return value * 1.60934;
      if (from == "Meters" && to == "Yards") return value * 1.09361;
      if (from == "Yards" && to == "Meters") return value / 1.09361;
      return value; // same unit
    },
    "Weight": (String from, String to, double value) {
      if (from == "Kilograms" && to == "Grams") return value * 1000;
      if (from == "Grams" && to == "Kilograms") return value / 1000;
      if (from == "Kilograms" && to == "Pounds") return value * 2.20462;
      if (from == "Pounds" && to == "Kilograms") return value / 2.20462;
      if (from == "Pounds" && to == "Ounces") return value * 16;
      if (from == "Ounces" && to == "Pounds") return value / 16;
      return value; // same unit
    },
    "Area": (String from, String to, double value) {
      if (from == "Square Meters" && to == "Square Kilometers") return value / 1e6;
      if (from == "Square Kilometers" && to == "Square Meters") return value * 1e6;
      if (from == "Square Meters" && to == "Hectares") return value / 10000;
      if (from == "Hectares" && to == "Square Meters") return value * 10000;
      if (from == "Hectares" && to == "Acres") return value * 2.47105;
      if (from == "Acres" && to == "Hectares") return value / 2.47105;
      return value; // same unit
    },
    "Temperature": (String from, String to, double value) {
      if (from == "Celsius" && to == "Fahrenheit") return value * 9 / 5 + 32;
      if (from == "Fahrenheit" && to == "Celsius") return (value - 32) * 5 / 9;
      if (from == "Celsius" && to == "Kelvin") return value + 273.15;
      if (from == "Kelvin" && to == "Celsius") return value - 273.15;
      if (from == "Fahrenheit" && to == "Kelvin") return (value - 32) * 5 / 9 + 273.15;
      if (from == "Kelvin" && to == "Fahrenheit") return (value - 273.15) * 9 / 5 + 32;
      return value; // same unit
    },
    "Currency": (String from, String to, double value) {
      final rates = {"USD": 1.0, "EUR": 0.85, "RUB": 75.0, "JPY": 110.0};
      if (rates.containsKey(from) && rates.containsKey(to)) {
        return value * (rates[to]! / rates[from]!);
      }
      return value; // same currency
    },
  };

  void _convert() {
    if (input.isEmpty) return;

    final value = double.tryParse(input);
    if (value == null) {
      setState(() => result = "Invalid input");
      return;
    }

    final convert = conversionFunctions[selectedCategory];
    if (convert != null) {
      final convertedValue = convert(fromUnit, toUnit, value);
      setState(() => result = convertedValue.toStringAsFixed(2));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Unit Converter"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedCategory,
              items: units.keys
                  .map((category) => DropdownMenuItem(
                value: category,
                child: Text(category),
              ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedCategory = value;
                    fromUnit = units[value]!.first;
                    toUnit = units[value]!.last;
                  });
                }
              },
            ),
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: fromUnit,
                    items: units[selectedCategory]!
                        .map((unit) => DropdownMenuItem(
                      value: unit,
                      child: Text(unit),
                    ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => fromUnit = value);
                      }
                    },
                  ),
                ),
                Icon(Icons.arrow_right_alt),
                Expanded(
                  child: DropdownButton<String>(
                    value: toUnit,
                    items: units[selectedCategory]!
                        .map((unit) => DropdownMenuItem(
                      value: unit,
                      child: Text(unit),
                    ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => toUnit = value);
                      }
                    },
                  ),
                ),
              ],
            ),
            TextField(
              decoration: InputDecoration(labelText: "Enter value"),
              keyboardType: TextInputType.number,
              onChanged: (value) => setState(() => input = value),
            ),
            ElevatedButton(
              onPressed: _convert,
              child: Text("Convert"),
            ),
            Text(
              "Result: $result",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
