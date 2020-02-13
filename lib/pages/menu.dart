import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:math' as math;

const double APP_BAR_DEFAULT_HEIGHT = 56;
const List foods = [
  {
    'price': 10.0,
    'name': 'Dummy 1',
  },
  {
    'price': 8.7,
    'name': 'Dummy 2',
  },
  {
    'price': 9.5,
    'name': 'Dummy 3',
  },
  {
    'price': 11.2,
    'name': 'Dummy 4',
  },
  {
    'price': 5.8,
    'name': 'Lorem Ipsum is simply dummy',
  },
  {
    'price': 5.8,
    'name': 'Lorem Ipsum is simply dummy',
  },
];
const double FOOD_RADIUS = 90;
const double CURVE_HEIGHT = FOOD_RADIUS * 2;
const double FOOD_PADDING_TOP = 20;

class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> with TickerProviderStateMixin {
  PageController _pageViewController;
  double _screenWidth = window.physicalSize.width / window.devicePixelRatio;
  double _currentPageValue = 0;
  double _foodRadius = FOOD_RADIUS;
  double _pageviewRatio = 0.7;
  double _pageviewDistance;
  double _translateDistance;
  double _rotateDistance;
  int _currentPage = 0;

  @override
  void initState() {
    _pageviewDistance = _pageviewRatio * _screenWidth;
    _translateDistance = _pageviewDistance / 2 - _foodRadius;
    _rotateDistance = _pageviewDistance - _translateDistance;

    _pageViewController =
        PageController(initialPage: _currentPage, viewportFraction: 0.7)
          ..addListener(() {
            setState(() {
              _currentPageValue = _pageViewController.page;
            });
          });
    super.initState();
  }

