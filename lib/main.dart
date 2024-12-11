//IM/2021/105

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() => runApp(CalculatorApp());

class CalculatorApp extends StatefulWidget {
  @override
  _CalculatorAppState createState() => _CalculatorAppState();
}

class _CalculatorAppState extends State<CalculatorApp> {
  bool isDarkMode = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isDarkMode ? _buildDarkTheme() : _buildLightTheme(),
      home: Calculator(
        toggleTheme: toggleTheme,
        isDarkMode: isDarkMode,
      ),
    );
  }

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.black,
      hintColor: Colors.blue[400],
      scaffoldBackgroundColor: Colors.black,
      textTheme: TextTheme(
        bodyMedium: TextStyle(color: Colors.white),
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.white,
      hintColor: Colors.lightBlue[400],
      scaffoldBackgroundColor: Colors.white,
      textTheme: TextTheme(
        bodyMedium: TextStyle(color: Colors.black),
      ),
    );
  }
}

class Calculator extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  Calculator({required this.toggleTheme, required this.isDarkMode});

  @override
  _CalculatorState createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String input = '';
  String result = '0';
  List<String> history = [];
  bool showHistory = false;

  void calculateSquareRoot() {
    if (input.isEmpty) return;

    final double num = double.parse(input);
    if (num < 0) {
      setState(() {
        result = "Error";
        input = '';
      });
      return;
    }

    double sqrtResult = sqrt(num);
    setState(() {
      result = sqrtResult.toString();
      history.insert(0, "√$input = $result");
      if (history.length > 20) {
        history.removeLast();
      }
      input = '';
    });
  }

  void buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == 'AC') {
        input = '';
        result = '0';
      } else if (buttonText == 'DEL') {
        if (input.isNotEmpty) {
          input = input.substring(0, input.length - 1);
        }
        if (input.isEmpty) {
          result = '0';
        }
      } else if (buttonText == '=') {
        try {
          String processedInput = input
              .replaceAll('%', '/100')
              .replaceAll('x', '*')
              .replaceAll('√', 'sqrt');

          Parser p = Parser();
          Expression exp = p.parse(processedInput);
          ContextModel cm = ContextModel();
          double evalResult = exp.evaluate(EvaluationType.REAL, cm);

          if (evalResult == evalResult.toInt()) {
            result = evalResult.toInt().toString();
          } else {
            result = evalResult.toString();
          }

          history.add('$input = $result');

          input = result;
        } catch (e) {
          result = 'Error';
          input = '';
        }
      } else if (buttonText == '√') {
        calculateSquareRoot();
      } else if (buttonText == '%') {

        if (input.isNotEmpty) {
          input += '%';
        }
      } else {

        if (input.isEmpty && ['+', 'x', '/'].contains(buttonText)) {
          input = '0' + buttonText;
        } else {

          if (input.isNotEmpty &&
              RegExp(r'[+\-x/%]').hasMatch(buttonText) &&
              RegExp(r'[+\-x/%]').hasMatch(input[input.length - 1])) {
            input = input.substring(0, input.length - 1) + buttonText;
          } else {

            if (buttonText == '.' &&
                input.isNotEmpty &&
                input.split(RegExp(r'[+\-x/%\n]')).last.contains('.')) {
              return;
            }


            List<String> rows = input.split('\n');
            String currentRow = rows.isNotEmpty ? rows.last : '';
            if (currentRow.length >= 25 && !RegExp(r'[+\-x/]').hasMatch(buttonText)) {
              return;
            }

            if (currentRow.length == 25 && RegExp(r'[+\-x/]').hasMatch(buttonText)) {
              input += '\n';
            }

            input += buttonText;
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> buttons = [
      'AC', 'DEL', '%', '/',
      '7', '8', '9', 'x',
      '4', '5', '6', '-',
      '1', '2', '3', '+',
      '0', '.', '=', '√'
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('FlexiCalc', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color)),
        actions: [
          IconButton(
            icon: Icon(
              widget.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: Theme.of(context).textTheme.bodyMedium!.color,
            ),
            onPressed: widget.toggleTheme,
          ),
          IconButton(
            icon: Icon(Icons.history, color: Theme.of(context).textTheme.bodyMedium!.color),
            onPressed: () {
              setState(() {
                showHistory = !showHistory;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          if (showHistory)
            Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: history.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                              history[index],
                              style: TextStyle(color: Colors.black),
                            ),
                          );
                        },
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          history.clear();
                        });
                      },
                      child: Text('Clear History', style: TextStyle(color: Colors.blue)),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.all(16.0),
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ...input.split('\n').map((line) {
                    return FittedBox(
                      alignment: Alignment.centerRight,
                      fit: BoxFit.scaleDown,
                      child: Text(
                        line,
                        style: TextStyle(
                          fontSize: line.length > 20
                              ? (30 - (line.length - 20) * 1.5).clamp(16, 30).toDouble()
                              : 30,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).textTheme.bodyMedium!.color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  SizedBox(height: 8),
                  Text(
                    result,
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: widget.isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
              ),
              padding: EdgeInsets.all(16.0),
              itemCount: buttons.length,
              itemBuilder: (context, index) {
                String buttonText = buttons[index];
                bool isOperator = ['+', '-', 'x', '/', 'AC', 'DEL', '%', '√'].contains(buttonText);
                bool isEqualButton = buttonText == '=';

                return GestureDetector(
                  onTap: () {
                    buttonPressed(buttonText);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isEqualButton
                          ? Colors.blue[400]
                          : isOperator
                          ? Colors.blueGrey[50]
                          : Colors.blueGrey[50],
                      borderRadius: BorderRadius.circular(54),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      buttonText,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isOperator ? Colors.blue : (isEqualButton ? Colors.white : Colors.black),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
