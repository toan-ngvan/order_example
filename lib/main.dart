// Cores
import 'package:flutter/material.dart';
// Pages
import 'package:order_example/pages/menu.dart';
import 'package:order_example/pages/foodDetail.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Map<String, Widget Function(BuildContext)> _routes = {
    'menu': (context) => Menu(),
    'food-detail': (context) => FoodDetail(),
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FoodDetail(),
      routes: _routes,
    );
  }
}
