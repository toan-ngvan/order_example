import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:order_example/resources/dummyData.dart' as data;

const double APP_BAR_DEFAULT_HEIGHT = 56;
const double FOOD_RADIUS = 90;
const double CURVE_HEIGHT = FOOD_RADIUS * 2;
const double FOOD_PADDING_TOP = 20;

class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> with TickerProviderStateMixin {
  AppBar _appBar;
  BottomAppBar _bottomAppBar;
  PageController _pageViewController;
  List<Map> foods;
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
    foods = data.foods;

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
    _appBar = AppBar(
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
    _bottomAppBar = BottomAppBar(
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
    );
    return Scaffold(
      appBar: _appBar,
      body: FutureBuilder(
          future: null,
          builder: (context, snapshot) {
            return Stack(
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
                _renderCart(),
              ],
            );
          }),
      bottomNavigationBar: _bottomAppBar,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final AnimationController foodAnimationController =
              AnimationController(
            vsync: this,
            duration: Duration(milliseconds: 800),
          );
          final Animation foodAnimation =
              Tween<double>(begin: 1, end: 0).animate(
            CurvedAnimation(
              parent: foodAnimationController,
              curve: Curves.easeOutQuart,
            ),
          );
          final appBarHeight = _appBar.preferredSize.height;
          final OverlayState overlayState = Overlay.of(context);
          final OverlayEntry overlayEntry = OverlayEntry(
            builder: (_) {
              return Positioned(
                top: appBarHeight + FOOD_PADDING_TOP,
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
                            math.pow(t, 3) * (FOOD_RADIUS + appBarHeight / 2);
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
          await foodAnimationController.forward();
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

  _renderCart() {
    OverlayState overlayState = Overlay.of(context);
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          bottom: -10,
          child: Container(
            width: 200,
            height: FOOD_RADIUS,
            color: Colors.red,
          ),
        );
      },
    );
    overlayState.insert(overlayEntry);
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
