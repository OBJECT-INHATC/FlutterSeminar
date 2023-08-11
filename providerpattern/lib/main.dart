import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:providerpattern/providers/p_group.dart';

import 'models/m_auth.dart';
import 'providers/p_auth.dart';
import '/screens/s_login.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // 세부 내용이 필요한 경우 추가...
}

void initializeNotification() async {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(const AndroidNotificationChannel(
      'high_importance_channel', 'high_importance_notification',
      importance: Importance.max));

  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings("@mipmap/ic_launcher"),
    )
  );

  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: true,
    badge: true,
    carPlay: true,
    criticalAlert: true,
    provisional: true,
    sound: true,
  );

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    RemoteNotification? notification = message.notification;

    if (notification != null) {
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'high_importance_notification',
              importance: Importance.max,
            ),
          ),
          payload: message.data['test_paremeter1']);
      print("수신자 측 메시지 수신");
    }
  });

  RemoteMessage? message = await FirebaseMessaging.instance.getInitialMessage();
  if (message != null) {
    // 액션 부분 -> 파라미터는 message.data['test_parameter1'] 이런 방식으로...
  }
}


Future<void> main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  initializeNotification();

  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => AuthStore( AuthModel( Dio())),
          ),
          ChangeNotifierProvider(
            create: (context) => GroupStore()
          ),
        ],
        child: MaterialApp(
          title: 'Provider Example',
          theme: ThemeData(
          primarySwatch: Colors.blue,
          ), home: MyApp(),
      ),
  )
  );
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var messageString = "";

  void getMyDeviceToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    print("내 디바이스 토큰: $token");
  }

  @override
  void initState() {
    // 디바이스 토큰을 가져오는 함수 호출
    getMyDeviceToken();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LoginPage();
  }
}
