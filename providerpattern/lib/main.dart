import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:providerpattern/providers/p_group.dart';
import 'models/m_auth.dart';
import 'providers/p_auth.dart';
import '/screens/s_login.dart';

/// 백 그라운드 메시지 수신 -> 호출 콜백 함수
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

/// 앱 실행 시 초기화 함수
void initializeNotification() async {

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
    )
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

  /// 알림 수신 시 호출되는 콜백 함수
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    RemoteNotification? notification = message.notification;

    if (notification != null) {

      /// 알림을 받았을 때 실행되는 부분
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

  /// 앱이 종료된 상태에서 알림을 클릭했을 때 실행되는 부분
  RemoteMessage? message = await FirebaseMessaging.instance.getInitialMessage();
  if (message != null) {
    // 액션 부분 -> 파라미터는 message.data['test_parameter1'] 이런 방식으로...
  }
}

/// 앱 실행
Future<void> main() async{

  /// .env 파일을 읽어서 환경변수를 설정
  await dotenv.load(fileName: ".env"); // Replace with your custom file name

  /// Firebase 초기화
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  /// 알림 초기화
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
  /// 푸시 메시지 저장 변수
  var messageString = "";

  /// 디바이스 토큰을 가져오는 함수
  void getMyDeviceToken() async {
    var token = await FirebaseMessaging.instance.getToken();
    print(token);
    if(!mounted) return;
    await Provider.of<AuthStore>(context, listen: false).saveToken(token.toString());
  }

  @override
  void initState() {
    getMyDeviceToken();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LoginPage();
  }
}
