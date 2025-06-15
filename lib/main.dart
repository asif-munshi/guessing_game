import 'dart:math';
import 'package:flutter/material.dart';
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

class MyAppState extends ChangeNotifier {
  int randomNumber = Random().nextInt(99) + 1;

  void randomNumberGenerator() {
    randomNumber = Random().nextInt(99) + 1;
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    int number = appState.randomNumber;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            BigCard(number: number),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () => appState.randomNumberGenerator(),
              icon: Icon(Icons.refresh_rounded),
              label: const Text('Generate'),
            ),
          ],
        ),
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({super.key, required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: AnimatedSize(
          duration: Duration(milliseconds: 200),
          child: MergeSemantics(
            child: Wrap(
              children: [
                Column(
                  children: [
                    Text(
                      'The Random Generated Number:',
                      style: style.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: kDefaultFontSize,
                      ),
                    ),
                    Text(
                      number.toString(),
                      style: style.copyWith(fontWeight: FontWeight.w200),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
