import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart'; // Add confetti package

void main() {
  runApp(const CoinFlipApp());
}

class CoinFlipApp extends StatelessWidget {
  const CoinFlipApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Coin Toss',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: const Color(0xFF1E1E2C), // Dark background
        colorScheme: ColorScheme.dark(
          primary: Colors.purple,
          secondary: Colors.cyanAccent,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
              fontSize: 36.0, fontWeight: FontWeight.bold, color: Colors.white),
          bodyLarge: TextStyle(fontSize: 18.0, color: Colors.white70),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 10,
            shadowColor: Colors.cyanAccent,
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
  late Animation<double> _animationTiltY; // Tilt on the Y-axis for realism
  bool _isTossing = false;
  late ConfettiController _confettiController; // Confetti controller

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Y-axis movement (coin moving up and down)
    _animationY = Tween<double>(begin: 0, end: -250).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut, // Ease out to mimic realistic slowing down
    ));

    // X-axis rotation (coin flipping)
    _animationRotationX = Tween<double>(begin: 0, end: 2 * pi * 4) // Four full flips
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Slight Y-axis tilt for realism
    _animationTiltY = Tween<double>(begin: 0, end: pi / 6) // Small tilt angle
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Initialize the confetti controller
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 1));
  }

  void _tossCoin() {
    if (_userGuess == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please select Heads or Tails first!',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.purple,
        ),
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
                _confettiController.play(); // Play confetti on correct guess
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Good Guess!',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                _score--;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Try Again!',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: Colors.red,
                  ),
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
      _confettiController.stop(); // Stop confetti when game is reset
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose(); // Dispose confetti controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Coin Toss',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E1E2C), Color(0xFF232347)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Select Heads or Tails',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildChoiceButton('Heads', context),
                        const SizedBox(width: 20),
                        _buildChoiceButton('Tails', context),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed:
                      _userGuess == null || _isTossing ? null : _tossCoin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.secondary,
                      ),
                      child: const Text('Toss',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                    ),
                    const SizedBox(height: 20),
                    _buildAnimatedCoin(), // Coin flip animation
                    const SizedBox(height: 20),
                    _buildScoreCard(),
                    const SizedBox(height: 20),OutlinedButton(
                      onPressed: _resetGame,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: theme.colorScheme.secondary, width: 2), // Thicker border
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12), // Padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20), // Rounded corners
                        ),
                      ).copyWith(
                        // Add hover and pressed effects
                        backgroundColor: MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                            if (states.contains(MaterialState.pressed)) {
                              return theme.colorScheme.secondary.withOpacity(0.3); // Color when pressed
                            } else if (states.contains(MaterialState.hovered)) {
                              return theme.colorScheme.secondary.withOpacity(0.2); // Color when hovered
                            }
                            return Colors.transparent; // Default background
                          },
                        ),
                      ),
                      child: Text(
                        'Reset',
                        style: TextStyle(
                          color: theme.colorScheme.secondary, // Text color
                          fontSize: 20, // Font size
                          fontWeight: FontWeight.bold, // Bold text
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),
          // Confetti widget
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceButton(String choice, BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = _userGuess == choice;

    return GestureDetector(
      onTap: () {
        setState(() {
          _userGuess = choice;
          _confettiController.stop(); // Stop confetti when a new guess is selected
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.secondary.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: theme.colorScheme.secondary.withOpacity(0.6),
              blurRadius: 15,
              spreadRadius: 5,
            )
          ]
              : [],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
        child: Text(
          choice,
          style: TextStyle(
            color: isSelected ? Colors.white : theme.colorScheme.secondary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedCoin() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform(
          transform: Matrix4.identity()
            ..translate(0.0, _animationY.value) // Y-axis movement
            ..rotateX(_animationRotationX.value) // X-axis rotation (flip)
            ..rotateY(_animationTiltY.value), // Small Y-axis tilt for realism
          alignment: Alignment.center,
          child: Image.asset(
            _coinResult == 'Heads'
                ? 'assets/head.png' // Use your asset for Heads
                : 'assets/tail.png', // Use your asset for Tails
            width: 100,
            height: 100,
          ),
        );
      },
    );
  }

  Widget _buildScoreCard() {
    return Card(
      color: const Color(0xFF2C2C3C),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Score',
              style:
              Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              '$_score',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.yellow,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
