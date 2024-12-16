import 'package:flutter/material.dart';

void main() => runApp(CalculatorApp());

class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Calculator",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String displayText = "0";
  String currentInput = "";
  String operator = "";
  double firstOperand = 0;

  void _onButtonPressed(String value) {
    setState(() {
      if (value == "C") {
        // Сброс всех значений
        displayText = "0";
        currentInput = "";
        operator = "";
        firstOperand = 0;
      } else if (value == "=") {
        // Вычисление результата
        _calculate();
      } else if (["+", "-", "*", "/", "^"].contains(value)) {
        // Сохранение первого операнда и оператора
        operator = value;
        firstOperand = double.tryParse(currentInput) ?? 0;
        currentInput = "";
      } else {
        // Добавление цифр к текущему вводу
        currentInput += value;
        displayText = currentInput;
      }
    });
  }

  void _calculate() {
    double secondOperand = double.tryParse(currentInput) ?? 0;
    double result;

    try {
      if (operator == "+") {
        result = firstOperand + secondOperand;
      } else if (operator == "-") {
        result = firstOperand - secondOperand;
      } else if (operator == "*") {
        result = firstOperand * secondOperand;
      } else if (operator == "/") {
        if (secondOperand == 0) {
          displayText = "Ошибка";
          return;
        }
        result = firstOperand / secondOperand;
      } else if (operator == "^") {
        result = firstOperand;
        for (int i = 1; i < secondOperand; i++) {
          result *= firstOperand;
        }
        if (secondOperand == 0) result = 1; // Любое число в степени 0 = 1
      } else {
        displayText = "Ошибка";
        return;
      }

      displayText = result.toString();
    } catch (e) {
      displayText = "Ошибка";
    } finally {
      // Очистка для следующего ввода
      currentInput = "";
      operator = "";
      firstOperand = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Калькулятор"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.bottomRight,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Text(
                displayText,
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: GridView.count(
              crossAxisCount: 4,
              children: [
                ...["7", "8", "9", "/"].map((label) => _buildButton(label)),
                ...["4", "5", "6", "*"].map((label) => _buildButton(label)),
                ...["1", "2", "3", "-"].map((label) => _buildButton(label)),
                ...["C", "0", "=", "+"].map((label) => _buildButton(label)),
                _buildButton("^")
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String label) {
    return GestureDetector(
      onTap: () => _onButtonPressed(label),
      child: Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: label == "="
              ? Colors.orange
              : label == "C"
              ? Colors.red
              : Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 24,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}