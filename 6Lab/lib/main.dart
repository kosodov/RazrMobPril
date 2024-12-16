import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MealApp());
}

class MealApp extends StatelessWidget {
  const MealApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Справочник рецептов',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MealHomePage(),
    );
  }
}

class MealHomePage extends StatefulWidget {
  const MealHomePage({super.key});

  @override
  _MealHomePageState createState() => _MealHomePageState();
}

class _MealHomePageState extends State<MealHomePage> {
  List<dynamic> meals = [];
  bool isLoading = false;

  // Загрузка списка рецептов
  Future<void> fetchMeals(String category) async {
    setState(() {
      isLoading = true;
    });

    final url =
        'https://www.themealdb.com/api/json/v1/1/filter.php?c=$category';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      setState(() {
        meals = jsonDecode(response.body)['meals'];
      });
    } else {
      throw Exception('Failed to load meals');
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchMeals('Seafood'); // Категория по умолчанию
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Справочник рецептов'),
      ),
      body: Column(
        children: [
          DropdownButton<String>(
            value: 'Seafood',
            items: const [
              DropdownMenuItem(value: 'Seafood', child: Text('Морепродукты')),
              DropdownMenuItem(value: 'Beef', child: Text('Говядина')),
              DropdownMenuItem(value: 'Chicken', child: Text('Курица')),
            ],
            onChanged: (String? newValue) {
              if (newValue != null) {
                fetchMeals(newValue);
              }
            },
          ),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
                  child: ListView.builder(
                    itemCount: meals.length,
                    itemBuilder: (context, index) {
                      final meal = meals[index];
                      return ListTile(
                        title: Text(meal['strMeal']),
                        leading: Image.network(
                          meal['strMealThumb'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MealDetailPage(meal['idMeal']),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}

class MealDetailPage extends StatelessWidget {
  final String mealId;

  const MealDetailPage(this.mealId, {super.key});

  Future<Map<String, dynamic>> fetchMealDetails() async {
    final url =
        'https://www.themealdb.com/api/json/v1/1/lookup.php?i=$mealId';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['meals'][0];
    } else {
      throw Exception('Failed to load meal details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Детали рецепта')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchMealDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Ошибка загрузки данных'));
          } else {
            final meal = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal['strMeal'],
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Image.network(meal['strMealThumb']),
                  const SizedBox(height: 10),
                  Text(
                    'Категория: ${meal['strCategory']}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Инструкция:\n${meal['strInstructions']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
