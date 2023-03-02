import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as gc;
// import 'package:geocoder/geocoder.dart';
// import 'package:flutter_geocoder/geocoder.dart' as gc;

int _dayIndex = 0;
Color? _colorBar;

double? _latitude, _longitude, _qibla;
DateTime _fajrTime = DateTime.now(),
    _dhuhrTime = DateTime.now(),
    _asrTime = DateTime.now(),
    _maghribTime = DateTime.now(),
    _ishaTime = DateTime.now(),
    _midNight = DateTime.now(),
    _thirdNight = DateTime.now(),
    _isyraqTime = DateTime.now();
// _dhuhaTime = DateTime.now();

String _nowEvent = '', _nextEvent = '', _cityName = '';

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
  Timer? timer;

  @override
  void initState() {
    super.initState();
    initialization();
    timer = Timer.periodic(const Duration(minutes: 1), (Timer timer) {
      whatTime();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _colorBar,
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
                PopupMenuItem(
                  child: const Text("Color"),
                  onTap: () {
                    if (_dayIndex == 0) {
                      _colorBar = Colors.deepPurple.shade400;
                    } else if (_dayIndex == 1) {
                      _colorBar = Colors.green.shade400;
                    } else if (_dayIndex == 2) {
                      _colorBar = Colors.amber.shade600;
                    } else if (_dayIndex == 3) {
                      _colorBar = Colors.deepOrange.shade300;
                    } else {
                      _colorBar = Colors.indigo.shade400;
                    }
                    _dayIndex++;
                    if (_dayIndex > 4) {
                      _dayIndex = 0;
                    }
                    setState(() {});
                  },
                ),
              ];
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(children: [
            Container(
              height: 200,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: _colorBar,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '',
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        _nowEvent,
                        style: const TextStyle(color: Colors.white),
                        textScaleFactor: 2,
                      ),
                      Text(
                        _nextEvent,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _cityName,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Text('latitude: $_latitude'),
            Text('longitude: $_longitude'),
            Text('fajr: ${DateFormat.Hm().format(_fajrTime)}'),
            Text('isyraq: ${DateFormat.Hm().format(_isyraqTime)}'),
            Text('dhuhr: ${DateFormat.Hm().format(_dhuhrTime)}'),
            Text('asr: ${DateFormat.Hm().format(_asrTime)}'),
            Text('maghrib: ${DateFormat.Hm().format(_maghribTime)}'),
            Text('isha: ${DateFormat.Hm().format(_ishaTime)}'),
            Text('midnight: ${DateFormat.Hm().format(_midNight)}'),
            Text('thirdnight: ${DateFormat.Hm().format(_thirdNight)}'),
            Text('qibla direction: $_qibla'),
          ]),
        ),
      ),
    );
  }

  void initialization() async {
    //### colorbar ###

    int time = int.parse(DateFormat.H().format(DateTime.now()));
    if (time >= 3 && time < 6) {
      _colorBar = Colors.deepPurple.shade400;
      _dayIndex = 0;
    } else if (time >= 6 && time < 15) {
      _colorBar = Colors.green.shade400;
      _dayIndex = 1;
    } else if (time >= 15 && time < 18) {
      _colorBar = Colors.amber.shade600;
      _dayIndex = 2;
    } else if (time >= 18 && time < 20) {
      _colorBar = Colors.deepOrange.shade300;
      _dayIndex = 3;
    } else {
      _colorBar = Colors.indigo.shade400;
      _dayIndex = 4;
    }

    //### location ###
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationData = await location.getLocation();
    _latitude = locationData.latitude!;
    _longitude = locationData.longitude!;

    List<gc.Placemark> placemarks =
        await gc.placemarkFromCoordinates(_latitude ?? 0, _longitude ?? 0);

    _cityName = placemarks.first.locality ?? '';

    //### adhan ###

    final myCoordinates = Coordinates(_latitude ?? 0, _longitude ?? 0);
    final params = CalculationMethod.singapore.getParameters();
    params.madhab = Madhab.shafi;
    final prayerTimes = PrayerTimes.today(myCoordinates, params);
    final sunnahTimes = SunnahTimes(prayerTimes);
    final qibla = Qibla(myCoordinates);

    _fajrTime = prayerTimes.fajr;
    _isyraqTime = prayerTimes.sunrise;
    _dhuhrTime = prayerTimes.dhuhr;
    _asrTime = prayerTimes.asr;
    _maghribTime = prayerTimes.maghrib;
    _ishaTime = prayerTimes.isha;
    _midNight = sunnahTimes.middleOfTheNight;
    _thirdNight = sunnahTimes.lastThirdOfTheNight;
    _qibla = qibla.direction;

    whatTime();

    setState(() {});

    FlutterNativeSplash.remove();
  }

  void whatTime() {
    //### whatime ###
    final now = DateTime.now();
    Duration? nextDuration;
    String? nextEventName;

    if (now.isBefore(_isyraqTime)) {
      _nowEvent = 'Subuh';
      nextEventName = 'Isyraq';
      nextDuration = _isyraqTime.difference(now);
    } else if (now.isBefore(_isyraqTime.add(const Duration(minutes: 15)))) {
      nextDuration =
          _isyraqTime.subtract(const Duration(minutes: 15)).difference(now);
      _nowEvent = 'Isyraq';
      nextEventName = 'Dhuha';
    } else if (now.isBefore(_dhuhrTime.subtract(const Duration(minutes: 15)))) {
      nextDuration = _dhuhrTime.difference(now);
      _nowEvent = 'Dhuha';
      nextEventName = 'Dzuhur';
    } else if (now.isBefore(_asrTime)) {
      nextDuration = _asrTime.difference(now);
      _nowEvent = 'Dzuhur';
      nextEventName = 'Ashar';
    } else if (now.isBefore(_maghribTime)) {
      nextDuration = _maghribTime.difference(now);
      _nowEvent = 'Ashar';
      nextEventName = 'Maghrib';
    } else if (now.isBefore(_ishaTime)) {
      nextDuration = _ishaTime.difference(now);
      _nowEvent = 'Maghrib';
      nextEventName = 'Isya';
    } else {
      _nowEvent = 'Isya';
      nextEventName = 'Subuh';
    }

    if (nextDuration!.inHours > 0) {
      _nextEvent = '${nextDuration.inHours} jam ';
    } else {
      _nextEvent = '';
    }

    if (nextDuration.inMinutes > 0) {
      _nextEvent =
          '$_nextEvent${(nextDuration.inMinutes - (nextDuration.inHours * 60))} menit $nextEventName';
    }
  }
}
