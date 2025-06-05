import 'dart:async';

import 'package:flutter/material.dart';
import 'package:push_notification_test/view/notification/notification_view.dart';

void main() async {
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const MyApp());
  }, (error, stackTrace) {
    print('error: $error');
    print('stackTrace: $stackTrace');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Notification Test',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: NotificationView(),
    );
  }
}
