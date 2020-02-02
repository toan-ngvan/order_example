import 'package:flutter/material.dart';
import 'package:order_example/pages/menu.dart';

class FoodDetail extends StatefulWidget {
  @override
  _FoodDetailState createState() => _FoodDetailState();
}

class _FoodDetailState extends State<FoodDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food detail'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, a1, a2) {
                return Menu();
              },
              transitionsBuilder: (context, a1, a2, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(a1),
                  child: child,
                );
              },
              transitionDuration: Duration(
                milliseconds: 500,
              ),
            ),
          );
        },
      ),
    );
  }
}
