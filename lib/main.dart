import 'dart:developer';
import 'package:exemplo_push/firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:exemplo_push/components/component_notification.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/models.dart';
import 'firebase_options.dart';

// Manipulando mensagens em segundo plano
Future<void> _firebaseMessagingBackground(RemoteMessage message) async {
  log('Mensagem de segundo plano ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _totalNotifications;
  late FirebaseMessaging _messaging;
  PushNotificationModel? _notificationInfo;

  void registerNotification() async {
    await Firebase.initializeApp();
    _messaging = FirebaseMessaging.instance;

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackground);

    NotificationSettings settings = await _messaging.requestPermission(
        alert: true, badge: true, provisional: false, sound: true);

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('Usuário está permitido');

      //Para lidar com as notificações recebidas
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        log('Titulo da mensagem: ${message.notification?.title}, corpo: ${message.notification?.body}, data: ${message.data}');

        // Converte as mensagens recebidas
        PushNotificationModel notification = PushNotificationModel(
            title: message.notification?.title,
            body: message.notification?.body,
            dataTitle: message.data['title'],
            dataBody: message.data['body']);

        setState(() {
          _notificationInfo = notification;
          _totalNotifications++;
        });

        if (_notificationInfo != null) {
          // Para exibir as notificações
          showSimpleNotification(
            Text(_notificationInfo!.title!),
            leading: ComponentNotification(notification: _totalNotifications),
            subtitle: Text(_notificationInfo!.body!),
            background: Colors.blueAccent,
            duration: const Duration(seconds: 2),
          );
        }
      });
    } else {
      log('Sem permissão');
    }
  }

  checkForInitialMessage() async {
    await Firebase.initializeApp();
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      PushNotificationModel notificationModel = PushNotificationModel(
          title: initialMessage.notification?.title,
          body: initialMessage.notification?.body,
          dataTitle: initialMessage.data['title'],
          dataBody: initialMessage.data['body']);

      setState(() {
        _notificationInfo = notificationModel;
        _totalNotifications++;
      });
    }
  }

  @override
  void initState() {
    _totalNotifications = 0;
    registerNotification();
    checkForInitialMessage();

    // Para lidar com o app quando estiver em segundo plano e a notificação é tocada
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage remoteMessage) {
      PushNotificationModel pushNotificationModel = PushNotificationModel(
          title: remoteMessage.notification?.title,
          body: remoteMessage.notification?.body,
          dataTitle: remoteMessage.data['title'],
          dataBody: remoteMessage.data['body']);

      setState(() {
        _notificationInfo = pushNotificationModel;
        _totalNotifications++;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Push Notification'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Pushes Notifications:'),
            const SizedBox(height: 12.0,),
            ComponentNotification(notification: _totalNotifications),
            const SizedBox(height: 12.0,),
            _notificationInfo != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Titulo: ${_notificationInfo!.dataTitle ?? _notificationInfo!.title}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 8.0,),
                      Text(
                        'Conteúdo da Mensagem: ${_notificationInfo!.dataBody ?? _notificationInfo!.body}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))
                    ],
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
