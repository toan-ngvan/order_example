import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation _animationParent;
  Animation _animationChild;
  double _screenWidth = window.physicalSize.width / window.devicePixelRatio;
  double r = 500;
  double t = 80;
  double a;
  double b;

  @override
  void initState() {
    a = math.asin((_screenWidth / 2 + 40) / r);
    b = a * r / t;
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _animationParent = Tween<double>(begin: 0, end: a).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.linear,
      ),
    );
    _animationChild = Tween<double>(begin: 0, end: b).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.linear,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('Food'),
        centerTitle: true,
        actions: <Widget>[
          Icon(Icons.shopping_cart),
        ],
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Stack(
          children: <Widget>[
            CurvedShape(),
            Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Column(
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      _renderChild(a),
                      _renderChild(0),
                      _renderChild(-a),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigator.of(context).pushNamed('food-detail');
          if (_animationController.isCompleted) {
            _animationController.reverse();
          } else {
            _animationController.forward();
          }
        },
        child: Icon(Icons.settings_applications),
      ),
    );
  }

  _renderChild(double rad) {
    return AnimatedBuilder(
      animation: _animationParent,
      builder: (_, child) => Transform.rotate(
        angle: _animationParent.value + rad,
        origin: Offset(0.0, -r),
        child: child,
      ),
      child: AnimatedBuilder(
        animation: _animationChild,
        builder: (_, child) {
          return Transform.rotate(
            angle: -_animationChild.value,
            child: child,
          );
        },
        child: CircleAvatar(
          backgroundImage: AssetImage('assets/images/rice.png'),
          backgroundColor: Colors.black12,
          maxRadius: t,
        ),
      ),
    );
  }
}

class CurvedShape extends StatelessWidget {
  static const double CURVE_HEIGHT = 110;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: CURVE_HEIGHT,
      child: CustomPaint(
        painter: _MyPainter(),
      ),
    );
  }
}

class _MyPainter extends CustomPainter {
  static const PI = math.pi;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true
      ..color = Colors.orange;

    Offset left = Offset(0, 90);
    Offset right = Offset(size.width, 90);
    Offset top = Offset(size.width / 2, 110);

    Path path = Path()
      ..lineTo(left.dx,
          left.dy) // this move isn't required since the start point is (0,0)
      ..quadraticBezierTo(top.dx, top.dy, right.dx, right.dy)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
