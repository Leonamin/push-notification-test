import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:push_notification_test/notification_view_model.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Notification Test',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: NotificationTestScreen(),
    );
  }
}

class NotificationTestScreen extends StatefulWidget {
  const NotificationTestScreen({super.key});

  @override
  State<NotificationTestScreen> createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends State<NotificationTestScreen> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final TextEditingController messageController = TextEditingController();
  final TextEditingController secondsController = TextEditingController();

  final NotificationViewModel notificationViewModel = NotificationViewModel();
  final NotificationViewModel notificationViewModel2 = NotificationViewModel();

  @override
  void initState() {
    super.initState();
    notificationViewModel.init();
  }

  Future<void> _handleScheduleNotification() async {
    final String message = messageController.text;
    final int? seconds = int.tryParse(secondsController.text);

    if (message.isEmpty || seconds == null || seconds <= 0) {
      print('Invalid input');
      return;
    }

    notificationViewModel2.scheduleNotification(
      NotificationPayload(
        title: '예약 알림',
        body: message,
      ),
      DateTime.now().add(Duration(seconds: seconds)),
    );
  }

  Future<void> _handleShowImmediateNotification() async {
    final String message = messageController.text;
    if (message.isEmpty) {
      print('Invalid input');
      return;
    }

    notificationViewModel2.showNotification(
      NotificationPayload(
        title: '즉시 알림',
        body: message,
      ),
    );
  }

  @override
  void dispose() {
    messageController.dispose();
    secondsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        print('unfocus');
      },
      child: Scaffold(
        appBar: AppBar(title: Text('푸시 예약 테스트')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            spacing: 24,
            children: [
              TextField(
                controller: messageController,
                decoration: InputDecoration(labelText: '메시지 내용'),
              ),
              TextField(
                controller: secondsController,
                decoration: InputDecoration(labelText: '몇 초 후 알림 보낼지'),
                keyboardType: TextInputType.number,
              ),
              ElevatedButton(
                onPressed: _handleScheduleNotification,
                child: Text('푸시 예약하기'),
              ),
              ElevatedButton(
                onPressed: _handleShowImmediateNotification,
                child: Text('푸시 즉시 보내기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
