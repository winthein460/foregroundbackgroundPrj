import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:foreground_background_prj/notification_helper.dart';
import 'package:geolocator/geolocator.dart';
Future<void> initializeService() async{
  final service = FlutterBackgroundService();
  await service.configure(iosConfiguration: IosConfiguration(
    autoStart: true,
    onForeground: onStart,
    onBackground:  onIosBackground,
  ), androidConfiguration: AndroidConfiguration(onStart: onStart, isForegroundMode: true,autoStart: false,notificationChannelId: 'download_channel',foregroundServiceNotificationId: 11,autoStartOnBoot: false));
}
@pragma('vm:entry-point')
Future<void> onStart(ServiceInstance service) async {
 DartPluginRegistrant.ensureInitialized();
//   await Future.delayed(Duration(seconds: 1));
//  for (var i = 1; i <= 100; i++) {
//   await NotificationHelper.show(i);
//   await Future.delayed(Duration(milliseconds: 500));
//  }
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event){
       print("forground service");
       service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((event){
       print("background service");
       service.setAsBackgroundService();
    });
  }
   service.on("stop").listen((event) {
    service.stopSelf();
    print("background process is now stopped");
  });
  service.on("start").listen((event) {});
  Timer.periodic(Duration(seconds: 3), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        print("Hello Noti");
       
        service.setForegroundNotificationInfo(title: "Testing My Project",content: "Foreground Notification Work${DateTime.now().second}");
       
      }
    }
    
   print("service is successfully running ${DateTime.now().second}");
   try {
      Position position =await Geolocator.getCurrentPosition();
      print("Background${position.latitude},${position.longitude}");
      await NotificationHelper.show(position.latitude.round());
      await NotificationHelper.showMessage();
   } catch (e) {
     print(e);
   }
    service.invoke('update');
  });
}
@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}