  @override
  void dispose() {
    _pageViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar(
      elevation: 0,
      title: Text('Food'),
      centerTitle: true,
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.shopping_cart),
          onPressed: () {},
        ),
      ],
      backgroundColor: Colors.redAccent,
    );
    return Scaffold(
      appBar: appBar,
      body: Stack(
        children: <Widget>[
          CurvedShape(),
          Padding(
            padding: const EdgeInsets.only(top: FOOD_PADDING_TOP),
            child: Center(
              child: Column(
                children: <Widget>[
                  _renderMenu(),
                ],
              ),
            ),
          ),
          _renderPrice(),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                color: Colors.orange,
                child: Text(
                  'ORDER NOW',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          AnimationController foodAnimationController = AnimationController(
            vsync: this,
            duration: Duration(milliseconds: 800),
          );
          Animation foodAnimation = Tween<double>(begin: 1, end: 0).animate(
            CurvedAnimation(
              parent: foodAnimationController,
              curve: Curves.easeOutQuart,
            ),
          );
          OverlayState overlayState = Overlay.of(context);
          OverlayEntry overlayEntry = OverlayEntry(
            builder: (_) {
              return Positioned(
                top: appBar.preferredSize.height + FOOD_PADDING_TOP,
                left: _screenWidth / 2 - FOOD_RADIUS,
                child: AnimatedBuilder(
                  animation: foodAnimation,
                  builder: (_, child) {
                    // Use quadratic Bezier curve
                    // P0(center of circle):
                    // x = 0, y = 0
                    // P1(bottom center of appbar):
                    // x = 0, y = FOOD_RADIUS + FOOD_PADDING_TOP
                    // P2(center of cart icon):
                    // x = _screenWidth / 2 - (iconSize / 2 + iconPadding) (default is 20)
                    // y =
                    double t = 1 - foodAnimation.value;
                    double dx = math.pow(t, 3) * (_screenWidth / 2 - 20);
                    double dy =
                        -2 * (1 - t) * t * (FOOD_RADIUS + FOOD_PADDING_TOP) -
                            math.pow(t, 3) *
                                (FOOD_RADIUS + appBar.preferredSize.height / 2);
                    return Transform.translate(
                      offset: Offset(dx, dy),
                      child: Transform.scale(
                        scale: foodAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    constraints: BoxConstraints(
                        maxHeight: 2 * _foodRadius, maxWidth: 2 * _foodRadius),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/images/rice.png'),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
          overlayState.insert(overlayEntry);
          foodAnimationController.forward();
          await Future.delayed(Duration(milliseconds: 1000));
          foodAnimationController.dispose();
          overlayEntry.remove();
        },
        backgroundColor: Colors.orange,
        child: Icon(
          Icons.add,
          size: 40,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  _renderMenu() {
    return SizedBox(
      height: 4 * _foodRadius,
      child: PageView(
        controller: _pageViewController,
        onPageChanged: (int page) {
          setState(() {
            _currentPage = page;
          });
        },
        children: <Widget>[
          for (var i = 0; i < foods.length; i++)
            Column(
              children: <Widget>[
                _renderHeader(i),
                _renderBody(i),
              ],
            )
        ],
      ),
    );
  }

  _renderHeader(int index) {
    double dxTranslate;
    double rotateAngle;
    double scale;
    if (index == 0) {
      dxTranslate = _currentPageValue * _translateDistance;
      rotateAngle = -_currentPageValue * _rotateDistance / _foodRadius;
      scale = 1 - 0.2 * _currentPageValue;
    } else if (index == foods.length - 1) {
      dxTranslate = (_currentPageValue - foods.length + 1) * _translateDistance;
      rotateAngle = (index - _currentPageValue) * _rotateDistance / _foodRadius;
      scale = 1 - 0.2 * (index - _currentPageValue);
    } else {
      dxTranslate = (_currentPageValue - index) * _translateDistance;
      rotateAngle =
          -(_currentPageValue - index) * _rotateDistance / _foodRadius;
      scale = 1 - 0.2 * (_currentPageValue - index).abs();
    }

    return Stack(
      children: <Widget>[
        AnimatedBuilder(
          animation: AnimationController(vsync: this),
          builder: (_, child) {
            return Transform.translate(
              offset: Offset(dxTranslate, 0),
              child: child,
            );
          },
          child: Transform.rotate(
            angle: rotateAngle,
            child: Transform.scale(
              scale: scale,
              child: Container(
                constraints: BoxConstraints(
                    maxHeight: 2 * _foodRadius, maxWidth: 2 * _foodRadius),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage('assets/images/rice.png'),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  _renderBody(int index) {
    double opacity;
    double dxTranslate = 0;

    if (index == 0) {
      opacity = _currentPageValue <= 1 ? 1 - _currentPageValue : 0;
    } else if (index == foods.length - 1) {
      opacity =
          _currentPageValue >= index - 1 ? _currentPageValue + 1 - index : 0;
    } else {
      opacity = _currentPageValue < index - 1 || _currentPageValue > index + 1
          ? 0
          : _currentPageValue <= index
              ? _currentPageValue + 1 - index
              : index + 1 - _currentPageValue;
    }
    // dxTranslate = _pageviewDistance / 2 * (1 - opacity);

    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: Transform.translate(
        offset: Offset(dxTranslate, 0),
        child: AnimatedOpacity(
          duration: Duration(milliseconds: 0),
          opacity: opacity,
          child: Column(
            children: <Widget>[
              Text(
                foods[index]['name'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.redAccent,
                ),
              ),
              SizedBox(
                height: 40,
              ),
              Text(
                'Lorem Ipsum is simply dummy Lorem Ipsum is simply dummy',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _renderPrice() {
    double currentPrice = foods[_currentPage]['price'];
    double nextPrice;
    double difPrice;
    double price;
    double rate;
    int next = _currentPage;
    if (_currentPage > _currentPageValue) {
      next = _currentPage - 1;
    } else if (_currentPage < _currentPageValue) {
      next = _currentPage + 1;
    }
    nextPrice = foods[next]['price'];
    difPrice = nextPrice - currentPrice;
    rate = (_currentPage - _currentPageValue).abs();
    price = currentPrice + difPrice * rate;

    return Positioned(
      right: _screenWidth / 2 - _foodRadius - 65,
      top: 3,
      child: Container(
        width: 70,
        height: 70,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.orange,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4.0,
            ),
          ],
        ),
        child: RichText(
          text: TextSpan(
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
            children: <TextSpan>[
              TextSpan(
                text: '${price.toStringAsFixed(1)}',
              ),
              TextSpan(
                text: '\$',
                style: TextStyle(
                  fontSize: 16,
                  textBaseline: TextBaseline.alphabetic,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CurvedShape extends StatelessWidget {
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
      ..color = Colors.redAccent;

    Offset left =
        Offset(-5, APP_BAR_DEFAULT_HEIGHT + FOOD_PADDING_TOP + FOOD_RADIUS / 4);
    Offset right = Offset(size.width,
        APP_BAR_DEFAULT_HEIGHT + FOOD_PADDING_TOP + FOOD_RADIUS / 4);
    Offset top = Offset(size.width / 2, CURVE_HEIGHT);

    Path path = Path()
      ..lineTo(left.dx, left.dy)
      ..quadraticBezierTo(top.dx, top.dy, right.dx, right.dy)
      ..lineTo(size.width, -5)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
