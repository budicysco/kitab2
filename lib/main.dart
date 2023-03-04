import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as gc;

Color _colorTop = const Color(0xff67d3ef),
    _colorBottom = const Color(0xffbdf9ff);
String _nowEvent = '', _nextEvent = '', _cityName = '';

double _latitude = 0, _longitude = 0, _qibla = 0;

DateTime _fajr = DateTime.now(),
    _sunrise = DateTime.now(),
    _dhuhr = DateTime.now(),
    _asr = DateTime.now(),
    _maghrib = DateTime.now(),
    _isha = DateTime.now(),
    _midnight = DateTime.now(),
    _latenight = DateTime.now();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData(
        brightness: Brightness.light,
      ),
      dark: ThemeData(
        brightness: Brightness.dark,
      ),
      initial: AdaptiveThemeMode.system,
      builder: (theme, darkTheme) => MaterialApp(
        title: 'Kitab Aswaja',
        home: const MyHomePage(),
        theme: theme,
        darkTheme: darkTheme,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    setColor();
    initialization();

    Timer.periodic(const Duration(minutes: 1), (timer) {
      whatTime();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _colorTop,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: const Text("Theme"),
                  onTap: () {
                    if (Theme.of(context).brightness == Brightness.dark) {
                      AdaptiveTheme.of(context).setLight();
                    } else {
                      AdaptiveTheme.of(context).setDark();
                    }
                  },
                ),
              ];
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Expanded(
          // child:
          SingleChildScrollView(
              child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 200),
                width: double.infinity,
                height: 5000,
                child: Column(children: [
                  Text('latitude: $_latitude'),
                  Text('longitude: $_longitude'),
                  Text('fajr: ${DateFormat.Hm().format(_fajr)}'),
                  Text('isyraq: ${DateFormat.Hm().format(_sunrise)}'),
                  Text('dhuhr: ${DateFormat.Hm().format(_dhuhr)}'),
                  Text('asr: ${DateFormat.Hm().format(_asr)}'),
                  Text('maghrib: ${DateFormat.Hm().format(_maghrib)}'),
                  Text('isha: ${DateFormat.Hm().format(_isha)}'),
                  Text('midnight: ${DateFormat.Hm().format(_midnight)}'),
                  Text('thirdnight: ${DateFormat.Hm().format(_latenight)}'),
                  Text('qibla direction: $_qibla'),
                ]),
              ),
            ],
          )),
          // ),
          Stack(
            // alignment: Alignment.topCenter,
            children: [
              Container(
                height: 100,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _colorTop,
                      _colorBottom,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.elliptical(100, 50),
                    bottomRight: Radius.elliptical(100, 50),
                  ),
                ),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _nowEvent,
                              textScaleFactor: 2,
                              style: const TextStyle(color: Colors.black),
                            ),
                            Text(
                              _nextEvent,
                              style: const TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _cityName,
                            style: const TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ]),
              ),
              Positioned(
                // top: 0,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: 70,
                    margin: const EdgeInsets.only(top: 60, bottom: 5),
                    width: 240,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0x19000000)),
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x55ffffff), Color(0xddeeeeee)],
                      ),
                    ),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Image.asset('assets/icon-kt.png'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Image.asset('assets/icon-pt.png'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Image.asset('assets/icon-qc.png'),
                          ),
                        ]),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  void initialization() async {
    LocationData locationData = await getLocation();

    setState(() {
      _latitude = locationData.latitude!;
      _longitude = locationData.longitude!;
    });

    List<gc.Placemark> placemarks =
        await gc.placemarkFromCoordinates(_latitude, _longitude);

    setState(() {
      _cityName = placemarks.first.locality!;
    });

    final myCoordinates = Coordinates(_latitude, _longitude);
    final params = CalculationMethod.singapore.getParameters();
    params.madhab = Madhab.shafi;
    var prayerTimes = PrayerTimes.today(myCoordinates, params);
    var sunnahTimes = SunnahTimes(prayerTimes);
    var qibla = Qibla(myCoordinates);

    setState(() {
      _fajr = prayerTimes.fajr;
      _sunrise = prayerTimes.sunrise;
      _dhuhr = prayerTimes.dhuhr;
      _asr = prayerTimes.asr;
      _maghrib = prayerTimes.maghrib;
      _isha = prayerTimes.isha;
      _midnight = sunnahTimes.middleOfTheNight;
      _latenight = sunnahTimes.lastThirdOfTheNight;
      _qibla = qibla.direction;
    });

    whatTime();

    FlutterNativeSplash.remove();
  }

  void whatTime() {
    final myCoordinates = Coordinates(_latitude, _longitude);
    final params = CalculationMethod.singapore.getParameters();
    params.madhab = Madhab.shafi;
    var prayerTimes = PrayerTimes.today(myCoordinates, params);
    var sunnahTimes = SunnahTimes(prayerTimes);
    var qibla = Qibla(myCoordinates);

    setState(() {
      _fajr = prayerTimes.fajr;
      _sunrise = prayerTimes.sunrise;
      _dhuhr = prayerTimes.dhuhr;
      _asr = prayerTimes.asr;
      _maghrib = prayerTimes.maghrib;
      _isha = prayerTimes.isha;
      _midnight = sunnahTimes.middleOfTheNight;
      _latenight = sunnahTimes.lastThirdOfTheNight;
      _qibla = qibla.direction;
    });

    final now = DateTime.now();
    Duration nextDuration = Duration.zero;
    String nextEventName = '';

    print(now.toString());

    setState(() {
      if (now.isBefore(_sunrise)) {
        _nowEvent = 'Subuh';
        nextEventName = 'Isyraq';
        nextDuration = _sunrise.difference(now);
      } else if (now.isBefore(_sunrise.add(const Duration(minutes: 15)))) {
        nextDuration =
            _sunrise.subtract(const Duration(minutes: 15)).difference(now);
        _nowEvent = 'Isyraq';
        nextEventName = 'Dhuha';
      } else if (now.isBefore(_dhuhr.subtract(const Duration(minutes: 15)))) {
        nextDuration = _dhuhr.difference(now);
        _nowEvent = 'Dhuha';
        nextEventName = 'Dzuhur';
      } else if (now.isBefore(_asr)) {
        nextDuration = _asr.difference(now);
        _nowEvent = 'Dzuhur';
        nextEventName = 'Ashar';
      } else if (now.isBefore(_maghrib)) {
        nextDuration = _maghrib.difference(now);
        _nowEvent = 'Ashar';
        nextEventName = 'Maghrib';
      } else if (now.isBefore(_isha)) {
        nextDuration = _isha.difference(now);
        _nowEvent = 'Maghrib';
        nextEventName = 'Isya';
      } else {
        _nowEvent = 'Isya';
        nextEventName = 'Subuh';
        if (_fajr.isBefore(_isha)) {
          _fajr = _fajr.add(const Duration(days: 1));
        }
        nextDuration = _fajr.difference(now);
      }

      if (nextDuration.inHours > 0) {
        _nextEvent = '${nextDuration.inHours} jam ';
      } else {
        _nextEvent = '';
      }
      if (nextDuration.inMinutes > 0) {
        _nextEvent =
            '$_nextEvent${(nextDuration.inMinutes - (nextDuration.inHours * 60))} menit $nextEventName';
      }
    });
  }

  void setColor() {
    final time = int.parse(DateFormat.H().format(DateTime.now()));
    // final dark = 999999;
    setState(() {
      if (time >= 3 && time < 6) {
        _colorTop = const Color(0xff3684a8);
        _colorBottom = const Color(0xffb0e2fb);
      } else if (time >= 6 && time < 10) {
        _colorTop = const Color(0xff4ea6bd);
        _colorBottom = const Color(0xffccf556 - 999999);
      } else if (time >= 10 && time < 16) {
        _colorTop = const Color(0xff67d3ef);
        _colorBottom = const Color(0xffbdf9ff);
      } else if (time >= 16 && time < 18) {
        _colorTop = const Color(0xfffc7cac);
        _colorBottom = const Color(0xfffef596);
      } else if (time >= 18 && time < 20) {
        _colorTop = const Color(0xff3a6b94);
        _colorBottom = const Color(0xffcab6f1);
      } else {
        _colorTop = const Color(0xff192936);
        _colorBottom = const Color(0xff274663);
      }
    });
  }
}

Future<LocationData> getLocation() async {
  Location location = Location();
  bool serviceEnabled;
  PermissionStatus permissionGranted;

  serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) {
      // return;
    }
  }

  permissionGranted = await location.hasPermission();
  if (permissionGranted == PermissionStatus.denied) {
    permissionGranted = await location.requestPermission();
    if (permissionGranted != PermissionStatus.granted) {
      // return;
    }
  }

  LocationData locationData = await location.getLocation();

  return locationData;
}
