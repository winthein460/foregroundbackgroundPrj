import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:foreground_background_prj/background_service.dart';
import 'package:foreground_background_prj/notification_helper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
 
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
AndroidNotificationChannel downloadChannel = AndroidNotificationChannel('download_channel', 'Download Channel');
AndroidNotificationChannel messageChannel = AndroidNotificationChannel('message_channel', 'Message Channel');
final andriodPlugin = flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
    AndroidFlutterLocalNotificationsPlugin>();
await andriodPlugin?.createNotificationChannel(downloadChannel);
await andriodPlugin?.createNotificationChannel(messageChannel);
//await andriodPlugin?.createNotificationChannelGroup(AndroidNotificationChannelGroup(id, name))
 await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });
await requestLocationPermission();
await NotificationHelper.initialize();
await initializeService();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String status = "Stop Service";
  Timer? timer;

@override
  void initState() {
    timer =  Timer.periodic(Duration(seconds: 3), (tick) async {
      Position position = await Geolocator.getCurrentPosition();
      print("${position.latitude},${position.longitude}");
    });
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
           
            ElevatedButton(
              onPressed: () {
                FlutterBackgroundService().invoke('setAsForeground');
              },
              child: Text("Foreground Service"),
            ),
            ElevatedButton(
              onPressed: () {
                FlutterBackgroundService().invoke('setAsBackground');
              },
              child: Text("Background Service"),
            ),
            ElevatedButton(
              onPressed: () async {
                 startBackgroundService();
                // bool isRunning = await service.isRunning();
                // if (isRunning) {
                //   stopBackgroundService();
                //   status = "Start Service";
                // } else {
                //   startBackgroundService();
                //   status = "Stop Service";
                // }
                // setState(() {});
              },
              child: Text("Start Service"),
            ),
          ],
        ),
      ),
    );
  }
}

void startBackgroundService() {
  final service = FlutterBackgroundService();
  service.startService();
}

void stopBackgroundService() {
  final service = FlutterBackgroundService();
  service.invoke("stop");
}

Future<Position> determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {

    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
      'Location permissions are permanently denied, we cannot request permissions.');
  }

  return await Geolocator.getCurrentPosition();
}

Future<void> requestLocationPermission() async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.whileInUse) {
    permission = await Geolocator.requestPermission(); // Ask "Always allow"
  }

  if (permission != LocationPermission.always) {
    print("Background location permission not granted");
  }
}

