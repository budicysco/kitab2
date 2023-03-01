// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

var _temaIkon = Icons.dark_mode;
var _temaMode = 0;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData(
        // primaryColor: Colors.amber.shade50,
        appBarTheme: const AppBarTheme(
          foregroundColor: Colors.black,
        ),
        brightness: Brightness.light,
        accentColor: Colors.black,
        scaffoldBackgroundColor: const Color(0xffffffcc),
      ),
      dark: ThemeData(
        // primaryColor: Colors.black,
        appBarTheme: const AppBarTheme(
          foregroundColor: Colors.white,
        ),
        brightness: Brightness.dark,
        accentColor: Colors.white,
        scaffoldBackgroundColor: const Color(0xff222222),
      ),
      initial: AdaptiveThemeMode.system,
      builder: (theme, darkTheme) => MaterialApp(
        title: 'Kitab Aswaja',
        theme: theme,
        darkTheme: darkTheme,
        home:
            const MyHomePage(title: 'Ahad, 1 Januari 2021 (1 Muharram 1444H)'),
      ),
    );
    // return MaterialApp(
    //   title: 'Flutter Demo',
    //   theme: ThemeData(
    //     primarySwatch: Colors.blue,
    //   ),
    //   home: const MyHomePage(title: 'Flutter Demo Home Page'),
    // );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
      AdaptiveTheme.of(context).toggleThemeMode();
    });
  }

  @override
  void initState() {
    super.initState();
    initialization();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          textScaleFactor: 0.7,
        ),
        elevation: 0,
        backgroundColor: const Color(0x00000000),
        actions: [
          PopupMenuButton(
              icon: const Icon(Icons.more_vert_outlined),
              tooltip: 'More...',
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    value: 0,
                    child: Icon(_temaIkon),
                    onTap: () {
                      if (_temaMode == 0) {
                        AdaptiveTheme.of(context).setLight();
                        setState(() {
                          _temaIkon = Icons.dark_mode_outlined;
                          _temaMode = 1;
                        });
                      } else if (_temaMode == 1) {
                        AdaptiveTheme.of(context).setDark();
                        setState(() {
                          _temaIkon = Icons.dark_mode_outlined;
                          _temaMode = 2;
                        });
                      } else {
                        AdaptiveTheme.of(context).setSystem();
                        setState(() {
                          _temaIkon = Icons.light_mode_outlined;
                          _temaMode = 0;
                        });
                      }
                    },
                  ),
                  const PopupMenuItem(
                    value: 1,
                    child: Text("Settings"),
                  ),
                  const PopupMenuItem(
                    value: 2,
                    child: Text("Logout"),
                  ),
                ];
              },
              onSelected: (value) {
                if (value == 0) {
                  print("My account menu is selected.");
                } else if (value == 1) {
                  print("Settings menu is selected.");
                } else if (value == 2) {
                  print("Logout menu is selected.");
                }
              }),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  void initialization() async {
    print('ready in 3...');
    await Future.delayed(const Duration(seconds: 1));
    print('ready in 2...');
    await Future.delayed(const Duration(seconds: 1));
    print('ready in 1...');
    await Future.delayed(const Duration(seconds: 1));
    print('go!');
    FlutterNativeSplash.remove();
  }
}
