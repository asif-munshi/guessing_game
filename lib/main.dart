import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Guess',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class Guess {
  final int value;
  final String feedback;

  Guess(this.value, this.feedback);
}

class MyAppState extends ChangeNotifier {
  int randomNumber = Random().nextInt(99) + 1;
  List<Guess> guesses = [];
  GlobalKey<AnimatedListState>? historyListKey;

  void newGame() {
    guesses.clear();
    randomNumber = Random().nextInt(99) + 1;
    historyListKey = GlobalKey<AnimatedListState>();
    notifyListeners();
  }

  void addGuess(Guess guess) {
    guesses.insert(0, guess);
    historyListKey?.currentState?.insertItem(0);
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  String _errorMessage = '';
  bool _gameWon = false;
  Key _historyListKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      if (_errorMessage.isNotEmpty) {
        setState(() {
          _errorMessage = '';
        });
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitGuess() {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a number.';
      });
      _focusNode.requestFocus();
      return;
    }

    final guessValue = int.tryParse(text);
    if (guessValue == null || guessValue < 1 || guessValue > 100) {
      setState(() {
        _errorMessage = 'Please enter a number between 1 and 100.';
      });
      _focusNode.requestFocus();
      return;
    }

    final appState = context.read<MyAppState>();
    String feedback;
    if (guessValue < appState.randomNumber) {
      feedback = 'Too low!';
    } else if (guessValue > appState.randomNumber) {
      feedback = 'Too high!';
    } else {
      feedback = 'You guessed it!';
      setState(() {
        _gameWon = true;
      });
    }

    appState.addGuess(Guess(guessValue, feedback));

    setState(() {
      _errorMessage = '';
      _textController.clear();
    });
    _focusNode.requestFocus();
  }

  void _startNewGame() {
    final appState = context.read<MyAppState>();
    appState.newGame();
    setState(() {
      _gameWon = false;
      _historyListKey = UniqueKey();
    });
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(flex: 3, child: HistoryListView(key: _historyListKey)),
            SizedBox(height: 15),
            BigCard(
              controller: _textController,
              focusNode: _focusNode,
              onSubmitted: _gameWon ? null : (_) => _submitGuess(),
              enabled: !_gameWon,
            ),
            Visibility(
              visible: _errorMessage.isNotEmpty,
              maintainState: true,
              maintainAnimation: true,
              maintainSize: true,
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(_errorMessage, style: TextStyle(color: Colors.red)),
              ),
            ),
            SizedBox(height: 10),
            if (_gameWon)
              ElevatedButton(
                onPressed: _startNewGame,
                child: const Text('Play Again'),
              )
            else
              ElevatedButton.icon(
                onPressed: _submitGuess,
                icon: Icon(Icons.arrow_forward_rounded),
                label: const Text('Submit'),
              ),
            Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.controller,
    required this.focusNode,
    this.onSubmitted,
    required this.enabled,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String)? onSubmitted;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: AnimatedSize(
          duration: Duration(milliseconds: 200),
          child: Wrap(
            alignment: WrapAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      onSubmitted: onSubmitted,
                      enabled: enabled,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Enter your guess',
                        labelStyle: TextStyle(
                          color: theme.colorScheme.onPrimary,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      style: TextStyle(color: theme.colorScheme.onPrimary),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HistoryListView extends StatefulWidget {
  const HistoryListView({super.key});

  @override
  State<HistoryListView> createState() => _HistoryListViewState();
}

class _HistoryListViewState extends State<HistoryListView> {
  final _key = GlobalKey<AnimatedListState>();

  static const Gradient _maskingGradient = LinearGradient(
    colors: [Colors.transparent, Colors.black],
    stops: [0.0, 0.5],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    appState.historyListKey = _key;

    return ShaderMask(
      shaderCallback: (bounds) => _maskingGradient.createShader(bounds),
      blendMode: BlendMode.dstIn,
      child: AnimatedList(
        key: _key,
        reverse: true,
        padding: EdgeInsets.only(top: 100),
        initialItemCount: appState.guesses.length,
        itemBuilder: (context, index, animation) {
          final guess = appState.guesses[index];
          return SizeTransition(
            sizeFactor: animation,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Guess: ${guess.value}'),
                  SizedBox(width: 10),
                  Text(guess.feedback),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
