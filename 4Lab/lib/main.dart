import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(CalendarApp());
}

class CalendarApp extends StatelessWidget {
  const CalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: CalendarPage(),
    );
  }
}

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _currentDate = DateTime.now();
  
  // Получаем список дней в текущем месяце
  List<DateTime> _getDaysInMonth(DateTime date) {
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    final lastDayOfMonth = DateTime(date.year, date.month + 1, 0);
    List<DateTime> days = [];

    for (int i = 0; i <= lastDayOfMonth.day - 1; i++) {
      days.add(DateTime(date.year, date.month, i + 1));
    }

    return days;
  }

  // Форматируем текущую дату для отображения
  String _getFormattedDate(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime> daysInMonth = _getDaysInMonth(_currentDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              setState(() {
                _currentDate = DateTime(_currentDate.year, _currentDate.month + 1);
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Отображение месяца и года
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _getFormattedDate(_currentDate),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          // Календарь
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemCount: daysInMonth.length,
              itemBuilder: (context, index) {
                DateTime day = daysInMonth[index];
                bool isToday = day.day == _currentDate.day &&
                    day.month == _currentDate.month &&
                    day.year == _currentDate.year;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentDate = day;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isToday ? Colors.blueAccent : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          color: isToday ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Кнопка для возврата к текущему месяцу
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentDate = DateTime.now();
                });
              },
              child: const Text('Go to Current Month'),
            ),
          ),
        ],
      ),
    );
  }
}
