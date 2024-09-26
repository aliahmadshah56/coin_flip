import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const CoinFlipApp());
}

class CoinFlipApp extends StatelessWidget {
  const CoinFlipApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Coin Toss Game',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 36.0, fontWeight: FontWeight.bold), // Updated
          bodyLarge: TextStyle(fontSize: 18.0), // Updated
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 5,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
      home: const CoinFlipPage(),
    );
  }
}

class CoinFlipPage extends StatefulWidget {
  const CoinFlipPage({Key? key}) : super(key: key);

  @override
  _CoinFlipPageState createState() => _CoinFlipPageState();
}

class _CoinFlipPageState extends State<CoinFlipPage>
    with SingleTickerProviderStateMixin {
  String? _userGuess;
  String _coinResult = 'Heads';
  int _score = 0;
  late AnimationController _controller;
  late Animation<double> _animationY;
  late Animation<double> _animationRotationX;
  late Animation<double> _animationRotationY;
  late Animation<double> _animationScale;
  bool _isTossing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animationY = Tween<double>(begin: 0, end: -300).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _animationRotationX = Tween<double>(begin: 0, end: 4 * pi)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
    _animationRotationY = Tween<double>(begin: 0, end: 4 * pi)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
    _animationScale = Tween<double>(begin: 1.0, end: 0.7)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  void _tossCoin() {
    if (_userGuess == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Heads or Tails first!')),
      );
      return;
    }

    setState(() {
      _isTossing = true;
      _controller.forward().then((_) {
        String result = Random().nextBool() ? 'Heads' : 'Tails';
        setState(() {
          _coinResult = result;
        });

        _controller.reverse().then((_) {
          Future.delayed(const Duration(milliseconds: 500), () {
            setState(() {
              if (_userGuess == result) {
                _score++;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Good Guess!')),
                );
              } else {
                _score--;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Try Again!')),
                );
              }
              _isTossing = false;
              _userGuess = null;
              _controller.reset();
            });
          });
        });
      });
    });
  }

  void _resetGame() {
    setState(() {
      _userGuess = null;
      _coinResult = 'Heads';
      _score = 0;
      _controller.reset();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: const Text('Coin Toss Game'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Select Heads or Tails',
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: Colors.deepOrange,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _userGuess = 'Heads';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _userGuess == 'Heads'
                          ? Colors.orange[600]
                          : Colors.blue,
                    ),
                    child: const Text(
                      'Heads',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _userGuess = 'Tails';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _userGuess == 'Tails'
                          ? Colors.orange[600]
                          : Colors.blue,
                    ),
                    child: const Text(
                      'Tails',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _userGuess == null || _isTossing ? null : _tossCoin,
                child: const Text('Toss Coin'),
              ),
              const SizedBox(height: 20),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform(
                    transform: Matrix4.identity()
                      ..translate(0.0, _animationY.value)
                      ..rotateX(_animationRotationX.value)
                      ..rotateY(_animationRotationY.value)
                      ..scale(_animationScale.value),
                    alignment: Alignment.center,
                    child: _coinResult.isNotEmpty
                        ? Image.asset(
                      _coinResult == 'Heads'
                          ? 'assets/head.png'
                          : 'assets/tail.png',
                      height: 150,
                      width: 150,
                    )
                        : SizedBox(
                      height: 150,
                      width: 150,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Your Score: $_score',
                    style: theme.textTheme.headlineLarge?.copyWith(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _resetGame,
                child: const Text('Reset Game'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
