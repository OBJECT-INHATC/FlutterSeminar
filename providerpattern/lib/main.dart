import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:providerpattern/color_schemes.g.dart';
import 'package:providerpattern/firebase_options.dart';
import 'package:providerpattern/providers/p_group.dart';
import 'package:providerpattern/screens/s_chat.dart';
import 'package:providerpattern/screens/s_home.dart';
import 'package:providerpattern/service/sv_auth.dart';
import 'models/m_auth.dart';
import 'providers/p_auth.dart';
import '/screens/s_login.dart';

/// 백 그라운드 메시지 수신 -> 호출 콜백 함수
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (message != null && message.notification != null) {
    // 클릭 시의 동작 처리
    print("백그라운드 도착");
    // 적절한 처리 코드 추가
  }
}


// 알림 클릭 콜백 함수
Future<void> selectNotification(String? payload) async {
  if (payload != null) {
    print('페이로드 받음');
    Map<String, dynamic> data = json.decode(payload);
    // payload를 분석하여 원하는 페이지로 이동하는 로직을 수행
    if (data['id'] == '1') {
      print("채팅방 이동 ");
      // Navigate to the chat message screen
      Navigator.push(
        MyApp.navigatorKey.currentContext!,
        MaterialPageRoute(builder: (context) => ChatPage(
          groupId: data['groupId'],
          groupName: data['groupName'],
          userName: 'testtest',
        )),
      );
    } else {
      // Navigate to the create group screen
      print('group');
    }
  }
}

void showFlutterNotification(RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  if (notification != null) {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
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
      payload: json.encode(message.data),
    );
  }
}

/// 앱 실행 시 초기화 함수
Future<void> initializeNotification() async {

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// 채널 생성
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(const AndroidNotificationChannel(
      'high_importance_channel', 'high_importance_notification',
      importance: Importance.max));

  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings("@mipmap/ic_launcher"),
    ),
      onSelectNotification: selectNotification
  );

  /// 알림 권한 요청
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: true,
    badge: true,
    carPlay: true,
    criticalAlert: true,
    provisional: true,
    sound: true,
  );

  /// 포그라운드 상태에서 알림을 받을 수 있도록 설정
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );



  /// 포어그라운드 알림 수신 시 호출되는 콜백 함수
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
        payload: json.encode(message.data),
      );
    }
  });

  /// Background 또는 Terminated 상태에서 알림 처리
  RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    flutterLocalNotificationsPlugin.show(
      initialMessage.hashCode,
      initialMessage.notification!.title,
      initialMessage.notification!.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'high_importance_notification',
          importance: Importance.max,
        ),
      ),
      payload: json.encode(initialMessage.data),
    );
  }

}

/// 앱 실행
Future<void> main() async{

  /// .env 파일을 읽어서 환경변수를 설정
  await dotenv.load(fileName: ".env"); // Replace with your custom file name

  /// Firebase 초기화
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  /// 얘는 모르곘음
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  /// 알림 초기화
  await initializeNotification();

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
          navigatorKey: MyApp.navigatorKey,
          title: 'Provider Example',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightColorScheme,
          ), home: MyApp(),
      ),
  )
  );
}

class MyApp extends StatefulWidget {
  static final navigatorKey = GlobalKey<NavigatorState>();

  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// 푸시 메시지 저장 변수
  var messageString = "";

  /// 디바이스 토큰을 가져오는 함수
  void getMyDeviceToken() async {
    var token = await FirebaseMessaging.instance.getToken();
    print(token);
    if(!mounted) return;
    await Provider.of<AuthStore>(context, listen: false).saveToken(token.toString());
  }

  ///로그인 체크
void checkLogin() async{
    var result = await AuthService().checkUserAvailable();

    if(result){

      if(!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }

  }

  @override
  void initState() {
    getMyDeviceToken();
    checkLogin();

    // foreground 수신처리
    FirebaseMessaging.onMessage.listen(showFlutterNotification);
    // background 수신처리
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    super.initState();

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

  }

  @override
  Widget build(BuildContext context) {
    return LoginPage();
  }
}
